---
layout: post
title: "TIL: March 16, 2026 - Weekly Reading"
date: "2026-03-16 09:00:00 +0900"
blog: til
tags: weekly-reading
render_with_liquid: false
---

## Artificial Intelligence & Software Development

- [How to Kill the Code Review](https://www.latent.space/p/reviews-dead) -- _Ankit Jain_

    This post argues that humans can't keep up with reviewing the amount of code
    that agents are producing so we should give up and just not review code at
    all. Agents are unreliable and they are writing the code in the first place
    so we should just not review.

    Instead, Ankit argues, we should put up "deterministic guardrails" to verify
    that the code being produced is correct. His idea is that these guardrails
    should come in the form of "acceptance criteria" that takes the form of
    English text that agents use to verify the code that was produced.

    I can't tell you how wrong I think this is. Agents are going to be bad a
    code review so we shouldn't do it but instead use them to verify some vague
    acceptance criteria? Humans apparently shouldn't care at all about the code,
    only the "intent", but we're also supposed to be able to handle important
    areas like auth or modifying database schemas should be handled by humans.

    I think the end result will be that the engineers aren't going to have any
    idea how the system works, there will be huge churn, and thinks will break
    often due to vague acceptance criteria. Any escalations will be exactly the
    kind of rubber-stamp reviews that Ankit thinks are a waste of time.

    My notes are on
    [Readwise](https://readwise.io/reader/shared/01kk7z9k5n38wcccad3ez9we1h).

## How AI Shapes Our Thinking

- [Three more AI psychoses](https://readwise.io/reader/shared/01kkkb814es3damyep24h6c843) -- _Cory Doctorow_

    Cory Doctorow, as always, does an excellent job of putting the anxiety many
    of us feel about AI into words. He mentions three "AI psychoses" that people
    are experiencing: the investor delusion, the boss delusion, and the critic
    delusion.

    The investor delusion doesn't seem specific to AI. It seems to describe the
    normal hype cycles that we see with new technologies. AI is just bigger
    scale and has worse unit economics.

    The boss delusion is specific to AI and describes the delusional zeal that
    bosses have to use AI to replace their employees.

    The critic delusion is also specific to AI and describes the way folks think
    everything that has to do with AI _must_ be immoral in some way because the
    people creating and promoting it are immoral.

    [This reaction thread](https://hachyderm.io/@glyph@mastodon.social/116220202809001014)
    by Glyph (author of the [Twisted](https://twisted.org/) Python library) is
    pretty good. He points out that much of the changes that AI will cause in
    people's thinking will fly under the radar compared to the extreme "AI
    psychosis" delusions people have.

    My notes are on
    [Readwise](https://readwise.io/reader/shared/01kkkb814es3damyep24h6c843).

- [AI autocomplete doesn’t just change how you write. It changes how you think](https://www.scientificamerican.com/article/ai-autocomplete-doesnt-just-change-how-you-write-it-changes-how-you-think/) -- _Claire Cameron, Scientific American_

    This article cites recent research showing that AI generated text can
    influence how people respond when entering their views in a survey. It's
    pretty concerning how AI can influence people's opinions. People seem to
    resist changing their opinion when it's another person trying to influence
    them but they seem to think of AI more like a neutral tool without biases.
    This is even when they are warned that the AI could be biased.

    My notes are on
    [Readwise](https://readwise.io/reader/shared/01kkkb4hptvfth6zkym0mwjpdb).

## The `go fix` tool in Go 1.26

- [Using `go fix` to modernize Go code](https://go.dev/blog/gofix) -- _Alan Donovan, the Go team, Google_

    The `go fix` command was introduced _way_ back in Go r59 (pre 1.0) as a
    way to automatically update Go code to modernize it with changes to APIs and
    new features.

    Go 1.26 includes a rewrite of `go fix` using the new [Go analysis
    framework](https://pkg.go.dev/golang.org/x/tools/go/analysis) with includes
    a full framework for writing reusable analyzers for Go code.

    This is a really cool tool and I've noticed that many of the existing
    `staticcheck` analyzers that suggest code modernizations have been really
    useful for me when programming. I look forward to using this a lot more in
    the future.

    My notes are on
    [Readwise](https://readwise.io/reader/shared/01khpmfp0tkvmf4z2c19yvgpj5).

- [`//go:fix inline` and the source-level inliner](https://go.dev/blog/inliner) -- _Alan Donovan, the Go team, Google_

    The `//go:fix inline` directive is a new feature in Go 1.26 that allows
    developers to write custom inlining rules for their code. These rules are
    mostly intended to replace deprecated function calls with new, more modern
    code, rather than for performance reasons.

    This seems pretty useful for providing hints on how to automatically
    modernize calls to deprecated functions. However, it's going to be limited to
    function calls, and won't be able to arbitrarily apply code suggestions.

    My notes are on
    [Readwise](https://readwise.io/reader/shared/01kkhv9hzap69qw1je11b9ge09).
