
import os

import nimterop/[build, cimport, plugin]
import std/macros, std/strutils
const
  baseDir = getProjectCacheDir("libuv")
echo baseDir

getHeader(
  header = "uv.h",
  #giturl = "https://github.com/libuv/libuv/",
  outdir = baseDir,
  cmakeFlags = "-DENABLE_LIB_ONLY=ON -DENABLE_STATIC_LIB=ON",
  conFlags = "--enable-lib-only"
)

cSkipSymbol(@["uv__queue", "uv__io_t", "uv__work", "UV_REQ_PRIVATE_FIELDS", "UV_SHUTDOWN_PRIVATE_FIELDS", "UV_HANDLE_PRIVATE_FIELDS", "UV_STREAM_PRIVATE_FIELDS", "UV_WRITE_PRIVATE_FIELDS", "UV_TCP_PRIVATE_FIELDS", "UV_CONNECT_PRIVATE_FIELDS", "UV_UDP_PRIVATE_FIELDS", "UV_TTY_PRIVATE_FIELDS", "UV_PIPE_PRIVATE_FIELDS", "UV_POLL_PRIVATE_FIELDS", "UV_PREPARE_PRIVATE_FIELDS", "UV_CHECK_PRIVATE_FIELDS", "UV_IDLE_PRIVATE_FIELDS", "UV_ASYNC_PRIVATE_FIELDS", "UV_TIMER_PRIVATE_FIELDS", "UV_GETADDRINFO_PRIVATE_FIELDS", "UV_GETNAMEINFO_PRIVATE_FIELDS", "UV_PROCESS_PRIVATE_FIELDS", "UV_WORK_PRIVATE_FIELDS", "UV_DIR_PRIVATE_FIELDS", "UV_FS_PRIVATE_FIELDS", "UV_FS_EVENT_PRIVATE_FIELDS", "UV_SIGNAL_PRIVATE_FIELDS", "UV_LOOP_PRIVATE_FIELDS"])


static:
  cSkipSymbol(@["uv__queue", "uv__io_t", "uv__work", "UV_REQ_PRIVATE_FIELDS", "UV_SHUTDOWN_PRIVATE_FIELDS", "UV_HANDLE_PRIVATE_FIELDS", "UV_STREAM_PRIVATE_FIELDS", "UV_WRITE_PRIVATE_FIELDS", "UV_TCP_PRIVATE_FIELDS", "UV_CONNECT_PRIVATE_FIELDS", "UV_UDP_PRIVATE_FIELDS", "UV_TTY_PRIVATE_FIELDS", "UV_PIPE_PRIVATE_FIELDS", "UV_POLL_PRIVATE_FIELDS", "UV_PREPARE_PRIVATE_FIELDS", "UV_CHECK_PRIVATE_FIELDS", "UV_IDLE_PRIVATE_FIELDS", "UV_ASYNC_PRIVATE_FIELDS", "UV_TIMER_PRIVATE_FIELDS", "UV_GETADDRINFO_PRIVATE_FIELDS", "UV_GETNAMEINFO_PRIVATE_FIELDS", "UV_PROCESS_PRIVATE_FIELDS", "UV_WORK_PRIVATE_FIELDS", "UV_DIR_PRIVATE_FIELDS", "UV_FS_PRIVATE_FIELDS", "UV_FS_EVENT_PRIVATE_FIELDS", "UV_SIGNAL_PRIVATE_FIELDS", "UV_LOOP_PRIVATE_FIELDS"])

  cPlugin:
    import std/strutils
    var file = open("/tmp/ignore.txt", fmWrite)
    proc onSymbol*(sym: var Symbol) {.exportc, dynlib.} =
            echo "broxx: ", sym.name
            if sym.name.contains("PRIVATE"):
                quit(1)
            if sym.name.contains("uv__"):
                file.writeLine(sym.name)




                file.flushFile()



                #sym.name = sym.name.replace("uv__", "uvx_")
                #echo "detected shit"
                #echo sym.parent
                #echo cOverrides
                #quit(1)
                
                sym.name = sym.name.replace("uv__", "uvx_")
            if sym.name.contains("UV__"):
                file.writeLine(sym.name)

                #echo "detected shit"
                #echo sym.parent
                #quit(1)
                sym.name = sym.name.replace("UV__", "UVX_")
    
  cDebug()
  cDisableCaching()

static:
    cSkipSymbol(@["uvx_queue", "uvx_io_t", "uvx_work", "uv__queue", "uv__io_t", "uv__work", "UV_REQ_PRIVATE_FIELDS", "UV_SHUTDOWN_PRIVATE_FIELDS", "UV_HANDLE_PRIVATE_FIELDS", "UV_STREAM_PRIVATE_FIELDS", "UV_WRITE_PRIVATE_FIELDS", "UV_TCP_PRIVATE_FIELDS", "UV_CONNECT_PRIVATE_FIELDS", "UV_UDP_PRIVATE_FIELDS", "UV_TTY_PRIVATE_FIELDS", "UV_PIPE_PRIVATE_FIELDS", "UV_POLL_PRIVATE_FIELDS", "UV_PREPARE_PRIVATE_FIELDS", "UV_CHECK_PRIVATE_FIELDS", "UV_IDLE_PRIVATE_FIELDS", "UV_ASYNC_PRIVATE_FIELDS", "UV_TIMER_PRIVATE_FIELDS", "UV_GETADDRINFO_PRIVATE_FIELDS", "UV_GETNAMEINFO_PRIVATE_FIELDS", "UV_PROCESS_PRIVATE_FIELDS", "UV_WORK_PRIVATE_FIELDS", "UV_DIR_PRIVATE_FIELDS", "UV_FS_PRIVATE_FIELDS", "UV_FS_EVENT_PRIVATE_FIELDS", "UV_SIGNAL_PRIVATE_FIELDS", "UV_LOOP_PRIVATE_FIELDS"])

echo "patbella", uvPath

cIncludeDir(uvPath.parentDir())

#cIncludeDir(uvPath.parentDir().parentDir())

cImport(uvPath.parentDir() / "uv" / "errno.h")

#cImport(uvPath)


