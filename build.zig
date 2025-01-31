const std = @import("std");
const fs = std.fs;
const mem = std.mem;

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const target_os = target.result.os.tag;

    const libuv_dep = b.dependency("libuv", .{});

    const libuv = b.addStaticLibrary(.{
        .name = "libuv",
        .target = target,
        .optimize = optimize,
    });

    if (target_os == .windows) {
        libuv.linkSystemLibrary("psapi");
        libuv.linkSystemLibrary("user32");
        libuv.linkSystemLibrary("advapi32");
        libuv.linkSystemLibrary("iphlpapi");
        libuv.linkSystemLibrary("userenv");
        libuv.linkSystemLibrary("ws2_32");
    }

    if (target_os == .linux) {
        libuv.linkSystemLibrary("pthread");
    }

    var flags = std.ArrayList([]const u8).init(b.allocator);
    defer flags.deinit();

    if (target_os != .windows) {
        try flags.appendSlice(&.{
            "-D_FILE_OFFSET_BITS=64",
            "-D_LARGEFILE_SOURCE",
        });
    }

    if (target_os == .linux) {
        try flags.appendSlice(&.{
            "-D_GNU_SOURCE",
            "-D_POSIX_C_SOURCE=200112",
        });
    }

    if (target_os.isDarwin()) {
        try flags.appendSlice(&.{
            "-D_DARWIN_UNLIMITED_SELECT=1",
            "-D_DARWIN_USE_64_BIT_INODE=1",
        });
    }

    libuv.addCSourceFiles(.{
        .root = libuv_dep.path("src"),
        .files = &.{
            "fs-poll.c",
            "idna.c",
            "inet.c",
            "random.c",
            "strscpy.c",
            "strtok.c",
            "threadpool.c",
            "timer.c",
            "uv-common.c",
            "uv-data-getter-setters.c",
            "version.c",
        },
        .flags = flags.items,
    });

    if (target_os != .windows) {
        libuv.addCSourceFiles(.{
            .root = libuv_dep.path("src"),
            .files = &.{
                "unix/async.c",
                "unix/core.c",
                "unix/dl.c",
                "unix/fs.c",
                "unix/getaddrinfo.c",
                "unix/getnameinfo.c",
                "unix/loop-watcher.c",
                "unix/loop.c",
                "unix/pipe.c",
                "unix/poll.c",
                "unix/process.c",
                "unix/random-devurandom.c",
                "unix/signal.c",
                "unix/stream.c",
                "unix/tcp.c",
                "unix/thread.c",
                "unix/tty.c",
                "unix/udp.c",
            },
            .flags = flags.items,
        });
    }

    if (target_os == .linux or target_os.isDarwin()) {
        libuv.addCSourceFiles(.{
            .root = libuv_dep.path("src"),
            .files = &.{
                "unix/proctitle.c",
            },
            .flags = flags.items,
        });
    }

    if (target_os == .linux) {
        libuv.addCSourceFiles(.{
            .root = libuv_dep.path("src"),
            .files = &.{
                "unix/linux.c",
                "unix/procfs-exepath.c",
                "unix/random-getrandom.c",
                "unix/random-sysctl-linux.c",
            },
            .flags = flags.items,
        });
    }

    if (target_os.isBSD()) { // includes darwin
        libuv.addCSourceFiles(.{
            .root = libuv_dep.path("src"),
            .files = &.{
                "unix/bsd-ifaddrs.c",
                "unix/kqueue.c",
            },
            .flags = flags.items,
        });
    }

    if (target_os.isDarwin() or target_os == .openbsd) {
        libuv.addCSourceFiles(.{
            .root = libuv_dep.path("src"),
            .files = &.{"unix/random-getentropy.c"},
            .flags = flags.items,
        });
    }

    if (target_os.isDarwin()) {
        libuv.addCSourceFiles(.{
            .root = libuv_dep.path("src"),
            .files = &.{
                "unix/darwin-proctitle.c",
                "unix/darwin.c",
                "unix/fsevents.c",
            },
            .flags = flags.items,
        });
    }

    libuv.addIncludePath(libuv_dep.path("include"));
    libuv.addIncludePath(libuv_dep.path("src"));
    libuv.linkLibC();

    libuv.installHeadersDirectory(libuv_dep.path("include"), "", .{});
    libuv.installHeadersDirectory(libuv_dep.path("include"), "uv", .{});
    libuv.installHeadersDirectory(libuv_dep.path("src"), "uv", .{});

    b.installArtifact(libuv);

    const bindings = b.addTranslateC(.{ .optimize = optimize, .target = target, .root_source_file = libuv_dep.path("include/uv.h") });

    bindings.addIncludePath(libuv_dep.path("include"));
    bindings.addIncludePath(libuv_dep.path("src"));

    const transform_bindings = try TransformStep.create(b, bindings);
    const module = bindings.addModule("libuv");
    module.linkLibrary(libuv);
    libuv.step.dependOn(&transform_bindings.step);

    const root_mod = b.createModule(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    root_mod.addImport("libuv", module);

    const lib_unit_tests = b.addTest(.{
        .root_module = root_mod,
        .target = target,
        .optimize = optimize,
    });

    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);

    const exe_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    exe_mod.addImport("libuv", module);

    const exe = b.addExecutable(.{
        .name = "tmp",
        .root_module = exe_mod,
    });

    exe.addIncludePath(libuv_dep.path("include"));
    exe.addIncludePath(libuv_dep.path("src"));
    exe.installHeadersDirectory(libuv_dep.path("include"), "", .{});
    exe.installHeadersDirectory(libuv_dep.path("include"), "uv", .{});
    exe.installHeadersDirectory(libuv_dep.path("src"), "uv", .{});

    b.installArtifact(exe);
    const run_exe = b.addRunArtifact(exe);
    const run_step = b.step("run", "Run example");
    run_step.dependOn(&run_exe.step);
}

