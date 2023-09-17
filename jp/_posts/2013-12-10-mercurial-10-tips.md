---
layout: post
title: "Mercurialログ情報出力の５個のtips"
date: 2013-12-10 13:30:00 +0000
permalink: /jp/mercurial-10-tips
blog: jp
tags: mercurial source-control
render_with_liquid: false
---

<img src="/assets/images/mercurial/mercurial_medium.png" class="align-center" />

_この記事は [Mercurial Advent Calendar 2013](http://connpass.com/event/3950/) の第３目の記事 (なのに 10日に公開しています orz)。前の記事は @cointoss1973 さんの「 [TortoiseHg のワークベンチから快適なターミナルを起動する(Windows)](http://cointoss.hatenablog.com/entry/2013/12/02/182618)」。次の記事は @toruot さんの「 [Mercurialのextdiffツールを自作する ](http://toruot.hatenablog.jp/entry/2013/12/04/231914) 」という記事です。_

Mercurial はログ情報を出力する時に、テンプレートを指定することで、出力の形式を変更することができます。

これは簡単な例:

```
$ hg log -r 0:1 --template="{node}: {desc}"
a8e31726b566b71279f5ef08563d0cccb982dcb8: Initial
bf5b22ba1b0243dcab398620b5c1c5ea5b7fef36: fuga
```

ここでは、 `node` はチェンジセットのハッシュで、 `desc` はコミットメッセージになる。使えるキーワードは結構あるので、`hg help templates` を実行すると詳しい説明を受けます。

## author の解析

テンプレートはいいところは unix のパイプコマンドでいろなことができるところです。例えば、コミットの `author` の解析:

```
$ hg log --template="{author}" | sort | uniq -c | sort -r
61 Ian Lewis <xxxxxxxxx@gmail.com>
56 hoge <hoge@example.com>
49 fuga <fuga@example.com>
```

## 時系列の解析

dateフォーマットを使うと時系列のデータ解析ができる。ここで１ヶ月毎のコミット数のグラフを表示する:

```
$ hg log --template="{date(date, '%Y%m')}\n" | sort | uniq -c | gnuplot -e "set xdata time;set timefmt \"%Y%m\";set xtics rotate by -45;plot '<cat' using 2:1 title \"commits\" with lines" -persist
```

## 外部ファイル

もう一つのtipは複雑なテンプレートを外部ファイルに保存すること:

```
$ echo "==========\n{node}:\n{author}:\n{desc}\n===========\n\n" > my.tmpl
$ hg log -r 0:1 --template="`cat my.tmpl`"
==========
bf5b22ba1b0243dcab398620b5c1c5ea5b7fef36:
Ian Lewis <xxxxxxxxx@gmail.com>:
fuga
===========

==========
a8e31726b566b71279f5ef08563d0cccb982dcb8:
Ian Lewis <xxxxxxxxx@gmail.com>:
Initial
===========
```

## XMLを吐き出す

外部フォーマットにすれば、複雑なフォーマットでも出力することができます。
例えば、みんなが大好きなXML

以下のテンプレートを `my_template.xml` に保存しようとしますと、

```
<changeset id="{node|escape}">
  <author>{author|escape}</author>
  <date>{date|isodate|escape}</date>
  <description>{desc|escape}</description>
  <parents>
    <parent1>{p1node|escape}</parent1>
    <parent2>{p2node|escape}</parent2>
  </parents>
  <files>\n{files % "      <file>{file|escape}</file>\n"}    </files>
</changeset>\n
```

こんな感じになります:

```
$ (echo '<?xml version="1.0" encoding="UTF-8" ?>\n<log>' && hg log --template="`cat my_template.xml`" && echo "</log>")
<?xml version="1.0" encoding="UTF-8" ?>
<log>
  <changeset id="f77123c287ab035e1d19768ddac34ec502489730">
    <author>Ian Lewis &lt;xxxxxxxxx@gmail.com&gt;</author>
    <date>2013-12-09 22:06 +0900</date>
    <description>merge</description>
    <parents>
      <parent1>bf1b9eea4d74ec2d221e0ed30bbcbd3afe34552c</parent1>
      <parent2>bf5b22ba1b0243dcab398620b5c1c5ea5b7fef36</parent2>
    </parents>
    <files>
      <file>test.txt</file>
    </files>
  </changeset>
  <changeset id="bf1b9eea4d74ec2d221e0ed30bbcbd3afe34552c">
    <author>Ian Lewis &lt;xxxxxxxxx@gmail.com&gt;</author>
    <date>2013-12-09 22:06 +0900</date>
    <description>aaaa</description>
    <parents>
      <parent1>a8e31726b566b71279f5ef08563d0cccb982dcb8</parent1>
      <parent2>0000000000000000000000000000000000000000</parent2>
    </parents>
    <files>
      <file>test.txt</file>
    </files>
  </changeset>
  ...
</log>
```

※ `--style` オプションでも同じような事ができます。実は Redmine のリポジトリビューアは `--style` オプションを使って [MercurialにXMLを出力させています](http://www.redmine.org/projects/redmine/repository/entry/trunk/lib/redmine/scm/adapters/mercurial_adapter.rb) 。

## ２つのチェンジセットの差分のファイル一覧

`--template` オプションで `{files}` が使えるのがわかりますよね？

ちょっとやってみようと:

```
$ hg log -r 0:3 --template="{join(files, "\n")}\n"
test.txt
test.txt
no-changes.txt
test.txt
test.txt
```

あれ？ 同じファイルが出てましたね。これは、チェンジセット毎のファイルリストをひたすら一覧化しているだけですね。ここではさっき使っていた `sort -u` コマンドで唯一なファイル名を表示することができる:

```
$ hg log -r 0:3 --template="{join(files, "\n")}\n" | sort -u
no-changes.txt
test.txt
```

それはましなんだけど、例えば、 `no-changes.txt` はチェンジセット０とチェンジセット３の間に変更があったけど、取り消された場合は `0:3` にすれば、本当は差分がないはずですよね？ 本当は `hg diff` をやった時のファイルリストが欲しい。

そうしたら、 `hg diff --stat` を使えばいい。ちょっと余計な出力もあるので、 `awk` と `head` で削る:

```
$ hg diff -r 0:3 --stat | awk '{ print $1; }' | head -n -1
test.txt
```
