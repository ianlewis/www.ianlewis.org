---
layout: post
title: "DjangoのHTTPS対応開発サーバ"
date: 2009-11-18 21:21:26 +0000
permalink: /jp/django-dev-server-https-support
blog: jp
tags: tech django
render_with_liquid: false
locale: ja
---

Djangoの開発サーバはHTTPSを普段に対応してないので、HTTPS対応をどうやって開発すればいいんだろうと思ったら、調べてみた。秘密は開発サーバ、http用とhttps用を二つ立ち上げます。https開発サーバはstunnelでHTTPS対応します。stunnelは普通のソケットをSSL
tunnelingをしてくれます。

[このドキュメント](http://www.stunnel.org/examples/https_windows.html) を使います。

stunnel をインストールしてから、pemファイルを作ります。

```text
openssl req -new -days 365 -nodes -out newreq.pem -keyout /etc/stunnel/stunnel.pem
```

stunnel の設定ファイルを適当なところに保存します
(これから、dev_https)。acceptはhttpsサーバのポート。connectはhttps用の開発サーバのポートになります。

```text
pid =

[https]
accept=8002
connect=8003
```

stunnel に設定ファイルを指定してdaemonを立ち上げます

```text
stunnel dev_http
```

https用の開発サーバを立ち上げます。 HTTPS=on の環境変数を設定しておけば、 request.is_secure()などは
Trueをちゃんと返す。

```text
HTTPS=on python manage.py runserver 0.0.0.0:8003
```

http用のサーバを立ち上げる

```text
python manage.py runserver 0.0.0.0:8000
```

これで、 <http://localhost:8001> と <https://localhost:8002> で接続することができる。
