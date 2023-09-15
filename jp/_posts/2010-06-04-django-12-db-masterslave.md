---
layout: post
title: "Django 1.2 マルチ DB と master/slave レプリ"
date: 2010-06-04 16:49:05 +0000
permalink: /jp/django-12-db-masterslave
blog: jp
render_with_liquid: false
---

Django 1.2 はマルチDB対応ができまして、master/slave
レプリにも対応しているのですが、詳しく見るといろな問題が出てきます。

Django 1.2 のマルチDB対応は
どのDBから、読み込むか、どのDBに書き込むかがDBルータで決める。しかし、そのルータで決める時点でリクエストオブジェクトにアクセスできないので、レプリラグのどを自動的に対応するのが難しい。

レプリケーションを使っている場合、マスターDB
に書き込んだ時に、データがスレーブDBまで流れるラグがあるので、DBに書き込んだデータがすぐDBから取れない場合がある
(eventual consistency)。

``` python
obj = MyModel.objects.create(content="Hello World")
obj.content = "Hello World!"
obj.update()

# 失敗する可能性あり
obj2 = MyModel.objects.get(pk=obj.id)
```

こういう場合に対応するには、 QuerySet の using メソッドを使わないとダメです。

``` python
obj = MyModel.objects.create(content="Hello World")
obj.content = "Hello World!"
obj.update()

# OK
obj2 = MyModel.objects.using("master").get(pk=obj.id)
```

しかし、view コードの中に、DBの仕組みに依存しないといけなくなる。環境
（開発、関連サイトなど）によってDBの仕組みが違う場合もあるだろう。第三者アプリも動かない場合があります。(
Django 1.2 自体の contrib モジュールの標準アプリも保証なし）

上の問題と同じく、POSTして新しく追加したレコードも次のGETリクエストが来た時点では取れない可能性が高い。本当はPOSTした後のGETリクエストは
マスター DBを使いたいんですが、 Django 1.2 の仕組みだとそういう処理を導入することが難しい。上と同じく view の中に
using() で対応する必要があります。

どのDBを使うかは QuerySet 単位で、デフォールトDBの名前も固定で、リクエストごとデフォールトDBを変更することもできません。

今のところは monkey patch しなければ、 Django 1.2 のマルチDBでちゃんと master/slave
レプリを使えないのかな。やっぱり微妙ですね。
