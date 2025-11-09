---
layout: post
title: "Django modelformset_factory便利"
date: 2010-01-14 19:35:55 +0000
permalink: /jp/django-modelformset_factory
blog: jp
tags: django modelform
render_with_liquid: false
locale: ja
---

Django
は複数のフォームのデータを同時に扱えるために、FormSetsというものを用意しているんですけど、実は、ModelFormのFormSetでも使える。クエリーの結果のデータのModelFormを一個一個、一つのページに出すにはこんなコードを書ける。

```python
from django.forms.models import modelformset_factory

formset = modelformset_factory(
    MyModel,
    fields=('status','content'),
    extra=0,
)(queryset=MyModel.objects.filter(status=1))
```

便利
