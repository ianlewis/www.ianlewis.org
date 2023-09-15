---
layout: post
title: "UTF-8 with guile"
date: 2008-11-19 23:03:47 +0000
permalink: /en/utf-8-with-guile
blog: en
---

<p>Getting UTF-8 to work with guile is a bit of a stretch as guile doesn't have any real encoding or UTF-8 support to speak of, but I was able to get at least some basic stuff working by using the <a href="http://www.gnu.org/software/guile-gnome/docs/glib/html/Unicode-Manipulation.html#Unicode-Manipulation">Unicode Manipulation</a> routines which are part of the <a href="http://www.gnu.org/software/guile-gnome/docs/glib/html/index.html">Guile-Glib</a> module.</p>

<p>This requires that you have your LD_LIBRARY_PATH and GUILE_LOAD_PATH set properly so that it can load the glib libraries. This didn't work for me out of the box with guile, but <a href="http://www.ubuntu.com/" title="Ubuntu">Ubuntu</a>'s guile-gnome0-glib package provides a script called guile-gnome-0 for setting these values for you and running guile. If you just run guile as is...</p>

<blockquote>
<span class="codespan">ian@laptop:~# guile<br />
guile<span style="color: #66cc66;">&gt;</span> <span style="color: #66cc66;">&#40;</span>use<span style="color: #66cc66;">-</span>modules <span style="color: #66cc66;">&#40;</span>gnome glib<span style="color: #66cc66;">&#41;</span><span style="color: #66cc66;">&#41;</span><br />
<br />
Backtrace:<br />
In standard input:<br />
&nbsp; &nbsp;<span style="color: #cc66cc;">1</span>: <span style="color: #cc66cc;">0</span><span style="color: #66cc66;">*</span> <span style="color: #66cc66;">&#40;</span>use<span style="color: #66cc66;">-</span>modules <span style="color: #66cc66;">&#40;</span>gnome glib<span style="color: #66cc66;">&#41;</span><span style="color: #66cc66;">&#41;</span><br />
&nbsp; &nbsp;<span style="color: #cc66cc;">1</span>: <span style="color: #cc66cc;">1</span> &nbsp;<span style="color: #66cc66;">&#40;</span>eval<span style="color: #66cc66;">-</span><span style="color: #b1b100;">case</span> <span style="color: #66cc66;">&#40;</span># # <span style="color: #66cc66;">*</span>unspecified<span style="color: #66cc66;">*</span><span style="color: #66cc66;">&#41;</span> <span style="color: #66cc66;">&#40;</span><span style="color: #b1b100;">else</span> #<span style="color: #66cc66;">&#41;</span><span style="color: #66cc66;">&#41;</span><br />
&nbsp; &nbsp;<span style="color: #cc66cc;">1</span>: <span style="color: #cc66cc;">2</span> &nbsp;<span style="color: #66cc66;">&#40;</span><span style="color: #b1b100;">begin</span> <span style="color: #66cc66;">&#40;</span>process<span style="color: #66cc66;">-</span>use<span style="color: #66cc66;">-</span>modules <span style="color: #66cc66;">&#40;</span><span style="color: #b1b100;">list</span> <span style="color: #66cc66;">&#40;</span><span style="color: #b1b100;">list</span> #<span style="color: #66cc66;">&#41;</span><span style="color: #66cc66;">&#41;</span><span style="color: #66cc66;">&#41;</span> <span style="color: #66cc66;">*</span>unspecified<span style="color: #66cc66;">*</span><span style="color: #66cc66;">&#41;</span><br />
In unknown file:<br />
&nbsp; &nbsp;?: <span style="color: #cc66cc;">3</span><span style="color: #66cc66;">*</span> <span style="color: #66cc66;">&#91;</span>process<span style="color: #66cc66;">-</span>use<span style="color: #66cc66;">-</span>modules <span style="color: #66cc66;">&#40;</span><span style="color: #66cc66;">&#40;</span><span style="color: #66cc66;">&#40;</span>gnome glib<span style="color: #66cc66;">&#41;</span><span style="color: #66cc66;">&#41;</span><span style="color: #66cc66;">&#41;</span><span style="color: #66cc66;">&#93;</span><br />
<br />
<span style="color: #66cc66;">&lt;</span>unnamed port<span style="color: #66cc66;">&gt;</span>: In procedure process<span style="color: #66cc66;">-</span>use<span style="color: #66cc66;">-</span>modules in expression <span style="color: #66cc66;">&#40;</span>process<span style="color: #66cc66;">-</span>use<span style="color: #66cc66;">-</span>modules <span style="color: #66cc66;">&#40;</span><span style="color: #b1b100;">list</span> #<span style="color: #66cc66;">&#41;</span><span style="color: #66cc66;">&#41;</span>:<br />
<span style="color: #66cc66;">&lt;</span>unnamed port<span style="color: #66cc66;">&gt;</span>: no code for module <span style="color: #66cc66;">&#40;</span>gnome glib<span style="color: #66cc66;">&#41;</span><br />
ABORT: <span style="color: #66cc66;">&#40;</span>misc<span style="color: #66cc66;">-</span>error<span style="color: #66cc66;">&#41;</span><br />
guile<span style="color: #66cc66;">&gt;</span></span>
</blockquote>

