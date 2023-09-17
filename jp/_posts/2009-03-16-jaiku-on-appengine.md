---
layout: post
title: "Jaikuを動かしてみた"
date: 2009-03-16 00:30:34 +0000
permalink: /jp/jaiku-on-appengine
blog: jp
tags: appengine
render_with_liquid: false
---

<p><a href="/assets/images/516/jaiku.png"><img src="https://storage.googleapis.com/static.ianlewis.org/prod/img/516/jaiku.png" /></a></p>

<p>昨日、<a href="http://www.google.co.jp/">Google</a>の<a href="http://www.twitter.com/">Twitter</a>ライクなサービス、<a href="http://www.jaiku.com/">Jaiku</a>が<a href="http://code.google.com/p/jaikuengine/">オープンソース</a>になって、<a href="http://code.google.com/intl/ja/appengine/">Google Appengine</a>に移動することに</p>

<p>早速、コードを落として、動かしてみた。</p>

<p>doc/README に入ってる手順(重要なのはlocal_settings.example.pyをlocal_settings.pyにコピー)にしたがってやってたんだけど、最初に動かそうとして、No module named djangoってエラーが出た。何だこれ！って思ったけど、ファイル数が多すぎて、deployする時にzipimport使ってる。さらに、Appengine SDK 1.1.9がapp.yamlにskip-filesに入ってるファイルにアクセスすることを拒否することになったので、ちゃんとzipにしないと動かない。Makefileにzip_allのコマンドはあるので、make zip_allで起動できるはずなのに、なぜか、同じくNo module named djangoがでた。</p>

<p>でも、どうせにzipimportで、エラーがでたら、tracebackもでないし、俺は結局、app.yamlいじりました。</p>

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

<p>これでようやく動くはずなのに、またエラーが出たけど、今回はpstatsのエラーで、python-profileのパッケージを入れて、解決した。</p>
