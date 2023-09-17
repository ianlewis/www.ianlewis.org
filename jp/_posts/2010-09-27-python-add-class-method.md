---
layout: post
title: "Pythonでメソッドをクラスまたはインスタンスに動的に追加する"
date: 2010-09-27 09:58:02 +0000
permalink: /jp/python-add-class-method
blog: jp
tags: python
render_with_liquid: false
---

Pythonでは、あるクラスもしくは、クラスインスタンスに動的にメソッドを付けたいことがあります。Pythonコードでは、一般的に考えるとこういう風に書くって思いがちだけど、

```python
class MyObj(object):
    def __init__(self, val):
        self.val = val

def new_method(self, value):
    return self.val + value

obj = MyObj(3)
obj.method = new_method
```

そうすると、self は使えないのです。実行結果を見てみます。

```python
>>> obj.method(5)
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
TypeError: new_method() takes exactly 2 arguments (1 given)
```

おっと！ なんで！

実際は、そうすると、 `new_method`
は普通のプロバティとしてインスタンスに追加されるので、メソッドをインスタンスにバインドしないといけません。そういう時に、
`types` モジュールの `MethodType` を使います。

```python
>>> from types import MethodType
>>> obj.method = MethodType(new_method, obj, MyObj)
>>> obj.method(5)
8
```

それで `self` が使えます。 `MethodType` にインスタンスを渡すとバウンドメソッドになります。

```python
>>> obj.method
<bound method MyObj.new_method of <__main__.MyObj object at 0xb75c928c>>
```

この場合は `method` は `obj` インスタンスにしか付いていない。別の `MyObj` インスタンスを作ってみよう。

```python
>>> obj2 = MyObj(2)
>>> obj2.method(5)
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
AttributeError: 'MyObj' object has no attribute 'method
```

新しいインスタンスを作っても、追加したメソッドが入っているようにしたい場合はクラスに付けないといけない。具体的なインスタンスにバインドしないので、アンバウンドメソッドを作る。

```python
>>> MyObj.method = MethodType(new_method, None, MyObj)
>>> MyObj.method
<unbound method MyObj.new_method>
>>> obj2 = MyObj(2)
>>> obj2.method(5)
7
```

そうすると、新しいインスタンスを作成すると、動的に追加したメソッドも付いてくる。
