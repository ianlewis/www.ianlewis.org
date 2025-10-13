---
layout: post
title: "Jaikuを動かしてみた"
date: 2009-03-16 00:30:34 +0000
permalink: /jp/jaiku-on-appengine
blog: jp
tags: tech cloud
render_with_liquid: false
locale: ja
---

![Jaiku logo](/assets/images/516/jaiku.png)

昨日、GoogleのTwitterライクなサービス、[Jaiku](http://www.jaiku.com/)が[オープンソース](http://code.google.com/p/jaikuengine/)になって、[Google App Engine](https://cloud.google.com/appengine)に移動することに

早速、コードを落として、動かしてみた。

`doc/README`に入ってる手順(重要なのは`local_settings.example.py`を`local_settings.py`にコピー)にしたがってやってたんだけど、最初に動かそうとして、`No module named django`ってエラーが出た。何だこれ！って思ったけど、ファイル数が多すぎて、deployする時に`zipimport`使ってる。さらに、App Engine SDK 1.1.9が`app.yaml`に`skip-files`に入ってるファイルにアクセスすることを拒否することになったので、ちゃんとzipにしないと動かない。`Makefile`に`zip_all`のコマンドはあるので、`make zip_all`で起動できるはずなのに、なぜか、同じく`No module named django`がでた。

でも、どうせに`zipimport`で、エラーがでたら、トレースバックもでないし、俺は結局、`app.yaml`いじりました。

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
