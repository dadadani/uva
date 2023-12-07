import bindings/uv

type UvError* = object of CatchableError
    code: cint

proc returnException*(code: cint): ref UvError =
  let excp = new UvError
  excp.code = code
  excp.msg = $uv_strerror(code)
  return excp

proc checkError*(code: cint) {.raises: UvError.} =
  ## Checks the given code and raises an exception if it is not 0.
  if code < 0:
    raise returnException(code)
    #raise newException(Defect, "sus")


  