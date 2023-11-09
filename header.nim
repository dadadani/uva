# Generated @ 2023-11-08T12:58:22+01:00
# Command line:
#   /home/daniele/.nimble/pkgs2/nimterop-0.6.13-a93246b2ad5531db11e51de7b2d188c42d95576a/nimterop/toast --preprocess -m:c --includeDirs+=/home/daniele/.cache/nim/nimterop/libuv/include --passL+=/home/daniele/.cache/nim/nimterop/libuv/buildcache/libuv.a --pnim --nim:/home/daniele/.choosenim/toolchains/nim-1.6.14/bin/nim --pluginSourcePath=/home/daniele/.cache/nim/nimterop/cPlugins/nimterop_896335056.nim /home/daniele/.cache/nim/nimterop/libuv/include/uv.h -o /home/daniele/.cache/nim/nimterop/toastCache/nimterop_863174983.nim

# const 'UV_EXTERN' has unsupported value '__attribute__((visibility("default")))'
# tree-sitter parse error: 'typedef enum {', skipped
# tree-sitter parse error: 'typedef enum {', skipped
# const 'UV_MAXHOSTNAMESIZE' has unsupported value '(MAXHOSTNAMELEN + 1)'
{.push hint[ConvFromXtoItselfNotNeeded]: off.}
import macros

macro defineEnum(typ: untyped): untyped =
  result = newNimNode(nnkStmtList)

  # Enum mapped to distinct cint
  result.add quote do:
    type `typ`* = distinct cint

  for i in ["+", "-", "*", "div", "mod", "shl", "shr", "or", "and", "xor", "<", "<=", "==", ">", ">="]:
    let
      ni = newIdentNode(i)
      typout = if i[0] in "<=>": newIdentNode("bool") else: typ # comparisons return bool
    if i[0] == '>': # cannot borrow `>` and `>=` from templates
      let
        nopp = if i.len == 2: newIdentNode("<=") else: newIdentNode("<")
      result.add quote do:
        proc `ni`*(x: `typ`, y: cint): `typout` = `nopp`(y, x)
        proc `ni`*(x: cint, y: `typ`): `typout` = `nopp`(y, x)
        proc `ni`*(x, y: `typ`): `typout` = `nopp`(y, x)
    else:
      result.add quote do:
        proc `ni`*(x: `typ`, y: cint): `typout` {.borrow.}
        proc `ni`*(x: cint, y: `typ`): `typout` {.borrow.}
        proc `ni`*(x, y: `typ`): `typout` {.borrow.}
    result.add quote do:
      proc `ni`*(x: `typ`, y: int): `typout` = `ni`(x, y.cint)
      proc `ni`*(x: int, y: `typ`): `typout` = `ni`(x.cint, y)

  let
    divop = newIdentNode("/")   # `/`()
    dlrop = newIdentNode("$")   # `$`()
    notop = newIdentNode("not") # `not`()
  result.add quote do:
    proc `divop`*(x, y: `typ`): `typ` = `typ`((x.float / y.float).cint)
    proc `divop`*(x: `typ`, y: cint): `typ` = `divop`(x, `typ`(y))
    proc `divop`*(x: cint, y: `typ`): `typ` = `divop`(`typ`(x), y)
    proc `divop`*(x: `typ`, y: int): `typ` = `divop`(x, y.cint)
    proc `divop`*(x: int, y: `typ`): `typ` = `divop`(x.cint, y)

    proc `dlrop`*(x: `typ`): string {.borrow.}
    proc `notop`*(x: `typ`): `typ` {.borrow.}


{.pragma: impuvHdr,
  header: "/home/daniele/.cache/nim/nimterop/libuv/include/uv.h".}
{.experimental: "codeReordering".}
{.passC: "-I/home/daniele/.cache/nim/nimterop/libuv/include".}
{.passL: "/home/daniele/.cache/nim/nimterop/libuv/buildcache/libuv.a".}
defineEnum(uv_loop_option)
defineEnum(uv_run_mode)
defineEnum(uv_clock_id)
defineEnum(uv_membership)
defineEnum(uv_tcp_flags)
defineEnum(uv_udp_flags)
defineEnum(uv_tty_mode_t)
defineEnum(uv_tty_vtermstate_t)
defineEnum(Enum_uvh1)
defineEnum(uv_poll_event)
defineEnum(uv_stdio_flags)   ## ```
                             ##   uv_spawn() options.
                             ## ```
defineEnum(uv_process_flags) ## ```
                             ##   These are the flags that can be used for the uv_process_options.flags field.
                             ## ```
defineEnum(uv_dirent_type_t)
defineEnum(uv_fs_type)
defineEnum(uv_fs_event)
defineEnum(uv_fs_event_flags) ## ```
                              ##   Flags to be passed to uv_fs_event_start().
                              ## ```
defineEnum(uv_thread_create_flags)
const
  UV_LOOP_BLOCK_SIGNAL* = (0).uv_loop_option
  UV_METRICS_IDLE_TIME* = (UV_LOOP_BLOCK_SIGNAL + 1).uv_loop_option
  UV_RUN_DEFAULT* = (0).uv_run_mode
  UV_RUN_ONCE* = (UV_RUN_DEFAULT + 1).uv_run_mode
  UV_RUN_NOWAIT* = (UV_RUN_ONCE + 1).uv_run_mode
  UV_CLOCK_MONOTONIC* = (0).uv_clock_id
  UV_CLOCK_REALTIME* = (UV_CLOCK_MONOTONIC + 1).uv_clock_id
  UV_LEAVE_GROUP* = (0).uv_membership
  UV_JOIN_GROUP* = (UV_LEAVE_GROUP + 1).uv_membership
  UV_TCP_IPV6ONLY* = (1).uv_tcp_flags ## ```
                                      ##   Used with uv_tcp_bind, when an IPv6 address is used.
                                      ## ```
  UV_UDP_IPV6ONLY* = (1).uv_udp_flags ## ```
                                      ##   Disables dual stack mode.
                                      ## ```
  UV_UDP_PARTIAL* = (2).uv_udp_flags ## ```
                                     ##   Indicates message was truncated because read buffer was too small. The
                                     ##      remainder was discarded by the OS. Used in uv_udp_recv_cb.
                                     ## ```
  UV_UDP_REUSEADDR* = (4).uv_udp_flags ## ```
                                       ##   Indicates if SO_REUSEADDR will be set when binding the handle.
                                       ##      This sets the SO_REUSEPORT socket flag on the BSDs and OS X. On other
                                       ##      Unix platforms, it sets the SO_REUSEADDR flag.  What that means is that
                                       ##      multiple threads or processes can bind to the same address without error
                                       ##      (provided they all set the flag) but only the last one to bind will receive
                                       ##      any traffic, in effect "stealing" the port from the previous listener.
                                       ## ```
  UV_UDP_MMSG_CHUNK* = (8).uv_udp_flags ## ```
                                        ##   Indicates that the message was received by recvmmsg, so the buffer provided
                                        ##      must not be freed by the recv_cb callback.
                                        ## ```
  UV_UDP_MMSG_FREE* = (16).uv_udp_flags ## ```
                                        ##   Indicates that the buffer provided has been fully utilized by recvmmsg and
                                        ##      that it should now be freed by the recv_cb callback. When this flag is set
                                        ##      in uv_udp_recv_cb, nread will always be 0 and addr will always be NULL.
                                        ## ```
  UV_UDP_LINUX_RECVERR* = (32).uv_udp_flags ## ```
                                            ##   Indicates if IP_RECVERR/IPV6_RECVERR will be set when binding the handle.
                                            ##      This sets IP_RECVERR for IPv4 and IPV6_RECVERR for IPv6 UDP sockets on
                                            ##      Linux. This stops the Linux kernel from suppressing some ICMP error
                                            ##      messages and enables full ICMP error reporting for faster failover.
                                            ##      This flag is no-op on platforms other than Linux.
                                            ## ```
  UV_UDP_RECVMMSG* = (256).uv_udp_flags ## ```
                                        ##   Indicates that recvmmsg should be used, if available.
                                        ## ```
  UV_TTY_MODE_NORMAL* = (0).uv_tty_mode_t ## ```
                                          ##   Initial/normal terminal mode
                                          ## ```
  UV_TTY_MODE_RAW* = (UV_TTY_MODE_NORMAL + 1).uv_tty_mode_t ## ```
                                                            ##   Raw input mode (On Windows, ENABLE_WINDOW_INPUT is also enabled)
                                                            ## ```
  UV_TTY_MODE_IO* = (UV_TTY_MODE_RAW + 1).uv_tty_mode_t ## ```
                                                        ##   Binary-safe I/O mode for IPC (Unix-only)
                                                        ## ```
  UV_TTY_SUPPORTED* = (0).uv_tty_vtermstate_t ## ```
                                              ##   The console supports handling of virtual terminal sequences
                                              ##      (Windows10 new console, ConEmu)
                                              ## ```
  UV_TTY_UNSUPPORTED* = (UV_TTY_SUPPORTED + 1).uv_tty_vtermstate_t ## ```
                                                                   ##   The console cannot process the virtual terminal sequence.  (Legacy
                                                                   ##      console)
                                                                   ## ```
  UV_PIPE_NO_TRUNCATE* = (1'u shl typeof(1'u)(0)).cint
  UV_READABLE* = (1).uv_poll_event
  UV_WRITABLE* = (2).uv_poll_event
  UV_DISCONNECT* = (4).uv_poll_event
  UV_PRIORITIZED* = (8).uv_poll_event
  UV_IGNORE* = (0x00000000).uv_stdio_flags
  UV_CREATE_PIPE* = (0x00000001).uv_stdio_flags
  UV_INHERIT_FD* = (0x00000002).uv_stdio_flags
  UV_INHERIT_STREAM* = (0x00000004).uv_stdio_flags
  UV_READABLE_PIPE* = (0x00000010).uv_stdio_flags ## ```
                                                  ##   When UV_CREATE_PIPE is specified, UV_READABLE_PIPE and UV_WRITABLE_PIPE
                                                  ##      determine the direction of flow, from the child process' perspective. Both
                                                  ##      flags may be specified to create a duplex data stream.
                                                  ## ```
  UV_WRITABLE_PIPE* = (0x00000020).uv_stdio_flags
  UV_NONBLOCK_PIPE* = (0x00000040).uv_stdio_flags ## ```
                                                  ##   When UV_CREATE_PIPE is specified, specifying UV_NONBLOCK_PIPE opens the
                                                  ##      handle in non-blocking mode in the child. This may cause loss of data,
                                                  ##      if the child is not designed to handle to encounter this mode,
                                                  ##      but can also be significantly more efficient.
                                                  ## ```
  UV_OVERLAPPED_PIPE* = (0x00000040).uv_stdio_flags ## ```
                                                    ##   old name, for compatibility
                                                    ## ```
  UV_PROCESS_SETUID* = ((1 shl typeof(1)(0))).uv_process_flags ## ```
                                                               ##   Set the child process' user id. The user id is supplied in the uid field
                                                               ##      of the options struct. This does not work on windows; setting this flag
                                                               ##      will cause uv_spawn() to fail.
                                                               ## ```
  UV_PROCESS_SETGID* = ((1 shl typeof(1)(1))).uv_process_flags ## ```
                                                               ##   Set the child process' group id. The user id is supplied in the gid
                                                               ##      field of the options struct. This does not work on windows; setting this
                                                               ##      flag will cause uv_spawn() to fail.
                                                               ## ```
  UV_PROCESS_WINDOWS_VERBATIM_ARGUMENTS* = ((1 shl typeof(1)(2))).uv_process_flags ## ```
                                                                                   ##   Do not wrap any arguments in quotes, or perform any other escaping, when
                                                                                   ##      converting the argument list into a command line string. This option is
                                                                                   ##      only meaningful on Windows systems. On Unix it is silently ignored.
                                                                                   ## ```
  UV_PROCESS_DETACHED* = ((1 shl typeof(1)(3))).uv_process_flags ## ```
                                                                 ##   Spawn the child process in a detached state - this will make it a process
                                                                 ##      group leader, and will effectively enable the child to keep running after
                                                                 ##      the parent exits.  Note that the child process will still keep the
                                                                 ##      parent's event loop alive unless the parent process calls uv_unref() on
                                                                 ##      the child's process handle.
                                                                 ## ```
  UV_PROCESS_WINDOWS_HIDE* = ((1 shl typeof(1)(4))).uv_process_flags ## ```
                                                                     ##   Hide the subprocess window that would normally be created. This option is
                                                                     ##      only meaningful on Windows systems. On Unix it is silently ignored.
                                                                     ## ```
  UV_PROCESS_WINDOWS_HIDE_CONSOLE* = ((1 shl typeof(1)(5))).uv_process_flags ## ```
                                                                             ##   Hide the subprocess console window that would normally be created. This
                                                                             ##      option is only meaningful on Windows systems. On Unix it is silently
                                                                             ##      ignored.
                                                                             ## ```
  UV_PROCESS_WINDOWS_HIDE_GUI* = ((1 shl typeof(1)(6))).uv_process_flags ## ```
                                                                         ##   Hide the subprocess GUI window that would normally be created. This
                                                                         ##      option is only meaningful on Windows systems. On Unix it is silently
                                                                         ##      ignored.
                                                                         ## ```
  UV_DIRENT_UNKNOWN* = (0).uv_dirent_type_t
  UV_DIRENT_FILE* = (UV_DIRENT_UNKNOWN + 1).uv_dirent_type_t
  UV_DIRENT_DIR* = (UV_DIRENT_FILE + 1).uv_dirent_type_t
  UV_DIRENT_LINK* = (UV_DIRENT_DIR + 1).uv_dirent_type_t
  UV_DIRENT_FIFO* = (UV_DIRENT_LINK + 1).uv_dirent_type_t
  UV_DIRENT_SOCKET* = (UV_DIRENT_FIFO + 1).uv_dirent_type_t
  UV_DIRENT_CHAR* = (UV_DIRENT_SOCKET + 1).uv_dirent_type_t
  UV_DIRENT_BLOCK* = (UV_DIRENT_CHAR + 1).uv_dirent_type_t
  UV_PRIORITY_LOW* = 19
  UV_PRIORITY_BELOW_NORMAL* = 10
  UV_PRIORITY_NORMAL* = 0
  UV_PRIORITY_ABOVE_NORMAL* = -7
  UV_PRIORITY_HIGH* = -14
  UV_PRIORITY_HIGHEST* = -20
  UV_FS_UNKNOWN* = (-1).uv_fs_type
  UV_FS_CUSTOM* = (UV_FS_UNKNOWN + 1).uv_fs_type
  UV_FS_OPEN* = (UV_FS_CUSTOM + 1).uv_fs_type
  UV_FS_CLOSE* = (UV_FS_OPEN + 1).uv_fs_type
  UV_FS_READ* = (UV_FS_CLOSE + 1).uv_fs_type
  UV_FS_WRITE* = (UV_FS_READ + 1).uv_fs_type
  UV_FS_SENDFILE* = (UV_FS_WRITE + 1).uv_fs_type
  UV_FS_STAT* = (UV_FS_SENDFILE + 1).uv_fs_type
  UV_FS_LSTAT* = (UV_FS_STAT + 1).uv_fs_type
  UV_FS_FSTAT* = (UV_FS_LSTAT + 1).uv_fs_type
  UV_FS_FTRUNCATE* = (UV_FS_FSTAT + 1).uv_fs_type
  UV_FS_UTIME* = (UV_FS_FTRUNCATE + 1).uv_fs_type
  UV_FS_FUTIME* = (UV_FS_UTIME + 1).uv_fs_type
  UV_FS_ACCESS* = (UV_FS_FUTIME + 1).uv_fs_type
  UV_FS_CHMOD* = (UV_FS_ACCESS + 1).uv_fs_type
  UV_FS_FCHMOD* = (UV_FS_CHMOD + 1).uv_fs_type
  UV_FS_FSYNC* = (UV_FS_FCHMOD + 1).uv_fs_type
  UV_FS_FDATASYNC* = (UV_FS_FSYNC + 1).uv_fs_type
  UV_FS_UNLINK* = (UV_FS_FDATASYNC + 1).uv_fs_type
  UV_FS_RMDIR* = (UV_FS_UNLINK + 1).uv_fs_type
  UV_FS_MKDIR* = (UV_FS_RMDIR + 1).uv_fs_type
  UV_FS_MKDTEMP* = (UV_FS_MKDIR + 1).uv_fs_type
  UV_FS_RENAME* = (UV_FS_MKDTEMP + 1).uv_fs_type
  UV_FS_SCANDIR* = (UV_FS_RENAME + 1).uv_fs_type
  UV_FS_LINK* = (UV_FS_SCANDIR + 1).uv_fs_type
  UV_FS_SYMLINK* = (UV_FS_LINK + 1).uv_fs_type
  UV_FS_READLINK* = (UV_FS_SYMLINK + 1).uv_fs_type
  UV_FS_CHOWN* = (UV_FS_READLINK + 1).uv_fs_type
  UV_FS_FCHOWN* = (UV_FS_CHOWN + 1).uv_fs_type
  UV_FS_REALPATH* = (UV_FS_FCHOWN + 1).uv_fs_type
  UV_FS_COPYFILE* = (UV_FS_REALPATH + 1).uv_fs_type
  UV_FS_LCHOWN* = (UV_FS_COPYFILE + 1).uv_fs_type
  UV_FS_OPENDIR* = (UV_FS_LCHOWN + 1).uv_fs_type
  UV_FS_READDIR* = (UV_FS_OPENDIR + 1).uv_fs_type
  UV_FS_CLOSEDIR* = (UV_FS_READDIR + 1).uv_fs_type
  UV_FS_STATFS* = (UV_FS_CLOSEDIR + 1).uv_fs_type
  UV_FS_MKSTEMP* = (UV_FS_STATFS + 1).uv_fs_type
  UV_FS_LUTIME* = (UV_FS_MKSTEMP + 1).uv_fs_type
  UV_FS_COPYFILE_EXCL* = 0x00000001
  UV_FS_COPYFILE_FICLONE* = 0x00000002
  UV_FS_COPYFILE_FICLONE_FORCE* = 0x00000004
  UV_FS_SYMLINK_DIR* = 0x00000001
  UV_FS_SYMLINK_JUNCTION* = 0x00000002
  UV_RENAME* = (1).uv_fs_event
  UV_CHANGE* = (2).uv_fs_event
  UV_FS_EVENT_WATCH_ENTRY* = (1).uv_fs_event_flags ## ```
                                                   ##   By default, if the fs event watcher is given a directory name, we will
                                                   ##      watch for all events in that directory. This flags overrides this behavior
                                                   ##      and makes fs_event report only changes to the directory entry itself. This
                                                   ##      flag does not affect individual files watched.
                                                   ##      This flag is currently not implemented yet on any backend.
                                                   ## ```
  UV_FS_EVENT_STAT* = (2).uv_fs_event_flags ## ```
                                            ##   By default uv_fs_event will try to use a kernel interface such as inotify
                                            ##      or kqueue to detect events. This may not work on remote filesystems such
                                            ##      as NFS mounts. This flag makes fs_event fall back to calling stat() on a
                                            ##      regular interval.
                                            ##      This flag is currently not implemented yet on any backend.
                                            ## ```
  UV_FS_EVENT_RECURSIVE* = (4).uv_fs_event_flags ## ```
                                                 ##   By default, event watcher, when watching directory, is not registering
                                                 ##      (is ignoring) changes in it's subdirectories.
                                                 ##      This flag will override this behaviour on platforms that support it.
                                                 ## ```
  UV_IF_NAMESIZE* = (16 + typeof(16)(1))
  UV_THREAD_NO_FLAGS* = (0x00000000).uv_thread_create_flags
  UV_THREAD_HAS_STACK_SIZE* = (0x00000001).uv_thread_create_flags


