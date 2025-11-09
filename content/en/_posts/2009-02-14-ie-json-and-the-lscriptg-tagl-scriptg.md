---
layout: post
title: "IE, JSON, and the script tag"
date: 2009-02-14 13:34:57 +0000
permalink: /en/ie-json-and-the-lscriptg-tagl-scriptg
blog: en
tags: tech programming javascript security
render_with_liquid: false
---

My coworker recently introduced me to one of the most blatantly bad behaviors
in web browser history. He introduced it thus:

```python
Out[1]: simplejson.dumps({'foo': '<script>alert(document.cookie);</script>'})
Out[2]: '{"foo": "<script>alert(document.cookie);</script>"}'
```

The thing is, that there is nothing wrong with what simplejson is doing. The
problem is that this little piece of json is not handled properly in IE and IE
actually executes the JavaScript in the script tag regardless of the fact that
it's inside a string. This can leave an application wide open to XSS attacks.
IE seems to do this for at least the `text/plain` mime-type.
