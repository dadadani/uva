import ../utils, ../globals
import ../bindings/uv
from nativesockets import Port

type TCPServer = ref object
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

    var client: ptr uv_tcp_t = cast[ptr uv_tcp_t](alloc(sizeof(uv_tcp_t)))
    checkError uv_tcp_init(defaultLoop.loop, client)
    let err = uv_accept(server, cast[ptr uv_stream_t](client))
    if err < 0:
        echo "Error on accept: ", err
        uv_close(cast[ptr uv_handle_t](client), onClose)
        checkError(err)
        return
    else:
        checkError uv_read_start(cast[ptr uv_stream_t](client), allocBuffer, readCb)

proc main() = 
    var server: uv_tcp_t
    checkError uv_tcp_init(defaultLoop.loop, addr server)

    var adr: Sockaddr_in

    checkError uv_ip4_addr("0.0.0.0", 3534, addr adr)

    checkError uv_tcp_bind(addr server, cast[ptr SockAddr](addr adr), 0)

    checkError uv_listen(cast[ptr uv_stream_t](addr server), 128, onNewConnection)

    checkError uv_run(defaultLoop.loop, UV_RUN_DEFAULT)

main()