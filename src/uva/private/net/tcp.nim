import ../utils, ../globals
import ../bindings/uv
import std/net, std/asyncmacro, std/asyncfutures
import resolveaddr
export PreferredAddrFamily
import ../streams
import ../handles
import std/importutils

from nativesockets import Port

when defined windows:
    import winlean
else: 
    import posix

type TCP* = ref object of Stream

type TCPServer* = distinct TCP

proc onConnectImpl(req: ptr uv_connect_t, status: cint) =
    let fut = cast[Future[TCP]](req.data)
    GC_unref(fut)
    let self = cast[TCP](req.handle.data)
    #GC_unref(self)
    let handle = req.handle
    dealloc(req)

    privateAccess(Handle)
    self.handle = cast[ptr uv_handle_s](handle)
    
    if status < 0:
        self.close().addCallback(proc () = 
            fut.fail(returnException(status))
        )

        return
    fut.complete(self)

proc onConnect(req: ptr uv_connect_t, status: cint) {.cdecl.} = 
    try:
        onConnectImpl(req, status)
    except:
        uv_stop(getLoop().loop)
        raise

proc `nodelay=`*(self: TCP, value: bool) =
    ## Enable/disable Nagle's algorithm.
    privateAccess(Handle)
    let err = uv_tcp_nodelay(cast[ptr uv_tcp_t](self.handle), value.cint)
    if err != 0:
        raise returnException(err)

proc dial*(hostname: string, port: Port, family = PreferredAddrFamily.Any, buffered = true): Future[TCP] =
    result = newFuture[TCP]("dial")
    GC_ref(result)
    var resultaddr = cast[pointer](result)

    resolveAddrPtr(hostname, family, $port).addCallback proc (fut: Future[ptr AddrInfo]) {.gcsafe.} =
        let result = cast[Future[TCP]](resultaddr)
        GC_unref(result)
        if fut.failed:
            result.fail(fut.error)
            return
        let dest = fut.read
        privateAccess(Stream)

        let self = TCP(buffered: buffered)
        let socket = create(uv_tcp_t, sizeof(uv_tcp_t))
        GC_ref(self)
        socket.data = cast[pointer](self)

        var err = uv_tcp_init(getLoop().loop, socket)
        if err != 0:
            dealloc(socket)
            result.fail(returnException(err))
            return

        let connection = create(uv_connect_t, sizeof(uv_connect_t))
        GC_ref(result)
        connection.data = cast[pointer](result)

        err = uv_tcp_connect(connection, socket, dest.ai_addr, onConnect)
        uv_freeaddrinfo(dest)
        if err != 0:
            dealloc(socket)
            dealloc(connection)
            GC_unref(result)
            result.fail(returnException(err))
            return

proc test() {.async.} =
    #echo "a:", await resolveAddr("127.0.0.1")
    let con = await dial("127.0.0.1", 8000.Port)
    echo "Connected!"
    await con.send("GET / HTTP/1.1\n\n\n\n")
    echo "Written!"
    var data = newString(1024)
    let read = await con.recvInto(addr data[0], data.len)

    echo data
    echo "xx len: ", data.len

    echo "Done!"
    await con.close()
    #await con.write("test")
when isMainModule:
    for i in 0..100:
        asyncCheck test()
    runForever()