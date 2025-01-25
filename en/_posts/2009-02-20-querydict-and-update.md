---
layout: post
title: "QueryDict and update()"
date: 2009-02-20 09:29:46 +0000
permalink: /en/querydict-and-update
blog: en
tags: tech programming python django
render_with_liquid: false
---

Yesterday I ran into an interesting quirk with Django's QueryDict object and
the normal dictionary update() method. Normally the update method will allow
you to merge two dictionary or dictionary like objects but because the
QueryDict internally holds it's values as lists you get some unexpected
behavior.

For instance with a normal dictionary you can do this:

```python
>> x = {"name": "Ian"}
>> x.update({"age":27})
>> x
{'age': 27, 'name': 'Ian'}
```

But with Django's `request.POST` and `request.GET` QueryDict objects the
internal representation of the values are list so you get unexpected behavior
even though normally accessing the value by key does not give you a list:

```python
>> x = {"job":"programmer"}
>> request.POST
<QueryDict: {u'name': [u'Ian'], u'age': [u'27']}>
>> request.POST['name']
u'Ian'
>> request.POST['age']
u'27'
>> x.update(request.POST)
>> x
{u'name': [u'Ian'], u'age': [u'27'], 'job': 'programmer'}
>> x['name']
[u'Ian']
>> x['age']
[u'27']
```
