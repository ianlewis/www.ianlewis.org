---
layout: post
title: "mercurialで、インメモリで、勝手チェンジセットをコミットする方法"
date: 2010-01-23 17:01:56 +0000
permalink: /jp/mercurial-inmemory-commit
blog: jp
tags: mercurial
render_with_liquid: false
locale: ja
---

MercurialはPythonで書かれて、わかりやすいAPIを用意しているので、触りたいと思って、インメモリでコミットをしようとするとどうすればいいかというのを調べてみた。

Mercurialは、リポジトリオブジェクト(`localrepository`)があって、そのしたに、チェンジコンテキスト(`changectx`)がって、その下に、ファイルコンテキスト(`filectx`)があると言う仕組みになる。触るのが意外と簡単です。

普段のMercurialはディスクにあるファイルの処理をするんですけども、インメモリの処理をするために、`memctx`と、`memfilectx` のインメモリチェンジコンテキストとファイルコンテキストが用意してあります。

勝手コミットをするとこうなります。

> **Update:** ここに書いてあったコードはアクセスできなくなりました。

それで、`hg update`たたくと、新しいファイルができました。

```bash
$ hg update
1 files updated, 0 files merged, 0 files removed, 0 files unresolved
```

ファイルの更新は同じく新しいファイルの内容を渡せば、勝手にdiffしてくれます。
