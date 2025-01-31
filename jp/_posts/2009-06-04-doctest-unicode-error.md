---
layout: post
title: "Python 例外のひどい仕様"
date: 2009-06-04 14:39:55 +0000
permalink: /jp/doctest-unicode-error
blog: jp
tags: python django 例外 unicode test
render_with_liquid: false
locale: ja
---

<p><a href="http://www.python.org/" title="Python">Python</a>の例外オブジェクトは苦手です。例外のメッセージが何でもasciiとして扱われることがひどい。</p>

<div class="codeblock amc_python amc_short"><table><tr class="amc_code_odd"><td class="amc_line"><div class="amc1"></div></td><td>In <span style="color: black;">&#91;</span><span style="color: #ff4500;">1</span><span style="color: black;">&#93;</span>: t = <span style="color: #008000;">ValueError</span><span style="color: black;">&#40;</span><span style="color: #483d8b;">&quot;テスト&quot;</span>.<span style="color: black;">decode</span><span style="color: black;">&#40;</span><span style="color: #483d8b;">&quot;utf8&quot;</span><span style="color: black;">&#41;</span><span style="color: black;">&#41;</span><br /></td></tr><tr class="amc_code_even"><td class="amc_line"><div class="amc2"></div></td><td><br /></td></tr><tr class="amc_code_odd"><td class="amc_line"><div class="amc3"></div></td><td>In <span style="color: black;">&#91;</span><span style="color: #ff4500;">2</span><span style="color: black;">&#93;</span>: <span style="color: #ff7700;font-weight:bold;">print</span> t<br /></td></tr><tr class="amc_code_even"><td class="amc_line"><div class="amc4"></div></td><td>locale: ja
---------------------------------------------------------------------------<br /></td></tr><tr class="amc_code_odd"><td class="amc_line"><div class="amc5"></div></td><td><span style="color: #008000;">UnicodeEncodeError</span> &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;Traceback <span style="color: black;">&#40;</span>most recent call last<span style="color: black;">&#41;</span><br /></td></tr><tr class="amc_code_even"><td class="amc_line"><div class="amc6"></div></td><td><br /></td></tr><tr class="amc_code_odd"><td class="amc_line"><div class="amc7"></div></td><td>/home/ian/src/project/<span style="color: #66cc66;">&lt;</span>ipython console<span style="color: #66cc66;">&gt;</span> <span style="color: #ff7700;font-weight:bold;">in</span> <span style="color: #66cc66;">&lt;</span>module<span style="color: #66cc66;">&gt;</span><span style="color: black;">&#40;</span><span style="color: black;">&#41;</span><br /></td></tr><tr class="amc_code_even"><td class="amc_line"><div class="amc8"></div></td><td><br /></td></tr><tr class="amc_code_odd"><td class="amc_line"><div class="amc9"></div></td><td><span style="color: #008000;">UnicodeEncodeError</span>: <span style="color: #483d8b;">'ascii'</span> codec can<span style="color: #483d8b;">'t encode characters in position 0-2: ordinal not in range(128)<br /></td></tr><tr class="amc_code_even"><td class="amc_line"><div class="amc0"><div class="amc1"></div></div></td><td><br /></td></tr><tr class="amc_code_odd"><td class="amc_line"><div class="amc1"><div class="amc1"></div></div></td><td>In [3]: t = ValueError(u&quot;テスト&quot;) # Unicode object'</span>s don<span style="color: #483d8b;">'t work either<br /></td></tr><tr class="amc_code_even"><td class="amc_line"><div class="amc2"><div class="amc1"></div></div></td><td><br /></td></tr><tr class="amc_code_odd"><td class="amc_line"><div class="amc3"><div class="amc1"></div></div></td><td>In [4]: print t<br /></td></tr><tr class="amc_code_even"><td class="amc_line"><div class="amc4"><div class="amc1"></div></div></td><td>---------------------------------------------------------------------------<br /></td></tr><tr class="amc_code_odd"><td class="amc_line"><div class="amc5"><div class="amc1"></div></div></td><td>UnicodeEncodeError &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;Traceback (most recent call last)<br /></td></tr><tr class="amc_code_even"><td class="amc_line"><div class="amc6"><div class="amc1"></div></div></td><td><br /></td></tr><tr class="amc_code_odd"><td class="amc_line"><div class="amc7"><div class="amc1"></div></div></td><td>/home/ian/src/project/&lt;ipython console&gt; in &lt;module&gt;()<br /></td></tr><tr class="amc_code_even"><td class="amc_line"><div class="amc8"><div class="amc1"></div></div></td><td><br /></td></tr><tr class="amc_code_odd"><td class="amc_line"><div class="amc9"><div class="amc1"></div></div></td><td>UnicodeEncodeError: '</span>ascii<span style="color: #483d8b;">' codec can'</span>t encode characters <span style="color: #ff7700;font-weight:bold;">in</span> position <span style="color: #ff4500;">0</span><span style="color: #ff4500;">-2</span>: ordinal <span style="color: #ff7700;font-weight:bold;">not</span> <span style="color: #ff7700;font-weight:bold;">in</span> <span style="color: #008000;">range</span><span style="color: black;">&#40;</span><span style="color: #ff4500;">128</span><span style="color: black;">&#41;</span></td></tr></table></div>