type
  uv_buf_t* {.bycopy, impuvHdr, importc: "struct uv_buf_t".} = object
    when defined windows:
        base*: cstring
        len*: culong
    else:
        base*: cstring
        len*: csize_t 

when defined windows:
    from winlean import AddrInfo, SockAddr
    export AddrInfo, SockAddr
else:
    from posix import AddrInfo, SockAddr  
    export AddrInfo, SockAddr

type
  uv_handle_type_arg* = cint
  uv_req_type_arg* = cint

  uv_handle_type* = enum
    UV_UNKNOWN_HANDLE = 0, UV_ASYNC, UV_CHECK, UV_FS_EVENT, UV_FS_POLL, 
    UV_HANDLE, UV_IDLE, UV_NAMED_PIPE, UV_POLL, UV_PREPARE, UV_PROCESS, 
    UV_STREAM, UV_TCP, UV_TIMER, UV_TTY, UV_UDP, UV_SIGNAL, UV_FILE, 
    UV_HANDLE_TYPE_ARG_MAX
  uv_req_type* = enum
    UV_UNKNOWN_REQ = 0, UV_REQ, UV_CONNECT, UV_WRITE, UV_SHUTDOWN, UV_UDP_SEND, 
    UV_FS, UV_WORK, UV_GETADDRINFO, UV_GETNAMEINFO, UV_REQ_TYPE_ARG_MAX


  
