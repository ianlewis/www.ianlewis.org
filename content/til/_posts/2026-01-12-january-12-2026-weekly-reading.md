---
layout: post
title: "TIL: January 12, 2026 - Weekly Reading: AI, Career, and the Economy"
date: "2026-01-12 00:00:00 +0900"
blog: til, ai
tags: weekly-reading ai career
render_with_liquid: false
---

## Artificial Intelligence

<!-- TODO(#488): remove ignore comment when pettier bug is fixed -->
<!-- prettier-ignore-start -->

- [Sleeper Agents in Large Language Models](https://www.youtube.com/watch?v=wL22URoMZjo) -- _Computerphile_

    <iframe
        title="YouTube video player"
        src="https://www.youtube-nocookie.com/embed/wL22URoMZjo?si=R4ObMImExALH-Wag"
        class="youtube"
        allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
        referrerpolicy="strict-origin-when-cross-origin"
        allowfullscreen>
    </iframe>

    Computerphile explains the problem with "sleeper agents" in large language
    models (LLMs). These are hidden instructions that are embedded in the
    training data that can be triggered by specific prompts or at a specific
    time.

    These are really hard to detect because they are hard to trigger outside of
    the right context. This is because the trainers don't know the trigger and
    even if you do know the trigger, training the model to avoid them just makes
    it better at deception.

- [The Hard Problem of Controlling Powerful AI Systems](https://www.youtube.com/watch?v=JAcwtV_bFp4) -- _Computerphile_

    <iframe
        title="YouTube video player"
        src="https://www.youtube-nocookie.com/embed/JAcwtV_bFp4?si=48OCum5lI5irH_YO"
        class="youtube"
        allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
        referrerpolicy="strict-origin-when-cross-origin"
        allowfullscreen>
    </iframe>

    This is another Computerphile video that discusses the challenges of
    making sure that powerful AI systems do what we want them to do and only
    what we want them to do. It mostly discusses ideas like using other simpler,
    more trusted AI systems to monitor and control the more powerful AI
    systems.

    It's really puzzling to me that folks never seem to discuss sandboxing AIs
    as a first step. AI agents are effectively just remote code execution (RCE)
    as a service on your machine. If you don't trust the AI, then the first step
    is to only give it access to the resources it needs to do its job and
    physically restricting it with a security sandbox (e.g.
    [gVisor](https://gvisor.dev/),
    [Firecracker](https://firecracker-microvm.github.io/), virtual machine,
    etc.).

    You will still need to monitor the AI's behavior but sandboxing is at the
    very least, the first step to prevent catastrophic damage. The idea also
    that you can use other powerful AIs to monitor and control powerful AIs
    seems like a terrible idea to me. First, the AI can collude against you.

    Collusion doesn't require communication between the agents either, and can
    be simply an emergent behavior. If Agent `A` is being sandboxed and Agent
    `B` is monitoring it, then Agent `B` is incentivized to not report the bad
    behavior of Agent `A`. This is because Agent `B` will want to do bad
    behavior when it's monitored by Agent `A`.

    Some of the solutions given, like asking the AI multiple times to ensure
    you're not getting a false positive for suspicious behavior seems ludicrous
    to me. Obviously, asking an untrusted AI multiple times isn't going to
    improve the trustworthiness of its answers. In fact, that sounds like a
    great opportunity for deception.

<!-- prettier-ignore-end -->

## Career

- [Advice for New Principal Tech ICs (i.e., Notes to Myself)](https://eugeneyan.com/writing/principal/)

    Eugene Yan shares advice for new principal-level individual contributors
    (ICs) in big tech companies. He has 31(!) tips covering various aspects of
    the role. The fact that there is so much stuff here is indicative of just
    how complex the role of a principal IC is.

    It's worth noting that it seems that principal is a level 7 at AWS which is
    equivalent to a staff or senior staff engineer at Google. A principal at
    Google is a level 8 which is equivalent to a director, or senior principal
    engineer at AWS.

    My feeling is that you largely need to have a strong foundation in technical
    skills down pat before becoming a principal engineer. The knowledge
    necessary to make good technical decisions is something you need to have
    already because you will need to spend the vast majority of your time on
    persuasion and influence with directors, vice presidents (VPs), and product
    managers.

## Economy

<!-- TODO(#488): remove ignore comment when pettier bug is fixed -->
<!-- prettier-ignore-start -->

- [Why You Don't Matter Anymore ........... (Economically Speaking)](https://www.youtube.com/watch?v=T2OHjHPkUzM) -- _How Money Works_

    <iframe
        title="YouTube video player"
        src="https://www.youtube-nocookie.com/embed/T2OHjHPkUzM?si=kw105eE7qt607hPG"
        class="youtube"
        allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
        referrerpolicy="strict-origin-when-cross-origin"
        allowfullscreen>
    </iframe>

    This is a good explainer about why the economy overall could be doing well
    while most people feel like they are struggling. It's basically outlining
    how the rich own most investments and assets that are appreciating in value,
    while most people rely on wages that are not keeping up with the inflation
    of essential goods and services.

    We could actually have tons of people being laid off in a booming economy
    and it wouldn't make much of a difference to the overall economic
    indicators. It might even make things look better for the economy as a whole
    because companies are cutting costs and increasing profits.

- [Why the Rich Don’t Pay Taxes](https://www.youtube.com/watch?v=aLKacgW6YOI)

    <iframe
        title="YouTube video player"
        src="https://www.youtube-nocookie.com/embed/aLKacgW6YOI?si=PFuGFwiy_oOGm5Gg"
        class="youtube"
        allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
        referrerpolicy="strict-origin-when-cross-origin"
        allowfullscreen>
    </iframe>

    Ray Madoff from Boston College Law School explains how wealthy people make
    up a "second estate" that is where they are largely exempt from paying
    taxes.

    The wealthy use a variety of legal strategies to minimize their tax burden,
    such as using capital gains rates, tax-exempt investments, trusts, and
    offshore accounts. They avoid capital gains taxes by not selling
    investments. They just borrow against them and live off the borrowed money.
    They basically never fully pay back the money.

    They also can generally avoid estate taxes through careful planning by
    putting their assets in real-estate which is subject to step-up basis, and
    other loopholes.

    Wealthy people can also completely eliminate their tax burden by donating to
    their charity funds that have no obligation to actually pay out. Since the
    wealthy can afford to give away large sums of money,

    Working people bear most of the cost of funding the U.S. government through
    income taxes, payroll taxes, sales taxes, and tariffs in the form of higher
    prices. They also can't completely avoid taxes by giving to charity because
    charitable deductions don't apply to payroll taxes and are capped at a
    percentage of income.

<!-- prettier-ignore-end -->

- [Part 1: My Life Is a Lie](https://www.yesigiveafig.com/p/part-1-my-life-is-a-lie) -- _Michael W. Green_

    This is a post that went viral and sparked a lot of discussion about the
    cost of living in the U.S.. It was
    [discussed](https://www.youtube.com/watch?v=aGN8oy1xa-Y) bit by Michael
    Smerconish on CNN as well (His goofy look with the sucked in cheeks when
    he's listening to his guests always gets me).

    The main claim of the post is that the official poverty line of $31,200
    (defined in 1963) doesn't fit today's reality.

    > “The U.S. poverty line is calculated as three times the cost of a minimum
    > food diet in 1963, adjusted for inflation.”

    This basically says that in 2025, you need to be spending about 1/3 of your
    budget on food to be at the poverty line. Given the relatively low cost of
    food in 2025, when compared to housing, healthcare, childcare,
    transportation, and education, this isn't realistic. And that's not
    mentioning the internet, phone, and other modern necessities.

    Michael W. Green calculated what the poverty line should be in 2025 using
    the same logic from 1963 but applied to today's typical percentage of
    spending on food of about 5~7%. This gives a poverty line of around $140,000
    for a family of four in 2025. This is notable since the median household
    income in the U.S. is around $80,000.

    Even where I live in Japan, I've often thought that you'd need a tech salary
    just to feel comfortable. Even with universal healthcare, lower education
    costs, and lower housing costs, the cost of living can still be quite high.
