import ../utils, ../globals
import ../bindings/uv
import std/net, std/asyncmacro, std/asyncfutures
import resolveaddr
from nativesockets import Port

when defined windows:
    import winlean
else: 
    import posix

type TCPConnection* = object

proc onWrite(req: ptr uv_write_t; status: cint) {.cdecl.} = 
    if status < 0:
        raise newException(UVError, "uv_write failed: " & $uv_strerror(status))

    dealloc(req)

proc onAlloc(handle: ptr uv_handle_t; suggested_size: uint; buf: ptr uv_buf_t) {.cdecl.} =
    buf[] = uv_buf_init(cast[cstring](alloc(suggested_size)), cuint(suggested_size))

proc onClose(handle: ptr uv_handle_t) {.cdecl.} =
    echo "Connection closed!"
    dealloc(handle)

proc onRead(stream: ptr uv_stream_t; nread: int; buf: ptr uv_buf_t) {.cdecl.} =
    if nread > 0:
        echo "Received: ", buf.base
        dealloc(buf.base)
    else:
        dealloc(buf.base)
        uv_close(cast[ptr uv_handle_t](stream), onClose)

proc write*(stream: ptr uv_stream_t, data: string) =
    var writer = create(uv_write_t, sizeof(uv_write_t))

    let buffer = [
        uv_buf_t(
            base: cstring(data),
            len: uint(data.len)
        )
    ]

    let err = uv_write(writer, stream, cast[UncheckedArray[uv_buf_t]](buffer), 1, onWrite)
    if err != 0:
        raise newException(UVError, "uv_write failed: " & $uv_strerror(err))     

proc onConnect(req: ptr uv_connect_t, status: cint) {.cdecl.} = 
    let stream = req.handle
    dealloc(req)

    if status < 0:
        uv_close(cast[ptr uv_handle_t](stream), onClose)
        echo "Connection failed: ", uv_strerror(status)
        return
        #raise newException(UVError, "uv_tcp_connect failed: " & $uv_strerror(status))
        
    
    echo "Connected!"

    write(stream, "GET / HTTP/1.1\n\n\n\n")
    let err = uv_read_start(stream, onAlloc, onRead)
    if err != 0:
        raise newException(UVError, "uv_read_start failed: " & $uv_strerror(err))
    

proc connect(hostname: string, port: Port) =

    var dest: Sockaddr_in
    var err = uv_ip4_addr(cstring(hostname), cint(port), addr dest)
    if err != 0:
        raise newException(UVError, "uv_ip4_addr failed: " & $uv_strerror(err))
    
    
    let socket = create(uv_tcp_t, sizeof(uv_tcp_t))

    err = uv_tcp_init(getLoop().loop, socket)
    if err != 0:
        dealloc(socket)
        raise newException(UVError, "uv_tcp_init failed: " & $uv_strerror(err))


    let connection = create(uv_connect_t, sizeof(uv_connect_t))
    err = uv_tcp_connect(connection, socket, cast[ptr Sockaddr](addr dest), onConnect)
    if err != 0:
        dealloc(socket)
        dealloc(connection)
        raise newException(UVError, "uv_tcp_connect failed: " & $uv_strerror(err))

connect("127.0.0.1", 8000.Port)
connect("127.0.0.1", 8000.Port)
connect("127.0.0.1", 8000.Port)

runForever()
