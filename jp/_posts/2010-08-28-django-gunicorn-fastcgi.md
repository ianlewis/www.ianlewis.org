---
layout: post
title: "Django アプリサーバ、gunicorn と fastcgi の比較"
date: 2010-08-28 13:34:39 +0000
permalink: /jp/django-gunicorn-fastcgi
blog: jp
tags: python django
render_with_liquid: false
---

![image](/assets/images/624/large_gunicorn_big.png)

# 概要

最近、会社では、fastcgi より、 [gunicorn](http://gunicorn.org/) を使うのがどう？
といわれました。gunicorn を触ったことない僕は fastcgi
のロードテストも実際やったことなくて、メソッドについて、(prefork
がいいか、 threadedがいいか) の読んでいたものを元にした推測しかできない状態で、知識足りないと思った。

gunicorn は何かというと、python で作られた
[WSGI](http://ja.wikipedia.org/wiki/Web_Server_Gateway_Interface)
に対応するウェブサーバーです。同期、非同期ウェブアプリ両方対応できますし、作りがよくてかなりスピーディーそうですし、Django
アプリを簡単に組み込めますし、python で運用が楽というのがポイントですね。もちろん、エンドユーザーが直接 gunicorn
に接続するのではなく、 nginx のローダーバランサーでプロクシーのが一般的だと思っています。

# テストアプリケーション

ということで、ちゃんとテストしようと思いまして、gunicorn と fastcgi prefork と fastcgi threaded
を比較できるテスアプリを作りました。 [bitbucket
にアップ](http://bitbucket.org/IanLewis/gunicorn-test)
しましたので、ご参考ください。

まず、 [buildout](http://www.buildout.org/)
を使いましたので、以下のコマンドでテストサーバーの環境を作ります。
mysql と nginx も必要なので、インストールしておいてください。

```text
python bootstrap.py
./bin/buildout init -d
./bin/buildout
```

プロジェクトディレクトリのなか、 fastcgi_nginx.conf と gunicorn_nginx.conf
ができるので、それぞれのテストをするときに、リンクを/etc/nginx/sites-enabled/
においてください。アプリは同じポートを使っているので、両方のconf ファイルを同時に有効にすることができない。gunicorn
を有効にするときに、まず、fastcgi のリンクを /etc/nginx/sites-enabled/
から削除してください。

mysql の DB は以下のSQLで作れます。

```sql
CREATE DATABASE gunicorn_test CHARACTER SET utf8;
```

DBを作った後に、syncdb コマンドを実行してください。管理者は特にいらないので、 'no' を入力して大丈夫です。

```text
./bin/syncdb
```

同じポートを使いますし、同時に立ち上げることができないんですが、それぞれのアプリサーバーは以下のように立ち上げます。

```text
./bin/runfcgi                         (fcgi prefork)
./bin/runfcgi_threaded                (fastcgi threaded)
./bin/run_gunicorn -w <# of workers>  (gunicorn)
```

テストアプリはトップページしかなくて、一つのフォームを持って、一ページくらい(20個)のコンテンツを表示するような処理をします。

クライアントは以下のように環境をつくれます。

```text
cd testing/httpclient
python bootstrap.py
./bin/buildout init -d
./bin/buildout
```

クライアントは以下のように実行できます。クライアントのプロセス数と遅延時間を指定できます。遅延時間でテストの期間を指定できます。
デフォールトはプロセス数 500 で、遅延時間 10秒。この設定で、 500
プロセスの処理を10秒の間に伸びます。1秒目は50プロセス、2秒目は50プロセス。。。と言うふうにテストを行います。つまり、1秒間のテスト数はプロセス数わり遅延時間
(500 / 10 = 50)

```text
./bin/python run_test.py <host> <# processes> <wait time>
```

クライアントが行う処理は、トップページを表示し、フォームにテキストデータを入れて、POSTする処理です。なので、１プロセスは3回リクエストをします。
トップページを表示、POST・リダイレクト、トップページを表示
と言う風なテストを行います。なぜなら、ページの閲覧とデータの登録が激しいテストをしたかったわけです。

# テストの環境

私は今まで知っていたかぎり、theaded はメモリを節約してくれるけど、コアを使いこなせなくて、 メモリが足りるなら、prefork
の方がいいという認識でした。 gunicorn もマルチプロセスモデルを使っているので、同じくthreaded
より早いはずだが、http の解析は fastcgi より若干遅いかなと思いました。gunicorn
の作りが全く別なので、なんとも言えないけど、作りが一緒んであれば、http よりfastcgi が若干早いはず。

このテストは [EC2](http://aws.amazon.com/jp/ec2/) 上で行い、 [ハイCPU ミディアム
インスタンス](http://aws.amazon.com/jp/ec2/instance-types/) 5台
(サーバー1台、 クライアント4台)。
なぜかというと、複数のコアを使いこなすかどうかをテストしたかったわけです。サーバーインスタンスは2ギガくらいメモリを持っているので、かなりのリクエストを処理するには充分足りるかと思っていました。

gunicorn は 5ワーカー(リクエストを処理するプロセス)を使ってテストしました。 gunicorn はコア数 \* 2 + 1
のワーカーを使うのを
[おすすめしています](http://gunicorn.org/design.html#how-many-workers)
。

毎回テストを行う前にDBをクリアしました。

```text
echo "delete from perftest_mymodel;" | mysql -u root gunicorn_test
```

テストを行った時に、 1クライアント500プロセス、10秒間にしました。ようするに、
2000ユーザーを同時にアプリをアクセスして、サーバーの処理できるリミットをテストしました。

```text
./bin/python runtest xxx.compute.internal 500 10
```

# テストの成果

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

Min time は最低処理時間 (1プロセス)、Max Time は最高処理時間(1プロセス)、 Average Time
は平均処理時間(1プロセス)、Errors
は途中でエラーが出て失敗して、処理が出来なかった率とプロセス数。エラーが出たプロセスは時間の計測に入らない。

# まとめ

fastcgi は思ったより頑張ってましたが、メモリが充分あれば、プロセスモデルを使った prefork
メソッドを使うべきでしょうね。平均処理する時間が半分になり、途中でエラーが出る率も半分になりますよね。

gunicorn の場合は処理時間がfastcgi の prefork
と少し早く見えますけど、最低処理時間が少し高くなって、あんまりかわらないんですが、エラー数が
prefork よりさらに半分くらいになりました。要するに、gunicorn は fastcgi prefork
より多くのユーザーを扱うことができました。
ということは、本当の運用しているアプリケーションにgunicorn
がリソースをより効率的に使う可能性が高いですね。 [BeProud](http://www.beproud.jp/)
ではもうちょっと検討するのですが、非同期アプリケーションの仕事も増えていますし、将来にgunicorn
を使うのが良さそうに見えます。

もし、誰かがこのテストを使ったら、他のハードウエア、環境などでは、どういう結果がでるかを聞きたいと思っています。もしくは、テストについてのコメントがあれば、ぜひ宜しくお願いします。
