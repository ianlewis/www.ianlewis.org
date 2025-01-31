---
layout: post
title: "Google Appengine SDK 1.4.0 がリリースされました！"
date: 2010-12-03 09:16:18 +0000
permalink: /jp/google-appengine-sdk-140
blog: jp
tags: python google appengine
render_with_liquid: false
locale: ja
---

[Google Appengine](http://code.google.com/appengine/)1.4.0がリリースされました！！このリリースはかなりでかい！！チャンネルAPI,"Always On"(リザーブインスタンス)、タスクキューの正式リリース、スタートアップリクエスト、バックグラウンド処理の改善などなど、

## チャンネルAPI

まずは、一番重要なチャンネルAPI。チャンネルAPIでクライアントブラウザーにプッシュすることができるようになります。内部的には、[Google Talk](http://www.google.com/talk/intl/ja/)の[XMPP](http://ja.wikipedia.org/wiki/Extensible_Messaging_and_Presence_Protocol)インフラを使っているらしくて、それでスケールアウトしてくれます。チャンネルAPIは2つの部分がに分けています。サーバー再度のチャンネルAPIとチャンネルAPIのJavascriptライブラリ。

チャンネルAPIはサーバー側から、クライアントの通信に使います。クライアントからサーバーへの通信は今までどおりのPOSTがGET HTTPリクエスト。

### サーバー側

まずは、チャンネルのIDをクライアントに渡す。クライアントはそのIDを使って、チャンネルに接続する。

`channel.create_channel()`に渡す`user`は、ユーザーだけじゃなくて、内部的に文字列にするので、`create_channel()`に渡すデータは単の文字列でも大丈夫です。

```python
from google.appengine.ext import webapp
from google.appengine.api import channel
from django.template.loader import render_to_string

class MyHandler(BaseHandler):
    def get(self):
        user = users.get_current_user()

        # ユーザーのチャンネルを作る
        # create_channel に渡すデータは単の文字列でも大丈夫
        id = channel.create_channel(user)

        return self.response.out.write(
            render_to_string(
                "index.html",
                {"channel_id": id},
            )
        )
```

クライアント側のJavascriptはチャンネルに接続

```javascript
var channel = new goog.appengine.Channel("{{ channel_id }}");
var socket = channel.open();
socket.onopen = function () {
  window.setTimeout(function () {
    alert("Connected!");
  }, 100);
};

// メッセージのハンドラーを登録
socket.onmessage = function (evt) {
  // テキストを受けているけど、JSONがおすすめ
  // var o = JSON.parse(evt.data);
  alert(evt.data);
  // do something
};
```

サーバーからクライアントにメッセージを送る

```python
from google.appengine.api import channel
from google.appengine.api import users

class AjaxHandler(BaseHandler):
    def get(self):
        user = users.get_current_user()

        # メッセージをクライアントに渡す。
        # クライアントが接続している状態が不要
        # 誰も接続してない場合は何もしない
        # ここでテキストデータを送るけど、JSONがおすすめです
        channel.send_message(user, "Hello World!!")
```

Channel API のドキュメント:
<http://code.google.com/intl/ja/appengine/docs/python/channel/overview.html>

## Always On

今までは、リクエストが少ない場合は、Appengineのサーバーインスタンスがすべて落とされるので、リクエストがその状態で来た時、かなりスピンアップ(サーバーインスタンスの起動)に時間かかってしまいました。"Always On"という機能を使うと３つのインスタンスを保持してくれます。有料ですが、かなりスピンアップに困っている人に好調的だね。

> **Note:** "Always On"はアクセスがあんまりこない時のみに効果があるので、自分のアプリは常にトラフィック量が高い場合、最低３つのインスタンスを保持してもしょうがないです。３つまで下がってないからです。

## スタートアップリクエスト

この機能もスピンアップにいいのですが、効果がちょっと違うので、説明します。今まで、リクエストが増えて、スケールアウト（新しいインスタンスの起動)が必要な場合、あるリクエストが新しいインスタンスに割り当てると、インスタンスがロードに時間かかったり、`DeadlineExceededError`が出たりしました。

スタートアップリクエスト機能は、スケールアウトが必要な場合、ユーザーからのリクエストを割り当てる前に、スタートアップリクエストをインスタンスに投げる。このリクエストで必要なモジュールを未然にロードできるようになります。それで、最初のユーザーリクエストが来たら、より速く返せるようになります。

つまり、スタートアップリクエストがスケールアウトする時に効果があるので、インスタンスがいくらでもあっても効果的です。

使うには、まずはメールみたいに、`inbound_services`を`app.yaml`に設定します。

```yaml
inbound_services:
  - warmup
```

スタートアップリクエストが`/_ah/warmup`のURLに来るので、スタートアップリクエストを受けとるURLを`app.yaml`に設定する。

```yaml
- url: /_ah/warmup.*
  script: warmup.py
```

`warmup.py`の中に、必要そうなモジュールをインポートする。

```python
# ロードが重いモジュールを未然にロードする
import mybigmodule
import myothermodule

def main():
    print "Content-type: text/plain"
    print "OK"
```

## タスクキュー正式リリース

今まで、AppengineのタスクキューはBetaで`google.appengine.api.labs.taskqueue`に入っていたけど、labsから卒業するので、`google.appengine.api.taskqueue`に移動される。タスクキューのデータもデータのクオータに含まれるようになります。データクオータにひっかかるので、ヘビーに使っている人たちはちょっと大変かもしれない。

## cron/タスクキューの改善

cronとタスクキューの時間制限は今まで、30秒でしたが、10分になります。ですが、長く実行しているcronジョブ・タスクは認識され、別インフラに移動されて、スループット(実行頻度）が落ちるので、速くて小さいタスクが良好だと言われる。

## Metadata クエリー

Appengineデータストアのメタデータ、`Namespace`,`Kind`,`Property`をクエリすることができるようになりました。メタデータのモデルクラスは`google.appengine.ext.db.metadata`モジュールに入っています。

`Kind`インスタンスが持っている`Property`の親になるので、ある`Kind`の`Property`を取得するには、`ancestor()`クエリができます。

```python
from google.appengine.ext.db.metadata import Namespace, Kind, Property

for namespace in Namespace.all():
    print namespace.namespace_name

for kind in Kind.all():
    print kind.kind_name
    for property in Property.all().ancestor(kind):
        print "    %s" % property.property_name
```

## ダウンロード

<http://code.google.com/intl/en/appengine/downloads.html> ではまだ出てないみたいですが、code.google.comのプロジェクトの以下のURLからダウンロードできます。

- Python: [google_appengine_1.4.0.zip](http://code.google.com/p/googleappengine/downloads/detail?name=google_appengine_1.4.0.zip)
- Java: [appengine-java-sdk-1.4.0.zip](http://code.google.com/p/googleappengine/downloads/detail?name=appengine-java-sdk-1.4.0.zip)
- [リリースノート](http://code.google.com/p/googleappengine/wiki/SdkReleaseNotes)
