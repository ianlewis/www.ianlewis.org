---
layout: post
title: "Javascript インタープリター"
date: 2008-07-08 22:58:52 +0000
permalink: /jp/javascript-interpreter-1
blog: jp
tags: tech programming javascript
render_with_liquid: false
locale: ja
---

[JSON schema proposal](http://www.json.org/json-schema-proposal/)の実装した典型的JavaScript validatorを試してみようと思って、[Python](http://www.python.org/)のインタラクティブシェルみたいなJavaScriptインタラクティブ　インタープリターを使いたいとさらに思って、以前に使ってた[Bob](http://bob.pythonmac.org/)さんの[Mochikit](http://mochikit.com)インタープリターをまた取り出した。

このインタープリターはMochikitのいじりにすごくよかったけど、一般的なJavaScriptをいろいろ試してみたいから、一般URLからインポートできるように、簡単な関数を作った。`importjs(url)`でどこからでも、JavaScriptをインポートして、インタラクティブシェルで直接触るようになった。コードは以下のよう

```javascript
function (jssource) {
  importdiv = DIV();
  importdiv.innerHTML = "Importing " + jssource + " <script type='text/javascript' src='" + jssource + "'></script>";
  writeln(importdiv);
}
```

僕の修正したバージョンは[こちら](/assets/demos/files/interpreter/index.html)

結局、JSON Schema Validatorを試してみたら、うまく動かなかった。

```javascript
test = "blah";
schema = { type: "integer" };
JSONSchema.validate(test, schema).valid;
```

という風に入力しても、`true`が出た。orz
