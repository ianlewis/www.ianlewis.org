---
layout: post
title: "Riak を Python で使う"
date: 2013-03-12 20:30:00 +0000
permalink: /jp/riak-python
blog: jp
tags: python riak
render_with_liquid: false
---

![image](/assets/images/699/riak_big.png)

Riak は [Basho](http://basho.com/) が作っているキーべリューストレージ (KVS) システム。 せっかく
[Riak Meetup Tokyo](http://connpass.com/event/1823/) に参加しているっていうことを
きっかけにして、Riak を Python から使ってみよう。

# インストールなど

Riak をインストールするにはちょっと面倒くさいことがあるけど、動かしてみると使いやすい。 Riak
のインストールはここに説明しないけど、僕が以前に [Riak
Source Code Reading](http://connpass.com/series/218/) で 発表した Riak
のインストールと動作の内容を見て頂ければと思います =\> [Let's
りあっくぅ](https://docs.google.com/presentation/d/1TEUie_V7kr6Z7reeNNnQTUQUWcWzFfHXFZxtgofEx5Q/edit?usp=sharing)

# クライアントの準備

Riak をPythonから使う為のクライアントライブラリが用意されています。 実際はオープンソースで、Github でソースコード見れます。
PyPi にも上がっていて、 pip で簡単にインストールできます:

```shell
pip install riak
```

その後は、簡単に `riak` モジュールをインポートできます。

# 接続

まずは、サーバーに接続しよう。上の資料で riak の開発環境を立ち上げる時に デフォルトポートと違うポートになるので、その設定に合わせます。

```python
>>> client = riak.RiakClient(
...    host="127.0.0.1",
...    port=8091,
... )
```

Riak はデータを `Bucket` という名前空間でデータを分ける形になっている。アプリケーションで データを bucket
毎に分けたりすることができますが、大抵は同じ bucket をよく使うと思います。 それで bucket
オブジェクトを作ります。

```python
>>> bucket = client.bucket('mybucket')
```

`bucket` が `client` オブジェクトを内蔵しているので、接続オブジェクトとして 使いまわすことが出来ます。

# データを保存

それで、一個一個のレコードは JSON オブジェクトみたいなフォーマットで保存するのですが、 その JSON データをラッピングする
`RiakObject` があります。 キーを決めて、 `RiakObject` を 作成して、最終的に `store()`
メソッドを呼び出すことで、保存します。

```python
>>> obj = bucket.new('key', data={
...     'spam': 'hoge',
...     'eggs': 'fuga',
... })
>>> obj.store()
```

# データを取得

データを取得するのが簡単で、キーで取得するだけ。 `bucket` の `get()` メソッドで キーを渡して、データ保存する時の同じ
`RiakObject` が返ってきます。

JSON の `dict` データを取得する為に、 `RiakObject` の `get_data()` メソッドを 呼び出す。

```python
>>> obj = user_bucket.get('key')
>>> obj.get_data()
{'spam': 'hoge', 'eggs': 'fuga'}
```

# MapReduce

MapReduce は JavaScript で書くことができます。 Riak は Firefox が使っている JavaScript エンジン
SpiderMonkey を使っています。

まずは、 `client` オブジェクトに `add()` メソッドを呼び出して、 MapReduce のクエリーに
「追加」する形になる。クエリーを作ったら、 `map()` メソッドに Map 関数の
JavaScript を渡して、 `run()` メソッドで実行出来ます。

```python
>>> query = client.add('mybucket')
>>> query.map("function(v) { var data = JSON.parse(v.values[0].data); if(data.spam) { return [[v.key, data]]; } return []; }")
>>> for spam in query.run():
....    print("%s - %s" % (spam[0], spam[1]))
key - {'spam': 'hoge', 'eggs': 'fuga'}
```

# まとめ

Riak の Python クライアントは実際 Riak 作っている Basho の中の人はメンテしているので、 Secondary
Index、Search を含めて、基本的にすべての機能が使えて、安定しています。 Python
クライアントの公式ドキュメントは以下のURLでアクセスできるから、興味がある方、
是非見て下さい （英語ですが。。)

<http://basho.github.io/riak-python-client/>

分散サーバーにしては、Riak は結構簡単に動かせて、簡単にPython からつなげて、 割と、面白いなと思いますので、是非使ってみて下さい。
