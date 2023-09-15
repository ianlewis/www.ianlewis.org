---
layout: post
title: "BPStudy: VIM勉強会"
date: 2009-02-23 11:20:18 +0000
permalink: /jp/vim_benkyoukai-1
blog: jp
---

<p>昨日、VIM勉強会に参加してきた。いろな話があったのだが、screenの使い方が大きな話題になりました。僕はsshや、コンソールでvimをほぼ使ってないので、screenに得意じゃないけど、リモートサーバに接続するときによく使う。以下は<a href="http://twitter.com/shin_no_suke">id:shin_no_suke</a>のプレゼンの資料になります。</p>

<div style="width:425px;text-align:left" id="__ss_1056088"><a style="font:14px Helvetica,Arial,Sans-serif;display:block;margin:12px 0 3px 0;text-decoration:underline;" href="http://www.slideshare.net/bpstudy/gnu-screen-vim-study-1?type=powerpoint" title="GNU screen (vim study #1)">GNU screen (vim study #1)</a><object style="margin:0px" width="425" height="355"><param name="movie" value="http://static.slideshare.net/swf/ssplayer2.swf?doc=vim_study01_screen-090222022852-phpapp02&amp;stripped_title=gnu-screen-vim-study-1" /><param name="allowFullScreen" value="true" /><param name="allowScriptAccess" value="always" /><embed src="http://static.slideshare.net/swf/ssplayer2.swf?doc=vim_study01_screen-090222022852-phpapp02&amp;stripped_title=gnu-screen-vim-study-1" type="application/x-shockwave-flash" allowscriptaccess="always" allowfullscreen="true" width="425" height="355"></embed></object><div style="font-size:11px;font-family:tahoma,arial;height:26px;padding-top:2px;">View more <a style="text-decoration:underline;" href="http://www.slideshare.net/">presentations</a> from <a style="text-decoration:underline;" href="http://www.slideshare.net/bpstudy">bpstudy</a>. (tags: <a style="text-decoration:underline;" href="http://slideshare.net/tag/gnu">gnu</a> <a style="text-decoration:underline;" href="http://slideshare.net/tag/screen">screen</a>)</div></div>

<div style="width:425px;text-align:left" id="__ss_1056087"><a style="font:14px Helvetica,Arial,Sans-serif;display:block;margin:12px 0 3px 0;text-decoration:underline;" href="http://www.slideshare.net/bpstudy/vim-vim-study-1?type=presentation" title="vim入門 (vim study #1)">vim入門 (vim study #1)</a><object style="margin:0px" width="425" height="355"><param name="movie" value="http://static.slideshare.net/swf/ssplayer2.swf?doc=vim_study01-090222022859-phpapp02&amp;stripped_title=vim-vim-study-1" /><param name="allowFullScreen" value="true" /><param name="allowScriptAccess" value="always" /><embed src="http://static.slideshare.net/swf/ssplayer2.swf?doc=vim_study01-090222022859-phpapp02&amp;stripped_title=vim-vim-study-1" type="application/x-shockwave-flash" allowscriptaccess="always" allowfullscreen="true" width="425" height="355"></embed></object><div style="font-size:11px;font-family:tahoma,arial;height:26px;padding-top:2px;">View more <a style="text-decoration:underline;" href="http://www.slideshare.net/">presentations</a> from <a style="text-decoration:underline;" href="http://www.slideshare.net/bpstudy">bpstudy</a>. (tags: <a style="text-decoration:underline;" href="http://slideshare.net/tag/vim">vim</a> <a style="text-decoration:underline;" href="http://slideshare.net/tag/使い方">使い方</a>)</div></div>

<p>僕は vim に初心者なので、結構Vimを充実してないと思いますが、以下の便利な技法を手に入れました。</p>

<ul>
<li><em>Visual Block Modeで挿入</em><br />
I&lt;text&gt;&lt;ESC&gt;<br />
ブロックの前に挿入
<table style="border:1px solid black;">
<tbody>
<tr>
<td style="padding:10px;">
01234<br />
0<font style="background-color: rgb(255, 229, 136);">123</font>4<br />
0<font style="background-color: rgb(255, 229, 136);">123</font>4<br />
0<font style="background-color: rgb(255, 229, 136);">123</font>4<br />
01234<br />
</td>
<td>
=>
</td>
<td style="padding:10px;">
01234<br />
0&lt;text&gt;1234<br />
0&lt;text&gt;1234<br />
0&lt;text&gt;1234<br />
01234<br />
</td>
</tr>
</tbody>
</table>
</li>

<li><em>Visual Block Modeで</em><br />
A&lt;/text&gt;&lt;ESC&gt;<br />
ブロックの後に追加
<table style="border:1px solid black;">
<tbody>
<tr>
<td style="padding:10px;">
01234<br />
0<font style="background-color: rgb(255, 229, 136);">&lt;text&gt;123</font>4<br />
0<font style="background-color: rgb(255, 229, 136);">&lt;text&gt;123</font>4<br />
0<font style="background-color: rgb(255, 229, 136);">&lt;text&gt;123</font>4<br />
01234<br />
</td>
<td>
=>
</td>
<td style="padding:10px;">
01234<br />
0&lt;text&gt;123&lt;/text&gt;4<br />
0&lt;text&gt;123&lt;/text&gt;4<br />
0&lt;text&gt;123&lt;/text&gt;4<br />
01234<br />
</td>
</tr>
</tbody>
</table>
</li>

<li>qbuf.vimを使い、.vimrcで設定すると、&quot;;;&quot;だけでバッファーリストを開ける<br />
<div class="codeblock amc_vim amc_short"><table><tr class="amc_code_odd"><td class="amc_line"><div class="amc1"></div></td><td>let g:qb_hotkey = &quot;;;&quot;</td></tr></table></div>
</li></ul>
<div class="sharethis">
        <script type="text/javascript" language="javascript">
          SHARETHIS.addEntry( {
            title : 'BPStudy: VIM勉強会',
              url   : 'http://www.ianlewis.org/jp/vim_benkyoukai-1'}, 
            { button: true }
          ) ;
        </script></div>
