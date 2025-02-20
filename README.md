# zig-build-libuv

> Builds [libuv](https://github.com/libuv/libuv) with [Zig](https://github.com/ziglang/zig)!

## Work in progress

This package hasn't had much use yet but should be generally usable. Usage examples are on the way. Currently you can look at [src/timer.zig](src/timer.zig) for some examples of loop and timer usage.

## About

This continues the work from the archived [mitchellh/zig-libuv](https://github.com/mitchellh/zig-libuv) repository.

This repo can be used as a dependency to easily add libuv to your project.

## Usage

To **add libuv to your project:**

Add the dependency to the build.zig.zon using `zig fetch`:

```sh
zig fetch --save=zig_build_libuv "git ref url"
```

A gif ref url can be a commit, tag, release, etc.

Define the dependency in build.zig:

```zig
const libuv_dep = b.dependency("libuv", .{
    .target = target,
    .optimize = optimize,
});
```

Add libuv to the appropriate module(s):

```zig
lib_mod.addImport("libuv", libuv_dep.module("libuv"));
```