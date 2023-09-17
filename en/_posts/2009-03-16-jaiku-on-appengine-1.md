---
layout: post
title: "Jaiku on Appengine"
date: 2009-03-16 00:52:31 +0000
permalink: /en/jaiku-on-appengine-1
blog: en
tags: appengine
render_with_liquid: false
---

<p><a href="/assets/images/516/jaiku.png"><img src="https://storage.googleapis.com/static.ianlewis.org/prod/img/516/jaiku.png" /></a></p>

<p>Yesterday <a href="http://www.google.com/">Google</a>'s <a href="http://www.twitter.com/">Twitter</a>-like service, <a href="http://www.jaiku.com/">Jaiku</a> was released as <a href="http://code.google.com/p/jaikuengine/">open source</a> running on <a href="http://code.google.com/appengine/">Google Appengine</a> so I decided to take it for a spin. It has a lot of neat parts like XMPP and google contacts integration, but what I'm interested in most is how it implements it's publisher/subscriber model.</p>

<p>I brought the code down from svn and tried to follow the instructions, but I got a "No module named django" error. One of the problems currently with appengine is that you have a limit of 1000 files you can upload. Because of this limit when deploying jaiku you need to zip a bunch of libraries into a zip file and use zipimport. Accordingly you have to prevent the source files from being uploaded because you get an error saying you can't upload more than 1000 files.</p>

<p>The problem there is that the newest (1.1.9) SDK prevents you from loading modules and/or accessing files that are specified in the skip-files directive in your app.yaml. This prevented me from importing django because it's a zipped module.</p>

<p>At first I tried just zipping the files up using the zip_all command in the Makefile (make zip_all) but I still got the same error so I just commented out the relevant parts in app.yaml.</p>

