---
layout: post
title: "Django Sitemap Framework"
date: 2008-11-18 21:22:06 +0000
permalink: /en/django-sitemap-framework
blog: en
tags: tech programming python django
render_with_liquid: false
---

Using the Django [sitemap
framework](http://docs.djangoproject.com/en/dev/ref/contrib/sitemaps/) is so
easy it's almost no work at all. Just make a sitemap object and add it to the
sitemap in `urls.py`. The sitemap framework calls `items()` in your Sitemap to
get the list of objects to put in the sitemap and then calls
`get_absolute_url()` on each object.

```python
# models.py

from django.db import models

class Entry(models.Model):
    @permalink
    def get_absolute_url(self):
        return self.url
```

```python
# sitemap.py

from django.contrib.sitemaps import Sitemap
from mysite.blog.models import Entry

from django.contrib.sitemaps import Sitemap
from mysite.blog.models import Entry

class BlogSitemap(Sitemap):
    priority = 0.5

    def items(self):
        return Entry.objects.filter(is_draft=False)

    def lastmod(self, obj):
        return obj.pub_date

    # changefreq can be callable too
    def changefreq(self, obj):
        return "daily" if obj.comments_open() else "never"
```

```python
# urls.py

from mysite.blog.sitemap import BlogSitemap
# ...
sitemaps = {
    "blog": BlogSitemap
}
(r'^sitemap.xml$', 'django.contrib.sitemaps.views.sitemap', {'sitemaps': sitemaps})
# ...
```

You can even generate [sitemap
indexes](http://docs.djangoproject.com/en/dev/ref/contrib/sitemaps/#creating-a-sitemap-index)
and it will pagenate the indexes on Google's limit of 50,000 urls so that you
don't have a problem with it crawling your indexes.
