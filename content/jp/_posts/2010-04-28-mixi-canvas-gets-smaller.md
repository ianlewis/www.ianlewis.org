---
layout: post
title: "mixi アプリのキャンバスが狭くなるぞ"
date: 2010-04-28 16:52:22 +0000
permalink: /jp/mixi-canvas-gets-smaller
blog: jp
tags: mixi
render_with_liquid: false
locale: ja
---

昨日、mixi アプリのキャンバスサイズ (run_appli.pl (canvas) の表示サイズ) が狭くなる[ニューズ](http://developer.mixi.co.jp/news/2010042702)が出た。mixi の公告プラットフォームのために、キャンバスの幅を狭くし、右側に公告を出すようにするらしい。10月までにアプリを修正しないとだめだ。これはひどい。Flashのサイズ限定アプリはほぼ作り直しになるかも。

6月～9月に、`945px`と`760px` 両方使えるのですけど、`760px` にすると、`945px`に元に戻すことができなくなる。後、10月から、`945px`のサポートが終了になる。ということで注意しろ

[run_appli.pl (canvas)の表示サイズ変更について](http://developer.mixi.co.jp/appli/pc/lets_enjoy_making_mixiapp/adjust_iframe/change_iframe_size)
