---
layout: post
title: "Twitter reply updates via e-mail"
date: 2008-08-09 19:10:52 +0000
permalink: /en/twitter-reply-updates-via-e-mail
blog: en
---

<p>I just set up <a href="http://www.plagger.org/" title="Plagger">Plagger</a> to send me e-mails to my cellphone and gmail when there are updates to my replies rss feed on twitter. This took way longer than anticipated because of how long it took to install and configure <a href="http://www.plagger.org/" title="Plagger">Plagger</a> properly.</p>
<p>First installing it took a long time. I installed it via cpan and <a href="http://www.plagger.org/" title="Plagger">Plagger</a> has a huge number of dependencies. Many of the dependencies are not set properly so cpan fails to install it more often then not. I had to force install the IO::Socket::SSL package because the tests failed. I didn't need TLS for mail and it's an optional package so I'm not sure why I needed SSL in the first place.</p>
<p>Once plagger was installed there isn't a terribly large amount of info about how to set it up. You basically have to create a config.yaml file in the same directory as the plagger executable or create a yaml file with any name and specify the location with the -c flag.</p>
<p>The yaml files configuration are easy to read but what options are available for each plugin is a bit obtuse without any examples to look at. There <a href="http://plagger.org/trac/browser/trunk/plagger/examples">are some</a> but it took me a while to find them since they aren't listed on the <a href="http://plagger.org/trac/wiki/PlaggerCookbook">plagger cookbook</a> which is linked to from the homepage. To find out what options are available to each plugin you'll either need to read the examples or the bottom of the <a href="http://plagger.org/trac/browser/trunk/plagger/lib/Plagger/Plugin">plugin's source code files</a> to get a description of what it does and it's options. I'm also not sure what all of the types of plugins do but I gather than Subsription plugins are plugins for reading RSS feeds and incoming data, Publish plugins are for publishing RSS feeds, email, html etc., and Filters are for parsing and/or modifying the data.</p>
<p>I used three Plugins to achieve what I wanted to do which was to get e-mail sent to my gmail account and my mobile. I used the Subscription::Config, Filter::HTMLScrubber, and Publish::<a href="http://www.google.com/mail/" title="Gmail">Gmail</a> plugins. The config plugin pulls from an rss feed and caches the results. It only passes on changes to the feed to other plugins. The <a href="http://www.google.com/mail/" title="Gmail">Gmail</a> plugin is essentially a SMTP/SMTP TLS plugin which sends e-mails when it gets updates from the subscription plugins. Unfortunately the version of the plugin that installed with cpan had a bug as it called the MIME::Lite::extract_addrs function which is not present on the machine where I was running plagger. I needed to update the <a href="http://www.google.com/mail/" title="Gmail">Gmail</a>.pm plugin file to the <a href="http://plagger.org/trac/browser/trunk/plagger/lib/Plagger/Plugin/Publish/Gmail.pm">newest version</a> in plagger's svn. That version includes a fix around like 214 to call the extract_full_addrs fuction if the extract_addrs fuction doesn't exist.</p>
<p>Next, my mobile doesn't support html mail very well so I had to scrub the HTML from the RSS feeds with the HTMLScrubber plugin. Unfortunately though the <a href="http://www.google.com/mail/" title="Gmail">Gmail</a> plugin sends e-mails as text/html encoded so I needed to further modify the <a href="http://www.google.com/mail/" title="Gmail">Gmail</a>.pm file to mail as text/plain around line 90.</p>
<p>After that the template file that is used to generate the e-mail, gmail_notify.tt, was missing so I needed to get <a href="http://plagger.org/trac/browser/trunk/plagger/assets/plugins/Publish-Gmail/gmail_notify.tt">that from svn as well</a> and I put it in my .cpan/assets/common directory and added that directory to the templates search path in my config.yaml. The contents of the template are also html so I needed to edit the template to remove all the html tags.</p>
<p>After that I just put config.yaml in the same directory as my plagger executable and added a line to execute plagger every 10 minutes to my crontab. This also had it's glitches as plagger prints debug and info messages to stderr so you can't just do "plagger &gt; /dev/null" you have to have something like "plagger &gt; /dev/null 2&gt;&amp;1" so that cron doesn't email you with plagger info messages every 10 minutes.</p>
<p>Anyway, after a few hours of messing with it, it finally worked. Here is the config.yaml I used.</p>
<div class="codeblock amc_yaml amc_short"><table><tr class="amc_code_odd"><td class="amc_line"><div class="amc1"></div></td><td>global:<br />
</td></tr><tr class="amc_code_even"><td class="amc_line"><div class="amc2"></div></td><td>&nbsp; assets_path: /home/&lt;myuser&gt;/.cpan/assets<br />
</td></tr><tr class="amc_code_odd"><td class="amc_line"><div class="amc3"></div></td><td>plugins:<br />
</td></tr><tr class="amc_code_even"><td class="amc_line"><div class="amc4"></div></td><td>&nbsp; - module: Subscription::Config<br />
</td></tr><tr class="amc_code_odd"><td class="amc_line"><div class="amc5"></div></td><td>&nbsp; &nbsp; config:<br />
</td></tr><tr class="amc_code_even"><td class="amc_line"><div class="amc6"></div></td><td>&nbsp; &nbsp; &nbsp; - feed:<br />
</td></tr><tr class="amc_code_odd"><td class="amc_line"><div class="amc7"></div></td><td>&nbsp; &nbsp; &nbsp; &nbsp; url: <a href="http://IanMLewis:&lt;twitterpassword&gt;@twitter.com/statuses/replies.rss">http://IanMLewis:&lt;twitterpassword&gt;@twitter.com/statuses/replies.rss</a><br />
</td></tr><tr class="amc_code_even"><td class="amc_line"><div class="amc8"></div></td><td><br />
</td></tr><tr class="amc_code_odd"><td class="amc_line"><div class="amc9"></div></td><td>&nbsp; - module: Filter::HTMLScrubber<br />
</td></tr><tr class="amc_code_even"><td class="amc_line"><div class="amc0"><div class="amc1"></div></div></td><td>&nbsp; &nbsp; config:<br />
</td></tr><tr class="amc_code_odd"><td class="amc_line"><div class="amc1"><div class="amc1"></div></div></td><td>&nbsp; &nbsp; &nbsp; comment: 0<br />
</td></tr><tr class="amc_code_even"><td class="amc_line"><div class="amc2"><div class="amc1"></div></div></td><td><br />
</td></tr><tr class="amc_code_odd"><td class="amc_line"><div class="amc3"><div class="amc1"></div></div></td><td>&nbsp; - module: Publish::<a href="http://www.google.com/mail/" title="Gmail">Gmail</a><br />
</td></tr><tr class="amc_code_even"><td class="amc_line"><div class="amc4"><div class="amc1"></div></div></td><td>&nbsp; &nbsp; config:<br />
</td></tr><tr class="amc_code_odd"><td class="amc_line"><div class="amc5"><div class="amc1"></div></div></td><td>&nbsp; &nbsp; &nbsp; mailto: &nbsp; &lt;me&gt;@gmail.com, &lt;mobile e-mail&gt;<br />
</td></tr><tr class="amc_code_even"><td class="amc_line"><div class="amc6"><div class="amc1"></div></div></td><td>&nbsp; &nbsp; &nbsp; mailfrom: <a href="mailto:twitter@ianlewis.org">twitter@ianlewis.org</a><br />
</td></tr><tr class="amc_code_odd"><td class="amc_line"><div class="amc7"><div class="amc1"></div></div></td><td>&nbsp; &nbsp; &nbsp; mailroute:<br />
</td></tr><tr class="amc_code_even"><td class="amc_line"><div class="amc8"><div class="amc1"></div></div></td><td>&nbsp; &nbsp; &nbsp; &nbsp; via: smtp<br />
</td></tr><tr class="amc_code_odd"><td class="amc_line"><div class="amc9"><div class="amc1"></div></div></td><td>&nbsp; &nbsp; &nbsp; &nbsp; host: localhost:26<br />
</td></tr><tr class="amc_code_even"><td class="amc_line"><div class="amc0"><div class="amc2"></div></div></td><td>&nbsp; &nbsp; &nbsp; &nbsp; username: &lt;local mail user&gt;<br />
</td></tr><tr class="amc_code_odd"><td class="amc_line"><div class="amc1"><div class="amc2"></div></div></td><td>&nbsp; &nbsp; &nbsp; &nbsp; password: &lt;local mail password&gt;</td></tr></table></div>
<div class="sharethis">
        <script type="text/javascript" language="javascript">
          SHARETHIS.addEntry( {
            title : 'Twitter reply updates via e-mail',
              url   : 'http://www.ianlewis.org/en/twitter-reply-updates-via-e-mail'}, 
            { button: true }
          ) ;
        </script></div>
