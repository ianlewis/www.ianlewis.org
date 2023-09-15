---
layout: post
title: "javascript \"var\""
date: 2009-05-13 15:38:30 +0000
permalink: /jp/javascript-var
blog: jp
render_with_liquid: false
---

<p>javascript で変数を定義する時に、var を付ける場合があります。var を付けないと、変数がグローバル名前空間に入ってしまう。</p>

<div class="codeblock amc_javascript amc_short"><table><tr class="amc_code_odd"><td class="amc_line"><div class="amc1"></div></td><td><span style="color: #66cc66;">&gt;&gt;&gt;</span> test = <span style="color: #003366; font-weight: bold;">function</span><span style="color: #66cc66;">&#40;</span><span style="color: #66cc66;">&#41;</span> <span style="color: #66cc66;">&#123;</span> test = <span style="color: #3366CC;">&quot;blah&quot;</span> <span style="color: #66cc66;">&#125;</span>;<br /></td></tr><tr class="amc_code_even"><td class="amc_line"><div class="amc2"></div></td><td><span style="color: #003366; font-weight: bold;">function</span><span style="color: #66cc66;">&#40;</span><span style="color: #66cc66;">&#41;</span><br /></td></tr><tr class="amc_code_odd"><td class="amc_line"><div class="amc3"></div></td><td><span style="color: #66cc66;">&gt;&gt;&gt;</span> test<span style="color: #66cc66;">&#40;</span><span style="color: #66cc66;">&#41;</span>;<br /></td></tr><tr class="amc_code_even"><td class="amc_line"><div class="amc4"></div></td><td><span style="color: #66cc66;">&gt;&gt;&gt;</span> test<span style="color: #66cc66;">&#40;</span><span style="color: #66cc66;">&#41;</span>;<br /></td></tr><tr class="amc_code_odd"><td class="amc_line"><div class="amc5"></div></td><td>TypeError: test <span style="color: #000066; font-weight: bold;">is</span> not a <span style="color: #003366; font-weight: bold;">function</span> source=<span style="color: #000066; font-weight: bold;">with</span><span style="color: #66cc66;">&#40;</span>_FirebugCommandLine<span style="color: #66cc66;">&#41;</span><span style="color: #66cc66;">&#123;</span>test<span style="color: #66cc66;">&#40;</span><span style="color: #66cc66;">&#41;</span>;\n<span style="color: #66cc66;">&#125;</span>;</td></tr></table></div>

<p>この場合だと、testがtestを文字列に変えてしまう。</p>

<div class="codeblock amc_javascript amc_short"><table><tr class="amc_code_odd"><td class="amc_line"><div class="amc1"></div></td><td><span style="color: #66cc66;">&gt;&gt;&gt;</span> test = <span style="color: #003366; font-weight: bold;">function</span><span style="color: #66cc66;">&#40;</span><span style="color: #66cc66;">&#41;</span> <span style="color: #66cc66;">&#123;</span> blah = <span style="color: #3366CC;">&quot;blah&quot;</span> <span style="color: #66cc66;">&#125;</span>;<br /></td></tr><tr class="amc_code_even"><td class="amc_line"><div class="amc2"></div></td><td><span style="color: #003366; font-weight: bold;">function</span><span style="color: #66cc66;">&#40;</span><span style="color: #66cc66;">&#41;</span><br /></td></tr><tr class="amc_code_odd"><td class="amc_line"><div class="amc3"></div></td><td><span style="color: #66cc66;">&gt;&gt;&gt;</span> test<span style="color: #66cc66;">&#40;</span><span style="color: #66cc66;">&#41;</span>;<br /></td></tr><tr class="amc_code_even"><td class="amc_line"><div class="amc4"></div></td><td><span style="color: #66cc66;">&gt;&gt;&gt;</span> blah<br /></td></tr><tr class="amc_code_odd"><td class="amc_line"><div class="amc5"></div></td><td><span style="color: #3366CC;">&quot;blah&quot;</span></td></tr></table></div>

<p>...ということです。</p>

<p>知らなくて恥ずかしいんですけど、今まで書いたjavascriptで一再付けなくて、あまりよくない。でも、逆に var を付けるのがあまりにも面倒くさいので、凹んでjavascriptを書く気がちょっと減ってしまった。orz</p>
