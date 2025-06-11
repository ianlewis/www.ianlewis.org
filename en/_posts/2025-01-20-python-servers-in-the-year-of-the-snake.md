---
layout: post
title: "Python Servers in the Year of the Snake: 2025"
date: 2025-01-20 00:00:00 +0000
permalink: /en/python-servers-in-the-year-of-the-snake
blog: en
tags: tech programming python
render_with_liquid: false
image: /assets/images/2025-01-20-python-servers-in-the-year-of-the-snake/python_snake.png
---

![](/assets/images/2025-01-20-python-servers-in-the-year-of-the-snake/python_snake.png){:style="width: 40%; display:block; margin-left:auto; margin-right:auto"}

This year is the [year of the snake in the Chinese
Zodiac](<https://en.wikipedia.org/wiki/Snake_(zodiac)>). Every 12th year is a
bit of a special year for the Python community in Asia. For example in 2013, in
the last year of the Snake, the theme for the PyCon JP conference was [“The
Year of Python”](https://apac-2013.pycon.jp/ja/about/index.html). This year is
an especially good opportunity to reflect on the state of Python and how my
relationship with it has changed personally over the last 12 years.

Python has a very diverse community of academics, data scientists, DevOps
engineers, security engineers, and many many others but one group of
programmers that Python has clearly lost are server developers.

## The Python 3 Debacle

In 2025 the Python community has largely moved on but in 2013 the latest
version of Python was 3.3 and the migration from Python 2 to Python 3 was very
much in full swing. Many library authors spent a good deal of effort to make
their libraries usable on both 2 and 3 using
[2to3](https://docs.python.org/3.12/library/2to3.html) or
[six](https://pypi.org/project/six/). When Python 3.0 was released in 2008 it
was said that it would take a decade to migrate.

In the end it took 12 painful years before the final version of Python 2
reached end-of-life. While I acknowledge that many of the changes make Python
more accessible to newcomers and non-programmers, as a Python developer the
changes felt largely cosmetic. Changing the `print` function to be a proper
function, `unicode` becoming `str`, and `str` becoming `bytes` were some of the
most obvious changes. Sure there were new additions that no one uses now like
`asyncio`, but in the end, there weren’t any transformative new features for
all the work that went into migrating.

## Concurrency not Parallelism

A bit before the last Year of the Snake in 2013, when Python 3 was new, there
was much discussion about the future of Python from a performance standpoint.
Major companies like Dropbox and Instagram used Python as their primary
languages. Projects like [pypy](https://pypy.org/) existed to improve
performance and experiment with removing the Global Interpreter Lock (GIL).
Python 3 felt like it could be a good opportunity to make changes to the
language that could remove some of the pain points that server developers had.

There is a good reason that the `asyncio` library’s
[documentation](https://docs.python.org/3/library/asyncio.html) uses the word
“concurrent”. It’s because Python still can’t run code in parallel without
creating a new Python process. Coupled with the [huge
slowdown](https://apenwarr.ca/diary/2011-10-pycodeconf-apenwarr.pdf) you get
from the Python interpreter itself, this makes it really difficult to use for
writing servers. [PEP 703](https://peps.python.org/pep-0703/) proposed making
the GIL optional and this was experimentally added to 3.13 but this is a very
recent addition and too-little-to-late.

Dave Cheney wrote a [very good
article](https://dave.cheney.net/2015/08/08/performance-without-the-event-loop)
(circa 2015) outlining the trends in hardware that additionally form the
rationale for new languages. Avery Pennarun at Tailscale also wrote a very good
article on [improvements to computing
tech](https://tailscale.com/blog/living-in-the-future) in the last couple
decades. Python is just not very well positioned to take advantage of any of
the advancements that were outlined there. Languages like Java, with proper
parallelism are better able to take advantage of the increasing number of cores
on CPUs. More modern languages, like Go or Rust, in addition to supporting
parallelism are also compiled to native code making them much more performant.

Instead of making major changes Python has, perhaps understandably, decided to
play to its strengths and focus on academics like science and math, and
embedded applications where folks can make use of Python’s approachability and
where the performance issues can be mitigated by deferring to C extensions.

## Python is Glue

As I moved on from writing Python for server projects, Python’s strength in
tying different systems together hasn’t changed. It’s still a great language
for writing intuitive code to tie together disparate systems and libraries via
its vast catalog of packages and its C API. This is perhaps why it works so
well in the areas of data science, machine learning, and automation. In playing
to its strengths, [Python still manages to
grow](https://github.blog/developer-skills/programming-languages-and-frameworks/why-python-keeps-growing-explained/)
outstripping Java to become the second most used language on GitHub.

However, industry trends mean Python is not the best choice for server
applications and hasn’t been for a while. To be fair, other non-JIT interpreted
languages like Ruby suffer from this problem as well, but there really isn’t
any reason to choose Python for server projects when there are so many mature
alternative languages out there.

> NOTE: The image at the top of this post was generated by Gemini 1.5 Pro using
> the prompt "Generate an image that I can add to the following article. The
> image must have a transparent background.". It was further edited to remove
> the background and make it transparent.
