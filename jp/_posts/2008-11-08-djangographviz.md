---
layout: post
title: "DjangoGraphviz"
date: 2008-11-08 11:40:03 +0000
permalink: /jp/djangographviz
blog: jp
---

<p>今日、<a href="http://www.djangoproject.com/" title="Django">Django</a>アプリケーションのモデルの構成を分かりやすく見たくて、モデル構成から<a href="http://ja.wikipedia.org/wiki/Graphviz">Graphviz</a> ドットファイルを生成できれば、いいなと思って、<a href="http://code.djangoproject.com/wiki/DjangoGraphviz">DjangoGraphviz</a>を見つけた。ただ、<a href="http://code.unicoders.org/django/trunk/utils/modelviz.py">ここ</a>からダウンロードして、こう実行する。</p>
<p>PYTHONPATH=$PYTHONPATH:. DJANGO_SETTINGS_MODULE=appmodule.settings python modelviz.py applabel &gt; app.dot<br />dot app.dot -Tpng app.png</p>
<p>最近作った <a href="http://www.bitbucket.org/IanLewis/django-lifestream/overview/">django-lifestream</a>のモデル構成イメージを作るとこれがでる。</p>
<p><a rel="lightbox" href="http://www.ianlewis.org/gallery2/d/11018-2/dlife.png"><img src="/gallery2/d/11019-2/dlife.png" alt="" width="80" height="150" /></a></p>
<p>よくできてるね。</p>
