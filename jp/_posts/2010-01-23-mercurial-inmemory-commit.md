---
layout: post
title: "mercurialで、インメモリで、勝手チェンジセットをコミットする方法"
date: 2010-01-23 17:01:56 +0000
permalink: /jp/mercurial-inmemory-commit
blog: jp
tags: mercurial
render_with_liquid: false
---

<!-- textlint-disable rousseau -->

<p>mercurial はpythonで書かれて、わかりやすいAPIを用意しているので、触りたいと思って、インメモリでコミットをしようとするとどうすればいいかというのを調べてみた。</p>

<p>mercurialは、リポジトリオブジェクト(localrepository)があって、そのしたに、チェンジコンテキスト(changectx)がって、その下に、ファイルコンテキスト(filectx)があると言う仕組みになる。触るのが意外と簡単です。</p>

<p>普段のmercurialはディスクにあるファイルの処理をするんですけども、インメモリの処理をするために、memctxと、memfilectx のインメモリチェンジコンテキストとファイルコンテキストが用意してあります。</p>

<p>勝手コミットをするとこうなります。</p>

<script type="text/javascript" src="http://www.smipple.net/embed/KoInZvRSofE2qQIm"></script>

<p>それで、hg update たたくと、新しいファイルができました。</p>

<div class="highlight notranslate">
<pre>$ hg update
1 files updated, 0 files merged, 0 files removed, 0 files unresolved</pre>
</div>

<p>ファイルの更新は同じく新しいファイルの内容を渡せば、勝手にdiffしてくれます。</p>

<!-- textlint-enable rousseau -->
