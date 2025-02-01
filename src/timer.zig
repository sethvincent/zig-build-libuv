const std = @import("std");
const uv = @import("libuv");

const t = std.testing;
const print = std.debug.print;
const Allocator = std.mem.Allocator;

test "uv_timer_t: start callback" {
    const loop: *uv.uv_loop_t = try std.heap.c_allocator.create(uv.uv_loop_t);
    defer std.heap.c_allocator.destroy(loop);

    const init_result = uv.uv_loop_init(loop);
    try t.expectEqual(0, init_result);

    const timer = try std.heap.c_allocator.create(uv.uv_timer_t);
    errdefer std.heap.c_allocator.destroy(timer);

    const timer_init_result = uv.uv_timer_init(loop, timer);
    try t.expectEqual(0, timer_init_result);

    var called: bool = false;
    uv.uv_handle_set_data(
        @as(*uv.uv_handle_t, @ptrCast(timer)),
        &called,
    );

    const Func = struct {
        fn callback(timer_struct: [*c]uv.struct_uv_timer_s) void {
            if (uv.uv_handle_get_data(@as(*uv.uv_handle_t, @ptrCast(timer_struct)))) |called_ptr| {
                @as(
                    *bool,
                    @ptrCast(@alignCast(@as(*anyopaque, called_ptr))),
                ).* = true;
            }
            uv.uv_close((@as(*uv.uv_handle_t, @ptrCast(timer_struct))), null);
        }
    };

    const Wrapper = struct {
        pub fn callback(handle: [*c]uv.uv_timer_t) callconv(.c) void {
            @call(.always_inline, Func.callback, .{handle});
        }
    };

    const timer_start_result = uv.uv_timer_start(
        timer,
        Wrapper.callback,
        10,
        1000,
    );
    try t.expectEqual(0, timer_start_result);

    const run_result = uv.uv_run(loop, uv.UV_RUN_DEFAULT);
    try t.expectEqual(0, run_result);
    try t.expect(called);
}

test "uv_timer_t: close callback" {
    const loop: *uv.uv_loop_t = try std.heap.c_allocator.create(uv.uv_loop_t);
    defer std.heap.c_allocator.destroy(loop);

    const init_result = uv.uv_loop_init(loop);
    try t.expectEqual(0, init_result);

    const timer = try std.heap.c_allocator.create(uv.uv_timer_t);
    errdefer std.heap.c_allocator.destroy(timer);

    const timer_init_result = uv.uv_timer_init(loop, timer);
    try t.expectEqual(0, timer_init_result);

    var data: u8 = 42;
    uv.uv_handle_set_data(
        @as(*uv.uv_handle_t, @ptrCast(timer)),
        &data,
    );

    uv.uv_close((@as([*c]uv.uv_handle_t, @ptrCast(timer))), (struct {
        fn callback(v: [*c]uv.uv_handle_t) callconv(.c) void {
            const data_ptr = uv.uv_handle_get_data(@as(*uv.uv_handle_t, @ptrCast(v)));

            if (data_ptr) |ptr| {
                @as(
                    *u8,
                    @ptrCast(@alignCast(@as(*anyopaque, ptr))),
                ).* = 24;
            }
        }
    }).callback);

    const run_result = uv.uv_run(loop, uv.UV_RUN_DEFAULT);
    try t.expectEqual(0, run_result);

    try t.expectEqual(@as(u8, 24), data);
}

pub fn startTimer(
    timer: [*c]uv.uv_timer_t,
    callback: fn ([*c]uv.struct_uv_timer_s) void,
    timeout: u64,
    repeat: u64,
) !void {
    const Wrapper = struct {
        fn cb(handle: [*c]uv.uv_timer_t) callconv(.c) void {
            @call(.always_inline, callback, .{handle});
        }
    };

    const timer_start_result = uv.uv_timer_start(
        timer,
        Wrapper.cb,
        timeout,
        repeat,
    );

    if (timer_start_result < 0) {
        return error.TimerStartFailed;
    }
}