<div class="codeblock amc_yaml amc_long"><table><tr class="amc_code_odd"><td class="amc_line"><div class="amc1"></div></td><td>skip_files: |<br />
</td></tr><tr class="amc_code_even"><td class="amc_line"><div class="amc2"></div></td><td>&nbsp;^(.*/)?(<br />
</td></tr><tr class="amc_code_odd"><td class="amc_line"><div class="amc3"></div></td><td>&nbsp;(app\.yaml)|<br />
</td></tr><tr class="amc_code_even"><td class="amc_line"><div class="amc4"></div></td><td>&nbsp;(app\.yml)|<br />
</td></tr><tr class="amc_code_odd"><td class="amc_line"><div class="amc5"></div></td><td>&nbsp;(index\.yaml)|<br />
</td></tr><tr class="amc_code_even"><td class="amc_line"><div class="amc6"></div></td><td>&nbsp;(index\.yml)|<br />
</td></tr><tr class="amc_code_odd"><td class="amc_line"><div class="amc7"></div></td><td>&nbsp;(#.*#)|<br />
</td></tr><tr class="amc_code_even"><td class="amc_line"><div class="amc8"></div></td><td>&nbsp;(.*~)|<br />
</td></tr><tr class="amc_code_odd"><td class="amc_line"><div class="amc9"></div></td><td>&nbsp;(.*\.py[co])|<br />
</td></tr><tr class="amc_code_even"><td class="amc_line"><div class="amc0"><div class="amc1"></div></div></td><td>&nbsp;(.*/RCS/.*)|<br />
</td></tr><tr class="amc_code_odd"><td class="amc_line"><div class="amc1"><div class="amc1"></div></div></td><td>&nbsp;# (\..*)|<br />
</td></tr><tr class="amc_code_even"><td class="amc_line"><div class="amc2"><div class="amc1"></div></div></td><td>&nbsp;# (manage.py)|<br />
</td></tr><tr class="amc_code_odd"><td class="amc_line"><div class="amc3"><div class="amc1"></div></div></td><td>&nbsp;# (google_appengine.*)|<br />
</td></tr><tr class="amc_code_even"><td class="amc_line"><div class="amc4"><div class="amc1"></div></div></td><td>&nbsp;# (simplejson/.*)|<br />
</td></tr><tr class="amc_code_odd"><td class="amc_line"><div class="amc5"><div class="amc1"></div></div></td><td>&nbsp;# (gdata/.*)|<br />
</td></tr><tr class="amc_code_even"><td class="amc_line"><div class="amc6"><div class="amc1"></div></div></td><td>&nbsp;# (atom/.*)|<br />
</td></tr><tr class="amc_code_odd"><td class="amc_line"><div class="amc7"><div class="amc1"></div></div></td><td>&nbsp;# (tlslite/.*)|<br />
</td></tr><tr class="amc_code_even"><td class="amc_line"><div class="amc8"><div class="amc1"></div></div></td><td>&nbsp;# (oauth/.*)|<br />
</td></tr><tr class="amc_code_odd"><td class="amc_line"><div class="amc9"><div class="amc1"></div></div></td><td>&nbsp;# (beautifulsoup/.*)|<br />
</td></tr><tr class="amc_code_even"><td class="amc_line"><div class="amc0"><div class="amc2"></div></div></td><td>&nbsp;# (django/.*)|<br />
</td></tr><tr class="amc_code_odd"><td class="amc_line"><div class="amc1"><div class="amc2"></div></div></td><td>&nbsp;# (docutils/.*)|<br />
</td></tr><tr class="amc_code_even"><td class="amc_line"><div class="amc2"><div class="amc2"></div></div></td><td>&nbsp;# (epydoc/.*)|<br />
</td></tr><tr class="amc_code_odd"><td class="amc_line"><div class="amc3"><div class="amc2"></div></div></td><td>&nbsp;# (appengine_django/management/commands/.*)|<br />
</td></tr><tr class="amc_code_even"><td class="amc_line"><div class="amc4"><div class="amc2"></div></div></td><td>&nbsp;# (README)|<br />
</td></tr><tr class="amc_code_odd"><td class="amc_line"><div class="amc5"><div class="amc2"></div></div></td><td>&nbsp;# (CHANGELOG)|<br />
</td></tr><tr class="amc_code_even"><td class="amc_line"><div class="amc6"><div class="amc2"></div></div></td><td>&nbsp;# (Makefile)|<br />
</td></tr><tr class="amc_code_odd"><td class="amc_line"><div class="amc7"><div class="amc2"></div></div></td><td>&nbsp;# (bin/.*)|<br />
</td></tr><tr class="amc_code_even"><td class="amc_line"><div class="amc8"><div class="amc2"></div></div></td><td>&nbsp;# (images/ads/.*)|<br />
</td></tr><tr class="amc_code_odd"><td class="amc_line"><div class="amc9"><div class="amc2"></div></div></td><td>&nbsp;# (images/ext/.*)|<br />
</td></tr><tr class="amc_code_even"><td class="amc_line"><div class="amc0"><div class="amc3"></div></div></td><td>&nbsp;# (wsgiref/.*)|<br />
</td></tr><tr class="amc_code_odd"><td class="amc_line"><div class="amc1"><div class="amc3"></div></div></td><td>&nbsp;# (elementtree/.*)|<br />
</td></tr><tr class="amc_code_even"><td class="amc_line"><div class="amc2"><div class="amc3"></div></div></td><td>&nbsp;# (doc/.*)|<br />
</td></tr><tr class="amc_code_odd"><td class="amc_line"><div class="amc3"><div class="amc3"></div></div></td><td>&nbsp;# (profiling/.*)<br />
</td></tr><tr class="amc_code_even"><td class="amc_line"><div class="amc4"><div class="amc3"></div></div></td><td>&nbsp;)$</td></tr></table></div>

<p>From there it should have worked but I got an error about the pstats module. That just happened to not be installed on my machine so installed python-profiler and Jaiku ran from there.</p>
