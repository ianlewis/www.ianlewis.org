---
layout: post
title: "Ubuntu で日本語 106キーDvorak 配列を設定"
date: 2010-08-06 11:06:55 +0000
permalink: /jp/japanese-106-key-dvorak-keyboard-layout
blog: jp
tags: ubuntu linux dvorak キーボード
render_with_liquid: false
---

私はQwerty配列でキーボードで打つのがあまりよくなくて、Dvorakを使ったほうが効率高いんじゃないかと考えて、ずっと前から
[Dvorak配列](http://ja.wikipedia.org/wiki/Dvorak%E9%85%8D%E5%88%97)
を使っています。 何かというと、キーポードの配列をソフトで切り替えるような仕組みを使っています。例えば、普通のキーポードの
a s d f のキーを打つと、a o e u が入力されます。

U.S. Dvorak配列のイメージです。

![image](http://static.ianlewis.org/prod/img/621/us_dvorak.png)

アメリカにいたら、よくある U.S. Dvorak
配列を使っていたんですが、日本に来てから、日本語用のキーポードが普段になっていたので、キーの配置が若干違うのが問題でした。漢字変換用のキーなども普段にキーポードに入っています。日本語キーポードで動くDvorak
配列ってあまりなかったわけですが、探したら、 [DvorakJP](http://www7.plala.or.jp/dvorakjp/)
というサイトを見つけたりして、その時は仕事で Windows で作業していたので、結局、
[このサイト](http://hp.vector.co.jp/authors/VA009883/) の `dvorak
kr` というのを使うことにした。

Windowsを使う限り、それはそれでよかったんですが、Ubuntu では、そういうキーボード配列がなかったので、自分で作ることしかなかった。

Ubuntu では、 `/usr/share/X11/xkb/` に入っている `xkb`
設定をさわると、カスタムキーボードのマッピングを追加できます。修正するファイルは、
`rules/evdev.lst` 、 `rules/evdev.xml` 、 `symbols/jp` のみつです。

まずは、 `symbols/jp` でキーマップの定期をする。下のテキストを `symbols/jp` の一番したに追加する。定義は U.S.
のキーボードマップを継承する。

```text
// DvorakJP keyboard.
// Copyright 2009-2010 Ian Lewis

partial xkb_symbols "dvorak" {

    include "us(dvorak)"
    name[Group1]= "Japan - Dvorak";

    // Alphanumeric section
    key <HZTG> {
        type[Group1]="PC_SYSRQ",
        symbols[Group1]= [ Zenkaku_Hankaku, Kanji ]
    };

    key <AE02> { [ 2, quotedbl      ] };

    key <AE06> { [ 6, ampersand     ] };
    key <AE07> { [ 7, apostrophe    ] };
    key <AE08> { [ 8, parenleft     ] };
    key <AE09> { [ 9, parenright    ] };
    key <AE10> { [ 0,asciitilde     ] };
    key <AE11> { [ bracketleft, braceleft ] };
    key <AE12> { [ bracketright, braceright ] };
    key <AE13> { [ backslash, bar   ] };

    key <AD12> { [ at, grave        ] };

    key <AC11> { [ minus, equal     ] };
    key <AC12> { [ asciicircum, asciitilde] };

    key <CAPS> { [ Eisu_toggle, Caps_Lock ] };

    key <AB01> { [ semicolon, plus  ] };
    key <AD01> { [ colon, asterisk  ] };

    key <AB11> { [ backslash, underscore ] };

    key <NFER> { [ Muhenkan     ]   };

    key <XFER> {
        type[Group1]="PC_SYSRQ",
        symbols[Group1]= [ Henkan, Mode_switch ]
    };
    key <HKTG> {
        type[Group1]="PC_SYSRQ",
        symbols[Group1]= [ Hiragana_Katakana, Romaji ]
    };

    key <PRSC> {
        type[Group1]= "PC_SYSRQ",
        symbols[Group1]= [ Print, Execute ]
    };
};
```

次は `rules/evdev.xml` を修正する。Japan という layout を探して、そこに、 Dvorak
\<variant\>タグを追加する。

```xml
<layout>
  <configItem>
    <name>jp</name>
    <shortDescription>Jpn</shortDescription>
    <description>Japan</description>
    <languageList><iso639Id>jpn</iso639Id></languageList>
  </configItem>
  <variantList>
    <variant>
      <configItem>
        <name>kana</name>
        <description>Kana</description>
      </configItem>
    </variant>
     <variant>
      <configItem>
        <name>OADG109A</name>
        <description>OADG 109A</description>
      </configItem>
    </variant>
    <variant>
      <configItem>
        <name>mac</name>
        <description>Macintosh</description>
      </configItem>
    </variant>
    <!-- Dvorak を追加 -->
    <variant>
      <configItem>
        <name>dvorak</name>
        <description>Dvorak</description>
      </configItem>
    </variant>
  </variantList>
</layout>
```

最後に `symbols/evdev.lst` を修正する。 `jp: Kana` を検索して、dvorak キーマップを variant
のリストに追加する。

```text
...
us              it: US keyboard with Italian letters
geo             it: Georgian
kana            jp: Kana
OADG109A        jp: OADG 109A
mac             jp: Macintosh
dvorak          jp: Dvorak
phonetic        kg: Phonetic
ruskaz          kz: Russian with Kazakh
kazrus          kz: Kazakh with Russian
...
```

それで、ログアウトして、またログインすると、xkb を使うdaemon
や、Xキーマップの設定が再読み込みするはず。それで、メニューから選ぶ、「システム」=\>
「設定」=\> 「キーボード」 =\> 「追加」 で、日本語Dvorak キーボード配列を選択できる。

![image](http://static.ianlewis.org/prod/img/621/jp160_dvorak.jpg)
