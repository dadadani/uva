import bindings/uv
import utils


type HandleHolder = object 
    handle*: ptr uv_handle_t

proc `=destroy`(x: HandleHolder)

type Handle* = ref object of RootObj
    ## Base type for all handles.
    ## It shouldn't be used directly, however it's useful to have it in the type hierarchy.
    handle: HandleHolder

proc isActive*(handle: Handle): bool =
    ## Returns `true` if the handle is active, `false` otherwise.
    ## An active handle is one that is running some kind of operation.
    return uv_is_active(handle.handle.handle) == 1

proc isClosed*(handle: Handle): bool =
    ## Returns `true` if the handle is closed or is closing, `false` otherwise.
    return uv_is_closing(handle.handle.handle) == 1 or handle.handle.handle == nil

proc readBufferSize*(handle: Handle): cint =
    ## Returns the size of the read buffer.
    result = 0
    checkError uv_recv_buffer_size(handle.handle.handle, addr result)

proc `readBufferSize=`*(handle: Handle; size: cint) =
    ## Sets the size of the read buffer.
    doAssert size > 0
    checkError uv_recv_buffer_size(handle.handle.handle, addr size)

proc writeBufferSize*(handle: Handle): cint =
    ## Returns the size of the write buffer.
    result = 0
    checkError uv_send_buffer_size(handle.handle.handle, addr result)

proc `writeBufferSize=`*(handle: Handle; size: cint) =
    ## Sets the size of the write buffer.
    doAssert size > 0
    checkError uv_send_buffer_size(handle.handle.handle, addr size)

proc `=destroy`(x: HandleHolder) =
    proc onClose(handle: ptr uv_handle_t) {.cdecl.} =
        dealloc(handle)

    if not isNil(x.handle):
        if uv_is_closing(x.handle) != 1:
            uv_close(x.handle, onClose)
        else:
            dealloc(x.handle)