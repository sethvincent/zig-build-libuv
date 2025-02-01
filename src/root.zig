const std = @import("std");

const t = std.testing;
const loop = @import("loop.zig");
const timer = @import("timer.zig");

test {
    t.refAllDecls(@This());
}
