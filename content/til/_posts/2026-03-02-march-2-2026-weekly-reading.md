---
layout: post
title: "TIL: March 2, 2026 - Weekly Reading: Veritasium does XZ, Anthropic vs. DoW, Block layoffs"
date: "2026-03-02 09:00:00 +0900"
blog: til
tags: weekly-reading ai security career
render_with_liquid: false
---

## The XZ Utils Backdoor story

<!-- prettier-ignore-start -->
<!-- TODO(#488): remove ignore comment when prettier bug is fixed -->

- [The Internet Was Weeks Away From Disaster and No One Knew](https://www.youtube.com/watch?v=aoag03mSuXQ) -- _Veritasium_

    <iframe
        title="YouTube video player"
        src="https://www.youtube-nocookie.com/embed/aoag03mSuXQ?si=WpBn5Jx2nLLBReKg"
        class="youtube"
        allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
        referrerpolicy="strict-origin-when-cross-origin"
        allowfullscreen>
    </iframe>

    Veritasium covers the [backdoor
    campaign](https://en.wikipedia.org/wiki/XZ_Utils_backdoor) against
    `xz-utils` that was discovered in 2024. The attack was a supply chain attack
    on OpenSSH and that was discovered by accident when an engineer working on
    PostgreSQL noticed that connections over `ssh` were significantly slower
    than before the backdoor was introduced.

    It's interesting to see how Veritasium covers this from outside of the
    industry. They go all the way back to explaining what open-source is and why
    it's relevant to the social engineering aspect of the attack. I'm glad they
    covered it this way because the social engineering aspect is at least as
    important as the technical aspects of the backdoor itself.

<!-- prettier-ignore-end -->

## Anthropic vs. Department of War

- [Statement from Dario Amodei on our discussions with the Department of War](https://www.anthropic.com/news/statement-department-of-war) -- _Dario Amodei, Anthropic_

    Dario Amodei, the CEO of Anthropic, released a statement about their
    discussions with the Department of War (DoW) about the potential use of
    Anthropic's AI models for military applications.

    Anthropic has said they refuse to remove safeguards around using Claude for
    domestic surveillance and automated weapons. This is pretty reasonable and
    it's their choice what they are and aren't willing to provide to the
    government. The fact that the DoW is targeting domestic companies and
    saying they are a "supply-chain risk" to the military because they won't
    play ball is pretty authoritarian.

    I suppose it's completely unrelated but this comes with the backdrop that
    the U.S. is attacking countries to capture their leaders (Venezuela), and
    bombing others to instigate regime change (Iran) just in the last couple
    months.

    My notes are on
    [Readwise](https://readwise.io/reader/shared/01kjkcyvkgnvvbwj600nkmztvw).

    > Aside: The fact that we're calling the Department of Defense the
    > Department of War, and we're calling armed service members warfighters
    > still feels like a cartoonish bad joke. Irrespective of the fact that
    > service members may call themselves warfighters, using that name when
    > describing them to the general public is a kind of warmongering propaganda
    > that really has no place in the _civilian led_ U.S. government.

## Block layoffs

- [Block Announces Layoffs of 4,000 People, Over 40% Cut](https://www.engineerscodex.com/block-layoffs-4000-ai) -- _Engineers Codex_

    Block, formerly Square, announced layoffs of 4,000 people, which is about
    40% of their workforce. This is a huge layoff, and is apparently the largest
    workforce cut as a share of total employees in S&P 500 history. On top of
    that, the stated reason is because of their embrace of AI. They do mention
    overhiring during COVID a bit, but I've always thought that was always kind
    of silly excuse.

    The quote from Balaji Srinivasan in the article is also telling:

    > So, for him to cut 40% of headcount in this way is a signal to everyone in
    > tech: get good now. Become indispensable. Work nights and weekends. Learn
    > the AI tools and raise your game. Or you might not make the cut, as an
    > employee or as a company.
    >
    > I know. That sucks. But capitalism is natural selection. The market is
    > unforgiving, because you are the market. After all, it’s not like you’re
    > buying some random gallon of milk from the store; you’re always buying the
    > best product at the best price.

    It's clear that employers don't care at all about workers. This is why
    worker organization and unions are so important. Capitalism extends to the
    services that workers provide to their employers as well. So workers should
    act like it by organizing, demanding better pay, benefits, and working
    conditions, striking and walking away when necessary, and voting for
    politicians that support workers' rights.

    If workers don't stand together and demand better, employers and investors
    will continue to take advantage of them. They are saying so explicitly.

    My notes are on
    [Readwise](https://readwise.io/reader/shared/01kjkcw8px1vj45r5xdeb2qwmk).
