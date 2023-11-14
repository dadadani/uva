import ../utils, ../globals
import ../bindings/uv
import std/asyncfutures
when defined windows:
    import winlean
else:
    import posix

proc onResolved(req: ptr uv_getaddrinfo_t; status: cint; res: ptr AddrInfo) {.cdecl.} =
    if status != 0:
        echo "Error: ", uv_strerror(status)
        return
    echo "Resolved!"
    var str = newString(17)
    echo uv_ip4_name(cast[ptr Sockaddr_in](res.ai_addr), addr str[0], 16)
    echo "IP: ", str
proc main() = 

    var hints: AddrInfo
    hints.ai_family = AF_INET
    hints.ai_socktype = SOCK_STREAM
    hints.ai_protocol = IPPROTO_TCP
    hints.ai_flags = 0

    var resolver: uv_getaddrinfo_t
    echo "Resolving..."
    let r = uv_getaddrinfo(defaultLoop.loop, addr resolver, onResolved, cstring("irc.libera.chat"), cstring("6667"), addr hints)
    if r != 0:
        echo "Error: ", uv_strerror(r)
        return

    echo $uv_run(defaultLoop.loop, UV_RUN_DEFAULT) 

main()