---
layout: post
title: "TIL: November 23, 2025 - Weekly Reading: Security and AI"
date: "2025-11-23 00:00:00 +0900"
blog: til
tags: weekly-reading
render_with_liquid: false
---

## Security

- [Introducing CodeMender: an AI agent for code security](https://deepmind.google/discover/blog/introducing-codemender-an-ai-agent-for-code-security/) - _Raluca Ada Popa and Four Flynn, DeepMind_

    CodeMender is a new AI agent developed by DeepMind that automatically
    identifies and fixes security vulnerabilities in codebases. It seems like a
    promising tool for finding vulnerabilities and actually patching them. One
    of the issues in the news recently has been how companies spend money on
    security audits and submitting reports but not contributing to actually
    fixing the issues.

    I hope that companies like Google won't use these tools as an alternative to
    actually funding open-source work but I'm not holding my breath.

<!-- TODO(#488): remove ignore comment when pettier bug is fixed -->
<!-- prettier-ignore-start -->

- [NDSS 2025 -A Holistic Security Analysis of Google Fuchsia's (and gVisor's) Network Stack](https://youtube.com/watch?v=RLdbNoVkYIE) - _Inon Kaplan (Independent researcher), Ron even (Independent researcher), Amit Klein (The Hebrew University of Jerusalem, Israel)_

    <iframe
        title="YouTube video player"
        src="https://www.youtube-nocookie.com/embed/RLdbNoVkYIE?si=qz2WlIv_ny3GRBpf"
        class="youtube"
        allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
        referrerpolicy="strict-origin-when-cross-origin"
        allowfullscreen>
    </iframe>

    This is a talk on some research some folks independent researchers and
    researchers at The Hebrew University of Jerusalem did on the gVisor network
    stack (Netstack) at the Network and Distributed System Security Symposium
    (NDSS).

    Netstack is a reasonable TCP/IP,UDP network stack but it's true that it's
    less sophisticated than Linux's network stack. The researchers found a
    number of vulnerabilities in the stack mostly around their ability to
    determine the pseudorandom number generator (PRNG) seed. That then allowed
    them to predict the initial TCP initial sequence number, TCP timestamp, TCP
    and UDP source ports, and IPv4/IPv6 fragment ID fields

    The talk focused on using this for web-based tracking since a stable device
    ID could be derived that persisnt until the system was rebooted. I suppose,
    though, that this could allow for [injection
    attacks](https://en.wikipedia.org/wiki/TCP_sequence_prediction_attack) if an
    attacker could predict TCP sequence numbers.

    The speaker then throws some shade at the end.

    > _I think they wanted to. To go through it in a clean slate, manner without
    > actually taking a lot of influence from existing implementations and
    > results, well, you could see the results._

    I think the reason that Netstack hasn't really addressed some of these kinds
    of issues is that the gVisor team, which develops and maintains Netstack is
    mostly focused on server-side container workloads. The threat model there
    might be a bit different in that these kinds of attacks are less likely.

    Fuchsia, on the other hand is a general-purpose OS that is intended to run
    on consumer devices. It's notable that contributions from the Fuchsia team
    to Netstack have fallen off in recent years. You can see that
    [contributions](https://github.com/google/gvisor/graphs/contributors) from
    Tamir Duberstein (tamird) and Ghanan Gowripalan (ghananigans) have basically
    stopped since the end of 2022 and end of 2023 respectively.

<!-- prettier-ignore-end -->

## Artificial Intelligence (Machine Learning)

- [Octoverse: A new developer joins GitHub every second as AI leads TypeScript to #1](https://github.blog/news-insights/octoverse/octoverse-a-new-developer-joins-github-every-second-as-ai-leads-typescript-to-1/) - _GitHub Staff_

    The 2025 GitHub Octoverse report has some interesting statistics on how AI
    is changing software development. The big one they note is that TypeScript
    has become the most popular programming language on GitHub. They don't
    outright say it, but it's clear that this is due to most generated code
    being in TypeScript for frontend frameworks (React etc.).

    The Top 10 countries for GitHub users also caught my eye. There is lots of
    growth from developing countries, but it's nice to see that Japan is holding
    its own, even if the per capita developer population is still lower than
    other developed countries.
