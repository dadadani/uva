
import os

import nimterop/[build, cimport, plugin]
import std/macros, std/strutils
const
  baseDir = getProjectCacheDir("libuv")

getHeader(
  header = "uv.h",
  giturl = "https://github.com/libuv/libuv/",
  outdir = baseDir,
  cmakeFlags = "-DENABLE_LIB_ONLY=ON -DENABLE_STATIC_LIB=ON",
  conFlags = "--enable-lib-only"
)



static:
  cPlugin:
    import std/strutils
    proc onSymbol*(sym: var Symbol) {.exportc, dynlib.} =
            echo "broxx: ", sym.name
            if sym.name.contains("uv__"):
                echo "detected shit"
                sym.name = sym.name.replace("uv__", "uvx_")
            if sym.name.contains("UV__"):
                echo "detected shit"
                sym.name = sym.name.replace("UV__", "uvx_")
  cDebug()

echo "patbella", uvPath
cIncludeDir(uvPath.parentDir())

#cIncludeDir(uvPath.parentDir().parentDir())

cImport(uvPath)
