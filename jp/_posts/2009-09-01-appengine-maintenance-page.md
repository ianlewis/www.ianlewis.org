---
layout: post
title: "App Engine メンテナンスが行われる時にメンテナンスページを出す方法"
date: 2009-09-01 23:23:46 +0000
permalink: /jp/appengine-maintenance-page
blog: jp
tags: tech programming python cloud
render_with_liquid: false
locale: ja
---

Google App Engineのメンテナンス時間がある時、Datastoreが読み込み専用になるのが多いと思いますが、データを書こうとする時に、`CapabilitiesError`と言う例外が起こる。それを自分のコードうまく処理しないと、500エラーがでて、ユーザには良くない表現になる。

ドキュメントがないけども、実は、App Engine SDKでmaintenanceが行ってるかどうかをチェックできる[capabilities](http://code.google.com/p/googleappengine/source/browse/trunk/python/google/appengine/api/capabilities/__init__.py)
と言うAPIがあります。 メンテナンスがスケジュールされて、ある時間以内にメンテナンスを行うかをチェックします。僕は
[Django](http://djangoproject.jp/) を使ってるけど、Capabilities APIに特に依存がないですね。

```python
from google.appengine.api.capabilities import CapabilitySet

datastore_write = CapabilitySet('datastore_v3', capabilities=['write'])
if not datastore_write.will_remain_enabled_for(60):
  # エラー処理
```

毎回毎回チェックするのが大変なので、僕が作ったコードシェアリングサイト、 [Smipple](http://www.smipple.net)
、では、以下のユーティリティ関数とdecoratorを使っています。

```python
from django.core.cache import cache

from google.appengine.api.capabilities import CapabilitySet

def is_appengine_maintenance():
    datastore_readonly = cache.get("appengine_datastore_readonly")
    if datastore_readonly is None:
        datastore_write = CapabilitySet('datastore_v3', capabilities=['write'])
        datastore_readonly = not datastore_write.will_remain_enabled_for(60)
        cache.set(
            "appengine_datastore_readonly",
            datastore_readonly,
            60,
        )
    return datastore_readonly

def maintenance_check(view):
  """
  Checks the request method is in one of the given methods
  """
  def wrapped(request, *args, **kwargs):
      if is_appengine_maintenance():
        return HttpResponseRedirect(reverse('maintenance_page'))
      return view(request, *args, **kwargs)
  return wrapped
```

それで、POSTのviewで、maintenance_checkデコレーターを付けて、maintenanceが起こる時に、maintenanceページにリダイレクトする処理をしています。

```python
@login_required
@maintenance_check
def myview(request):
  if request.method == "POST":
    #書き込み
```
