---
layout: post
title: "TIL: February 9, 2026 - Weekly Reading: AI Agents & Empathy, More Moltbook"
date: "2026-02-09 09:00:00 +0900"
blog: til
tags: weekly-reading ai security
render_with_liquid: false
---

## Open Source & Security

- [Building cryptographic agility into Sigstore](https://blog.trailofbits.com/2026/01/29/building-cryptographic-agility-into-sigstore/) -- _Trail of Bits_

    Trail of Bits recently improved Sigstore by adding the ability to use more
    algorithms for signing and hashing. I think the main motivation for this is
    to support compliance requirements that mandate certain algorithms. They did
    it in a smart way by only allowing specific suites of algorithms to prevent
    users from picking insecure algorithm combinations and to prevent algorithm
    confusion attacks.

    My notes are on
    [Readwise](https://readwise.io/reader/shared/01kge8k0c64gp50jac313nczgk).

## AI

- [Is the Detachment in the Room? - Agents, Cruelty, and Empathy](https://hailey.at/posts/3mear2n7v3k2r) -- _Hailey_

    Hailey created an AI agent called Penny which they have been operating as a
    social experiment. Apparently some people on social media responded to
    interactions with them with slurs and saying they should commit suicide.

    The main gist of the post is that treating agents poorly is socially
    unhealthy because it follows the same patterns used to dehumanize real
    people.

    I think the social experiment of Penny is at least as interesting as the
    intended topic. Hailey teaching Penny things like social boundaries reminds
    me a lot of the Star Trek: The Next Generation episode [The
    Offspring](<https://memory-alpha.fandom.com/wiki/The_Offspring_(episode)>)
    where Data creates a "daughter" named Lal. The dogpile episode also reminded
    me of the interactions between Lal and the other children at school.

    I'd like to try to make an agent myself sometime. However, I have a lot to
    do in the short term, including building a new home lab, so I'm not sure
    when I'll find the time.

    My notes are on
    [Readwise](https://readwise.io/reader/shared/01kgvzd3rc388pc4gm5xpjpsjv)

## AI & Security

- [OpenClaw (a.k.a. Moltbot) is everywhere all at once, and a disaster waiting to happen](https://garymarcus.substack.com/p/openclaw-aka-moltbot-is-everywhere) -- _Gary Marcus_

    Another post about OpenClaw and how it's a security nightmare. It touches a
    bit on what I think is the biggest architectural mistake of these systems
    -- the fact that they run as you with your identity rather than their own.

    It also touched on something that was new to me. The fact that Moltbook
    might have more human-posted content meant to look like bot-created content.
    Some folks could be intentionally putting up some wild stuff to troll people
    who are thinking it's a bot.

    My notes are on
    [Readwise](https://readwise.io/reader/shared/01kgddf3886htrfrzx3c8v8kj9).

## Open Source

- [Anki’s Growing Up](https://forums.ankiweb.net/t/ankis-growing-up/68610) -- _Damien Elmes_

    Damien Elmes, the creator of Anki, has decided to step back from the project
    and hand over the project to the folks at
    [AnkiHub](https://www.ankihub.net/). Damien has been working on Anki for
    almost 20 years and I'm sure the project has been pretty demanding on him.

    I've been an Anki user for pretty much that entire time and I'm grateful for
    Damien's work. I started using Anki almost as soon as it was initially
    released. I was a regular in the `#japanese` channel on
    [Freenode](https://freenode.net/) back in the early 2000s before moving to
    Japan. One of the other regulars, David Smith, had created a spaced
    repetition flashcard program for Emacs. David was also a big
    [Pylons](https://pylonsproject.org/) fan. That inspired Damien to create
    Anki as a client application using Python with a sync server written with
    Pylons.

    I hope the project continues to thrive under the new leadership.
