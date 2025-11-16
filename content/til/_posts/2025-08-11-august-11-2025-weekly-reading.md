---
layout: post
title: "TIL: August 10, 2025 - Weekly Reading: AI, HTTP/1.1 request smuggling, and Life Advice"
date: "2025-08-10 00:00:00 +0900"
blog: til
tags: weekly-reading ai security
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
    language has its limitations and is a pretty high bandwidth interface. There
    are much better ways to interact that convey much more information more
    quickly than text in most situations.

    As an example of a "copilot" interface that should be avoided, the post
    makes the unfortunate choice of an agent that helps avoid collisions by
    alerting the pilot with something like “collision, go right and down!”. This
    is a pretty poor example, because this describes the existing TCAS/ACAS
    mid-air collision avoidance systems that are actually very helpful for
    critical safety situations in a complex environment. These HUDs also have
    their limits due to the complexity and time-sensitivity of that environment.
    I think the answer for this situation is to have both a copilot and an
    improved interface.

- [Good context leads to good code: How we built an AI-Native Eng
  Culture](https://blog.stockapp.com/good-context-good-code/) -- _StockApp_

    This post has some interesting ideas about how to best make use of AI in
    your engineering culture. It echos the idea of writing more documentation,
    specifications, and design docs directly in your repository and maintaining
    them in a mono-repo. This was touched on in the AI Engineer World’s Fair
    talk [The New Code](https://www.youtube.com/watch?v=8rABwKRsec4) by Sean
    Grove at OpenAI that I mentioned in a [previous weekly
    reading](/til/2025/07/22/july-23-2025-weekly-reading).

- [No, AI is not Making Engineers 10x as
  Productive](https://colton.dev/blog/curing-your-ai-10x-engineer-imposter-syndrome/)
  -- _Colton Voege_

    This is a really down-to-earth post about AI that really resonates with me.
    There just seems to be a lot of echo-chamber-like hype around AI written by
    people whose motivations are to sell AI products or services, or to expand
    their social media profile. This post links the supposed AI productivity
    gains to the "10x engineer" myth. AI may help you be more productive, but
    it's likely more of a 1.05x-1.15x increase, not a 10x increase.

    To be fair, providing a 1.15x productivity increase to customers would still
    be a huge deal. It's likely worth hundreds of millions or even billions of
    dollars, but it's not the crazy disruptive change folks have been expecting
    it to be.

## Security

- [HTTP/1.1 Must Die](https://http1mustdie.com/) -- _James Kettle_

    HTTP/1.1 has had issues with HTTP request smuggling attacks [for a
    while](https://portswigger.net/research/http-desync-attacks-request-smuggling-reborn)
    but James Kettle argues that the protocol is inherently insecure and should
    be deprecated. He released more novel attacks for HTTP/1.1 this week in the
    white paper [<!-- textlint-disable spelling -->_HTTP/1.1 must die: the desync
    endgame_<!--textlint-enable spelling -->](https://portswigger.net/research/http1-must-die).

    I'm not sure I agree that it's totally unfixable, but I do think these
    kind of attacks should be taken more seriously.

    If HTTP/1.1 really isn't worth it to keep around, then I think it's a sad
    day for the web. HTTP/2 does offer a lot of advantages, but it's much more
    complicated and harder to implement correctly. That said, these attacks can
    only be prevented on HTTP/1.1 by implementing the protocol in a consistent
    way across all servers and clients, which is a really tall order.

## Life Advice

- [40 Harsh Truths I Wish I Knew In My 20s](https://www.youtube.com/watch?v=w39A92UzTDY) -- _Daniel Pink_

    I'm not in my 20s but I still found this video to be helpful. Most of the
    40 "truths" are short pithy statements, but are still worth thinking about
    how to apply them to your own life. I found myself nodding along and
    agreeing with most of them but had some thoughts about others. I think it's
    just a good seed to get you thinking about your strengths and weaknesses and
    how to improve yourself.
