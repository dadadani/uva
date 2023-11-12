import ../utils, ../globals
import ../bindings/uv
from nativesockets import Port

type TCPServer = ref object
    host: Sockaddr_in
    port: Port
    server: uv_tcp_t
    store: string


proc allocCb(handle: ptr uv_handle_t; suggested_size: uint; buf: ptr uv_buf_t) {.cdecl.} =
    let nvc = "test"
    echo "isnil chk: ", isNil(handle.data)
    
    echo "allocCb"
    buf.base = cast[ptr cchar](alloc(suggested_size))
    buf.len = suggested_size

proc onClose(handle: ptr uv_handle_t) {.cdecl.} =
    echo "onClose"
    dealloc(handle)

proc readCb(stream: ptr uv_stream_t; nread: int; buf: ptr uv_buf_t) {.cdecl.} =
    try:
        echo "x: ", nread
    except:
        echo "error, ", getCurrentExceptionMsg()

    echo "isnil chk1: ", isNil(stream.data)
    echo "get ", cast[TCPServer](stream.data).store

    echo "readCb"
    echo nread
    if nread < 0:
        if nread == UV_EOF:
            echo "EOF"
            uv_close(cast[ptr uv_handle_t](stream), onClose)
        else:
            echo "read error: ", nread
        checkError cint(nread)
        echo "read error"
    else:
        echo "read: ", nread
        let r = $buf.base
        echo "read: ", r[0..<nread]
    
    dealloc(buf.base)

proc onConnection(server: ptr uv_stream_t; status: cint) {.cdecl.} =
    try:
        checkError status

        echo "connection accepted"

        let connection = cast[ptr uv_tcp_t](alloc(sizeof(uv_tcp_t)))
        
        connection.data = server.data

        checkError uv_tcp_init(defaultLoop.loop, connection)
        checkError uv_tcp_init(defaultLoop.loop, connection)

        let chk = uv_accept(server, cast[ptr uv_stream_t](connection))
        if chk == 0:
            checkError uv_read_start(cast[ptr uv_stream_t](connection), allocCb, readCb)
        else:
            uv_close(cast[ptr uv_handle_t](connection), onClose)
    except:
        echo "error onConnection: ", getCurrentExceptionMsg()
        raise
proc bindTCPServer(host: string, port: Port): TCPServer =
    result = new(TCPServer)
    result.store = "test"
    result.port = port

    checkError uv_tcp_init(defaultLoop.loop, addr result.server)

    checkError uv_ip4_addr(cstring(host), cint(port), addr result.host) 

    checkError uv_tcp_bind(addr result.server, cast[ptr SockAddr](addr result.host), 0)

    checkError uv_listen(cast[ptr uv_stream_t](addr result.server), 128, onConnection)

    result.server.data = cast[pointer](result)

    echo "listening on port ", int(port)

echo "isnil: ", isnil(defaultLoop.loop)

let server = bindTCPServer("0.0.0.0", 3534.Port)

checkError uv_run(defaultLoop.loop, UV_RUN_DEFAULT)
