---
layout: post
title: "Werkzeugのreverse URL処理"
date: 2009-03-12 17:57:47 +0000
permalink: /jp/werkzeug-reverse-url
blog: jp
tags: python django werkzeug
render_with_liquid: false
locale: ja
---

<p><a href="http://twisted-mind.appspot.com/">ほぼ汎用イベント管理ツール</a>の改善をしようと思ってて、実際にコードを見ると<a href="http://bitbucket.org/voluntas/twisted-mind/src/tip/views.py#cl-132">URLを使ってる</a>のが気になった。</p>

<p>WerkzeugのURLルーティングで<a href="http://www.djangoproject.com/" title="Django">Django</a>のreverse関数みたいにURLの名前からURLに変換できるのかなと調べて、ある方法がありました。名前からじゃなくて、endpointから変換するけど。。。</p>

<div class="codeblock amc_python amc_short"><table><tr class="amc_code_odd"><td class="amc_line"><div class="amc1"></div></td><td><span style="color: #ff7700;font-weight:bold;">from</span> werkzeug redirect as wredirect<br /></td></tr><tr class="amc_code_even"><td class="amc_line"><div class="amc2"></div></td><td><span style="color: #ff7700;font-weight:bold;">from</span> urls <span style="color: #ff7700;font-weight:bold;">import</span> url_map<br /></td></tr><tr class="amc_code_odd"><td class="amc_line"><div class="amc3"></div></td><td><br /></td></tr><tr class="amc_code_even"><td class="amc_line"><div class="amc4"></div></td><td><span style="color: #ff7700;font-weight:bold;">def</span> reverse<span style="color: black;">&#40;</span><span style="color: #66cc66;">**</span>kwargs<span style="color: black;">&#41;</span>:<br /></td></tr><tr class="amc_code_odd"><td class="amc_line"><div class="amc5"></div></td><td>&nbsp; c = url_map.<span style="color: black;">bind</span><span style="color: black;">&#40;</span><span style="color: #483d8b;">''</span><span style="color: black;">&#41;</span><br /></td></tr><tr class="amc_code_even"><td class="amc_line"><div class="amc6"></div></td><td>&nbsp; <span style="color: #ff7700;font-weight:bold;">return</span> wredirect<span style="color: black;">&#40;</span>c.<span style="color: black;">build</span><span style="color: black;">&#40;</span><span style="color: #66cc66;">**</span>kwargs<span style="color: black;">&#41;</span><span style="color: black;">&#41;</span><br /></td></tr><tr class="amc_code_odd"><td class="amc_line"><div class="amc7"></div></td><td><br /></td></tr><tr class="amc_code_even"><td class="amc_line"><div class="amc8"></div></td><td>...<br /></td></tr><tr class="amc_code_odd"><td class="amc_line"><div class="amc9"></div></td><td>&nbsp; &nbsp;<span style="color: #ff7700;font-weight:bold;">return</span> reverse<span style="color: black;">&#40;</span><span style="color: #483d8b;">'form'</span>, <span style="color: #008000;">dict</span><span style="color: black;">&#40;</span>key=key, slug=slug<span style="color: black;">&#41;</span><span style="color: black;">&#41;</span><br /></td></tr><tr class="amc_code_even"><td class="amc_line"><div class="amc0"><div class="amc1"></div></div></td><td>...</td></tr></table></div>
