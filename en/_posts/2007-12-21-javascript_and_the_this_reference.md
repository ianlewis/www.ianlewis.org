---
layout: post
title: "MochiKit does makes java suck less"
date: 2007-12-21 22:58:44 +0000
permalink: /en/javascript_and_the_this_reference
blog: en
tags: tech programming javascript
render_with_liquid: false
---

So the last few days I've been playing around with
[MochiKit](http://www.mochikit.com/) and working with Javascript. Until now I
have done some Javascript here and there but not too much. MochiKit seems to
make it a lot easier by providing you with lots of useful functions for things
you do often. In fact it's so popular that I have a hard time explaining to
myself why I hadn't tried to use it up until now. I'm certainly not on the
bleeding edge here.

Anyway, like I said, MochiKit makes JavaScript less painful. I have a little
mockup for a page that defers going to the server until the user has stopped
entering data for 3 seconds. That cuts down on a lot of back and forth between
the server and client. It's easy in MochiKit. Just use the
[callLater](http://www.mochikit.com/doc/html/MochiKit/Async.html#fn-calllater)
function.

```javascript
update: function() {
  if (this.deferred) {
    this.deferred.cancel();
    log('Previous deferred cancelled.');
  }

  if (this.request) {
    this.request.cancel();
   log('Previous request cancelled.');
  }

  log('updated');
  this.deferred = callLater(3.0, bind(this.deferredupdate, this));
}
```

In [this example](/assets/demos/files/calllatertest.html) the callLater is used to call
another function, deferredupdate, after 3 seconds. However, if the user enters
data a second time before the three seconds are up then the deferred object
will be cancelled and a new deferred object will be created. This has the
effect of not calling the update function until a user is _really_ done
entering data.

The request object is created in the deferredupdate function.

```javascript
deferredupdate: function() {
  log('Loading document');
  this.deferred = null;

  this.request = loadJSONDoc('domains.json');
  this.request.addCallback(bind(this.pageupdate, this));
}
```

The deferredupdate function calls
[loadJSONDoc](http://www.mochikit.com/doc/html/MochiKit/Async.html#fn-loadjsondoc)
which creates a deferred object as well however this deferred object doesn't
wait for any time it simply does it's work in a separate thread and executes a
callback when it's done. In this case I set the callback to be the pageupdate
function. The pageupdate function does the work of putting the resulting data
into a table and adding that table to the html DOM.

If you are wondering what the
[bind](http://mochikit.com/doc/html/MochiKit/Base.html#fn-bind) function does,
it always ensures that the 'this' reference works. I'll leave the full
explanation for another post.

Most people who program in JavaScript already know about MochiKit but if you
are interested in it check out the
[screencast](http://mochikit.com/screencasts/MochiKit_Intro-1.mov) at
http://www.mochikit.com/
