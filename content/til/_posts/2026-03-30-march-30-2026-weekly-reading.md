---
layout: post
title: "TIL: March 30, 2026 - Weekly Reading - LiteLLM Supply Chain Compromise"
date: "2026-03-30 09:00:00 +0900"
blog: til
tags: weekly-reading
render_with_liquid: false
---

## The LiteLLM Supply Chain Compromise

- [<!-- textlint-disable spelling -->Supply Chain Attack in litellm 1.82.8 on PyPI<!-- textlint-enable spelling -->](https://futuresearch.ai/blog/litellm-pypi-supply-chain-attack/) -- _Callum McMahon, futuresearch_

    One of the first articles outlining the attack on LiteLLM, a popular Python
    library for working with large language models. The author seems to be the
    one that initially found the issue. It provides an overview of the attack
    and what it does. This article focused on 1.82.8 but it was later found out
    that 1.82.7 was also affected.

    It seems that 1.82.7 was more potent because it did not use the same `.pth`
    file mechanism to trigger the attack. This mechanism had a bug that fork
    bombed the system which, I suspect, is one reason why it was discovered.

    Version 1.82.7 needed you to import the `litellm` module for the attack to
    work, so 1.82.8 was likely meant to be a more aggressive attack that would
    trigger just by running the Python interpreter.

    My notes are on
    [Readwise](https://readwise.io/reader/shared/01kmhc5w32e7gdkztkc3srmkhm).

    The author wrote a [follow up
    post](https://futuresearch.ai/blog/no-prompt-injection-required/) which goes
    into how they find the issue. My notes for that are also on
    [Readwise](https://readwise.io/reader/shared/01kmhc4r9c292ekn6nx5n63jma).

- [2026年3月24日の LiteLLM 侵害の概要と対応指針](https://diary.shift-js.info/litellm-compromise/) -- _Takashi Yoneuchi_

    This blog post is a detailed analysis of the attack on LiteLLM with a fairly
    exhaustive list of the attack's features. It should be helpful for folks who
    need to understand the impact of the attack and where to look for indicators
    of compromise.

    The article is in Japanese so if you're not a Japanese speaker you may need
    to use a translation service to read it.

    My notes are on
    [Readwise](https://readwise.io/reader/shared/01kmvyej2pm3c9ynycwcxvqyhr).

- [<!-- textlint-disable spelling -->Analysis of Python's .pth files as a persistence mechanism<!-- textlint-enable spelling -->](https://dfir.ch/posts/publish_python_pth_extension/)

    Apparently, using a `.pth` file to persistently execute code was also used
    to attack
    [GlobalProtect](https://www.volexity.com/blog/2024/04/12/zero-day-exploitation-of-unauthenticated-remote-code-execution-vulnerability-in-globalprotect-cve-2024-3400/),
    a VPN system for Palo Alto Networks' PAN-OS. The article notes some more of
    the features of `.pth` files and some more discussion on their dangers.

    My notes are on
    [Readwise](https://readwise.io/reader/shared/01kmhc4prhvcj7q7czpp19qvpq).

- [Update: Ongoing Investigation and Continued Remediation](https://www.aquasec.com/blog/trivy-supply-chain-attack-what-you-need-to-know/) -- _Aqua Team, Aqua Security_

    The LiteLLM attack was facilitated by the attack on Trivy, a popular
    container vulnerability scanner, by the same attackers. The LiteLLM
    repository's CI pipeline was compromised via Trivy which allowed the
    attackers to push malicious versions to PyPI.

    This goes into the details and remediation efforts regarding the Trivy
    attack.
