---
layout: post
title: "Gallery2 for WordPress"
date: 2008-04-18 11:51:03 +0000
permalink: /en/gallery2-for-wordpress
blog: en
tags: tech programming projects
render_with_liquid: false
---

I took a look at the [Gallery2 plugin for
WordPress](http://wpg2.galleryembedded.com/) by [ozgreg](http://www.ozgreg.com/)
to get some ideas on how they had integrated Gallery2 with the Wordpress blog
engine and how I might be able to bring those features to
[b2evolution](http://www.b2evolution.net/ "b2evolution"). I felt somewhat bad
looking at it as I've worked on by own [Gallery2 integration plugin for
b2evolution](http://manual.b2evolution.net/Plugins/gallery2_plugin) for about a
year and haven't really taken more than a cursory look at the WordPress
counterpart. I felt even worse when I realized how slick it is compared to my,
comparatively, rather simple integration.

The scale and amount of code was the first thing I noticed. My Gallery2 plugin
is on the bigger end, in terms of lines of code, for a
[b2evolution](http://www.b2evolution.net/ "b2evolution") plugin but the
WordPress Gallery2 plugin has a few times as much code. This might be seen as
bloat if it wasn't for the number of features that it offers.

Both of our plugins use the [Gallery image
chooser](http://g2image.steffensenfamily.com/) (`g2image`) to allow users to add
images to posts and offer single sign on between the blog and Gallery2. But
there are a number of things that the WordPress plugin either is done better
than my plugin or isn't present at all in my plugin.

- Both of the plugins allow mapping of blog users to Gallery2 but the WordPress
  plugin goes a step further and allows you to manage each user mapping and
  create and delete users in Gallery2 manually. This is a cool feature and I
  think I'm going to create something similar in
  [b2evolution](http://www.b2evolution.net/ "b2evolution")'s Gallery2 plugin.
- The WordPress plugin also offers a wider range of widgets to place in the
  sidebar and allows more customization including a customizable template. This
  is cool but the implementation is questionable as it makes use of Gallery2's
  PHP classes themselves rather than relying on the Embedded API. It also
  generates the sidebar image block itself instead of letting Gallery2 do it. I
  need to test it but I'm not sure if this works with say, the Gallery2
  multi-language plugin. I think this kind of manuvering is what precipitated
  the need for a [release compatibility
  matrix](http://wpg2.galleryembedded.com/index.php?title=WPG2:Release_Matrix)
  which I think might be a pain for users, so I plan to add some more options
  while sticking as much to the embedded api as possible.
- The WordPress plugin adds a button to TinyMCE automatically. Currently with my
  plugin you have to [jump through some
  hoops](http://manual.b2evolution.net/Plugins/gallery2_plugin#Using_the_Gallery2_Plugin_with_the_TinyMCE_Plugin).
  I would like to work with the author of the [TinyMCE
  plugin](http://manual.b2evolution.net/Tinymce_plugin) for
  [b2evolution](http://www.b2evolution.net/ "b2evolution") to allow me to
  integrate seamlessly.
- The WordPress plugin creates a page automatically that puts [your gallery
  inside
  WordPress](http://wpg2.galleryembedded.com/index.php?title=WPG2:Screenshots_of_a_Gallery2_Embedded_Page_1).
  This is pretty cool and allows users to more easily integrate their blog with
  gallery. I'd like to do something similar in
  [b2evolution](http://www.b2evolution.net/ "b2evolution").
- The WordPress plugin has some url rewrite options which seem to allow you to
  create nice permalinks inside your embedded Gallery2 page. This might be used
  somehow to preserve previous Gallery2 permalinks, or just to make nice new
  permalinks inside your WordPress blog.
- The WordPress plugin searches some common paths for your Gallery2
  installation. Simple but a useful feature that I didn't implement into my
  Gallery2 plugin.

That seems like a lot doesn't it? I really need to get to work to close these
gaps. The WordPress plugin has predated my plugin by almost 2 years and still
makes mine look like child's play in terms of features. The integration into
WordPress is pretty slick too. The menus are placed in intuitive locations
within the admin. That's something I might not be able to do in
[b2evolution](http://www.b2evolution.net/ "b2evolution") given it's rather
antiquated, plugin interface (essentially a [`Plugin`
class](http://doc.b2evolution.net/HEAD/plugins/Plugin.html) you extend
overridding any needed "hook" methods).

Anyway, look for some of these improvements in the coming weeks/months.
