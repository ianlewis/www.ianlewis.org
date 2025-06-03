---
layout: post
title: "feedparserで、media コンテンツを取る"
date: 2008-11-24 21:12:30 +0000
permalink: /jp/feedparser_and_media
blog: jp
tags: media python rss
render_with_liquid: false
locale: ja
---

[`feedparser`](http://www.feedparser.org/)で、どうやってビデオを取れるかをずっと悩みましたけど、今日少しだけ、進展した。問題の核心はYouTubeや、Vimeoは[Yahoo! RSS モジュール](http://search.yahoo.com/mrss/)を使って、RSS拡張ネームスペースにデータを入れている。この拡張データの処理は`feedparser`が中途半端でやってる。見てみよう。

YouTubeのGDATA APIで取ったデータはこうなる

```xml
<entry>
  <id>http://gdata.youtube.com/feeds/api/videos/R3orQKBxiEg</id>
  <published>2008-07-17T23:58:51.000Z</published>
  <updated>2008-11-24T02:32:25.000Z</updated>
  ...
  <title type="text">Official Watchmen Trailer</title>
  <content type="text">Title speaks for itself

so people don't have to keep answerin
the name of the song is:

smashing pumpkins- the beginning is the end is the beginning</content>
    ...
  <author>
    <name>Garrettheparrot</name>
    <uri>http://gdata.youtube.com/feeds/api/users/garrettheparrot</uri>
  </author>
  <media:group>
    <media:title type="plain">Official Watchmen Trailer</media:title>
    <media:description type="plain">Title speaks for itself

so people don't have to keep answerin
the name of the song is:

smashing pumpkins- the beginning is the end is the beginning</media:description>
    <media:keywords>2009, Comic, Men, Movie, Watch, Watches, Who</media:keywords>
    <yt:duration seconds="140"/>
    <media:category label="Film &amp; Animation" scheme="http://gdata.youtube.com/schemas/2007/categories.cat">Film</media:category>
    <media:content url="http://www.youtube.com/v/R3orQKBxiEg&amp;f=gdata_user_favorites" type="application/x-shockwave-flash" medium="video" isDefault="true" expression="full" duration="140" yt:format="5"/>
    <media:content url="rtsp://rtsp2.youtube.com/CjALENy73wIaJwlIiHGgQCt6RxMYDSANFEgGUhRnZGF0YV91c2VyX2Zhdm9yaXRlcww=/0/0/0/video.3gp" type="video/3gpp" medium="video" expression="full" duration="140" yt:format="1"/>
    <media:content url="rtsp://rtsp2.youtube.com/CjALENy73wIaJwlIiHGgQCt6RxMYESARFEgGUhRnZGF0YV91c2VyX2Zhdm9yaXRlcww=/0/0/0/video.3gp" type="video/3gpp" medium="video" expression="full" duration="140" yt:format="6"/>
    <media:thumbnail url="http://i.ytimg.com/vi/R3orQKBxiEg/2.jpg" height="97" width="130" time="00:01:10"/>
    <media:thumbnail url="http://i.ytimg.com/vi/R3orQKBxiEg/1.jpg" height="97" width="130" time="00:00:35"/>
    <media:thumbnail url="http://i.ytimg.com/vi/R3orQKBxiEg/3.jpg" height="97" width="130" time="00:01:45"/>
    <media:thumbnail url="http://i.ytimg.com/vi/R3orQKBxiEg/0.jpg" height="240" width="320" time="00:01:10"/>
    <media:player url="http://www.youtube.com/watch?v=R3orQKBxiEg"/>
  </media:group>
  ...
</entry>
```

`media`という名前空間の下に結構データが入ってる。なのに、`feedparser`はちょっとしか取らない。

```python
>>> d = feedparser.parse("http://gdata.youtube.com/feeds/api/users/IanLewisInJapan/favorites")
>>> e = d['entries'][0]
>>> filter(lambda x: x.startswith('media_'), e.keys())
['media_category', 'media_player', 'media_group', 'media_keywords', 'media_description', 'media_content', 'media_thumbnail']
>>> e['media_content']
u''
>>> e['media_thumbnail']
u''
>>> e['media_player']
u''
>>> e['media_description']
u'Last.fm/presents Yellow Magic Orchestra Interview at Royal Festival Hall in London.\nCheck out http://www.last.fm/Presents to find out about all of our other interviews or upcoming/past events.'
>>>
```

ビデオのURLはどこかにない。原因は`feedparser`の拡張ネームスペース処理に入ってるけども、一言いうと、`<media:content>`というタグの属性は取れてない。こう見たら、どうやって、とれるかを調べたら、`unknown_starttag()`というメソッドの中にこのコードを見つけた。

## feedparser.py

```python
# call special handler (if defined) or default handler
methodname = '_start_' + prefix + suffix
try:
  method = getattr(self, methodname)
  return method(attrsD)
except AttributeError:
  return self.push(prefix + suffix, 1)
```

じゃ、[XML](http://en.wikipedia.org/wiki/XML)を解析するときに、タグを見つけたら、`unknown_starttag()`という関数が実行されて、タグの名前に一致するメソッドがあれば、実行する処理やってる。それで、`start_media_content()`というメソッドがあれば実行してくれるわけだね。でも、どうやって、パーサークラスに付けるのか。`feedparser`は`_StrictFeedParser`というクラスを名前で使ってるから、自分が作ったクラスを`_ScrictFeedParser`と交換。

```python
feedparser._StrictFeedParser_old = feedparser._StrictFeedParser
class DlifeFeedParser(feedparser._StrictFeedParser_old):

  def _start_media_content(self, attrsD):
    self.entries[-1]['media_content_attrs'] = copy.deepcopy(attrsD)
feedparser._StrictFeedParser = DlifeFeedParser
```

それで、また`parse()`を実行すると、

```python
>>> import feedparser
>>> import copy
>>> feedparser._StrictFeedParser_old = feedparser._StrictFeedParser
>>> class DlifeFeedParser(feedparser._StrictFeedParser_old):
...
...   def _start_media_content(self, attrsD):
...         self.entries[-1]['media_content_attrs'] = copy.deepcopy(attrsD)
...     return self.push('media_content', 1)
...
>>> feedparser._StrictFeedParser = DlifeFeedParser
>>> d = feedparser.parse("http://gdata.youtube.com/feeds/api/users/IanLewisInJapan/favorites")
>>> filter(lambda x: x.startswith("media_"), d['entries'][0].keys())
['media_category', 'media_player', 'media_group', 'media_content_attrs', 'media_keywords', 'media_description', 'media_content', 'media_thumbnail']
>>> d['entries'][0]['media_content_attrs']
['medium', 'format', 'url', 'expression', 'duration', 'type', 'yt:format']
```

それで、`media:content`の属性を取れた。`media:group`の下に`content`が複数ある場合もあるから、もうちょっとまとめないといけないけど、やり方が少し分かってきた。
