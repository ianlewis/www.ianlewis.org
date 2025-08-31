---
layout: post
title: "Werkzeugのreverse URL処理"
date: 2009-03-12 17:57:47 +0000
permalink: /jp/werkzeug-reverse-url
blog: jp
tags: python django werkzeug
render_with_liquid: false
locale: ja
---

[ほぼ汎用イベント管理ツール](http://twisted-mind.appspot.com/)の改善をしようと思ってて、実際にコードを見ると[URLを使ってる](http://bitbucket.org/voluntas/twisted-mind/src/tip/views.py#cl-132)のが気になった。

WerkzeugのURLルーティングで[Django](http://www.djangoproject.com/)のreverse関数みたいにURLの名前からURLに変換できるのかなと調べて、ある方法がありました。名前からじゃなくて、endpointから変換するけど。。。

```python
from werkzeug redirect as wredirect
from urls import url_map

def reverse(**kwargs):
  c = url_map.bind('')
  return wredirect(c.build(**kwargs))

  # ...
  
  return reverse('form', dict(key=key, slug=slug))
```
