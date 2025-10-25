---
layout: post
title: "Bash is the best tool for the job"
date: 2025-10-27 08:00:00 +0900
permalink: /en/bash-is-the-best-tool-for-the-job
blog: en
tags: tech devops programming
render_with_liquid: false
---

Bash is the black sheep of programming languages and yet every backend or DevOps
engineer needs to deal with it throughout their career. It is hard to avoid.
It's always available on Linux servers and it's often the best tool for the job.

Like Bash itself, the things that it is best for are things that programmers
need to do but that they habitually avoid. Automation, Continuous Integration,
and project infrastructure come to mind as examples where engineers spend the
least amount of time that they possibly can. A common thread is that Bash is
often the best tool for all of these. It's the most widely used shell scripting
language and is familiar across wide swaths of developer ecosystems.

<!-- textlint-disable spelling -->

![A screenshot from Bluesky of a post by Wil Deny (@wildeny.bsky.social) that says 'I just wrote a shell script that generates a bash script full of double barrelled awk commands that parse key value pairs out of xml because the other guy doesn't know perl so a have to write scripts in bash.'](/assets/images/2025-10-27-bash-is-the-best-tool-for-the-job/bsky_will.png "Oh lordy."){: .align-center}

<!-- textlint-enable spelling -->

Yet, Bash is derided as a terrible programming language that is best avoided.
Every programmer has complained at least once about unmaintainable shell scripts
that were written by some engineer that left the company long ago. They aren't
wrong but Bash scripts aren't going anywhere either. If anything, the number of
situations where they are needed only seems to be increasing. It would behoove
us all to give Bash scripts the respect they deserve and maintain them better.
In the end, it would make us better programmers.

## To Bash or not to Bash

The first thing to learn when setting out to write better Bash is to know when
to write it and when not to. Like all programming languages, Bash is good at
some things but not others. So while we should aim to write _better_ Bash, we
shouldn't necessarily be writing _more_ Bash.

Bash is best used sparingly for “glue” tasks where you are wrapping or
automating the execution of other commands without manipulating much data. It's
often found and used effectively as an embedded language in other files where
Bash scripts are written inline. Some examples include GitHub Actions workflows,
or Makefiles.

There are no hard and fast rules about when to use Bash and when not to. So it's
a good idea to get a feel for where it's appropriate. Writing business logic in
Bash is typically a red flag, but you might occasionally find Bash to be
appropriate for writing scripts of considerable length.

## The false promise of POSIX compatibility

One topic that often comes up when writing shell scripts is POSIX compatibility.
This refers to the [POSIX
shell](https://pubs.opengroup.org/onlinepubs/9699919799/) (`sh`) which sets a
kind of minimum standard for Unix shells. Many shells that are available on
\*nix systems are POSIX compatible including Bash, Z Shell (`zsh`), and
KornShell (`ksh)`. Many are not, including `tcsh` and `fish`.

The idea of POSIX compatibility is that the scripts that you write will be more
portable across systems. This sounds good on paper. Who doesn't want more
compatible shell scripts?

The biggest problem with a POSIX conforming shell script is that the features
are extremely limited. This often leads to poorly written and fragile shell
scripts as you're forced to use worse language constructs. If you think Bash
scripts are bad, POSIX conforming shell scripts are even worse.

Bash has extended the POSIX standard shell scripting language and smoothed over
many of its deficiencies (e.g. `[[ ]]` vs `[ ]`). Bash is also available almost
everywhere a standard POSIX shell is available, so there isn't a great advantage
in portability on modern systems. On relatively modern systems, the upside to
using Bash is large and the downside to using it is small when compared to
standard POSIX scripting.

## Bash is just another programming language

To write better Bash we should be writing it like we do any other programming
language. When creating software, Bash scripts too often get special treatment
in a programmer's mind. I think there are a few reasons for that. The main
reason is that Bash scripts are most often written for maintenance tasks that
don't contribute directly to new features or revenue streams. For that reason,
programmers invest very little time into maintaining and understanding Bash
scripts properly.

For something that lives with you for most of your career and causes so many
problems, programmers invest surprisingly little time into understanding them.
Fundamentally though, Bash scripts, like all languages, benefit greatly from
normal software development practices like code reviews, formatters, linters,
unit tests, libraries, and improved software architecture. If we write Bash
scripts into a single file where everything needs to be reinvented from scratch,
has no unit tests, is unreadable with improper indentation, and has easily
caught syntax bugs, it's no wonder everyone hates them.

If we want maintainable software that works reliably, we need to invest the
requisite amount of time in it. There are many tools like
[`shellcheck`](https://www.shellcheck.net/) for linting,
[`shfmt`](https://github.com/mvdan/sh) for formatting, and
[`bats`](https://github.com/bats-core/bats-core) for unit tests that can be used
to greatly improve the quality of Bash scripts.

## AI can't save us

Since Bash is a widely used language with lots of example code to train on and
no one wants to actually write or maintain it, it's tempting to have AI write it
for us.

<!-- textlint-disable spelling -->
<!-- markdownlint-disable emphasis-style -->

![A screenshot of a post from X by Cindy Sridharan (@copyconstruct) that says 'One thing AI models are *really* a godsend for ... is scripting with bash. Bash is so terrible in so many ways, yet it's ubiquitous and often the best tool for many tasks. Having AI models write most of my bash with me just having to do minor edits is such a luxury.](/assets/images/2025-10-27-bash-is-the-best-tool-for-the-job/x_cindy.png){: .align-center}

<!-- markdownlint-enable emphasis-style -->
<!-- textlint-enable spelling -->

The main issue with this is that most bash code, and thus the code the models
are trained on, isn't particularly well written. Poor programming practices are
widespread. AI models are also good at making mistakes and require programmers
who understand the code to review it.

If we want AI to write better Bash scripts, the only solution is to better
understand Bash ourselves.

## The payoff

Bash scripts are very powerful tools that have, for decades, consistently been
the best tool for the job. They are excellent for integrating different pieces
of software and systems together in a low-cost and predictable way.

<!-- textlint-disable spelling -->

![A screenshot of a Linkedin post by Kelsey Hightower that says 'One day the industry will recognize the drawbacks of AI agents and nondeterministic automation, and rediscover the UNIX philosophy of chaining together small purpose built tools in a low cost and predictable way, otherwise known as shell scripts.'](/assets/images/2025-10-27-bash-is-the-best-tool-for-the-job/linkedin_kelsey.png){: .align-center}

<!-- textlint-enable spelling -->

However, they are often overlooked when thinking about stability and
maintainability. While Bash can have rough edges, these edges can be smoothed
over if better understood and integrated into already existing software
development practices like linting, unit-testing, and code reviews.

Programmers encounter Bash scripts throughout their careers. With only a little
effort, we can achieve a really large payoff in stability and maintainability of
the software we run every day.