type
  uvx_queue* {.bycopy, impuvHdr, importc: "struct uv__queue".} = object
    next*: ptr uvx_queue
    prev*: ptr uvx_queue

  uv_loop_t* {.importc, impuvHdr.} = uv_loop_s ## ```
                                               ##   Handle types.
                                               ## ```
  uv_handle_t* {.importc, impuvHdr.} = uv_handle_s
  uv_dir_t* {.importc, impuvHdr.} = uv_dir_s
  uv_stream_t* {.importc, impuvHdr.} = uv_stream_s
  uv_tcp_t* {.importc, impuvHdr.} = uv_tcp_s
  uv_udp_t* {.importc, impuvHdr.} = uv_udp_s
  uv_pipe_t* {.importc, impuvHdr.} = uv_pipe_s
  uv_tty_t* {.importc, impuvHdr.} = uv_tty_s
  uv_poll_t* {.importc, impuvHdr.} = uv_poll_s
  uv_timer_t* {.importc, impuvHdr.} = uv_timer_s
  uv_prepare_t* {.importc, impuvHdr.} = uv_prepare_s
  uv_check_t* {.importc, impuvHdr.} = uv_check_s
  uv_idle_t* {.importc, impuvHdr.} = uv_idle_s
  uv_async_t* {.importc, impuvHdr.} = uv_async_s
  uv_process_t* {.importc, impuvHdr.} = uv_process_s
  uv_fs_event_t* {.importc, impuvHdr.} = uv_fs_event_s
  uv_fs_poll_t* {.importc, impuvHdr.} = uv_fs_poll_s
  uv_signal_t* {.importc, impuvHdr.} = uv_signal_s
  uv_req_t* {.importc, impuvHdr.} = uv_req_s ## ```
                                             ##   Request types.
                                             ## ```
  uv_getaddrinfo_t* {.importc, impuvHdr.} = uv_getaddrinfo_s
  uv_getnameinfo_t* {.importc, impuvHdr.} = uv_getnameinfo_s
  uv_shutdown_t* {.importc, impuvHdr.} = uv_shutdown_s
  uv_write_t* {.importc, impuvHdr.} = uv_write_s
  uv_connect_t* {.importc, impuvHdr.} = uv_connect_s
  uv_udp_send_t* {.importc, impuvHdr.} = uv_udp_send_s
  uv_fs_t* {.importc, impuvHdr.} = uv_fs_s
  uv_work_t* {.importc, impuvHdr.} = uv_work_s
  uv_random_t* {.importc, impuvHdr.} = uv_random_s
  uv_env_item_t* {.importc, impuvHdr.} = uv_env_item_s ## ```
                                                       ##   None of the above.
                                                       ## ```
  uv_cpu_info_t* {.importc, impuvHdr.} = uv_cpu_info_s
  uv_interface_address_t* {.importc, impuvHdr.} = uv_interface_address_s
  uv_dirent_t* {.importc, impuvHdr.} = uv_dirent_s
  uv_passwd_t* {.importc, impuvHdr.} = uv_passwd_s
  uv_group_t* {.importc, impuvHdr.} = uv_group_s
  uv_utsname_t* {.importc, impuvHdr.} = uv_utsname_s
  uv_statfs_t* {.importc, impuvHdr.} = uv_statfs_s
  uv_metrics_t* {.importc, impuvHdr.} = uv_metrics_s
  uv_malloc_func* {.importc, impuvHdr.} = proc (size: uint): pointer {.cdecl.}
  uv_realloc_func* {.importc, impuvHdr.} = proc (`ptr`: pointer; size: uint): pointer {.
      cdecl.}
  uv_calloc_func* {.importc, impuvHdr.} = proc (count: uint; size: uint): pointer {.
      cdecl.}
  uv_free_func* {.importc, impuvHdr.} = proc (`ptr`: pointer) {.cdecl.}
  uv_alloc_cb* {.importc, impuvHdr.} = proc (handle: ptr uv_handle_t;
      suggested_size: uint; buf: ptr uv_buf_t) {.cdecl.}
  uv_read_cb* {.importc, impuvHdr.} = proc (stream: ptr uv_stream_t; nread: int;
      buf: ptr uv_buf_t) {.cdecl.}
  uv_write_cb* {.importc, impuvHdr.} = proc (req: ptr uv_write_t; status: cint) {.
      cdecl.}
  uv_connect_cb* {.importc, impuvHdr.} = proc (req: ptr uv_connect_t;
      status: cint) {.cdecl.}
  uv_shutdown_cb* {.importc, impuvHdr.} = proc (req: ptr uv_shutdown_t;
      status: cint) {.cdecl.}
  uv_connection_cb* {.importc, impuvHdr.} = proc (server: ptr uv_stream_t;
      status: cint) {.cdecl.}
  uv_close_cb* {.importc, impuvHdr.} = proc (handle: ptr uv_handle_t) {.cdecl.}
  uv_poll_cb* {.importc, impuvHdr.} = proc (handle: ptr uv_poll_t; status: cint;
      events: cint) {.cdecl.}
  uv_timer_cb* {.importc, impuvHdr.} = proc (handle: ptr uv_timer_t) {.cdecl.}
  uv_async_cb* {.importc, impuvHdr.} = proc (handle: ptr uv_async_t) {.cdecl.}
  uv_prepare_cb* {.importc, impuvHdr.} = proc (handle: ptr uv_prepare_t) {.cdecl.}
  uv_check_cb* {.importc, impuvHdr.} = proc (handle: ptr uv_check_t) {.cdecl.}
  uv_idle_cb* {.importc, impuvHdr.} = proc (handle: ptr uv_idle_t) {.cdecl.}
  uv_exit_cb* {.importc, impuvHdr.} = proc (a1: ptr uv_process_t;
      exit_status: int64; term_signal: cint) {.cdecl.}
  uv_walk_cb* {.importc, impuvHdr.} = proc (handle: ptr uv_handle_t;
      arg: pointer) {.cdecl.}
  uv_fs_cb* {.importc, impuvHdr.} = proc (req: ptr uv_fs_t) {.cdecl.}
  uv_work_cb* {.importc, impuvHdr.} = proc (req: ptr uv_work_t) {.cdecl.}
  uv_after_work_cb* {.importc, impuvHdr.} = proc (req: ptr uv_work_t;
      status: cint) {.cdecl.}
  uv_getaddrinfo_cb* {.importc, impuvHdr.} = proc (req: ptr uv_getaddrinfo_t;
      status: cint; res: ptr AddrInfo) {.cdecl.}
  uv_getnameinfo_cb* {.importc, impuvHdr.} = proc (req: ptr uv_getnameinfo_t;
      status: cint; hostname: cstring; service: cstring) {.cdecl.}
  uv_random_cb* {.importc, impuvHdr.} = proc (req: ptr uv_random_t;
      status: cint; buf: pointer; buflen: uint) {.cdecl.}
  uv_timespec_t* {.bycopy, importc, impuvHdr.} = object ## ```
                                                         ##   XXX(bnoordhuis) not 2038-proof, https:github.com/libuv/libuv/issues/3864
                                                         ## ```
    tv_sec*: clong
    tv_nsec*: clong

  uv_timespec64_t* {.bycopy, importc, impuvHdr.} = object
    tv_sec*: int64
    tv_nsec*: int32

  uv_timeval_t* {.bycopy, importc, impuvHdr.} = object ## ```
                                                        ##   XXX(bnoordhuis) not 2038-proof, https:github.com/libuv/libuv/issues/3864
                                                        ## ```
    tv_sec*: clong
    tv_usec*: clong

  uv_timeval64_t* {.bycopy, importc, impuvHdr.} = object
    tv_sec*: int64
    tv_usec*: int32

  uv_stat_t* {.bycopy, importc, impuvHdr.} = object
    st_dev*: uint64
    st_mode*: uint64
    st_nlink*: uint64
    st_uid*: uint64
    st_gid*: uint64
    st_rdev*: uint64
    st_ino*: uint64
    st_size*: uint64
    st_blksize*: uint64
    st_blocks*: uint64
    st_flags*: uint64
    st_gen*: uint64
    st_atim*: uv_timespec_t
    st_mtim*: uv_timespec_t
    st_ctim*: uv_timespec_t
    st_birthtim*: uv_timespec_t

  uv_fs_event_cb* {.importc, impuvHdr.} = proc (handle: ptr uv_fs_event_t;
      filename: cstring; events: cint; status: cint) {.cdecl.}
  uv_fs_poll_cb* {.importc, impuvHdr.} = proc (handle: ptr uv_fs_poll_t;
      status: cint; prev: ptr uv_stat_t; curr: ptr uv_stat_t) {.cdecl.}
  uv_signal_cb* {.importc, impuvHdr.} = proc (handle: ptr uv_signal_t;
      signum: cint) {.cdecl.}
  uv_req_s* {.bycopy, impuvHdr, importc: "struct uv_req_s".} = object
    data*: pointer           ## ```
                             ##   public
                             ## ```
    `type`*: uv_req_type_arg     ## ```
                             ##   read-only
                             ## ```
    reserved*: array[6, pointer] ## ```
                                 ##   private
                                 ## ```
  
  uv_shutdown_s* {.bycopy, impuvHdr, importc: "struct uv_shutdown_s".} = object
    data*: pointer           ## ```
                             ##   public
                             ## ```
    `type`*: uv_req_type_arg     ## ```
                             ##   read-only
                             ## ```
    reserved*: array[6, pointer] ## ```
                                 ##   private
                                 ## ```
    handle*: ptr uv_stream_t ## ```
                             ##   empty
                             ## ```
    cb*: uv_shutdown_cb      ## ```
                             ##   empty
                             ## ```
  
  Union_uvh1* {.union, bycopy, impuvHdr, importc: "union Union_uvh1".} = object
    fd*: cint
    reserved*: array[4, pointer]

  uv_handle_s* {.bycopy, impuvHdr, importc: "struct uv_handle_s".} = object
    data*: pointer           ## ```
                             ##   public
                             ## ```
    loop*: ptr uv_loop_t     ## ```
                             ##   read-only
                             ## ```
    `type`*: uv_handle_type_arg  ## ```
                             ##   private
                             ## ```
    close_cb*: uv_close_cb   ## ```
                             ##   private
                             ## ```
    handle_queue*: uvx_queue
    u*: Union_uvh1
    next_closing*: ptr uv_handle_t
    flags*: cuint

  Union_uvh2* {.union, bycopy, impuvHdr, importc: "union Union_uvh2".} = object
    fd*: cint
    reserved*: array[4, pointer]

  uv_stream_s* {.bycopy, impuvHdr, importc: "struct uv_stream_s".} = object
    data*: pointer           ## ```
                             ##   public
                             ## ```
    loop*: ptr uv_loop_t     ## ```
                             ##   read-only
                             ## ```
    `type`*: uv_handle_type_arg  ## ```
                             ##   private
                             ## ```
    close_cb*: uv_close_cb   ## ```
                             ##   private
                             ## ```
    handle_queue*: uvx_queue
    u*: Union_uvh2
    next_closing*: ptr uv_handle_t
    flags*: cuint            ## ```
                             ##   number of bytes queued for writing
                             ## ```
    write_queue_size*: uint  ## ```
                             ##   number of bytes queued for writing
                             ## ```
    alloc_cb*: uv_alloc_cb
    read_cb*: uv_read_cb     ## ```
                             ##   private
                             ## ```
    connect_req*: ptr uv_connect_t ## ```
                                   ##   private
                                   ## ```
    shutdown_req*: ptr uv_shutdown_t
    io_watcher*: uvx_io_t
    write_queue*: uvx_queue
    write_completed_queue*: uvx_queue
    connection_cb*: uv_connection_cb
    delayed_error*: cint
    accepted_fd*: cint
    queued_fds*: pointer     ## ```
                             ##   empty
                             ## ```
  
  uv_write_s* {.bycopy, impuvHdr, importc: "struct uv_write_s".} = object
    data*: pointer           ## ```
                             ##   public
                             ## ```
    `type`*: uv_req_type_arg     ## ```
                             ##   read-only
                             ## ```
    reserved*: array[6, pointer] ## ```
                                 ##   private
                                 ## ```
    cb*: uv_write_cb         ## ```
                             ##   empty
                             ## ```
    send_handle*: ptr uv_stream_t ## ```
                                  ##   TODO: make private and unix-only in v2.x.
                                  ## ```
    handle*: ptr uv_stream_t ## ```
                             ##   TODO: make private and unix-only in v2.x.
                             ## ```
    queue*: uvx_queue
    write_index*: cuint
    bufs*: ptr uv_buf_t
    nbufs*: cuint
    error*: cint
    bufsml*: array[4, uv_buf_t]

  Union_uvh3* {.union, bycopy, impuvHdr, importc: "union Union_uvh3".} = object
    fd*: cint
    reserved*: array[4, pointer]

  uv_tcp_s* {.bycopy, impuvHdr, importc: "struct uv_tcp_s".} = object
    data*: pointer           ## ```
                             ##   public
                             ## ```
    loop*: ptr uv_loop_t     ## ```
                             ##   read-only
                             ## ```
    `type`*: uv_handle_type_arg  ## ```
                             ##   private
                             ## ```
    close_cb*: uv_close_cb   ## ```
                             ##   private
                             ## ```
    handle_queue*: uvx_queue
    u*: Union_uvh3
    next_closing*: ptr uv_handle_t
    flags*: cuint            ## ```
                             ##   number of bytes queued for writing
                             ## ```
    write_queue_size*: uint  ## ```
                             ##   number of bytes queued for writing
                             ## ```
    alloc_cb*: uv_alloc_cb
    read_cb*: uv_read_cb     ## ```
                             ##   private
                             ## ```
    connect_req*: ptr uv_connect_t ## ```
                                   ##   private
                                   ## ```
    shutdown_req*: ptr uv_shutdown_t
    io_watcher*: uvx_io_t
    write_queue*: uvx_queue
    write_completed_queue*: uvx_queue
    connection_cb*: uv_connection_cb
    delayed_error*: cint
    accepted_fd*: cint
    queued_fds*: pointer     ## ```
                             ##   empty 
                             ##      empty
                             ## ```
  
  uv_connect_s* {.bycopy, impuvHdr, importc: "struct uv_connect_s".} = object
    data*: pointer           ## ```
                             ##   public
                             ## ```
    `type`*: uv_req_type_arg     ## ```
                             ##   read-only
                             ## ```
    reserved*: array[6, pointer] ## ```
                                 ##   private
                                 ## ```
    cb*: uv_connect_cb       ## ```
                             ##   empty
                             ## ```
    handle*: ptr uv_stream_t
    queue*: uvx_queue

  uv_udp_send_cb* {.importc, impuvHdr.} = proc (req: ptr uv_udp_send_t;
      status: cint) {.cdecl.}
  uv_udp_recv_cb* {.importc, impuvHdr.} = proc (handle: ptr uv_udp_t;
      nread: int; buf: ptr uv_buf_t; `addr`: ptr SockAddr; flags: cuint) {.cdecl.}
  Union_uvh4* {.union, bycopy, impuvHdr, importc: "union Union_uvh4".} = object
    fd*: cint
    reserved*: array[4, pointer]

  uv_udp_s* {.bycopy, impuvHdr, importc: "struct uv_udp_s".} = object
    data*: pointer           ## ```
                             ##   public
                             ## ```
    loop*: ptr uv_loop_t     ## ```
                             ##   read-only
                             ## ```
    `type`*: uv_handle_type_arg  ## ```
                             ##   private
                             ## ```
    close_cb*: uv_close_cb   ## ```
                             ##   private
                             ## ```
    handle_queue*: uvx_queue
    u*: Union_uvh4
    next_closing*: ptr uv_handle_t
    flags*: cuint ## ```
                  ##   read-only 
                  ##     
                  ##      Number of bytes queued for sending. This field strictly shows how much
                  ##      information is currently queued.
                  ## ```
    send_queue_size*: uint ## ```
                           ##   read-only 
                           ##     
                           ##      Number of bytes queued for sending. This field strictly shows how much
                           ##      information is currently queued.
                           ## ```
    send_queue_count*: uint ## ```
                            ##   Number of send requests currently in the queue awaiting to be processed.
                            ## ```
    alloc_cb*: uv_alloc_cb
    recv_cb*: uv_udp_recv_cb
    io_watcher*: uvx_io_t
    write_queue*: uvx_queue
    write_completed_queue*: uvx_queue

  uv_udp_send_s* {.bycopy, impuvHdr, importc: "struct uv_udp_send_s".} = object
    data*: pointer           ## ```
                             ##   public
                             ## ```
    `type`*: uv_req_type_arg     ## ```
                             ##   read-only
                             ## ```
    reserved*: array[6, pointer] ## ```
                                 ##   private
                                 ## ```
    handle*: ptr uv_udp_t    ## ```
                             ##   empty
                             ## ```
    cb*: uv_udp_send_cb
    queue*: uvx_queue
    `addr`*: sockaddr_storage
    nbufs*: cuint
    bufs*: ptr uv_buf_t
    status*: int
    send_cb*: uv_udp_send_cb
    bufsml*: array[4, uv_buf_t]

  Union_uvh5* {.union, bycopy, impuvHdr, importc: "union Union_uvh5".} = object
    fd*: cint
    reserved*: array[4, pointer]

  uv_tty_s* {.bycopy, impuvHdr, importc: "struct uv_tty_s".} = object
    data*: pointer           ## ```
                             ##   public
                             ## ```
    loop*: ptr uv_loop_t     ## ```
                             ##   read-only
                             ## ```
    `type`*: uv_handle_type_arg  ## ```
                             ##   private
                             ## ```
    close_cb*: uv_close_cb   ## ```
                             ##   private
                             ## ```
    handle_queue*: uvx_queue
    u*: Union_uvh5
    next_closing*: ptr uv_handle_t
    flags*: cuint            ## ```
                             ##   number of bytes queued for writing
                             ## ```
    write_queue_size*: uint  ## ```
                             ##   number of bytes queued for writing
                             ## ```
    alloc_cb*: uv_alloc_cb
    read_cb*: uv_read_cb     ## ```
                             ##   private
                             ## ```
    connect_req*: ptr uv_connect_t ## ```
                                   ##   private
                                   ## ```
    shutdown_req*: ptr uv_shutdown_t
    io_watcher*: uvx_io_t
    write_queue*: uvx_queue
    write_completed_queue*: uvx_queue
    connection_cb*: uv_connection_cb
    delayed_error*: cint
    accepted_fd*: cint
    queued_fds*: pointer     ## ```
                             ##   empty
                             ## ```
    mode*: cint

  Union_uvh6* {.union, bycopy, impuvHdr, importc: "union Union_uvh6".} = object
    fd*: cint
    reserved*: array[4, pointer]

  uv_pipe_s* {.bycopy, impuvHdr, importc: "struct uv_pipe_s".} = object
    data*: pointer           ## ```
                             ##   public
                             ## ```
    loop*: ptr uv_loop_t     ## ```
                             ##   read-only
                             ## ```
    `type`*: uv_handle_type_arg  ## ```
                             ##   private
                             ## ```
    close_cb*: uv_close_cb   ## ```
                             ##   private
                             ## ```
    handle_queue*: uvx_queue
    u*: Union_uvh6
    next_closing*: ptr uv_handle_t
    flags*: cuint            ## ```
                             ##   number of bytes queued for writing
                             ## ```
    write_queue_size*: uint  ## ```
                             ##   number of bytes queued for writing
                             ## ```
    alloc_cb*: uv_alloc_cb
    read_cb*: uv_read_cb     ## ```
                             ##   private
                             ## ```
    connect_req*: ptr uv_connect_t ## ```
                                   ##   private
                                   ## ```
    shutdown_req*: ptr uv_shutdown_t
    io_watcher*: uvx_io_t
    write_queue*: uvx_queue
    write_completed_queue*: uvx_queue
    connection_cb*: uv_connection_cb
    delayed_error*: cint
    accepted_fd*: cint
    queued_fds*: pointer     ## ```
                             ##   empty
                             ## ```
    ipc*: cint ## ```
               ##   non-zero if this pipe is used for passing handles
               ## ```
    pipe_fname*: cstring     ## ```
                             ##   NULL or strdup'ed
                             ## ```
  
  Union_uvh7* {.union, bycopy, impuvHdr, importc: "union Union_uvh7".} = object
    fd*: cint
    reserved*: array[4, pointer]

  uv_poll_s* {.bycopy, impuvHdr, importc: "struct uv_poll_s".} = object
    data*: pointer           ## ```
                             ##   public
                             ## ```
    loop*: ptr uv_loop_t     ## ```
                             ##   read-only
                             ## ```
    `type`*: uv_handle_type_arg  ## ```
                             ##   private
                             ## ```
    close_cb*: uv_close_cb   ## ```
                             ##   private
                             ## ```
    handle_queue*: uvx_queue
    u*: Union_uvh7
    next_closing*: ptr uv_handle_t
    flags*: cuint
    poll_cb*: uv_poll_cb
    io_watcher*: uvx_io_t

  Union_uvh8* {.union, bycopy, impuvHdr, importc: "union Union_uvh8".} = object
    fd*: cint
    reserved*: array[4, pointer]

  uv_prepare_s* {.bycopy, impuvHdr, importc: "struct uv_prepare_s".} = object
    data*: pointer           ## ```
                             ##   public
                             ## ```
    loop*: ptr uv_loop_t     ## ```
                             ##   read-only
                             ## ```
    `type`*: uv_handle_type_arg  ## ```
                             ##   private
                             ## ```
    close_cb*: uv_close_cb   ## ```
                             ##   private
                             ## ```
    handle_queue*: uvx_queue
    u*: Union_uvh8
    next_closing*: ptr uv_handle_t
    flags*: cuint
    prepare_cb*: uv_prepare_cb
    queue*: uvx_queue

  Union_uvh9* {.union, bycopy, impuvHdr, importc: "union Union_uvh9".} = object
    fd*: cint
    reserved*: array[4, pointer]

  uv_check_s* {.bycopy, impuvHdr, importc: "struct uv_check_s".} = object
    data*: pointer           ## ```
                             ##   public
                             ## ```
    loop*: ptr uv_loop_t     ## ```
                             ##   read-only
                             ## ```
    `type`*: uv_handle_type_arg  ## ```
                             ##   private
                             ## ```
    close_cb*: uv_close_cb   ## ```
                             ##   private
                             ## ```
    handle_queue*: uvx_queue
    u*: Union_uvh9
    next_closing*: ptr uv_handle_t
    flags*: cuint
    check_cb*: uv_check_cb
    queue*: uvx_queue

  Union_uvh10* {.union, bycopy, impuvHdr, importc: "union Union_uvh10".} = object
    fd*: cint
    reserved*: array[4, pointer]

  uv_idle_s* {.bycopy, impuvHdr, importc: "struct uv_idle_s".} = object
    data*: pointer           ## ```
                             ##   public
                             ## ```
    loop*: ptr uv_loop_t     ## ```
                             ##   read-only
                             ## ```
    `type`*: uv_handle_type_arg  ## ```
                             ##   private
                             ## ```
    close_cb*: uv_close_cb   ## ```
                             ##   private
                             ## ```
    handle_queue*: uvx_queue
    u*: Union_uvh10
    next_closing*: ptr uv_handle_t
    flags*: cuint
    idle_cb*: uv_idle_cb
    queue*: uvx_queue

  Union_uvh11* {.union, bycopy, impuvHdr, importc: "union Union_uvh11".} = object
    fd*: cint
    reserved*: array[4, pointer]

  uv_async_s* {.bycopy, impuvHdr, importc: "struct uv_async_s".} = object
    data*: pointer           ## ```
                             ##   public
                             ## ```
    loop*: ptr uv_loop_t     ## ```
                             ##   read-only
                             ## ```
    `type`*: uv_handle_type_arg  ## ```
                             ##   private
                             ## ```
    close_cb*: uv_close_cb   ## ```
                             ##   private
                             ## ```
    handle_queue*: uvx_queue
    u*: Union_uvh11
    next_closing*: ptr uv_handle_t
    flags*: cuint
    async_cb*: uv_async_cb
    queue*: uvx_queue
    pending*: cint

  Union_uvh12* {.union, bycopy, impuvHdr, importc: "union Union_uvh12".} = object
    fd*: cint
    reserved*: array[4, pointer]

  uv_timer_s* {.bycopy, impuvHdr, importc: "struct uv_timer_s".} = object
    data*: pointer           ## ```
                             ##   public
                             ## ```
    loop*: ptr uv_loop_t     ## ```
                             ##   read-only
                             ## ```
    `type`*: uv_handle_type_arg  ## ```
                             ##   private
                             ## ```
    close_cb*: uv_close_cb   ## ```
                             ##   private
                             ## ```
    handle_queue*: uvx_queue
    u*: Union_uvh12
    next_closing*: ptr uv_handle_t
    flags*: cuint
    timer_cb*: uv_timer_cb
    heap_node*: array[3, pointer]
    timeout*: uint64
    repeat*: uint64
    start_id*: uint64

  uv_getaddrinfo_s* {.bycopy, impuvHdr, importc: "struct uv_getaddrinfo_s".} = object
    data*: pointer           ## ```
                             ##   public
                             ## ```
    `type`*: uv_req_type_arg     ## ```
                             ##   read-only
                             ## ```
    reserved*: array[6, pointer] ## ```
                                 ##   private
                                 ## ```
    loop*: ptr uv_loop_t     ## ```
                             ##   empty 
                             ##      read-only
                             ## ```
    work_req*: uvx_work ## ```
                        ##   struct addrinfo* addrinfo is marked as private, but it really isn't.
                        ## ```
    cb*: uv_getaddrinfo_cb
    hints*: ptr AddrInfo
    hostname*: cstring
    service*: cstring
    addrinfo*: ptr AddrInfo
    retcode*: cint

  uv_getnameinfo_s* {.bycopy, impuvHdr, importc: "struct uv_getnameinfo_s".} = object
    data*: pointer           ## ```
                             ##   public
                             ## ```
    `type`*: uv_req_type_arg     ## ```
                             ##   read-only
                             ## ```
    reserved*: array[6, pointer] ## ```
                                 ##   private
                                 ## ```
    loop*: ptr uv_loop_t     ## ```
                             ##   empty 
                             ##      read-only
                             ## ```
    work_req*: uvx_work ## ```
                        ##   host and service are marked as private, but they really aren't.
                        ## ```
    getnameinfo_cb*: uv_getnameinfo_cb
    storage*: sockaddr_storage
    flags*: cint
    host*: array[1025, cchar]
    service*: array[32, cchar]
    retcode*: cint

  Union_uvh13* {.union, bycopy, impuvHdr, importc: "union Union_uvh13".} = object
    stream*: ptr uv_stream_t
    fd*: cint

  uv_stdio_container_s* {.bycopy, impuvHdr,
                          importc: "struct uv_stdio_container_s".} = object
    flags*: uv_stdio_flags
    data*: Union_uvh13

  uv_stdio_container_t* {.importc, impuvHdr.} = uv_stdio_container_s
  uv_process_options_s* {.bycopy, impuvHdr,
                          importc: "struct uv_process_options_s".} = object
    exit_cb*: uv_exit_cb     ## ```
                             ##   Called after the process exits.
                             ## ```
    file*: cstring ## ```
                   ##   Path to program to execute. 
                   ##     
                   ##      Command line arguments. args[0] should be the path to the program. On
                   ##      Windows this uses CreateProcess which concatenates the arguments into a
                   ##      string this can cause some strange errors. See the note at
                   ##      windows_verbatim_arguments.
                   ## ```
    args*: ptr cstring ## ```
                       ##   Path to program to execute. 
                       ##     
                       ##      Command line arguments. args[0] should be the path to the program. On
                       ##      Windows this uses CreateProcess which concatenates the arguments into a
                       ##      string this can cause some strange errors. See the note at
                       ##      windows_verbatim_arguments.
                       ## ```
    env*: ptr cstring ## ```
                      ##   This will be set as the environ variable in the subprocess. If this is
                      ##      NULL then the parents environ will be used.
                      ## ```
    cwd*: cstring ## ```
                  ##   If non-null this represents a directory the subprocess should execute
                  ##      in. Stands for current working directory.
                  ## ```
    flags*: cuint ## ```
                  ##   Various flags that control how uv_spawn() behaves. See the definition of
                  ##      enum uv_process_flags below.
                  ## ```
    stdio_count*: cint ## ```
                       ##   The stdio field points to an array of uv_stdio_container_t structs that
                       ##      describe the file descriptors that will be made available to the child
                       ##      process. The convention is that stdio[0] points to stdin, fd 1 is used for
                       ##      stdout, and fd 2 is stderr.
                       ##     
                       ##      Note that on windows file descriptors greater than 2 are available to the
                       ##      child process only if the child processes uses the MSVCRT runtime.
                       ## ```
    stdio*: ptr uv_stdio_container_t ## ```
                                     ##   Libuv can change the child process' user/group id. This happens only when
                                     ##      the appropriate bits are set in the flags fields. This is not supported on
                                     ##      windows; uv_spawn() will fail and set the error to UV_ENOTSUP.
                                     ## ```
    uid*: uv_uid_t ## ```
                   ##   Libuv can change the child process' user/group id. This happens only when
                   ##      the appropriate bits are set in the flags fields. This is not supported on
                   ##      windows; uv_spawn() will fail and set the error to UV_ENOTSUP.
                   ## ```
    gid*: uv_gid_t

  uv_process_options_t* {.importc, impuvHdr.} = uv_process_options_s
  Union_uvh14* {.union, bycopy, impuvHdr, importc: "union Union_uvh14".} = object
    fd*: cint
    reserved*: array[4, pointer]

  uv_process_s* {.bycopy, impuvHdr, importc: "struct uv_process_s".} = object
    data*: pointer           ## ```
                             ##   public
                             ## ```
    loop*: ptr uv_loop_t     ## ```
                             ##   read-only
                             ## ```
    `type`*: uv_handle_type_arg  ## ```
                             ##   private
                             ## ```
    close_cb*: uv_close_cb   ## ```
                             ##   private
                             ## ```
    handle_queue*: uvx_queue
    u*: Union_uvh14
    next_closing*: ptr uv_handle_t
    flags*: cuint
    exit_cb*: uv_exit_cb
    pid*: cint
    queue*: uvx_queue
    status*: cint

  uv_work_s* {.bycopy, impuvHdr, importc: "struct uv_work_s".} = object
    data*: pointer           ## ```
                             ##   public
                             ## ```
    `type`*: uv_req_type_arg     ## ```
                             ##   read-only
                             ## ```
    reserved*: array[6, pointer] ## ```
                                 ##   private
                                 ## ```
    loop*: ptr uv_loop_t     ## ```
                             ##   empty
                             ## ```
    work_cb*: uv_work_cb
    after_work_cb*: uv_after_work_cb
    work_req*: uvx_work

  uv_cpu_times_s* {.bycopy, impuvHdr, importc: "struct uv_cpu_times_s".} = object
    user*: uint64            ## ```
                             ##   milliseconds
                             ## ```
    nice*: uint64            ## ```
                             ##   milliseconds
                             ## ```
    sys*: uint64             ## ```
                             ##   milliseconds
                             ## ```
    idle*: uint64            ## ```
                             ##   milliseconds
                             ## ```
    irq*: uint64             ## ```
                             ##   milliseconds
                             ## ```
  
  uv_cpu_info_s* {.bycopy, impuvHdr, importc: "struct uv_cpu_info_s".} = object
    model*: cstring
    speed*: cint
    cpu_times*: uv_cpu_times_s

  Union_uvh15* {.union, bycopy, impuvHdr, importc: "union Union_uvh15".} = object
    address4*: sockaddr_in
    address6*: sockaddr_in6

  Union_uvh16* {.union, bycopy, impuvHdr, importc: "union Union_uvh16".} = object
    netmask4*: sockaddr_in
    netmask6*: sockaddr_in6

  uv_interface_address_s* {.bycopy, impuvHdr,
                            importc: "struct uv_interface_address_s".} = object
    name*: cstring
    phys_addr*: array[6, cchar]
    is_internal*: cint
    address*: Union_uvh15
    netmask*: Union_uvh16

  uv_passwd_s* {.bycopy, impuvHdr, importc: "struct uv_passwd_s".} = object
    username*: cstring
    uid*: culong
    gid*: culong
    shell*: cstring
    homedir*: cstring

  uv_group_s* {.bycopy, impuvHdr, importc: "struct uv_group_s".} = object
    groupname*: cstring
    gid*: culong
    members*: ptr cstring

  uv_utsname_s* {.bycopy, impuvHdr, importc: "struct uv_utsname_s".} = object
    sysname*: array[256, cchar]
    release*: array[256, cchar]
    version*: array[256, cchar]
    machine*: array[256, cchar] ## ```
                                ##   This struct does not contain the nodename and domainname fields present in
                                ##        the utsname type. domainname is a GNU extension. Both fields are referred
                                ##        to as meaningless in the docs.
                                ## ```
  
  uv_statfs_s* {.bycopy, impuvHdr, importc: "struct uv_statfs_s".} = object
    f_type*: uint64
    f_bsize*: uint64
    f_blocks*: uint64
    f_bfree*: uint64
    f_bavail*: uint64
    f_files*: uint64
    f_ffree*: uint64
    f_spare*: array[4, uint64]

  uv_dirent_s* {.bycopy, impuvHdr, importc: "struct uv_dirent_s".} = object
    name*: cstring
    `type`*: uv_dirent_type_t

  uv_rusage_t* {.bycopy, importc, impuvHdr.} = object
    ru_utime*: uv_timeval_t  ## ```
                             ##   user CPU time used
                             ## ```
    ru_stime*: uv_timeval_t  ## ```
                             ##   system CPU time used
                             ## ```
    ru_maxrss*: uint64       ## ```
                             ##   maximum resident set size
                             ## ```
    ru_ixrss*: uint64        ## ```
                             ##   integral shared memory size
                             ## ```
    ru_idrss*: uint64        ## ```
                             ##   integral unshared data size
                             ## ```
    ru_isrss*: uint64        ## ```
                             ##   integral unshared stack size
                             ## ```
    ru_minflt*: uint64       ## ```
                             ##   page reclaims (soft page faults)
                             ## ```
    ru_majflt*: uint64       ## ```
                             ##   page faults (hard page faults)
                             ## ```
    ru_nswap*: uint64        ## ```
                             ##   swaps
                             ## ```
    ru_inblock*: uint64      ## ```
                             ##   block input operations
                             ## ```
    ru_oublock*: uint64      ## ```
                             ##   block output operations
                             ## ```
    ru_msgsnd*: uint64       ## ```
                             ##   IPC messages sent
                             ## ```
    ru_msgrcv*: uint64       ## ```
                             ##   IPC messages received
                             ## ```
    ru_nsignals*: uint64     ## ```
                             ##   signals received
                             ## ```
    ru_nvcsw*: uint64        ## ```
                             ##   voluntary context switches
                             ## ```
    ru_nivcsw*: uint64       ## ```
                             ##   involuntary context switches
                             ## ```
  
  uv_env_item_s* {.bycopy, impuvHdr, importc: "struct uv_env_item_s".} = object
    name*: cstring
    value*: cstring

  uv_metrics_s* {.bycopy, impuvHdr, importc: "struct uv_metrics_s".} = object
    loop_count*: uint64
    events*: uint64
    events_waiting*: uint64  ## ```
                             ##   private
                             ## ```
    reserved*: array[13, ptr uint64] ## ```
                                     ##   private
                                     ## ```
  
  uv_dir_s* {.bycopy, impuvHdr, importc: "struct uv_dir_s".} = object
    dirents*: ptr uv_dirent_t
    nentries*: uint
    reserved*: array[4, pointer]
    dir*: ptr DIR

  uv_fs_s* {.bycopy, impuvHdr, importc: "struct uv_fs_s".} = object
    data*: pointer           ## ```
                             ##   public
                             ## ```
    `type`*: uv_req_type_arg     ## ```
                             ##   read-only
                             ## ```
    reserved*: array[6, pointer] ## ```
                                 ##   private
                                 ## ```
    fs_type*: uv_fs_type     ## ```
                             ##   empty
                             ## ```
    loop*: ptr uv_loop_t
    cb*: uv_fs_cb
    result*: int
    `ptr`*: pointer
    path*: cstring
    statbuf*: uv_stat_t ## ```
                        ##   Stores the result of uv_fs_stat() and uv_fs_fstat().
                        ## ```
    new_path*: cstring ## ```
                       ##   Stores the result of uv_fs_stat() and uv_fs_fstat().
                       ## ```
    file*: uv_file
    flags*: cint
    mode*: mode_t
    nbufs*: cuint
    bufs*: ptr uv_buf_t
    off*: clong
    uid*: uv_uid_t
    gid*: uv_gid_t
    atime*: cdouble
    mtime*: cdouble
    work_req*: uvx_work
    bufsml*: array[4, uv_buf_t]

  Union_uvh17* {.union, bycopy, impuvHdr, importc: "union Union_uvh17".} = object
    fd*: cint
    reserved*: array[4, pointer]

  uv_fs_event_s* {.bycopy, impuvHdr, importc: "struct uv_fs_event_s".} = object
    data*: pointer           ## ```
                             ##   public
                             ## ```
    loop*: ptr uv_loop_t     ## ```
                             ##   read-only
                             ## ```
    `type`*: uv_handle_type_arg  ## ```
                             ##   private
                             ## ```
    close_cb*: uv_close_cb   ## ```
                             ##   private
                             ## ```
    handle_queue*: uvx_queue
    u*: Union_uvh17
    next_closing*: ptr uv_handle_t
    flags*: cuint            ## ```
                             ##   private
                             ## ```
    path*: cstring           ## ```
                             ##   private
                             ## ```
    cb*: uv_fs_event_cb
    watchers*: uvx_queue
    wd*: cint

  Union_uvh18* {.union, bycopy, impuvHdr, importc: "union Union_uvh18".} = object
    fd*: cint
    reserved*: array[4, pointer]

  uv_fs_poll_s* {.bycopy, impuvHdr, importc: "struct uv_fs_poll_s".} = object
    data*: pointer           ## ```
                             ##   public
                             ## ```
    loop*: ptr uv_loop_t     ## ```
                             ##   read-only
                             ## ```
    `type`*: uv_handle_type_arg  ## ```
                             ##   private
                             ## ```
    close_cb*: uv_close_cb   ## ```
                             ##   private
                             ## ```
    handle_queue*: uvx_queue
    u*: Union_uvh18
    next_closing*: ptr uv_handle_t
    flags*: cuint            ## ```
                             ##   Private, don't touch.
                             ## ```
    poll_ctx*: pointer       ## ```
                             ##   Private, don't touch.
                             ## ```
  
  Union_uvh19* {.union, bycopy, impuvHdr, importc: "union Union_uvh19".} = object
    fd*: cint
    reserved*: array[4, pointer]

  Type_uvh1* {.bycopy, impuvHdr, importc: "struct Type_uvh1".} = object ## ```
                                                                         ##   RB_ENTRY(uv_signal_s) tree_entry;
                                                                         ## ```
    rbe_left*: ptr uv_signal_s
    rbe_right*: ptr uv_signal_s
    rbe_parent*: ptr uv_signal_s
    rbe_color*: cint

  uv_signal_s* {.bycopy, impuvHdr, importc: "struct uv_signal_s".} = object
    data*: pointer           ## ```
                             ##   public
                             ## ```
    loop*: ptr uv_loop_t     ## ```
                             ##   read-only
                             ## ```
    `type`*: uv_handle_type_arg  ## ```
                             ##   private
                             ## ```
    close_cb*: uv_close_cb   ## ```
                             ##   private
                             ## ```
    handle_queue*: uvx_queue
    u*: Union_uvh19
    next_closing*: ptr uv_handle_t
    flags*: cuint
    signal_cb*: uv_signal_cb
    signum*: cint            ## ```
                             ##   RB_ENTRY(uv_signal_s) tree_entry;
                             ## ```
    tree_entry*: Type_uvh1   ## ```
                             ##   RB_ENTRY(uv_signal_s) tree_entry;
                             ## ```
    caught_signals*: cuint ## ```
                           ##   Use two counters here so we don have to fiddle with atomics.
                           ## ```
    dispatched_signals*: cuint

  uv_random_s* {.bycopy, impuvHdr, importc: "struct uv_random_s".} = object
    data*: pointer           ## ```
                             ##   public
                             ## ```
    `type`*: uv_req_type_arg     ## ```
                             ##   read-only
                             ## ```
    reserved*: array[6, pointer] ## ```
                                 ##   private
                                 ## ```
    loop*: ptr uv_loop_t     ## ```
                             ##   empty 
                             ##      read-only
                             ## ```
    status*: cint            ## ```
                             ##   private
                             ## ```
    buf*: pointer
    buflen*: uint
    cb*: uv_random_cb
    work_req*: uvx_work

  uv_thread_cb* {.importc, impuvHdr.} = proc (arg: pointer) {.cdecl.}
  uv_thread_options_s* {.bycopy, impuvHdr, importc: "struct uv_thread_options_s".} = object
    flags*: cuint
    stack_size*: uint        ## ```
                             ##   More fields may be added at any time.
                             ## ```
  
  uv_thread_options_t* {.importc, impuvHdr.} = uv_thread_options_s
  uv_any_handle* {.union, bycopy, impuvHdr, importc: "union uv_any_handle".} = object
    async*: uv_async_t
    check*: uv_check_t
    fs_event*: uv_fs_event_t
    fs_poll*: uv_fs_poll_t
    handle*: uv_handle_t
    idle*: uv_idle_t
    pipe*: uv_pipe_t
    poll*: uv_poll_t
    prepare*: uv_prepare_t
    process*: uv_process_t
    stream*: uv_stream_t
    tcp*: uv_tcp_t
    timer*: uv_timer_t
    tty*: uv_tty_t
    udp*: uv_udp_t
    signal*: uv_signal_t

  uv_any_req* {.union, bycopy, impuvHdr, importc: "union uv_any_req".} = object
    req*: uv_req_t
    connect*: uv_connect_t
    write*: uv_write_t
    shutdown*: uv_shutdown_t
    udp_send*: uv_udp_send_t
    fs*: uv_fs_t
    work*: uv_work_t
    getaddrinfo*: uv_getaddrinfo_t
    getnameinfo*: uv_getnameinfo_t
    random*: uv_random_t

  Union_uvh20* {.union, bycopy, impuvHdr, importc: "union Union_uvh20".} = object
    unused*: pointer
    count*: cuint

  Type_uvh2* {.bycopy, impuvHdr, importc: "struct Type_uvh2".} = object
    min*: pointer
    nelts*: cuint

  uv_loop_s* {.bycopy, impuvHdr, importc: "struct uv_loop_s".} = object
    data*: pointer           ## ```
                             ##   User data - use this for whatever.
                             ## ```
    active_handles*: cuint   ## ```
                             ##   Loop reference counting.
                             ## ```
    handle_queue*: uvx_queue
    active_reqs*: Union_uvh20
    internal_fields*: pointer ## ```
                              ##   Internal storage for future extensions.
                              ## ```
    stop_flag*: cuint        ## ```
                             ##   Internal flag to signal loop stop.
                             ## ```
    flags*: culong
    backend_fd*: cint
    pending_queue*: uvx_queue
    watcher_queue*: uvx_queue
    watchers*: ptr ptr uvx_io_t
    nwatchers*: cuint
    nfds*: cuint
    wq*: uvx_queue
    wq_mutex*: uv_mutex_t
    wq_async*: uv_async_t
    cloexec_lock*: uv_rwlock_t
    closing_handles*: ptr uv_handle_t
    process_handles*: uvx_queue
    prepare_handles*: uvx_queue
    check_handles*: uvx_queue
    idle_handles*: uvx_queue
    async_handles*: uvx_queue
    async_unused*: proc () {.cdecl.} ## ```
                                     ##   TODO(bnoordhuis) Remove in libuv v2.
                                     ## ```
    async_io_watcher*: uvx_io_t ## ```
                                ##   TODO(bnoordhuis) Remove in libuv v2.
                                ## ```
    async_wfd*: cint
    timer_heap*: Type_uvh2
    timer_counter*: uint64
    time*: uint64
    signal_pipefd*: array[2, cint]
    signal_io_watcher*: uvx_io_t
    child_watcher*: uv_signal_t
    emfile_fd*: cint
    inotify_read_watcher*: uvx_io_t
    inotify_watchers*: pointer
    inotify_fd*: cint

