---
layout: post
title: "Pickling Objects with Cached Properties"
date: 2014-12-12 12:00:00 +0000
permalink: /en/pickling-objects-cached-properties
blog: en
---

Python descriptors allow you to create properties on python objects
that are the result of executing some code. One of the simplest ways of doing
that is using the ``@property`` decorator. Here, accessing the `myprop` will
call the method and return the resulting `"data"`.

```python
    class MyClass(object):
        @property
        def myprop(self):
            return "data"
```

One variant of this is the `cached_property` pattern. There are many
implementations floating around. There is a
[package on pypi](https://pypi.python.org/pypi/cached-property/).
Werkzeug, and by extension Flask, has
[one](http://werkzeug.pocoo.org/docs/0.9/utils/#werkzeug.utils.cached_property).
[Django has one](https://docs.djangoproject.com/en/1.7/ref/utils/#django.utils.functional.cached_property).
These implementations all rely on the fact that if you add a value to the
`__dict__` of an object, that value has precedence over descriptors and so you
can use it as a quickly accessable place to store cached data.

This has a downside however in that this cached data will be pickled
along with your object when serializing it to disk or to a caching layer
like memcached. In extreme cases this can lead to your pickled binary data
exceeding the memcached per-key space limits.

I came up with a way to avoid this by adding a mixin
to classes but it's not terribly clean and seems like it would be brittle.

```python
    class CachedPropertyMixin(object):
        def __getstate__(self):
            state = self.__dict__.copy()
            for key in state:
                if (hasattr(self.__class__, key) and
                        isinstance(getattr(self.__class__, key), cached_property)):
                    del state[key]
            return state


    class MyClass(CachedPropertyMixin, object):
        @cached_property
        def myprop(self):
            return "data"
```

I'm not really satisfied with this solution so I'd be interested in hearing if
there are any other ideas about how to do avoid pickling cached data.