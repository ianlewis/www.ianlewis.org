---
layout: post
title: "HTMLサニタイズするライブラリbleachを試してみた"
date: 2014-06-23 13:00:00 +0000
permalink: /jp/htmlbleach
blog: jp
tags: python html
render_with_liquid: false
locale: ja
---

最近にHTMLををサニタイズしてくれる便利なライブラリ bleach を見つけた。HTMLを受け取ってウェブ上に表示したいんだけど、危険なやつをエスケープするもしくは消したいって場合に使うものだ。特にWYSIWYGエディターで入力されたHTMLとか

`html5lib`を使っているから、閉じタグが入ってないような汚いHTMLでもかなり強いらしいけど、どのくらい強いか試してみたかった。

僕は今まで自前で作ったBeautifulSoupベースのHTMLパーサーを使っていた。長い間使っているから、(自慢ではないけど)対応するエッジケースが多くて、結構使えたものでした。bleachは比べるとどんな感じなんだろうかと知りたかった。

例えば、 HTMLでは、以下のようなHTMLを見たことありませんか

```python
<input name=submit type=submit value=検索>
```

BeautifulSoup は Python 2.x だと`HTMLParser`ベースで、`HTMLParser`がこういうHTMLが入っているとこけちゃいますので、僕のパーサーに以下のようなモンキーパッチをしていました。

```python
import HTMLParser
try:
    _p = HTMLParser.HTMLParser()
    _p.feed(u"<input name=submit type=submit value=検索>")
    _p.close()
except HTMLParser.HTMLParseError:
    # Only patch HTMLParser if it's needed.
    HTMLParser.attrfind = re.compile(
        r'\s*([a-zA-Z_][-.:a-zA-Z_0-9]*)(\s*=\s*'
        r'(\'[^\']*\'|"[^"]*"|[^">\s]*))?')
```

## HTMLサニタイズ

まずは、簡単な例から始まります。

```python
>>> import bleach
>>> bleach.clean('<a href="http://example.com/"><span>hoge</div></a>')
u'<a href="http://example.com/">&lt;span&gt;hoge&lt;/div&gt;</a>'
```

デフォルトで span と div を許さないので、エスケープするけど、 `a`タグはそのままスルーしてくれたね。

```python
>>> bleach.clean(
...     text=u'<input name=submit type=submit value=検索>',
...     tags=["input"],
...     attributes={"input": ["name", "type", "value"]},
... )
u'<input type="submit" name="submit" value="\u691c\u7d22">'
```

次は上の例を見てみよう。これもいい感じでパースしてくれた。html5lib は結構優秀そう。

## CSSサニタイズ

ものによっては、styleタグでCSSスタイルを許したいけど、全部を許すのが危険。たとえば、background-image だとか、
positionだとかを許すと、表示するコンテンツの枠以外のところに影響する可能性がでてくる。ボタンをかくしたりとか、
画像を全画面に出しちゃったりするとか

```python
>>> bleach.clean(
...     text=u'<span style="position: absolute;top:0;left:0;font-size:12px;">',
...     tags=["span"],
...     attributes={"*": ["style"]},
...     styles=["font-size"]
... )
u'<span style="font-size: 12px;"></span>'
```

このように危険なスタイルも消せます。

## まとめ

bleachは結構使えそうで、これから使う場面がある時に自分で書いたもののリプレースとして、
使おうと思っている。

けど、bleachがすごい！ 使えそう！というところが感想というよりも、僕は大分前 (2008頃）
にこういう問題をk解決していたのに、ライブラリ化して、OSSとして出していなかったのが
すごくもったいないと感じていました。bleachのAPIと対応している機能は僕が書いた
ものとまったく同じでビックリしました。

自分が作ったものが全部のエッジケースに対応していなかたので、他の人に役に立たず、
意味がないと思っていた。完璧を目指しすぎて、結局会社の人しか使えなかったのが
残念だった感じです。
