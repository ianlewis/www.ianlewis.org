---
layout: post
title: "Google App Engine 1.4.3 リリースされました！"
date: 2011-04-01 15:44:30 +0000
permalink: /jp/google-appengine-143
blog: jp
tags: python tech cloud
render_with_liquid: false
locale: ja
---

水曜日にGoogle App Engine 1.4.3がリリースされました！1.4.1と1.4.2はブログ記事を書くほど大きくはなかったのですか、1.4.3はまたいろいろ入っているので、ご紹介します。

## Prospective Search API

以前、[Matcher API のブログ記事](/jp/appengine-matcher-api)を書きましたが、Trusted Testerリリースで出ていたMatcher APIは「Prospective Search API」という名前で開発者全員にリリースされています。まだ、Labs機能で、正式リリースではない様ですけど、モジュール名が変わっています。

```python
from google.appengine.api import prospective_search

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

    prospective_search.subscribe(dict, query, subscribe_name, schema=schema, topic=topic)

def remove_tweet_alert(user, tweet_text):
    query = 'text:"%s"' % tweet_text
    subscribe_name = "%s:%s" % (user.user_id(), tweet_text)
    topic='Tweet'

    prospective_search.unsubscribe(query, subscribe_name, topic=topic)
```

`matcher`というモジュールが、`prospective_search`というモジュール名になった意外は、特に大きいな変更はなさそうですね。

## Testbed

Testbedはテストを実行できるために、App Engine環境を偽装するものです。開発サーバーみたいに、App Engine本番にデプロイせずに、ローカル環境で、Memcached、DatastoreなどのApp Engineのサービスがテストの中に使えます。

```python
import unittest
from google.appengine.ext import testbed

class TestModel(db.Model):
    """A model class used for testing."""
    number = db.IntegerProperty(default=42)
    text = db.StringProperty()

class DemoTestCase(unittest.TestCase):

    def setUp(self):
        # Testbedクラスインスタンスを生成
        self.testbed = testbed.Testbed()

        # Testbed を活性化させる
        self.testbed.activate()
        # 使用するサービススタブを設定する。
        self.testbed.init_datastore_v3_stub()
        self.testbed.init_memcache_stub()

    def tearDown(self):
        # クリーンアップ
        self.testbed.deactivate()

    def testInsertEntity(self):
        """ モデル格納のテスト """
        TestModel().put()
        self.assertEqual(1, len(TestModel.all().fetch(2)))
```

デフォールト環境変数も設定できます。

```python
class DemoTestCase(unittest.TestCase):
    def setUp(self):
        self.testbed.setup_env(app_id=application-id)
        self.testbed.activate()
        self.testbed.init_datastore_v3_stub()

    # ...
```

テストを実行するために、テストランナーが必要です。[`gaeunit`](http://code.google.com/p/gaeunit/)、もしくは、[`nose-gae`](http://code.google.com/p/nose-gae/)のテストランナーを使うことが出来ます。簡単な例は以下のテストランナー。`unittest2`が必要なので、まずそれをインストールする必要があります。

```python
#!/usr/bin/python
import optparse
import sys
# Install the Python unittest2 package before you run this script.
import unittest2

USAGE = """%prog SDK_PATH TEST_PATH
Run unit tests for App Engine apps.

SDK_PATH    Path to the SDK installation
TEST_PATH   Path to package containing test modules"""

def main(sdk_path, test_path):
    sys.path.insert(0, sdk_path)
    import dev_appserver
    dev_appserver.fix_sys_path()
    suite = unittest2.loader.TestLoader().discover(test_path)
    unittest2.TextTestRunner(verbosity=2).run(suite)


if __name__ == '__main__':
    parser = optparse.OptionParser(USAGE)
    options, args = parser.parse_args()
    if len(args) != 2:
        print 'Error: Exactly 2 arguments required.'
        parser.print_help()
        sys.exit(1)
    SDK_PATH = args[0]
    TEST_PATH = args[1]
    main(SDK_PATH, TEST_PATH)
```

それで、スクリプトを実行すれば、プロジェクトの`test*.py`でテストケースを探して来て、テストを実行することができます。モジュール、もしくは、テストクラスを指定することもできます。

```shell
python testrunner.py demo.tests.DemoTestCase
```

## ファイルAPI

ファイルAPIでApp EngineのBlobstoreにファイル読み込み、書き込みができます。レポートの生成、データインポートなど、
ファイルシステムに必要なことに使えます。

```python
from __future__ import with_statement
from google.appengine.api import files

# ファイル作成
file_name = files.blobstore.create(mime_type='application/octet-stream')

# ファイルの中身を書き込む
with files.open(file_name, 'a') as f:
  f.write('data')

# ファイルデータを格納 (flush)
files.finalize(file_name)

# Blob キーを取得
blob_key = files.blobstore.get_blob_key(file_name)
```

## Cron と Task キューのヴァージョン指定

Cronジョブを実行するアプリケーションバージョンを指定することができるようになりました。`cron.yaml`の`target`プロパティでバージョン名を指定します。

```yaml
cron:
    - description: new daily summary job
      url: /tasks/summary
      schedule: every 24 hours
      target: version-2
```

キューの定義でも、あるキューのタスクがどのバージョンで実行されるかを`queue.yaml`の`target`プロパティで指定できます。

```yaml
queue:
    - name: my-queue
      rate: 20/s
      bucket_size: 40
      max_concurrent_requests: 10
      target: version-2
```

## まとめ

このリリースも結構大きくて、いろいろ改善されています。ファイルAPIを早速触ってみたいところです。

- [ダウンロード](http://code.google.com/intl/en/appengine/downloads.html)
- [リリースノート](http://code.google.com/p/googleappengine/wiki/SdkReleaseNotes)
