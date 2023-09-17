---
layout: post
title: "Google Appengine SDK 1.2.3"
date: 2009-06-19 10:04:46 +0000
permalink: /en/google-appengine-sdk-123
blog: en
tags: google appengine django task queue
render_with_liquid: false
---

The [Google Appengine
SDK 1.2.3](http://code.google.com/p/googleappengine/wiki/SdkReleaseNotes#Version_1.2.3_-_June_18,_2009)
was just released and contains some often asked for goodies such as
Django 1.0 support and support for a [task queue
API](http://googleappengine.blogspot.com/2009/06/new-task-queue-api-on-google-app-engine.html).

I haven't found much information about the Django 1.0 version in
Appengine but here are some links with some related information about
the Task Queue API.

- [Google Appengine Blog](http://googleappengine.blogspot.com/)
- [The task queue API
  documentation](http://code.google.com/appengine/docs/python/taskqueue/overview.html)
  - Looks relatively complete.
- [Offline Processing on App Engine: a Look
  Ahead](http://code.google.com/events/io/sessions/OfflineProcessingAppEngine.html)
  - This is the session at Google I/O where Brett Slatkin talks about
    the task queue API. I attended the talk in person and it was pretty
    informative.
- [Slides from Offline Processing on App Engine: a Look
  Ahead](http://dl.google.com/io/2009/pres/Th_1045_Offline_Processing_On_App_Engine_A_Look_Ahead.pdf).
- Some [task queue API
  demos](http://googleappengine.googlecode.com/svn/trunk/python/demos/taskqueue_examples/)

The code looks something like the code below. You tell the task queue
that you have some work to do later and which url the worker is located
at. The worker is then called via a [Web
Hook](http://blog.webhooks.org/about/) post request with the parameters
you gave it. The request is limited to 30 seconds like most requests. It
will continue retry the work until it gets a 200 OK response (That isn't
to say that you should just return a 500 HTTP status if your worker
cannot complete in time. If you have more work your worker should add
itself back to the queue and return 200 OK).

Tasks are executed as soon as possible and only if there is work so it's
quite a bit different from the cron support which runs every so often
regardless of whether there is work or not. Based on the demo from
Google I/O it runs faster than normal requests so you might even have
some work finished before the request that added the work to the task
queue finishes and gets back to your browser\!

```python
import wsgiref.handlers
from google.appengine.api.labs import taskqueue
from google.appengine.ext import db
from google.appengine.ext import webapp
from google.appengine.ext.webapp import template

class Counter(db.Model):
  count = db.IntegerProperty(indexed=False)

class CounterHandler(webapp.RequestHandler):
  def get(self):
    self.response.out.write(template.render('counters.html',
                                            {'counters': Counter.all()}))

  def post(self):
    key = self.request.get('key')

    # Add the task to the default queue.
    taskqueue.add(url='/worker', params={'key': key})

    self.redirect('/')

class CounterWorker(webapp.RequestHandler):
  def post(self):
    key = self.request.get('key')
    def txn():
      counter = Counter.get_by_key_name(key)
      if counter is None:
        counter = Counter(key_name=key, count=1)
      else:
        counter.count += 1
      counter.put()
    db.run_in_transaction(txn)

def main():
  wsgiref.handlers.CGIHandler().run(webapp.WSGIApplication([
    ('/', CounterHandler),
    ('/worker', CounterWorker),
  ]))

if __name__ == '__main__':
  main()
```
