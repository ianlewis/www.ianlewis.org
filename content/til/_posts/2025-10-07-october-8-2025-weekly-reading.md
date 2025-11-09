---
layout: post
title: "TIL: October 8, 2025 - Weekly Reading: Programming and Kubernetes"
date: "2025-10-08 09:00:00 +0900"
blog: til
tags: weekly-reading programming kubernetes
render_with_liquid: false
---

## Programming

- [Processes and Threads](https://planetscale.com/blog/processes-and-threads) -- _Ben Dicken, PlanetScale_

    A simple overview of the processes, how they are multiplexed on a CPU, how
    they use memory, and how they differ from threads. It's a bit simplistic
    though and I didn't learn much I didn't already know.

- [Seven Years of Firecracker](https://brooker.co.za/blog/2025/09/18/firecracker.html) -- _Marc Brooker, AWS_

    A retrospective on Firecracker, a lightweight virtualization technology
    developed by AWS for running serverless workloads. Marc mentions some areas
    at AWS where Firecracker is used including Bedrock AgentCore. While I'm
    partial to the process model that gVisor uses, VM-based isolation does make
    it easier to provide the container with access to hardware features like
    GPUs.

- [I replaced all my bash scripts with Python, and here’s what happened](https://www.xda-developers.com/replaced-bash-scripts-python-what-happened/) -- _Jeff Butts_

    Jeff describes his experience replacing bash scripts with Python scripts. He
    found that Python scripts were more readable, maintainable, and easier to
    debug than bash scripts. Bash can easily bake in assumptions into the
    program regarding available environment variables, path names, and available
    commands just to name a few.

    I think bash is often overlooked and written off as a programming language
    for accomplishing real work and the problems encountered are often skill
    issues. It's great for wrapping other commands, running tests, etc. On the
    other hand, you should probably use a different language if you are actually
    writing business logic.

- [Building Statically Linked Go Executables with CGO and Zig](https://calabro.io/zig-cgo) -- _Jim Calabro_

    Apparently `cgo` does allow you to build statically linked Go binaries in some
    cases. You can statically link a Zig library that uses the C ABI into a Go
    program.

    You need to specify the right `LDFLAGS` to get a fully static binary.
    Compiling a library that you can do this with can be tricky to get right
    with C libraries but is a bit easier with Zig.

## Kubernetes

- [<!-- textlint-disable spelling -->Inside kube-scheduler: The Plugin Framework That Powers Kubernetes Scheduling<!-- textlint-enable spelling -->](https://medium.com/@helayoty/inside-kube-scheduler-the-plugin-framework-that-powers-kubernetes-scheduling-8452bee40c10) -- _Heba Elayoty_

    A detailed overview of the Kubernetes scheduler and its plugin framework.
    The article covers the architecture of the scheduler, how plugins are
    implemented, and an overview of the scheduling process.

    I wasn't familiar with the concept of Pod "binding" in the scheduling
    process. This is apparently part of the [scheduling
    framework](https://kubernetes.io/docs/concepts/scheduling-eviction/scheduling-framework/)
    that was added in Kubernetes 1.19. It seems that this can enable things like
    [Dynamic Binding
    Conditions](https://kubernetes.io/docs/concepts/scheduling-eviction/dynamic-resource-allocation/#device-binding-conditions)
    which delay binding the Pod to a Node until some required hardware is ready
    (e.g. a GPU).