proc uv_version*(): cuint {.importc, cdecl, impuvHdr.}
proc uv_version_string*(): cstring {.importc, cdecl, impuvHdr.}
proc uv_library_shutdown*() {.importc, cdecl, impuvHdr.}
proc uv_replace_allocator*(malloc_func: uv_malloc_func;
                           realloc_func: uv_realloc_func;
                           calloc_func: uv_calloc_func; free_func: uv_free_func): cint {.
    importc, cdecl, impuvHdr.}
proc uv_default_loop*(): ptr uv_loop_t {.importc, cdecl, impuvHdr.}
proc uv_loop_init*(loop: ptr uv_loop_t): cint {.importc, cdecl, impuvHdr.}
proc uv_loop_close*(loop: ptr uv_loop_t): cint {.importc, cdecl, impuvHdr.}
  ## ```
                                                                           ##   NOTE:
                                                                           ##     This function is DEPRECATED, users should
                                                                           ##     allocate the loop manually and use uv_loop_init instead.
                                                                           ## ```
proc uv_loop_new*(): ptr uv_loop_t {.importc, cdecl, impuvHdr.}
  ## ```
                                                               ##   NOTE:
                                                               ##     This function is DEPRECATED, users should
                                                               ##     allocate the loop manually and use uv_loop_init instead.
                                                               ## ```
