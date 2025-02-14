const std = @import("std");
const lib = @import("libuv");

const UvError = enum(i32) {
    E2BIG = lib.UV_E2BIG,
    EACCES = lib.UV_EACCES,
    EADDRINUSE = lib.UV_EADDRINUSE,
    EADDRNOTAVAIL = lib.UV_EADDRNOTAVAIL,
    EAFNOSUPPORT = lib.UV_EAFNOSUPPORT,
    EAGAIN = lib.UV_EAGAIN,
    EAI_ADDRFAMILY = lib.UV_EAI_ADDRFAMILY,
    EAI_AGAIN = lib.UV_EAI_AGAIN,
    EAI_BADFLAGS = lib.UV_EAI_BADFLAGS,
    EAI_BADHINTS = lib.UV_EAI_BADHINTS,
    EAI_CANCELED = lib.UV_EAI_CANCELED,
    EAI_FAIL = lib.UV_EAI_FAIL,
    EAI_FAMILY = lib.UV_EAI_FAMILY,
    EAI_MEMORY = lib.UV_EAI_MEMORY,
    EAI_NODATA = lib.UV_EAI_NODATA,
    EAI_NONAME = lib.UV_EAI_NONAME,
    EAI_OVERFLOW = lib.UV_EAI_OVERFLOW,
    EAI_PROTOCOL = lib.UV_EAI_PROTOCOL,
    EAI_SERVICE = lib.UV_EAI_SERVICE,
    EAI_SOCKTYPE = lib.UV_EAI_SOCKTYPE,
    EALREADY = lib.UV_EALREADY,
    EBADF = lib.UV_EBADF,
    EBUSY = lib.UV_EBUSY,
    ECANCELED = lib.UV_ECANCELED,
    ECHARSET = lib.UV_ECHARSET,
    ECONNABORTED = lib.UV_ECONNABORTED,
    ECONNREFUSED = lib.UV_ECONNREFUSED,
    ECONNRESET = lib.UV_ECONNRESET,
    EDESTADDRREQ = lib.UV_EDESTADDRREQ,
    EEXIST = lib.UV_EEXIST,
    EFAULT = lib.UV_EFAULT,
    EFBIG = lib.UV_EFBIG,
    EHOSTUNREACH = lib.UV_EHOSTUNREACH,
    EINTR = lib.UV_EINTR,
    EINVAL = lib.UV_EINVAL,
    EIO = lib.UV_EIO,
    EISCONN = lib.UV_EISCONN,
    EISDIR = lib.UV_EISDIR,
    ELOOP = lib.UV_ELOOP,
    EMFILE = lib.UV_EMFILE,
    EMSGSIZE = lib.UV_EMSGSIZE,
    ENAMETOOLONG = lib.UV_ENAMETOOLONG,
    ENETDOWN = lib.UV_ENETDOWN,
    ENETUNREACH = lib.UV_ENETUNREACH,
    ENFILE = lib.UV_ENFILE,
    ENOBUFS = lib.UV_ENOBUFS,
    ENODEV = lib.UV_ENODEV,
    ENOENT = lib.UV_ENOENT,
    ENOMEM = lib.UV_ENOMEM,
    ENONET = lib.UV_ENONET,
    ENOPROTOOPT = lib.UV_ENOPROTOOPT,
    ENOSPC = lib.UV_ENOSPC,
    ENOSYS = lib.UV_ENOSYS,
    ENOTCONN = lib.UV_ENOTCONN,
    ENOTDIR = lib.UV_ENOTDIR,
    ENOTEMPTY = lib.UV_ENOTEMPTY,
    ENOTSOCK = lib.UV_ENOTSOCK,
    ENOTSUP = lib.UV_ENOTSUP,
    EOVERFLOW = lib.UV_EOVERFLOW,
    EPERM = lib.UV_EPERM,
    EPIPE = lib.UV_EPIPE,
    EPROTO = lib.UV_EPROTO,
    EPROTONOSUPPORT = lib.UV_EPROTONOSUPPORT,
    EPROTOTYPE = lib.UV_EPROTOTYPE,
    ERANGE = lib.UV_ERANGE,
    EROFS = lib.UV_EROFS,
    ESHUTDOWN = lib.UV_ESHUTDOWN,
    ESPIPE = lib.UV_ESPIPE,
    ESRCH = lib.UV_ESRCH,
    ETIMEDOUT = lib.UV_ETIMEDOUT,
    ETXTBSY = lib.UV_ETXTBSY,
    EXDEV = lib.UV_EXDEV,
    UNKNOWN = lib.UV_UNKNOWN,
    EOF = lib.UV_EOF,
    ENXIO = lib.UV_ENXIO,
    EMLINK = lib.UV_EMLINK,
    ENOTTY = lib.UV_ENOTTY,
    EFTYPE = lib.UV_EFTYPE,
    EILSEQ = lib.UV_EILSEQ,
    ESOCKTNOSUPPORT = lib.UV_ESOCKTNOSUPPORT,
    EUNATCH = lib.UV_EUNATCH,
};

