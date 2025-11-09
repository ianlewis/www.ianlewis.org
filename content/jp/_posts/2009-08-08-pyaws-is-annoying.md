---
layout: post
title: "pyawsの使いにくい部分"
date: 2009-08-08 14:55:57 +0000
permalink: /jp/pyaws-is-annoying
blog: jp
tags: tech programming cloud
render_with_liquid: false
locale: ja
---

AmazonのアフィリエイトAPIのpython クライアント pyaws は単純にpythonオブジェクトを持つ Bagクラスがある。

```python
# Wrapper class for ECS
class Bag :
    """A generic container for the python objects"""
    def __repr__(self):
        return '<Bag instance: ' + self.__dict__.__repr__() + '>'
```

でも、実はdictでいいかなって思ったの。オブジェクトだと simplejson.dumps出来ないから、嬉しくないな

```python
>>> simplejson.dumps(books[0], indent=2)
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
  File "__init__.py", line 241, in dumps

  File "build/bdist.linux-i686/egg/simplejson/encoder.py", line 366, in encode
  File "build/bdist.linux-i686/egg/simplejson/encoder.py", line 316, in _iterencode
  File "build/bdist.linux-i686/egg/simplejson/encoder.py", line 322, in _iterencode_default
  File "build/bdist.linux-i686/egg/simplejson/encoder.py", line 343, in default
TypeError: <Bag instance: {...}> is not JSON serializable
```
