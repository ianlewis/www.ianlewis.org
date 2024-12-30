---
layout: post
title: "Django redirect_to はnon-ascii URLに対応してない"
date: 2009-09-22 12:19:28 +0000
permalink: /jp/django-redirect_to-non-ascii-url
blog: jp
tags: django redirect redirect_to
render_with_liquid: false
---

<!-- textlint-disable rousseau -->

Django は一般的なリダイレクトするビューを django.views.generic.simple.redirect_to
に用意していますけど、unicodeのキーワードがあれば、動かないのが最近見つけた。

Djangoプロジェクトのurls.pyでこういう風にURLの設定を書けます。

```python
from django.conf.urls.defaults import *

urlpatterns = patterns('django.views.generic.simple',
    url(r'^jp/(?P<tag_name>.+)\;', 'redirect_to', {'url': '/jp/tag/%(tag_name)s'}),
)
```

そうした場合、redirect_to は
tag_nameに入ったデータをリダイレクト先にURLに入れてくれます。が、そのデータはasciiでない場合、redirect_to
の中にtag_nameのデータに入れたURLを
urlquoteに特に渡すなど、特に何もしないで、HttpResponseRedirectに渡す。redirect_toはDjango
1.1でこの通り

```python
def redirect_to(request, url, permanent=True, **kwargs):
    """
    Redirect to a given URL.

    The given url may contain dict-style string formatting, which will be
    interpolated against the params in the URL.  For example, to redirect from
    ``/foo/<id>/`` to ``/bar/<id>/``, you could use the following URLconf::

        urlpatterns = patterns('',
            ('^foo/(?P<id>\d+)/$', 'django.views.generic.simple.redirect_to', {'url' : '/bar/%(id)s/'}),
        )

    If the given url is ``None``, a HttpResponseGone (410) will be issued.

    If the ``permanent`` argument is False, then the response will have a 302
    HTTP status code. Otherwise, the status code will be 301.
    """
    if url is not None:
        klass = permanent and HttpResponsePermanentRedirect or HttpResponseRedirect
        return klass(url % kwargs)
    else:
        return HttpResponseGone()
```

最終的に、この問題が起こる時に、このエラーが出る。

```text
UnicodeEncodeError: 'ascii' codec can't encode characters in position 8-11: ordinal not in
  range(128), HTTP response headers must be in US-ASCII format
```

実際は下バグが既にあって、HttpResponseRedirectの中で、asciiでないURLをちゃんとエンコードするはず。

[\#11522 Crash on redirect to a relative URL if request.path is
unicode](http://code.djangoproject.com/ticket/11522)

<!-- textlint-enable rousseau -->
