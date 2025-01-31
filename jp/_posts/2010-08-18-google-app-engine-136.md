---
layout: post
title: "Google App Engine 1.3.6"
date: 2010-08-18 09:46:54 +0000
permalink: /jp/google-app-engine-136
blog: jp
tags: python google appengine
render_with_liquid: false
locale: ja
---

今日、 [Appengine](http://code.google.com/appengine/) 1.3.6
がリリースされました。今回の大きいなリリースは以下の4つです。元のブログポストは
[こちら](http://googleappengine.blogspot.com/2010/08/multi-tenancy-support-high-performance_17.html)

# 1\. データの名前空間API

これは結構おもしろくて、データを名前空間を使うと、ユーザーのデータを完全に分けることができる。たとえば、xxx.jp と yyy.jp
は自分が作ったアプリケーションを使っているとすると、 xxx.jp のデータと、 yyy.jp
のデータを名前空間で分けて、そのユーザーは自分のバージョンを見ると、自分のデータしかみれない。というような仕組みが作れるようになりました。

日本語のドキュメントがまだないみたいだけど、
[Python](http://code.google.com/intl/ja/appengine/docs/python/multitenancy/)
と [Java](http://code.google.com/appengine/docs/java/multitenancy/)
のドキュメントを見てみてください。

# 2\. 高速画像サービング

Picasa のインフラーを使っていて、リサイズ、切れ抜きなどの自動変換した画像を高速でサーブできるようになった。Python の
[get_serving_url](http://code.google.com/appengine/docs/python/images/functions.html)
か、 Java の
[getServingUrl](<http://code.google.com/appengine/docs/java/javadoc/com/google/appengine/api/images/ImagesService.html#getServingUrl(com.google.appengine.api.blobstore.BlobKey)>)
を使うと画像のURLを取得できる。
このURLを使うと別のインフラを使うので、アプリケーションのCPUクオータとダイナミックサービングロード、データストアアクセスクオータなどがかからないというのが特徴です。

# 3\. カスタムエラーページ

オーバークオータエラーとか、システムエラーの場合、カスタムページを使うことができるようになりました。
[Javaのドキュメント](http://code.google.com/appengine/docs/java/config/appconfig.html)
と
[Pythonのドキュメント](http://code.google.com/appengine/docs/python/config/appconfig.html)
をお読みください。

# 4\. クオータ

ようやく、 クエリーと、カウントの
1000件リミットを外すことにしました。これから、莫大クエリーは早く返ってこないだろうけれど、1000件リミットではなく、自分のCPUクオータと、リクエスト時間がネックになります。無料アプリケーションは
Burst クオータも、有料アプリケーションの同じレベルになりました。
[クオータリミットのドキュメント](http://code.google.com/appengine/docs/quotas.html)
