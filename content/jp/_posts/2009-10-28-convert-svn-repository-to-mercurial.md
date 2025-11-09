---
layout: post
title: "svn リポジトリをmercurialに変換"
date: 2009-10-28 09:52:43 +0000
permalink: /jp/convert-svn-repository-to-mercurial
blog: jp
tags: tech programming
render_with_liquid: false
locale: ja
---

最近、SVNとGitのリポジトリをMercurialにして、Bitbucketに載せるのが多い。難しいか面倒だろうと思う人がいるかもしれないけど、現実は`hg convert`というコマンドを使うとすごく簡単です。`hg convert`は [Mercurial convert extension](http://mercurial.selenic.com/wiki/ConvertExtension)のコマンドです。`hg convert`は標準にインストールされているはずなので、以下を`.hgrc`に追加すると、簡単に使えます。

```text
[extensions]
hgext.convert=
```

`hg convert`でリポジトリを変換するのが簡単ですけど、HTTPで実行するのがすごく遅いので、SVNリポジトリを変換するなら、[`svnsync`](http://www.asahi-net.or.jp/~iu9m-tcym/svndoc/svn_svnsync.html)を使ってロカールに落とすほうが早い。

```text
$ svnadmin create foomirror
$ echo '#!/bin/sh' > foomirror/hooks/pre-revprop-change   # make insecure dummy hook
$ chmod +x foomirror/hooks/pre-revprop-change
$ svnsync init --username svnsync file://`pwd`/foomirror https://foo.svn.sourceforge.net/svnroot/foo
Copied properties for revision 0.
$ svnsync sync file://`pwd`/foomirror
Committed revision 1.
Copied properties for revision 1.
Committed revision 2.
Copied properties for revision 2.
...
```

ローカルのSVNリポジトリが出来上がったら、それに対して、`hg convert`を実行することができる。これはまさに早い。

```text
$ hg convert foomirror   # convert directly from repo mirror to foomirror-hg
...
```
