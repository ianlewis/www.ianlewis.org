---
layout: post
title: "Make Firefox look like Chrome"
date: 2008-11-27 14:02:52 +0000
permalink: /en/make-firefox-look-like-chrome
blog: en
tags: tech
render_with_liquid: false
---

> **Update (2026/05/24)**: Most of the links on this page are unfortunately no longer working
> and have been removed.

Recently [Google Chrome](https://www.google.com/chrome/) has been pretty popular
with web folks and Google fans. It's fast and has only a little "chrome" or
window trimmings which makes the overall screen bigger when viewing web pages.
However, it lacks a lot of features that are present in
[Firefox](https://www.firefox.com/) that I pretty much can't do without so today
I set about making Firefox have all the small interface improvements that make
Chrome so nice. Fortunately you can do this with existing plugins.

The first thing I did was try to reduce Firefox's "chrome" by tightening up the
menus. I right-clicked on the menu in the top and hit "Customize" which lets
me customize the menu bars. I put the navigation buttons (back, forward, stop,
etc.), bookmark buttons, home, toolbar bookmarks, navigation bar and search bar
all in the same toolbar. I hid all other toolbars. I hid the status bar by
selecting the checkbox under View `->` Show status bar.

I then realized that I almost never use the menu bar (File, Edit etc.) and I
could hide this. Unfortunately you can't get rid of the menu bar in the default
Firefox. This is where the _Hide Menubar_ add-on comes in. This plugin is very
simple as it simply allows you to hide the menu bar like any other toolbar. You
can show it again temporarily by hitting alt. Very useful.

Next I went about adding a start page. I came across a blog post which suggested
using the _New Tab Jumpstart_ add-on which is the most like Google Chrome's
start page. However, the one I settled with was the _Fast Dial_ add-on which is
more like Opera's speed dial.

Chrome has dynamic context menus that change based on what you have selected,
what you are clicking on etc. This functionality was implemented in the
_FFChrome_ add-on.

Chrome's omnibox is pretty cool. You can get similar functionality but not quite
as good from the _Omnibox_ Firefox add-on. Firefox's omnibox ties into the
registered search engines in Firefox and requires that you type `@youtube` or
the like for search engines other than the default.

You can hide window trimmings to maximize window space a bit more by using the
_Hide Titlebar_ add-on. However, this didn't work well for me in Linux, so I
don't use it there.

For those that want to really make it look like Chrome you can install the
Chrome theme which is actually pretty darn good and beats the bulky, tall, tabs
in the default theme.

When you put that all together it looks something like this:

![Screenshot of Firefox with a smaller UI footprint](/assets/images/gallery/screenshot.png){:style="width: 60%; display:block; margin-left:auto; margin-right:auto"}

Now I have a much more usable and productive browser and still have access to
all the nice Firefox plugins that I use regularly Firebug and Delicious
bookmarks.
