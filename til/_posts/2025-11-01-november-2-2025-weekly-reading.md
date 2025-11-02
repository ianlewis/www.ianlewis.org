---
layout: post
title: "TIL: November 2, 2025 - Weekly Reading: Go, Scripts, and Security"
date: "2025-11-02 09:00:00 +0900"
blog: til
tags: weekly-reading golang programming security
render_with_liquid: false
---

## Go

- [I'm Independently Verifying Go's Reproducible Builds](https://www.agwa.name/blog/post/verifying_go_reproducible_builds) -- _Andrew Ayer_

    Since Go toolchains were [introduced](https://go.dev/blog/rebuild) in 1.21,
    Go's builds have been byte-for-byte reproducible. This means that anyone can
    theoretically build Go from source and get the exact same binary as the
    official Go releases.

    Reproducible builds are useful for supply chain security because you
    can verify the entire build process. They can essentially do the same thing
    (and maybe even more) than provenance (like [SLSA](https://slsa.dev/))
    because you can independently verify the build process and the source code
    used to create the binary.

    Not many folks have done this however, so it's notable that Andrew is doing
    the work to independently verify Go's reproducible builds. The more folks do
    this, the more confidence we can have in the supply chain security of the Go
    runtime.

    Andrew runs [Source Spotter](https://sourcespotter.com/) to verify the Go
    toolchains and modules from the Go checksum database.

- [The Green Tea Garbage Collector](https://go.dev/blog/greenteagc) - _Michael Knyszek, Austin Clements_

    The Go team has been working on a new garbage collector called the Green Tea
    garbage collector. It's designed to improve overall GC performance by
    operating on memory pages rather than at the level of individual objects.

    The idea is simple. The goal is to have the GC scan sequential memory more
    often which is more likely to be in local CPU's cache (for NUMA
    architectures).

    The real-world results seem a bit mixed but overall positive so they plan to
    make it the default in Go 1.26. We'll see if that works out or gets pushed
    back.

## Programming

- [Scripts I wrote that I use all the time](https://evanhahn.com/scripts-i-wrote-that-i-use-all-the-time/) -- _Evan Hahn_

    This is a list of scripts that Evan wrote for himself. It seems like a mix
    of fairly useless, niche and specific to his workflow, and genuinely useful
    scripts.

    Some seemed like mostly useless wrappers. `jsonformat`, for example, wraps
    `jq` and pretty-prints JSON when you could just use `jq`. Also `length`
    which is just basically `wc -c`.

    Some like `radio` to play his favorite internet radio station is specific to
    his tastes, and not useful to me since I'm most often inside an `ssh`
    session anyway.

    But others seem genuinely useful. The `murder` script is a graceful
    terminator script which sends `SIGTERM` to a process, waits a bit, and then
    sends `SIGKILL` if the process is still alive. `waitfor` waits for a process
    to finish and then returns its exit code. It's not useful for me since I use
    servers that don't go to sleep, but it's notable that it makes efforts
    to keep the machine awake while waiting.

## Security

- [HTTPS by default](https://security.googleblog.com/2025/10/https-by-default.html) -- _Chris Thompson, Mustafa Emre Acer, Serena Chen, Joe DeBlasio, Emily Stark and David Adrian (Chrome Security Team)_

    Chrome is going to change the “Always Use Secure Connections” to be the
    default setting for public sites in Chrome 147 (April 2026), and extended to
    private sites in Chrome 154 (October 2026). This means it will warn you
    whenever it can't connect to a site over HTTPS.

    The biggest caveat is for internal sites that either don't have HTTPS or
    don't have a publicly trusted certificate with certificate transparency logs
    etc. Some folks have
    [complained](https://bsky.app/profile/apenwarr.ca/post/3m4dn6ygak22s) that
    they'd like to keep internal sites off of public transparency logs. So
    there's still a big open question about how to handle trust for private
    certificates.
