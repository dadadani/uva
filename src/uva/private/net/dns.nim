## Module for resolving hostnames to IP addresses.

import ../utils, ../globals
import ../bindings/uv
import std/asyncfutures
import segfaults

proc c_strlen(a: cstring): csize_t {.importc: "strlen", header: "<string.h>",
                                     noSideEffect, raises: [], tags: [],
                                     forbids: [].}
when defined windows:
    import winlean
else:
    import posix

type PreferredAddrFamily* = enum
    IPv4
    IPv6
    Any

proc onResolved(req: ptr uv_getaddrinfo_t; status: cint; res: ptr AddrInfo) {.cdecl.} =
    echo "onResolved called"
    let fut = cast[Future[ptr AddrInfo]](req.data)
    GC_unref(fut)
    if status != 0:
        dealloc(req)
        if not isNil(res):
            uv_freeaddrinfo(res)
        fut.fail(returnException(status))
        return
    echo "onResolved completed"
    fut.complete(res)
    echo "onResolved freed"
    dealloc(req)

proc onResolvedStr(req: ptr uv_getaddrinfo_t; status: cint; res: ptr AddrInfo) {.cdecl.} =
    let fut = cast[Future[tuple[address: string, family: PreferredAddrFamily]]](req.data)
    GC_unref(fut)
    if status != 0:
        dealloc(req)
        if not isNil(res):
            uv_freeaddrinfo(res)
        fut.fail(returnException(status))
        return
    if res.ai_family == AF_INET:
        var address = newString(17)
        let ck = uv_ip4_name(cast[ptr Sockaddr_in](res.ai_addr), cstring(address), 16)
        if ck != 0:
            uv_freeaddrinfo(res)
            dealloc(req)
            fut.fail(returnException(ck))
            return
        fut.complete((address[0..<c_strlen(cstring(address))], IPv4))
    else:
        var address = newString(UV_IF_NAMESIZE)
        let ck = uv_ip6_name(cast[ptr Sockaddr_in6](res.ai_addr), cstring(address), UV_IF_NAMESIZE)
        if ck != 0:
            uv_freeaddrinfo(res)
            dealloc(req)
            fut.fail(returnException(ck))
            return
        fut.complete((address[0..<c_strlen(cstring(address))], IPv6))

    uv_freeaddrinfo(res)
    dealloc(req)


proc resolveAddr*(hostname: string, family: PreferredAddrFamily = Any): Future[tuple[address: string, family: PreferredAddrFamily]]  = 
    ## Resolves a hostname to an IP address.
    ## Returns a tuple of the IP address and the address family (IPv4 or IPv6).
    ## By default, both IPv4 and IPv6 addresses are returned.
    result = newFuture[tuple[address: string, family: PreferredAddrFamily]]("resolveAddr")

    var hints: AddrInfo
    if family == Any:
        hints.ai_family = AF_UNSPEC
    elif family == IPv4:
        hints.ai_family = AF_INET
    else:
        hints.ai_family = AF_INET6

    var resolver: ptr uv_getaddrinfo_t = cast[ptr uv_getaddrinfo_t](alloc(sizeof(uv_getaddrinfo_t)))
    GC_ref(result)
    resolver.data = cast[pointer](result)
    let r = uv_getaddrinfo(defaultLoop.loop, resolver, onResolvedStr, hostname, nil, addr hints)
    if r != 0:
        GC_unref(result)
        result.fail(returnException(r))

proc resolveAddrPtr*(hostname: string, family: PreferredAddrFamily = Any): Future[ptr AddrInfo] =
    ## Resolves a hostname to an IP address.
    ##
    ## Returns a pointer to an AddrInfo struct, useful for low level usage of the struct.
    ##
    ## Note: AddrInfo is managed by libuv and must be freed with `uv_freeaddrinfo` after use.
    result = newFuture[ptr AddrInfo]("resolveAddrPtr")
    var hints: AddrInfo
    if family == Any:
        hints.ai_family = AF_UNSPEC
    elif family == IPv4:
        hints.ai_family = AF_INET
    else:
        hints.ai_family = AF_INET6

    var resolver: ptr uv_getaddrinfo_t = cast[ptr uv_getaddrinfo_t](alloc(sizeof(uv_getaddrinfo_t)))
    GC_ref(result)
    resolver.data = cast[pointer](result)
    echo "resolving"
    let r = uv_getaddrinfo(defaultLoop.loop, resolver, onResolved, hostname, nil, addr hints)
    if r != 0:
        echo "failed"
        GC_unref(result)
        result.fail(returnException(r))



#echo waitFor resolveAddr("localhost", IPv6)