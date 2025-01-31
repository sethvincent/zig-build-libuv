const std = @import("std");
const uv = @import("libuv");

const t = std.testing;
const print = std.debug.print;
const Allocator = std.mem.Allocator;

pub fn createLoop() !uv.uv_loop_t {
    var loop: uv.uv_loop_t = undefined;
    const result = uv.uv_loop_init(&loop);
    if (result < 0) return error.UvError;
    return loop;
}

test "loop" {
    const loop: *uv.uv_loop_t = try t.allocator.create(uv.uv_loop_t);
    defer t.allocator.destroy(loop);

    const init_result = uv.uv_loop_init(loop);
    try t.expectEqual(0, init_result);

    const run_result = uv.uv_run(loop, uv.UV_RUN_DEFAULT);
    try t.expectEqual(0, run_result);

    const close_result = uv.uv_loop_close(loop);
    try t.expectEqual(0, close_result);
}

test "default_loop" {
    const loop = uv.uv_default_loop();

    const run_result = uv.uv_run(loop, uv.UV_RUN_DEFAULT);
    try t.expectEqual(0, run_result);

    const close_result = uv.uv_loop_close(loop);
    try t.expectEqual(0, close_result);
}