proc uv_loop_delete*(a1: ptr uv_loop_t) {.importc, cdecl, impuvHdr.}
  ## ```
                                                                    ##   NOTE:
                                                                    ##     This function is DEPRECATED. Users should use
                                                                    ##     uv_loop_close and free the memory manually instead.
                                                                    ## ```
proc uv_loop_size*(): uint {.importc, cdecl, impuvHdr.}
proc uv_loop_alive*(loop: ptr uv_loop_t): cint {.importc, cdecl, impuvHdr.}
proc uv_loop_configure*(loop: ptr uv_loop_t; option: uv_loop_option): cint {.
    importc, cdecl, impuvHdr, varargs.}
proc uv_loop_fork*(loop: ptr uv_loop_t): cint {.importc, cdecl, impuvHdr.}
proc uv_run*(a1: ptr uv_loop_t; mode: uv_run_mode): cint {.importc, cdecl,
    impuvHdr.}
proc uv_stop*(a1: ptr uv_loop_t) {.importc, cdecl, impuvHdr.}
proc uv_ref*(a1: ptr uv_handle_t) {.importc, cdecl, impuvHdr.}
proc uv_unref*(a1: ptr uv_handle_t) {.importc, cdecl, impuvHdr.}
proc uv_has_ref*(a1: ptr uv_handle_t): cint {.importc, cdecl, impuvHdr.}
proc uv_update_time*(a1: ptr uv_loop_t) {.importc, cdecl, impuvHdr.}
proc uv_now*(a1: ptr uv_loop_t): uint64 {.importc, cdecl, impuvHdr.}
proc uv_backend_fd*(a1: ptr uv_loop_t): cint {.importc, cdecl, impuvHdr.}
proc uv_backend_timeout*(a1: ptr uv_loop_t): cint {.importc, cdecl, impuvHdr.}
proc uv_translate_sys_error*(sys_errno: cint): cint {.importc, cdecl, impuvHdr.}
proc uv_strerror*(err: cint): cstring {.importc, cdecl, impuvHdr.}
proc uv_strerror_r*(err: cint; buf: cstring; buflen: uint): cstring {.importc,
    cdecl, impuvHdr.}
proc uv_err_name*(err: cint): cstring {.importc, cdecl, impuvHdr.}
proc uv_err_name_r*(err: cint; buf: cstring; buflen: uint): cstring {.importc,
    cdecl, impuvHdr.}
proc uv_shutdown*(req: ptr uv_shutdown_t; handle: ptr uv_stream_t;
                  cb: uv_shutdown_cb): cint {.importc, cdecl, impuvHdr.}
proc uv_handle_size*(`type`: uv_handle_type_arg): uint {.importc, cdecl, impuvHdr.}
proc uv_handle_get_type*(handle: ptr uv_handle_t): uv_handle_type_arg {.importc,
    cdecl, impuvHdr.}
proc uv_handle_type_name*(`type`: uv_handle_type_arg): cstring {.importc, cdecl,
    impuvHdr.}
proc uv_handle_get_data*(handle: ptr uv_handle_t): pointer {.importc, cdecl,
    impuvHdr.}
proc uv_handle_get_loop*(handle: ptr uv_handle_t): ptr uv_loop_t {.importc,
    cdecl, impuvHdr.}
proc uv_handle_set_data*(handle: ptr uv_handle_t; data: pointer) {.importc,
    cdecl, impuvHdr.}
proc uv_req_size*(`type`: uv_req_type_arg): uint {.importc, cdecl, impuvHdr.}
proc uv_req_get_data*(req: ptr uv_req_t): pointer {.importc, cdecl, impuvHdr.}
proc uv_req_set_data*(req: ptr uv_req_t; data: pointer) {.importc, cdecl,
    impuvHdr.}
