---
layout: post
title: "Django勉強会Disc.8の資料をRSTにした"
date: 2009-04-24 13:22:58 +0000
permalink: /jp/django-disc-8-rst
blog: jp
tags: tech programming events python django
render_with_liquid: false
locale: ja
---

[id:tokibito](http://d.hatena.ne.jp/nullpobug/ "岡野真也")が[見つけてくれた](http://d.hatena.ne.jp/nullpobug/20090424)[`rst2pdf`](https://rst2pdf.org/)を使って[id:tmatsuo](http://takashi-matsuo.blogspot.com/ "松尾貴史")とDjango勉強会Disc.8 ハンズオンC の資料をPDFにした。

ほとんどid:tokibitoと同じやり方でPDFを吐き出したけど、問題点が二つあった。

`rst2pdf`をたたくと`ja.json`を指定する上、`--font-folder`も指定しないと日本語が化ける。Ubuntuの場合`VL-Gothic`で充分なので、

```bash
rst2pdf \
    -s ja.json,perldoc.json \
    --font-folder="/usr/share/fonts/truetype/vlgothic" \
    django-hack-a-thon-get-handson.part2.rst
```

問題点の二つ目は、`rst2pdf`の`wordWrap`が段落に対して、一つのフラグメント(?)しか扱えないようで、エラーが出た。

```bash
[ERROR] styles.py L191 Error processing font VL-Gothic-Regular: Can't open file "ipam.otf"
[ERROR] styles.py L192 Registering VL-Gothic-Regular as Helvetica alias
Traceback (most recent call last):
  File "/usr/bin/rst2pdf", line 8, in <module>
    load_entry_point('rst2pdf==0.9', 'console_scripts', 'rst2pdf')()
  File "/usr/lib/python2.5/site-packages/rst2pdf-0.9-py2.5.egg/rst2pdf/createpdf.py", line 1212, in main
    compressed=options.compressed)
  File "/usr/lib/python2.5/site-packages/rst2pdf-0.9-py2.5.egg/rst2pdf/createpdf.py", line 991, in createPdf
    pdfdoc.build(elements)
  File "/usr/lib/python2.5/site-packages/Reportlab-2.1-py2.5.egg/reportlab/platypus/doctemplate.py", line 740, in build
    self.handle_flowable(flowables)
  File "/usr/lib/python2.5/site-packages/Reportlab-2.1-py2.5.egg/reportlab/platypus/doctemplate.py", line 638, in handle_flowable
    if frame.add(f, self.canv, trySplit=self.allowSplitting):
  File "/usr/lib/python2.5/site-packages/Reportlab-2.1-py2.5.egg/reportlab/platypus/frames.py", line 141, in _add
    w, h = flowable.wrap(aW, h)
  File "/usr/lib/python2.5/site-packages/Reportlab-2.1-py2.5.egg/reportlab/platypus/paragraph.py", line 567, in wrap
    self.blPara = self.breakLinesCJK([first_line_width, later_widths])
  File "/usr/lib/python2.5/site-packages/Reportlab-2.1-py2.5.egg/reportlab/platypus/paragraph.py", line 819, in breakLinesCJK
    raise ValueError('CJK Wordwrap can only handle one fragment per paragraph for now')
ValueError: CJK Wordwrap can only handle one fragment per paragraph for now
```

なので、面倒くさいから、`wordWrap`を無効にした。

```json
{
    "embeddedFonts": [
        [
            "VL-Gothic-Regular.ttf",
            "VL-PGothic-Regular.ttf",
            "ipam.otf",
            "verdanaz.ttf"
        ]
    ],
    "fontsAlias": {
        "stdFont": "VL-PGothic-Regular",
        "stdBold": "VL-PGothic-Regular",
        "stdItalic": "VL-PGothic-Regular",
        "stdMono": "VL-Gothic-Regular"
    },
    "styles": [
        [
            "base",
            {
                "wordWrap": "<strong>None</strong>"
            }
        ],
        [
            "literal",
            {
                "wordWrap": "None"
            }
        ]
    ]
}
```

[Bitbucket](http://bitbucket.org/tmatsuo/gae-handson/src/)に保存してる。

- **PDF**
    - [Part 1](http://bitbucket.org/tmatsuo/gae-handson/raw/12bccec0295a/django-hack-a-thon-get-handson.pdf)
    - [Part 2](http://bitbucket.org/tmatsuo/gae-handson/raw/12bccec0295a/django-hack-a-thon-get-handson.part2.pdf)
