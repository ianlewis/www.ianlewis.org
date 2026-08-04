---
layout: post
title: "Reactions to the CNCF State of Cloud Native in Japan 2026"
blog: en
tags:
    - tech
    - programming
    - kubernetes
    - containers
permalink: /en/state-of-cloud-native-japan-2026
render_with_liquid: false
---

The CNCF recently published the
[State of Cloud Native in Japan
2026](/assets/pdf/DN31-JAPAN-State-of-Cloud-Native-Development-1.pdf) report
where they published information on the state of the community here in Japan. I
wanted to write some of my reactions to the report and share some of the data
that I found interesting.

The report is based on the
[SlashData™ Developer Nation’s 31st edition](https://research.slashdata.co/reports/68c99072f9eed41a5dadcc8f)
survey of roughly 12,500 developers worldwide. The report doesn't include
information on exactly how many developers in Japan were surveyed, but the
report does include that 9% were from East Asia. "Greater China" is separated
out so roughly 1,125 developers are from Japan and South Korea combined. Some of
the sample sizes for individual questions are quite small, so we'll need to take
the data with a large grain of salt.

> **NOTE:** SlashData™ and to the Cloud Native Computing Foundation (CNCF) have
> sponsored the report and I will reproduce some of the data here under the
> [Creative Commons Attribution-NoDerivatives Licence 4.0 (International)](https://creativecommons.org/licenses/by-nd/4.0/).

Unfortunately, the report provides only a small amount of data specific to Japan
and falls back to including a lot of global data. Again, it can't really say a
lot about Japan without a larger sample size.

## Cloud Native Developers in Japan

The report includes a chart showing the percentage of backend developers who are
using cloud native technologies. It shows a large spike from 23% in Q1 2025 to
48% in Q3 2025.

![Proportion of Cloud Native Developers in Japan](/assets/images/state-of-cloud-native-japan/proportion-of-cloud-native-developers-in-japan.png){: .align-center}

This is a huge jump in a short period of time. I think this is
mostly due to the very small sample size. It also seems that the survey
methodology was changed in Q3 2025 as noted on page 24. This is further
explained on page 21 as a change that now includes "web developers" as "backend
developers".

It seems that, perhaps, a larger proportion of web developers in Japan are using
cloud native technology relative to other countries.

## Infrastructure Deployment in Japan

One of the key findings of the report is that Japan has a higher proportion of
on-premises deployments relative to other countries. As noted on page 17 and 18,
this is likely due to the fact that
[Japan uses a lot of system integrators (SIers)](https://nihonium.io/the-unique-role-of-a-system-integrator-si-in-japan/#What_are_System_Integrators)
who often manage the on-premises deployments. These on-premises deployments
often have performance, efficiency, data sovereignty, and risk management
advantages over public cloud deployments at the expense of flexibility.

![Trends in Cloud Native Deployments](/assets/images/state-of-cloud-native-japan/trends-in-cloud-native-deployments.png){: .align-center}

The on-premises numbers are also separate from "private cloud" so this means
that the community in Japan has a much larger proportion of cloud native
developers who aren't actually using VMs and are deploying clusters on bare
metal.

The report also notes the implications for the cloud native community as well.

> Japan's SI-mediated infrastructure model means cloud native tooling decisions
> are typically made at the organizational level, not the developer level. This
> has a consequence beyond procurement: Fewer Japanese developers may engage
> directly with the open source projects underpinning the technologies their
> organizations already rely on. That matters for the open source community as
> much as it does for Japan. Open source is strengthened when developers from
> different regions, cultures, sectors, and roles build the solutions that serve
> them and their colleagues. Additionally, a Japanese developer community more
> directly engaged with cloud native projects has Japan-specific problems,
> priorities, and use cases to contribute that the broader community would
> otherwise never see.

I think this is an important and accurate point. In addition, I think that as a
result of a more centralized decision-making process, the community that does
exist is a much more grassroots driven community, as opposed to a community
driven by companies.

## Cloud Native Usage in Japan

The report notes that, while Japan has a lower rate of adoption of cloud, the
rate of adoption of cloud native technology is on par with the global rate
(41% in Japan vs. 39% globally). The fact that private cloud is also has lower
adoption rate (29% in Japan vs. 38% globally) is also interesting.

> This structural difference in infrastructure strategy is also the most
> plausible explanation for how Japan has achieved cloud native parity through a
> different route. In other regions, higher levels of cloud nativeness tend to
> occur alongside higher levels of cloud usage more broadly. Japan, however, has
> achieved comparable levels of cloud nativeness among its developer population
> without this pattern holding.

Given that private cloud adoption in Japan is also low, it seems that
organizations in Japan might be choosing their deployment model due to
performance, cost efficiency, or cultural reasons. You could achieve similar
data sovereignty, risk management, and better flexibility with a private cloud
deployment, but more organizations in Japan are choosing bare metal deployments.

The fact that cloud native adoption is on par with the global rate also
indicates that the cloud native technology is fairly mature, and isn't suffering
from a lagging adoption anymore. Cloud is even older, so the low adoption is not
due to the technology being immature, or due to adoption lag. The low adoption
is a conscious choice made for other reasons.

## Japanese Cloud Native Community

The Cloud Native community in Japan was started (by myself) with the
[Kubernetes Meetup Tokyo](https://k8sjp.connpass.com/) in May 2016. At the time
I created the meetup as part of my job at Google. However, I couldn't keep up
with community demand, and it quickly became a grassroots community without any
major corporate sponsorship.

Eventually the CNCF community broadened to include other cloud native
technologies, but it's always been a grassroots driven. Many folks are now using
cloud native tech in their jobs, but I think the grassroots nature of the
community speaks to its strength. Folks contribute to the community because they
believe in the technology rather than because of their job.
