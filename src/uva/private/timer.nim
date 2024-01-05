import bindings/uv
import globals
import std/asyncfutures
import utils

proc sleepAsync*(timeout: uint): Future[void] = 
  ## Sleeps for the given number of milliseconds asynchronously.
  
  proc onTimeout(handle: ptr uv_timer_t) {.cdecl.} =
    let fut = cast[Future[void]](handle.data)
    GC_unref(fut)
    discard uv_timer_stop(handle)
    uv_close(cast[ptr uv_handle_t](handle), nil)
    dealloc(handle)
    fut.complete()


  result = newFuture[void]()
  let timer = create(uv_timer_t, sizeof(uv_timer_t))
  
  var err = uv_timer_init(getLoop().loop, timer)

  if err != 0:
    result.fail(returnException(err))
    uv_close(cast[ptr uv_handle_t](timer), nil)
    dealloc(timer)
  
  timer.data = cast[pointer](result)
  GC_ref(result)

  err = uv_timer_start(timer, onTimeout, timeout, 0)
  if err != 0:
    result.fail(returnException(err))
    uv_close(cast[ptr uv_handle_t](timer), nil)
    dealloc(timer)



