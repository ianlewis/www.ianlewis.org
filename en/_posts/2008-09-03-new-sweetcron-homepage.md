---
layout: post
title: "New Sweetcron Homepage"
date: 2008-09-03 22:02:39 +0000
permalink: /en/new-sweetcron-homepage
blog: en
tags: php rss sweetcron yongfook
render_with_liquid: false
---

<p><img title="Sweetcron" src="/system/application/views/themes/boxy_but_good/images/credits.gif" alt="Sweetcron" width="170" height="25" /></p>
<p>I just finished implementing <a href="http://sweetcron.com/">sweetcron</a> on my homepage. It's a pretty architecturally bare-bones but slick feed aggregator that makes a page containing all the most current information about you or what your are interested in. This page is called a "lifestream" and I liked the concept because I'm a busy person and I want to make publishing to my homepage easier so that it doesn't become dusty and so I don't have to create blog posts on anything and everything just to get a blurb on my homepage.</p>
<p>It basically aggregates feeds and puts the entries in your lifestream. Your twitter, digg links, blog entries can all end up in the same place. nice. It includes some basic blogging functionality but it's pretty lame and I have too much invested in b2evo to give it up so I stuck with that for my blogging. I just simply import my blog RSS feeds into sweetcron.</p>
<p>Sweetcron is made by <a href="http://www.yongfook.com/">Yongfook</a>, a local web consultant here in Tokyo. I find him a bit pretentious but he seems quite popular. He has a habit of <a href="http://www.yongfook.com/post/view/463/time-stormtroopers-iphone-blam">singing in</a> <a href="http://www.yongfook.com/post/view/508/sneak-preview-of-the-sweetcron-admin-panel-bit">video blog posts</a> and speaking in a voice that feels to outlandish to be real. But for any faults he might have he seems to be successful and competent at consulting.</p>
<p>His programming could be better though. I'm glad he made Sweetcron because it allowed me to do something I had been wanting to do for a while, but it required a bit of programming to get working properly. It has a few bugs and the default install is pretty unusable. It's written using codeigniter which is ok but sweetcron doesn't support some of it's features properly. For instance, using the database table prefix causes sweetcron to throw SQL errors. His codeigniter templates are simply PHP code files which I don't like because they end up being programs themselves and don't separate logic and presentation very well. Codeigniter has it's <a href="http://codeigniter.com/user_guide/libraries/parser.html">own templates</a> but they're lame so I kind of wish he used <a href="http://www.smarty.net/">Smarty</a> which I've had good experience with.</p>
<p>That said it was still pretty easy to implement and get integrated with the <a href="http://www.b2evolution.net/" title="b2evolution">b2evolution</a> site and I'm pleased with the results.</p>
<div class="sharethis">
        <script type="text/javascript" language="javascript">
          SHARETHIS.addEntry( {
            title : 'New Sweetcron Homepage',
              url   : 'http://www.ianlewis.org/en/new-sweetcron-homepage'}, 
            { button: true }
          ) ;
        </script></div>
