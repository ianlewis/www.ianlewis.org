---
layout: post
title: "Google App Engine 1.7.7 pre-release"
date: 2013-04-09 07:00:00 +0000
permalink: /en/google-appengine-177-pre-release
blog: en
tags: tech programming python google-cloud appengine
render_with_liquid: false
---

<div class="note">

<div class="title">

Note

</div>

**Update:** App Engine 1.7.7 final has been released and is available
here: <https://developers.google.com/appengine/downloads>

</div>

![image](/assets/images/appengine/appengine_lowres_small.png)

The [App Engine 1.7.7 pre-release SDKs were
released](https://groups.google.com/forum/?fromgroups=#!topic/google-appengine/nnHmLdXMgKs)
about a week ago and I finally got around to taking a look at the source
code. The only real addition in the release notes and what caught my eye
was the socket API being released as an experimental feature for billed
apps. Being an experimental feature, that means that the feature is
included in the SDK and you can try it out at least locally.

I looked around and there doesn't seem to be any documentation for how
the socket API will work yet so I was curious how you would use it in a
Python app. Breaking open the SDK you can look at the
`google/appengine/api/remote_socket/` to find the source code related to
the new socket API. I had a look at the `_remote_socket.py` file and
from the docstrings and code it looked like it was a drop in replacement
for the Python socket module.

```python
"""Socket Module.

This file is intended to provide the equivalent of
python/Modules/socketmodule.c rather than python/Lib/socket.py which amongst
other things adds a buffered file-like interface.
"""
```

This is very nice since it would ensure maximum compatibility with
existing Python libraries.

In order to try it out I created a really simple app. This app just
makes a simple socket connection to the www.google.com webserver and
returns the result.

```python
import webapp2
import socket

class MainPage(webapp2.RequestHandler):
    def get(self):
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.connect(("www.google.com", 80))
        s.send("GET %s HTTP/1.0\r\nHost: %s\r\n\r\n" % ('/', "www.google.com"))

        data = s.recv(1024)
        string = ""
        while len(data):
          string = string + data
          data = s.recv(1024)
        s.close()

        self.response.headers['Content-Type'] = 'text/plain'
        self.response.out.write(string)

application = webapp2.WSGIApplication([('/', MainPage)],
                              debug=True)
```

It seems, at least locally, that you can keep a socket around across
requests as, or as part of, a module level global variable. This is
probably not really recommended as it could create a lot of sockets if
you have a lot of App Engine instances.

```python
import webapp2
import socket

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect(("www.google.com", 80))
s.send("GET %s HTTP/1.0\r\nHost: %s\r\n\r\n" % ('/', "www.google.com"))

class MainPage(webapp2.RequestHandler):
    def get(self):
        string = s.recv(20)
        self.response.headers['Content-Type'] = 'text/plain'
        self.response.out.write(string)

application = webapp2.WSGIApplication([('/', MainPage)],
                              debug=True)
```

It would be interesting if you could set the socket descriptor for each
socket so that you can reuse the same socket across various App Engine
instances. Not sure how that would really work in practice though. _See
below about the underlying API to see what I mean._

Sending and receiving from sockets isn't the only thing you can do with
the Python socket module. Finally, you can do DNS lookups on App Engine.

```python
import webapp2
import socket

class MainPage(webapp2.RequestHandler):
    def get(self):
        self.response.headers['Content-Type'] = 'text/plain'
        self.response.out.write(socket.getaddrinfo('www.google.com', 80))

application = webapp2.WSGIApplication([('/', MainPage)],
                              debug=True)
```

# The Underlying API

Looking further at the SDK code reveals that, like all the other App
Engine APIs, it's Protocol Buffers based. They have a `socket` class
which replaces the normal Python one in the standard library,
implementing socket handling with Protocol Buffers. When the socket is
created a "CreateSocketRequest" RPC call is sent in the
`_CreateSocket()` method to the socket API service. A socket is created
via that service and a "socket descriptor" is returned which is a unique
identifier for the socket.

```python
def _CreateSocket(self, address=None, bind_address=None,
                  address_hostname_hint=None):
  assert not self._created
  self._created = True

  request = remote_socket_service_pb.CreateSocketRequest()

  # ...

  reply = remote_socket_service_pb.CreateSocketReply()

  try:
    apiproxy_stub_map.MakeSyncCall(
        'remote_socket', 'CreateSocket', request, reply)
  except apiproxy_errors.ApplicationError, e:
    raise _SystemExceptionFromAppError(e)

  self._socket_descriptor = reply.socket_descriptor()

  # ...
```

Sending data or receiving data on the socket are also handled via RPC
calls. When you want to write on the socket, an RPC call is made that
sends the data to the socket API service which forwards it on the actual
socket. Like the normal Python socket class it returns the number of
bytes sent.

```python
def sendto(self, data, *args):
  """sendto(data[, flags], address) -> count

  Like send(data, flags) but allows specifying the destination address.
  For IP sockets, the address is a pair (hostaddr, port).
  """

  # ...

  request = remote_socket_service_pb.SendRequest()
  request.set_socket_descriptor(self._socket_descriptor)

  # ...

  reply = remote_socket_service_pb.SendReply()

  try:
    apiproxy_stub_map.MakeSyncCall('remote_socket', 'Send', request, reply)
  except apiproxy_errors.ApplicationError, e:
    raise _SystemExceptionFromAppError(e)

  nbytes = reply.data_sent()
  assert nbytes >= 0
  if self.type == SOCK_STREAM:
    self._stream_offset += nbytes
  return nbytes
```

Reading from the socket is a bit interesting since you don't have a full
duplex socket that you can read from directly. Your app sends a
`ReceiveRequest` and gets back an amount of data from the socket. The
socket API must buffer the sockets remotely and return to you the
contents of the buffer when you do a `recv()` call.

```python
def recvfrom(self, buffersize, flags=0):
  """recvfrom(buffersize[, flags]) -> (data, address info)

  Like recv(buffersize, flags) but also return the sender's address info.
  """
  # ...

  request = remote_socket_service_pb.ReceiveRequest()
  request.set_socket_descriptor(self._socket_descriptor)
  request.set_data_size(buffersize)
  request.set_flags(flags)

  # ...

  reply = remote_socket_service_pb.ReceiveReply()

  try:
    apiproxy_stub_map.MakeSyncCall('remote_socket', 'Receive', request, reply)
  except apiproxy_errors.ApplicationError, e:
    e = _SystemExceptionFromAppError(e)
    if not self._shutdown_read or e.errno != errno.EAGAIN:
      raise e

  # ...

  return reply.data(), address
```

In reality, this is sort of similar to what the OS does for you anyway,
so it's actually not that different from a normal socket app. I would
imagine this would be a couple of orders of magnitude slower though.

# Wrapping Up

As you can't really have a full socket open from an App Engine app
without limiting App Engine's ability to scale and handle requests from
any instance it wants, I pretty much expected this kind of
implementation.

I only tested this out using the local SDK since it's a pre-release and
hasn't been released to App Engine yet. From the release notes it looks
like it will be released as an experimental feature for billed apps
before becoming generally available. I expect because it's RPC based you
won't get a lot of speed from it. I also expect you'll need to do a lot
of proper error handling since I would expect, like some of the other
APIs, that it may have some growing pains.

One thing to look out for is how this feature will be billed in App
Engine apps. I expect it will be like the channel API and be billed by
number of sockets created, but we'll have to see.

I hope 1.7.7 is released soon because I'm looking forward to using the
socket API with at least one of the apps I've created. Till then I'll
just have to sit on my hands. :)
