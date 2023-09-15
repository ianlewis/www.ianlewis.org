---
layout: post
title: "Django 勉強会 Disc.7"
date: 2009-01-16 21:34:38 +0000
permalink: /jp/django-disc-7
blog: jp
---

<p>昨日、<a href="http://accense.com/">アクセンス・テクノロジー</a>の東京本社に<a href="http://djangoproject.jp/etude/7/">Django 勉強会 Disc.7</a>に参加しに行ってきました。</p>

<h3>GeoDjango</h3>
<p>最初は<a href="http://twitter.com/tmatsuo">松尾さん</a>の<a href="http://geodjango.org/">geodjango</a>の話。</p>
<ul>
<li>GeoDjangoのDBサポートはpostgisが一番対応してます。</li>
<li>Adminで地形のエリア編集などは地図のJavascriptアプリで楽々</li>
<li>GeoDjangoのGeoManagerでfilter(field__poly_contains=point)ができる。</li>

</ul>

<h3>ContentType</h3>
<p>次は増田さんのGenericForeignKeyの話と、次に岡野さんのContentTypeの話</p>
<ul>
<li>GenericForeignKeyはContentTypeとobject_idのフィールドのラッパーに過ぎない</li>
<li>ContentTypeでModelの処理が結構一般的にできる(<a href="http://bitbucket.org/tokibito/sample_nullpobug/src/tip/django/ct_sample/">岡野さんのサンプルアプリ</a>)</li>
<li>ContentTypeManagerのget_for_model()と、ContentTypeのget_object_for_this_type()で色な面白いことができる。</li>
</ul>
<li>

<h3>モバイル</h3>
<p>次に、OpenIdの話と、最後に<a href="http://d.hatena.ne.jp/perezvon/">酒徳さん</a>の<a href="http://www.djangoproject.com/" title="Django">Django</a>でモバイルサイトの話</p>
<ul>
<li>モバイルの開発は大変</li>
<li>セッションを使わずにurlでフォームウィザードみたいなのを作るのがあり</li>
<li><a href="http://gu3.jp/">gumi</a>がよくできてる。</li>
</ul>

<h3>まとめ</h3>
<ul>
<li><a href="http://accense.com/">アクセンス・テクノロジー</a>の人たちに感謝</li>
<li>懇親会で酒徳さんと松尾さんといい話をして楽しかった</li>
<li>アクセンスから、かっこいい手帳をもらった。<br /><a href="http://farm4.static.flickr.com/3338/3201528890_28293f2266.jpg?v=0" rel="lightbox"><img src="http://farm4.static.flickr.com/3338/3201528890_28293f2266_m.jpg" title="アクセンス・テクノロジーfullflex手帳" alt="" /></a></li>
</ul>

参加したみんなさん、お疲れ様でした！</li>
<div class="sharethis">
        <script type="text/javascript" language="javascript">
          SHARETHIS.addEntry( {
            title : 'Django 勉強会 Disc.7',
              url   : 'http://www.ianlewis.org/jp/django-disc-7'}, 
            { button: true }
          ) ;
        </script></div>
