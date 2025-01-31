---
layout: post
title: "Djangoの DateTimeField の auto_now と auto_now_add"
date: 2012-06-20 16:46:12 +0000
permalink: /jp/django-datetimefield-auto_now-auto_now_add
blog: jp
tags: python django
render_with_liquid: false
locale: ja
---

Django の Model の DateTimeField に auto_nowと auto_now_add
というキーワード引数があります。この引数はデフォールトで False になっていますが、
True にすると、 モデルのインスタンスを保存するタイミングで更新されます。
auto_now=Trueの場合はモデルインスタンスを保存する度に現在の時間で更新される。auto_now_add
はインスタンスの作成(DBにINSERT)する度に更新される。

ただ、ありがちなのは、この引数を使うと、自分でこのフィールドを更新することができません。

例えば、こういうようなモデルがあるとします。

```python
from django.db import models

class MyModel(models.Model):
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
```

これで、MyModelを作成しようとします。

```python
>>> from datetime import datetime
>>> model = MyModel.objects.create(
...    created_at=datetime(2012, 1, 1, 12, 00),
...    updated_at=datetime(2012, 1, 2, 12, 00),
... )
>>> model.created_at
datetime.datetime(2012, 6, 20, 16, 44, 50, 585743)
>>> model.updated_at
datetime.datetime(2012, 6, 20, 16, 44, 50, 585790)
```

こういうふうに created_at と updated_at
を指定しても、この二つのフィールドは現在の時間になります。自前で変更できません。

実は、Django 1.0 が出る前から、この引数を廃止するかどうかという議論があった。

<https://code.djangoproject.com/ticket/7634>

最終的には使いやすくて便利な機能ですし、廃止すると互換性に非常にいたいことが起きてしまうので、このままにしましょう。という結論でした。とは言ってもDjango
のユーザーとして、これは意識しないといけません。

auto_now_add に関しては、 default 引数は callable オブジェクトにも対応しているので、
default=datetime.now にすると自分で、作成時間を指定することができます。

```python
from datetime import datetime

class MyModel(models.Model):
    created_at = models.DateTimeField(default=datetime.now)
    updated_at = models.DateTimeField(auto_now=True)
```

auto_now は
save()メソッドをオーバーライドして、実装するのがおすすめと言われますが、僕はそんなことがよくあるパターンでメンテするコストが高すぎるので、やらない。

でも、もし、やろうとすると、こんな感じなのかなと思います。

```python
from datetime import datetime

class MyModel(models.Model):
    created_at = models.DateTimeField(default=datetime.now)
    updated_at = models.DateTimeField()

    def save(self, *args, **kwargs):
        auto_now = kwargs.pop('updated_at_auto_now', True)
        if auto_now:
            self.updated_at = datetime.now()
        super(MyModel, self).save(*args, **kwargs)
```
