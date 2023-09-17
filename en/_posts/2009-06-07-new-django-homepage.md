---
layout: post
title: "New Django-based Homepage"
date: 2009-06-07 00:06:01 +0000
permalink: /en/new-django-homepage
blog: en
tags: django homepage pygments
render_with_liquid: false
---

I finally got around to finishing up my
[Django](http://www.djangoproject.com/) based website. It's pretty
inexcusable for a Django developer to have a PHP based blog website. I'm
happy that it seems to be snappier and I haven't don't anything
particular to try to make it fast so that means I can probably make it
even speedier by optimizing delivery of static content, and some caching
since the blog and some other content doesn't change that often.

This is also my first post that I'm writing in [Restructured
Text](http://docutils.sourceforge.net/docs/user/rst/quickstart.html).
I'm starting to write pretty much all of my documentation so hopefully
I'll get used to it sooner or later.

The lifestream on the homepage is my own creation
[django-lifestream](http://bitbucket.org/IanLewis/django-lifestream/)
I've kind of been developing it within the context of this website so I
haven't been updating the project itself as often as I should. But look
for updates as I'll probably be polishing it up a bit in the coming
weeks. It is also my first django application so some of the code and
design is kind of crufty. Use with care. The code for the actual website
is housed in a separate repository from the lifestream app. It's located
in my [homepage](http://bitbucket.org/IanLewis/homepage/) repository.

I did implement code highlighting support for blog posts using
[pygments](http://pygments.org/). It's taken mostly from Brian Rosner's
blog [oebfare](http://github.com/brosner/oebfare/tree/master).
Highlighting is done something like the following:

```rst
.. code-block:: python

   some python source code here
```

There isn't any preview functionality yet so I will need to do that soon
also or else I'll be publishing some half baked looking blog posts.

Also, I think I got most things but there may be broken links and bugs
on the site so if you see one let me know on
[Twitter](http://twitter.com/ianmlewis).
