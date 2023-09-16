---
layout: post
title: "Mercurial MQ"
date: 2009-08-15 13:32:03 +0000
permalink: /jp/mercurial-mq-extension
blog: jp
render_with_liquid: false
---

最近 mercurial の mq
エクステンションを試しに使ってる。mercurialのリビジョンをコミットする前に、変更を管理したい、もしくは、途中で他の作業をやらないといけないので、今の変更をどっかに置かないといけない場合に便利なエクステンションです。

mq は標準に入っているので、インストールしなくてもいいだが、エクステンションを.hgrcで有効しないと。

```text
[extensions]
mq =
```

それで、コマンドを巡回する。パッチキューを初期化する。

```text
hg qinit
```

新しいパッチを作る。これは変更がない状態で実行しないといけないので、ちょっと面倒くさい。

```text
hg qnew
```

もし、qnewを忘れた場合、変更を置かないと。これは面倒くさい。もし、もっといい方法があれば、教えてください。たまに、windows のeol
と unix の eol が両方 my.diff に入ってしまって、patch がちゃんと適用することが出来ない場合がある。ご注意

```text
hg diff -U > my.diff
hg revert --all
hg qnew mypatch
patch -p1 < my.diff
```

**Update:** -f で現在の変更を含めて新しいパッチを作れる。上の処理を下のコマンドで同じことができる。

```text
hg qnew -f mypatch
```

ここで、変更を行って、patch を更新するコマンドはqrefresh. これを実行するのと、hg
statusを実行すると何もでない。パッチの内容も hg view
で見れる。

```text
hg qrefresh
```

コミットするときの、コミットメッセージは分かりにくいだが、 qrefresh で指定する。

```text
hg qrefresh -e
```

一回指定すれば、コミットするときに、書いたメッセージを使う。

パッチを置かないといけない場合は、qpop を使う。

```text
hg qpop mypatch
```

もしくは、

```text
hg qpop -a
```

パッチをまた適用する qpush

```text
hg qpush mypatch
```

もしくは、

```text
hg qpush -a
```

パッチをリポジトリにコミットする場合は、qfinish

```text
hg qfinish mypatch
```

もしくは、全てをコミット

```text
hg qfinish qbase:qtip
```
