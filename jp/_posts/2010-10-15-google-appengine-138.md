---
layout: post
title: "Google Appengine 1.3.8リリースされました！"
date: 2010-10-15 19:44:31 +0000
permalink: /jp/google-appengine-138
blog: jp
tags: python google appengine
render_with_liquid: false
---

Google Appengine 1.3.8 がリリースされました！

今回のリリースは、いろな面白い機能が入ってきた。

# ハンドラー

appstats や、データストアの管理画面、リモートAPIのハンドラーが簡単に設定できるようになりました。

```yaml
builtins:
  datastore_admin: on
  appstats: on
```

# 管理画面の改善

" エンティティタイプのすべてのエンティティを削除したり、データストアを完全にクリアすることができるようになりました。データストアのクリアは
`datastore_admin` のハンドラーを有効しないといけません。データの削除はクオータを使いますので、ご注意ください。 \*
管理画面から、タスクキューに入っているタスクをすぐ実行でくるようになりました。

# マルチアカウント

" マルチアカウント認証を使えるようになりました。 複数の Google アカウントでログインできるようになりました。 Appengine
のサイトにアクセスすると、どのアカウントを使うかを選択するようになります。

# 雑多な改善

- 画像API の `execute_transforms()` 関数で、 JPEG画像の質を指定することができるようになりました。
- queue.yaml で、バケットサイズは最大件数は 100件 になりました。
- プレコンパイルはデフォールトに有効になりました。無効にしたい場合は、 `--no_precompilation`
  オプションを指定すれば、無効にすることができます。
- zigzag merge-join クエリーの制限を外しました。 したがって "The built-in indices are not
  efficient enough for this query and your data. Please add a
  composite index for this query." というエラーが出る可能性が低くなりました。

リリースノートはこちら:
<http://code.google.com/p/googleappengine/wiki/SdkReleaseNotes>

ダウンロードはこちら: <http://code.google.com/intl/ja/appengine/downloads.html>