<p>Anyway you can run guile with the right paths on <a href="http://www.ubuntu.com/" title="Ubuntu">Ubuntu</a> by running guile-gnome-0. After getting that running I made use of the Guile-Glib module to do some operations of utf8 data. I did this from a utf8 console. Beware. The terminal was not to friendly with me about things like arrow keys and backspaces over multibyte characters etc.</p>

<blockquote>
<span class="codespan">guile<span style="color: #66cc66;">&gt;</span> <span style="color: #66cc66;">&#40;</span>use<span style="color: #66cc66;">-</span>modules <span style="color: #66cc66;">&#40;</span>gnome glib<span style="color: #66cc66;">&#41;</span><span style="color: #66cc66;">&#41;</span><br />
WARNING: <span style="color: #66cc66;">&#40;</span>gnome gw generics<span style="color: #66cc66;">&#41;</span>: imported module <span style="color: #66cc66;">&#40;</span>gnome gobject generics<span style="color: #66cc66;">&#41;</span> overrides core binding `connect'<br />
guile<span style="color: #66cc66;">&gt;</span> <span style="color: #66cc66;">&#40;</span>string<span style="color: #66cc66;">-</span><span style="color: #b1b100;">length</span> <span style="color: #ff0000;">&quot;テスト&quot;</span><span style="color: #66cc66;">&#41;</span><br />
<span style="color: #cc66cc;">9</span><br />
guile<span style="color: #66cc66;">&gt;</span> <span style="color: #66cc66;">&#40;</span>g<span style="color: #66cc66;">-</span>utf8<span style="color: #66cc66;">-</span>strlen <span style="color: #ff0000;">&quot;テスト&quot;</span> <span style="color: #cc66cc;">-1</span><span style="color: #66cc66;">&#41;</span><br />
<span style="color: #cc66cc;">3</span><br />
guile<span style="color: #66cc66;">&gt;</span> <span style="color: #66cc66;">&#40;</span>g<span style="color: #66cc66;">-</span>utf8<span style="color: #66cc66;">-</span>validate <span style="color: #ff0000;">&quot;テスト&quot;</span> <span style="color: #cc66cc;">-1</span> #f<span style="color: #66cc66;">&#41;</span><br />
#t<br />
guile<span style="color: #66cc66;">&gt;</span> <span style="color: #66cc66;">&#40;</span>g<span style="color: #66cc66;">-</span>unichar<span style="color: #66cc66;">-</span>validate <span style="color: #66cc66;">&#40;</span>g<span style="color: #66cc66;">-</span>utf8<span style="color: #66cc66;">-</span>get<span style="color: #66cc66;">-</span>char <span style="color: #ff0000;">&quot;手&quot;</span><span style="color: #66cc66;">&#41;</span><span style="color: #66cc66;">&#41;</span><br />
#t</span>
</blockquote>
