import bindings/uv
import globals
import std/asyncfutures
import utils

proc sleepAsync*(timeout: uint): Future[void] = 
  ## Sleeps for the given number of milliseconds asynchronously.

  proc deallocAndComplete(handle: ptr uv_handle_t) {.cdecl.} =
    let fut = cast[Future[void]](handle.data)
    GC_unref(fut)
    dealloc(handle)
    fut.complete()

  
  proc onTimeout(handle: ptr uv_timer_t) {.cdecl.} =
    discard uv_timer_stop(handle)
    uv_close(cast[ptr uv_handle_t](handle), deallocAndComplete)


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



proc withTimeout*[T](fut: Future[T], timeout: uint): owned(Future[bool]) =
  ## Returns a future which will complete once `fut` completes or after
  ## `timeout` milliseconds has elapsed.
  ##
  ## If `fut` completes first the returned future will hold true,
  ## otherwise, if `timeout` milliseconds has elapsed first, the returned
  ## future will hold false.

  var retFuture = newFuture[bool]("uva.`withTimeout`")
  var timeoutFuture = sleepAsync(timeout)
  fut.callback =
    proc () =
      if not retFuture.finished:
        if fut.failed:
          retFuture.fail(fut.error)
        else:
          retFuture.complete(true)
  timeoutFuture.callback =
    proc () =
      if not retFuture.finished: retFuture.complete(false)
  return retFuture