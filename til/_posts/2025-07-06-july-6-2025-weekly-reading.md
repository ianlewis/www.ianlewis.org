---
layout: post
title: "TIL: July 6, 2025 - Weekly Reading: AI, Go's greentea GC, and OSS Security"
date: "2025-07-06 00:00:00 +0900"
blog: til
tags: AI go security weekly-reading
render_with_liquid: false
---

<!-- markdownlint-disable MD041 -->

## Artificial Intelligence

<!-- markdownlint-enable MD041 -->

- [Who are your MCP servers talking to?](https://dev.to/stacklok/who-are-your-mcp-servers-talking-to-1m5e) - _Stacklok_

    Stacklok introduces their project
    [`toolhive`](https://github.com/stacklok/toolhive) which is a project that
    runs MCP servers in containers with strict network policies to prevent MCP
    servers from leaking sensitive information.

    While I think that MCP servers should probably be run with strict network
    policies to prevent them from exfiltrating data or interfering with each
    other, they are generally aren't LLMs themselves and are just regular API
    servers. So far many of the attacks [rely on running untrusted MCP servers
    alongside trusted
    ones](https://invariantlabs.ai/blog/whatsapp-mcp-exploited). Very little,
    nothing is going to save you from running untrusted code on your machine no
    matter what you do.

    The real danger it seems to me is the MCP clients themselves which rely on
    LLMs and are running command willy-nilly on your machine with your local
    permissions.

- [Tools: Code Is All You Need](https://lucumr.pocoo.org/2025/7/3/tools/) -- _Armin Ronacher_

    Armin discusses how he's not a fan of MCP (Model Context Protocol) servers
    because they rely on the LLM to filter large amounts of information down to
    produce the right result. He seems to propose that the agent the generate
    one-off code and presumably run it to accomplish the task. He compares this
    to the old adage "replace yourself with a shell script" with the caveat that
    previously you would automate things you did all the time, whereas now LLMs
    allow you to generate code for one-off tasks that you might not do over and
    over again.

- [AI Is Better at Maintaining Docs Than Humans](https://dosu.dev/blog/ai-is-better-at-maintaing-docs-than-humans) -- _Devin Stein_

    This post proposes that AI should be used to keep documentation more up to
    date than humans can. The idea is that documentation often falls behind as
    the code changes and AI could be used to automatically update the
    documentation to match the code.

    I'm highly skeptical that AI should be relied upon to maintain documentation
    in a truly automated way. I think it could be used in an automated way to
    automatically create draft PRs that propose documentation updates based on
    code changes. That way, figuring out what documentation needs to be updated
    could be more easily managed. But I think humans should really be ultimately
    responsible for the final results.

## Go

- [Read/Write/Nil with Michael Knyszek and Michael Pratt](https://sigpod.dev/6) -- _Significant Bits_

    This is a cool podcast which is new to me. It features Michael Knyszek and
    Michael Pratt discussing development of the Go runtime and a performance bug
    in the new experimental "greentea" garbage collector. Due to some esoteric
    issues the new runtime caused a large number of pagefaults for new memory and
    greatly decreased performance for programs that allocate a lot of new memory
    and throw it away.

## OSS Security

- [Open Source Security work isn't “Special”](https://sethmlarson.dev/security-work-isnt-special) -- _Seth Michael Larson_

    Seth Michael Larson is the maintainer of the `urllib3` Python library. I've
    worked with Seth when he was implementing SLSA provenance generation support
    for `urllib3`. He's a rare maintainer who is serious about security of his
    projects.

    Seth argues for a model of open source security work where "trusted
    individuals" are given authority to do security work on a project without
    necessarily being a project maintainer. It seems to suggest that certain OSS
    "security contributors" specialize in security and cover many projects. I
    think this sounds reasonable, but I wonder if doing security work wouldn't
    require more detailed knowledge of the project than the security
    contributors would be able to have as a non-maintainer.

## Continuous Integration

- [A Lightweight Merge Queue using GitHub Actions](https://sketch.dev/blog/lightweight-merge-queue) -- _Philip Zeyliger, Josh Bleecher Snyder_

    This post describes a simple alternative workflow to the [GitHub merge
    queue](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/configuring-pull-request-merges/managing-a-merge-queue)
    that doesn't require you to create pull requests. It basically involves
    pushing to a specific branch that triggers a GitHub Actions run that merges
    the changes and force pushes them to the main branch.

    This post was interesting to me because the GitHub Actions merge queue has
    been unusable for a long time for me due to an
    [issue](https://github.com/github/codeql-action/issues/1572) with CodeQL that
    prevents it from reporting scanning results.

    The main issue I have with this solution and others that merge
    dependabot/renovate PRs is that it requires giving GitHub Actions jobs the
    `contents: write` permission allowing it automatically push **any** changes
    to a repository. I think it might be satisfactory for jobs where you
    strictly control all of the code, but I don't think it's a good practice to
    give third party actions this permission. Another issue I have with this
    approach is that it requires you to bypass branch protection checks in your
    GitHub Actions workflow.
