---
layout: post
title: "TIL: Apr 29, 2025 - Weekly Reading: Go ABI/GC hacks and MCP"
date: "2025-04-29 00:00:00 +0900"
blog: til
tags: learning programming weekly-reading
render_with_liquid: false
---

These are some of the things I was reading this last week or so.

## Programming

- [Cheating the Reaper in Go - mcyoung](https://mcyoung.xyz/2025/04/21/go-arenas/)

    This is an good post that build's on Miguel's previous post [Things You
    Never Wanted To Know About Go
    Interfaces](https://mcyoung.xyz/2024/12/12/go-abi/). It discusses how to
    implement an "arena" in Go, which is a memory management data structure that
    is useful for assigning objects to a specific region in memory which can be
    allocated and freed all at once when it's no longer needed.

    I hadn't heard of this data structure before, but it might be fun to try to
    implement in Rust later.

## Model Context Protocol

- [Introducing the Model Context Protocol](https://www.anthropic.com/news/model-context-protocol) - Anthropic

    This is a blog post introducing Anthropic's Model Context Protocol (MCP).
    It's used to allow you to set up data sources that can then be used to
    provide data to a AI model via a prompt's context. MCP allows models to have
    a unified API to get data rather than having to build custom integrations
    for each data source.

    There are a bunch of reference [MCP server
    implementations](https://github.com/modelcontextprotocol/servers) for things
    like git repositories, databases, etc. These servers seems a lot like LSP
    servers in how they could be used; at least by programmers for coding.

- [pprofの結果を出力するMCPサーバーを作って自律的にパフォーマンス改善を行う](https://blog.yudppp.com/posts/pprof-mcp-agent)
  (Japanese) - yudppp

    One related project that caught my eye was
    [`pprof-mcp-agent`](https://github.com/yudppp/pprof-mcp-agent) which is a
    MCP server that can be used to analyze performance Go programs by providing
    pprof profiles to AI models.

- [A Deep Dive Into MCP and the Future of AI
  Tooling](https://a16z.com/a-deep-dive-into-mcp-and-the-future-of-ai-tooling/) - Yoko Li (a16z).

    I'm not a big fan of Andreessen Horowitz, but this is a good overview of MCP
    and how it was indeed inspired by LSP. It does a much better job than the
    Anthropic post of explaining the motivation behind MCP and showing some
    examples of how it could be used.

    It does indeed seem pretty powerful but I'm kind of skeptical when a VC
    company gets this excited about a technology. The kind of data that a AI
    model company could hoover up from MCP servers seems pretty scary to me.

- [AI Model Context Protocol (MCP) and
  Security](https://community.cisco.com/t5/security-blogs/ai-model-context-protocol-mcp-and-security/ba-p/5274394a) - Omar Santos (Cisco)

    This post outlines some of the security risks of using MCP servers. Since
    MCP servers can do just about anything there is a real risk of inadvertently
    doing something you didn't intend to do. I'm not sure how prevalent
    fine-grained access control is in the MCP server implementations, but it
    seems like it would be a good idea if you could restrict the server to only
    a subset of what it's actually capable of doing.
