---
layout: post
title: "App EngineのMaster-Slaveデータストアを廃止する件"
date: 2015-07-03 20:21:56 +0000
permalink: /jp/app-engine-master-slave-migration-ja
blog: jp
tags: appengine
render_with_liquid: false
---

App Engineの一部のユーザーに最近は以下のようなメールが何件届いていると思います。こういうようなメールは英語で書かれいて、「英語を読むの面倒くせぇー、スルーしよう」ってメールを消す方が多いんじゃないかなと思うんだが、実は重要なお知らせです。

![Master-Slave Datastore Email](https://storage.googleapis.com/static.ianlewis.org/prod/img/736/master-slave-datastore-email.png)

このお知らせは、 **「Master-Slave Datastoreが廃止され、High Replication Datastoreに移行しなければ、あなたのアプリは7月６日（月）に無効になるよ」** というお知らせ。(正確に言えば、６日PSTなので、日本からいうと７日の朝頃)

# 背景

App Engineが最初にリリースされた時(2008年頃の夏頃)に、データストアというデータベースシステムが組んでいて、同期マスタースレーブレプリケーションをするデータベースでした。これはいわゆる Master-Slave Datastore. リリースした約２年半後(2011年１月頃)、High Replication Datastoreという次世代データストアをリリースした。このデータストアは Master-Slaveの動きの異なっていて、自動的にマイクレーションするのが困難。だけど、Googleがマイグレーションツールを提供して、開発者が自前でマイグレーションできるようにした。「Master-Slaveが廃止されます。High Replicationに移行してください」とドキュメントや、App Engineの管理画面に３年間の廃止期間に表示された。

それじゃ、わからないよ！ってユーザーがたくさんいるだろうし、せっかくに作っていて、ずっと動いていたアプリが動かなくなるのがよくないから、この記事を書いた。

# どうすればいいのじゃ

まずは、 [ドキュメント](https://cloud.google.com/appengine/docs/deprecations/ms_datastore) を詳しく読むのがいいと思います。英語だけど、一番詳しく書いているのがこれなので、読むべし。

次は Master-Slave から High Replication Datastore のマイグレーションを行う必要がある。 [マイグレーションツールのドキュメント](https://cloud.google.com/appengine/docs/adminconsole/migration)を見れば、やり方がわかると思います。日本語がいいという方は [Google先生に聞けば](https://www.google.co.jp/webhp?ie=UTF-8#q=Master%2FSlave+High+Replication+Datastore+%E7%A7%BB%E8%A1%8C)、やり方が書いている記事がたくさん出てくると思います。

# 移行しなかったらどうなる？

移行は６日まで無理と言う方は、一旦ご安心ください。６日にアプリが無効になるんですが、再有効化できるようになっている。そして、１３日、２０日、２７日にまだ無効になるけど、再有効化することができる。８月３日にはアプリがまた無効になるが、再有効化ができなくなります。その後、そのアプリは動かないけど、１０日までデータのマイグレーションはできます。

つもり、頑張って毎週に有効化すれば最悪の場合８月３日までにマイグレーションすれば、スムーズに移行できる。廃止にスケジュールは[ドキュメント](https://cloud.google.com/appengine/docs/deprecations/ms_datastore)の「Shutdown timetable」のところに書いている。

もし、質問があったら、[@IanMLewis](https://twitter.com/IanMLewis)に連絡してください

**Update:** [FAQ](http://qiita.com/IanMLewis/items/ffab882797df24757fa3)も作ってみたので、ご参考にしてください。
