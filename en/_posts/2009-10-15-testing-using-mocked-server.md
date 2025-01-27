---
layout: post
title: "Testing using a mocked HTTP server"
date: 2009-10-15 09:50:18 +0000
permalink: /en/testing-using-mocked-server
blog: en
tags: tech programming python django
render_with_liquid: false
---

Recently I got some tests working for my
[django-lifestream](http://bitbucket.org/IanLewis/django-lifestream/)
project. The lifestream imports data from RSS/Atom feeds so there isn't
a good way to run tests without creating a test HTTP server to serve up
your RSS/Atom.

The tests start up an http server in a separate thread which serves
rss/atom/xml files from a set test directory. I copied the test http
server which was used for [feedparser's
tests](http://code.google.com/p/feedparser/source/browse/trunk/feedparser/feedparsertest.py).
The code is entirely unreadable but the important thing that it does is
read information about what to supply in response headers from the xml
file (This is useful for testing different scenarios where encoding in
the response header is different from the encoding in the xml file etc.)

In order to get it to work I had to do a bit of threaded programming
which I'm pretty new to in python. In order to have main thread running
the tests wait until the server was started properly I used a [Condition
object](http://docs.python.org/library/threading.html#condition-objects)
from the [threading](http://docs.python.org/library/threading.htm)
library. The condition provides a way to maintain a lock and notify
another thread to stop waiting.

In order for various tests to use this functionality I created a base
test class. It looks something like this:

```python
#!/usr/bin/env python
#:coding=utf-8:

import urllib
import threading
import logging

from django.test import TransactionTestCase as DjangoTestCase

from testserver import PORT,FeedParserTestServer,stop_server

class BaseTest(DjangoTestCase):
    base_url = "http://127.0.0.1:%s/%s"

    def setUp(self):
        # Disable logging to the console
        logging.disable(logging.CRITICAL+1)

        self.cond = threading.Condition()
        self.server = FeedParserTestServer(self.cond)
        self.cond.acquire()
        self.server.start()

        # Wait until the server is ready
        while not self.server.ready:
            # Collect left over servers so they release their
            # sockets
            import gc
            gc.collect()
            self.cond.wait()

        self.cond.release()

    def get_url(self, path):
        return self.base_url % (PORT, path)

    def tearDown(self):
        self.server = None
        stop_server(PORT)
```

The server thread takes the condition object and starts the mock
webserver.

```python
class FeedParserTestServer(Thread):
    """HTTP Server that runs in a thread and handles a predetermined number of requests"""
    TIMEOUT=10

    def __init__(self, cond=None):
        Thread.__init__(self)
        self.ready = False
        self.cond = cond

    def run(self):
        self.cond.acquire()
        timeout=0
        self.httpd = None
        while self.httpd is None:
            try:
                self.httpd = StoppableHttpServer(('', PORT), FeedParserTestRequestHandler)
            except Exception, e:
                import socket,errno,time
                if isinstance(e, socket.error) and errno.errorcode[e.args[0]] == 'EADDRINUSE' and timeout < self.TIMEOUT:
                    timeout+=1
                    time.sleep(1)
                else:
                    self.cond.notifyAll()
                    self.cond.release()
                    self.ready = True
                    raise e
        self.ready = True
        if self.cond:
            self.cond.notifyAll()
            self.cond.release()
        self.httpd.serve_forever()
```

The important part with conditions is that both threads need to call the
acquire() method in order for blocking to occur. I kind of got confused
when one thread said that I hadn't aquired the condition when I had done
so already in another thread. It's important that both threads attempt
to acquire the lock.

So thread 1, the main thread, acquires the lock and starts thread 2
which also acquires the lock. This doesn't block right away as it would
block forever. Instead thread 1 calls wait() and blocks until notified.
Thread 2 attempts to start the HTTP server and when finished calls
notifyAll() which notifies thread 1 to stop waiting and continue with
testing.

Because this method starts a server in the setUp() method and stops it
in the tearDown() method a new thread and server is started for each
test in each TestCase that extends the BaseTest. Because socket
connections don't release their port until they are garbage collected
there is a little bit in there to get the garbage collector to do it's
thing so we can start up the next server on the same port. Also we have
a timeout in thread two which causes it to try to start the server a
number of times before giving up.

In order to stop the server in the tearDown() I used a stoppable HTTP
server that implements the QUIT HTTP method that tells the server to
stop.

```python
class FeedParserTestRequestHandler(SimpleHTTPRequestHandler):
    # Some other stuff here ...

    def do_QUIT(self):
        """send 200 OK response, and set server.stop to True"""
        self.send_response(200)
        self.end_headers()
        self.server.stop = True

class StoppableHttpServer(HTTPServer):
    """http server that reacts to self.stop flag"""

    def serve_forever (self):
        """Handle one request at a time until stopped."""
        self.stop = False
        while not self.stop:
            self.handle_request()

def stop_server(port):
    """send QUIT request to http server running on localhost:<port>"""
    conn = httplib.HTTPConnection("127.0.0.1:%d" % port)
    conn.request("QUIT", "/")
    conn.getresponse()
```

The do_QUIT method is executed when the QUIT HTTP method is sent to the
server. The stop_server function makes a QUIT message to the server to
stop it.

There you have it. This code seems to work in Linux but I'm not sure if
it is very portable code. If someone wants to give it a try and let me
know the results I'd be eternally grateful.
