---
layout: post
title: "IE, JSON, and the script tag"
date: 2009-02-14 13:34:57 +0000
permalink: /en/ie-json-and-the-lscriptg-tagl-scriptg
blog: en
tags: javascript json ie xss
render_with_liquid: false
---

<p>My coworker recently introduced me to one of the most blatantly bad behaviors in web browser history. He introduced it thus:</p>

<div class="codeblock amc_python amc_short"><table><tr class="amc_code_odd"><td class="amc_line"><div class="amc1"></div></td><td>Out<span style="color: black;">&#91;</span><span style="color: #ff4500;">1</span><span style="color: black;">&#93;</span>: simplejson.<span style="color: black;">dumps</span><span style="color: black;">&#40;</span><span style="color: black;">&#123;</span><span style="color: #483d8b;">'foo'</span>: <span style="color: #483d8b;">'&lt;script&gt;alert(document.cookie);&lt;/script&gt;'</span><span style="color: black;">&#125;</span><span style="color: black;">&#41;</span><br /></td></tr><tr class="amc_code_even"><td class="amc_line"><div class="amc2"></div></td><td>Out<span style="color: black;">&#91;</span><span style="color: #ff4500;">2</span><span style="color: black;">&#93;</span>: <span style="color: #483d8b;">'{&quot;foo&quot;: &quot;&lt;script&gt;alert(document.cookie);&lt;/script&gt;&quot;}'</span></td></tr></table></div>

<p>The thing is, that there is nothing wrong with what simplejson is doing. The problem is that this little piece of json is not handled properly in IE and IE actually executes the javascript in the script tag regardless of the fact that it's inside a string. This can leave an application wide open to XSS attacks. IE seems to do this for at least the text/plain mime-type.</p>
