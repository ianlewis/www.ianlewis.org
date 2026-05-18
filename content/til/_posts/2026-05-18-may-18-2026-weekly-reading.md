---
layout: post
title: "TIL: May 18, 2026 - Weekly Reading: Mythos and Go Performance Optimization"
date: "2026-05-18 09:00:00 +0900"
blog: til
tags: weekly-reading ai go security
render_with_liquid: false
---

## Mythos

- [Apple’s Security Has Been Tough to Crack. Mythos Helped Find a Way In.](https://www.wsj.com/tech/ai/anthropic-mythos-apple-macos-bug-339da403) -- _Robert McMillan, The Wall Street Journal_

    Two researchers at a security company called Calif found a rare privilege
    escalation vulnerability in
    macOS. Unfortunately, the details are still not public, but it seems like
    it's legitimate.

    The interesting part is that they used Anthropic's Mythos, a large language
    model fine-tuned for security research, to find the vulnerability. Right now
    Anthropic is practicing a kind of responsible disclosure with Mythos and I
    feel like that's a good idea. Moving more deliberately allows time to adopt
    the technology without the immediate downsides.

- [First public macOS kernel memory corruption exploit on Apple M5](https://blog.calif.io/p/first-public-kernel-memory-corruption) -- _Calif_

    This is the blog post from Calif about the vulnerability. It goes into a bit
    more technical detail, but not much more. The vulnerability is a kernel
    memory corruption bug that bypasses macOS's Memory Integrity Enforcement
    (MIE).

    They make use of two vulnerabilities to achieve privilege escalation. I
    wonder if security postures may need to be rethought if AI can find multiple
    vulnerabilities at once. Building systems target to deal with multiple
    new vulnerabilities gets very complicated quickly.

    In the end, I think it's a temporary problem though. AI will increasingly be
    used to find vulnerabilities by the companies themselves and be better
    positioned.

    My notes are on
    [Readwise](https://readwise.io/reader/shared/01krv4h6qgybnhwyft0w5nden8).

## Go Performance Optimization

- [Notes from Optimizing CPU-Bound Go Hot Paths](https://blog.andr2i.com/posts/2026-05-03-notes-from-optimizing-cpu-bound-go-hot-paths) -- _Andrii Berezhynskyi_

    Andrii is an engineer working on
    [`go-brrr`](https://github.com/molecule-man/go-brrr) which is a highly
    optimized Go implementation of Brotli compression.

    Andrii makes a lot of good points about Go's downsides when developing
    CPU-bound workloads. Go is really meant for network servers and other
    IO-bound workloads, but CPU-bound workloads are quite common. Many
    applications will go back and forth between CPU-bound and IO-bound
    code.

    The details are worth a read and I think Go could really improve by having
    some more ways of optimizing CPU-bound code even if it requires `unsafe`.
    The downside is more `unsafe` code in Go's ecosystem so there is perhaps a
    tradeoff to be made.

    My notes are on
    [Readwise](https://readwise.io/reader/shared/01krm72rynnaf6xdwtpqx3rwdt)
