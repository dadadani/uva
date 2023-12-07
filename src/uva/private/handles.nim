import bindings/uv
import globals
import std/asyncfutures
import utils

type Handle* = ref object of RootObj
    ## Base type for all handles.
    ## It shouldn't be used directly, however it's useful to have it in the type hierarchy.
    handle: ptr uv_handle_t

proc isActive*(handle: Handle): bool =
    ## Returns `true` if the handle is active, `false` otherwise.
    ## An active handle is one that is running some kind of operation.
    return uv_is_active(handle.handle) != 0

proc isClosed*(handle: Handle): bool =
    ## Returns `true` if the handle is closed or is closing, `false` otherwise.
    return uv_is_closing(handle.handle) != 0

proc readBufferSize*(handle: Handle): cint =
    ## Returns the size of the read buffer.
    result = 0
    checkError uv_recv_buffer_size(handle.handle, addr result)

proc `readBufferSize=`*(handle: Handle; size: cint) =
    ## Sets the size of the read buffer.
    doAssert size > 0
    checkError uv_recv_buffer_size(handle.handle, addr size)

proc writeBufferSize*(handle: Handle): cint =
    ## Returns the size of the write buffer.
    result = 0
    checkError uv_send_buffer_size(handle.handle, addr result)

proc `writeBufferSize=`*(handle: Handle; size: cint) =
    ## Sets the size of the write buffer.
    doAssert size > 0
    checkError uv_send_buffer_size(handle.handle, addr size)
