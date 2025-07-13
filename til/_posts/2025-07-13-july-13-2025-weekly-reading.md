---
layout: post
title: "TIL: July 13, 2025 - Weekly Reading, MCP Server security, Bespoke Agents"
date: "2025-07-13 00:00:00 +0900"
blog: til
tags: ai weekly-reading
render_with_liquid: false
---

## MCP Server security

- [Getting Authentication Right is Critical to Running MCP
  Servers](https://dev.to/stacklok/getting-authentication-right-is-critical-to-running-mcp-servers-39fk)
  -- _Juan Antonio Osorio, Stacklok_

    After finding out about ToolHive last week, I took a closer look at it this
    week. Authentication, Authorization, and secrets management are probably the
    areas where ToolHive brings the most value. Without something like ToolHive,
    each MCP server has to implement it themselves, and your security is left at
    the mercy of each MCP server's implementation.

- [Secure-by-Default Authorization for MCP Servers powered by
  ToolHive](https://dev.to/stacklok/secure-by-default-authorization-for-mcp-servers-powered-by-toolhive-1hp6)
  -- _Juan Antonio Osorio, Stacklok_

    ToolHive's authorization system isn't what I initially expected. I expected
    that ToolHive would help manage OAuth2/OIDC tokens for MCP servers that need
    to authenticate with OAuth2 APIs. Instead it seems to only really have
    support for storing secrets that can be [passed to MCP servers via
    environment
    variables](https://github.com/stacklok/toolhive/blob/8b7bbe06548128f3b0cec2c0876f1dfefe28cb6c/pkg/registry/data/registry.json#L19-L24).

    Instead, ToolHive provides an authorization system for invoking individual MCP
    "tools" that can be controlled via a policy file written using the [Cedar
    policy language](https://www.cedarpolicy.com/). I assume this will be useful
    to some folks but I am at a loss to imagine what situations writing policy
    over MCP tools would be the right solution rather than authorization on at
    backend API level.

- [Docker Brings Compose to the Agent Era: Building AI Agents is Now
  Easy](https://www.docker.com/blog/build-ai-agents-with-docker-compose/) --
  _Docker_

    Docker is trying to make it easier to run AI agents and their associated MCP
    servers using Docker Compose. This makes sense to me because Docker Compose
    is good for orchestrating multiple containers that run together on the same
    machine.

    Docker is also creating an MCP server registry called [MCP
    Catalog](https://www.docker.com/products/mcp-catalog-and-toolkit/). This
    helps solve the problem of finding and installing MCP servers, while also
    signing and providing provenance for the MCP servers to improve security.
    ToolHive is also trying to solve this problem, and while it seems like
    Docker's solution is currently more sophisticated, Docker's MCP Catalog
    seems to only support Docker for desktop at the moment.

- [The Security Risks of Model Context Protocol
  (MCP)](https://www.pillar.security/blog/the-security-risks-of-model-context-protocol-mcp)
  -- _Pillar Security_

    This is a article from a few months ago that talks about some of the
    security issues with MCP servers. It highlights some of the issues that some
    tools like ToolHive and Docker are trying to solve. Unfortunately, many of
    the issues aren't easily solved. Prompt/Command injection is going to
    continue to be a problem, though it's somewhat mitigated by isolating MCP
    servers from each other and from the host system.

- [MCP Security Exposed: What You Need to Know
  Now](https://live.paloaltonetworks.com/t5/community-blogs/mcp-security-exposed-what-you-need-to-know-now/ba-p/1227143)
  -- _Palo Alto Networks_

    This article mentions many of the same issues, but also highlights trust
    issues with MCP servers. Things like MCP server provenance will be important
    since they will get powerful access and folks are not likely to audit them
    before installing them on their system. ToolHive and Docker's MCP Catalog
    are both trying to solve this problem with their MCP server registries.

    Another interesting point is the idea of "consent fatigue" in which an MCP
    server could continually ask for access to fatigue them and get them to
    grant more access then they would otherwise.

- [Model Context Protocol: Security Best
  Practices](https://modelcontextprotocol.io/specification/2025-06-18/basic/security_best_practices)
  -- _Anthropic_

    This is the official security best practices for MCP servers. It mostly
    focuses on session hijacking attacks and mitigation.

## Bespoke Agents

- [Introducing bespoken](https://koaning.io/posts/introducing-bespoken/)
  -- _Vincent D. Warmerdam_

    Bespoken is a neat tool that allows you to create a "bespoke" AI agent
    providing the agent access only to the local tools it needs. It's a neat
    framework that might be useful for creating some bespoke tools.

    Outside of some very specialized tooling, I think that agents should not be
    given access to anything and should be required to go though specifically
    registered and authorized MCP servers for all outside interaction.
