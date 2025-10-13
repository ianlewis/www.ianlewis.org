---
layout: post
title: "BPStudy: VIM勉強会"
date: 2009-02-23 11:20:18 +0000
permalink: /jp/vim_benkyoukai-1
blog: jp
tags: tech programming events
render_with_liquid: false
locale: ja
---

昨日、VIM勉強会に参加してきた。いろな話があったのだが、screenの使い方が大きな話題になりました。僕はsshや、コンソールでvimをほぼ使ってないので、screenに得意じゃないけど、リモートサーバに接続するときによく使う。以下は[id:shin_no_suke](http://twitter.com/shin_no_suke)のプレゼンの資料になります。

- [GNU screen](https://www.slideshare.net/slideshow/gnu-screen-vim-study-1/1056088)
- [vim入門](https://www.slideshare.net/slideshow/vim-vim-study-1/1056087)

僕は vim に初心者なので、結構Vimを充実してないと思いますが、以下の便利な技法を手に入れました。

たとえ、以下のテキストがあってVisual Block Modeで２行目から４行目までの`123`をハイライトするとして

```text
01234
01234
01234
01234
01234
```

Visual Block Modeで挿入 `I<text><ESC>` ブロックの前に挿入

```text
01234
0<text>1234
0<text>1234
0<text>1234
01234
```

Visual Block Modeで `A</text><ESC>` ブロックの後に追加

```text
01234
0<text>123</text>4
0<text>123</text>4
0<text>123</text>4
01234
```

[`qbuf.vim`](https://www.vim.org/scripts/script.php?script_id=1910)を使い、`.vimrc`で設定すると、`;;`だけでバッファーリストを開ける

```vim
let g:qb_hotkey = ";;"
```
