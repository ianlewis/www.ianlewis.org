---
layout: post
title: "Werkzeug and reverse urls"
date: 2009-03-14 11:57:52 +0000
permalink: /en/werkzeug-and-reverse-urls
blog: en
tags: tech programming python django
render_with_liquid: false
---

I wanted to impove a [Google App Engine](http://code.google.com/appengine)
application that a friend of mine created
([ほぼ汎用イベント管理ツール](http://twisted-mind.appspot.com/)(jp)) and noticed
that he was [redirecting directly to
urls](http://bitbucket.org/voluntas/twisted-mind/src/tip/views.py#cl-132). He is
using [Werkzeug](http://werkzeug.pocoo.org/) to handle url routing so I wondered
if there was a method for generating urls from a name like you can in
[Django](http://www.djangoproject.com/).

It turns out you can but you give it an endpoint name rather than a url name.

**urls.py:**

```python
from werkzeug.routing import Map, Rule, RuleTemplate, Submount, EndpointPrefix

resource = RuleTemplate([
  Rule('/${name}/', endpoint='${name}_index'),
  Rule('/${name}/create/', endpoint='create_${name}'),
  Rule('/${name}/update/<string:${var}>/', endpoint='update_${name}'),
  Rule('/${name}/delete/<string:${var}>/', endpoint='delete_${name}'),
])

url_map = Map([
  Rule('/', endpoint='index'),
  Rule('/<string:slug>/', endpoint='project_or_event'),
  Rule('/form/<string:key>/<string:slug>/', endpoint='form'),
  Submount('/account', [
    Rule('/', endpoint='account_index'),
    Rule('/create/', endpoint='create_account'),
    Rule('/update/', endpoint='update_account'),
    Rule('/delete/', endpoint='delete_account'),
    Rule('/event/cancel/<string:slug>/', endpoint='event_cancel'),
  ]),
  EndpointPrefix('admin_', [
    Submount('/admin', [
      resource(name='account', var='email'),
      resource(name='project', var='slug'),
      resource(name='event', var='slug'),
      resource(name='program', var='slug'),
      resource(name='application', var='slug'),
    ]),
  ])
])
```

**views.py:**

```python
from werkzeug import redirect as wredirect
from urls import url_map

def reverse(**kwargs):
  c = url_map.bind('')
  return wredirect(c.build(**kwargs))

# ...

  return reverse('form', dict(key=key, slug=slug))
# ...
```

You need to give the build function a full endpoint. in the above example you
can have endpoints like `admin_create_${name}` where `${name}` is the name of a
resource. This would need to be filled in when passing it to build.

```python
# ...
  return reverse('admin_create_event')
# ...
```
