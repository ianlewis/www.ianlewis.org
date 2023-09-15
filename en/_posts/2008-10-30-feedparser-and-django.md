---
layout: post
title: "Feedparser and Django"
date: 2008-10-30 19:13:52 +0000
permalink: /en/feedparser-and-django
blog: en
---

<p>Over the weekend at <a href="http://www.python.org/" title="Python">Python</a> Onsen I worked on a lifestream web application using <a href="http://www.djangoproject.com/" title="Django">Django</a> and <a href="http://www.feedparser.org/">feedparser</a>. I was really impressed with how simple feedparser is to use and how easy it is to get unified results from atom or rss feeds. You simply import feedparser and call feedparser.parse to parse a feed from a url.</p>
feeds.py
<div class="codeblock amc_python amc_short"><table><tr class="amc_code_odd"><td class="amc_line"><div class="amc1"></div></td><td>...<br /></td></tr><tr class="amc_code_even"><td class="amc_line"><div class="amc2"></div></td><td><span style="color: #ff7700;font-weight:bold;">def</span> update_feeds<span style="color: black;">&#40;</span><span style="color: black;">&#41;</span>:<br /></td></tr><tr class="amc_code_odd"><td class="amc_line"><div class="amc3"></div></td><td>&nbsp; feeds = Feed.<span style="color: black;">objects</span>.<span style="color: #008000;">filter</span><span style="color: black;">&#40;</span>feed_deleted=<span style="color: #008000;">False</span><span style="color: black;">&#41;</span><br /></td></tr><tr class="amc_code_even"><td class="amc_line"><div class="amc4"></div></td><td>&nbsp; <span style="color: #ff7700;font-weight:bold;">for</span> feed <span style="color: #ff7700;font-weight:bold;">in</span> feeds:<br /></td></tr><tr class="amc_code_odd"><td class="amc_line"><div class="amc5"></div></td><td>&nbsp; &nbsp; <span style="color: #ff7700;font-weight:bold;">try</span>:<br /></td></tr><tr class="amc_code_even"><td class="amc_line"><div class="amc6"></div></td><td>&nbsp; &nbsp; &nbsp; feed_items = feedparser.<span style="color: black;">parse</span><span style="color: black;">&#40;</span>feed.<span style="color: black;">feed_url</span><span style="color: black;">&#41;</span><br /></td></tr><tr class="amc_code_odd"><td class="amc_line"><div class="amc7"></div></td><td>&nbsp; &nbsp; &nbsp; <span style="color: #ff7700;font-weight:bold;">for</span> entry <span style="color: #ff7700;font-weight:bold;">in</span> feed_items<span style="color: black;">&#91;</span><span style="color: #483d8b;">'entries'</span><span style="color: black;">&#93;</span>:<br /></td></tr><tr class="amc_code_even"><td class="amc_line"><div class="amc8"></div></td><td>...</td></tr></table></div>

<p>You can check out feeds.py <a href="http://bitbucket.org/IanLewis/django-lifestream/src/a64fcf2090a1/dlife/lifestream/feeds.py">here</a>.</p>

<p>The interesting bit comes with how I had to parse the dates which sometimes include timezone info and other goodies. In my search for a solution to the problem of how to deal with dates in various formats I turned came across this <a href="http://www.deadlybloodyserious.com/2007/09/feedparser-v-django/">blog entry</a> which describes the problem and some possible solutions. The solution I used was the simplest and most robust (please skip the comments talking about taking a slice of the date string). I used mikael's suggestion from the comments and used the dateutil.parser to parse the date string into a proper datetime object.</p>

<div class="codeblock amc_python amc_short"><table><tr class="amc_code_odd"><td class="amc_line"><div class="amc1"></div></td><td><span style="color: #808080; font-style: italic;"># Parse to an actual datetime object</span><br /></td></tr><tr class="amc_code_even"><td class="amc_line"><div class="amc2"></div></td><td>date_published = dateutil.<span style="color: #dc143c;">parser</span>.<span style="color: black;">parse</span><span style="color: black;">&#40;</span>date_published<span style="color: black;">&#41;</span></td></tr></table></div>

<p>This however leaves timezone info on the timestamp which isn't supported by mysql so I hand rolled some code convert the timestamp to utc and remove the timezone info.</p>

<div class="codeblock amc_python amc_short"><table><tr class="amc_code_odd"><td class="amc_line"><div class="amc1"></div></td><td><span style="color: #808080; font-style: italic;"># Change the date to UTC and remove timezone info since MySQL doesn't</span><br /></td></tr><tr class="amc_code_even"><td class="amc_line"><div class="amc2"></div></td><td><span style="color: #808080; font-style: italic;"># support it</span><br /></td></tr><tr class="amc_code_odd"><td class="amc_line"><div class="amc3"></div></td><td>date_published = <span style="color: black;">&#40;</span>date_published - date_published.<span style="color: black;">utcoffset</span><span style="color: black;">&#40;</span><span style="color: black;">&#41;</span><span style="color: black;">&#41;</span>.<span style="color: black;">replace</span><span style="color: black;">&#40;</span>tzinfo=<span style="color: #008000;">None</span><span style="color: black;">&#41;</span></td></tr></table></div>

<p>I'm not sure this works in all situations yet so I might go with something like <a href="http://intertwingly.net/blog/2007/09/02/Dealing-With-Dates">how another commenter solved the problem</a> by converting feedparsers parsed date to a utc timestamp before converting to a datetime object. I think either way would work but which is cleaner and less prone to breakage, I'm not sure.</p>
<div class="sharethis">
        <script type="text/javascript" language="javascript">
          SHARETHIS.addEntry( {
            title : 'Feedparser and Django',
              url   : 'http://www.ianlewis.org/en/feedparser-and-django'}, 
            { button: true }
          ) ;
        </script></div>
