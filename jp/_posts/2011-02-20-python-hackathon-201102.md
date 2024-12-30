---
layout: post
title: "Python Hackathon 2011.02"
date: 2011-02-20 21:24:03 +0000
permalink: /jp/python-hackathon-201102
blog: jp
tags: python twisted
render_with_liquid: false
---

<!-- textlint-disable rousseau -->

Python Hackathon 2011.02 に参加しに行ってきました。今回は、ちょっと遅く着いたが、楽しかった。

やったことはほとんどプレゼンの準備でした。発表したのは、[Twisted](http://twistedmatrix.com/)で作られたロングポーリングチャットサーバの作り方についてでした。

<iframe src="//www.slideshare.net/slideshow/embed_code/key/xrp8u56T9XPIn0" width="595" height="485" frameborder="0" marginwidth="0" marginheight="0" scrolling="no" style="border:1px solid #CCC; border-width:1px; margin-bottom:5px; max-width: 100%;" allowfullscreen> </iframe> <div style="margin-bottom:5px"> <strong> <a href="//www.slideshare.net/IanMLewis/twisted" title="Twisted ロングポーリング チャット サーバ" target="_blank">Twisted ロングポーリング チャット サーバ</a> </strong> from <strong><a href="https://www.slideshare.net/IanMLewis" target="_blank">Ian Lewis</a></strong> </div>

チャットサーバ自体のコードはこんな感じ

```python
#:coding=utf-8:

import sys

import json
from functools import partial
from time import sleep
from twisted.web import server, resource
from twisted.internet import reactor, defer
from twisted.application import internet, service

println = sys.stdout.write

def chat_msg(request, chat_msg):
    callback = request.args.get("callback")[0];
    request.setHeader('Content-Type', 'application/javascript')
    request.write("%s(%s)" % (callback, json.dumps(chat_msg)))
    request.finish()

class ChatServer(resource.Resource):
    isLeaf = True

    deferred_list = []

    def render_POST(self, request):
        #pprint(request.__dict__)
        newdata = request.content.getvalue()
        data = json.loads(newdata)
        for i in range(len(self.deferred_list)):
            d = self.deferred_list.pop()
            d.callback(data)
        return 'OK'

    def render_GET(self, request):

        chat_d = defer.Deferred()
        chat_d.addCallback(partial(chat_msg, request))
        chat_d.addErrback(println, "chat error")

        self.deferred_list.append(chat_d)

        return server.NOT_DONE_YET

site = server.Site(ChatServer())
application = service.Application("simplechat")
server_obj = internet.TCPServer(8080, site)
server_obj.setServiceParent(application)
```

<!-- textlint-enable rousseau -->