proc uv_req_get_type*(req: ptr uv_req_t): uv_req_type_arg {.importc, cdecl, impuvHdr.}
proc uv_req_type_name*(`type`: uv_req_type_arg): cstring {.importc, cdecl, impuvHdr.}
proc uv_is_active*(handle: ptr uv_handle_t): cint {.importc, cdecl, impuvHdr.}
proc uv_walk*(loop: ptr uv_loop_t; walk_cb: uv_walk_cb; arg: pointer) {.importc,
    cdecl, impuvHdr.}
proc uv_print_all_handles*(loop: ptr uv_loop_t; stream: File) {.importc, cdecl,
    impuvHdr.}
  ## ```
              ##   Helpers for ad hoc debugging, no API/ABI stability guaranteed.
              ## ```
proc uv_print_active_handles*(loop: ptr uv_loop_t; stream: File) {.importc,
    cdecl, impuvHdr.}
proc uv_close*(handle: ptr uv_handle_t; close_cb: uv_close_cb) {.importc, cdecl,
    impuvHdr.}
proc uv_send_buffer_size*(handle: ptr uv_handle_t; value: ptr cint): cint {.
    importc, cdecl, impuvHdr.}
proc uv_recv_buffer_size*(handle: ptr uv_handle_t; value: ptr cint): cint {.
    importc, cdecl, impuvHdr.}
proc uv_fileno*(handle: ptr uv_handle_t; fd: ptr uv_os_fd_t): cint {.importc,
    cdecl, impuvHdr.}
proc uv_buf_init*(base: cstring; len: cuint): uv_buf_t {.importc, cdecl,
    impuvHdr.}
proc uv_pipe*(fds: array[2, uv_file]; read_flags: cint; write_flags: cint): cint {.
    importc, cdecl, impuvHdr.}
proc uv_socketpair*(`type`: cint; protocol: cint;
                    socket_vector: array[2, uv_os_sock_t]; flags0: cint;
                    flags1: cint): cint {.importc, cdecl, impuvHdr.}
proc uv_stream_get_write_queue_size*(stream: ptr uv_stream_t): uint {.importc,
    cdecl, impuvHdr.}
proc uv_listen*(stream: ptr uv_stream_t; backlog: cint; cb: uv_connection_cb): cint {.
    importc, cdecl, impuvHdr.}
proc uv_accept*(server: ptr uv_stream_t; client: ptr uv_stream_t): cint {.
    importc, cdecl, impuvHdr.}
proc uv_read_start*(a1: ptr uv_stream_t; alloc_cb: uv_alloc_cb;
                    read_cb: uv_read_cb): cint {.importc, cdecl, impuvHdr.}
proc uv_read_stop*(a1: ptr uv_stream_t): cint {.importc, cdecl, impuvHdr.}
proc uv_write*(req: ptr uv_write_t; handle: ptr uv_stream_t;
               bufs: UncheckedArray[uv_buf_t]; nbufs: cuint; cb: uv_write_cb): cint {.
    importc, cdecl, impuvHdr.}
proc uv_write2*(req: ptr uv_write_t; handle: ptr uv_stream_t;
                bufs: UncheckedArray[uv_buf_t]; nbufs: cuint;
                send_handle: ptr uv_stream_t; cb: uv_write_cb): cint {.importc,
    cdecl, impuvHdr.}
proc uv_try_write*(handle: ptr uv_stream_t; bufs: UncheckedArray[uv_buf_t];
                   nbufs: cuint): cint {.importc, cdecl, impuvHdr.}
proc uv_try_write2*(handle: ptr uv_stream_t; bufs: UncheckedArray[uv_buf_t];
                    nbufs: cuint; send_handle: ptr uv_stream_t): cint {.importc,
    cdecl, impuvHdr.}
proc uv_is_readable*(handle: ptr uv_stream_t): cint {.importc, cdecl, impuvHdr.}
proc uv_is_writable*(handle: ptr uv_stream_t): cint {.importc, cdecl, impuvHdr.}
proc uv_stream_set_blocking*(handle: ptr uv_stream_t; blocking: cint): cint {.
    importc, cdecl, impuvHdr.}
proc uv_is_closing*(handle: ptr uv_handle_t): cint {.importc, cdecl, impuvHdr.}
proc uv_tcp_init*(a1: ptr uv_loop_t; handle: ptr uv_tcp_t): cint {.importc,
    cdecl, impuvHdr.}
proc uv_tcp_init_ex*(a1: ptr uv_loop_t; handle: ptr uv_tcp_t; flags: cuint): cint {.
    importc, cdecl, impuvHdr.}
proc uv_tcp_open*(handle: ptr uv_tcp_t; sock: uv_os_sock_t): cint {.importc,
    cdecl, impuvHdr.}
proc uv_tcp_nodelay*(handle: ptr uv_tcp_t; enable: cint): cint {.importc, cdecl,
    impuvHdr.}
proc uv_tcp_keepalive*(handle: ptr uv_tcp_t; enable: cint; delay: cuint): cint {.
    importc, cdecl, impuvHdr.}
proc uv_tcp_simultaneous_accepts*(handle: ptr uv_tcp_t; enable: cint): cint {.
    importc, cdecl, impuvHdr.}
proc uv_tcp_bind*(handle: ptr uv_tcp_t; `addr`: ptr SockAddr; flags: cuint): cint {.
    importc, cdecl, impuvHdr.}
proc uv_tcp_getsockname*(handle: ptr uv_tcp_t; name: ptr SockAddr;
                         namelen: ptr cint): cint {.importc, cdecl, impuvHdr.}
proc uv_tcp_getpeername*(handle: ptr uv_tcp_t; name: ptr SockAddr;
                         namelen: ptr cint): cint {.importc, cdecl, impuvHdr.}
proc uv_tcp_close_reset*(handle: ptr uv_tcp_t; close_cb: uv_close_cb): cint {.
    importc, cdecl, impuvHdr.}
proc uv_tcp_connect*(req: ptr uv_connect_t; handle: ptr uv_tcp_t;
                     `addr`: ptr SockAddr; cb: uv_connect_cb): cint {.importc,
    cdecl, impuvHdr.}
proc uv_udp_init*(a1: ptr uv_loop_t; handle: ptr uv_udp_t): cint {.importc,
    cdecl, impuvHdr.}
proc uv_udp_init_ex*(a1: ptr uv_loop_t; handle: ptr uv_udp_t; flags: cuint): cint {.
    importc, cdecl, impuvHdr.}
proc uv_udp_open*(handle: ptr uv_udp_t; sock: uv_os_sock_t): cint {.importc,
    cdecl, impuvHdr.}
proc uv_udp_bind*(handle: ptr uv_udp_t; `addr`: ptr SockAddr; flags: cuint): cint {.
    importc, cdecl, impuvHdr.}
proc uv_udp_connect*(handle: ptr uv_udp_t; `addr`: ptr SockAddr): cint {.
    importc, cdecl, impuvHdr.}
proc uv_udp_getpeername*(handle: ptr uv_udp_t; name: ptr SockAddr;
                         namelen: ptr cint): cint {.importc, cdecl, impuvHdr.}
proc uv_udp_getsockname*(handle: ptr uv_udp_t; name: ptr SockAddr;
                         namelen: ptr cint): cint {.importc, cdecl, impuvHdr.}
proc uv_udp_set_membership*(handle: ptr uv_udp_t; multicast_addr: cstring;
                            interface_addr: cstring; membership: uv_membership): cint {.
    importc, cdecl, impuvHdr.}
proc uv_udp_set_source_membership*(handle: ptr uv_udp_t;
                                   multicast_addr: cstring;
                                   interface_addr: cstring;
                                   source_addr: cstring;
                                   membership: uv_membership): cint {.importc,
    cdecl, impuvHdr.}
proc uv_udp_set_multicast_loop*(handle: ptr uv_udp_t; on: cint): cint {.importc,
    cdecl, impuvHdr.}
proc uv_udp_set_multicast_ttl*(handle: ptr uv_udp_t; ttl: cint): cint {.importc,
    cdecl, impuvHdr.}
proc uv_udp_set_multicast_interface*(handle: ptr uv_udp_t;
                                     interface_addr: cstring): cint {.importc,
    cdecl, impuvHdr.}
proc uv_udp_set_broadcast*(handle: ptr uv_udp_t; on: cint): cint {.importc,
    cdecl, impuvHdr.}
proc uv_udp_set_ttl*(handle: ptr uv_udp_t; ttl: cint): cint {.importc, cdecl,
    impuvHdr.}
proc uv_udp_send*(req: ptr uv_udp_send_t; handle: ptr uv_udp_t;
                  bufs: UncheckedArray[uv_buf_t]; nbufs: cuint;
                  `addr`: ptr SockAddr; send_cb: uv_udp_send_cb): cint {.
    importc, cdecl, impuvHdr.}
proc uv_udp_try_send*(handle: ptr uv_udp_t; bufs: UncheckedArray[uv_buf_t];
                      nbufs: cuint; `addr`: ptr SockAddr): cint {.importc,
    cdecl, impuvHdr.}
proc uv_udp_recv_start*(handle: ptr uv_udp_t; alloc_cb: uv_alloc_cb;
                        recv_cb: uv_udp_recv_cb): cint {.importc, cdecl,
    impuvHdr.}
proc uv_udp_using_recvmmsg*(handle: ptr uv_udp_t): cint {.importc, cdecl,
    impuvHdr.}
proc uv_udp_recv_stop*(handle: ptr uv_udp_t): cint {.importc, cdecl, impuvHdr.}
proc uv_udp_get_send_queue_size*(handle: ptr uv_udp_t): uint {.importc, cdecl,
    impuvHdr.}
proc uv_udp_get_send_queue_count*(handle: ptr uv_udp_t): uint {.importc, cdecl,
    impuvHdr.}
proc uv_tty_init*(a1: ptr uv_loop_t; a2: ptr uv_tty_t; fd: uv_file;
                  readable: cint): cint {.importc, cdecl, impuvHdr.}
proc uv_tty_set_mode*(a1: ptr uv_tty_t; mode: uv_tty_mode_t): cint {.importc,
    cdecl, impuvHdr.}
proc uv_tty_reset_mode*(): cint {.importc, cdecl, impuvHdr.}
proc uv_tty_get_winsize*(a1: ptr uv_tty_t; width: ptr cint; height: ptr cint): cint {.
    importc, cdecl, impuvHdr.}
proc uv_tty_set_vterm_state*(state: uv_tty_vtermstate_t) {.importc, cdecl,
    impuvHdr.}
proc uv_tty_get_vterm_state*(state: ptr uv_tty_vtermstate_t): cint {.importc,
    cdecl, impuvHdr.}
proc uv_guess_handle*(file: uv_file): uv_handle_type_arg {.importc, cdecl, impuvHdr.}
proc uv_pipe_init*(a1: ptr uv_loop_t; handle: ptr uv_pipe_t; ipc: cint): cint {.
    importc, cdecl, impuvHdr.}
proc uv_pipe_open*(a1: ptr uv_pipe_t; file: uv_file): cint {.importc, cdecl,
    impuvHdr.}
proc uv_pipe_bind*(handle: ptr uv_pipe_t; name: cstring): cint {.importc, cdecl,
    impuvHdr.}
proc uv_pipe_bind2*(handle: ptr uv_pipe_t; name: cstring; namelen: uint;
                    flags: cuint): cint {.importc, cdecl, impuvHdr.}
proc uv_pipe_connect*(req: ptr uv_connect_t; handle: ptr uv_pipe_t;
                      name: cstring; cb: uv_connect_cb) {.importc, cdecl,
    impuvHdr.}
proc uv_pipe_connect2*(req: ptr uv_connect_t; handle: ptr uv_pipe_t;
                       name: cstring; namelen: uint; flags: cuint;
                       cb: uv_connect_cb): cint {.importc, cdecl, impuvHdr.}
proc uv_pipe_getsockname*(handle: ptr uv_pipe_t; buffer: cstring; size: ptr uint): cint {.
    importc, cdecl, impuvHdr.}
proc uv_pipe_getpeername*(handle: ptr uv_pipe_t; buffer: cstring; size: ptr uint): cint {.
    importc, cdecl, impuvHdr.}
proc uv_pipe_pending_instances*(handle: ptr uv_pipe_t; count: cint) {.importc,
    cdecl, impuvHdr.}
proc uv_pipe_pending_count*(handle: ptr uv_pipe_t): cint {.importc, cdecl,
    impuvHdr.}
proc uv_pipe_pending_type*(handle: ptr uv_pipe_t): uv_handle_type_arg {.importc,
    cdecl, impuvHdr.}
proc uv_pipe_chmod*(handle: ptr uv_pipe_t; flags: cint): cint {.importc, cdecl,
    impuvHdr.}
proc uv_poll_init*(loop: ptr uv_loop_t; handle: ptr uv_poll_t; fd: cint): cint {.
    importc, cdecl, impuvHdr.}
proc uv_poll_init_socket*(loop: ptr uv_loop_t; handle: ptr uv_poll_t;
                          socket: uv_os_sock_t): cint {.importc, cdecl, impuvHdr.}
proc uv_poll_start*(handle: ptr uv_poll_t; events: cint; cb: uv_poll_cb): cint {.
    importc, cdecl, impuvHdr.}
proc uv_poll_stop*(handle: ptr uv_poll_t): cint {.importc, cdecl, impuvHdr.}
proc uv_prepare_init*(a1: ptr uv_loop_t; prepare: ptr uv_prepare_t): cint {.
    importc, cdecl, impuvHdr.}
proc uv_prepare_start*(prepare: ptr uv_prepare_t; cb: uv_prepare_cb): cint {.
    importc, cdecl, impuvHdr.}
proc uv_prepare_stop*(prepare: ptr uv_prepare_t): cint {.importc, cdecl,
    impuvHdr.}
proc uv_check_init*(a1: ptr uv_loop_t; check: ptr uv_check_t): cint {.importc,
    cdecl, impuvHdr.}
proc uv_check_start*(check: ptr uv_check_t; cb: uv_check_cb): cint {.importc,
    cdecl, impuvHdr.}
proc uv_check_stop*(check: ptr uv_check_t): cint {.importc, cdecl, impuvHdr.}
proc uv_idle_init*(a1: ptr uv_loop_t; idle: ptr uv_idle_t): cint {.importc,
    cdecl, impuvHdr.}
