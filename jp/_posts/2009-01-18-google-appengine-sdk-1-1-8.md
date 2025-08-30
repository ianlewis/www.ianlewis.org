---
layout: post
title: "Google Appengine SDK 1.1.8がリリースされました"
date: 2009-01-18 11:45:59 +0000
permalink: /jp/google-appengine-sdk-1-1-8
blog: jp
tags: python appengine django
render_with_liquid: false
locale: ja
---

Appengineの新しいリリース1.1.8が来た。色な面白いところがあるけど、仲居さん(id:[Voluntas](http://d.hatena.ne.jp/Voluntas/))の[ブログポスト](http://d.hatena.ne.jp/Voluntas/20090117/1232209649)からピックアップする。

> - ByteStringProperty が実装 気軽に使える BlobProperty
> - UserProperty に auto_current_user / auto_current_user_add が追加。
>     - DateTimeProperty と同じ動作すると思われ。
> - PolyModel が追加されました。
>     - [Django](http://www.djangoproject.com/) の継承と一緒、使い方は簡単です。
>
> ```python
> from google.appengine.ext import db
> from google.appengine.ext.db import polymodel
>
> class Entity(polymodel.PolyModel):
>   created = db.DateTimeProperty()
>
> class Status(Entity):
>   message = db.StringProperty()
>
> class Clip(Entity):
>   url = db.StringProperty()
> ```
>
> - Image API に width/height が実装されました
> - db.Model.order() にて **key** のソートが出来るようになりました。bugfix

僕が気になったところがもう一個あるんだけど、このリリースにて、antlr3というモジュールが必須となった。1.1.8をインストールして動かそうたしたら、

> ImportError: No module named antlr3

が出てきた。理由はappengine_djangoを使ってること。appengine_djangoはgoogle_appengine/lib/antlr3のモジュールをインポートしてなかったので、エラーが出てきた。appengine_djangoのSVNの最新版を使えば、解決する。

何で、antlr3が必要になったというと、実際コード見ると、google_appengine/google/appengine/cronで、groc.py, GrocLexer.py, GrocParser.pyがある。grocというcronみたいなサービスがもうすぐ出るかもしれないね。GrocLexer.pyとGrocParser.pyはantlr3を使ってcronの時間設定文字列を解析するパーサーだという。面白い。
