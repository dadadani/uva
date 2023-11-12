


const
  UV_EOF* = (-4095)
  UV_UNKNOWN* = (-4094)
  UV_EAI_ADDRFAMILY* = (-3000)
  UV_EAI_AGAIN* = (-3001)
  UV_EAI_BADFLAGS* = (-3002)
  UV_EAI_CANCELED* = (-3003)
  UV_EAI_FAIL* = (-3004)
  UV_EAI_FAMILY* = (-3005)
  UV_EAI_MEMORY* = (-3006)
  UV_EAI_NODATA* = (-3007)
  UV_EAI_NONAME* = (-3008)
  UV_EAI_OVERFLOW* = (-3009)
  UV_EAI_SERVICE* = (-3010)
  UV_EAI_SOCKTYPE* = (-3011)
  UV_EAI_BADHINTS* = (-3013)
  UV_EAI_PROTOCOL* = (-3014)

##  Only map to the system errno on non-Windows platforms. It's apparently
##  a fairly common practice for Windows programmers to redefine errno codes.
##

when defined(E2BIG) and not defined(windows):
  const
    UV_E2BIG* = UV_ERR(E2BIG)
else:
  const
    UV_E2BIG* = (-4093)
when defined(EACCES) and not defined(windows):
  const
    UV_EACCES* = UV_ERR(EACCES)
else:
  const
    UV_EACCES* = (-4092)
when defined(EADDRINUSE) and not defined(windows):
  const
    UV_EADDRINUSE* = UV_ERR(EADDRINUSE)
else:
  const
    UV_EADDRINUSE* = (-4091)
when defined(EADDRNOTAVAIL) and not defined(windows):
  const
    UV_EADDRNOTAVAIL* = UV_ERR(EADDRNOTAVAIL)
else:
  const
    UV_EADDRNOTAVAIL* = (-4090)
when defined(EAFNOSUPPORT) and not defined(windows):
  const
    UV_EAFNOSUPPORT* = UV_ERR(EAFNOSUPPORT)
else:
  const
    UV_EAFNOSUPPORT* = (-4089)
when defined(EAGAIN) and not defined(windows):
  const
    UV_EAGAIN* = UV_ERR(EAGAIN)
else:
  const
    UV_EAGAIN* = (-4088)
when defined(EALREADY) and not defined(windows):
  const
    UV_EALREADY* = UV_ERR(EALREADY)
else:
  const
    UV_EALREADY* = (-4084)
when defined(EBADF) and not defined(windows):
  const
    UV_EBADF* = UV_ERR(EBADF)
else:
  const
    UV_EBADF* = (-4083)
when defined(EBUSY) and not defined(windows):
  const
    UV_EBUSY* = UV_ERR(EBUSY)
else:
  const
    UV_EBUSY* = (-4082)
when defined(ECANCELED) and not defined(windows):
  const
    UV_ECANCELED* = UV_ERR(ECANCELED)
else:
  const
    UV_ECANCELED* = (-4081)
when defined(ECHARSET) and not defined(windows):
  const
    UV_ECHARSET* = UV_ERR(ECHARSET)
else:
  const
    UV_ECHARSET* = (-4080)
when defined(ECONNABORTED) and not defined(windows):
  const
    UV_ECONNABORTED* = UV_ERR(ECONNABORTED)
else:
  const
    UV_ECONNABORTED* = (-4079)
when defined(ECONNREFUSED) and not defined(windows):
  const
    UV_ECONNREFUSED* = UV_ERR(ECONNREFUSED)
else:
  const
    UV_ECONNREFUSED* = (-4078)
when defined(ECONNRESET) and not defined(windows):
  const
    UV_ECONNRESET* = UV_ERR(ECONNRESET)
else:
  const
    UV_ECONNRESET* = (-4077)
when defined(EDESTADDRREQ) and not defined(windows):
  const
    UV_EDESTADDRREQ* = UV_ERR(EDESTADDRREQ)
else:
  const
    UV_EDESTADDRREQ* = (-4076)
when defined(EEXIST) and not defined(windows):
  const
    UV_EEXIST* = UV_ERR(EEXIST)
else:
  const
    UV_EEXIST* = (-4075)
when defined(EFAULT) and not defined(windows):
  const
    UV_EFAULT* = UV_ERR(EFAULT)
else:
  const
    UV_EFAULT* = (-4074)
when defined(EHOSTUNREACH) and not defined(windows):
  const
    UV_EHOSTUNREACH* = UV_ERR(EHOSTUNREACH)
else:
  const
    UV_EHOSTUNREACH* = (-4073)
when defined(EINTR) and not defined(windows):
  const
    UV_EINTR* = UV_ERR(EINTR)
else:
  const
    UV_EINTR* = (-4072)
when defined(EINVAL) and not defined(windows):
  const
    UV_EINVAL* = UV_ERR(EINVAL)
else:
  const
    UV_EINVAL* = (-4071)
