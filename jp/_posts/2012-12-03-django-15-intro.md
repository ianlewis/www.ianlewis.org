---
layout: post
title: "Django 1.5 の紹介"
date: 2012-12-03 10:00:00 +0000
permalink: /jp/django-15-intro
blog: jp
render_with_liquid: false
---

![image](https://storage.googleapis.com/static.ianlewis.org/prod/img/django/django-logo-positive_medium.png)

<div class="note">

<div class="title">

Note

</div>

この記事は [2012
Pythonアドベントカレンダー(Webフレームワーク)](http://connpass.com/event/1439/)
の第３目の記事。昨日の記事は id:shomah4a の「 [2012 Python アドベントカレンダー (Web フレームワーク ) 二日目
WSGI でなんか作ってみる](http://d.hatena.ne.jp/shomah4a/20121202) 」。明日は surgo
さんが、 Django 1.5 以降と Python 3 あたりの記事を書いてくれます。

</div>

１０月２５日に [Django 1.5 alpha 1
がリリースされて](https://www.djangoproject.com/weblog/2012/oct/25/15-alpha-1/)
、順調に先週の火曜日（１１月２７日）に [Django 1.5 beta 1
がリリースされました](https://www.djangoproject.com/weblog/2012/nov/27/15-beta-1/)
。徐々に Django 1.5 の正式リリースに近づいてきいます。もしかして、年内にいいクリスマスプレゼントになるかもしれません。

# 新機能

Django 1.5 はたくさんの変更がありますが、一番大きい変更をピックアップして、紹介します。

# Python 3 対応

Django 1.5 では、Python 3の体験的サポートが入っています。少なくとも、Django 1.5 の unittest
がすべて成功して、一般的に動作します。主要な対象はまだ Python 2 なので、
[six](http://packages.python.org/six/) という Python 2/3 互換性のためのライブラリが
Django に組み込まれています。Django自体の互換性を守るためももちろんですが、第三者の Django
アプリの作者はこのライブラリを使って、今まで Python 2
でしか動かない汎用アプリを Python 2 でも 3 でも動くように修正できることも Django
に組み込む目的の一つです。

Python 3 の本格的サポートは 1.5 以降ですし、 surgo さんももっと詳しく書いてくれるのを期待しましょう。

# カスタムユーザーモデル

これは Django 1.5 の一番大きい新機能なのかなと思います。今までは、Django の `contrib.auth`
モジュールを使うには、 `username` や、 `password`
などのフィールドが不要だとしても、整数以外のプライマリーキーが必要だとしても、そのアプリが提供したユーザーモデルを使わないといけなかった。なにかしらの理由で
`contrib.auth`
を利用出来なかった場合、ユーザー認証、ログイン、ログアウト、パスワードハッシュ生成などを自前で実装しないといけなかった。

Django 1.5 から、 `AUTH_USER_MODEL` という設定が増えました。この設定をすると、指定したDjango
アプリとモデル名を使ってユーザーモデルとして利用できます。

``` python
AUTH_USER_MODEL = 'myapp.MyUser'
```

自分のユーザーモデルに指す `ForeignKey` をこういう風に作れます。 `settings.AUTH_USER_MODEL`
はアプリ名とモデル名が入っている文字列だけなので、 `ForeignKey` の既存機能をそのまま使えます。

``` python
from django.conf import settings
from django.db import models

class Article(models.Model)
    author = models.ForeignKey(settings.AUTH_USER_MODEL)
```

当然データベースの構造が変わるので、そころ辺に関しては注意して頂ける必要がある。既存アプリケーションでは、
[South](http://south.aeracode.org/) とか、データベースマイグレーションを使うといいです。

ユーザーモデルを作るために、抽象的なベースクラスを使うことができるようになりました。 `AbstractBaseUser` を継承して、
`USERNAME_FIELD` を設定すると、 `contrib.auth` アプリの `login()` ビューなどが使えるようになります。
`REQUIRED_FIELDS` は Django の 既存 `createsuperuser`
などのコマンドなど、新しいユーザー作成の為です。

    class MyUser(AbstractBaseUser):
        identifier = models.CharField(max_length=40, unique=True, db_index=True)
    
        date_of_birth = models.DateField()
        height = models.FloatField()
    
        USERNAME_FIELD = 'identifier'
        REQUIRED_FIELDS = ['date_of_birth', 'height']

もっと詳しくは [Customizing the User
model](https://docs.djangoproject.com/en/dev/topics/auth/#customizing-the-user-model)
を読んでみて下さい。

ユーザーモデルは settings.py で設定するので、複数の settings.py
モジュールを用意して、別プロセスで起動すれば、複数のユーザーモデルを使うことができるんじゃないかなと思います。

# モデルフィールドのサブセットだけを保存

Django 1.5 まで、 モデルの `save()` メソッドを呼び出した時に、モデルのすべてのフィールドが保存されたんだが、 Django
1.5 からは、保存するフィールドを指定することができるようになった。 保存するフィールドを指定するのは `update_fields`
という引数を渡します。

``` python
mymodel.save(update_fields=['name', 'date'])
```

# リレーションで同じモデルをキャッシュする

Django 1.4以下は、あるモデルのインスタンスが同じIDだったのに、データベースから２回取ってきたりしました。Django 1.5
からは、リレーションでアクセスしたモデルインスタンスは使ったモデルを使います。

``` python
>>> first_poll = Poll.objects.all()[0]
>>> first_choice = first_poll.choice_set.all()[0]
>>> first_choice.poll is first_poll
True
```

Django 1.4 だと、 `first_choice.poll` は別クエリが発生して、 `first_poll`
と別インスタンスになった。

# 注意点

しかし、Django 1.5 で、いくつかのことが変わっていますので、少し注意が必要。Django
を内部的に触っている場合も、プログラムの修正が必要な場合があります。

# url テンプレートタグの旧バージョンがなくなる

Django 1.3 では `{% url %}` の旧バージョンが [deprecated
になりました](https://docs.djangoproject.com/en/1.3/ref/templates/builtins/#url)
。1.3 までは、 `{% url urlname %}` でクオートなしでURL名を指定したんですが、1.3 から `{% load url
from future %}` をテンプレートに書けば、 `{% url "urlname" %}` の様に書けることになりました。

Django の Deprecation ポリシーに従って、deprecated バージョンは２つのバージョンの後に廃止するので、 Django
1.5 では、 `{% url urlname %}` という風に書くことができなくなりました。今までは、多くのDjango
アプリケーションはこういう風に書いていましたので、たくなんのテンプレートは修正する必要があります。

future の書き方はまだ Django 1.5 でも動くので、多くのDjango
バージョンに対応する必要がある場合は、こういう風に書くのがおすすめです。

``` html+django
{% load url from future %}
{% url 'myapp:view-name' %}
```

# 非フォームデータとHTTPリクエスト

今までは、Django はどんなコンテントタイプヘッダー (`Content-Type`) でPOSTリクエストを送信しても、フォームデータを
`request.POST` に突っ込みました。Django 1.5 からは、`multipart/form-data` か
`application/x-www-form-urlencoded` かどっちかを `Content-Type`
ヘッダーに入れないといけない。
それ以外の場合にリクエストデータをアクセスしたい場合は、
`request.body` を使ってください。

# などなど

他に互換性を持たない変更があるので、
[リリースノート](https://docs.djangoproject.com/en/dev/releases/1.5-beta-1/#backwards-incompatible-changes-in-1-5)
を読んでみて下さい。　

# まとめ

Django 1.5 では、主に Python 3 の対応とユーザー認証のカスタマイズが一歩進んだ感じだね。　Django 1.5
以降は非常に楽しみ
