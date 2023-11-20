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
        discard
        uv_walk(self.loop, walkCb, nil)
        checkError uv_run(self.loop, UV_RUN_DEFAULT)
        checkError uv_loop_close(self.loop)
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

proc sleepAsync*(timeout: uint): Future[void] = 
  ## Sleeps for the given number of milliseconds asynchronously.
  
  proc onTimeout(handle: ptr uv_timer_t) {.cdecl.} =
    let fut = cast[Future[void]](handle.data)
    GC_unref(fut)
    discard uv_timer_stop(handle)
    uv_close(cast[ptr uv_handle_t](handle), nil)
    fut.complete()


  result = newFuture[void]()
  let timer = new uv_timer_t
  
  var err = uv_timer_init(defaultLoop.loop, cast[ptr uv_timer_t](timer))

  if err != 0:
    result.fail(returnException(err))
    uv_close(cast[ptr uv_handle_t](timer), nil)
  
  timer.data = cast[pointer](result)
  GC_ref(result)

  err = uv_timer_start(cast[ptr uv_timer_t](timer), onTimeout, timeout, 0)
  if err != 0:
    result.fail(returnException(err))
    uv_close(cast[ptr uv_handle_t](timer), nil)



