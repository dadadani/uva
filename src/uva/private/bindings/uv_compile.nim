import os

{.used.}

const path = currentSourcePath() / ".." / "libuv"

{.passC: "-I" & path / "src".}
{.passC: "-I" & path / "include".}
{.passC: "-I" & path / "include/uv/errno.h".}
{.passC: "-I" & path / "include/uv/threadpool.h".}
{.passC: "-I" & path / "include/uv/version.h".}

when defined linux:
    {.passC: "-D_GNU_SOURCE".}
    {.passC: "-I" & path / "include/uv/linux.h".}

    {.compile: path / "src" / "unix" / "linux.c".}
    {.compile: path / "src" / "unix" / "procfs-exepath.c".}
    {.compile: path / "src" / "unix" / "proctitle.c".}
    {.compile: path / "src" / "unix" / "random-getrandom.c".}
    {.compile: path / "src" / "unix" / "random-sysctl-linux.c".}



when defined unix:
    {.passC: "-I" & path / "include/uv/unix.h".}
    {.passC: "-I" &  path / "src" / "unix" / "internal.h".}

    {.compile: path / "src" / "unix" / "async.c".}
    {.compile: path / "src" / "unix" / "core.c".}
    {.compile: path / "src" / "unix" / "dl.c".}
    {.compile: path / "src" / "unix" / "fs.c".}
    {.compile: path / "src" / "unix" / "getaddrinfo.c".}
    {.compile: path / "src" / "unix" / "getnameinfo.c".}
    {.compile: path / "src" / "unix" / "loop-watcher.c".}
    {.compile: path / "src" / "unix" / "loop.c".}
    {.compile: path / "src" / "unix" / "pipe.c".}
    {.compile: path / "src" / "unix" / "poll.c".}
    {.compile: path / "src" / "unix" / "process.c".}
    {.compile: path / "src" / "unix" / "random-devurandom.c".}
    {.compile: path / "src" / "unix" / "signal.c".}
    {.compile: path / "src" / "unix" / "stream.c".}
    {.compile: path / "src" / "unix" / "tcp.c".}
    {.compile: path / "src" / "unix" / "thread.c".}
    {.compile: path / "src" / "unix" / "tty.c".}
    {.compile: path / "src" / "unix" / "udp.c".}
else:
    {.error: "Unsupported platform".}

{.compile: path / "src" / "fs-poll.c".}
{.compile: path / "src" / "idna.c".}
{.compile: path / "src" / "inet.c".}
{.compile: path / "src" / "random.c".}
{.compile: path / "src" / "strscpy.c".}
{.compile: path / "src" / "thread-common.c".}
{.compile: path / "src" / "threadpool.c".}
{.compile: path / "src" / "timer.c".}
{.compile: path / "src" / "uv-data-getter-setters.c".}
{.compile: path / "src" / "uv-common.c".}
{.compile: path / "src" / "version.c".}
{.compile: path / "src" / "strtok.c".}



#[
    src/unix/async.c \
                   src/unix/core.c \
                   src/unix/dl.c \
                   src/unix/fs.c \
                   src/unix/getaddrinfo.c \
                   src/unix/getnameinfo.c \
                   src/unix/internal.h \
                   src/unix/loop-watcher.c \
                   src/unix/loop.c \
                   src/unix/pipe.c \
                   src/unix/poll.c \
                   src/unix/process.c \
                   src/unix/random-devurandom.c \
                   src/unix/signal.c \
                   src/unix/stream.c \
                   src/unix/tcp.c \
                   src/unix/thread.c \
                   src/unix/tty.c \
                   src/unix/udp.c
]#

when defined linux:
    discard






#[
    src/fs-poll.c \
                   src/heap-inl.h \
                   src/idna.c \
                   src/idna.h \
                   src/inet.c \
                   src/queue.h \
                   src/random.c \
                   src/strscpy.c \
                   src/strscpy.h \
                   src/thread-common.c \
                   src/threadpool.c \
                   src/timer.c \
                   src/uv-data-getter-setters.c \
                   src/uv-common.c \
                   src/uv-common.h \
                   src/version.c \
                   src/strtok.c \
                   src/strtok.h
]#