---
layout: post
title: "GAE Hackathon Disc. 3 全文検索"
date: 2009-04-11 20:46:13 +0000
permalink: /jp/gae-hackathon-disc-3-jp
blog: jp
tags: python google appengine 全文検索 text search
render_with_liquid: false
locale: ja
---

GAE Hackathon Disc. 3 に参加してきました！私と[id:a2c](http://d.hatena.ne.jp/a2c/) ([Twitter](http://twitter.com/atusi))が[Google App Engine](https://cloud.google.com/appengine) (GAE)の日本語が対応する全文検索エンジンを作ってみました。

GAEでは、データストアが`Entity`と言う概念で作られてるけど、`Entity`を検索する時に、データを完全一致しないと、データを取れないので、全文検索が難しくて、以下の状況になってる。

- 一応、[`SearchableModel`](http://code.google.com/p/googleappengine/source/browse/trunk/python/google/appengine/ext/search/__init__.py#287)というクラスを継承すれば、英文検索が出来るけど、日本語テキスト検索が全くできない。（英語でも結構ひどい)
- `SearchModel`で、英語検索しても、スペース文字で単語単位で切るので、単語を完全一致しないといけない。（つまり、informationがテキストに入ってるけど、infoで検索しても出てこない）
- `SearchableModel`では、3文字以下の単語はインデクスしてくれないので、ほとんどの日本語はアウト
- 上の点の関係で、3文字以下の検索キーワードもアウト
- 検索キーワードが無視された場合、何でも、引っかかるので、検索結果が分かりにくい

a2cさんが以前に、いろいろ調べたり、試してみたりしてくれたので、いろいろ助かった。いい情報を取れたので、すごくいい話が当日にできました。

<!-- textlint-disable spelling -->

- [GAEのAPI1.2で追加になったCronを使って転置インデックスの更新をしてみる](http://d.hatena.ne.jp/a2c/20090409/1239209449)
- [GAE ハカソン事前MTG](http://d.hatena.ne.jp/a2c/20090407/1239086203)
- [GoogleAppEngineのReq/Sec計って見た](http://d.hatena.ne.jp/a2c/20090402/1238608082)
- [gae上でDataStore使わずにmemcacheで転置インデックス作ってみた。](http://d.hatena.ne.jp/a2c/20090401/1238579242)
- [GoogleAppEngineのサーバサイドの処理時間をProfileで表示させる為にcProfile使う](http://d.hatena.ne.jp/a2c/20090331/1238464001)
- [GAEのDatastoreが順調に肥大中](http://d.hatena.ne.jp/a2c/20090326/1238000082)

<!-- textlint-enable spelling -->

`SearchableModel`のAPIは基本的にいいと思ったので、`SearchableModel`と同じように、日本語対応できる`SearchableModel`を使いたいなと思いました。こう書けば、わりと簡単に検索できる。

```python
from google.appengine.ext.search import SearchableModel
from google.appengine.ext.db import *

class Document(SearchableModel):
  title = StringProperty(u"Title")
  text = TextProperty(u"Body Text")

# ...
Document.all().search(keyword)
# ...
```

まず、`SearchableModel`がいろいろ、自分を参照したので、継承するのが難しかったから、別のモジュールにコピーして、forkすることにした。それで、[この辺](http://bitbucket.org/a2c/gaehackathon_misopotato/src/e26dda1c611c/saichugen/ian/search/__init__.py#cl-195)に単語の分け方を a2cが作ってくれた [N-gram実装](http://bitbucket.org/a2c/gaehackathon_misopotato/src/e26dda1c611c/saichugen/a2c/n_gram.py#cl-1)に切り替えた。([N-gramとは？](http://d.hatena.ne.jp/keyword/N-gram))　それで、`SearchableModel`のモジュールを変えるだけで、Googleの実装と同じように使える。

検索キーワードをN-gramで分けて、インデクスを検索すると、ちゃんと部分的にデータが引っ張ってくる。 [`http://saichugen.appspot.com/`](http://saichugen.appspot.com/) でテストアプリを見れる。コードは[Bitbucket](http://bitbucket.org/a2c/gaehackathon_misopotato/)で公開されてる。

これから、a2cさんともっと検索結果を取れるようにするのと、インデクスの容量をへらしたりするのと、分け方を自分で実装できるAPIを導入したいと思うので、ぜひ期待してください
