---
layout: post
title: "Google Developer Day 2008"
date: 2008-06-11 12:20:24 +0000
permalink: /jp/limg-src-http-code-google-com-intl-ja-ev-1
blog: jp
render_with_liquid: false
locale: ja
---

昨日、Google Developer Day 2008に行ってきました。キーノットスピーチは[Google I/O](http://code.google.com/events/io/)と全く同じだと思いますが(プレゼンのスライドは翻訳したそのまま）、Googleのデベロッパー向けの将来的なブランが発表された。

## Keynote

コンピュータの世界では、AccessibilityとComputing Powerを同時にうまく使えるように、Client、Connectability、Cloud、三つの課題を目指すそうです。

Clientって言えば、ウェブブラウザです。リッチ アプリケーションを作れるために、ブラウザの機能を広げることを目指す。例えば、ブラウザでデータを保存し、アプリケーションを速くできるように、Google Gearsや、いろなプラグインを作成する予定だそうです。

Connectabilityというのは、インターネットのアクセスがよくできることです。これはソフトウエアだけで解決できない問題と思いますけど、皆さんが平等にアクセスできるように、ISP連携して、電波スタンダードをオープンにして、モバイルプラットフォーム([Android](http://code.google.com/android/))を作成中です。

Cloudというのは、上に述べたComputing Powerです。Googleのサーバー、データセンターをアクセスし、コンピューターのパワーを使えるように[App Engine](https://cloud.google.com/appengine)を作成して、改善していくらしい。

## App Engine Hackathon

午後はApp Engine Hackathonに参加しました。Developer Dayの前の連絡にて、日本語で行うと思ったら、全部英語になってしまいました。私はかまいませんが、他の日本人デベロッパーにはかわいそうな気持ち。さすがGoogleはイベントでワイヤレスアクセスを用意して、テクニカルな準備がいいけども、人間の関係の部分がちょっと不足だったと思った。

最初は　Brett SlatkinがApp Engineの開発環境のプレゼンをしてくれて、それから、コディング、それから、最後に作ったアプリケーションを発表した。皆さんのデベロッパーから、結構いいアイデアが出てきました。最初の発表したのは、アメリカのGoogleのデベロッパーの一人。「僕が軽く作って全然よくないものですが。。」って言ったら、RSSフィードを読んで、それで、DBに入れ込んで、それから、コメントを投稿できる結構いいアプリケーションを発表した。[Memcache](https://memcached.org/)の対応もできたらしい。さすがGoogleエンジニアだと思った。

参加したデベロッパーからのアプリケーションは、つぶやきに写真をつけるアプリケーションや、ソーシャルブックマークアプリケーションや、Djangoの翻訳ファイル作成アプリケーションが含まれた。

僕も一応、ローカルで動いたフォームメーカーのアプリケーションを発表したんだけど、すごく緊張してて、意味がなかなか分からなかった人もいったかもしれない。

## 宴会

Google Developer Dayの終了後、App Engineセッションに参加したデベロッパーと一緒に宴会。たくさんの人の名刺を貰って、僕自身の名刺がなくなってしまった。それでも、皆さんと皆ですごく楽しめて、大満足だった。家に戻ったら、[a2cさん](http://d.hatena.ne.jp/a2c/)や、[山下英孝さん(Weboo!)](https://gihyo.jp/author/%E5%B1%B1%E4%B8%8B%E8%8B%B1%E5%AD%9D)や、[松尾貴史さん](http://takashi-matsuo.blogspot.com/)や、Google Developer Day サポーターページ（Update:このページはもう存在しません！）に載った人が多かったと気づいた。こんな素晴らしいデベロッパーなのに接することができたなんて本当によかったと思った。今度を本当に楽しみにしている。
