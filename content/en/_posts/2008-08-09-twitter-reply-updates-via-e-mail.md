---
layout: post
title: "Twitter reply updates via e-mail"
date: 2008-08-09 19:10:52 +0000
permalink: /en/twitter-reply-updates-via-e-mail
blog: en
tags: tech
render_with_liquid: false
---

I just set up [Plagger](http://www.plagger.org/) to send me e-mails to my
cellphone and Gmail when there are updates to my replies rss feed on twitter.
This took way longer than anticipated because of how long it took to install and
configure [Plagger](http://www.plagger.org/) properly.

First installing it took a long time. I installed it via CPAN and
[Plagger](http://www.plagger.org/) has a huge number of dependencies. Many of
the dependencies are not set properly so CPAN fails to install it more often
than not. I had to force install the `IO::Socket::SSL` package because the tests
failed. I didn't need TLS for mail and it's an optional package so I'm not sure
why I needed SSL in the first place.

Once Plagger was installed there isn't a terribly large amount of info about how
to set it up. You basically have to create a `config.yaml` file in the same
directory as the Plagger executable or create a YAML file with any name and
specify the location with the `-c` flag.

The YAML files configuration are easy to read but what options are available for
each plugin is a bit obtuse without any examples to look at. There [are
some](http://plagger.org/trac/browser/trunk/plagger/examples) but it took me a
while to find them since they aren't listed on the [Plagger
cookbook](http://plagger.org/trac/wiki/PlaggerCookbook) which is linked to from
the homepage. To find out what options are available to each plugin you'll
either need to read the examples or the bottom of the [plugin's source code
files](http://plagger.org/trac/browser/trunk/plagger/lib/Plagger/Plugin) to get
a description of what it does and it's options. I'm also not sure what all of
the types of plugins do but I gather than Subscription plugins are plugins for
reading RSS feeds and incoming data, Publish plugins are for publishing RSS
feeds, email, html etc., and Filters are for parsing and/or modifying the data.

I used three Plugins to achieve what I wanted to do which was to get e-mail sent
to my Gmail account and my mobile. I used the `Subscription::Config`,
`Filter::HTMLScrubber`, and `Publish::Gmail` plugins. The configuration plugin
pulls from an RSS feed and caches the results. It only passes on changes to the
feed to other plugins. The Gmail plugin is essentially a SMTP/SMTP TLS plugin
which sends e-mails when it gets updates from the subscription plugins.
Unfortunately the version of the plugin that installed with CPAN had a bug as it
called the `MIME::Lite::extract_addrs` function which is not present on the
machine where I was running Plagger. I needed to update the `Gmail.pm` plugin
file to the [newest
version](http://plagger.org/trac/browser/trunk/plagger/lib/Plagger/Plugin/Publish/Gmail.pm)
in Plagger's SVN. That version includes a fix around like 214 to call the
`extract_full_addrs` function if the `extract_addrs` function doesn't exist.

Next, my mobile doesn't support HTML mail very well so I had to scrub the HTML
from the RSS feeds with the `HTMLScrubber` plugin. Unfortunately though the
Gmail plugin sends e-mails as `text/html` encoded so I needed to further modify
the `Gmail.pm` file to mail as `text/plain` around line 90.

After that the template file that is used to generate the e-mail,
`gmail_notify.tt`, was missing so I needed to get [that from SVN as
well](http://plagger.org/trac/browser/trunk/plagger/assets/plugins/Publish-Gmail/gmail_notify.tt)
and I put it in my `.cpan/assets/common` directory and added that directory to the
templates search path in my `config.yaml`. The contents of the template are also
html so I needed to edit the template to remove all the HTML tags.

After that I just put `config.yaml` in the same directory as my Plagger executable
and added a line to execute Plagger every 10 minutes to my `crontab`. This also
had it's glitches as Plagger prints debug and info messages to standard error so
you can't just do `plagger > /dev/null` you have to have something like `plagger
/dev/null 2>&1` so that `cron` doesn't email you with Plagger info messages
every 10 minutes.

Anyway, after a few hours of messing with it, it finally worked. Here is the
`config.yaml` I used.

```yaml
global:
    assets_path: /home/<myuser>/.cpan/assets
plugins:
    - module: Subscription::Config
      config:
          - feed:
                url: http://IanMLewis:<twitterpassword>@twitter.com/statuses/replies.rss

    - module: Filter::HTMLScrubber
      config:
          comment: 0

    - module: Publish::Gmail
      config:
          mailto: <me>@gmail.com, <mobile e-mail>
          mailfrom: twitter@ianlewis.org
          mailroute:
              via: smtp
              host: localhost:26
              username: <local mail user>
              password: <local mail password>
```
