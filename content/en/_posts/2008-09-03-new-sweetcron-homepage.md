---
layout: post
title: "New Sweetcron Homepage"
date: 2008-09-03 22:02:39 +0000
permalink: /en/new-sweetcron-homepage
blog: en
tags: tech meta programming php
render_with_liquid: false
---

![Sweetcron](/system/application/views/themes/boxy_but_good/images/credits.gif)

I just finished implementing [Sweetcron](http://sweetcron.com/) on my homepage.
It's a pretty architecturally bare-bones but slick feed aggregator that makes a
page containing all the most current information about you or what your are
interested in. This page is called a "lifestream" and I liked the concept
because I'm a busy person and I want to make publishing to my homepage easier so
that it doesn't become dusty and so I don't have to create blog posts on
anything and everything just to get a blurb on my homepage.

It basically aggregates feeds and puts the entries in your lifestream. Your
Twitter, Digg links, blog entries can all end up in the same place. nice. It
includes some basic blogging functionality but it's pretty lame and I have too
much invested in b2evolution to give it up so I stuck with that for my blogging.
I just simply import my blog RSS feeds into Sweetcron.

Sweetcron is made by [Yongfook](http://www.yongfook.com/), a local web
consultant here in Tokyo. I find him a bit pretentious but he seems quite
popular. He has a habit of [singing
in](http://www.yongfook.com/post/view/463/time-stormtroopers-iphone-blam) [video
blog
posts](http://www.yongfook.com/post/view/508/sneak-preview-of-the-sweetcron-admin-panel-bit)
and speaking in a voice that feels to outlandish to be real. But for any faults
he might have he seems to be successful and competent at consulting.

His programming could be better though. I'm glad he made Sweetcron because it
allowed me to do something I had been wanting to do for a while, but it required
a bit of programming to get working properly. It has a few bugs and the default
install is pretty unusable. It's written using CodeIgniter which is ok but
Sweetcron doesn't support some of its features properly. For instance, using
the database table prefix causes Sweetcron to throw SQL errors. His CodeIgniter
templates are simply PHP code files which I don't like because they end up being
programs themselves and don't separate logic and presentation very well.
CodeIgniter has it's [own
templates](http://codeigniter.com/user_guide/libraries/parser.html) but they're
lame so I kind of wish he used [Smarty](http://www.smarty.net/) which I've had
good experience with.

That said it was still pretty easy to implement and get integrated with the
[b2evolution](http://www.b2evolution.net/) site and I'm pleased with the
results.
