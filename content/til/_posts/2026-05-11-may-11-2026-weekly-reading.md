---
layout: post
title: "TIL: May 11, 2026 - Weekly Reading: Abstractions, Chrome's Prompt API, and GitHub's Unreliability"
date: "2026-05-11 09:00:00 +0900"
blog: til
tags: weekly-reading programming ai
render_with_liquid: false
---

## Abstractions and Where They Fail

- [<!-- textlint-disable spelling -->The 'Hidden' Costs of Great Abstractions<!-- textlint-enable spelling -->](https://jdgr.net/the-hidden-costs-of-great-abstractions) -- _James Ludwell-Grymes_

    James brings up an "obvious" point that AI is an abstraction (I'd say it's
    almost the ultimate abstraction), including the downside of other
    abstractions; that they hide important details about the underlying
    implementation.

    Folks often [vibe-code](https://en.wikipedia.org/wiki/Vibe_coding) a
    working application with little knowledge of how the code actually works.
    And, indeed, we know surprisingly very little about how the actual models
    work themselves.

    My notes are
    [Readwise](https://readwise.io/reader/shared/01kr2cadh32bbpt2fgn1xza0w1).

- [Tailscaleやめたい](https://mq1.dev/entry/j7zvrsp48lb/) -- _Sudachi Mai_

    This is a Japanese article that ties in with the article above about
    abstractions. Tailscale is a great product abstraction that simplifies
    setting up a [WireGuard VPN](https://www.wireguard.com/). However, this can
    lead to issues with the underlying implementation.

    In this case, the author had issues with Tailscale's DNS implementation, and
    the IP address space it uses. Tailscale DNS doesn't always interact well
    with `systemd-resolved` in `leader+legacy` mode and this can lead it to add
    its own MagicDNS DNS server as an upstream DNS causing infinite loops. In
    this case, Tailscale is making incorrect assumptions about the underlying DNS
    system on the machine. GitHub issue
    [#7816](https://github.com/tailscale/tailscale/issues/7816) has a full
    description of the underlying problem.

    Another issue is that Tailscale uses the [Carrier-grade
    NAT](https://en.wikipedia.org/wiki/Carrier-grade_NAT) (CGNAT) address space
    of `100.64.0.0/10` for its
    ["tailnet"](https://tailscale.com/docs/concepts/tailnet) IP addresses. The
    author here complains that this is a violation of [RFC
    6598](https://datatracker.ietf.org/doc/html/rfc6598) because it makes use of
    an address space that is reserved for ISPs to use in IP overflow situations.
    It's also typically used by network administrators when internal IPs are
    exhausted. This can happen often in large organizations or on Kubernetes
    clusters where the number of pods is large and are not using something like
    an [overlay network](https://en.wikipedia.org/wiki/Overlay_network).

    Tailscale is a great OSS product that greatly simplifies setting up a
    WireGuard VPN. When you are using `systemd-resolved` in `leader+legacy` mode
    or CGNAT for your internal network, these abstractions can cause conflicts
    that can be hard or impossible to resolve, without deep knowledge of the
    implementation.

    My notes are
    [Readwise](https://readwise.io/reader/shared/01kqzpjwyx837zb7xmmn5atdn1).

## The Google Chrome Prompt API

- [Google’s Prompt API](https://wil.to/posts/googles-prompt-api/) -- _Mat “Wilto” Marquis_

    Google Chrome has shipped a new ["Prompt
    API"](https://developer.chrome.com/docs/ai/prompt-api) that as a part of a
    new Chrome feature that downloads a 4GB Gemini Nano model and provides
    access to it via JavaScript. There was some effort to make this into a
    proper web standard, but
    [no](https://github.com/WebKit/standards-positions/issues/495#issuecomment-4356846488)
    [one](https://github.com/mozilla/standards-positions/issues/1213#issuecomment-4347988313)
    else was supportive and they just ended up ramming it through.

    You can disable its use by going to `Settings > System` and disabling the
    `On-device AI` option. This won't stop the model from being downloaded and
    taking up space on your machine though.

    My notes are on
    [Readwise](https://readwise.io/reader/shared/01kr2c64ebrfh92rwsqxpvt4j3).

- [Google Chrome silently installs a 4 GB AI model on your device](https://www.thatprivacyguy.com/blog/chrome-silent-nano-install/) -- _Alexander Hanff_

    Alexander Hanff speaks mostly to the privacy and legal implications of
    downloading the local model. I find his arguments much weaker than those of
    the web standards folks.

    He seems to focus a lot of the 4GB size of the model. He mentions it no less
    than 30 times in the article. It seems to me that the model is no different
    from any of the other local models that are used as part of Chrome aside
    from the file size.

    I agree that it is large for such a limited feature but 4GB is not actually
    that unreasonable for software nowadays and I don't expect that the download
    would cause many issues for actual users.

    I agree that Google should make this an opt-in feature that downloads the
    model only if enabled. However, I don't really buy the legal arguments that
    this is some kind of breach of privacy that auto-updates aren't. Presumably,
    any device fingerprinting that is possible with the model could also be done
    easier via auto-updates.

    My notes are on
    [Readwise](https://readwise.io/reader/shared/01kqzwbac10rdedbdwe3q2r7zh).

## GitHub's Unreliability

- [Ghostty Is Leaving GitHub](https://mitchellh.com/writing/ghostty-leaving-github) -- _Mitchell Hashimoto_

    [The Ghostty project](https://ghostty.org/) is apparently leaving GitHub due
    to recent unreliability. I have noticed that GitHub has been less reliable
    but it's mostly been in ways that don't block work from progressing; PR
    counts not updating, open/merged labels not updating, temporary GitHub
    Actions job connectivity issues etc.

    I can understand this position though if you have a large project. GitHub
    has had some
    [major outages recently](https://github.blog/news-insights/company-news/an-update-on-github-availability/)
    due to the explosion of AI generated code. But it's also been struggling
    with reliability since the
    [Microsoft acquisition](https://damrnelson.github.io/github-historical-uptime/).

    I wonder how projects like Kubernetes are coping. Presumably, the problem is
    much, much worse for them.

    My notes are on
    [Readwise](https://readwise.io/reader/shared/01kqskc12cc0169ndpq56ckd10).

- [The Pulse: AI load breaks GitHub – why not other vendors?](https://newsletter.pragmaticengineer.com/p/the-pulse-ai-load-breaks-github-why) -- _Gergely Orosz_

    Gergely summarizes GitHub's recent reliability problems well. April has been
    a really bad month for them.

    Gergely asks if it's an issue due to Microsoft acquisition or something else?
    I think it's likely that they have been mired in a long migration to Azure
    that was mandated after the acquisition. It's been going on for years and
    it's likely taking a much longer time than expected. I suspect that they
    have been kicking the reliability can down the road until after the
    migration is complete and that day hasn't come.

    Then the AI load has really spiked in the last year or so and it's caught
    them when their reliability already wasn't that great and they've had
    trouble coping.

    My notes are on
    [Readwise](https://readwise.io/reader/shared/01kr2c523tv5kdbhn5k5142cr5).
