---
layout: post
title: "Twitter Page Code"
date: 2008-06-19 19:14:11 +0000
permalink: /en/twitter-page-code
blog: en
tags: tech programming
render_with_liquid: false
---

![Twitter](/assets/images/gallery/twitter.png)

I took a look at [Twitter](http://www.twitter.com/)'s code as an example of a site that gets lots of traffic and noticed a couple things.

1. They use [Amazon S3](http://www.amazon.com/gp/browse.html?node=16427261) to store images
2. They split the javascript, favicons, and css up across 3 or 4 subdomains (assets0.twitter.com, assets2.twitter.com, etc.)
3. They include [prototype](http://www.prototypejs.org/) and a version of [jQuery](http://jquery.com/) as well as a version of [script.aculo.us](http://script.aculo.us/).

```html
<script
    src="http://assets3.twitter.com/javascripts/prototype.js?1213829093"
    type="text/javascript"
></script>
<script
    src="http://assets1.twitter.com/javascripts/effects.js?1213829093"
    type="text/javascript"
></script>

<script
    src="http://assets0.twitter.com/javascripts/application.js?1213829093"
    type="text/javascript"
></script>
<script
    src="http://assets0.twitter.com/javascripts/jquery-1.2.3.min.js?1213829093"
    type="text/javascript"
></script>
```

It kind of surprised me that they include a version of prototype _AND_ [jQuery](http://jquery.com/) _AND_ script.aculo.us since they aren't really light javascript files. Prototype comes in at 123kb, [jQuery](http://jquery.com/) is 53kb, and script.aculo.us is 38kb. Seems to me that even with caching and all they could significantly reduce download traffic by sticking to one javascript library. I'm sure there is some weird reason they do it though.
