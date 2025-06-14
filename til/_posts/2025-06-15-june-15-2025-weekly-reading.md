---
layout: post
title: "TIL: June 15, 2025 - Weekly Reading: AI, Programming, and Life Lessons"
date: "2025-06-15 00:00:00 +0900"
blog: til
tags: AI programming learning
render_with_liquid: false
---

## Artificial Intelligence

- [AI Changes Everything](https://lucumr.pocoo.org/2025/6/4/changes/) - _Armin Ronacher_

    Armin seems very AI-positive. He now uses Claude Code and finds it
    significantly increases productivity by alternating between giving
    instructions and reviewing work. His optimistic outlook sees AI enhancing
    human capabilities rather than replacing people, potentially democratizing
    knowledge and accelerating innovation.

    While I can agree that AI is likely an irreversible change, I don't share
    his view that it won't replace people or that the job of programmer or
    designer won't go away. I think that largely using AI to write code will
    change the job of a programmer completely, and the skills required will be
    completely different.

- [GenAI Criticism and Moral Quandaries](https://lucumr.pocoo.org/2025/6/10/genai-criticism/) - _Armin Ronacher_

    This is a follow-up post by Armin in in response to a [post by Glyph](https://blog.glyph.im/2025/06/i-think-im-done-thinking-about-genai-for-now.html).
    While Grlyph is skeptical, Armin sees significant potential AI code
    generation when used properly. Armin seems to think that code review with AI
    is enjoyable and programming with AI assistance is still satisfying but I'm
    not so sure. I think programing will be totally different and we'll see a
    lot of churn with programmers as many who don't enjoy the new paradigm
    switch out to other jobs.

- [Using Claude Code to Migrate Wyvern Management Scripts](https://www.youtube.com/watch?v=HtqxI53h7zM) - _Steve Yegge, Gene Kim_

    Steve Yegge and Gene Kim have a vibe-coding sessions of Steve's game Wyvernn
    They use Claude to migrate the game's management scripts to Kotlin.

    While I think that many folks will feel like they are in control during
    vibe-coding sessions, much like folks using auto-pilot mode in a Tesla,
    folks won't be paying nearly as much attention as they think they are.

    [During the video](https://www.youtube.com/watch?v=HtqxI53h7zM&t=558s), Gene
    says "I assume you are being vigilant about what change is being made?" and
    Steve responds "Oh yeah, I know my code really well... I am reading all this
    code as we talk" like he understands everything that's going on, but then
    like a second later Claude asks if it should run the `kwyvern` command that
    just wrote and he's like "do you want to proceed? eeeeh, I don't know what
    this means but sure!". But Steve! I thought you were reading all that code!

## Programming

- [AI-assisted coding for teams that can't get away with vibes](https://blog.nilenso.com/blog/2025/05/29/ai-assisted-coding/) - _Atharva Raykar_

    Atharva provides a lot of helpful and practical tips on how to effectively
    use AI.

    The section on "Implications on how AI changes craft" particularly stood out
    to me. He notes that rewrites are now very cheap, and writing abstractions
    is now a lot less important. While, many programmers already overvalue
    abstractions to begin with, I think these kind of changes will result in
    code that is much less readable for humans.

- [How I program with Agents](https://sketch.dev/blog/programming-with-agents) - _David Crawshaw_

    David Crawshaw (ex(?)-CTO of Tailscale) discusses his approach to
    programming with AI agents. He provides a few examples of how he's used them
    in the past. One example that stood out was where the AI agent got confused
    at how used a non-standard way of encoding JSON in Postgres database tables.
    Their solution was to add comments to the code to help the AI agent but that
    programmers would likely skip over. I feel like we'll see a lot more code
    that includes instructions for AI agents in the future, which will make
    comments even more likely to be ignored by actual human programmers.

## Personal Development

- [25 things I know at 25](https://atharvaraykar.com/25-things-i-know-at-25/) - _Atharva Raykar_

    Atharva is the same author of article _AI-assisted coding for teams that
    can't get away with vibes_ listed above.

    This is a really great list of life lessons for someone still young enough
    to be this optimistic. I find myself to be a lot more cynical these days. I
    wish I was this self-aware when I was 25. I may not be now.

    Some of the lessons I wish I was better at:

    - _When trying to fix your health, start with fixing your sleep_: I think I
      need a lot more sleep than is really practical. I've been working on this
      for a while but it remains elusive.
    - _Never ever read the news. Pick up a history book instead_: Since COVID,
      I've found it impossible to avoid the news. TBQH, It really feels like
      everything is burning down all around us.
    - _The world is a malleable place for those who can think in systems.
      Learning to think in these terms will turn you into an optimist, whether
      you like it or not_: I really wish this was true for me. I think it's
      entirely possible for observed metrics (the aspects of life best improved
      by systems) to get better, but lived experience to get worse.
