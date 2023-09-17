---
layout: post
title: "Javaに日本語のフォントのインストール"
date: 2009-06-16 11:38:01 +0000
permalink: /jp/java-japanese-fonts
blog: jp
tags: 日本語 java フォント
render_with_liquid: false
---

LinuxではJavaは標準に日本語フォントが大体インストールされてないので、手でインストールしないといけない。

Ubuntuでは、このようにFontインストールが済む:

    mkdir -p <jvm>/jre/lib/fonts/fallback
    cp /usr/share/fonts/truetype/vlgothic/*.ttf <jvm>/jre/lib/fonts/fallback