test startTimer {
    const loop: *uv.uv_loop_t = try std.heap.c_allocator.create(uv.uv_loop_t);
    defer std.heap.c_allocator.destroy(loop);

    const init_result = uv.uv_loop_init(loop);
    try t.expectEqual(0, init_result);

    const timer = try std.heap.c_allocator.create(uv.uv_timer_t);
    defer std.heap.c_allocator.destroy(timer);

    const timer_init_result = uv.uv_timer_init(loop, timer);
    try t.expectEqual(0, timer_init_result);

    var called: bool = false;
    uv.uv_handle_set_data(
        @as(*uv.uv_handle_t, @ptrCast(timer)),
        &called,
    );

    try startTimer(timer, struct {
        fn callback(timer_struct: [*c]uv.struct_uv_timer_s) void {
            const timer_ptr = uv.uv_handle_get_data(@as(*uv.uv_handle_t, @ptrCast(timer_struct)));

            if (timer_ptr) |ptr| {
                @as(
                    *bool,
                    @ptrCast(@alignCast(@as(*anyopaque, ptr))),
                ).* = true;
            }

            uv.uv_close((@as(*uv.uv_handle_t, @ptrCast(timer_struct))), null);
        }
    }.callback, 10, 1000);

    const run_result = uv.uv_run(loop, uv.UV_RUN_DEFAULT);
    try t.expectEqual(0, run_result);
    try t.expect(called);
}

const Timer = struct {
    handle: uv.uv_timer_t,

    pub fn init(allocator: Allocator, loop: *uv.uv_loop_t) !*Timer {
        var timer = try allocator.create(Timer);

        timer.* = .{
            .handle = undefined,
        };

        const timer_init_result = uv.uv_timer_init(loop, &timer.handle);

        if (timer_init_result < 0) {
            return error.TimerInitFailed;
        }

        return timer;
    }

    pub fn deinit(self: *Timer, allocator: Allocator) void {
        allocator.destroy(self);
    }

    pub fn start(
        self: *Timer,
        callback: fn ([*c]uv.struct_uv_timer_s) void,
        timeout: u64,
        repeat: u64,
    ) !void {
        const Wrapper = struct {
            fn cb(handle: [*c]uv.uv_timer_t) callconv(.c) void {
                @call(.always_inline, callback, .{handle});
            }
        };

        const timer_start_result = uv.uv_timer_start(
            &self.handle,
            Wrapper.cb,
            timeout,
            repeat,
        );

        if (timer_start_result < 0) {
            return error.TimerStartFailed;
        }
    }
};

test Timer {
    const loop: *uv.uv_loop_t = try std.heap.c_allocator.create(uv.uv_loop_t);
    defer std.heap.c_allocator.destroy(loop);

    const init_result = uv.uv_loop_init(loop);
    try t.expectEqual(0, init_result);

    const timer = try Timer.init(std.heap.c_allocator, loop);
    defer timer.deinit(std.heap.c_allocator);
    try t.expectEqual(*Timer, @TypeOf(timer));

    var called: bool = false;
    uv.uv_handle_set_data(
        @as(*uv.uv_handle_t, @ptrCast(timer)),
        &called,
    );

    try timer.start(struct {
        fn callback(timer_struct: [*c]uv.struct_uv_timer_s) void {
            const timer_ptr = uv.uv_handle_get_data(@as(*uv.uv_handle_t, @ptrCast(timer_struct)));

            if (timer_ptr) |ptr| {
                @as(
                    *bool,
                    @ptrCast(@alignCast(@as(*anyopaque, ptr))),
                ).* = true;
            }

            uv.uv_close((@as(*uv.uv_handle_t, @ptrCast(timer_struct))), null);
        }
    }.callback, 10, 1000);

    const run_result = uv.uv_run(loop, uv.UV_RUN_DEFAULT);
    try t.expectEqual(0, run_result);
    try t.expect(called);
}
