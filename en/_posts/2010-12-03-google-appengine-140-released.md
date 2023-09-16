---
layout: post
title: "Google Appengine 1.4.0 Released!!"
date: 2010-12-03 09:19:38 +0000
permalink: /en/google-appengine-140-released
blog: en
render_with_liquid: false
---

[Google Appengine](http://code.google.com/appengine/) 1.4.0 was just
released and has lots of interesting new features. Channel API, "Always
On" (reserved instances), Improvements to background processing, Warm up
requests, and Metadata queries just to name the big ones.

# Channel API

The Channel API is a way for you to "push" data to the client browser.
The Channel is a bit like a socket connection but it's implemented using
Google's
[XMPP](http://en.wikipedia.org/wiki/Extensible_Messaging_and_Presence_Protocol)
infrastructure built for [Google Talk](http://www.google.com/talk/). So
it will scale properly as needed.

The Channel API feature includes two parts, a server-side API for
creating channels and sending messages, and a Javascript API for
recieving and processing those messages.

Let's take a look and what a simple application might look like to
demonstrate the API.

## Server-Side

First we need to create a channel. We give it a unique channel key and
it will give us an ID that we can give to the client, who will in turn
use the ID to connect to the channel to recieve messsages.

Here we are passing the current `user` object to
`channel.create_channel()` but any string will do. So you could have
many clients listening to the same channel designated by an arbitrary
key.

```python
from google.appengine.ext import webapp
from google.appengine.api import channel
from django.template.loader import render_to_string

class MyHandler(BaseHandler):
    def get(self):
        user = users.get_current_user()

        # Create the channel
        # We could pass a string to create_channel() if we wanted to.
        id = channel.create_channel(user)

        return self.response.out.write(
            render_to_string(
                "index.html",
                {"channel_id": id},
            )
        )
```

On the client site we use javascript to connect to the channel.

```javascript
var channel = new goog.appengine.Channel("{{ channel_id }}");
var socket = channel.open();
socket.onopen = function () {
  window.setTimeout(function () {
    alert("Connected!");
  }, 100);
};

// Register a message handler
socket.onmessage = function (evt) {
  // Here we are getting text from the server
  // But JSON data is recommended.
  // var o = JSON.parse(evt.data);
  alert(evt.data);
  // do something
};
```

Last, we can send a message to the client using the `user` as the
channel key.

```python
from google.appengine.api import channel
from google.appengine.api import users

class AjaxHandler(BaseHandler):
    def get(self):
        user = users.get_current_user()

        # Send a message to the client.
        # Noone actually needs to be connected
        # If sending to a channel where noone
        # is connected then this does nothing.
        channel.send_message(user, "Hello World!!")
```

<div class="note">

<div class="title">

Note

</div>

The channel API is not a two-way channel. It is for pushing data to the
client. If you want to send data to the server you can do so using
normal AJAX POST requests.

</div>

# Always On

The "Always On" feature lets you pay to keep at least 3 instances
running at all times. Until now your application could go completely
cold with no instances running. When a user made a request for the first
time, Appengine would have to spin up an instance in order to serve the
request, which could take a lot of time.

<div class="note">

<div class="title">

Note

</div>

Something to note is that this is only really effective for applications
that have times where their application falls below 3 instances. If your
application always has enough traffic to keep appengine above 3
instances then this feature won't do anything for you.

</div>

# Warmup Requests

Until now, when a request came that would cause Appengine to scale out
and create a new instance, it would need to send the request to your
instance cold. i.e. Your instance wouldn't have a chance to load modules
before the request came, so that particular request would be served
slowly.

Warmup requests are requests that are sent to your instance as the first
request before serving user facing requests. This allows you to load
heavy modules before serving user facing requests, allowing for a much
better experience for users.

In order to enable Warmup Requests, you need to add `warmup` to your
`inbound_services` section of your `app.yaml` much like you would for
mail or XMPP.

```yaml
inbound_services:
  - warmup
```

The warmup request will be sent to `/_ah/warmup` so you can add a
handler to your `app.yaml` to specifically handle the request or just
use a catch all handler.

Here we'll use our own handler.

```yaml
- url: /_ah/warmup.*
  script: warmup.py
```

Our `warmup.py` might look like this.

```python
# Load some big modules that we need for our application here
import mybigmodule
import myothermodule

def main():
    print "Content-type: text/plain"
    print "OK"
```

# Task Queue Official Release

In 1.4.0, The task queue graduates from labs and becomes a first class
feature of Appengine. This means that the taskqueue API module will move
from `google.appengine.api.labs.taskqueue` to
`google.appengine.api.taskqueue`. You can still import the task queue
API from the old module but it will give you a deprecation warning on
the development server and could be removed in future versions.

Task Queue tasks were not previously counted against your storage quota
but they will be now so heavy users might need to start watching their
data quota more closely.

# Improved Background Processing

Cron and Task Queue tasks are going from having a request limit of 30
seconds to having a request limit of 10 minutes. This is a huge jump\!\!
but it doesn't mean that you can be lazy now. Appengine will recognize
long running cron jobs and tasks and process them separately (in a
separate queue/different infrastructure) from fast running cron
jobs/tasks. So you won't be able to get high throughput for long running
tasks. This means you will only be able to do a few long running tasks
or cron jobs at a time without backing things up.

# Metadata Queries

You can now do queries against Appengine Datastore metadata. The SDK now
provides new `Namespace`, `Kind`, and `Property` Model classes that live
in `google.appengine.ext.db.metadata`. You can query these like regular
models but you won't be able to create new ones by saving them to the
datastore like you would be with regular modules.

Namespaces are pretty trivial. Kinds are parent objects of their
properties so you can get the properties for a particular kind by doing
an ancestor query.

```python
from google.appengine.ext.db.metadata import Namespace, Kind, Property

for namespace in Namespace.all():
    print namespace.namespace_name

for kind in Kind.all():
    print kind.kind_name
    for property in Property.all().ancestor(kind):
        print "    %s" % property.property_name
```

# Download

It looks like the download hasn't made it to the appengine download page
yet but you can download it from the links at the google project page.

- Python:
  [google_appengine_1.4.0.zip](http://code.google.com/p/googleappengine/downloads/detail?name=google_appengine_1.4.0.zip)
- Java:
  [appengine-java-sdk-1.4.0.zip](http://code.google.com/p/googleappengine/downloads/detail?name=appengine-java-sdk-1.4.0.zip)
- Release Notes:
  <http://code.google.com/p/googleappengine/wiki/SdkReleaseNotes>
