import utils
import bindings/uv
import std/asyncfutures
import std/deques

proc xmalloc(size: csize_t;): pointer {.cdecl.} =
    return alloc(size)

proc xfree(`ptr`: pointer; ) {.cdecl.} =
    if not isNil(`ptr`):
        dealloc(`ptr`)

proc xrealloc(`ptr`: pointer; size: csize_t;): pointer {.cdecl.} =
    return realloc(`ptr`, size)

proc xcalloc(nmemb: csize_t; size: csize_t;): pointer {.cdecl.} =
    return alloc0(nmemb * size)

type 
    UvLoopObj = object
        loop*: ptr uv_loop_s
        callbacks*: Deque[proc () {.gcsafe.}]
        check*: uv_prepare_t

    UvLoop = ref UvLoopObj


proc walkCb(handle: ptr uv_handle_t; arg: pointer) {.cdecl.} =
    if uv_is_closing(handle) == 0:
        uv_close(handle, nil)

proc `=destroy`(self: UvLoopObj) =
    if self.loop != nil:
        
        uv_walk(self.loop, walkCb, nil)
        discard uv_run(self.loop, UV_RUN_DEFAULT)
        discard uv_loop_close(self.loop)
        uv_library_shutdown()

var defaultLoop*: UvLoop

proc vcallSoon*(cbproc: proc () {.gcsafe.}) {.gcsafe.}

proc processCallbacks() 

proc init() =

    defaultLoop = new UvLoop
    # Replace the default allocators with Nim's allocators.
    # This guarantees better compatibility and faster performance.
    checkError uv_replace_allocator(xmalloc, xrealloc, xcalloc, xfree)

    # Initialize the default loop.
    defaultLoop.loop = uv_default_loop()
    defaultLoop.callbacks = initDeque[proc () {.gcsafe.}]()

    setCallSoonProc(vcallSoon)
    checkError uv_prepare_init(defaultLoop.loop, addr defaultLoop.check)
 
    defaultLoop.check.data = cast[pointer](defaultLoop)

    proc idleCb(handle: ptr uv_prepare_t) {.cdecl.} =
        processCallbacks()

    checkError uv_prepare_start(addr defaultLoop.check, idleCb)


init()


proc getLoop*(): UvLoop =
    {.gcsafe.}:
        return defaultloop

proc vcallSoon*(cbproc: proc () {.gcsafe.}) =
    getLoop().callbacks.addLast(cbproc)

proc processCallbacks() =
    while getLoop().callbacks.len > 0:
        let cb = getLoop().callbacks.popFirst()
        try:
            cb()
        except:
            {.gcsafe.}:
                uv_stop(getLoop().loop)
            raise

proc runOnce*(): bool =
    ## Run the default loop once.
    ## Returns when there are no active tasks.
    var code = uv_run(getLoop().loop, UV_RUN_ONCE)
    checkError code
    return code == 1


proc runForever*() {.gcsafe.} = 
    ## Run the default loop forever.
    var code = cint(1)
    while code >= 1:
        code = uv_run(getLoop().loop, UV_RUN_DEFAULT)
        checkError code

        

proc waitFor*[T](fut: Future[T]): T {.gcsafe.} =
    ## Block the current thread and wait for a single task to complete.
    while not fut.finished():
        discard runOnce()
    
    fut.read
