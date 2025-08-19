---
layout: post
title: "TIL: July 23, 2025 - Weekly Reading: AI, Go, and Security"
date: "2025-07-23 00:00:00 +0900"
blog: til
tags: ai security weekly-reading
render_with_liquid: false
---

## Artificial Intelligence

- [AI Engineer World's Fair: The New
  Code](https://www.youtube.com/watch?v=8rABwKRsec4) -- _Sean Grove, OpenAI_

    I felt very weird watching this talk. It suggests a lot of things that are
    very unproductive like storing prompts in source control instead of code. Sean
    says that code is a lossy projection of the specification, but I'd suggest
    it's actually the other way around. The specification necessarily omits
    details that are important, but not relevant at the specification level. If
    you did include that granularity, then prompts would be no different than
    code, and AI would be a terrible way to turn it into an executable format.

    I did like the idea of writing a specification that can be used to inform the
    AI about what the system should do. However, I think these documents should be
    primarily for humans to understand, with the AI being able to understand as a
    by-product, rather than AI's being the primary audience.

- [Don’t Let Your AI Go Rogue: Securing Database Tools with MCP
  Toolbox](https://medium.com/google-cloud/dont-let-your-ai-go-rogue-securing-database-tools-with-mcp-toolbox-dab9a53dd6a0)
  -- _Kurtis Van Gent, Google_

    I like that MCP toolbox is a library for creating MCP "tools" for databases.
    This allows you to create only the tools you need rather than giving the AI
    full access to run SQL on the database. This is important for security and
    overall data safety. No one wants AI to deleted their production database,
    amirite?

    I think this is another example of creating bespoke tools for AI, similar to
    [bespoken](https://koaning.github.io/bespoken/) that I wrote about in a
    previous weekly reading.

## Go

- [What's //go:nosplit for?](https://mcyoung.xyz/2025/07/07/nosplit/) -- _Miguel
  Young de la Sota_

    A detailed look at Go's `//go:nosplit` directive, which prevents the Go
    runtime from splitting a function's stack frame. This is useful for
    low-level operations where you want to ensure that the function does not
    yield control back to the Go scheduler, such as in signal handlers or
    certain performance-critical code paths.

    This unfortunately leads to bad runtime behavior in many edge cases,
    including some segfaults. It's basically a way to write unsafe code without
    importing the `unsafe` package so it's a bit of a hack. It should only be
    used if you really know what you're doing, review the code very
    carefully, and have good unit tests around it to catch changes in runtime
    behavior.

## Security

- [Scorecarding Security](https://ramimac.me/scorecarding) - _Rami McCarthy, Wiz_

    This blog post from Rami McCarthy (not at Wiz when the post was written, but
    now at Wiz) discusses the security scorecarding in organizations. I think
    the takeaway is not so much about scorecarding itself, but rather the
    importance of building relationships with engineering teams and collecting
    security indicators.

    Relationships help build trust and help engineering teams understand the
    importance of security. Security teams can provide resources and tools to
    engineering teams to help build that trust.

    Security indicators can help teams improve their security posture and
    help the security team prioritize where to allocate resources.

    I'm a bit upset that Rami didn't include anything on Open Source development
    and [OpenSSF Scorecard](https://openssf.org/projects/scorecard/). It
    incorporates many of the ideas he mentioned like getting indicators from
    security vulnerabilities, code quality, and more.