when defined(EIO) and not defined(windows):
  const
    UV_EIO* = UV_ERR(EIO)
else:
  const
    UV_EIO* = (-4070)
when defined(EISCONN) and not defined(windows):
  const
    UV_EISCONN* = UV_ERR(EISCONN)
else:
  const
    UV_EISCONN* = (-4069)
when defined(EISDIR) and not defined(windows):
  const
    UV_EISDIR* = UV_ERR(EISDIR)
else:
  const
    UV_EISDIR* = (-4068)
when defined(ELOOP) and not defined(windows):
  const
    UV_ELOOP* = UV_ERR(ELOOP)
else:
  const
    UV_ELOOP* = (-4067)
when defined(EMFILE) and not defined(windows):
  const
    UV_EMFILE* = UV_ERR(EMFILE)
else:
  const
    UV_EMFILE* = (-4066)
when defined(EMSGSIZE) and not defined(windows):
  const
    UV_EMSGSIZE* = UV_ERR(EMSGSIZE)
else:
  const
    UV_EMSGSIZE* = (-4065)
when defined(ENAMETOOLONG) and not defined(windows):
  const
    UV_ENAMETOOLONG* = UV_ERR(ENAMETOOLONG)
else:
  const
    UV_ENAMETOOLONG* = (-4064)
when defined(ENETDOWN) and not defined(windows):
  const
    UV_ENETDOWN* = UV_ERR(ENETDOWN)
else:
  const
    UV_ENETDOWN* = (-4063)
when defined(ENETUNREACH) and not defined(windows):
  const
    UV_ENETUNREACH* = UV_ERR(ENETUNREACH)
else:
  const
    UV_ENETUNREACH* = (-4062)
when defined(ENFILE) and not defined(windows):
  const
    UV_ENFILE* = UV_ERR(ENFILE)
else:
  const
    UV_ENFILE* = (-4061)
when defined(ENOBUFS) and not defined(windows):
  const
    UV_ENOBUFS* = UV_ERR(ENOBUFS)
else:
  const
    UV_ENOBUFS* = (-4060)
when defined(ENODEV) and not defined(windows):
  const
    UV_ENODEV* = UV_ERR(ENODEV)
else:
  const
    UV_ENODEV* = (-4059)
when defined(ENOENT) and not defined(windows):
  const
    UV_ENOENT* = UV_ERR(ENOENT)
else:
  const
    UV_ENOENT* = (-4058)
when defined(ENOMEM) and not defined(windows):
  const
    UV_ENOMEM* = UV_ERR(ENOMEM)
else:
  const
    UV_ENOMEM* = (-4057)
when defined(ENONET) and not defined(windows):
  const
    UV_ENONET* = UV_ERR(ENONET)
else:
  const
    UV_ENONET* = (-4056)
when defined(ENOSPC) and not defined(windows):
  const
    UV_ENOSPC* = UV_ERR(ENOSPC)
else:
  const
    UV_ENOSPC* = (-4055)
when defined(ENOSYS) and not defined(windows):
  const
    UV_ENOSYS* = UV_ERR(ENOSYS)
else:
  const
    UV_ENOSYS* = (-4054)
when defined(ENOTCONN) and not defined(windows):
  const
    UV_ENOTCONN* = UV_ERR(ENOTCONN)
else:
  const
    UV_ENOTCONN* = (-4053)
when defined(ENOTDIR) and not defined(windows):
  const
    UV_ENOTDIR* = UV_ERR(ENOTDIR)
else:
  const
    UV_ENOTDIR* = (-4052)
when defined(ENOTEMPTY) and not defined(windows):
  const
    UV_ENOTEMPTY* = UV_ERR(ENOTEMPTY)
else:
  const
    UV_ENOTEMPTY* = (-4051)
when defined(ENOTSOCK) and not defined(windows):
  const
    UV_ENOTSOCK* = UV_ERR(ENOTSOCK)
else:
  const
    UV_ENOTSOCK* = (-4050)
when defined(ENOTSUP) and not defined(windows):
  const
    UV_ENOTSUP* = UV_ERR(ENOTSUP)
else:
  const
    UV_ENOTSUP* = (-4049)
when defined(EPERM) and not defined(windows):
  const
    UV_EPERM* = UV_ERR(EPERM)
else:
  const
    UV_EPERM* = (-4048)
when defined(EPIPE) and not defined(windows):
  const
    UV_EPIPE* = UV_ERR(EPIPE)
else:
  const
    UV_EPIPE* = (-4047)
when defined(EPROTO) and not defined(windows):
  const
    UV_EPROTO* = UV_ERR(EPROTO)
else:
  const
    UV_EPROTO* = (-4046)
when defined(EPROTONOSUPPORT) and not defined(windows):
  const
    UV_EPROTONOSUPPORT* = UV_ERR(EPROTONOSUPPORT)
else:
  const
    UV_EPROTONOSUPPORT* = (-4045)
