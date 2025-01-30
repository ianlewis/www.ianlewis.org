---
layout: post
title: "DjangoGraphviz"
date: 2008-11-08 11:40:03 +0000
permalink: /jp/djangographviz
blog: jp
tags: python django graphviz model
render_with_liquid: false
---

> **Update:** DjangoGraphVizはもう存在しませんが、[`django-extensions`](https://github.com/django-extensions/django-extensions)パッケージで[同様な機能](https://django-extensions.readthedocs.io/en/latest/graph_models.html)が入っています。

今日、[Django](http://www.djangoproject.com/)アプリケーションのモデルの構成を分かりやすく見たくて、モデル構成から[Graphviz](http://ja.wikipedia.org/wiki/Graphviz)ドットファイルを生成できれば、いいなと思って、[DjangoGraphviz](http://code.djangoproject.com/wiki/DjangoGraphviz)を見つけた。ただ、[ここ](http://code.unicoders.org/django/trunk/utils/modelviz.py)からダウンロードして、こう実行する。

```shell
PYTHONPATH=$PYTHONPATH:. DJANGO_SETTINGS_MODULE=appmodule.settings python modelviz.py applabel > app.dot
dot app.dot -Tpng app.png
```

最近作った[django-lifestream](http://www.bitbucket.org/IanLewis/django-lifestream/overview/)のモデル構成イメージを作るとこれがでる。

![](/assets/images/gallery/dlife.png){:style="width: 40%; display:block; margin-left:auto; margin-right:auto"}

よくできてるね。
