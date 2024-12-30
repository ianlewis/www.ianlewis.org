---
layout: post
title: "svn リポジトリをmercurialに変換"
date: 2009-10-28 09:52:43 +0000
permalink: /jp/convert-svn-repository-to-mercurial
blog: jp
tags: mercurial hg svn
render_with_liquid: false
---

<!-- textlint-disable rousseau -->

最近、svn・gitのリポジトリをmercurialにして、bitbucketに載せるのが多い。難しいか面倒だろうと思う人がいるかもしれないけど、現実は
hg convert というコマンドを使うとすごく簡単です。hg convert は [mercurial convert
extension](http://mercurial.selenic.com/wiki/ConvertExtension)
のコマンドです。convert は標準にインストールされているはずなので、以下を .hgrc
に追加すると、簡単に使えます。

```text
[extensions]
hgext.convert=
```

convert でリポジトリを変換するのが簡単ですけど、http で実行するのがすごく遅いので、svn リポジトリを変換するなら、
[svnsync](http://www.asahi-net.or.jp/~iu9m-tcym/svndoc/svn_svnsync.html)
を使ってロカールに落とすほうが早い。

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

ローカルのsvn リポジトリが出来上がったら、それに対して、hg convert を実行することができる。これはまさに早い。

```text
$ hg convert foomirror   # convert directly from repo mirror to foomirror-hg
...
```

<!-- textlint-enable rousseau -->
