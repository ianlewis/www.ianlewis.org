---
layout: post
title: "TIL: August 10, 2025 - Weekly Reading"
date: "2025-08-10 00:00:00 +0900"
blog: til
tags: weekly-reading
render_with_liquid: false
---

## Artificial Intelligence

- [Enough AI copilots! We need AI
  HUDs](https://www.geoffreylitt.com/2025/07/27/enough-ai-copilots-we-need-ai-huds)
  -- _Geoffrey Litt_

    Geoffrey Litt writes that, rather than conversational AI agents that talk to
    you and grab your attention, we should create improved interfaces that
    enhance existing abilities. This resonates with the "bicycle for the mind"
    idea of computing.

    I like the idea of enhancing existing abilities because I think that natural
    language has it's limitations and is a pretty high bandwidth interface.
    There are much better ways to interact that convey much more information
    more quickly than text in most situations.

    As an example of a "copilot" interface that should be avoided, the post
    makes the unfortunate choice of an agent that helps avoid collisions by
    alerting the pilot with something like “collision, go right and down!”. This
    is a pretty poor example, because this describes the existing TCAS/ACAS
    mid-air collision avoidance systems that are actually very helpful for
    critical safety situations in a complex environment. There HUDs also have
    their limits due to the complexity and time-sensitivity of that environment.
    I think the answer for this situation is to have both a copilot and an
    improved interface.

## Security

- [HTTP/1.1 Must Die](https://http1mustdie.com/) -- _James Kettle_

    HTTP/1.1 has had issues with HTTP request smuggling attacks for a while, but
    James Kettle argues that the protocol is inherently insecure and should be
    deprecated. I'm not sure I agree that it's unfixable, but I do think these
    kind of attacks should be taken more seriously.

    If HTTP/1.1 really isn't worth it to keep around, then I think it's a sad
    day for the web. HTTP/2 does offer a lot of advantages, but it's much more
    complicated and harder to implement correctly.

<!-- FIXME: He will be giving a talk on new desync attacks on Aug 7 so I
  should include info on that here. -->

- [HTTP Desync Attacks: Request Smuggling
  Reborn](https://portswigger.net/research/http-desync-attacks-request-smuggling-reborn)
  -- _James Kettle_
