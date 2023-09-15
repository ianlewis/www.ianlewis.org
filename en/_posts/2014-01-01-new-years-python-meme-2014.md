---
layout: post
title: "New Year’s Python Meme 2014"
date: 2014-01-01 15:30:00 +0000
permalink: /en/new-years-python-meme-2014
blog: en
render_with_liquid: false
---

Since [everyone](http://blog.hirokiky.org/2013/12/31/new_years_python_meme_2013.html) [else](http://pelican.aodag.jp/new-years-python-meme-2014.html) was doing it I thought I'd write one up too.

## What’s the coolest Python application, framework or library you discovered this year?

* [Luigi](https://github.com/spotify/luigi): A data processing pipeline framework written by some folks at Spotify. I gave a [talk](http://www.youtube.com/watch?v=iwUbKPFtQRA) on it at last year's PyCon APAC.
* [Numba](http://numba.pydata.org/): A just-in-time compiler that compiles annotated Python (and numpy) code to LLVM bytecode. It's interesting it that you could use it to speed up particularly slow parts of Python code.

## What new programming technique did you learn this year?

Not much learning of new programming techniques per se, but I did learn some other things. 

I've been out of Java development for a while and took a look at Android to get up to speed.

* Android App Developent
* Dependency Injection
* Java Generics
* Java > 1.4 language changes.

## Which open source project did you contribute to the most this year? What did you do?

Not much contributing to open source this year. Mostly just bug fixes and merging pull requests.

* [django-storages](https://bitbucket.org/david/django-storages): Mostly testing, commenting on and merging pull requests.
* [django-ses](https://github.com/hmarr/django-ses/pull/52): An as of yet unmerged pull request for bounce message processing
* [Sinon.js](https://github.com/cjohansen/Sinon.JS): A small bug fix in timer mocking
* [redis-mock](https://github.com/connpass/redis-mock): An in memory mock for a Redis server that acts as a drop in replacement for [redis-py](https://github.com/andymccurdy/redis-py). Currently implements a subset of redis operations.

* [Perfect Python](http://gihyo.jp/book/2013/978-4-7741-5539-5?ard=1388556176) (Japanese): A book I helped write was also released in 2013

## Which Python blogs, websites, or mailing lists did you read the most this year?

Usually I read source code on github/bitbucket.  I don't really read blog posts but when I do it's usually:

* [Tarek Ziadé](http://ziade.org/)
* [tokibito](http://d.hatena.ne.jp/nullpobug/)
* [aodag](http://pelican.aodag.jp/)

## What are the top three things you want to learn next year?

* [asyncio](http://docs.python.org/3.4/library/asyncio.html)
* [Numba](http://numba.pydata.org/)
* [Haskell](http://www.haskell.org/)
* More [Go](http://www.golang.org/)

## What is the top software, application or library you wish someone would write next year?

I want more tools that help make python a more modern language.

* Better async tools. i.e. green-threads + queues (like go).
* A Python code formatter that re-formats code to be compliant with pep-8 in the same spirit as gofmt. ([autopep8](https://pypi.python.org/pypi/autopep8/) seems reasonable)
* A Python code processor that helps verify the "correctness" of code and/or comments. Annotating code or checking docstrings might be interesting.