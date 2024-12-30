---
layout: post
title: "Phantom QUnit Test Runner"
date: 2012-12-26 15:00:00 +0000
permalink: /en/phantom-qunit-test-runner
blog: en
tags: javascript phantomjs qunit
render_with_liquid: false
---

<!-- textlint-disable rousseau -->

![image](/assets/images/690/phantomjs+qunit.png)

I have been using [PhantomJS](http://phantomjs.org/) and
[QUnit](http://qunitjs.com/) for a while now to run JavaScript automated
tests. I like QUnit because has a decent in-browser UI but also has a
nice extension API so you can create plugins and output in different
formats if you like.

However, I've been spoiled by test runners like the Python test runners
that create output that is easy to parse with the eyes, shows you
tracebacks, and lets you specify filters to limit which tests get run.
Most JavaScript test runners aren't very flexable. QUnit allows you to
filter tests, and this can be done easily by adding a simple filter
parameter to the URL of your test html page. But the test runners people
have written for the console aren't that friendly.

I would also like to do is output test results in different formats like
JUnit. Most QUnit test runners I've seen only output in one format and
aren't very flexible.

Another problem I've found with other test runners, is that they don't
handle errors in a robust way. PhantomJS allows you to set an error
handler by passing a function to the `page.onError()` method. But if you
modify the `window.onerror` callback like QUnit does, the
`page.onError()` handler doesn't get called. This can be annoying
because your test runner may not be able to know when something has gone
wrong and it needs to quit.

Given all these problems I thought that, as with many other things in
JavaScript land, the only get all the things I wanted was to write it
myself. So I wrote a nice little PhantomJS QUnit test runner script.

Because phantomjs' command line interface isn't terribly friendly I
included a simple python wrapper that is a bit easier to use. It takes
the URL or path to your QUnit HTML file and accepts a number of options:

```shell
$ ./runner.py --help
Usage: runner.py FILE_OR_URL [filter] [options]

Run QUnit tests.

Options:
  -h, --help        show this help message and exit
  --output=OUT      The test output format. [console, junit, tap] (Default:
                    console)
  --errorcode=CODE  The error code to use when the test fails.
  --noglobals       Invoke QUnit with the noglobals setting.
  --notrycatch      Invoke QUnit with the notrycatch setting.
  --abbrev          Abbreviated console output.
```

# Console Output

The default console output takes inspiration from
[mocha.js](http://visionmedia.github.com/mocha/) test runner and the
Python test runner. Console output for a test run looks like the this:

```shell
$ ./runner.py example/index.html
Tests Started

mymodule

     Equal Test
        ✓ ok() check (0.001s)
        ✓ equal() check (0.001s)
        ✓ Passed Test (0.001s)
     OK Test
        ✓ ok() check (0.001s)

othermodule

     OK Test
        ✓ ok() check (0s)

----------------------------------------------------------------------
Ran 5 tests in 0.099 secs

OK
```

A failed test run produces a failure report including tracebacks:

```shell
$ ./runner.py example/index.html mymodule
Tests Started

mymodule

     Equal Test
        ✓ ok() check (0.001s)
        ✓ equal() check (0.001s)
        ☓ Failed Test (0.001s)
     OK Test
        ✓ ok() check (0s)

======================================================================
FAIL: Equal Test(mymodule)
----------------------------------------------------------------------
Failed Test
    at file:///home/ian/src/phantomjs-qunit/example/qunit.js:435
    at file:///home/ian/src/phantomjs-qunit/example/mymodule.test.js:9
    at file:///home/ian/src/phantomjs-qunit/example/qunit.js:136
    at file:///home/ian/src/phantomjs-qunit/example/qunit.js:279
    at process (file:///home/ian/src/phantomjs-qunit/example/qunit.js:1277)
    at file:///home/ian/src/phantomjs-qunit/example/qunit.js:383
----------------------------------------------------------------------
Ran 4 tests in 0.023 secs

FAILED (failures=1)
```

# Output Formats

With just a simple option change you can get JUnit XML output:

```shell
$ ./runner.py example/index.html --output=junit
<?xml version="1.0" encoding="UTF-8"?>
<testsuites name="testsuites">
    <testsuite name="mymodule" errors="0" failures="1" tests="4" time="0.002">
        <testcase classname="mymodule" name="Equal Test" time="0.002">
            <failure type="failed" message="Failed Test"/>
        </testcase>
        <testcase classname="mymodule" name="OK Test" time="0"/>
    </testsuite>
    <testsuite name="othermodule" errors="0" failures="0" tests="1" time="0">
        <testcase classname="othermodule" name="OK Test" time="0"/>
    </testsuite>
</testsuites>
```

... or TAP output:

```shell
$ ./runner.py example/index.html --output=tap
# module: mymodule
# test: Equal Test
ok 1 - ok() check
ok 2 - equal() check
not ok 3 - Failed Test
# test: OK Test
ok 4 - ok() check
# module: othermodule
# test: OK Test
ok 5 - ok() check
1..5
```

# Filters

You can apply filters to the input to determine which tests get run:

```shell
$ ./runner.py example/index.html othermodule
Tests Started

othermodule

     OK Test
        ✓ ok() check (0s)

----------------------------------------------------------------------
Ran 1 tests in 0.024 secs

OK
```

# QUnit Tests

The test runner doesn't require you to include any extra code in order
to work. Any QUnit test HTML should do. Simply create your test page and
save it to an file. You can then give the path to this file to the test
runner.

Your HTML may look as follows

```html
<!doctype html>
<html>
  <head>
    <meta charset="UTF-8" />
    <title>QUnit Example</title>
    <link rel="stylesheet" href="qunit.css" type="text/css" media="screen" />
    <script type="text/javascript" src="qunit.js"></script>

    <script type="text/javascript" src="mymodule.test.js"></script>
  </head>
  <body>
    <div id="qunit"></div>
    <div id="qunit-fixture"></div>
  </body>
</html>
```

# Code

The code is up on Github here:
<https://github.com/IanLewis/phantomjs-qunit>

The JUnit output is based on [this
gist](https://gist.github.com/1363104) by [Eric
Wendelin](https://gist.github.com/eriwen). The TAP output is based off
of [qunit-tap](https://github.com/twada/qunit-tap) by [Takuto
Wada](https://github.com/twada).

# Future

Some things to think about for the future are getting saving coverage
information using [JSCoverage](http://siliconforks.com/jscoverage/).

<!-- textlint-enable rousseau -->
