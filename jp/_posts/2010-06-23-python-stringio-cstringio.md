---
layout: post
title: "Python StringIO と cStringIO のもう一つの違い"
date: 2010-06-23 16:50:30 +0000
permalink: /jp/python-stringio-cstringio
blog: jp
tags: python django stringio
render_with_liquid: false
locale: ja
---

C で作られた cStringIO は ピュア Python で作られた StringIO
モジュールと違うのをみんな知っていると思いますけど、今日、私が知らなかった違いをもう一つ見つけました。

StringIO では、StringIO のコンストラクターに文字列を渡せば、その文字列に書き込みすることができる。

```python
>>> from StringIO import StringIO
>>> writer = StringIO('a')
>>> writer.seek(1)
>>> writer.write("b")
>>> writer.getvalue()
'ab'
```

だが、 cStringIO の場合、コンストラクターに文字列を渡せば、StringIO.StringI オブジェクトになって、write
メソッドがそもそもないオブジェクトになります。

```python
>>> from cStringIO import StringIO
>>> writer = StringIO('a')
>>> writer
<cStringIO.StringI object at 0xb74b3530>
>>> writer.write("b")
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
AttributeError: 'cStringIO.StringI' object has no attribute 'write'
```

解決するのがそんなに難しくないけど、AttributeError が出て、ビックリしました。

解決するのはこう書けばいい。

```python
>>> from cStringIO import StringIO
>>> x = 'a' # 既存文字列
>>> writer = StringIO()
>>> writer.write(x)
>>> writer.write('b')
>>> writer.getvalue()
'ab'
```

私は具体的に、やろうとしていたのは、 Django の django.core.files.base の ContentFile
を使おうとしていた。だが、どうしても、StringIOのコンストラクターに文字列を渡すので、書き込みには使い物にならなかった。

```python
>>> from cStringIO import StringIO
>>> from django.core.files.base import File, ContentFile
>>> f = ContentFile(None)
>>> f.write('a')
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
  File "/home/ian/.virtualenvs/django-test/lib/python2.5/site-packages/django/core/files/utils.py", line 24, in <lambda>
    write = property(lambda self: self.file.write)
AttributeError: 'cStringIO.StringI' object has no attribute 'write'
>>> f = File(StringIO())
>>> f.write('a')
>>> f.seek(0)
>>> f.read()
'a'
```
