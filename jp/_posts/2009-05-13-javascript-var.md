---
layout: post
title: 'javascript "var"'
date: 2009-05-13 15:38:30 +0000
permalink: /jp/javascript-var
blog: jp
tags: javascript 変数
render_with_liquid: false
locale: ja
---

JavaScript で変数を定義する時に、`var`を付ける場合があります。`var`を付けないと、変数がグローバル名前空間に入ってしまう。

```javascript
>>> test = function() { test = "blah" };
>>> test();
>>> test();
TypeError: test is not a function source=with(_FirebugCommandLine){test();};
```

この場合だと、`test`が`test`を文字列に変えてしまう。

```javascript
>>> test = function() { blah = "blah" };
>>> test();
>>> blah
"blah"
```

...ということです。

知らなくて恥ずかしいんですけど、今まで書いたJavaScriptで一再付けなくて、あまりよくない。でも、逆に`var`を付けるのがあまりにも面倒くさいので、凹んでJavaScriptを書く気がちょっと減ってしまった。orz
