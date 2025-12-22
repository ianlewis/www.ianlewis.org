---
layout: post
title: "Django サイトマップ フレームワーク"
date: 2008-11-18 21:51:26 +0000
permalink: /jp/django_sitemap_framework
blog: jp
tags: tech programming python django
render_with_liquid: false
locale: ja
---

[Django sitemap framework](http://docs.djangoproject.com/en/dev/ref/contrib/sitemaps/)を使うのが簡単過ぎる。下記のようにサイトマップクラスを作って、`urls.py`に登録するだけ。サイトマップに載るURLを取るのに、サイトマップフレームワークが自分が作ったクラスの`items()`を呼び出して、アイテムの`get_absolute_url()`を順番に呼び出す感じ。

```python
# models.py

from django.db import models
...
class Entry(models.Model):
...
    @permalink
    def get_absolute_url(self):
        return ...
...
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
...
sitemaps = {
    "blog": BlogSitemap
}
(r'^sitemap.xml$', 'django.contrib.sitemaps.views.sitemap', {'sitemaps': sitemaps})
...
```

[サイトマップインデクス](http://docs.djangoproject.com/en/dev/ref/contrib/sitemaps/#creating-a-sitemap-index)も作れる。GoogleのURL 50,000件の制限があるため、サイトマップを`Paginator`で自動的にURLを振り分けてくれる。`urls.py`をこう変えるだけ

```python
from mysite.blog.sitemap import BlogSitemap
...
sitemaps = {
    "blog": BlogSitemap
}
(r'^sitemap.xml$', 'django.contrib.sitemaps.views.index', {'sitemaps': sitemaps}),
(r'^sitemap-(?P<section>.+)\.xml$', 'django.contrib.sitemaps.views.sitemap', {'sitemaps':sitemaps})
...
```

素敵だな。後、サイトのコンテンツが変更された時、Googleが新しいコンテンツをインデクスするために `ping_google`という`manage.py`コマンドが用意してある。`python manage.py ping_google`でも、[他の検索エンジンが同じようなサービスがある](http://d.hatena.ne.jp/mstn/20080425)のに、`ping_google`しかないので、上記のようなコマンドをいくつも作っていた。
