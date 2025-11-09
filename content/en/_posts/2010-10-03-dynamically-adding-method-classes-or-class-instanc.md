---
layout: post
title: "Dynamically Adding a Method to Classes or Class Instances in Python"
date: 2010-10-03 21:42:26 +0000
permalink: /en/dynamically-adding-method-classes-or-class-instanc
blog: en
tags: tech programming python
render_with_liquid: false
---

In Python you sometimes want to dynamically add methods to classes or
class instances (objects). In Python code, the most obvious way to
accomplish this might be something like the following but it has one
caveat,

```python
class MyObj(object):
    def __init__(self, val):
        self.val = val

def new_method(self, value):
    return self.val + value

obj = MyObj(3)
obj.method = new_method
```

... you can't use self. Let's try to actually call the method.

```python
>>> obj.method(5)
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
TypeError: new_method() takes exactly 2 arguments (1 given)
```

The `new_method()` function is added to the class as a property which is
a function that takes two arguments. So how do we add a method that can
use self? The answer is that we use the `types` module's `MethodType`.

```python
>>> from types import MethodType
>>> obj.method = MethodType(new_method, obj, MyObj)
>>> obj.method(5)
8
```

OK, so now we can use self. The `MethodType` type actually binds the
method to the instance and creates a "bound method".

```python
>>> obj.method
<bound method MyObj.new_method of <__main__.MyObj object at 0xb75c928c>>
```

Here, the method `method` is bound to the `obj` instance but is only
available to that single instance. If we create another `MyObj` instance
it won't have the new method. Let's create a new instance:

```python
>>> obj2 = MyObj(2)
>>> obj2.method(5)
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
AttributeError: 'MyObj' object has no attribute 'method
```

So if we create a new instance it doesn't have the new method. In the
case where we want to add a new method to a class and have all new
instances of that Class have the new method we will need to add an
"unbound method" to the class.

```python
>>> MyObj.method = MethodType(new_method, None, MyObj)
>>> MyObj.method
<unbound method MyObj.new_method>
>>> obj2 = MyObj(2)
>>> obj2.method(5)
7
```

So now we can create any number of `MyObj` instances and they will all
contain the new method. Pretty handy eh?
