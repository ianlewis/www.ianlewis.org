---
layout: post
title: "TIL: January 25, 2026 - Weekly Reading: AI, Security, and Programming"
date: "2026-01-25 09:00:00 +0900"
blog: til
tags: weekly-reading ai security programming golang
render_with_liquid: false
---

## Artificial Intelligence

- [Scaling long-running autonomous coding](https://cursor.com/blog/scaling-agents) -- _Wilson Lin_

    Wilson Lin at Cursor created a system with multiple LLM agents to build a
    functioning web browser. The approaches folks are starting to take is
    interesting. More researchers are starting to explore ways to make LLMs
    generate systems more autonomously using multiple agents serving in
    different roles, and coordinating their efforts. Simon Willison [recently
    wrote](https://simonwillison.net/2026/Jan/19/) about building it and giving
    it a try.

    Wilson created a system with "planners" and "workers". The planners
    continuously read the code and create tasks and can spawn "sub-planners",
    while workers execute the tasks.

    This reminds me of the [Ralph Wiggum](https://ghuntley.com/ralph/) idea
    (there's an ["official" Claude-code plugin
    implementation](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/ralph-loop)
    and another implementation by Frank Bria on [on
    Github](https://github.com/frankbria/ralph-claude-code)). It also reminds me
    of the [Gas
    Town](https://steve-yegge.medium.com/welcome-to-gas-town-4f25ee16dd04)
    project by Steve Yegge. Both of these seemed like very fantastical ideas
    at first but Wilson's project grounds it a bit more for me.

## AI & Security

- [Claude Cowork Exfiltrates Files](https://www.promptarmor.com/resources/claude-cowork-exfiltrates-files) -- _PromptArmor_

    This is another example of how LLM agents can be manipulated to exfiltrate
    data they shouldn't have access to. What I think is interesting in this case
    is that Claude Cowork is apparently run in a sandboxed VM environment with
    restricted network access.

    The attacker was still able to get it to exfiltrate files by getting Claude
    to swap out the user's API key for their own, and upload the file to their
    Anthropic account instead of the user's.

    I've long thought that agents should be run in sandboxed environments with
    restricted access to resources, but this reminds us that even sandboxing
    isn't a silver bullet. Attackers will find ways to exploit them anyway,
    especially if we routinely give them powerful access to sensitive data.

    You can read my notes on
    [Readwise](https://readwise.io/reader/shared/01kf0hym5239cevsbjjc8ghsw1).

## Programming

- [Finding and Fixing a 50,000 Goroutine Leak That Nearly Killed Production](https://skoredin.pro/blog/golang/goroutine-leak-debugging) -- _Serge Skoredin_

    This is a write-up and a good reminder that good hygiene regarding
    goroutines is critical to keeps systems stable. I wrote about several of
    these issues before in my post
    [_Four Tips for Writing Better Go
    APIs_](https://www.ianlewis.org/en/four-tips-for-writing-better-go-apis).

    One thing the author points out is how writing to unbuffered channels with
    no readers can block an application. While this is true, it's also true for
    buffered channels when the buffer is full so it only delays the inevitable.
    You still need to clean up the channel or it will block eventually.

    The article also brings up the
    [`go.uber.org/goleak`](https://github.com/uber-go/goleak) package. I haven't
    used this before but it seems really useful for writing tests to help ensure
    you don't leak goroutines.

    You can read my notes on
    [Readwise](https://readwise.io/reader/shared/01kfc7tx21phw54h2xc8qb1dsh).