pub fn message(err: Error) []const u8 {
    return switch (err) {
        Error.E2BIG => "argument list too long",
        Error.EACCES => "permission denied",
        Error.EADDRINUSE => "address already in use",
        Error.EADDRNOTAVAIL => "address not available",
        Error.EAFNOSUPPORT => "address family not supported",
        Error.EAGAIN => "resource temporarily unavailable",
        Error.EAI_ADDRFAMILY => "address family not supported",
        Error.EAI_AGAIN => "temporary failure",
        Error.EAI_BADFLAGS => "bad ai_flags value",
        Error.EAI_BADHINTS => "invalid value for hints",
        Error.EAI_CANCELED => "request canceled",
        Error.EAI_FAIL => "permanent failure",
        Error.EAI_FAMILY => "ai_family not supported",
        Error.EAI_MEMORY => "out of memory",
        Error.EAI_NODATA => "no address",
        Error.EAI_NONAME => "unknown node or service",
        Error.EAI_OVERFLOW => "argument buffer overflow",
        Error.EAI_PROTOCOL => "resolved protocol is unknown",
        Error.EAI_SERVICE => "service not available for socket type",
        Error.EAI_SOCKTYPE => "socket type not supported",
        Error.EALREADY => "connection already in progress",
        Error.EBADF => "bad file descriptor",
        Error.EBUSY => "resource busy or locked",
        Error.ECANCELED => "operation canceled",
        Error.ECHARSET => "invalid Unicode character",
        Error.ECONNABORTED => "software caused connection abort",
        Error.ECONNREFUSED => "connection refused",
        Error.ECONNRESET => "connection reset by peer",
        Error.EDESTADDRREQ => "destination address required",
        Error.EEXIST => "file already exists",
        Error.EFAULT => "bad address in system call argument",
        Error.EFBIG => "file too large",
        Error.EHOSTUNREACH => "host is unreachable",
        Error.EINTR => "interrupted system call",
        Error.EINVAL => "invalid argument",
        Error.EIO => "i/o error",
        Error.EISCONN => "socket is already connected",
        Error.EISDIR => "illegal operation on a directory",
        Error.ELOOP => "too many symbolic links encountered",
        Error.EMFILE => "too many open files",
        Error.EMSGSIZE => "message too long",
        Error.ENAMETOOLONG => "name too long",
        Error.ENETDOWN => "network is down",
        Error.ENETUNREACH => "network is unreachable",
        Error.ENFILE => "file table overflow",
        Error.ENOBUFS => "no buffer space available",
        Error.ENODEV => "no such device",
        Error.ENOENT => "no such file or directory",
        Error.ENOMEM => "not enough memory",
        Error.ENONET => "machine is not on the network",
        Error.ENOPROTOOPT => "protocol not available",
        Error.ENOSPC => "no space left on device",
        Error.ENOSYS => "function not implemented",
        Error.ENOTCONN => "socket is not connected",
        Error.ENOTDIR => "not a directory",
        Error.ENOTEMPTY => "directory not empty",
        Error.ENOTSOCK => "socket operation on non-socket",
        Error.ENOTSUP => "operation not supported on socket",
        Error.EOVERFLOW => "value too large for defined data type",
        Error.EPERM => "operation not permitted",
        Error.EPIPE => "broken pipe",
        Error.EPROTO => "protocol error",
        Error.EPROTONOSUPPORT => "protocol not supported",
        Error.EPROTOTYPE => "protocol wrong type for socket",
        Error.ERANGE => "result too large",
        Error.EROFS => "read-only file system",
        Error.ESHUTDOWN => "cannot send after transport endpoint shutdown",
        Error.ESPIPE => "invalid seek",
        Error.ESRCH => "no such process",
        Error.ETIMEDOUT => "connection timed out",
        Error.ETXTBSY => "text file is busy",
        Error.EXDEV => "cross-device link not permitted",
        Error.UNKNOWN => "unknown error",
        Error.EOF => "end of file",
        Error.ENXIO => "no such device or address",
        Error.EMLINK => "too many links",
        Error.ENOTTY => "inappropriate ioctl for device",
        Error.EFTYPE => "inappropriate file type or format",
        Error.EILSEQ => "illegal byte sequence",
        Error.ESOCKTNOSUPPORT => "socket type not supported",
        Error.EUNATCH => "protocol driver not attached",
    };
}
