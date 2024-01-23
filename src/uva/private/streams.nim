import bindings/uv
import handles
import std/importutils
import std/asyncfutures
import utils


type 
    Stream* = ref object of Handle
        reportClosed: bool

        currentReadSize: int
        readBuffer: seq[uint8]
        readCallbackStr: Future[string]
        readCallbackPtr: Future[int]
        readPointer: pointer
        readPointerSize: int

proc close*(connection: Stream): Future[void] 

proc isActive*(connection: Stream): bool =
    ## Returns true if the stream is active.
    privateAccess(Handle)
    result = uv_is_active(cast[ptr uv_handle_t](connection.handle.handle)) != 0 and not connection.reportClosed

proc isReadable*(connection: Stream): bool =
    ## Returns true if the stream is readable.
    privateAccess(Handle)
    result = uv_is_readable(cast[ptr uv_stream_t](connection.handle.handle)) != 0

proc isWritable*(connection: Stream): bool =
    ## Returns true if the stream is writable.
    privateAccess(Handle)
    result = uv_is_writable(cast[ptr uv_stream_t](connection.handle.handle)) != 0

# --- Write ---

proc onWrite(req: ptr uv_write_t; status: cint) {.cdecl.} = 
    let fut = cast[Future[void]](req.data)
    GC_unref(fut)
    if status < 0:
        dealloc(req)
        fut.fail(returnException(status))
        return

    dealloc(req)
    fut.complete()

proc send*(connection: Stream, buf: pointer, size: int): Future[void] =
    ## Write `size` bytes from `buf` to the stream.
    result = newFuture[void]("send")

    if connection.isClosed:
        result.fail(newException(EOFError, "Stream is closed"))
        return result

    let writer = create(uv_write_t, sizeof(uv_write_t))
    GC_ref(result)
    writer.data = cast[pointer](result)
    let buffer = [
        uv_buf_t(
            base: cast[cstring](buf),
            len: cuint(size)
        )
    ]

    privateAccess(Handle)
    let err = uv_write(writer, cast[ptr uv_stream_t](connection.handle.handle), cast[UncheckedArray[uv_buf_t]](buffer), 1, onWrite)
    if err < 0:
        dealloc(writer)
        GC_unref(result)
        result.fail(returnException(err))
        return

proc send*(connection: Stream, data: sink string): Future[void] =
    ## Write data to the stream.
    result = newFuture[void]("send")

    if connection.isClosed:
        result.fail(newException(EOFError, "Stream is closed"))
        return result

    let writer = create(uv_write_t, sizeof(uv_write_t))
    GC_ref(result)
    writer.data = cast[pointer](result)
    let buffer = [
        uv_buf_t(
            base: cstring(data),
            len: uint(data.len)
        )
    ]

    privateAccess(Handle)
    let err = uv_write(writer, cast[ptr uv_stream_t](connection.handle.handle), cast[UncheckedArray[uv_buf_t]](buffer), 1, onWrite)
    if err < 0:
        dealloc(writer)
        GC_unref(result)
        result.fail(returnException(err))
        return

    
# --- Read ---

proc onReadStrAllocPtr(handle: ptr uv_handle_t; suggested_size: uint; buf: ptr uv_buf_t) {.cdecl.} =
    let ctx = cast[Stream](handle.data)
    if ctx.currentReadSize == -1:
        ctx.readBuffer.setLen(suggested_size)
        buf[] = uv_buf_init(cstring(cast[string](ctx.readBuffer)), cuint(suggested_size))
    else:
        buf[] = uv_buf_init(cast[cstring](cast[uint](ctx.readPointer)+uint(ctx.currentReadSize)), cuint(ctx.readPointerSize-ctx.currentReadSize))


proc onReadPtr(stream: ptr uv_stream_t; nread: int; buf: ptr uv_buf_t) {.cdecl.} =
    let ctx = cast[Stream](stream.data)
    if nread < 0:
        if nread == UV_EOF:
            discard uv_read_stop(stream)
            asyncCheck ctx.close()
            ctx.readCallbackPtr.complete(ctx.currentReadSize)
            return
        else:
            ctx.readCallbackPtr.fail(returnException(cint(nread)))
            discard uv_read_stop(stream)
            return

    if ctx.currentReadSize >= 0: ctx.currentReadSize += nread
    if ctx.currentReadSize == -1 or ctx.currentReadSize >= ctx.currentReadSize:
        if ctx.currentReadSize == -1:
            ctx.readBuffer.setLen(nread)
        discard uv_read_stop(stream)
        ctx.readCallbackPtr.complete(ctx.currentReadSize)
        return

proc onReadStrAllocStr(handle: ptr uv_handle_t; suggested_size: uint; buf: ptr uv_buf_t) {.cdecl.} =
    let ctx = cast[Stream](handle.data)

    if ctx.currentReadSize == -1:
        buf[] = uv_buf_init(cast[cstring](cast[uint](addr (ctx.readBuffer)[0])), cuint(ctx.readBuffer.len))
    else:
        buf[] = uv_buf_init(cast[cstring](cast[uint](addr (ctx.readBuffer)[0])+uint(ctx.currentReadSize)), cuint(ctx.readBuffer.len-ctx.currentReadSize))

        
