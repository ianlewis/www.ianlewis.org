---
layout: post
title: "Feedparser and Django"
date: 2008-10-30 19:13:52 +0000
permalink: /en/feedparser-and-django
blog: en
tags: tech programming python django
render_with_liquid: false
---

Over the weekend at Python Onsen I worked on a lifestream web application using
Django and [`feedparser`](http://www.feedparser.org/). I was really impressed
with how simple `feedparser` is to use and how easy it is to get unified results
from atom or RSS feeds. You simply import `feedparser` and call
`feedparser.parse` to parse a feed from a URL.

```python
# feeds.py

def update_feeds():
  feeds = Feed.objects.filter(feed_deleted=False)
  for feed in feeds:
    try:
      feed_items = feedparser.parse(feed.feed_url)
      for entry in feed_items['entries']:
        # ...
```

You can check out [`feeds.py` on
Bitbucket](http://bitbucket.org/IanLewis/django-lifestream/src/a64fcf2090a1/dlife/lifestream/feeds.py).

The interesting bit comes with how I had to parse the dates which sometimes
include timezone info and other goodies. In my search for a solution to the
problem of how to deal with dates in various formats I turned came across this
[blog entry](http://www.deadlybloodyserious.com/2007/09/feedparser-v-django/)
which describes the problem and some possible solutions. The solution I used
was the simplest and most robust (please skip the comments talking about taking
a slice of the date string). I used Mikael's suggestion from the comments and
used the `dateutil.parser` to parse the date string into a proper `datetime`
object.

```python
# Parse to an actual datetime object
date_published = dateutil.parser.parse(date_published)
```

This however leaves timezone info on the timestamp which isn't supported by
MySQL so I hand rolled some code convert the timestamp to UTC and remove the
timezone info.

```python
# Change the date to UTC and remove timezone info since MySQL doesn't
# support it
date_published = (date_published - date_published.utcoffset()).replace(tzinfo=None)
```

I'm not sure this works in all situations yet so I might go with something like
[how another commenter solved the
problem](http://intertwingly.net/blog/2007/09/02/Dealing-With-Dates) by
converting the parsed date to a UTC timestamp before converting to a
`datetime` object. I think either way would work but which is cleaner and less
prone to breakage, I'm not sure.
