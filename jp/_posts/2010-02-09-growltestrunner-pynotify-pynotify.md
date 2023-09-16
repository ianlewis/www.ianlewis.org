---
layout: post
title: "growltestrunner の pynotify 対応 / pynotify の使い方"
date: 2010-02-09 16:33:48 +0000
permalink: /jp/growltestrunner-pynotify-pynotify
blog: jp
render_with_liquid: false
---

最近、会社の [AE35](http://twitter.com/ae35) さんが
[growltestrunner](bitbucket.org/ae35/growltestrunner/) を作っていて、
[modipyd](http://www.metareal.org/p/modipyd/ja/)
を使って、ファイルを更新したタイミングで自動テストを自動的に実行してくれて、growlで通知するように素敵な環境を設定した。

俺はlinuxなので、当然 growl がないけど、Mac OS の growl みないな libnotify があって、pynotify
と言うpythonバインディングがあるから、pynotifyでも使えるように、
[fork](http://www.bitbucket.org/IanLewis/growltestrunner/) を作った。

ちなみに、pynotify はこういう使い方

```python
import pynotify
pynotify.init("My App")
n = pynotify.Notification("Title", "Message", "/path/to/my/icon.png")
n.show()
```
