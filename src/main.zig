const std = @import("std");
const lib = @import("libuv");

pub fn main() !void {
    var loop: lib.uv_loop_t = undefined;
    const result = lib.uv_loop_init(&loop);
    if (result < 0) return error.UvError;
    defer _ = lib.uv_loop_close(&loop);

    std.debug.print("Loop initialized! (｀◔ω◔´)\n", .{});
}
