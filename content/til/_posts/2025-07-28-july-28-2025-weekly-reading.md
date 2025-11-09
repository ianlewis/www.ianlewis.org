---
layout: post
title: "TIL: July 28, 2025 - Weekly Reading: Backpressure and Career Advice"
date: "2025-07-28 00:00:00 +0900"
blog: til
tags: weekly-reading programming python
render_with_liquid: false
---

## Concurrency and Backpressure

- [Playground Wisdom: Threads Beat
  Async/Await](https://lucumr.pocoo.org/2024/11/18/threads-beat-async-await/) --
  _Armin Ronacher_

    Armin points out a lot of the ways that async/await are not an ideal way to
    write concurrent code. Some of the points he makes involve the lack of
    [backpressure](https://en.wikipedia.org/wiki/Back_pressure) handling,
    halting issues, and an inability to block without tying up the entire
    control loop.

    I think the issues pointed out here are some of the reasons why I really
    like Go's concurrency model. It has a lot of the same issues with halting
    and backpressure, but does it in an imperative way that is much easier to
    reason about.

- [I'm not feeling the async
  pressure](https://lucumr.pocoo.org/2020/1/1/async-pressure/) -- _Armin Ronacher_

    This is Armin's previous article from 2020 that discusses issues with
    async/await regarding the inability to control backpressure. One of the main
    issues is the inability to block without tying up the entire control loop.
    In Python, calls that would normally block, buffer instead which could lead
    to memory issues, when applying backpressure by blocking would work better.

- [Backpressure explained — the resisted flow of data through
  software](https://medium.com/@jayphelps/backpressure-explained-the-flow-of-data-through-software-2350b3e77ce7)
  -- _Jay Phelps_

    Linked by Armin's post from 2020. This is a good introduction to the concept
    of backpressure in software systems. It covers some of the basic strategies
    for handling backpressure, such as buffering, throttling, and dropping data.
    It also covers some architectural patterns like push, pull, and hybrid
    push/pull architectures.

## Career and Impact

- [Don't End The Week With
  Nothing](https://training.kalzumeus.com/newsletters/archive/do-not-end-the-week-with-nothing)
  -- _Patrick McKenzie_

    Patrick talks about how to prioritize projects you work on during your
    career to maximize your impact over time. Some of the key points are:
    - Choose companies and projects where the work you do is visible to others
      like OSS or user-facing products. Internal projects aren't great because
      other's can't see them directly.
    - Work on projects that you can talk about publicly. This helps you
      build a reputation and network in the industry. Do talks at conferences,
      etc.
    - Prefer working on things that aren't tied to your employment. Ideally
      projects that you can retain some personal ownership. Side hustles and OSS
      projects that you can continue to work on after you leave the company are
      good for this.

    I like this advice because it helps build a career over time, that can have
    compounding returns for you rather than just having money to show for you
    work at the end.
