---
layout: post
title: "Windows Vista SuperFetch"
date: 2009-06-29 00:11:25 +0000
permalink: /en/superfetch
blog: en
tags: windows superfetch thrashing vista
render_with_liquid: false
---

I don't use Windows Vista that often but when I do it would thrash at
the hard drive constantly for hours. Not knowing what the problem is I
looked it up and it is aparently the "SuperFetch" service. Using the
following steps to disabled it stops the thrashing on the hard drive
almost immediately.

- Go to control panel \> administrative tools \> services.
- Right click on the "SuperFetch" service and click Properties.
- Set the service to disabled and hit Ok.
- Right click on the service again and click "Stop" to stop it.
