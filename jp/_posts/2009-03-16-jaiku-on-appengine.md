---
layout: post
title: "Jaikuを動かしてみた"
date: 2009-03-16 00:30:34 +0000
permalink: /jp/jaiku-on-appengine
blog: jp
tags: appengine
render_with_liquid: false
locale: ja
---

[![Jaiku](/assets/images/516/jaiku.png)](/assets/images/516/jaiku.png)

昨日、[Google](http://www.google.co.jp/)の[Twitter](http://www.twitter.com/)ライクなサービス、[Jaiku](http://www.jaiku.com/)が[オープンソース](http://code.google.com/p/jaikuengine/)になって、[Google Appengine](http://code.google.com/intl/ja/appengine/)に移動することに

早速、コードを落として、動かしてみた。

doc/README に入ってる手順(重要なのはlocal_settings.example.pyをlocal_settings.pyにコピー)にしたがってやってたんだけど、最初に動かそうとして、No module named djangoってエラーが出た。何だこれ！って思ったけど、ファイル数が多すぎて、deployする時にzipimport使ってる。さらに、Appengine SDK 1.1.9がapp.yamlにskip-filesに入ってるファイルにアクセスすることを拒否することになったので、ちゃんとzipにしないと動かない。Makefileにzip_allのコマンドはあるので、make zip_allで起動できるはずなのに、なぜか、同じくNo module named djangoがでた。

でも、どうせにzipimportで、エラーがでたら、tracebackもでないし、俺は結局、app.yamlいじりました。

```yaml
skip_files: |
    ^(.*/)?(
    (app\.yaml)|
    (app\.yml)|
    (index\.yaml)|
    (index\.yml)|
    (#.*#)|
    (.*~)|
    (.*\.py[co])|
    (.*/RCS/.*)|
    # (\..*) |
    # (manage.py)|
    # (google_appengine.*)|
    # (simplejson/.*)|
    # (gdata/.*)|
    # (atom/.*)|
    # (tlslite/.*)|
    # (oauth/.*)|
    # (beautifulsoup/.*)|
    # (django/.*)|
    # (docutils/.*)|
    # (epydoc/.*)|
    # (appengine_django/management/commands/.*)|
    # (README)|
    # (CHANGELOG)|
    # (Makefile)|
    # (bin/.*)|
    # (images/ads/.*)|
    # (images/ext/.*)|
    # (wsgiref/.*)|
    # (elementtree/.*)|
    # (doc/.*)|
    # (profiling/.*)
    )$
```

これでようやく動くはずなのに、またエラーが出たけど、今回はpstatsのエラーで、python-profileのパッケージを入れて、解決した。
