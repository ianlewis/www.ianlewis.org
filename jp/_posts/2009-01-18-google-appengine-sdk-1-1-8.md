---
layout: post
title: "Google Appengine SDK 1.1.8がリリースされました"
date: 2009-01-18 11:45:59 +0000
permalink: /jp/google-appengine-sdk-1-1-8
blog: jp
tags: python appengine django
render_with_liquid: false
---

<p>Appengineの新しいリリース1.1.8が来た。色な面白いところがあるけど、仲居さん(id:<a href="http://d.hatena.ne.jp/Voluntas/">Voluntas</a>)の<a href="http://d.hatena.ne.jp/Voluntas/20090117/1232209649">ブログポスト</a>からピックアップする。</p>

<blockquote>
<ul>
<li>ByteStringProperty が実装 気軽に使える BlobProperty</li>
<li>UserProperty に auto_current_user / auto_current_user_add が追加。
  <ul>
    <li>DateTimeProperty と同じ動作すると思われ。</li>
  </ul>
</li>
<li>PolyModel が追加されました。
  <ul>
    <li><a href="http://www.djangoproject.com/" title="Django">Django</a> の継承と一緒、使い方は簡単です。</li>
  </ul>
<div class="codeblock amc_python amc_short"><table><tr class="amc_code_odd"><td class="amc_line"><div class="amc1"></div></td><td><span style="color: #ff7700;font-weight:bold;">from</span> google.<span style="color: black;">appengine</span>.<span style="color: black;">ext</span> <span style="color: #ff7700;font-weight:bold;">import</span> db<br /></td></tr><tr class="amc_code_even"><td class="amc_line"><div class="amc2"></div></td><td><span style="color: #ff7700;font-weight:bold;">from</span> google.<span style="color: black;">appengine</span>.<span style="color: black;">ext</span>.<span style="color: black;">db</span> <span style="color: #ff7700;font-weight:bold;">import</span> polymodel<br /></td></tr><tr class="amc_code_odd"><td class="amc_line"><div class="amc3"></div></td><td><br /></td></tr><tr class="amc_code_even"><td class="amc_line"><div class="amc4"></div></td><td><span style="color: #ff7700;font-weight:bold;">class</span> Entity<span style="color: black;">&#40;</span>polymodel.<span style="color: black;">PolyModel</span><span style="color: black;">&#41;</span>:<br /></td></tr><tr class="amc_code_odd"><td class="amc_line"><div class="amc5"></div></td><td>&nbsp; created = db.<span style="color: black;">DateTimeProperty</span><span style="color: black;">&#40;</span><span style="color: black;">&#41;</span><br /></td></tr><tr class="amc_code_even"><td class="amc_line"><div class="amc6"></div></td><td><br /></td></tr><tr class="amc_code_odd"><td class="amc_line"><div class="amc7"></div></td><td><span style="color: #ff7700;font-weight:bold;">class</span> Status<span style="color: black;">&#40;</span>Entity<span style="color: black;">&#41;</span>:<br /></td></tr><tr class="amc_code_even"><td class="amc_line"><div class="amc8"></div></td><td>&nbsp; message = db.<span style="color: black;">StringProperty</span><span style="color: black;">&#40;</span><span style="color: black;">&#41;</span><br /></td></tr><tr class="amc_code_odd"><td class="amc_line"><div class="amc9"></div></td><td><br /></td></tr><tr class="amc_code_even"><td class="amc_line"><div class="amc0"><div class="amc1"></div></div></td><td><span style="color: #ff7700;font-weight:bold;">class</span> Clip<span style="color: black;">&#40;</span>Entity<span style="color: black;">&#41;</span>:<br /></td></tr><tr class="amc_code_odd"><td class="amc_line"><div class="amc1"><div class="amc1"></div></div></td><td>&nbsp; url = db.<span style="color: black;">StringProperty</span><span style="color: black;">&#40;</span><span style="color: black;">&#41;</span></td></tr></table></div>
</li>
<li>Image API に width/height が実装されました</li>
<li>db.Model.order() にて __key__ のソートが出来るようになりました。bugfix</li>
</ul>
</blockquote>

<p>僕が気になったところがもう一個あるんだけど、このリリースにて、antlr3というモジュールが必須となった。1.1.8をインストールして動かそうたしたら、</p>
<blockquote>
ImportError: No module named antlr3
</blockquote>
<p>が出てきた。理由はappengine_djangoを使ってること。appengine_djangoはgoogle_appengine/lib/antlr3のモジュールをインポートしてなかったので、エラーが出てきた。appengine_djangoのSVNの最新版を使えば、解決する。</p>

<p>何で、antlr3が必要になったというと、実際コード見ると、google_appengine/google/appengine/cronで、groc.py, GrocLexer.py, GrocParser.pyがある。grocというcronみたいなサービスがもうすぐ出るかもしれないね。GrocLexer.pyとGrocParser.pyはantlr3を使ってcronの時間設定文字列を解析するパーサーだという。面白い。</p>
