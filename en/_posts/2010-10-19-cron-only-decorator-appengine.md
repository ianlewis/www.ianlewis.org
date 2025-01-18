---
layout: post
title: "Cron only decorator for appengine"
date: 2010-10-19 10:54:14 +0000
permalink: /en/cron-only-decorator-appengine
blog: en
tags: tech programming python cloud google-cloud appengine
render_with_liquid: false
---

For a recent project I recently I have been using appengine's cron
feature to aggregate data and perform maintenance tasks. However, since
cron is a simple web request, if a user accesses that url then the cron
job will run. In order to prevent normal users from being able to run
cron jobs I created a decorator that specifies a view as cron only.

This decorator is for use with the [kay
framework](http://code.google.com/p/kay-framework/) but it should be
easy to port to your application.

```python
def cron_only(func):
    from werkzeug import Response
    def inner(request, *args, **kwargs):
        import os
        from kay.conf import settings
        if not ('SERVER_SOFTWARE' in os.environ and \
            os.environ['SERVER_SOFTWARE'].startswith('Dev') and \
            settings.DEBUG) and \
           not request.headers.get("X-AppEngine-Cron") == "true":
            return Response("Cron only", status=403)
        return func(request, *args, **kwargs)
    return inner
```
