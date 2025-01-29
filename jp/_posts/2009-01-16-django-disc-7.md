---
layout: post
title: "Django 勉強会 Disc.7"
date: 2009-01-16 21:34:38 +0000
permalink: /jp/django-disc-7
blog: jp
tags: django 勉強会 オクセンス
render_with_liquid: false
---

昨日、[アクセンス・テクノロジー](http://accense.com/)の東京本社に [Django
勉強会 Disc.7](http://djangoproject.jp/etude/7/)に参加しに行ってきました。

## GeoDjango

最初は[松尾さん](https://x.com/tmatsuo)の[geodjango](http://geodjango.org/)の話。

- GeoDjangoのDBサポートはpostgisが一番対応してます。
- Adminで地形のエリア編集などは地図のJavascriptアプリで楽々
- GeoDjangoのGeoManagerで `filter(field__poly_contains=point)` ができる。

## ContentType

次は増田さんのGenericForeignKeyの話と、次に岡野さんのContentTypeの話

- `GenericForeignKey`は`ContentType`と`object_id`のフィールドのラッパーに過ぎない
- `ContentType`で`Model`の処理が結構一般的にできる([岡野さんのサンプルアプリ](http://bitbucket.org/tokibito/sample_nullpobug/src/tip/django/ct_sample/))
- `ContentTypeManager`の`get_for_model()`と、`ContentTypeのget_object_for_this_type()`で色な面白いことができる。

## モバイル

次に、OpenIdの話と、最後に[酒徳さん](http://d.hatena.ne.jp/perezvon/)のDjangoでモバイルサイトの話

- モバイルの開発は大変
- セッションを使わずにurlでフォームウィザードみたいなのを作るのがあり
- [gumi](http://gu3.jp/)がよくできてる。

## まとめ

- アクセンス・テクノロジーの人たちに感謝
- 懇親会で酒徳さんと松尾さんといい話をして楽しかった
- アクセンスから、かっこいい手帳をもらった。

参加したみんなさん、お疲れ様でした！
