import ../utils, ../globals
import ../bindings/uv
import std/net, std/asyncmacro, std/asyncfutures
import dns
from nativesockets import Port

when defined windows:
    import winlean
else: 
    import posix

type TCPConnection* = object
    stream: ptr uv_stream_t

proc onClose(handle: ptr uv_handle_t) {.cdecl.} =
    echo "Connection closed!"
    dealloc(handle)


proc onWrite(req: ptr uv_write_t; status: cint) {.cdecl.} = 
    if status < 0:
        raise newException(UVError, "uv_write failed: " & $uv_strerror(status))

    dealloc(req)

proc onAlloc(handle: ptr uv_handle_t; suggested_size: uint; buf: ptr uv_buf_t) {.cdecl.} =
    buf[] = uv_buf_init(cast[cstring](alloc(suggested_size)), cuint(suggested_size))

proc onRead(stream: ptr uv_stream_t; nread: culong; buf: ptr uv_buf_t) {.cdecl.} =
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

    err = uv_tcp_init(defaultLoop.loop, socket)
    if err != 0:
        dealloc(socket)
        raise newException(UVError, "uv_tcp_init failed: " & $uv_strerror(err))


    let connection = create(uv_connect_t, sizeof(uv_connect_t))
    err = uv_tcp_connect(connection, socket, cast[ptr Sockaddr](addr dest), onConnect)
    if err != 0:
        dealloc(socket)
        dealloc(connection)
        raise newException(UVError, "uv_tcp_connect failed: " & $uv_strerror(err))

proc resolveaddr(hostname: string, port: Port, dest: ptr Sockaddr_in): cint = 
    result = uv_ip4_addr(cstring(hostname), cint(port), dest)

type FailContext = ref object
    future: Future[TCPConnection]
    exception: ref Exception

proc onCloseFail(handle: ptr uv_handle_t) {.cdecl.} =
    let ctx = cast[FailContext](handle.data)
    GC_unref(ctx)
    dealloc(handle)
    ctx.future.fail(ctx.exception)

proc tcpConnectionOnWrite(req: ptr uv_write_t; status: cint) {.cdecl.} = 
    let fut = cast[Future[void]](req.data)
    GC_unref(fut)
    if status < 0:
        dealloc(req)
        fut.fail(returnException(status))
        return


    dealloc(req)
    fut.complete()

proc write*(connection: TCPConnection, data: string): Future[void] = 
    result = newFuture[void]("TCPConnection.write")
    var writer = create(uv_write_t, sizeof(uv_write_t))
    GC_ref(result)
    writer.data = cast[pointer](result)
    let buffer = [
        uv_buf_t(
            base: cstring(data),
            len: uint(data.len)
        )
    ]

    #GC_unref(result)
    #dealloc(writer)
    #result.fail(newException(Exception, "test"))
    #return

    let err = uv_write(writer, connection.stream, cast[UncheckedArray[uv_buf_t]](buffer), 1, tcpConnectionOnWrite)
    if err != 0:
        GC_unref(result)
        dealloc(writer)
        result.fail(returnException(err))

        

proc tcpConnectionOnConnect(req: ptr uv_connect_t, status: cint) {.cdecl.} = 
    let fut = cast[Future[TCPConnection]](req.data)
    GC_unref(fut)
    let stream = req.handle
    dealloc(req)
    
    if status < 0:
        let fail = FailContext(future: fut, exception: returnException(status))
        GC_ref(fail)
        stream.data = cast[pointer](fail)
        uv_close(cast[ptr uv_handle_t](stream), onCloseFail)
        return


    let err = uv_read_start(stream, onAlloc, onRead)
    if err != 0:
        let fail = FailContext(future: fut, exception: returnException(err))
        GC_ref(fail)
        stream.data = cast[pointer](fail)
        uv_close(cast[ptr uv_handle_t](stream), onCloseFail)
        return

    let res = TCPConnection(stream: stream)
    fut.complete(res)




proc dial*(hostname: string, port: Port): Future[TCPConnection] =
    result = newFuture[TCPConnection]("dial")
    
    var dest: Sockaddr_in

    var err = resolveaddr(hostname, port, addr dest)
    if err != 0:
        result.fail(returnException(err))
        return

    let socket = create(uv_tcp_t, sizeof(uv_tcp_t))

    err = uv_tcp_init(defaultLoop.loop, socket)
    if err != 0:
        dealloc(socket)
        result.fail(returnException(err))
        return

    let connection = create(uv_connect_t, sizeof(uv_connect_t))
    GC_ref(result)
    connection.data = cast[pointer](result)
    err = uv_tcp_connect(connection, socket, cast[ptr Sockaddr](addr dest), tcpConnectionOnConnect)
    if err != 0:
        dealloc(socket)
        dealloc(connection)
        GC_unref(result)
        result.fail(returnException(err))
        return
    


proc test() {.async.} =
    try:
        let connection = await dial("127.0.0.1", 8000.Port)
        await connection.write("GET / HTTP/1.1\n\n\n\n")
    except:
        echo "Error!"
        raise
        

for i in 0..3000:
    asyncCheck test()


runForever()