proc onReadStr(stream: ptr uv_stream_t; nread: int; buf: ptr uv_buf_t) {.cdecl.} =
    let ctx = cast[Stream](stream.data)

    if nread < 0:
        if nread == UV_EOF:
            if ctx.currentReadSize >= 0:
                ctx.readBuffer.setLen(ctx.currentReadSize)
            else:
                ctx.readBuffer.setLen(0)
            discard uv_read_stop(stream)
            asyncCheck ctx.close()
            ctx.readCallbackStr.complete(cast[string](move(ctx.readBuffer)))

            return
        else:
            ctx.readCallbackStr.fail(returnException(cint(nread)))
            ctx.readBuffer.setLen(0)
            discard uv_read_stop(stream)
            return

    block:
        if ctx.currentReadSize >= 0: 
            ctx.currentReadSize += nread
        if ctx.currentReadSize == -1 or ctx.currentReadSize >= ctx.readBuffer.len:
            if ctx.currentReadSize == -1:
                ctx.readBuffer.setLen(nread)

            discard uv_read_stop(stream)
            ctx.readCallbackStr.complete(cast[string](move(ctx.readBuffer)))
            return

proc recvSingle*(connection: Stream, size: int): Future[string] =
    ## Read up to `size` bytes from the stream.
    ## Does not guarantee that the returned string is at least `size` bytes long.
    result = newFuture[string]("recvSingle")
    if connection.isClosed:
        result.complete("")
        return result

    connection.currentReadSize = 0
    connection.readBuffer.setLen(size)
    connection.currentReadSize = -1
    privateAccess(Handle)
    connection.readCallbackStr = result
    let err = uv_read_start(cast[ptr uv_stream_t](connection.handle.handle), onReadStrAllocStr, onReadStr)
    if err != 0:
        result.fail(returnException(err))
        return

proc recvIntoSingle*(connection: Stream, buf: pointer, size: int): Future[int] =
    ## Read up to `size` bytes from the stream into `buf`.
    ## Does not guarantee that the returned string is at least `size` bytes long.
    result = newFuture[int]("recvIntoSingle")
    if connection.isClosed:
        result.complete(0)
        return result

    connection.currentReadSize = 0
    connection.readBuffer.setLen(0)
    connection.readPointer = buf
    connection.readPointerSize = size
    connection.currentReadSize = -1
    privateAccess(Handle)
    connection.readCallbackPtr = result
    let err = uv_read_start(cast[ptr uv_stream_t](connection.handle.handle), onReadStrAllocPtr, onReadPtr)
    if err != 0:
        result.fail(returnException(err))
        return


proc recv*(connection: Stream, size: int): Future[string] =
    ## Read up to `size` bytes from the stream.
    ## Tries to guarantee that the returned string is at least `size` bytes long.
    result = newFuture[string]("recv")
    if connection.isClosed:
        result.complete("")
        return result

    connection.currentReadSize = 0
    connection.readBuffer.setLen(size)
    privateAccess(Handle)
    connection.readCallbackStr = result
    let err = uv_read_start(cast[ptr uv_stream_t](connection.handle.handle), onReadStrAllocStr, onReadStr)
    if err != 0:
        result.fail(returnException(err))
        return

proc recvInto*(connection: Stream, buf: pointer, size: int): Future[int] =
    ## Read up to `size` bytes from the stream into `buf`.
    result = newFuture[int]("recvInto")
    if connection.isClosed:
        result.complete(0)
        return result


    connection.currentReadSize = 0
    connection.readBuffer.setLen(0)
    connection.readPointer = buf
    connection.readPointerSize = size
    privateAccess(Handle)

    connection.readCallbackPtr = result
    let err = uv_read_start(cast[ptr uv_stream_t](connection.handle.handle), onReadStrAllocPtr, onReadPtr)
    if err != 0:
        result.fail(returnException(err))
        return


# --- Shutdown ---

proc onClosed(handle: ptr uv_handle_t) {.cdecl.} =
    let fut = cast[Future[void]](handle.data)
    GC_unref(fut)
    dealloc(handle)
    fut.complete()

proc onShutdown(req: ptr uv_shutdown_t; status: cint) {.cdecl.} =
    let fut = cast[Future[void]](req.data)
    if status < 0:
        dealloc(req)
        fut.fail(returnException(status))
        return

    let handle = cast[ptr uv_handle_t](req.handle)

    let ctx = cast[Stream](handle.data)
    if ctx.readCallbackStr != nil and not ctx.readCallbackStr.finished:
        ctx.readCallbackStr.complete("")
    if ctx.readCallbackPtr != nil and not ctx.readCallbackPtr.finished:
        ctx.readCallbackPtr.complete(0)

    handle.data = cast[pointer](fut)

    dealloc(req)
    uv_close(handle, onClosed)

proc close*(connection: Stream): Future[void] =
    ## Close the stream.
    result = newFuture[void]("close")

    privateAccess(Handle)
    connection.reportClosed = true  

    GC_ref(result)
    let shutdown = create(uv_shutdown_t, sizeof(uv_shutdown_t))
    shutdown.data = cast[pointer](result)
    let handle = connection.handle.handle
    connection.handle.handle = nil
    let err = uv_shutdown(shutdown, cast[ptr uv_stream_t](handle), onShutdown)
    if err != 0:
        dealloc(shutdown)
        result.fail(returnException(err))
        GC_unref(result)
        return


    