import bindings/uv
import globals
import handles
import std/importutils
import std/asyncfutures
import utils

type Stream* = ref object of Handle
    buffered: bool
    reportClosed: bool

    currentReadSize: int
    readBuffer: seq[uint8]
    readCallback: Future[string]


proc isActive*(connection: Stream): bool =
    ## Returns true if the stream is active.
    privateAccess(Handle)
    result = uv_is_active(cast[ptr uv_handle_t](connection.handle)) != 0 and not connection.reportClosed

proc isReadable*(connection: Stream): bool =
    ## Returns true if the stream is readable.
    privateAccess(Handle)
    result = uv_is_readable(cast[ptr uv_stream_t](connection.handle)) != 0

proc isWritable*(connection: Stream): bool =
    ## Returns true if the stream is writable.
    privateAccess(Handle)
    result = uv_is_writable(cast[ptr uv_stream_t](connection.handle)) != 0

# --- Write ---

proc onWriteImpl(req: ptr uv_write_t; status: cint) = 
    let fut = cast[Future[void]](req.data)
    GC_unref(fut)
    if status < 0:
        dealloc(req)
        fut.fail(returnException(status))
        return

    dealloc(req)
    fut.complete()

proc onWrite(req: ptr uv_write_t; status: cint) {.cdecl.} = 
    try:
        onWriteImpl(req, status)
    except:
        uv_stop(defaultLoop.loop)
        raise


proc write*(connection: Stream, data: sink string): Future[void] =
    ## Write data to the stream.
    result = newFuture[void]("read")

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
    let err = uv_write(writer, cast[ptr uv_stream_t](connection.handle), cast[UncheckedArray[uv_buf_t]](buffer), 1, onWrite)
    if err < 0:
        GC_unref(result)
        result.fail(returnException(err))
        return

    
# --- Read ---

proc onReadAlloc(handle: ptr uv_handle_t; suggested_size: uint; buf: ptr uv_buf_t) {.cdecl.} =
    let ctx = cast[Stream](handle.data)
    if not ctx.buffered:
        ctx.readBuffer.setLen(suggested_size)
        buf[] = uv_buf_init(cstring(cast[string](ctx.readBuffer)), cuint(suggested_size))
    else:
        buf[] = uv_buf_init(cast[cstring](cast[uint](addr (ctx.readBuffer)[0])+uint(ctx.currentReadSize)), cuint(ctx.readBuffer.len-ctx.currentReadSize))
proc onRead(stream: ptr uv_stream_t; nread: int; buf: ptr uv_buf_t) {.cdecl.} =
    let ctx = cast[Stream](stream.data)

    if nread < 0:
        if nread == UV_EOF:
            ctx.readBuffer.setLen(ctx.currentReadSize)
            discard uv_read_stop(stream)
            ctx.readCallback.complete(cast[string](move(ctx.readBuffer)))
            return
        else:
            ctx.readCallback.fail(returnException(cint(nread)))
            ctx.readBuffer.setLen(0)
            discard uv_read_stop(stream)
            return

    if not ctx.buffered:
        ctx.readCallback.complete(cast[string](move(ctx.readBuffer)))

        return
    else:
        ctx.currentReadSize += nread
        if ctx.currentReadSize >= ctx.readBuffer.len:
            discard uv_read_stop(stream)
            ctx.readCallback.complete(cast[string](move(ctx.readBuffer)))
            return

proc read*(connection: Stream, size: int): Future[string] =
    ## Read up to `size` bytes from the stream.
    ## Note: This procedure may only be called if the connection is set to buffered mode.
    result = newFuture[string]("read")
    if connection.isClosed:
        result.fail(newException(EOFError, "Stream is closed"))
        return result
    if not connection.buffered:
        result.fail(newException(FieldDefect, "Stream is not buffered"))
        return result
    connection.currentReadSize = 0
    connection.readBuffer.setLen(size)
    privateAccess(Handle)
    connection.readCallback = result
    let err = uv_read_start(cast[ptr uv_stream_t](connection.handle), onReadAlloc, onRead)
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
    GC_unref(ctx)

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

    let err = uv_shutdown(shutdown, cast[ptr uv_stream_t](connection.handle), onShutdown)
    if err != 0:
        result.fail(returnException(err))
        GC_unref(result)
        return


    