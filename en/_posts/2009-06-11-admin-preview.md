---
layout: post
title: "Preview blog posts within the django admin."
date: 2009-06-11 23:12:48 +0000
permalink: /en/admin-preview
blog: en
tags: django programming
render_with_liquid: false
---

I
[implemented](http://bitbucket.org/IanLewis/homepage/changeset/a7f07d233910/)
blog post previews for my blog using the technique described here:
<http://latherrinserepeat.org/2008/7/28/stupid-simple-django-admin-previews/>

It's very simple as it is simply a view using an existing record. I'd
prefer something that allows you to preview without having to save
before you do but that would mean you would either have to put all the
data in the url as GET parameters or implement it as a post request.

A get would be ideal since you could open it in a new window but it
would require javascript and ugly urls and support for the get
parameters on your preview view. A post is nice since it wouldn't
require javascript but it would cause the browser to load the preview
page in the current window so you would have to hit back button in your
browser to get it
