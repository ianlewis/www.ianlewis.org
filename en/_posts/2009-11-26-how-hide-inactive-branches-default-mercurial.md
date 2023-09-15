---
layout: post
title: "How to Hide Inactive Branches by Default with Mercurial"
date: 2009-11-26 16:53:44 +0000
permalink: /en/how-hide-inactive-branches-default-mercurial
blog: en
---

mercurial usually shows inactive branches when running "hg branches" but
that's kind of annoying if you have lots of old inactive branches. So I
recently set up my personal .hgrc to hide inactive branches by creating
an alias.

``` text
[alias]
branches = branches -a
```

Normally you get this kind of output.

``` text
ian@laptop:~/src/prj$ hg branches
default                     1662:1fa310d3052a
hoge                        1661:62d737e7146e
hoge_inactive               1623:ba27ba59a257 (inactive)
hoge_closed                 670:1c3134ca4a95 (closed)
```

But after setting up the alias inactive branches aren't shown.

``` text
ian@laptop:~/src/prj$ hg branches
default                     1662:1fa310d3052a
hoge                        1661:62d737e7146e
```

This way though there isn't a good way to show all branches if you have
set up an alias so you might want to give the alias a different name
like "abranches" for "active branches" so that you can show all branches
by using "hg branches".
