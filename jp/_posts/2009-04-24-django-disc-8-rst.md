---
layout: post
title: "Django勉強会Disc.8の資料をRSTにした"
date: 2009-04-24 13:22:58 +0000
permalink: /jp/django-disc-8-rst
blog: jp
render_with_liquid: false
---

<p><a href="http://d.hatena.ne.jp/nullpobug/" title="岡野真也">id:tokibito</a>が<a href="http://d.hatena.ne.jp/nullpobug/20090424">見つけてくれた</a> <a href="">rst2pdf</a> を使って<a href="http://takashi-matsuo.blogspot.com/" title="松尾 貴史">id:tmatsuo</a> と<a href="http://www.djangoproject.com/" title="Django">Django</a>勉強会Disc.8 ハンズオンC の資料をPDFにした。</p>

<p>ほとんど <a href="http://d.hatena.ne.jp/nullpobug/" title="岡野真也">id:tokibito</a>と同じやり方でPDFを吐き出したけど、問題点が二つあった。</p>

<p>rst2pdf をたたくと ja.jsonを指定する上、font-directoryも指定しないと日本語が化ける。<a href="http://www.ubuntu.com/" title="Ubuntu">Ubuntu</a>の場合 VL-Gothicで充分なので、</p>

<blockquote>rst2pdf -s ja.json,perldoc.json --font-folder="/usr/share/fonts/truetype/vlgothic" django-hack-a-thon-get-handson.part2.rst</blockquote>

<p>問題点の二つ目は、rst2pdfの wordWrapが段落に対して、一つのフラグメント(?)しか扱えないようで、エラーが出た。</p>

<blockquote>
<pre>
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
</module></pre>
</blockquote>

<p>なので、面倒くさいから、wordWrapを無効にした。</p>

<blockquote>
<pre>
{
  "embeddedFonts" :
[["VL-Gothic-Regular.ttf","VL-PGothic-Regular.ttf","ipam.otf","verdanaz.ttf"]],
  "fontsAlias" : {
    "stdFont": "VL-PGothic-Regular",
    "stdBold": "VL-PGothic-Regular",
    "stdItalic": "VL-PGothic-Regular",
    "stdMono": "VL-Gothic-Regular"
  },
  "styles" : [
    ["base" , {
      "wordWrap": "<strong>None</strong>"
    }],
    ["literal" , {
      "wordWrap": "None"
    }]
  ]
}
</pre>
</blockquote>

<p><a href="http://bitbucket.org/tmatsuo/gae-handson/src/">bitbucket</a>に保存してる。
<h4>PDF</h4>
<ul>
<li><a href="http://bitbucket.org/tmatsuo/gae-handson/raw/12bccec0295a/django-hack-a-thon-get-handson.pdf">Part 1</a></li>
<li><a href="http://bitbucket.org/tmatsuo/gae-handson/raw/12bccec0295a/django-hack-a-thon-get-handson.part2.pdf">Part 2</a></li>
</ul>
</p>
