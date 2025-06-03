---
layout: post
title: "Homepage Redesign"
date: 2012-12-09 23:51:42 +0000
permalink: /en/homepage-redesign
blog: en
tags: tech meta css
render_with_liquid: false
---

I recently redesigned my homepage to streamline it and give it a different look and feel. Here's what the old site looked like since I converted it to [Django](https://www.djangoproject.com/) back [3 or so years ago](http://www.ianlewis.org/en/new-django-homepage):

![image](/assets/images/689/old_homepage_big.png)

## No More Lifestream

I based the original site on the concept of a lifestream after seeking [Jon "Yongfook" Cockle](http://yongfook.com)'s homepage based in some PHP software he wrote called [sweetcron](http://code.google.com/p/sweetcron/). I had started working in Python so I wrote similar functionality to sweetcron into my own Django app called [django-lifestream](https://bitbucket.org/IanLewis/django-lifestream). It was my first Django app and I learned a lot making it so it wasn't a complete waste, but I learned, much like [Yongfook did](http://yongfook.posterous.com/why-posterous-instead-of-sweetcron), that it wasn't a good way to engage with my readers. Though I didn't really realize and internalize it until much later. While it looked cool, and web 2.0, and had embedded YouTube movies and other dodads or whatever, people just didn't look at it or care very much. I sort of knew that it wasn't a good way to interact with readers because I read Jon's blog post and understood the idea and could verify it with my own access data, but it took a while to figure out what to do instead.

The original content also ended up being a crawler sink. i.e. a bunch of pages that no one ever looked at but that web crawlers needed to crawl to index the site. The sheer number of pages and web crawler accesses slowed down my site reducing the overall usefulness. But after I implemented it sans-lifestream, there was a noticeable speedup because the site needed to be crawled much less. Whether people are better able to use the site and link to it remains to be seen.

## New Design

So I knew I needed to update the design of the site. It was done in hand made CSS by me 3 years ago, was never very fancy, and was finally getting long in the tooth. The lifestream was not used, and thus a waste of time and energy so I knew it should go. I also knew that users were coming to my site to read my blog posts or find out about me, and that since I had English and Japanese content on the site that I should give them the choice of which they wanted to read. English or Japanese if they could read it. I added this idea to the original site's top page and I carried it over to the new design which looks like this:

![image](/assets/images/689/new-top_big.png)

## Bootstrap

The original site was done with hand made CSS and I am no designer so I wanted to make this as simple as possible and get as much bang-for-the-buck as I could. This meant using a CSS framework and [Bootstrap](http://twitter.github.com/bootstrap/) is all the rage these days.

One nice thing about Bootstrap is that it implements the idea of [Responsive Design](http://en.wikipedia.org/wiki/Responsive_web_design) using media queries so, in general, the content is laid out well on mobile devices. I haven't had a lot of mobile access on the site, but I did want to make it more readable for those that do.

![image](/assets/images/689/2012-12-09_23.34.47_small.png)

## Onward

So far I'm pretty pleased with the result. The site is much easier to look at, it responds much faster, and looks good on mobile. Since I no longer have the lifestream I thought that I could just ditch Django and use [Hyde](http://hyde.github.com/) or [Pelican](http://docs.getpelican.com/en/latest/) or some other static site generator but I think I can hold off on that for a while at least. Now that I don't have to worry so much about the speed of the site I'd like to spend more time making content.
