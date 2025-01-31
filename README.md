# zig-build-libuv

Build [libuv](https://github.com/libuv/libuv) with easy cross-compilation enabled by [Zig](https://github.com/ziglang/zig)!

## About

This continues the work from the archived [mitchellh/zig-libuv](https://github.com/mitchellh/zig-libuv) repository.

This repo's only responsibility is building libuv.

## Usage

To **build libuv:**

Add the dependency:

```sh
zig fetch --save=zig_build_libuv "git ref url"
```

A gif ref url can be a commit, tag, release, etc.
