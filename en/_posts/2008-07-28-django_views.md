---
layout: post
title: "Django"
date: 2008-07-28 01:15:30 +0000
permalink: /en/django_views
blog: en
tags: python pylons appengine django web applications
render_with_liquid: false
---

I was thinking about using [Django](http://www.djangoproject.com) for one of my
projects on [GAE](http://code.google.com/appengine/) because it seems like a
popular project and somewhat easy to use, but I'm not quite understanding yet
why it's better to have helper functions rather than controller/handler classes
like [Pylons](http://pylonshq.com/) or
[GAE](http://code.google.com/appengine/)'s normal WSGI handling has. With
handler classes my controller might look like:

```python
from google.appengine.ext.webapp import RequestHandler

class MainHandler(webapp.RequestHandler):
  def get(self):
    # Read data from BigTable here
    self.response.out.write(outputhtml)

  def post(self):
    # Write data to BigTable here

    #redirect back to the url
    self.redirect(self.request.url)
```

Whereas the django helper function might look like:

```python
from django.http import HttpResponse, HttpResponseRedirect

def mainview(request):
  if request.method == 'POST':
    # Write to BigTable Here
    return HttpResponse(outputhtml)
  elif request.method == 'GET':
    # Read from BigTable Here
    return HTTPResponseRedirect(request.url)
```

While the [Django](http://www.djangoproject.com/) method might have the
potential to have be a bit less verbose it feels like it would be harder to do
things correctly, like factor code etc. I also don't really like the
conditional checks to see what kind of HTTP method was used. So either I would
need to split GETs and POSTs to separate urls or just live with the conditional
checks.

Personally I feel better with the [Pylons](http://pylonshq.com/)-ish
controller/handler approach. Anyone have an opinion?
