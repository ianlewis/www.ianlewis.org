---
layout: post
title: "TIL: July 1, 2025 - Weekly Reading: AI 2027, Go 1.25, and Career Development"
date: "2025-07-01 00:00:00 +0900"
blog: til
tags: AI go learning weekly-reading
render_with_liquid: false
---

## Artificial Intelligence

- [AI 2027](https://ai-2027.com/) - _Daniel Kokotajlo, Scott Alexander, Thomas Larsen, Eli Lifland, Romeo Dean_

    A speculative look at the future of AI in 2027, exploring how it might
    integrate into daily life, work, and society.

    This just seems so fantastical to me and makes little sense. I did listen to
    the [Sam Harris podcast interview with Daniel
    Kokotajlo](https://www.samharris.org/podcasts/making-sense-episodes/420-countdown-to-superintelligence)
    which made only slightly more sense. I think that I agree with how Daniel
    described the motivations of the AI companies, but I'm still skeptical that
    the current trajectory of AI will lead to the future that they describe.

    AI is good at generating content like text, images, sound, and video, but
    that's only a very small subset of what humans can do. I'm having a hard
    time seeing AI getting better at generating content will lead to some
    superintelligence explosion that will take over the world.

- [Vibe Coding as a software engineer](https://newsletter.pragmaticengineer.com/p/vibe-coding-as-a-software-engineer) - _Gergely Orosz, Elin Nilsson_

    This is another article about vibe coding, this time from the perspective of
    a software engineer. It discusses the difference between "vibe coding" and
    "AI-assisted coding". Basically, vibe coding is when you let AI drive most
    of the coding and you just review the product it produces without looking at
    the code much or at all. AI-assisted coding is when you use AI to help you
    code but you are still actively engaged in the coding, and reviewing
    process.

    I have noticed that some of my friends swear by using LLMs to drive almost
    everything, what I would describe as vibe coding, but my experience is that I
    am just barely able to use AI-assisted coding to be more productive. Almost
    every time I try AI-assisted coding, I end up having to rewrite everything
    almost from scratch if the AI makes any progress at all, which it frequently
    doesn't. This may be because I am not giving the AI enough context or info,
    but I do give it fairly detailed prompts and try to guide it with new
    information when it gets stuck.

## Programming

- [Go 1.25 Release Notes](https://tip.golang.org/doc/go1.25) - _Go Team_

    I recently attended
    [Shubuya.go](https://shibuya-go.connpass.com/event/357939/). Only a few
    joined but it's an where attendees work on a project and share their
    progress etc. In Japanese this is a called もくもく会 (mokumoku-kai).

    One of the attendees reviewed the upcoming Go 1.25 release notes so I
    decided to take a closer look myself. It seems like it's mostly internal
    changes and not much that will affect most users.

    One change that I already knew about was the [Container-aware
    GOMAXPROCS](https://tip.golang.org/doc/go1.25#container-aware-gomaxprocs).
    This change automatically sets and updates the `GOMAXPROCS` value based on
    the CPU limits imposed on the container by cgroups. While this helps for
    some workloads like those on Kubernetes, it will only work when you set
    limits which doesn't always work out well. Some folks like Lorin
    Hochstein say that [you should set hard limits for
    workloads](https://bsky.app/profile/norootcause.surfingcomplexity.com/post/3lscm2pgqz22d),
    arguing that you won't like what limits the system will impose if you don't
    set it implicitly. Others like Tim Hockin have long argued that the system
    (OS) is much better suited to imposing and managing limits via CPU shares
    relative to other processes/containers on the same machine so the
    `GOMAXPROCS` change won't actually be all that helpful.

    The new [encoding/json/v2](https://tip.golang.org/doc/go1.25#json_v2)
    package and the new [experimental garbage
    collector](https://tip.golang.org/doc/go1.25#new-experimental-garbage-collector)
    also look interesting but I haven't had a chance to look into them much yet.

## Personal Development

- [On How Long it Takes to Know if a Job is Right for You or Not](https://charity.wtf/2025/06/08/on-how-long-it-takes-to-know-if-a-job-is-right-for-you-or-not/) -_Charity Majors_

    Charity Majors writes about the relationship between employees and their
    managers and how long it takes to know if a job is right for you or not. Her
    argument is that, as a new employee, the first impression you get of working
    at a company isn't likely to change much during your tenure, so you should
    be able to tell if a job is right for you almost right away.

    This jives with my experience in some ways but not as much in others.
    Companies can change quite a bit while you work for them, but I agree that
    culture changes much more slowly. In that sense, you'll know if it's a good
    fit pretty quickly. Also, you probably don't really want to precious career
    time "feeling it out". It's probably better for you overall to make quicker
    decisions and move on. I know I've repeatedly felt in hindsight that I
    should have acted faster on major decisions during my own career.

- [Your Professional Decline Is Coming (Much) Sooner Than You Think](https://www.theatlantic.com/magazine/archive/2019/07/work-peak-professional-decline/590650/) - _Arthur C. Brooks_

    > I recently got a subscription to The Atlantic so this might be paywalled.

    This article discusses the inevitable decline of your professional career
    and how to deal with it. Current research shows happiness follows a sort of
    U-curve over the course of your life. Most people gain (or retain) happiness
    until around age 30, then it starts to decline until around age 50 when it
    starts to improve again until around age 70 (After 70 it's less predictible
    and men especially plummet in happiness).

    One thing the article brings up is that it might be hard to give up on long
    held dreams and ambitions, and also that it's hard to deal with life after
    flying high on major successes (“Unhappy is he who depends on success to be
    happy,”).

    One grim point in the article is that most people peak in their career about
    20 years in. So if you start your career in your early 20s, you might peak
    in your 40s. Most folks seem to peak at around 50 and decline quickly after.
    Pretty sobering stuff but it seems to match that [folks tend to hit peak
    income in their late 40s and early
    50s](https://www.bls.gov/charts/usual-weekly-earnings/usual-weekly-earnings-current-quarter-by-age.htm).
