# zig-build-libuv

> Builds [libuv](https://github.com/libuv/libuv) with [Zig](https://github.com/ziglang/zig)!

## Work in progress

Right now this only builds on macos and linux. Building on windows is on the way.

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
