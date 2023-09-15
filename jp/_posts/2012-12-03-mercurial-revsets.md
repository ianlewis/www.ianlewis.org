---
layout: post
title: "Mercurial revsets の紹介"
date: 2012-12-03 13:00:00 +0000
permalink: /jp/mercurial-revsets
blog: jp
render_with_liquid: false
---

![image](https://storage.googleapis.com/static.ianlewis.org/prod/img/mercurial/mercurial_medium.png)

<div class="note">

<div class="title">

Note

</div>

この記事は [Mercurial Advent Calendar 2012](http://connpass.com/event/1431/)
の第３目の記事。昨日の記事は id:@terapyon の「Bitbucket関連」。明日は @cointoss1973
さんが、「パッチ管理リポジトリ入門～MQ(パッチ)もMercurialで管理できるよ～」という記事を書いてくれる予定です。

</div>

# revsets って何？

あまり表に出てこない機能なんでしょうが、 revsetsは mercurial の超便利機能の一つです。一言にいうと mercurial
revsets はチェンジセットをクエリー・セレクトする為のDSL (ドメイン固有言語)です。 log
情報を探したり、diffデータを生成したりするのにすごく便利です。後例えば、自分たちのリリース仕組みによって、どういうチェンジセットは未リリースなのか、どのチェンジセットは
default
にマージされてないのかを探すのにすごく便利です。もう一つの例は、自分で作るCIシステムや、デプロイや、コミットフックなどに、マージされてないものを
push しないようにするとかも revsets で簡単にできます。

まずは revsets はどういうようなものなのか？ 見てみないとわからないでしょうから、簡単な例から、説明を進みたいと思います。

# チェンジセットの差

revsets はリビジョンのセットをセレクトするものなので、 `hg` コマンドでリビジョンを指定する場所全部使えます。

例えば、あるリビジョンとあるリビジョンの間に何があるか知りたい場合は、コロンの文脈を使うといいです。ただ、子孫ではなくても、いいですので、以下のように

    hg diff -r "x:y"

ある２つのリビジョンの差を取るには便利ですが、以下の様にチェンジセットをリストしても何を見ているか分からない場合が多いでしょう。

    $ hg log -r "x:y"

リビジョン 0〜3 があるとしましょう。

    $ hg init
    $ echo "0" > test.txt
    $ hg add test.txt
    $ hg commit -m "0"
    $ echo "1" > test.txt
    $ hg commit -m "1"
    $ echo "1" > test.txt
    $ hg update 0
    $ echo "2" > test.txt
    $ hg commit -m "2"
    $ echo "3" > test.txt
    $ hg commit -m "3"

上のようなコマンドで作りますと以下の様なグラフ構造になります。

![image](https://storage.googleapis.com/static.ianlewis.org/prod/img/687/tree1_medium.png)

実は `1:3` は以下のようなリビジョンのセットになります。0 が共通なので、含まれてないです。

    $ hg log -r "1:3"
    チェンジセット:   1:dd139b83c818
    ユーザ:           Ian Lewis
    日付:             Sun Dec 02 17:50:23 2012 +0900
    要約:             1
    
    チェンジセット:   2:67e971609b0e
    親:               0:76a5fc13ce06
    ユーザ:           Ian Lewis
    日付:             Sun Dec 02 17:50:35 2012 +0900
    要約:             2
    
    チェンジセット:   3:2d695c0c05f1
    タグ:             tip
    ユーザ:           Ian Lewis
    日付:             Sun Dec 02 17:50:44 2012 +0900
    要約:             3

# 祖先・子孫チェンジセット

親子関係は重要の場合、 *DAG (Directed Acyclic Graph)* クエリーを使います。このクエリーは `x` と `y`
を含めて `x` の子孫かつ、 `y` の祖先のチェンジセットになります。このクエリは２つのコロンを使います。

    $ hg log -r "x::y"

上の例では、1 と 3 は親類ではないので、DAGクエリーは空のセットを返します。

    $ hg log -r "1::3"
    $

ただし、 3 と 0 のレンジを取るとちょんと出てきます。

    $ hg log -r "0::3"
    チェンジセット:   0:76a5fc13ce06
    ユーザ:           Ian Lewis
    日付:             Sun Dec 02 17:50:13 2012 +0900
    要約:             0
    
    チェンジセット:   2:67e971609b0e
    親:               0:76a5fc13ce06
    ユーザ:           Ian Lewis
    日付:             Sun Dec 02 17:50:35 2012 +0900
    要約:             2
    
    チェンジセット:   3:2d695c0c05f1
    タグ:             tip
    ユーザ:           Ian Lewis
    日付:             Sun Dec 02 17:50:44 2012 +0900
    要約:             3

# セットの和集合・共通集合

セットの和集合は計算のように `+` で書きます。例えば、上の例の 1 が含まれているクエリだとこう書きます。

    $ hg log -r "0::3 + 1"
    チェンジセット:   0:76a5fc13ce06
    ユーザ:           Ian Lewis
    日付:             Sun Dec 02 17:50:13 2012 +0900
    要約:             0
    
    チェンジセット:   1:dd139b83c818
    ユーザ:           Ian Lewis
    日付:             Sun Dec 02 17:50:23 2012 +0900
    要約:             1
    
    チェンジセット:   2:67e971609b0e
    親:               0:76a5fc13ce06
    ユーザ:           Ian Lewis
    日付:             Sun Dec 02 17:50:35 2012 +0900
    要約:             2
    
    チェンジセット:   3:2d695c0c05f1
    タグ:             tip
    ユーザ:           Ian Lewis
    日付:             Sun Dec 02 17:50:44 2012 +0900
    要約:             3

さらに、セットの共通集合も取れます。例えば、2を含まれない DAG セットが欲しい場合は、このように書きます。

    $ hg log -r "0::3 - 2"
    チェンジセット:   0:76a5fc13ce06
    ユーザ:           Ian Lewis
    日付:             Sun Dec 02 17:50:13 2012 +0900
    要約:             0
    
    チェンジセット:   3:2d695c0c05f1
    タグ:             tip
    ユーザ:           Ian Lewis
    日付:             Sun Dec 02 17:50:44 2012 +0900
    要約:             3

# parents()

例えば、 tip リビジョンの親リビジョンを取るにはこうするといいです。

    $ hg log -r "parents(tip)"

マージリビジョンもあるので、 `parents()` は複数のリビジョンを返す場合もあります。

上のも書いてありましたが、リビジョンを指定する場所すべて revsets
使えるので、あるリビジョンと親リビジョンの変更を表示するために以下の様によくします。

    $ hg diff -r "parents(3):3"

これは親リビジョンが一つしかないリビジョンじゃないと動かないんですが、結構便利です。マージリビジョンの場合は、どの親リビジョンとの差を取るかをちゃんと指定しないといけません。

# まとめ

revsets は関数や文脈が多く、かなり強力な機能である。すべてのコマンドや関数は「 [Help:
revsets](http://www.selenic.com/hg/help/revsets) 」に書いてあります。
*(英語ページしか見つからなかったんですが、誰か日本語に翻訳してくれると素敵だなと思います。*

**Update:** 日本語訳はここです。 [THX
@troter\!](https://twitter.com/troter/status/275461587123462145) =\>
<http://mercurial-users.jp/manual/hg.1.html#revsets>

毎日 mercurial 使っている皆様は revsets
を少しでも、使ってみるといろいろ出来なかったことが出来るようになったり、人生が少し変わったように感じるかもしれません。Unix
コマンドと組み合わせてやると更に便利です。例えば、「あいつが仕事してねぇんじゃないの?」って思うときに、こういうようにコミットの数のランキングがとれます:

    $ hg log -r "sort(date('Nov 2012'), user)" | grep "ユーザ:" | awk 'BEGIN { FS=":"; } { print $2; }' | awk 'BEGIN { FS="<" } { print $1 }' | uniq -c | sort -r
        159            Y さん
         84            m さん
         24            c さん
         13            Ian Lewis

おうふ、もうちょっと仕事すればいいんですね。はいはい
