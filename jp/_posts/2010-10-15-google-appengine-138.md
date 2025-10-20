---
layout: post
title: "Google App Engine 1.3.8リリースされました！"
date: 2010-10-15 19:44:31 +0000
permalink: /jp/google-appengine-138
blog: jp
tags: python tech cloud
render_with_liquid: false
locale: ja
---

Google App Engine 1.3.8がリリースされました！

今回のリリースは、いろな面白い機能が入ってきた。

- [ダウンロード](http://code.google.com/intl/ja/appengine/downloads.html)
- [リリースノート](http://code.google.com/p/googleappengine/wiki/SdkReleaseNotes)

## ハンドラー

- `appstats`や、データストアの管理画面、リモートAPIのハンドラーが簡単に設定できるようになりました。

    ```yaml
    builtins:
        datastore_admin: on
        appstats: on
    ```

## 管理画面の改善

- エンティティタイプのすべてのエンティティを削除したり、データストアを完全にクリアすることができるようになりました。データストアのクリアは`datastore_admin`のハンドラーを有効しないといけません。データの削除はクオータを使いますので、ご注意ください。
- 管理画面から、タスクキューに入っているタスクをすぐ実行でくるようになりました。

## マルチアカウント

- マルチアカウント認証を使えるようになりました。複数のGoogleアカウントでログインできるようになりました。App Engineのサイトにアクセスすると、どのアカウントを使うかを選択するようになります。

## 雑多な改善

- 画像APIの`execute_transforms()`関数で、JPEG画像の質を指定することができるようになりました。`queue.yaml`で、バケットサイズは最大件数は100件になりました。
- プレコンパイルはデフォールトに有効になりました。無効にしたい場合は、`--no_precompilation`オプションを指定すれば、無効にすることができます。
- zigzag merge-joinクエリーの制限を外しました。したがって "The built-in indices are not efficient enough for this query and your data. Please add a composite index for this query." というエラーが出る可能性が低くなりました。
