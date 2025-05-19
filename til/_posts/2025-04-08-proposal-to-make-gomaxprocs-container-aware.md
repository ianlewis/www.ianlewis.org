---
layout: post
title: "TIL: Proposal to Make GOMAXPROCS Container-aware"
date: "2025-04-08 00:00:00 +0900"
blog: til
tags: go programming
render_with_liquid: false
---

One of my former colleagues, Michael Pratt, created a
[proposal](https://github.com/golang/go/issues/73193) for the Go runtime's
[`GOMAXPROCS`](https://pkg.go.dev/runtime#GOMAXPROCS) to take into account the
process's CPU limits imposed by cgroups. The goal is for Go to be more
container-aware because cgroup CPU limits are the main way that container
runtimes enforce resource constraints.

I'm really excited to see this added to Go because I adhere to the philosophy
that processes should need to know as little as possible about the
infrastructure that they are being run on. Currently, almost every production Go
application running in a container needs to incorporate code like
[`uber-go/automaxprocs`](https://github.com/uber-go/automaxprocs) to take into
account CPU limits.

The proposal that Michael writes is very thorough and brings up issues like the
fact that CPU quota allows for bursting while `GOMAXPROCS` does not. These are
some of the tradeoffs that users of `uber-go/automaxprocs` already have to deal
with however.
