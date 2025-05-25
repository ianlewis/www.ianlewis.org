---
layout: post
title: "Riak を Python で使う"
date: 2013-03-12 20:30:00 +0000
permalink: /jp/riak-python
blog: jp
tags: python riak
render_with_liquid: false
locale: ja
---

![Riak Logo](/assets/images/699/riak_big.png)

Riakは[Basho](http://basho.com/)が作っているキーべリューストレージ (KVS) システム。せっかく[Riak Meetup Tokyo](http://connpass.com/event/1823/)に参加しているっていうことをきっかけにして、RiakをPythonから使ってみよう。

## インストールなど

Riakをインストールするにはちょっと面倒くさいことがあるけど、動かしてみると使いやすい。Riakのインストールはここに説明しないけど、僕が以前に[Riak Source Code Reading](http://connpass.com/series/218/)で発表したRiakのインストールと動作の内容を見て頂ければと思います =\> [Let's りあっくぅ](https://docs.google.com/presentation/d/1TEUie_V7kr6Z7reeNNnQTUQUWcWzFfHXFZxtgofEx5Q/edit?usp=sharing)

## クライアントの準備

RiakをPythonから使う為のクライアントライブラリが用意されています。実際はオープンソースで、GitHubでソースコード見れます。PyPiにも上がっていて、`pip`で簡単にインストールできます:

```shell
pip install riak
```

その後は、簡単に `riak` モジュールをインポートできます。

## 接続

まずは、サーバーに接続しよう。上の資料でRiakの開発環境を立ち上げる時に デフォルトポートと違うポートになるので、その設定に合わせます。

```python
>>> client = riak.RiakClient(
...    host="127.0.0.1",
...    port=8091,
... )
```

Riakはデータを`Bucket`という名前空間でデータを分ける形になっている。アプリケーションでデータをBucket毎に分けたりすることができますが、大抵は同じBucketをよく使うと思います。それで`bucket`オブジェクトを作ります。

```python
>>> bucket = client.bucket('mybucket')
```

`bucket` が `client` オブジェクトを内蔵しているので、接続オブジェクトとして 使いまわすことが出来ます。

## データを保存

それで、一個一個のレコードはJSONオブジェクトみたいなフォーマットで保存するのですが、そのJSONデータをラッピングする`RiakObject`があります。キーを決めて、`RiakObject`を作成して、最終的に`store()`メソッドを呼び出すことで、保存します。

```python
>>> obj = bucket.new('key', data={
...     'spam': 'hoge',
...     'eggs': 'fuga',
... })
>>> obj.store()
```

## データを取得

データを取得するのが簡単で、キーで取得するだけ。`bucket`の`get()`メソッドでキーを渡して、データ保存する時の同じ
`RiakObject`が返ってきます。

JSONの`dict`データを取得する為に、`RiakObject`の`get_data()`メソッドを呼び出す。

```python
>>> obj = user_bucket.get('key')
>>> obj.get_data()
{'spam': 'hoge', 'eggs': 'fuga'}
```

## MapReduce

MapReduceはJavaScriptで書くことができます。RiakはFirefoxが使っているJavaScriptエンジンSpiderMonkeyを使っています。

まずは、`client` オブジェクトに`add()`メソッドを呼び出して、MapReduce のクエリーに「追加」する形になる。クエリーを作ったら、`map()` メソッドにMap関数のJavaScriptを渡して、`run()`メソッドで実行出来ます。

```python
>>> query = client.add('mybucket')
>>> query.map("function(v) { var data = JSON.parse(v.values[0].data); if(data.spam) { return [[v.key, data]]; } return []; }")
>>> for spam in query.run():
....    print("%s - %s" % (spam[0], spam[1]))
key - {'spam': 'hoge', 'eggs': 'fuga'}
```

## まとめ

RiakのPythonクライアントは実際Riak作っているBashoの中の人はメンテしているので、Secondary Index、Searchを含めて、基本的にすべての機能が使えて、安定しています。Pythonクライアントの公式ドキュメントは以下のURLでアクセスできるから、興味がある方、是非見て下さい（英語ですが。。)

[`http://basho.github.io/riak-python-client`](http://basho.github.io/riak-python-client)

分散サーバーにしては、Riakは結構簡単に動かせて、簡単にPythonからつなげて、割と、面白いなと思いますので、是非使ってみて下さい。
