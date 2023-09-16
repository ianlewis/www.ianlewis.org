---
layout: post
title: "Twitter Page Code"
date: 2008-06-19 19:14:11 +0000
permalink: /en/twitter-page-code
blog: en
render_with_liquid: false
---

<p><img src="http://static.ianlewis.org/prod/img/gallery/twitter.png" alt="Twitter" /></p>
<p>I took a look at <a href="http://www.twitter.com/" title="Twitter">Twitter</a>'s code as an example of a site that gets lots of traffic and noticed a couple things.</p>
<ol>
<li>They use <a href="http://www.amazon.com/gp/browse.html?node=16427261">Amazon S3</a> to store images</li>
<li>They split the javascript, favicons, and css up across 3 or 4 subdomains (assets0.twitter.com, assets2.twitter.com, etc.)</li>
<li>They include <a href="http://www.prototypejs.org/">prototype</a> and a version of <a href="http://jquery.com/">jQuery</a> as well as a version of <a href="http://script.aculo.us/">script.aculo.us</a>.<div class="codeblock amc_html amc_short"><table><tr class="amc_code_odd"><td class="amc_line"><div class="amc1"></div></td><td>&lt;script src=&quot;http://assets3.twitter.com/javascripts/prototype.js?1213829093&quot; type=&quot;text/javascript&quot;&gt;&lt;/script&gt;<br />
</td></tr><tr class="amc_code_even"><td class="amc_line"><div class="amc2"></div></td><td>&lt;script src=&quot;http://assets1.twitter.com/javascripts/effects.js?1213829093&quot; type=&quot;text/javascript&quot;&gt;&lt;/script&gt;<br />
</td></tr><tr class="amc_code_odd"><td class="amc_line"><div class="amc3"></div></td><td><br />
</td></tr><tr class="amc_code_even"><td class="amc_line"><div class="amc4"></div></td><td>&lt;script src=&quot;http://assets0.twitter.com/javascripts/application.js?1213829093&quot; type=&quot;text/javascript&quot;&gt;&lt;/script&gt;<br />
</td></tr><tr class="amc_code_odd"><td class="amc_line"><div class="amc5"></div></td><td>&lt;script src=&quot;http://assets0.twitter.com/javascripts/jquery-1.2.3.min.js?1213829093&quot; type=&quot;text/javascript&quot;&gt;&lt;/script&gt;</td></tr></table></div></li>
</ol>

<p>It kind of surprised me that they include a version of prototype <em>AND</em> <a href="http://jquery.com/" title="jQuery">jQuery</a> <em>AND</em> script.aculo.us since they aren't really light javascript files. Prototype comes in at 123kb, <a href="http://jquery.com/" title="jQuery">jQuery</a> is 53kb, and script.aculo.us is 38kb. Seems to me that even with caching and all they could significantly reduce download traffic by sticking to one javascript library. I'm sure there is some wierd reason they do it though.</p>
