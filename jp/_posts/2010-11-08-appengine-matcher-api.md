---
layout: post
title: "Appengine Matcher API"
date: 2010-11-08 09:33:06 +0000
permalink: /jp/appengine-matcher-api
blog: jp
tags: python appengine mapper
render_with_liquid: false
---

Matcher APIはあるオブジェクトが登録したクエリーにマッチするかをスケーラブルにチェックしてくれるサービスです。
クエリーが既に登録しているから、あるオブジェクトが一つ一つの登録したクエリーにマッチするかが他のクエリーに依存しないので、
[Map-Reduce](http://ja.wikipedia.org/wiki/MapReduce)
で簡単に平行で処理を分担してスケールできる。

# 何に使うか

これが少し分かり辛いところかもしれないので、少し説明します。クエリーを未然に登録するので、 Prospective Search
(プロスペクティブ検索、展望検索、予測検索?) と言います。
みんな使っている、普段の検索は、Retrospective Search
(遡及検索) です。クエリーが決まってないので、データをインデクスを作って、後でユーザーがデータを クエリーする形になっています。

プロスペクティブ検索は、未然にクエリーを決めて、そのクエリーにマッチするデータが出たら、ユーザーに通知する形になります。考えてみると、
遡及検索が同期と言いますと、プロスペクティブ検索は非同期です。
プロスペクティブ検索を使っているサービスの一番知られているのは、
[Google アラート](http://www.google.com/alerts?hl=ja) だと思います。

Appengine の Mapper API はまさにそういう機能を簡単に作るような
API。たくさんの通知を送らないといけないアプリケーションに強いものです。

# クエリーを登録する

以下のコードで、自分の [Twitter](http://twitter.com/)
タイムラインであるテキストにマッチすると、アラートを飛ばす機能を作る。
まずは、クエリーを登録する。クエリーは db.Model, db.Entity, dict データから作れます。 db.Entity, dict
の場合、データの スキーマと、 topic(データ名)というものを指定しないといけません。
db.Modelからクエリーを作る場合は、Modelクラスから
スキーマと、topic(モデル名)を取れるので、指定しなくても良いです。

unsubscribe することもできます。

参考:
<http://code.google.com/p/google-app-engine-samples/wiki/AppEngineMatcherService#API_methods>

```python
from google.appengine.api import matcher

def add_tweet_alert(user, tweet_text):
    # クエリーはMapper API のクエリー言語を使う
    # 参考: http://code.google.com/p/google-app-engine-samples/wiki/AppEngineMatcherService#Query_Language
    query = 'text:"%s"' % tweet_text

    # 読者IDはユニーク化しないといけないので、user_id と テキストから作る
    subscribe_name = "%s:%s" % (user.user_id(), tweet_text)

    # dict もしくは、 db.Entity オブジェクトで登録すると、スキーマが必須です。
    # 参考: http://code.google.com/p/google-app-engine-samples/wiki/AppEngineMatcherService#Document_Schema
    schema = {
        'str': 'text',
    }

    # dict もしくは、 db.Entity オブジェクトで登録すると、スキーマが必須です。
    # topic はデータスキーマの名前という意味がします。
    topic='Tweet'

    matcher.subscribe(dict, query, subscribe_name, schema=schema, topic=topic)

def remove_tweet_alert(user, tweet_text):
    query = 'text:"%s"' % tweet_text
    subscribe_name = "%s:%s" % (user.user_id(), tweet_text)
    topic='Tweet'

    matcher.unsubscribe(query, subscribe_name, topic=topic)
```

# データのマッチング

次に、データを処理した時に、 Matcher API に渡して、マッチしてもらいます。 Matcher API の結果が非同期で来ますので、
`matcher.match()` はタスクキューにタスクを入れたの同じ感じで使います。

```python
from google.appengine.api import matcher

def process_timeline(timeline):
    # python-(oauth)twitter の Status オブジェクトを期待する
    for tweet in timeline:
        # subscribe()と同じスキーマとtopicを使う
        document = {'text': tweet.text}
        topic = 'Tweet'

        matcher.match(document, topic=topic)
```

# マッチした結果を処理する

マッチした結果が非同期で、マッチ結果のURLにHTTPリクエストとしてきます。 デフォールトは `/_ah/matcher`
というURLに来ますけど、 `match()` を呼び出すときに、 `result_relative_url`
というキーワード引数として、 指定できます。

結果のデータがバッチでリクエストURLに来ますので、リストで処理する必要があります。
検索結果の１ページが１リクエストで来るイメージだと考えられます。

```python
#
# app.yaml に以下のURLを追加
#
# - url: /_ah/matcher
#   script: path/to/this/module.py

from google.appengine.ext import webapp
from google.appengine.api import mail
from google.appengine.api import matcher

def main(argv):
    application = webapp.WSGIApplication(
        [# ...
        ('/_ah/matcher', MatchResults)])

class MatcherHandler(webapp.RequestHandler):
    def post(self):
        # 読者 ID ('user_id:text')のリストを返す  ( ['123:アップエンジン', '124:経済', ...] )
        match_ids = self.request.get_all('id')

        # 結果の数 == len(match_ids)
        results_count = self.request.get('results_count')    #

        # 結果のオフセット。結果のページングみたいに、オフセットが来る
        results_offset = self.request.get('results_offset')

        # マッチしたデータを取得する
        document = matcher.get_document(self.request)

        for id in match_ids:
            user_id, text = id.split(":")

            # get_user() を自分で実装してね
            user = get_user(user_id)

            user_email = "%s <%s>" (user.nickname(), user.email())

            mail.send_mail(sender="Example.com Support <support@example.com>",
                           to=user_email,
                           subject="Timeline match for %s" % text,
                           body="""
%s 様,

Twitter タイムラインに'%s'というテキストを見つかりました。

%s
""" % (user.nickname(), document.get('text')))
```

# まとめ

これで Matcher API のアプリケーションを作りましたが、通知のあるアプリケーションに
結構強いかなと思います。例えば、雨の日だとか、熱い日だとか、自分が欲しい天気情報
を通知してくれるサービスとかができたら面白いかなと思っています。

Matcher APIはまだ本番 Appengine にリリースしていないのですが、1.3.8の SDK
に入っていますので、ローカルで試すことができます。 後、
Trusted Tester の権限を 得られると、本番で試すことができます。 以下のリンクで申請することができます。

<https://spreadsheets.google.com/a/google.com/viewform?hl=en&formkey=dG5XNnlVWXJYWG1yS0ExV2RmTW5EZEE6MQ#gid=0>
