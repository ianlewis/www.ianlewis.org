---
layout: post
title: "GAE Hackathon Disc. 3 全文検索"
date: 2009-04-11 20:46:13 +0000
permalink: /jp/gae-hackathon-disc-3-jp
blog: jp
tags: python google appengine 全文検索 text search
render_with_liquid: false
locale: ja
---

<p><a href="http://code.google.com/appengine/" title="Google App Engine">GAE</a> Hackathon Disc. 3 に参加してきました！ 私と<a href="http://d.hatena.ne.jp/a2c/">id:a2c</a> (<a href="http://twitter.com/atusi">Twitter</a>) が<a href="http://www.google.com/" title="Google">Google</a> <a href="http://code.google.com/appengine/" title="Appengine">Appengine</a>の日本語が対応する全文検索エンジンを作ってみました。</p>

<p><a href="http://code.google.com/appengine/" title="Google App Engine">GAE</a> では、データストアが Entity と言う概念で作られてるけど、Entityを検索する時に、データを完全一致しないと、データを取れないので、全文検索が難しくて、以下の状況になってる。</p>
<ul>
<li>一応、<a href="http://code.google.com/p/googleappengine/source/browse/trunk/python/google/appengine/ext/search/__init__.py#287">SearchableModel</a>というクラスを継承すれば、英文検索が出来るけど、日本語テキスト検索が全くできない。（英語でも結構ひどい)</li>
<li>SearchModelで、英語検索しても、スペース文字で単語単位で切るので、単語を完全一致しないといけない。（つまり、informationがテキストに入ってるけど、infoで検索しても出てこない）</li>
<li>SearchableModelでは、3文字以下の単語はインデクスしてくれないので、ほとんどの日本語はアウト</li>
<li>上の点の関係で、3文字以下の検索キーワードもアウト</li>
<li>検索キーワードが無視された場合、何でも、引っかかるので、検索結果が分かりにくい</li>
</ul>

<p>a2cさんが以前に、いろいろ調べたり、試してみたりしてくれたので、いろいろ助かった。いい情報を取れたので、すごくいい話が当日にできました。</p>

<ul>
<li><a href="http://d.hatena.ne.jp/a2c/20090409/1239209449">GAEのAPI1.2で追加になったCronを使って転置インデックスの更新をしてみる</a></li>
<li><a href="http://d.hatena.ne.jp/a2c/20090407/1239086203">GAE ハカソン事前MTG</a></li>
<li><a href="http://d.hatena.ne.jp/a2c/20090402/1238608082">GoogleAppEngineのReq/Sec計って見た</a></li>
<li><a href="http://d.hatena.ne.jp/a2c/20090401/1238579242">gae上でDataStore使わずにmemcacheで転置インデックス作ってみた。</a></li>
<li><a href="http://d.hatena.ne.jp/a2c/20090331/1238464001">GoogleAppEngineのサーバサイドの処理時間をProfileで表示させる為にcProfile使う</a></li>
<li><a href="http://d.hatena.ne.jp/a2c/20090326/1238000082">GAEのDatastoreが順調に肥大中</a></li>
</ul>

<p>SearchableModelのAPIは基本的にいいと思ったので、SearchableModelと同じように、日本語対応できるSearchableModelを使いたいなと思いました。こう書けば、わりと簡単に検索できる。</p>

<div class="codeblock amc_python amc_short"><table><tr class="amc_code_odd"><td class="amc_line"><div class="amc1"></div></td><td><span style="color: #ff7700;font-weight:bold;">from</span> google.<span style="color: black;">appengine</span>.<span style="color: black;">ext</span>.<span style="color: black;">search</span> <span style="color: #ff7700;font-weight:bold;">import</span> SearchableModel<br /></td></tr><tr class="amc_code_even"><td class="amc_line"><div class="amc2"></div></td><td><span style="color: #ff7700;font-weight:bold;">from</span> google.<span style="color: black;">appengine</span>.<span style="color: black;">ext</span>.<span style="color: black;">db</span> <span style="color: #ff7700;font-weight:bold;">import</span> <span style="color: #66cc66;">*</span><br /></td></tr><tr class="amc_code_odd"><td class="amc_line"><div class="amc3"></div></td><td><br /></td></tr><tr class="amc_code_even"><td class="amc_line"><div class="amc4"></div></td><td><span style="color: #ff7700;font-weight:bold;">class</span> Document<span style="color: black;">&#40;</span>SearchableModel<span style="color: black;">&#41;</span>:<br /></td></tr><tr class="amc_code_odd"><td class="amc_line"><div class="amc5"></div></td><td>&nbsp; title = StringProperty<span style="color: black;">&#40;</span>u<span style="color: #483d8b;">&quot;Title&quot;</span><span style="color: black;">&#41;</span><br /></td></tr><tr class="amc_code_even"><td class="amc_line"><div class="amc6"></div></td><td>&nbsp; text = TextProperty<span style="color: black;">&#40;</span>u<span style="color: #483d8b;">&quot;Body Text&quot;</span><span style="color: black;">&#41;</span></td></tr></table></div>

<div class="codeblock amc_python amc_short"><table><tr class="amc_code_odd"><td class="amc_line"><div class="amc1"></div></td><td>...<br /></td></tr><tr class="amc_code_even"><td class="amc_line"><div class="amc2"></div></td><td><span style="color: black;">Document</span>.<span style="color: black;">all</span><span style="color: black;">&#40;</span><span style="color: black;">&#41;</span>.<span style="color: black;">search</span><span style="color: black;">&#40;</span><span style="color: #dc143c;">keyword</span><span style="color: black;">&#41;</span><br /></td></tr><tr class="amc_code_odd"><td class="amc_line"><div class="amc3"></div></td><td>...</td></tr></table></div>

<p>まず、SearchableModelがいろいろ、自分を参照したので、継承するのが難しかったから、別のモジュールにコピーして、forkすることにした。それで、<a href="http://bitbucket.org/a2c/gaehackathon_misopotato/src/e26dda1c611c/saichugen/ian/search/__init__.py#cl-195">この辺</a>に単語の分け方を a2cが作ってくれた <a href="http://bitbucket.org/a2c/gaehackathon_misopotato/src/e26dda1c611c/saichugen/a2c/n_gram.py#cl-1">ngram実装</a>に切り替えた。(<a href="http://d.hatena.ne.jp/keyword/N-gram">ngramとは？</a>)　それで、SearchableModelのモジュールを変えるだけで、googleの実装と同じように使える。</p>

<p>検索キーワードをngramで分けて、インデクスを検索すると、ちゃんと部分的にデータが引っ張ってくる。 <a href="http://saichugen.appspot.com/">http://saichugen.appspot.com/</a> でテストアプリを見れる。コードは<a href="http://bitbucket.org/a2c/gaehackathon_misopotato/">bitbucket</a>で公開されてる。</p>

<p>これから、a2cさんともっと検索結果を取れるようにするのと、インデクスの容量をへらしたりするのと、分け方を自分で実装できるapiを導入したいと思うので、ぜひ期待してください
