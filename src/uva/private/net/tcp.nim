import ../utils, ../globals
import ../bindings/uv
import std/net, std/asyncfutures, std/asyncmacro
import resolveaddr
export PreferredAddrFamily
import ../streams
import ../handles
import std/importutils

from nativesockets import Port
export Port
when defined windows:
    import winlean
else: 
    import posix

type TCP* = ref object of Stream
 
type 
    TCPServer* = ref object of TCP
        callback: NewConnectionCallback
    NewConnectionCallback* = proc(server: TCPServer): Future[void]

proc onConnect(req: ptr uv_connect_t, status: cint) {.cdecl, used.} = 
    let fut = cast[Future[TCP]](req.data)
    GC_unref(fut)
    let self = cast[TCP](req.handle.data)
    GC_unref(self)
    privateAccess(Handle)
    let handle = req.handle
    dealloc(req)

    self.handle.handle = cast[ptr uv_handle_s](handle)

    if status < 0:
        self.close().addCallback(proc () = 
            fut.fail(returnException(status))
            uv_stop(getLoop().loop)
        )

        return
    fut.complete(self)
    privateAccess(Stream)



proc `nodelay=`*(self: TCP, value: bool) =
    ## Enable/disable Nagle's algorithm.
    privateAccess(Handle)
    let err = uv_tcp_nodelay(cast[ptr uv_tcp_t](self.handle), value.cint)
    if err != 0:
        raise returnException(err)

proc `keepalive=`*(self: TCP, delay: int) =
    ## Set the keep alive delay, in seconds. -1 to disable.
    privateAccess(Handle)
    if delay < 0:
        let err = uv_tcp_keepalive(cast[ptr uv_tcp_t](self.handle), 0, 0)
        if err != 0:
            raise returnException(err)
        return
    else:
        let err = uv_tcp_keepalive(cast[ptr uv_tcp_t](self.handle), 1, delay.cuint)
        if err != 0:
            raise returnException(err)

proc `simultaneousAccepts=`*(self: TCP, enable: bool) =
    ## Enable / disable simultaneous asynchronous accept requests that are queued by the operating system when listening for new TCP connections.
    privateAccess(Handle)
    let err = uv_tcp_simultaneous_accepts(cast[ptr uv_tcp_t](self.handle), enable.cint)
    if err != 0:
        raise returnException(err)

proc server*(hostname: string, port: Port, family = PreferredAddrFamily.Any): Future[TCPServer] =
    ## Create a new TCP server and bind it to the specified address and port.
    result = newFuture[TCPServer]("bind")
    GC_ref(result)
    var resultaddr = cast[pointer](result)

    resolveAddrPtr(hostname, family, $port).addCallback proc (fut: Future[ptr AddrInfo]) {.gcsafe.} =
        let result = cast[Future[TCPServer]](resultaddr)
        GC_unref(result)
        if fut.failed:
            result.fail(fut.error)
            return
        let dest = fut.read
        privateAccess(Stream)

        let self = TCPServer()
        let socket = create(uv_tcp_t, sizeof(uv_tcp_t))
        GC_ref(self)
        socket.data = cast[pointer](self)

        var err = uv_tcp_init(getLoop().loop, socket)
        if err != 0:
            dealloc(socket)
            result.fail(returnException(err))
            return

        err = uv_tcp_bind(socket, dest.ai_addr, 0)
        uv_freeaddrinfo(dest)
        if err != 0:
            dealloc(socket)
            result.fail(returnException(err))
            return

        privateAccess(Handle)
        self.handle.handle = cast[ptr uv_handle_s](socket)
        
        result.complete(self)


proc accept*(server: TCPServer): TCP =
    ## Accept incoming connections on a server.
    ## If the connection is accepted after receiving the callback, it is guaranteed that the function will complete successfully.
    ## Calling this function multiple times may return errors.
    privateAccess(Stream)
    result = TCP()


    privateAccess(Handle)
    result.handle.handle = cast[ptr uv_handle_s](create(uv_tcp_t, sizeof(uv_tcp_t)))
    var err = uv_tcp_init(getLoop().loop, cast[ptr uv_tcp_t](result.handle))
    if err != 0:
        dealloc(result.handle.handle)
        raise returnException(err)
    result.handle.handle.data = cast[pointer](result)
    GC_ref(result)

    err = uv_accept(cast[ptr uv_stream_t](server.handle), cast[ptr uv_stream_t](result.handle))
    if err != 0:
        uv_close(cast[ptr uv_handle_t](result.handle), nil)
        dealloc(result.handle.handle)
        raise returnException(err)

proc serverOnConnection(server: ptr uv_stream_t; status: cint) {.cdecl.} = 
    let self = cast[TCPServer](server.data)
    if status < 0:
        raise returnException(status)
    asyncCheck self.callback(self)

proc listen*(server: TCPServer, newConnectionCallback: NewConnectionCallback) =
    ## Start listening for incoming connections.
    privateAccess(Handle)
    let err = uv_listen(cast[ptr uv_stream_t](server.handle), 128, serverOnConnection)
    if err != 0:
        raise returnException(err)
    server.callback = newConnectionCallback

proc dial*(dest: ptr AddrInfo): Future[TCP] = 
    ## Create a new TCP connection and attempt to establish a connection to the specified AddrInfo.
    ## Note: the pointer is not automatically freed, you must call uv_freeaddrinfo after this function returns.
    result = newFuture[TCP]("dial")
    privateAccess(Stream)

    let self = TCP()

    let socket = create(uv_tcp_t, sizeof(uv_tcp_t))
    privateAccess(Handle)

    self.handle.handle = cast[ptr uv_handle_s](socket)
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
    if err != 0:
        dealloc(socket)
        dealloc(connection)
        GC_unref(result)
        result.fail(returnException(err))
        return
#[
proc dial*(hostname: string, port: Port, family = PreferredAddrFamily.Any, buffered = true, readCallback: ReadCallback = nil): Future[TCP] =
    ## Create a new TCP connection and attempt to establish a connection to the specified address and port.
    ## When disabling buffered mode, the readCallback must be set.
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
        if not buffered:
            if isNil(readCallback):
                result.fail(newException(Exception, "readCallback must be set if buffered is false"))
            self.readCallback = readCallback

        let socket = create(uv_tcp_t, sizeof(uv_tcp_t))
        privateAccess(Handle)

        self.handle.handle = cast[ptr uv_handle_s](socket)
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
]#

proc dial*(hostname: string, port: Port, family = PreferredAddrFamily.Any): Future[TCP] {.async.} =
    ## Create a new TCP connection and attempt to establish a connection to the specified address and port.
    let resolv = await resolveAddrPtr(hostname, family, $port)
    try:
        result = await dial(resolv)
    except:
        raise
    finally:
        uv_freeaddrinfo(resolv)
