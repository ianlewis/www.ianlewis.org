---
layout: post
title: "TIL: September 29, 2025 - Weekly Reading: Security, Programming, and AI"
date: "2025-09-29 08:00:00 +0900"
blog: til
tags: weekly-reading
render_with_liquid: false
---

## Security

- [From MCP to Shell](https://verialabs.com/blog/from-mcp-to-shell/) -- _Stephen
  Xu, Cayden Liao, Raymond, Jayden_

    Yet another method for exploiting Model Context Protocol (MCP) servers to
    get arbitrary code execution on the local machine. This seems to be mostly
    an issue for remote MCP servers since a malicious MCP servers installed
    locally would just be able to run arbitrary code anyway.

    In this case it's a fairly straightforward vulnerability due to lack of
    OAuth redirect URL validation. But I think it's going to be pretty hard to
    securely use MCP servers in general. MCP servers will be able to return
    content that can cause the client to try to execute commands locally by
    design. Clients like Claude Code will ask users to approve the command but I
    think this is a fairly weak security measure.

- [uv security advisory: ZIP payload
  obfuscation](https://astral.sh/blog/uv-security-advisory-cve-2025-54368) --
  _William Woodruff_

    A security vulnerability (CVE-2025-54368) was found in `uv` that allows
    malicious ZIP files to be crafted in a way that makes different tools
    extract different content from the ZIP archive.

    The vulnerability takes advantage of an ambiguities in the ZIP file format
    specification, which allows for multiple ways to parse a ZIP file and
    extract its contents.

## Programming

- [(1\*2)/2 = 2/2 = 1](https://samwho.dev/big-o/) -- _Sam Rose_

    This is a fun article that explains the concept of Big-O notation with cool
    visualizations and simple examples. It covers the basics of time complexity,
    common Big-O notations, and goes over some examples using some simple
    sorting and searching algorithms.

- [Default Methods in Go](https://mcyoung.xyz/2025/08/25/go-default-methods/) --
  _Miguel Young de la Sota_

    Miguel points out that, due to how Go's interfaces work, it's not easy to
    create default methods for interface types that can be inherited by their
    implementing types.

    He also brings up that to cast an interface to another interface, the
    runtime must check that all the methods of the target interface are
    implemented by the original interface. This results in an `O(n)` operation,
    where `n` is the number of methods in the target interface.

    I think this is a good point to consider when designing APIs in Go.
    Overreliance on interfaces can lead to performance issues and code that's
    difficult to maintain. Since the Go community generally prefers to maintain
    backwards compatibility it's a good idea to think about the long-term
    implications of interface design up front.

- [Shopify, pulling strings at Ruby Central, forces Bundler and RubyGems
  takeover](https://joel.drapper.me/p/rubygems-takeover/) -- _Joel Drapper_

    After David Heinemeier Hansson (DHH) was given a keynote slot at RailsConf
    2025, Sideqik withdrew their $250k/year sponsorship of Ruby Central. That
    left Ruby Central heavily reliant on Shopify for funding. Shopify smelled
    blood in the water and decided to leverage their position to instigate a
    takeover of Ruby Central as well as the RubyGems and Bundler projects. Long
    time contributors were locked out of the projects (at least temporarily),
    with some, like the original author of Bundler André Arko, singled out to be
    removed permanently.

    RubyGems and Bundler are supposed to be community-driven projects separate
    from Ruby Central but their repositories are in the `rubygems` GitHub
    organization that's controlled by Ruby Central. This allowed for the full
    take over from the organization level. I'm not sure how well they have been
    covering themselves legally but it's hard for me to imagine Shopify's
    lawyers approving of this kind of thing without legal rationale. All around,
    this is a terrible look for Shopify and Ruby Central.

## Artificial Intelligence

- [I Can Spot AI Writing Instantly — Here’s How You Can
  Too](https://www.youtube.com/watch?v=9Ch4a6ffPZY) -- _Evan Edinger_

    This is a fun video about how to spot AI-generated writing. It's good to
    think about these things if you use AI to help you write so you don't sound
    too drab or robotic.