proc uv_idle_start*(idle: ptr uv_idle_t; cb: uv_idle_cb): cint {.importc, cdecl,
    impuvHdr.}
proc uv_idle_stop*(idle: ptr uv_idle_t): cint {.importc, cdecl, impuvHdr.}
proc uv_async_init*(a1: ptr uv_loop_t; async: ptr uv_async_t;
                    async_cb: uv_async_cb): cint {.importc, cdecl, impuvHdr.}
proc uv_async_send*(async: ptr uv_async_t): cint {.importc, cdecl, impuvHdr.}
proc uv_timer_init*(a1: ptr uv_loop_t; handle: ptr uv_timer_t): cint {.importc,
    cdecl, impuvHdr.}
proc uv_timer_start*(handle: ptr uv_timer_t; cb: uv_timer_cb; timeout: uint64;
                     repeat: uint64): cint {.importc, cdecl, impuvHdr.}
proc uv_timer_stop*(handle: ptr uv_timer_t): cint {.importc, cdecl, impuvHdr.}
proc uv_timer_again*(handle: ptr uv_timer_t): cint {.importc, cdecl, impuvHdr.}
proc uv_timer_set_repeat*(handle: ptr uv_timer_t; repeat: uint64) {.importc,
    cdecl, impuvHdr.}
proc uv_timer_get_repeat*(handle: ptr uv_timer_t): uint64 {.importc, cdecl,
    impuvHdr.}
proc uv_timer_get_due_in*(handle: ptr uv_timer_t): uint64 {.importc, cdecl,
    impuvHdr.}
proc uv_getaddrinfo*(loop: ptr uv_loop_t; req: ptr uv_getaddrinfo_t;
                     getaddrinfo_cb: uv_getaddrinfo_cb; node: cstring;
                     service: cstring; hints: ptr AddrInfo): cint {.importc,
    cdecl, impuvHdr.}
proc uv_freeaddrinfo*(ai: ptr AddrInfo) {.importc, cdecl, impuvHdr.}
proc uv_getnameinfo*(loop: ptr uv_loop_t; req: ptr uv_getnameinfo_t;
                     getnameinfo_cb: uv_getnameinfo_cb; `addr`: ptr SockAddr;
                     flags: cint): cint {.importc, cdecl, impuvHdr.}
proc uv_spawn*(loop: ptr uv_loop_t; handle: ptr uv_process_t;
               options: ptr uv_process_options_t): cint {.importc, cdecl,
    impuvHdr.}
proc uv_process_kill*(a1: ptr uv_process_t; signum: cint): cint {.importc,
    cdecl, impuvHdr.}
proc uv_kill*(pid: cint; signum: cint): cint {.importc, cdecl, impuvHdr.}
proc uv_process_get_pid*(a1: ptr uv_process_t): uv_pid_t {.importc, cdecl,
    impuvHdr.}
proc uv_queue_work*(loop: ptr uv_loop_t; req: ptr uv_work_t;
                    work_cb: uv_work_cb; after_work_cb: uv_after_work_cb): cint {.
    importc, cdecl, impuvHdr.}
proc uv_cancel*(req: ptr uv_req_t): cint {.importc, cdecl, impuvHdr.}
proc uv_setup_args*(argc: cint; argv: ptr cstring): ptr cstring {.importc,
    cdecl, impuvHdr.}
proc uv_get_process_title*(buffer: cstring; size: uint): cint {.importc, cdecl,
    impuvHdr.}
proc uv_set_process_title*(title: cstring): cint {.importc, cdecl, impuvHdr.}
proc uv_resident_set_memory*(rss: ptr uint): cint {.importc, cdecl, impuvHdr.}
proc uv_uptime*(uptime: ptr cdouble): cint {.importc, cdecl, impuvHdr.}
proc uv_get_osfhandle*(fd: cint): uv_os_fd_t {.importc, cdecl, impuvHdr.}
proc uv_open_osfhandle*(os_fd: uv_os_fd_t): cint {.importc, cdecl, impuvHdr.}
proc uv_getrusage*(rusage: ptr uv_rusage_t): cint {.importc, cdecl, impuvHdr.}
proc uv_os_homedir*(buffer: cstring; size: ptr uint): cint {.importc, cdecl,
    impuvHdr.}
proc uv_os_tmpdir*(buffer: cstring; size: ptr uint): cint {.importc, cdecl,
    impuvHdr.}
proc uv_os_get_passwd*(pwd: ptr uv_passwd_t): cint {.importc, cdecl, impuvHdr.}
proc uv_os_free_passwd*(pwd: ptr uv_passwd_t) {.importc, cdecl, impuvHdr.}
proc uv_os_get_passwd2*(pwd: ptr uv_passwd_t; uid: uv_uid_t): cint {.importc,
    cdecl, impuvHdr.}
proc uv_os_get_group*(grp: ptr uv_group_t; gid: uv_uid_t): cint {.importc,
    cdecl, impuvHdr.}
proc uv_os_free_group*(grp: ptr uv_group_t) {.importc, cdecl, impuvHdr.}
proc uv_os_getpid*(): uv_pid_t {.importc, cdecl, impuvHdr.}
proc uv_os_getppid*(): uv_pid_t {.importc, cdecl, impuvHdr.}
proc uv_os_getpriority*(pid: uv_pid_t; priority: ptr cint): cint {.importc,
    cdecl, impuvHdr.}
proc uv_os_setpriority*(pid: uv_pid_t; priority: cint): cint {.importc, cdecl,
    impuvHdr.}
proc uv_available_parallelism*(): cuint {.importc, cdecl, impuvHdr.}
proc uv_cpu_info*(cpu_infos: ptr ptr uv_cpu_info_t; count: ptr cint): cint {.
    importc, cdecl, impuvHdr.}
proc uv_free_cpu_info*(cpu_infos: ptr uv_cpu_info_t; count: cint) {.importc,
    cdecl, impuvHdr.}
proc uv_cpumask_size*(): cint {.importc, cdecl, impuvHdr.}
proc uv_interface_addresses*(addresses: ptr ptr uv_interface_address_t;
                             count: ptr cint): cint {.importc, cdecl, impuvHdr.}
proc uv_free_interface_addresses*(addresses: ptr uv_interface_address_t;
                                  count: cint) {.importc, cdecl, impuvHdr.}
proc uv_os_environ*(envitems: ptr ptr uv_env_item_t; count: ptr cint): cint {.
    importc, cdecl, impuvHdr.}
proc uv_os_free_environ*(envitems: ptr uv_env_item_t; count: cint) {.importc,
    cdecl, impuvHdr.}
proc uv_os_getenv*(name: cstring; buffer: cstring; size: ptr uint): cint {.
    importc, cdecl, impuvHdr.}
proc uv_os_setenv*(name: cstring; value: cstring): cint {.importc, cdecl,
    impuvHdr.}
proc uv_os_unsetenv*(name: cstring): cint {.importc, cdecl, impuvHdr.}
proc uv_os_gethostname*(buffer: cstring; size: ptr uint): cint {.importc, cdecl,
    impuvHdr.}
proc uv_os_uname*(buffer: ptr uv_utsname_t): cint {.importc, cdecl, impuvHdr.}
proc uv_metrics_info*(loop: ptr uv_loop_t; metrics: ptr uv_metrics_t): cint {.
    importc, cdecl, impuvHdr.}
proc uv_metrics_idle_time*(loop: ptr uv_loop_t): uint64 {.importc, cdecl,
    impuvHdr.}
proc uv_fs_get_type*(a1: ptr uv_fs_t): uv_fs_type {.importc, cdecl, impuvHdr.}
proc uv_fs_get_result*(a1: ptr uv_fs_t): int {.importc, cdecl, impuvHdr.}
proc uv_fs_get_system_error*(a1: ptr uv_fs_t): cint {.importc, cdecl, impuvHdr.}
proc uv_fs_get_ptr*(a1: ptr uv_fs_t): pointer {.importc, cdecl, impuvHdr.}
proc uv_fs_get_path*(a1: ptr uv_fs_t): cstring {.importc, cdecl, impuvHdr.}
proc uv_fs_get_statbuf*(a1: ptr uv_fs_t): ptr uv_stat_t {.importc, cdecl,
    impuvHdr.}
proc uv_fs_req_cleanup*(req: ptr uv_fs_t) {.importc, cdecl, impuvHdr.}
proc uv_fs_close*(loop: ptr uv_loop_t; req: ptr uv_fs_t; file: uv_file;
                  cb: uv_fs_cb): cint {.importc, cdecl, impuvHdr.}
proc uv_fs_open*(loop: ptr uv_loop_t; req: ptr uv_fs_t; path: cstring;
                 flags: cint; mode: cint; cb: uv_fs_cb): cint {.importc, cdecl,
    impuvHdr.}
proc uv_fs_read*(loop: ptr uv_loop_t; req: ptr uv_fs_t; file: uv_file;
                 bufs: UncheckedArray[uv_buf_t]; nbufs: cuint; offset: int64;
                 cb: uv_fs_cb): cint {.importc, cdecl, impuvHdr.}
proc uv_fs_unlink*(loop: ptr uv_loop_t; req: ptr uv_fs_t; path: cstring;
                   cb: uv_fs_cb): cint {.importc, cdecl, impuvHdr.}
proc uv_fs_write*(loop: ptr uv_loop_t; req: ptr uv_fs_t; file: uv_file;
                  bufs: UncheckedArray[uv_buf_t]; nbufs: cuint; offset: int64;
                  cb: uv_fs_cb): cint {.importc, cdecl, impuvHdr.}
proc uv_fs_copyfile*(loop: ptr uv_loop_t; req: ptr uv_fs_t; path: cstring;
                     new_path: cstring; flags: cint; cb: uv_fs_cb): cint {.
    importc, cdecl, impuvHdr.}
proc uv_fs_mkdir*(loop: ptr uv_loop_t; req: ptr uv_fs_t; path: cstring;
                  mode: cint; cb: uv_fs_cb): cint {.importc, cdecl, impuvHdr.}
proc uv_fs_mkdtemp*(loop: ptr uv_loop_t; req: ptr uv_fs_t; tpl: cstring;
                    cb: uv_fs_cb): cint {.importc, cdecl, impuvHdr.}
proc uv_fs_mkstemp*(loop: ptr uv_loop_t; req: ptr uv_fs_t; tpl: cstring;
                    cb: uv_fs_cb): cint {.importc, cdecl, impuvHdr.}
proc uv_fs_rmdir*(loop: ptr uv_loop_t; req: ptr uv_fs_t; path: cstring;
                  cb: uv_fs_cb): cint {.importc, cdecl, impuvHdr.}
proc uv_fs_scandir*(loop: ptr uv_loop_t; req: ptr uv_fs_t; path: cstring;
                    flags: cint; cb: uv_fs_cb): cint {.importc, cdecl, impuvHdr.}
proc uv_fs_scandir_next*(req: ptr uv_fs_t; ent: ptr uv_dirent_t): cint {.
    importc, cdecl, impuvHdr.}
proc uv_fs_opendir*(loop: ptr uv_loop_t; req: ptr uv_fs_t; path: cstring;
                    cb: uv_fs_cb): cint {.importc, cdecl, impuvHdr.}
proc uv_fs_readdir*(loop: ptr uv_loop_t; req: ptr uv_fs_t; dir: ptr uv_dir_t;
                    cb: uv_fs_cb): cint {.importc, cdecl, impuvHdr.}
proc uv_fs_closedir*(loop: ptr uv_loop_t; req: ptr uv_fs_t; dir: ptr uv_dir_t;
                     cb: uv_fs_cb): cint {.importc, cdecl, impuvHdr.}
proc uv_fs_stat*(loop: ptr uv_loop_t; req: ptr uv_fs_t; path: cstring;
                 cb: uv_fs_cb): cint {.importc, cdecl, impuvHdr.}
proc uv_fs_fstat*(loop: ptr uv_loop_t; req: ptr uv_fs_t; file: uv_file;
                  cb: uv_fs_cb): cint {.importc, cdecl, impuvHdr.}
proc uv_fs_rename*(loop: ptr uv_loop_t; req: ptr uv_fs_t; path: cstring;
                   new_path: cstring; cb: uv_fs_cb): cint {.importc, cdecl,
    impuvHdr.}
proc uv_fs_fsync*(loop: ptr uv_loop_t; req: ptr uv_fs_t; file: uv_file;
                  cb: uv_fs_cb): cint {.importc, cdecl, impuvHdr.}
proc uv_fs_fdatasync*(loop: ptr uv_loop_t; req: ptr uv_fs_t; file: uv_file;
                      cb: uv_fs_cb): cint {.importc, cdecl, impuvHdr.}
proc uv_fs_ftruncate*(loop: ptr uv_loop_t; req: ptr uv_fs_t; file: uv_file;
                      offset: int64; cb: uv_fs_cb): cint {.importc, cdecl,
    impuvHdr.}
proc uv_fs_sendfile*(loop: ptr uv_loop_t; req: ptr uv_fs_t; out_fd: uv_file;
                     in_fd: uv_file; in_offset: int64; length: uint;
                     cb: uv_fs_cb): cint {.importc, cdecl, impuvHdr.}
proc uv_fs_access*(loop: ptr uv_loop_t; req: ptr uv_fs_t; path: cstring;
                   mode: cint; cb: uv_fs_cb): cint {.importc, cdecl, impuvHdr.}
proc uv_fs_chmod*(loop: ptr uv_loop_t; req: ptr uv_fs_t; path: cstring;
                  mode: cint; cb: uv_fs_cb): cint {.importc, cdecl, impuvHdr.}
proc uv_fs_utime*(loop: ptr uv_loop_t; req: ptr uv_fs_t; path: cstring;
                  atime: cdouble; mtime: cdouble; cb: uv_fs_cb): cint {.importc,
    cdecl, impuvHdr.}
proc uv_fs_futime*(loop: ptr uv_loop_t; req: ptr uv_fs_t; file: uv_file;
                   atime: cdouble; mtime: cdouble; cb: uv_fs_cb): cint {.
    importc, cdecl, impuvHdr.}
