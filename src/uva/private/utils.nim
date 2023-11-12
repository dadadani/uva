import asyncfutures
import bindings/uv

type UvError* = object of CatchableError
    code: cint

proc checkError*(code: cint) =
  ## Checks the given code and raises an exception if it is not 0.
  if code < 0:
    echo code

    let excp = new UvError
    excp.code = code
    excp.msg = $uv_strerror(code)
    raise excp
    #raise newException(Defect, "sus")