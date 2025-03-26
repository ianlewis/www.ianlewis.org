---
layout: post
title: "daemontoolsを使ってdjango fastcgiのデーモンを設定する"
date: 2009-12-13 22:01:54 +0000
permalink: /jp/daemontools-with-django
blog: jp
tags: django
render_with_liquid: false
locale: ja
---

daemontoolsの上にDjango fastcgiを使うのは簡単にできるけど、正しいユーザとして、フォアグラウンドに起動するには`bash`と`daemontools`の設定する必要がある。

フォアグラウンドに起動するには、`daemonize=false`を指定する必要がある。

それで、起動するデイモンはユーザを指定するオプションがないとrootユーザとして、起動する。`runfcgi`はそういうオプションがないので、`daemontools`の`setuidgid`ツールを使う。

`setuidgid`のコマンドになるので、プロセスの標準パイプを正しく接続するには、`bash`の`exec`コマンドを使う。

## /service/myapp/run

```bash
#!/bin/bash

BASEDIR="/home/www/"
PIDFILE="$BASEDIR/app.pid"

exec setuidgid www python /home/www/django-prj/manage.py runfcgi \
    --settings=settings_production method=threaded  port=8001 \
    pidfile=$PIDFILE daemonize=false 2>&1
```