const TransformStep = struct {
    step: std.Build.Step,
    bindings: *std.Build.Step.TranslateC,
    b: *std.Build,

    pub fn create(b: *std.Build, bindings: *std.Build.Step.TranslateC) !*TransformStep {
        const self = try b.allocator.create(TransformStep);

        self.* = .{
            .step = std.Build.Step.init(.{
                .id = .custom,
                .name = "transform-bindings",
                .owner = b,
                .makeFn = make,
            }),
            .bindings = bindings,
            .b = b,
        };

        self.step.dependOn(&bindings.step);
        return self;
    }

    fn make(step: *std.Build.Step, _: std.Build.Step.MakeOptions) !void {
        const self = @as(*TransformStep, @fieldParentPtr("step", step));
        const filepath = self.bindings.getOutput().getPath(self.b);
        const file = try fs.openFileAbsolute(filepath, .{ .mode = .read_only });
        const file_reader = file.reader();
        var reader = std.io.bufferedReader(file_reader);
        var buffer: [5120]u8 = undefined;
        var lines = std.ArrayList(u8).init(self.b.allocator);

        // Workaround based on https://github.com/mitchellh/zig-libuv/blob/main/src/c.zig#L9
        // See zig issue https://github.com/ziglang/zig/issues/12325
        while (try reader.reader().readUntilDelimiterOrEof(&buffer, '\n')) |line| {
            if (mem.eql(u8, "    close_cb: uv_close_cb = @import(\"std\").mem.zeroes(uv_close_cb),", line)) {
                try lines.appendSlice("    close_cb: ?*const anyopaque = null, // BUG uv_close_cb https://github.com/ziglang/zig/issues/12325");
            } else if (std.mem.eql(u8, "    read_cb: uv_read_cb = @import(\"std\").mem.zeroes(uv_read_cb),", line)) {
                try lines.appendSlice("     read_cb: ?*const anyopaque = null, // BUG uv_read_cb https://github.com/ziglang/zig/issues/12325");
            } else {
                try lines.appendSlice(line);
            }

            try lines.append('\n');
        }

        file.close();
        try fs.deleteFileAbsolute(filepath);
        const revised_file = try fs.createFileAbsolute(filepath, .{});
        try revised_file.writeAll(lines.items);
        revised_file.close();
    }
};
