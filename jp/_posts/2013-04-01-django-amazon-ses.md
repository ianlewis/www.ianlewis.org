---
layout: post
title: "Django で Amazon SES を使う"
date: 2013-04-01 13:00:00 +0000
permalink: /jp/django-amazon-ses
blog: jp
tags: python django aws
render_with_liquid: false
locale: ja
---

Amazon さんが、Amazon Web Services の下にメール送信サービス[Simple Email Service (SES)](http://aws.amazon.com/jp/ses/)を提供している。このサービスは、主に大量なメールでも正しく送信して、メールがちゃんと届くようにサービスを提供している。

[Connpass](http://connpass.com/) ではメール送信にSESを使っている。その事実がユーザーさんに判明されていたので、Djangoではどう使えばいいかを説明したいなと思った。

<!-- TODO: Add Twitter screenshot for tweet below -->

<!-- textlint-disable spelling -->

> connpass が AWS SES 使ってる。SES結構便利だからもっといろんなところで使えるケースあると思うんだけどなぁ。
> &mdash; TATSUYA (@tatsuya_info)

<!-- textlint-enable spelling -->

実は、SESをDjangoで使うのが簡単過ぎて、あまりネタにならないので、Django の説明とSESのはまりどころの話をしょうと思っている。本来は この話は Djangoよりは、SESの話になるかも。

## `django-ses`

Connpass は[`django-ses`](https://github.com/hmarr/django_ses/)を使っている。`django-ses`はDjangoの[`EMAIL_BACKEND`](https://docs.djangoproject.com/en/1.5/ref/settings/#email-backend)設定で使えるメールバックエンドを提供している。内部では、[`boto`](http://docs.pythonboto.org/en/latest/)というAWS APIのためのクライアントライブラリを使っている。

インストールはうつもの `pip` で簡単:

```shell
pip install boto django-ses
```

そして、Djangoの`settings..py`で4つの設定を加える。以下の適当な値が入っているので、自分のAWSアカウントの該当の設定を入れてください。

> NOTE: `AWS_ACCESS_KEY_ID`と`AWS_SECRET_ACCESS_KEY`とアクセス権限について、もうちょっと書くので、下まで読んで下さいね。

```python
AWS_ACCESS_KEY_ID = '<access key>'
AWS_SECRET_ACCESS_KEY = '<access secret>'
EMAIL_BACKEND = 'django_ses.SESBackend'
SERVER_EMAIL = u"noreply <no-reply@example.com>"
```

この３つの設定で Django アプリの修正は終わり。`AWS_ACCESS_KEY_ID`と`AWS_SECRET_ACCESS_KEY`は[`django-storages`](http://django-storages.readthedocs.org/en/latest/)と共通なので、S3と簡単に同時に使えます。

それで、アプリケーションで普通にDjangoの`send_mail()`を呼び出すことで、SES経由でメール送信できる。

## 本番アクセス

最初にアカウントをセットアップした時、SESは「sandbox」モードになっている。sandboxモードは特に使い方は特殊ではないのですが、メール送信が大きく制限されている。

- メール送信は24時間で最大200件
- 速度は最大秒間1件
- 確認したメアドからしか送信できない(Fromヘッダー)
- 確認したメアドにしか送れない(Toヘッダー)

SESを本格的に使う場合は[Production Access](http://docs.aws.amazon.com/ses/latest/DeveloperGuide/request-production-access.html)を申請する必要がある。本番アクセスの許可が来るまでに数日がかかるので、余裕を持って申請をしてください。

## クオータ

設定が非常に簡単ですが、AWS側でいろな設定が必要です。まずは、クオータの話。AWSはメール送信のクオータがあります。最初はクオータが小さくて、信用性が高いメールを送信するにつれて、クオータが上がってくる仕組みになっています。上がってくるタイミングはメールの量で変わってくるけど、少なくとも１段階上がるのに、数日かかります。

最初のクオータは正直小さすぎて、本番アプリには使い物にならないので、クオータが上がるように、何日間でSESの導入テストを行なう必要がある。メールの内容も見ているようなので、アプリケーションが送っているメールと同じような内容で送ればいいです。何かの自前で作ったスクリプトで適当なメールを送っちゃいけない。本番でリリース時にメールのが内容が急にかわったり、そもそもスパムっぽいメールを送ってしまったりするとAPIから怪しく見れて、メールを拒否するかもしれない。

以下は[Amazonのドキュメント](http://docs.aws.amazon.com/ses/latest/DeveloperGuide/increase-sending-limits.html)に書いているクオータが上がるための勧め。

1. **Send high-quality content** (質のいい内容を送る。スパムをそもそも送らない)
2. **Send real production content** (本番と同じような内容を送る)
3. **Send near your current quota** (クオータに近い量を送る)
4. **Have low bounce and complaint rates** (bounce と complaint率を低くする)

１と２と４は常にやればいいことだね。そうしないと、メール送信が拒否される場合があります。

３はクオータが上がって欲しい時にやればいい。つもり、クオータの制限に近づかなければ、SESがそのクオータに問題ないと判定して、クオータを上げてくれない。クオータの制限によく近づく場合は、クオータを上げる必要性を検出して、上げてくれる。

Connpassでやった時は、メール送信量は１日5000件くらいじゃないと厳しいと思って、SESのクオータがリリースギリギリまで、上がって来なかった。今は少し増しになっているかもしれないけど、確かにConnpassの場合は必要なレベルに上がるまでに少なくとも２週間くらいかかったと思います。

最後に、クオータの自動調整と別に制限を上げる要求([Extended Access Request](http://docs.aws.amazon.com/ses/latest/DeveloperGuide/submit-extended-access-request.html))を出すことが出来る。ただし、すぐアカウントを作った後にはこれは期待できない。

## メール受信

SESはメール受信の機能がないですが、自分のサーバーでPostfixなどを立てて、DNSの`MX`レコードを設定すれば、SMTPで受信することができます。ただし、SMTPサーバーを立てなければ、特に何もしなくともいいですが、SMTPサーバーをたてる場合、SESで送信するメールのFromに入っているアドレスは、SMTPサーバーにも登録されてないといけないらしいです。

わざわざ`noreply`のメアドはSMTPサーバーに登録しなくてもいいじゃんって思う人は多いと思うのですが、SESのスパム防止の対策で、SMTPサーバーにメアド存在チェックの為に、見に来ます。実際のPostfixログでAWSからアクセスが来ているが見れます。SMTPサーバーにそのメアドが登録されてないと以下のエラーメッセージでメール送信が拒否される場合があります。これは実際にConnpassで起こった問題です。

```text
BotoServerError: BotoServerError: 400 Bad Request
<ErrorResponse xmlns="http://ses.amazonaws.com/doc/2010-12-01/">
  <Error>
    <Type>Sender</Type>
    <Code>MessageRejected</Code>
    <Message>Address blacklisted.</Message>
  </Error>
  <RequestId>hogehoge</RequestId>
</ErrorResponse>
```

メールサーバーは具体的に何を返せばいいのか？ まず、以下の感じだと そのメールアドレスが登録されていないことが確認できる。

```shell
$ telnet localhost 25
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.
220 connpass.com ESMTP Postfix (Debian/GNU)
helo hi
250 connpass.com
mail from: <hoge@example.com>
250 2.1.0 Ok
rcpt to: <no-reply@connpass.com>
550 5.1.1 <no-reply@connpass.com>: Recipient address rejected: User unknown in local recipient table
```

登録されている場合、以下の感じになります。

```shell
$ telnet localhost 25
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.
220 connpass.com ESMTP Postfix (Debian/GNU)
helo hi
250 connpass.com
mail from: <hoge@example.com>
250 2.1.0 Ok
rcpt to: <no-reply@connpass.com>
250 2.1.5 Ok
```

no-reply のユーザーだと、以下コマンドを実行すると、メアドを登録することができます。 こうすると、 no-reply
に来るメールはすべて無視します。

```shell
# sudo echo "no-reply: /dev/null" >> /etc/aliases
# sudo newaliases
```

## まとめ

SESはセットアップが少し面倒くさくて時間かかるのですが、メールが届かない問題や、スパムとして判定される問題が避けるのが大きなメリットで、Connpassで使ったのが良かったと思います。`django-ses`でBackend切り替えだけですし、ベンダーロックインなどはそんなに問題なくて安心です。

SES もバウンスメールの処理もできるので、その処理を今 [僕の`django-ses`のフォーク](https://github.com/IanLewis/django-ses/compare/master...bounce_notifications)を実装しようとしていますので、興味ある方は見てみてください。
