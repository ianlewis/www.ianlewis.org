---
layout: post
title: "TIL: May 25, 2026 - Weekly Reading: Git and Mitigating Linux Kernel Vulnerabilities"
date: "2026-05-25 09:00:00 +0900"
blog: til
tags: weekly-reading programming security
render_with_liquid: false
---

## Git

- [Git Is Not Fine](https://www.billjings.com/posts/title/git-is-not-fine/) -- _Bridget Phillips_

    This post discusses some of the shortcomings of `git` and how some
    information can be lost during rebases etc. The ultimate argument is to use
    [Jujutsu](https://www.jj-vcs.dev/latest/) (`jj`) but it mostly talks about
    `git`.

    It's hard for me to care too much about this because I usually don't care
    about preserving info if commits are altered (rebased, amended, squashed).
    Usually it's an intentional omission of info to keep the history clean.

    I personally like commit histories that are linear and where each commit is
    a self-contained change. How each individual commit went back and forth
    during peer review isn't all that interesting. If there is information worth
    preserving there, it should probably be documented in a more permanent
    place.

    That said, GitHub's PR system relying on commits to track changes between
    rounds of review does not make this system easy. It's also difficult to
    maintain the original author's commit signatures. To preserve a linear
    history and original signatures, each PR author would have to rebase their
    change on top of the latest `main` branch commit which is very difficult
    when `main` is changing a lot.

    I'm pretty sure `jj` doesn't fix these issues and instead leans the other
    way towards preserving as much information as possible, regardless of its
    importance.

    My notes are on
    [Readwise](https://readwise.io/reader/shared/01kryjbas6ws6jjjsttpk2brsh).

## Linux Kernel Vulnerabilities

- [Live-patching security vulnerabilities inside the Linux kernel with eBPF Linux Security Module](https://blog.cloudflare.com/live-patch-security-vulnerabilities-with-ebpf-lsm/) -- _Frederick Lawler, Cloudflare_

    This post describes how Cloudflare uses eBPF Linux Security Modules (LSM) to
    mitigate the impact of common ways to break out of containers. In this case,
    they describe blocking the use of `unshare` with the `CLONE_NEWUSER` flag.

    Using eBPF LSMs seems like a really powerful way to add logic to the kernel
    without needing to update the kernel itself, or even reboot the system.

    My notes are on
    [Readwise](https://readwise.io/reader/shared/01krdnmqnwvdxrdvvqk0j48x1j).

- [How Cloudflare responded to the “Copy Fail” Linux vulnerability](https://blog.cloudflare.com/copy-fail-linux-vulnerability-mitigation/) -- _Chris J Arges, Sourov Zaman and Rian Islam, Cloudflare_

    Here Cloudflare describes how they used the eBPF LSM described in the
    previous post to mitigate the impact of the
    ["Copy Fail"](https://copy.fail/) vulnerability in the Linux kernel. This
    vulnerability allows an attacker to easily get root on the machine.

    Cloudflare mitigated the vulnerability quickly by deploying an eBPF LSM that
    used the `socket_bind` LSM hook for untrusted processes.

    My notes are on
    [Readwise](https://readwise.io/reader/shared/01krdn4tt9gaz58v14nn4z41em).
