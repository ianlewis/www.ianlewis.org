---
layout: post
title: "Django アプリサーバ、gunicorn と fastcgi の比較"
date: 2010-08-28 13:34:39 +0000
permalink: /jp/django-gunicorn-fastcgi
blog: jp
tags: python django
render_with_liquid: false
locale: ja
---

![image](/assets/images/624/large_gunicorn_big.png)

## 概要

最近、会社では、fastcgiより、[gunicorn](http://gunicorn.org/)を使うのがどう？といわれました。gunicornを触ったことない僕はfastcgiのロードテストも実際やったことなくて、メソッドについて、(preforkがいいか、threadedがいいか)の読んでいたものを元にした推測しかできない状態で、知識足りないと思った。

gunicornは何かというと、pythonで作られた[WSGI](http://ja.wikipedia.org/wiki/Web_Server_Gateway_Interface)に対応するウェブサーバーです。同期、非同期ウェブアプリ両方対応できますし、作りがよくてかなりスピーディーそうですし、Djangoアプリを簡単に組み込めますし、pythonで運用が楽というのがポイントですね。もちろん、エンドユーザーが直接gunicornに接続するのではなく、Nginxのローダーバランサーでプロクシーのが一般的だと思っています。

## テストアプリケーション

ということで、ちゃんとテストしようと思いまして、gunicornとfastcgi preforkとfastcgi threadedを比較できるテスアプリを作りました。[Bitbucketにアップ](http://bitbucket.org/IanLewis/gunicorn-test)しましたので、ご参考ください。

まず、[buildout](http://www.buildout.org/)を使いましたので、以下のコマンドでテストサーバーの環境を作ります。MySQLとNginxも必要なので、インストールしておいてください。

```shell
python bootstrap.py
./bin/buildout init -d
./bin/buildout
```

プロジェクトディレクトリのなか、`fastcgi_nginx.conf`と`gunicorn_nginx.conf`ができるので、それぞれのテストをするときに、リンクを`/etc/nginx/sites-enabled/`においてください。アプリは同じポートを使っているので、両方のconfファイルを同時に有効にすることができない。gunicornを有効にするときに、まず、fastcgiのリンクを`/etc/nginx/sites-enabled/`から削除してください。

MySQLのDBは以下のSQLで作れます。

```sql
CREATE DATABASE gunicorn_test CHARACTER SET utf8;
```

DBを作った後に、`syncdb`コマンドを実行してください。管理者は特にいらないので、'no'を入力して大丈夫です。

```shell
./bin/syncdb
```

同じポートを使いますし、同時に立ち上げることができないんですが、それぞれのアプリサーバーは以下のように立ち上げます。

```shell
./bin/runfcgi                         (fcgi prefork)
./bin/runfcgi_threaded                (fastcgi threaded)
./bin/run_gunicorn -w <# of workers>  (gunicorn)
```

テストアプリはトップページしかなくて、一つのフォームを持って、一ページくらい(20個)のコンテンツを表示するような処理をします。

クライアントは以下のように環境をつくれます。

```shell
cd testing/httpclient
python bootstrap.py
./bin/buildout init -d
./bin/buildout
```

クライアントは以下のように実行できます。クライアントのプロセス数と遅延時間を指定できます。遅延時間でテストの期間を指定できます。デフォールトはプロセス数500で、遅延時間10秒。この設定で、500プロセスの処理を10秒の間に伸びます。1秒目は50プロセス、2秒目は50プロセス。。。と言うふうにテストを行います。つまり、1秒間のテスト数はプロセス数わり遅延時間 (500 / 10 = 50)

```shell
./bin/python run_test.py <host> <# processes> <wait time>
```

クライアントが行う処理は、トップページを表示し、フォームにテキストデータを入れて、POSTする処理です。なので、１プロセスは3回リクエストをします。トップページを表示、POSTリダイレクト、トップページを表示と言う風なテストを行います。なぜなら、ページの閲覧とデータの登録が激しいテストをしたかったわけです。

## テストの環境

私は今まで知っていたかぎり、theadedはメモリを節約してくれるけど、コアを使いこなせなくて、 メモリが足りるなら、preforkの方がいいという認識でした。gunicornもマルチプロセスモデルを使っているので、同じくthreadedより早いはずだが、HTTPの解析はfastcgiより若干遅いかなと思いました。gunicornの作りが全く別なので、なんとも言えないけど、作りが一緒んであれば、httpよりfastcgiが若干早いはず。

このテストは[EC2](http://aws.amazon.com/jp/ec2/)上で行い、[ハイCPUミディアムインスタンス](http://aws.amazon.com/jp/ec2/instance-types/)5台(サーバー1台、クライアント4台)。なぜかというと、複数のコアを使いこなすかどうかをテストしたかったわけです。サーバーインスタンスは2ギガくらいメモリを持っているので、かなりのリクエストを処理するには充分足りるかと思っていました。

gunicornは5ワーカー(リクエストを処理するプロセス)を使ってテストしました。gunicornはコア数 \* 2 + 1 のワーカーを使うのを[おすすめしています](http://gunicorn.org/design.html#how-many-workers)。

毎回テストを行う前にDBをクリアしました。

```shell
echo "delete from perftest_mymodel;" | mysql -u root gunicorn_test
```

テストを行った時に、 1クライアント500プロセス、10秒間にしました。ようするに、2000ユーザーを同時にアプリをアクセスして、サーバーの処理できるリミットをテストしました。

```shell
./bin/python runtest xxx.compute.internal 500 10
```

## テストの成果

```text
fastcgi (threaded)
---------------------------

Min time: 0.0689101219177s
Max time: 23.1616601944s
Average Time: 8.089163658s
Errors: 1002 / 2000 (50.1%)

fastcgi (prefork)
---------------------------

Min time: 0.0668342113495s
Max time: 21.9225800037s
Average Time: 4.586471732s
Errors: 561 / 2000 (28.1%)

gunicorn
----------------------------

Min time: 0.0718009471893s
Max time: 21.6963949203s
Average Time: 4.199061027s
Errors: 293 / 2000 (14.7%)
```

Min timeは最低処理時間「1プロセス」、Max Timeは最高処理時間(1プロセス)、Average Timeは平均処理時間(1プロセス)、Errorsは途中でエラーが出て失敗して、処理が出来なかった率とプロセス数。エラーが出たプロセスは時間の計測に入らない。

## まとめ

fastcgiは思ったより頑張ってましたが、メモリが充分あれば、プロセスモデルを使ったpreforkメソッドを使うべきでしょうね。平均処理する時間が半分になり、途中でエラーが出る率も半分になりますよね。

gunicornの場合は処理時間がfastcgiのpreforkと少し早く見えますけど、最低処理時間が少し高くなって、あんまりかわらないんですが、エラー数がpreforkよりさらに半分くらいになりました。要するに、gunicornはfastcgi preforkより多くのユーザーを扱うことができました。ということは、本当の運用しているアプリケーションにgunicornがリソースをより効率的に使う可能性が高いですね。[BeProud](http://www.beproud.jp/)ではもうちょっと検討するのですが、非同期アプリケーションの仕事も増えていますし、将来にgunicornを使うのが良さそうに見えます。

もし、誰かがこのテストを使ったら、他のハードウエア、環境などでは、どういう結果がでるかを聞きたいと思っています。もしくは、テストについてのコメントがあれば、ぜひ宜しくお願いします。
