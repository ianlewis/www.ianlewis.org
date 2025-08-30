---
layout: post
title: "Python 例外のひどい仕様"
date: 2009-06-04 14:39:55 +0000
permalink: /jp/doctest-unicode-error
blog: jp
tags: python django 例外 unicode test
render_with_liquid: false
locale: ja
---

[Python](http://www.python.org/)の例外オブジェクトは苦手です。例外のメッセージが何でもASCIIとして扱われることがひどい。

```python
In [1]: t = ValueError("テスト".decode("utf8"))

In [2]: print t
---------------------------------------------------------------------------
UnicodeEncodeError                        Traceback (most recent call last)

/home/ian/src/project/<ipython console> in <module>()

UnicodeEncodeError: 'ascii' codec can't encode characters in position 0-2: ordinal not in range(128)

In [3]: t = ValueError(u"テスト") # Unicode objects don't work either

In [4]: print t
---------------------------------------------------------------------------
UnicodeEncodeError                        Traceback (most recent call last)

/home/ian/src/project/<ipython console> in <module>()

UnicodeEncodeError: 'ascii' codec can't encode characters in position 0-2: ordinal not in range(128)
```

[Django](http://www.djangoproject.com/)のテストフレームワークで、`doctest`を使おうと思ったら、例外のメッセージがASCIIじゃないとダメというのが判明

```python
u"""
>>> test(-1)
    Traceback (most recent call last):
        ...
    ValueError: エラーですよ！
"""
```

とやっても、うまくうごかない。以下の`UnicodeDecodeError`がでる

```bash
======================================================================
ERROR: Doctest: app.tests
----------------------------------------------------------------------
Traceback (most recent call last):
  File "/home/ian/.virtualenvs/test/lib/python2.5/site-packages/django/test/_doctest.py", line 2175, in runTest
    test, out=new.write, clear_globs=False)
  File "/home/ian/.virtualenvs/test/lib/python2.5/site-packages/django/test/_doctest.py", line 1403, in run
    return self.__run(test, compileflags, out)
  File "/home/ian/.virtualenvs/test/lib/python2.5/site-packages/django/test/_doctest.py", line 1291, in __run
    got += _exception_traceback(exc_info)
  File "/home/ian/.virtualenvs/test/lib/python2.5/site-packages/django/test/_doctest.py", line 269, in _exception_traceback
    return excout.getvalue()
  File "/usr/lib/python2.5/StringIO.py", line 270, in getvalue
    self.buf += ''.join(self.buflist)
UnicodeDecodeError: 'ascii' codec can't decode byte 0xe3 in position 24: ordinal not in range(128)

---
```

> Update: moriyoshiさんにより、Python 2.6 で[ちゃんと動くみたい](http://d.hatena.ne.jp/moriyoshi/20090604/1244092247)
