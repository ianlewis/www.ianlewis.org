---
layout: post
title: "Wanted: Dictionary program for Windows/Linux"
date: 2008-08-03 18:21:00 +0000
permalink: /en/wanted-dictionary-program-for-windows-li
blog: en
tags: tech projects
render_with_liquid: false
---

I have wanted a good dictionary application that supports a number of
dictionaries/dictionary formats for studying Japanese but I've been sort of
frustrated that there is no single application that does what I would like. I
have looked mostly at [StarDict](http://stardict.sourceforge.net/) and
[`epwing`](http://epwing.sourceforge.net/) because they are closest to the type of
dictionary I want. Specifically I have the following requirements:

1. It must work in [Linux](http://en.wikipedia.org/wiki/Linux) (`epwing` and
   StarDict)
2. It must work in Windows (`epwing` and StarDict)
3. It must support EPWING format (`epwing`)
4. It should ideally support an open dictionary format like StarDict. (StarDict)
5. It must support lookup via a
   [popup](http://stardict.sourceforge.net/images/stardict03e.gif) (`epwing` and
   StarDict)
6. It must support installing dictionaries as a non-root user (`epwing`)
7. It should support minimization to the system tray (StarDict)

1 and 2 and 5 are supported by both StarDict and `epwing` but the popup support
for `epwing` is less than ideal and `epwing` only supports EPWING format and
doesn't minimize to the system tray. The way `epwing` looks up words from
multiple dictionaries is also less than ideal,

StarDict on the other hand supports most of the things I want but doesn't
support EPWING or any way of converting the dictionaries from EPWING to StarDict
format. There are a number of tools to read EPWING dictionaries so I think this
could be done, but I don't think StarDict dictionaries currently support images
or media like EPWING dictionaries support so converting EPWING dictionaries
would lose that data. StarDict also has a  number of strange plugins and a net
dictionary protocol which seems strange. I'm not sure if the server side code is
open either.

I've been looking at the code for each of the dictionaries. While it seems like
the code for `epwing` is simpler and easier to read, StarDict supports most of
the features I want already so it would be better to explore how to add the
features I want to add. Development on both projects is pretty much halted so I
should be able to add features at my own pace without stepping on current
development.

I'm not looking forward to spending a lot of time on it but my frustration with
dictionaries has reached a bit of a boiling point.
