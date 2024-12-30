---
layout: post
title: "mercurial .hgrc include"
date: 2010-05-19 19:43:52 +0000
permalink: /jp/mercurial-hgrc-include
blog: jp
tags: python mercurial
render_with_liquid: false
---

<!-- textlint-disable rousseau -->

僕は [僕のシェル環境設定ファイル](http://bitbucket.org/IanLewis/my) をbitbucket で管理している。
新しいサーバーで作業する時にこのレポジトリからクローンして、ファイルを設定するけど、ローカル環境のみの設定が必要な場合が多い。今まで、bashrc等のスクリプトの中でローカル設定ファイルがあれば、sourceして、適用したんですけど、
mercurial の hgrc はそういうのができなかった。

と思ったら、 [mercurial 1.3
からできるらしい](http://stackoverflow.com/questions/1867237/load-multiple-hgrc-files-ie-some-with-machine-specific-settings)
です。下のコードを hgrc に入れると include ができる。超便利

```text
%include .hgrc.local
```

ファイルの場所は include したファイルの場所からの相対パス

でも、このファイルな存在しなければ、エラーが出るので、 `touch ~/.hgrc.local` を一回やらないとうるさい。

<!-- textlint-enable rousseau -->
