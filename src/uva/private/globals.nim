import utils
import bindings/uv
import std/asyncfutures

proc xmalloc(size: csize_t;): pointer {.cdecl.} =
    return alloc(size)

proc xfree(`ptr`: pointer; ) {.cdecl.} =
    if not isNil(`ptr`):
        dealloc(`ptr`)

proc xrealloc(`ptr`: pointer; size: csize_t;): pointer {.cdecl.} =
    return realloc(`ptr`, size)

proc xcalloc(nmemb: csize_t; size: csize_t;): pointer {.cdecl.} =
    return alloc0(nmemb * size)

type UvLoop = object
    loop*: ptr uv_loop_s

proc walkCb(handle: ptr uv_handle_t; arg: pointer) {.cdecl.} =
    if uv_is_closing(handle) == 0:
        uv_close(handle, nil)

proc `=destroy`(self: UvLoop) =
    if self.loop != nil:
        uv_walk(self.loop, walkCb, nil)
        discard uv_run(self.loop, UV_RUN_DEFAULT)
        discard uv_loop_close(self.loop)
        uv_library_shutdown()

var defaultLoop*: UvLoop

proc init() =

    # Replace the default allocators with Nim's allocators.
    # This guarantees better compatibility and faster performance.
    checkError uv_replace_allocator(xmalloc, xrealloc, xcalloc, xfree)

    # Initialize the default loop.
    defaultLoop.loop = uv_default_loop()


init()

proc runForever*() = 
    ## Run the default loop forever.
    ## Exits when there are active tasks.
    var code = cint(1)
    while code == 1:
        code = uv_run(defaultLoop.loop, UV_RUN_DEFAULT)
        checkError code

proc waitFor*[T](fut: Future[T]): T =
    ## Block the current thread and wait for a single task to complete.
    while not fut.finished():
        checkError uv_run(defaultLoop.loop, UV_RUN_ONCE)
    
    fut.read
