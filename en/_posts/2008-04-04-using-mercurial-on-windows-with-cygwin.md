---
layout: post
title: "Using mercurial on windows with cygwin"
date: 2008-04-04 18:40:54 +0000
permalink: /en/using-mercurial-on-windows-with-cygwin
blog: en
tags: tech mercurial
render_with_liquid: false
---

So for the longest time, well, about 5 months, I have used the mercurial package
in Cygwin as my mercurial at work where I run windows on my desktop. I use
Cygwin as my terminal on windows because it's Unix-like and the window command
line isn't very good. No sane command/path completion nothing. Scripting is a
nightmare etc. Anyway, the reason I used it was because I was under the false
impression that all other mercurial installations wouldn't play nice with Unix
paths.

Well, I was wrong. The `hg.exe` that is shipped with TortoiseHG deals with the
paths, at least relative paths, nominally (Though, I'm sure something like
Cygwin's silly `/cygdrive/c/file.txt` wouldn't work). So I've been using
Cygwin's mercurial with TortioseHG's `hgtk` and `kdiff3` for a couple of months
under the silly, wrong assumption that the `hg.exe` would junk my paths. oh
well.

Uninstall the Cygwin mercurial package and put TortoiseHG's path in my PATH
environment variable (well it was already there) and everything's dandy.
TortoiseHG just magically works on windows (though mercurial repos on the
windows network are very slow). It's nice to be able to just type `hg push` and
have it work as well as `hg merge` the same way I do at home on my Linux machine
(`hg view` is `hgtk log` though).
