---
layout: post
title: "jQuery Multi-Pageslide"
date: 2009-01-23 00:15:08 +0000
permalink: /en/jquery-multi-pageslide-1
blog: en
tags: javascript jquery
render_with_liquid: false
---

Earlier this week I came across the [jQuery Pageslide](http://halobrite.com/blog/jquery-pageslide/) plugin via
[Ajaxian](http://www.ajaxian.com/) and was impressed with the design. I set
about using it to display help messages to the user for a site I am working on.

It worked well and all but I found that you can only have one pageslide per
page. Say you want to have multiple links one one page that each invoke a page
slide but with different settings. So I made some changes to the plugin to
allow multiple pageslides per page. The demo includes a version of page slide
that allows multiple pageslide links per page and allows them all to have their
own individual settings. These all point to the same secondary page but could
just as well point to different pages. Currently they all share the same css
styles.

I made it so that only one pageslide can be open at a time. Clicking on a
pageslide link while a pageslide is already open will do nothing. I also
included a way to close the currently open pageslide from javascript.

Check out a demo here: [Demo](http://static.ianlewis.org/prod/demos/files/multi-pageslide/demo.html)

View the source:

- [demo.html](http://static.ianlewis.org/prod/demos/files/view-source/view-source.html#multi-pageslide/demo.html)
- [jquery.pageslide-0.2.js](http://static.ianlewis.org/prod/demos/files/view-source/view-source.html#multi-pageslide/jquery.pageslide-0.2.js)