proc uv_fs_lutime*(loop: ptr uv_loop_t; req: ptr uv_fs_t; path: cstring;
                   atime: cdouble; mtime: cdouble; cb: uv_fs_cb): cint {.
    importc, cdecl, impuvHdr.}
proc uv_fs_lstat*(loop: ptr uv_loop_t; req: ptr uv_fs_t; path: cstring;
                  cb: uv_fs_cb): cint {.importc, cdecl, impuvHdr.}
proc uv_fs_link*(loop: ptr uv_loop_t; req: ptr uv_fs_t; path: cstring;
                 new_path: cstring; cb: uv_fs_cb): cint {.importc, cdecl,
    impuvHdr.}
proc uv_fs_symlink*(loop: ptr uv_loop_t; req: ptr uv_fs_t; path: cstring;
                    new_path: cstring; flags: cint; cb: uv_fs_cb): cint {.
    importc, cdecl, impuvHdr.}
proc uv_fs_readlink*(loop: ptr uv_loop_t; req: ptr uv_fs_t; path: cstring;
                     cb: uv_fs_cb): cint {.importc, cdecl, impuvHdr.}
proc uv_fs_realpath*(loop: ptr uv_loop_t; req: ptr uv_fs_t; path: cstring;
                     cb: uv_fs_cb): cint {.importc, cdecl, impuvHdr.}
proc uv_fs_fchmod*(loop: ptr uv_loop_t; req: ptr uv_fs_t; file: uv_file;
                   mode: cint; cb: uv_fs_cb): cint {.importc, cdecl, impuvHdr.}
proc uv_fs_chown*(loop: ptr uv_loop_t; req: ptr uv_fs_t; path: cstring;
                  uid: uv_uid_t; gid: uv_gid_t; cb: uv_fs_cb): cint {.importc,
    cdecl, impuvHdr.}
proc uv_fs_fchown*(loop: ptr uv_loop_t; req: ptr uv_fs_t; file: uv_file;
                   uid: uv_uid_t; gid: uv_gid_t; cb: uv_fs_cb): cint {.importc,
    cdecl, impuvHdr.}
proc uv_fs_lchown*(loop: ptr uv_loop_t; req: ptr uv_fs_t; path: cstring;
                   uid: uv_uid_t; gid: uv_gid_t; cb: uv_fs_cb): cint {.importc,
    cdecl, impuvHdr.}
proc uv_fs_statfs*(loop: ptr uv_loop_t; req: ptr uv_fs_t; path: cstring;
                   cb: uv_fs_cb): cint {.importc, cdecl, impuvHdr.}
proc uv_fs_poll_init*(loop: ptr uv_loop_t; handle: ptr uv_fs_poll_t): cint {.
    importc, cdecl, impuvHdr.}
proc uv_fs_poll_start*(handle: ptr uv_fs_poll_t; poll_cb: uv_fs_poll_cb;
                       path: cstring; interval: cuint): cint {.importc, cdecl,
    impuvHdr.}
proc uv_fs_poll_stop*(handle: ptr uv_fs_poll_t): cint {.importc, cdecl, impuvHdr.}
proc uv_fs_poll_getpath*(handle: ptr uv_fs_poll_t; buffer: cstring;
                         size: ptr uint): cint {.importc, cdecl, impuvHdr.}
proc uv_signal_init*(loop: ptr uv_loop_t; handle: ptr uv_signal_t): cint {.
    importc, cdecl, impuvHdr.}
proc uv_signal_start*(handle: ptr uv_signal_t; signal_cb: uv_signal_cb;
                      signum: cint): cint {.importc, cdecl, impuvHdr.}
proc uv_signal_start_oneshot*(handle: ptr uv_signal_t; signal_cb: uv_signal_cb;
                              signum: cint): cint {.importc, cdecl, impuvHdr.}
proc uv_signal_stop*(handle: ptr uv_signal_t): cint {.importc, cdecl, impuvHdr.}
proc uv_loadavg*(avg: array[3, cdouble]) {.importc, cdecl, impuvHdr.}
proc uv_fs_event_init*(loop: ptr uv_loop_t; handle: ptr uv_fs_event_t): cint {.
    importc, cdecl, impuvHdr.}
proc uv_fs_event_start*(handle: ptr uv_fs_event_t; cb: uv_fs_event_cb;
                        path: cstring; flags: cuint): cint {.importc, cdecl,
    impuvHdr.}
proc uv_fs_event_stop*(handle: ptr uv_fs_event_t): cint {.importc, cdecl,
    impuvHdr.}
proc uv_fs_event_getpath*(handle: ptr uv_fs_event_t; buffer: cstring;
                          size: ptr uint): cint {.importc, cdecl, impuvHdr.}
proc uv_ip4_addr*(ip: cstring; port: cint; `addr`: ptr SockAddr_in): cint {.
    importc, cdecl, impuvHdr.}
proc uv_ip6_addr*(ip: cstring; port: cint; `addr`: ptr SockAddr_in6): cint {.
    importc, cdecl, impuvHdr.}
proc uv_ip4_name*(src: ptr SockAddr_in; dst: cstring; size: uint): cint {.
    importc, cdecl, impuvHdr.}
proc uv_ip6_name*(src: ptr SockAddr_in6; dst: cstring; size: uint): cint {.
    importc, cdecl, impuvHdr.}
proc uv_ip_name*(src: ptr SockAddr; dst: cstring; size: uint): cint {.importc,
    cdecl, impuvHdr.}
proc uv_inet_ntop*(af: cint; src: pointer; dst: cstring; size: uint): cint {.
    importc, cdecl, impuvHdr.}
proc uv_inet_pton*(af: cint; src: cstring; dst: pointer): cint {.importc, cdecl,
    impuvHdr.}
proc uv_random*(loop: ptr uv_loop_t; req: ptr uv_random_t; buf: pointer;
                buflen: uint; flags: cuint; cb: uv_random_cb): cint {.importc,
    cdecl, impuvHdr.}
proc uv_if_indextoname*(ifindex: cuint; buffer: cstring; size: ptr uint): cint {.
    importc, cdecl, impuvHdr.}
proc uv_if_indextoiid*(ifindex: cuint; buffer: cstring; size: ptr uint): cint {.
    importc, cdecl, impuvHdr.}
proc uv_exepath*(buffer: cstring; size: ptr uint): cint {.importc, cdecl,
    impuvHdr.}
proc uv_cwd*(buffer: cstring; size: ptr uint): cint {.importc, cdecl, impuvHdr.}
proc uv_chdir*(dir: cstring): cint {.importc, cdecl, impuvHdr.}
proc uv_get_free_memory*(): uint64 {.importc, cdecl, impuvHdr.}
proc uv_get_total_memory*(): uint64 {.importc, cdecl, impuvHdr.}
proc uv_get_constrained_memory*(): uint64 {.importc, cdecl, impuvHdr.}
proc uv_get_available_memory*(): uint64 {.importc, cdecl, impuvHdr.}
proc uv_clock_gettime*(clock_id: uv_clock_id; ts: ptr uv_timespec64_t): cint {.
    importc, cdecl, impuvHdr.}
proc uv_hrtime*(): uint64 {.importc, cdecl, impuvHdr.}
proc uv_sleep*(msec: cuint) {.importc, cdecl, impuvHdr.}
proc uv_disable_stdio_inheritance*() {.importc, cdecl, impuvHdr.}
proc uv_dlopen*(filename: cstring; lib: ptr uv_lib_t): cint {.importc, cdecl,
    impuvHdr.}
proc uv_dlclose*(lib: ptr uv_lib_t) {.importc, cdecl, impuvHdr.}
proc uv_dlsym*(lib: ptr uv_lib_t; name: cstring; `ptr`: ptr pointer): cint {.
    importc, cdecl, impuvHdr.}
proc uv_dlerror*(lib: ptr uv_lib_t): cstring {.importc, cdecl, impuvHdr.}
proc uv_mutex_init*(handle: ptr uv_mutex_t): cint {.importc, cdecl, impuvHdr.}
proc uv_mutex_init_recursive*(handle: ptr uv_mutex_t): cint {.importc, cdecl,
    impuvHdr.}
proc uv_mutex_destroy*(handle: ptr uv_mutex_t) {.importc, cdecl, impuvHdr.}
proc uv_mutex_lock*(handle: ptr uv_mutex_t) {.importc, cdecl, impuvHdr.}
proc uv_mutex_trylock*(handle: ptr uv_mutex_t): cint {.importc, cdecl, impuvHdr.}
proc uv_mutex_unlock*(handle: ptr uv_mutex_t) {.importc, cdecl, impuvHdr.}
proc uv_rwlock_init*(rwlock: ptr uv_rwlock_t): cint {.importc, cdecl, impuvHdr.}
proc uv_rwlock_destroy*(rwlock: ptr uv_rwlock_t) {.importc, cdecl, impuvHdr.}
proc uv_rwlock_rdlock*(rwlock: ptr uv_rwlock_t) {.importc, cdecl, impuvHdr.}
proc uv_rwlock_tryrdlock*(rwlock: ptr uv_rwlock_t): cint {.importc, cdecl,
    impuvHdr.}
proc uv_rwlock_rdunlock*(rwlock: ptr uv_rwlock_t) {.importc, cdecl, impuvHdr.}
proc uv_rwlock_wrlock*(rwlock: ptr uv_rwlock_t) {.importc, cdecl, impuvHdr.}
proc uv_rwlock_trywrlock*(rwlock: ptr uv_rwlock_t): cint {.importc, cdecl,
    impuvHdr.}
proc uv_rwlock_wrunlock*(rwlock: ptr uv_rwlock_t) {.importc, cdecl, impuvHdr.}
proc uv_sem_init*(sem: ptr uv_sem_t; value: cuint): cint {.importc, cdecl,
    impuvHdr.}
proc uv_sem_destroy*(sem: ptr uv_sem_t) {.importc, cdecl, impuvHdr.}
proc uv_sem_post*(sem: ptr uv_sem_t) {.importc, cdecl, impuvHdr.}
proc uv_sem_wait*(sem: ptr uv_sem_t) {.importc, cdecl, impuvHdr.}
proc uv_sem_trywait*(sem: ptr uv_sem_t): cint {.importc, cdecl, impuvHdr.}
proc uv_cond_init*(cond: ptr uv_cond_t): cint {.importc, cdecl, impuvHdr.}
proc uv_cond_destroy*(cond: ptr uv_cond_t) {.importc, cdecl, impuvHdr.}
proc uv_cond_signal*(cond: ptr uv_cond_t) {.importc, cdecl, impuvHdr.}
proc uv_cond_broadcast*(cond: ptr uv_cond_t) {.importc, cdecl, impuvHdr.}
proc uv_barrier_init*(barrier: ptr uv_barrier_t; count: cuint): cint {.importc,
    cdecl, impuvHdr.}
proc uv_barrier_destroy*(barrier: ptr uv_barrier_t) {.importc, cdecl, impuvHdr.}
proc uv_barrier_wait*(barrier: ptr uv_barrier_t): cint {.importc, cdecl,
    impuvHdr.}
proc uv_cond_wait*(cond: ptr uv_cond_t; mutex: ptr uv_mutex_t) {.importc, cdecl,
    impuvHdr.}
proc uv_cond_timedwait*(cond: ptr uv_cond_t; mutex: ptr uv_mutex_t;
                        timeout: uint64): cint {.importc, cdecl, impuvHdr.}
proc uv_once*(guard: ptr uv_once_t; callback: proc () {.cdecl.}) {.importc,
    cdecl, impuvHdr.}
proc uv_key_create*(key: ptr uv_key_t): cint {.importc, cdecl, impuvHdr.}
proc uv_key_delete*(key: ptr uv_key_t) {.importc, cdecl, impuvHdr.}
proc uv_key_get*(key: ptr uv_key_t): pointer {.importc, cdecl, impuvHdr.}
proc uv_key_set*(key: ptr uv_key_t; value: pointer) {.importc, cdecl, impuvHdr.}
proc uv_gettimeofday*(tv: ptr uv_timeval64_t): cint {.importc, cdecl, impuvHdr.}
proc uv_thread_create*(tid: ptr uv_thread_t; entry: uv_thread_cb; arg: pointer): cint {.
    importc, cdecl, impuvHdr.}
proc uv_thread_create_ex*(tid: ptr uv_thread_t; params: ptr uv_thread_options_t;
                          entry: uv_thread_cb; arg: pointer): cint {.importc,
    cdecl, impuvHdr.}
proc uv_thread_setaffinity*(tid: ptr uv_thread_t; cpumask: cstring;
                            oldmask: cstring; mask_size: uint): cint {.importc,
    cdecl, impuvHdr.}
proc uv_thread_getaffinity*(tid: ptr uv_thread_t; cpumask: cstring;
                            mask_size: uint): cint {.importc, cdecl, impuvHdr.}
proc uv_thread_getcpu*(): cint {.importc, cdecl, impuvHdr.}
proc uv_thread_self*(): uv_thread_t {.importc, cdecl, impuvHdr.}
proc uv_thread_join*(tid: ptr uv_thread_t): cint {.importc, cdecl, impuvHdr.}
proc uv_thread_equal*(t1: ptr uv_thread_t; t2: ptr uv_thread_t): cint {.importc,
    cdecl, impuvHdr.}
proc uv_loop_get_data*(a1: ptr uv_loop_t): pointer {.importc, cdecl, impuvHdr.}
proc uv_loop_set_data*(a1: ptr uv_loop_t; data: pointer) {.importc, cdecl,
    impuvHdr.}
proc uv_utf16_length_as_wtf8*(utf16: ptr uint16; utf16_len: int): uint {.
    importc, cdecl, impuvHdr.}
  ## ```
                              ##   String utilities needed internally for dealing with Windows.
                              ## ```
proc uv_utf16_to_wtf8*(utf16: ptr uint16; utf16_len: int; wtf8_ptr: ptr cstring;
                       wtf8_len_ptr: ptr uint): cint {.importc, cdecl, impuvHdr.}
proc uv_wtf8_length_as_utf16*(wtf8: cstring): int {.importc, cdecl, impuvHdr.}
proc uv_wtf8_to_utf16*(wtf8: cstring; utf16: ptr uint16; utf16_len: uint) {.
    importc, cdecl, impuvHdr.}
{.pop.}
