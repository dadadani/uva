import ../utils, ../globals
import ../bindings/uv
import std/net, std/asyncmacro, std/asyncfutures
import dns
from nativesockets import Port

when defined windows:
    import winlean
else: 
    import posix

type TCPServer = object
    host: Sockaddr_in
    port: Port
    server: uv_tcp_t
    store: string

proc allocBuffer(handle: ptr uv_handle_t; suggested_size: uint; buf: ptr uv_buf_t) {.cdecl.} =
    buf.base = cast[ptr cchar](alloc(suggested_size))
    buf.len = suggested_size

proc onClose(handle: ptr uv_handle_t) {.cdecl.} =
    dealloc(handle)

proc readCb(stream: ptr uv_stream_t; nread: int; buf: ptr uv_buf_t) {.cdecl.} = 
    if nread > 0:
        echo "Read: ", nread
        echo ($buf.base)[0..<nread]
    elif nread < 0:
        if nread == UV_EOF:
            echo "EOF"
            return
        echo "Error on read: ", nread
        uv_close(cast[ptr uv_handle_t](stream), onClose)
        checkError(cint(nread))
    
    dealloc(buf.base)

proc onNewConnection(server: ptr uv_stream_t; status: cint) {.cdecl.} = 
    if (status < 0):
        echo "Error on new connection: ", status
        checkError(status)
        return

    #var client: ptr uv_tcp_t = cast[ptr uv_tcp_t](alloc(sizeof(uv_tcp_t)))
    var client = new uv_tcp_t
    GC_ref(client)
    checkError uv_tcp_init(defaultLoop.loop, cast[ptr uv_tcp_t](client))
    let err = uv_accept(server, cast[ptr uv_stream_t](client))
    if err < 0:
        echo "Error on accept: ", err
        uv_close(cast[ptr uv_handle_t](client), onClose)
        checkError(err)
        return
    else:
        checkError uv_read_start(cast[ptr uv_stream_t](client), allocBuffer, readCb)

proc newTCPServer*(): TCPServer =

    checkError uv_tcp_init(defaultLoop.loop, addr result.server)


proc listen*(server: TCPServer, host: sink string, port: Port): Future[void] {.async.} =

    # first, try to parse the host as an ipv4

    var ip: SockAddr
    var ainfo: ptr AddrInfo
    var err = uv_ip4_addr(cstring(host), cint(port), cast[ptr Sockaddr_in](addr ip))
    if err != 0:
        var host = host # copy, for some reason without it the variable stops working. TODO: investigate
        # try ipv6
        err = uv_ip6_addr(cstring(host), cint(port), cast[ptr Sockaddr_in6](addr ip))
        if err != 0:
            # try to resolve the host
            ainfo = await resolveAddrPtr(host)
    
    if not isNil(ainfo):
        checkError uv_tcp_bind(addr server.server, ainfo.ai_addr, 0)
        uv_freeaddrinfo(ainfo)
    else:
        checkError uv_tcp_bind(addr server.server, cast[ptr SockAddr](addr ip), 0) 

    checkError uv_listen(cast[ptr uv_stream_t](addr server.server), 128, onNewConnection)



proc main() = 
    var server: uv_tcp_t
    checkError uv_tcp_init(defaultLoop.loop, addr server)

    var adr: Sockaddr_in

    checkError uv_ip4_addr("0.0.0.0", 3534, addr adr)

    checkError uv_tcp_bind(addr server, cast[ptr SockAddr](addr adr), 0)

    checkError uv_listen(cast[ptr uv_stream_t](addr server), 128, onNewConnection)

    checkError uv_run(defaultLoop.loop, UV_RUN_DEFAULT)


let sock = newTCPServer()
waitFor sock.listen("localhost", 3534.Port)
echo "Listening on"
runForever()
#main()


type TCPConnection = ref object
    handle: ref uv_tcp_t
    connection: ref uv_connect_t

proc onConnect(req: ptr uv_connect_t; status: cint) {.cdecl.} =
    let fut = cast[Future[TCPConnection]](req.data)
    let ctx = cast[TCPConnection](req.handle.data)
    if status != 0:
        uv_close(cast[ptr uv_handle_t](ctx.handle), onClose)
        fut.fail(returnException(status))
        return
    fut.complete(ctx)

proc dial*(host: string, port: Port): Future[TCPConnection] =
    echo "1"
    result = newFuture[TCPConnection]("dial")
    echo "2"

    var futaddr = addr result
    echo "3"

    let self = new TCPConnection
    echo "4"
    self.handle = new uv_tcp_t
    echo "5"
    self.connection = new uv_connect_t
    echo "6"
    var err = uv_tcp_init(defaultLoop.loop, cast[ptr uv_tcp_t](self.handle))
    echo "7"
    if err != 0:
        echo "8"
        result.fail(returnException(err))
        return

    # first, try to parse the host as an ipv4
    echo "9"
    var ip: SockAddr
    echo "10"
    #var ainfo: ptr AddrInfo
    err = uv_ip4_addr(cstring(host), cint(port), cast[ptr Sockaddr_in](addr ip))
    if err != 0:
        echo "11"
        var host = host # copy, for some reason without it the variable stops working. TODO: investigate
        # try ipv6
        echo "12"
        err = uv_ip6_addr(cstring(host), cint(port), cast[ptr Sockaddr_in6](addr ip))
        echo "13"
        if err != 0:
            # try to resolve the host
            #ainfo = await resolveAddrPtr(host)
            echo "14"
            resolveAddrPtr(host).callback = proc (ip: Future[ptr AddrInfo]) =
                    echo "16"
                    let ainfo = ip.read
                    echo "17"
                    err = uv_tcp_connect(cast[ptr uv_connect_t](self.connection), cast[ptr uv_tcp_t](self.handle), ainfo.ai_addr, onConnect)
                    echo "18"
                    uv_freeaddrinfo(ainfo)
                    uv_close(cast[ptr uv_handle_t](self.handle), onClose)
                    echo "19"
                    if err != 0:
                        echo "20"
                        futaddr[].fail(returnException(err))
            echo "15"
            return
    self.handle.data = cast[pointer](self)
    self.connection.data = cast[pointer](result)

    checkError uv_tcp_connect(cast[ptr uv_connect_t](self.connection), cast[ptr uv_tcp_t](self.handle), cast[ptr SockAddr](addr ip), onConnect) 

           
asyncCheck dial("google.com", 80.Port)
asyncCheck sleepAsync(5000)
runForever()