when defined(EPROTOTYPE) and not defined(windows):
  const
    UV_EPROTOTYPE* = UV_ERR(EPROTOTYPE)
else:
  const
    UV_EPROTOTYPE* = (-4044)
when defined(EROFS) and not defined(windows):
  const
    UV_EROFS* = UV_ERR(EROFS)
else:
  const
    UV_EROFS* = (-4043)
when defined(ESHUTDOWN) and not defined(windows):
  const
    UV_ESHUTDOWN* = UV_ERR(ESHUTDOWN)
else:
  const
    UV_ESHUTDOWN* = (-4042)
when defined(ESPIPE) and not defined(windows):
  const
    UV_ESPIPE* = UV_ERR(ESPIPE)
else:
  const
    UV_ESPIPE* = (-4041)
when defined(ESRCH) and not defined(windows):
  const
    UV_ESRCH* = UV_ERR(ESRCH)
else:
  const
    UV_ESRCH* = (-4040)
when defined(ETIMEDOUT) and not defined(windows):
  const
    UV_ETIMEDOUT* = UV_ERR(ETIMEDOUT)
else:
  const
    UV_ETIMEDOUT* = (-4039)
when defined(ETXTBSY) and not defined(windows):
  const
    UV_ETXTBSY* = UV_ERR(ETXTBSY)
else:
  const
    UV_ETXTBSY* = (-4038)
when defined(EXDEV) and not defined(windows):
  const
    UV_EXDEV* = UV_ERR(EXDEV)
else:
  const
    UV_EXDEV* = (-4037)
when defined(EFBIG) and not defined(windows):
  const
    UV_EFBIG* = UV_ERR(EFBIG)
else:
  const
    UV_EFBIG* = (-4036)
when defined(ENOPROTOOPT) and not defined(windows):
  const
    UV_ENOPROTOOPT* = UV_ERR(ENOPROTOOPT)
else:
  const
    UV_ENOPROTOOPT* = (-4035)
when defined(ERANGE) and not defined(windows):
  const
    UV_ERANGE* = UV_ERR(ERANGE)
else:
  const
    UV_ERANGE* = (-4034)
when defined(ENXIO) and not defined(windows):
  const
    UV_ENXIO* = UV_ERR(ENXIO)
else:
  const
    UV_ENXIO* = (-4033)
when defined(EMLINK) and not defined(windows):
  const
    UV_EMLINK* = UV_ERR(EMLINK)
else:
  const
    UV_EMLINK* = (-4032)
##  EHOSTDOWN is not visible on BSD-like systems when _POSIX_C_SOURCE is
##  defined. Fortunately, its value is always 64 so it's possible albeit
##  icky to hard-code it.
##

when defined(EHOSTDOWN) and not defined(windows):
  const
    UV_EHOSTDOWN* = UV_ERR(EHOSTDOWN)
elif defined(macosx) or defined(dragonfly) or defined(freebsd) or
    defined(netbsd) or
    defined(openbsd):
  const
    UV_EHOSTDOWN* = (-64)
else:
  const
    UV_EHOSTDOWN* = (-4031)
when defined(EREMOTEIO) and not defined(windows):
  const
    UV_EREMOTEIO* = UV_ERR(EREMOTEIO)
else:
  const
    UV_EREMOTEIO* = (-4030)
when defined(ENOTTY) and not defined(windows):
  const
    UV_ENOTTY* = UV_ERR(ENOTTY)
else:
  const
    UV_ENOTTY* = (-4029)
when defined(EFTYPE) and not defined(windows):
  const
    UV_EFTYPE* = UV_ERR(EFTYPE)
else:
  const
    UV_EFTYPE* = (-4028)
when defined(EILSEQ) and not defined(windows):
  const
    UV_EILSEQ* = UV_ERR(EILSEQ)
else:
  const
    UV_EILSEQ* = (-4027)
when defined(EOVERFLOW) and not defined(windows):
  const
    UV_EOVERFLOW* = UV_ERR(EOVERFLOW)
else:
  const
    UV_EOVERFLOW* = (-4026)
when defined(ESOCKTNOSUPPORT) and not defined(windows):
  const
    UV_ESOCKTNOSUPPORT* = UV_ERR(ESOCKTNOSUPPORT)
else:
  const
    UV_ESOCKTNOSUPPORT* = (-4025)
##  FreeBSD defines ENODATA in /usr/include/c++/v1/errno.h which is only visible
##  if C++ is being used. Define it directly to avoid problems when integrating
##  libuv in a C++ project.
##

when defined(ENODATA) and not defined(windows):
  const
    UV_ENODATA* = UV_ERR(ENODATA)
elif defined(freebsd):
  const
    UV_ENODATA* = (-9919)
else:
  const
    UV_ENODATA* = (-4024)
when defined(EUNATCH) and not defined(windows):
  const
    UV_EUNATCH* = UV_ERR(EUNATCH)
else:
  const
    UV_EUNATCH* = (-4023)