---
layout: post
title: "Minimum cost for warming-up various frameworks(and more)"
date: 2009-10-21 13:16:31 +0000
permalink: /en/minimum-cost-warming-various-frameworksand-more
blog: en
tags: tech cloud
render_with_liquid: false
---

My good friend [Takashi Matsuo](http://takashi-matsuo.blogspot.com/) wrote an
interesting
[blog post](http://takashi-matsuo.blogspot.com/2009/10/minimum-cost-of-various-frameworks-cold.html)
about start-up times of various frameworks on App Engine. Because App Engine
kills your server process it often needs to load your application into memory
from scratch. This can take a lot of time if a lot of modules are loaded.
