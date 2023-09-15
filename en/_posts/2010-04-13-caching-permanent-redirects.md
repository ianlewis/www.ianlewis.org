---
layout: post
title: "Caching Permanent Redirects"
date: 2010-04-13 14:47:03 +0000
permalink: /en/caching-permanent-redirects
blog: en
---

Since I've started using Chrome as my main browser for surfing I have
noticed that some web applications seem to redirect to 404 pages. After
some investigation it seems that the browser caches 301 responses (they
are permanent after all) and when going to that URL again automatically
redirects you.

This is a standard and correct thing to do since it saves HTTP requests
but many websites/webapps haven't used redirects and permanent redirects
properly. Many return permanent redirects when redirecting after a login
page or user action. I suppose many people think that it's the better
thing to do since it's more "[SEO
Friendly](http://www.theinternetdigest.net/archive/301-redirects-seo.html)"
or somesuch.

This kind of thing looks ok when they are developing it as 301 and 302
have very similar affects on the browser, but they really mean different
things.
