---
layout: post
title: "Make Firefox look like Chrome"
date: 2008-11-27 14:02:52 +0000
permalink: /en/make-firefox-look-like-chrome
blog: en
tags: tech google
render_with_liquid: false
---

Recently [Google Chrome](http://www.google.com/chrome/intl/en/features.html)
has been pretty popular with web folks and Google fans. It's fast and has only
a little "chrome" or window trimmings which makes the overall screen bigger
when viewing webpages. However it lacks a lot of features that are present in
[Firefox](http://www.getfirefox.com/) that I pretty
much can't do without so today I set about making Firefox have all the small
interface improvements that make Chrome so nice. Fortunately you can do this
with existing plugins.

The first thing I did was try to reduce Firefox's "chrome" by tightening up the
menus. I right clicked on the menu's in the top and hit "Customize" which lets
me customize the menu bars. I put the navigation buttons (back, forward, stop,
etc.), bookmark buttons, home, toolbar bookmarks, navigation bar and search bar
all in the same toolbar. I hid all other toolbars. I hid the status bar by
selecting the checkbox under View `->` Show statusbar.

I then realized that I almost never use the menubar (File, Edit etc.) and I
could hide this. Unfortunately you can't get rid of the menubar in the default
Firefox. This is where the [Hide
Menubar](https://addons.mozilla.org/en-US/firefox/addon/4762) Addon comes in.
This plugin is very simple as it simply allows you to hide he menu bar like any
other toolbar. You can show it again temporarily by hitting alt. Very useful.

Next I went about adding a start page. I came across [this blog
post](http://techie-buzz.com/featured/get-google-chrome-startpage-experience-in-firefox.html)
which suggested using the [New Tab
Jumpstart](https://addons.mozilla.org/en-US/firefox/addon/8914) which is the
most like Google Chrome's start page but the one I settled with was the [Fast
Dial](https://addons.mozilla.org/en-US/firefox/addon/5721) which is more like
Opera's speed dial.

Chrome has dynamic context menus that change based on what yau have selected,
what you are clicking on etc. This functionality was implemented in the
[FFChrome](http://www.binaryturf.com/free-software/ffchrome-for-firefox/)
addon.

Chrome's omnibox is pretty cool. You can get similar functionality but not
quite a good from the
[Omnibox](https://addons.mozilla.org/ja/firefox/addon/8823) Firefox addon.
Firefox's omnibox ties into the registered search engines in firefox and
requires that you type `@youtube` or the like for search engines other than
the default.

You can hide window trimmings to maximize window space a bit more by using the
[Hide Titlebar](https://addons.mozilla.org/ja/firefox/addon/9256) addon. This
didn't work well for me in Linux however so I don't use it there.

For those that want to really make it look like chrome you can install the
[Chrome theme](https://addons.mozilla.org/en-US/firefox/addon/8782) which is
actually pretty darn good and beats the bulky, tall, tabs in the default theme.

When you put that all together it looks something like this:

![](/assets/images/gallery/screenshot.png){:style="width: 60%; display:block; margin-left:auto; margin-right:auto"}

Now I have a much more usable and productive browser and still have access to
all the nice Firefox plugins that I use regularly Firebug and Delicious
bookmarks.
