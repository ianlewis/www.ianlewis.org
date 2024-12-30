---
layout: post
title: "mercurial でアクティブなブランチのみを表示する方法"
date: 2009-11-26 12:47:06 +0000
permalink: /jp/mercurial-show-active-only-jp
blog: jp
tags: mercurial ブランチ
render_with_liquid: false
---

<!-- textlint-disable rousseau -->

merucurial の hg
branchesっていうコマンドを打つと、inactiveブランチが普段に出てうるさいので、表示しないようにしてみた。これを
.hgrc に追加した

```text
[alias]
branches = branches -a
```

普通は、この表示になる

```text
ian@laptop:~/src/prj$ hg branches
default                     1662:1fa310d3052a
hoge                        1661:62d737e7146e
hoge_inactive               1623:ba27ba59a257 (inactive)
hoge_closed                 670:1c3134ca4a95 (closed)
```

修正後に、hg branchesを叩くと、綺麗にでる。

```text
ian@laptop:~/src/prj$ hg branches
default                     1662:1fa310d3052a
hoge                        1661:62d737e7146e
```

<!-- textlint-enable rousseau -->
