---
layout: post
title: "My Love-Hate Relationship with JavaScript"
date: 2012-05-01 09:01:09 +0000
permalink: /en/my-love-hate-relationship-javascript
blog: en
tags: tech programming javascript
render_with_liquid: false
---

I have a love-hate relationship with JavaScript. Well, more hate and less love
but I find myself conflicted when I write it. JavaScript simply makes it hard
for me to write good code. As a little background, the JavaScript I write is
almost exclusively meant to run in the browser. I don't do node.js or rhino
(I'll get to that later).

![](/assets/images/677/javascript_the_evil_parts_small.png)

## Writing Modular Code Sucks

JavaScript makes it hard to write modular code. Most sane languages give you a
way to sensibly scale your code base. They allow you to put code into containers
that have clear APIs and their own scope or namespace so you don't collide with
other variables etc. In Java these are packages. In Python these are modules.
JavaScript has no such thing. You need to implement scoping in the language by
wrapping your code in an anonymous function. Most languages also allow you to
see and manage dependencies for a module. In C/C++ you have includes. In Java and
Python you have imports. In JavaScript you have no such thing. Node.js has it's
own kind of way to load JavaScript from other files but in the browser this
usually means a expensive synchronous HTTP request via a script tag so you want
to mitigate this as much as possible which adds a lot of complexity and
convention to your code. It looks something like this:

```html
<script type="text/javascript" src="/static/js/jquery.js"></script>
<script type="text/javascript" src="/static/js/jqmodal.js"></script>
<script type="text/javascript" src="/static/js/jquery.ui.custom.js"></script>
<script type="text/javascript" src="/static/js/mylib.js"></script>
```

These will generate an HTTP request and be loaded inline synchronously which
will slow down the load of your page noticeably.

The only sane attempt I've seen to do this is RequireJS which works well enough
but it's impossible to debug if you have problems. To its credit, it works well,
loads modules asynchronously, and reuses the results of already loaded modules.

A RequireJS module looks like this:

```javascript
define('mymodule', ['jquery'], function(jQuery) {
    ...
    return MyModule;
});
```

You give the define function a name of your module (can be omitted and then it
takes the name from the file that it was loaded from), a list of dependencies
and a function that takes the dependent modules as arguments. When a modules is
loaded the given function is run and the return value of the function is passed
to dependent modules as arguments. This limits the scope.

In order to make modular code that has separate scopes to mitigate collisions
and keep code as simple to understand as possible, you need separate the code
into modules that makes sense based on the on the work the code is responsible
for. This is really hard for browser based JavaScript because extra files
usually means extra HTTP requests to get the required modules/files so you need
to bundle your code up into one file if you want to minimize the amount of
requests you need to do on each page. This is especially problematic for new
visitors who have an empty browser cache. Which brings me to my next point:

## Size matters

For code that needs to be loaded, compiled, and run at run-time like JavaScript,
size matters. I matters in how much you have to download and when parsing and
executing the code. This is usually solved by bundling multiple files into one
to minimize HTTP requests and minifying or compressing the JS. This works
extremely well and is pretty much necessary if you have more than a few modules.
I also don't want to worry about the extra size that comes with whitespace or
comments to my JS code. In most programming languages whitespace and comments
don't impact the speed of the program by in JavaScript it can have a noticeable
impact on performance.

As a side note, one of the nice things about using RequireJS is that it
includes a tool to do the bundling and minimizing for you.

## Testing

JavaScript is starting to get some good testing tools but most testing tools and
runners are fairly primitive and have few options or test discovery and running
subsets of tests. Qunit seems fairly decent though I don't like how it runs all
tests automatically. It would be much easier to use if it would discover the
tests and give them to me in a hierarchical list that I could then use to run
all or a subset of the tests.

I also don't like how it's `noglobals` mode gets tripped up by the random globals
that jQuery makes when it does JSONP or that jQuery UI makes when you use the
date picker. Mocha seems too focused on server side tests and it's browser based
runner leaves something to be desired. The normal assert library used with
mocha, expect.js, tries way too hard to be natural language.
`expect(x).to.be.an(Array)` or `expect(x).to.not.be.ok()` is just gross. You
have objects in objects in objects needlessly. I fail to understand if you
wouldn't have this in normal code, why would you put it in tests?

## Linting & Dev Tools

Checking for errors in code is pretty important if you want to write bug free,
robust code. In Java you have tools like Eclipse or IntelliJ or NetBeans, in
Python you have PyCharm or Pyflakes. In JavaScript you surprisingly have a
decent amount of tools here. [JetBrains](http://www.jetbrains.com/) (from the
makers of IntelliJ), [NetBeans](http://www.netbeans.org/), and
[Aptana](http://www.aptana.com/) all work well. I simply use `jslint` on my code
to spot errors. This works ok but not great in my editor of choice, vim.

There are folks who think that `jslint` is annoying and decide to write their
own linters or just don't use one because they've read the JS spec and have
"learned" how to write according to spec. As if since they read the spec and now
their JS is perfect or as if their code would always pass `jslint` or that
`jslint` points out things that really aren't a problem (they are). Like you
would ever want to support decimal, hex, and octal conversion when using
`parseInt()` or you would ever want things like x being 0 to cause a `x ==
undefined` check to pass.

## I just want to break free

![](/assets/images/677/break_free_medium.jpg)

In the end, I feel like I just want to program JavaScript just like any other
language. The fact that it gets loaded and run by a browser over HTTP shouldn't
mean that I have to write spaghetti code in one file or synchronously load JS
from many files just because that's the way I chose to organize it.

Though they have come a long, long way in recent years, I feel limited by JS's
development tools and environment. I really wish there was a better, easier way
to do the right thing and make use of programming best practices learned from
other languages when it comes to coding JavaScript.

RequireJS specifically is like Python's `pip`. It was developed separately from
the standard development environment to make up for an area in which the tools
were lacking. In pip's case, it tried to fix Python packaging. In RequireJS's
case it tries to fix module loading. Though recently in Python there has been
talk about including support for virtualenvs and better packaging support in the
language thanks to pip's lead. JS needs the features required for loading client
side code properly built into the browser and JS development environments and
tools should include support for minimizing (or perhaps bytecode compiling)
JavaScript so that whitespace, comments, and number of modules don't affect
download and load speed.

![](/assets/images/677/html5_thumbnail.png)

No wonder native apps for the iPhone are eating the lunch of HTML5 apps. HTML5
are slow, have a crappy development environment and require you to know a lot of
obscure things to get around these issues and make apps work properly. The web
has a lot of advantages that mostly derive from the protocols it runs on, TCP
and HTTP, and only to a lesser extent HTML and JavaScript.

I don't know what that would look like but I have a feeling it would be
radically different from what the environment is like today. The sooner we can
radically improve HTML and JavaScript the better.
