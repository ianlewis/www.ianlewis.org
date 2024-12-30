---
layout: post
title: "Leaving Google"
date: 2024-11-15 00:00:00 +0000
permalink: /en/leaving-google
blog: en
tags: google
render_with_liquid: false
---

<!-- textlint-disable rousseau -->

Today is my last day as a Google employee. After nearly 10 years working on the
Google Cloud Developer Relations team, I’ve decided to step away and pursue
other challenges.

## Before Google

Joining Google in January 2015 seemed like a natural career progression. My
first exposure to Google Cloud came in the summer of 2008 when I attended
Google Developer Day. Google App Engine for Python was just released and it
felt pretty special. It supported Python only, which was unusual at the time
and this was a boon for the Python community in Japan.

I attended a workshop to develop an application on App Engine and there I met
many people who would be long lasting friends.

![Google Developer Day 2008](/assets/images/2024-11-15-leaving-google/google-developer-day-2008.jpg "Google Developer Day 2008"){:style="width: 70%; display:block; margin-left:auto; margin-right:auto"}

*Do you remember iGoogle?*

In 2010 I became an API Expert[^1] for Google App Engine. My fellow experts
[Eiji Kitamura](https://twitter.com/agektmr),
[Takashi Matsuo](https://twitter.com/tmatsuo), and
[Kaz Sato](https://twitter.com/kazunori_279) all joined Cloud Developer
Relations ahead of me. Other friends like
[Yoshi Yamaguchi](https://twitter.com/ymotongpoo) and
[Brian Dorsey](https://twitter.com/briandorsey) also joined Google.

I had also been doing a lot in various developer communities in Tokyo. I helped
found [PyCon JP](https://www.pycon.jp/) to run the Python conferences in Japan,
and was organizing several IT meetups. So when I was asked if I would be
interested in joining a new Cloud DevRel team, working in DevRel seemed like a
good fit.

## Joining Google

Working at Google was both magical and terrifying at the same time. I had never
worked at a company bigger than ~600 people and Google had about 40k employees
at the time. Google was basically my dream job.

I was also suddenly working with folks who had masters or PhD degrees from the
storied halls of MIT, Stanford and other prestigious schools, people who worked
at Apple in the 90s, folks making 6 figure salaries from the moment they left
school, and literal celebrities in the software development world. On the other
hand, by any metric I went to one of the worst colleges in the U.S. and had
been earning peanuts by comparison up until that point. To say that I didn’t
feel like I fit in would be a massive understatement.

The first few years of working at Google were a whirlwind of activity. In the
first year I held events and gave presentations in
[9 countries and 15 different Google offices](https://www.ianlewis.org/en/looking-back-my-first-year-google),
visited two Google data centers in Washington State and Taiwan, and attended
the [very first KubeCon](https://ti.to/kubecon/kubecon-2015) ([sched](https://kubecon2015.sched.com/)).

![Coffee with Googlers](/assets/images/2024-11-15-leaving-google/coffee-with-googlers.jpg "Coffee with Googlers"){:style="width: 40%"}
![Me and Kaz](/assets/images/2024-11-15-leaving-google/ian-and-kaz.jpg "Me and Kaz"){:style="width: 40%"}
![Eating out after KubeCon 2015](/assets/images/2024-11-15-leaving-google/kubecon-2015.jpg "Eating out after KubeCon 2015"){:style="width: 50%"}
![Me and Monotaro at PyCon JP 2015](/assets/images/2024-11-15-leaving-google/monotaro.jpg "Me and Monotaro at PyCon JP 2015"){:style="width: 30%"}

Over time I focused on many different products. I started out working on [Cloud
Bigtable](https://cloud.google.com/bigtable?hl=en) and supporting customers in
China and Taiwan. After that, I moved on to focus on areas like Kubernetes,
Cloud Native Security, and Software Supply Chain Security.

Some of the highlights for me were working on the
[Open Source release](https://www.youtube.com/watch?v=TJJT8wc0T_c) of
[gVisor](https://gvisor.dev/), and building
[SLSA provenance generators](https://github.com/slsa-framework/slsa-github-generator)
for GitHub Actions.

## Challenges

As cool as many of the projects were at Google, it didn’t take long before I
felt limited by my role in DevRel. DevRel leadership's vision did not match my
own vision of Developer Advocates as community leaders, advocates for end-user
developer experience, and project contributors. I resolved to forge my own path
by working on projects like gVisor and SLSA, and had some success.

gVisor as an open source project has supported
[several other companies](https://gvisor.dev/users/) in addition to Google’s
first party
[GKE Sandbox](https://cloud.google.com/kubernetes-engine/docs/concepts/sandbox-pods).
For example, Cloudflare uses gVisor in their
[Cloudflare Pages](https://blog.cloudflare.com/cloudflare-pages-build-improvements/)
product and their upcoming
[serverless container platform](https://blog.cloudflare.com/container-platform-preview/)
which is used for their Workers AI and Workers Builds products. OpenAI also uses it to
execute code generated by their AI models. SLSA has been adopted by
[npm for Node.js packages](https://github.blog/security/supply-chain-security/introducing-npm-package-provenance/)
and in GitHub's [Artifact Attestations](https://github.blog/news-insights/product-news/introducing-artifact-attestations-now-in-public-beta/).
The SLSA team even won a company wide award this year with a ~$10k bonus. I
felt proud to be even a small part of their success.

While I felt that I was having an impact by contributing to these projects, it
was becoming more and more clear to me that the DevRel role did not fit the
kind of work I was doing. The feeling of impostor syndrome never went away. I
felt powerless and stagnant. COVID and layoffs only amplified these problems.

## Focusing on my Passions

So after much soul searching, I decided to leave Google behind and take some
time off before going back to my roots and pursuing my passions as a software
engineer. I’m starting by taking it easy, working on some open source projects,
and visiting with friends and family over the next few months. I’ll be staying
in the Tokyo area so I won’t be far from all of my local friends.

If you haven't already, you can connect with me on
[Linkedin](https://www.linkedin.com/in/ianmlewis/),
[X/Twitter](https://x.com/ianmlewis),
[BlueSky](https://bsky.app/profile/ianlewis.bsky.social), and, as always, via
email at [ianmlewis@gmail.com](mailto:ianmlewis@gmail.com).

Thanks to all the folks I worked with along the way! I feel most grateful for
your support.

[^1]: API Experts eventually became the [Google Developer Experts (GDE)](https://developers.google.com/community/experts) program.

<!-- textlint-enable rousseau -->
