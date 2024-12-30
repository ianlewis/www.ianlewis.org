---
layout: post
title: "特定なDjangoモデルを別DBに保存するメモ"
date: 2010-09-22 16:35:28 +0000
permalink: /jp/django-model-other-db-memo
blog: jp
tags: python django
render_with_liquid: false
---

<!-- textlint-disable rousseau -->

今日、会社で特定なDjangoモデルを別のDBに保存するようなニーズがあって、Django マルチDBを使えるかなという話がありました。
この間、
[Django1.2のマルチDBはレプリケーション対応に微妙](/jp/django-12-db-masterslave)
っブログに書きましたけど、ModelでDBを使い分けるのができるはずと思って、DBルータを書いてみた。

`Monjudoh` というモデルを 'monjudoh' DBに保存するためのDBルータです。

```python
from monjudoh.models import Monjudoh

class MonjudohRouter(object):
    def db_for_read(self, model, **hints):
        if issubclass(model, Monjudoh):
            return 'monjudoh'
        return None

    def db_for_write(self, model, **hints):
        if issubclass(model, Monjudoh):
            return 'monjudoh'
        return None

    def allow_relation(self, obj1, obj2, **hints):
        if isinstance(obj1, Monjudoh) or isinstance(obj2, Monjudoh):
            return True
        return None

    def allow_syncdb(self, db, model):
        if db == 'monjudoh':
            return issubclass(model, Monjudoh)
        elif issubclass(model, Monjudoh):
            return False
        return None
```

設定は `settings.py` で

```python
DATABASES = {
    'default': {
        'NAME': 'app_data',
        'ENGINE': 'django.db.backends.postgresql_psycopg2',
        'USER': 'postgres_user',
        'PASSWORD': 's3krit'
    },
    'monjudoh': {
        'NAME': 'monjudoh',
        'ENGINE': 'django.db.backends.mysql',
        'USER': 'mysql_user',
        'PASSWORD': 'priv4te'
    }
}
DATABASE_ROUTERS = ['path.to.MonjudohRouter']
```

<!-- textlint-enable rousseau -->