<p><a href="http://www.djangoproject.com/" title="Django">Django</a>のテストフレームワークで、doctestを使おうと思ったら、例外のメッセージがasciiじゃないとダメというのが判明</p>

<div class="codeblock amc_python amc_short"><table><tr class="amc_code_odd"><td class="amc_line"><div class="amc1"></div></td><td>u<span style="color: #483d8b;">&quot;&quot;</span><span style="color: #483d8b;">&quot;<br /></td></tr><tr class="amc_code_even"><td class="amc_line"><div class="amc2"></div></td><td>&gt;&gt;&gt; test(-1)<br /></td></tr><tr class="amc_code_odd"><td class="amc_line"><div class="amc3"></div></td><td>&nbsp; &nbsp; Traceback (most recent call last):<br /></td></tr><tr class="amc_code_even"><td class="amc_line"><div class="amc4"></div></td><td>&nbsp; &nbsp; &nbsp; &nbsp; ...<br /></td></tr><tr class="amc_code_odd"><td class="amc_line"><div class="amc5"></div></td><td>&nbsp; &nbsp; ValueError: エラーですよ！<br /></td></tr><tr class="amc_code_even"><td class="amc_line"><div class="amc6"></div></td><td>&quot;</span><span style="color: #483d8b;">&quot;&quot;</span></td></tr></table></div>

<p>とやっても、うまくうごかない。以下のUnicodeDecodeErrorがでる</p>

<blockquote>
<pre>
======================================================================
ERROR: Doctest: app.tests
locale: ja
----------------------------------------------------------------------
Traceback (most recent call last):
  File "/home/ian/.virtualenvs/test/lib/python2.5/site-packages/django/test/_doctest.py", line 2175, in runTest
    test, out=new.write, clear_globs=False)
  File "/home/ian/.virtualenvs/test/lib/python2.5/site-packages/django/test/_doctest.py", line 1403, in run
    return self.__run(test, compileflags, out)
  File "/home/ian/.virtualenvs/test/lib/python2.5/site-packages/django/test/_doctest.py", line 1291, in __run
    got += _exception_traceback(exc_info)
  File "/home/ian/.virtualenvs/test/lib/python2.5/site-packages/django/test/_doctest.py", line 269, in _exception_traceback
    return excout.getvalue()
  File "/usr/lib/python2.5/StringIO.py", line 270, in getvalue
    self.buf += ''.join(self.buflist)
UnicodeDecodeError: 'ascii' codec can't decode byte 0xe3 in position 24: ordinal not in range(128)

locale: ja
---

</pre>
</blockquote>

<p>Update: moriyoshiさんにより、Python 2.6 で<a href="http://d.hatena.ne.jp/moriyoshi/20090604/1244092247">ちゃんと動くみたい</a></p>
