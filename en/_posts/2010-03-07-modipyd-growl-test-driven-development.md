---
layout: post
title: "Modipyd with Growl Notifications and Test Driven Development"
date: 2010-03-07 15:54:09 +0000
permalink: /en/modipyd-growl-test-driven-development
blog: en
tags: growl modipyd pyautotest
render_with_liquid: false
---

<!-- textlint-disable rousseau -->

Recently at work my coworker [Shinya
Okano](http://d.hatena.ne.jp/nullpobug/) came across
[Modipyd](http://www.metareal.org/p/modipyd/) written by [Takanori
Ishikawa](http://twitter.com/takanori_is). Modipyd is a module
dependency monitoring framework which can build module dependency trees
and monitor when modules have been changed. But most interesting feature
it provides is the pyautotest tool.

pyautotest is a small daemon that will monitor modules in a project and
automatically run tests that depend on a particular module when the
module changes. This comes in really handy when writing python libraries
and tools.

When run on the console it looks something like this:

```shell
ian@macbook-ian:~/src/mylib$ pyautotest
....
----------------------------------------------------------------------
Ran 4 tests in 0.002s

OK
..........
----------------------------------------------------------------------
Ran 10 tests in 0.001s

OK
```

Here I edited a couple files and pyautotest ran the tests that are
dependent on those files.

Now to the really cool part. My other coworker [Yosuke
Ikeda](http://twitter.com/ae35) wrote a test runner that will invoke
growlnotify and show a growl message with the results of each test run.
Inspired by this I went ahead and added support for libnotify on Linux
using pynotify and [Shinya Okano](http://d.hatena.ne.jp/nullpobug/)
added support for Windows with Snarl.

![Growltestrunner](http://www.ianlewis.org/gallery2/d/12119-2/growltestrunner.png)

When combined with pyautotest this makes for a really cool test driven
development tool. Every time you save a file you get a notification if
you did something dumb and broke a dependent test. Just install
growltestrunner:

```shell
hg clone https://bitbucket.org/ae35/growltestrunner/
cd growltestrunner
python setup.py install
```

... and invoke pyautotest in your project directory like below

For growl:

```shell
pyautotest -r growltestrunner.GrowlTestRunner
```

For pynotify:

```shell
pyautotest -r growltestrunner.PynotifyTestRunner
```

For Snarl:

```shell
pyautotest -r growltestrunner.SnarlTestRunner
```

<!-- textlint-enable rousseau -->
