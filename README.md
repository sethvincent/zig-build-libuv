# zig-build-libuv

> Builds [libuv](https://github.com/libuv/libuv) with [Zig](https://github.com/ziglang/zig)!

## Work in progress

This package hasn't had much use yet but should be generally usable. Usage examples are on the way. Currently you can look at [src/timer.zig](src/timer.zig) for some examples of loop and timer usage.

## About

This continues the work from the archived [mitchellh/zig-libuv](https://github.com/mitchellh/zig-libuv) repository.

This repo can be used as a dependency to easily add libuv to your project.

## Usage

To **build libuv:**

Add the dependency:

```sh
zig fetch --save=zig_build_libuv "git ref url"
```

A gif ref url can be a commit, tag, release, etc.
