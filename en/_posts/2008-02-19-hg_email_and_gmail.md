---
layout: post
title: "hg email and gmail"
date: 2008-02-19 00:41:16 +0000
permalink: /en/hg_email_and_gmail
blog: en
tags: mercurial
render_with_liquid: false
---

I just set up my e-mail settings with
[Mercurial](http://www.selenic.com/mercurial/) so that I can e-mail patches via
my [Gmail](http://www.google.com/mail/) account. I have
[Debian](http://www.debian.org/) installed on my machine which has
[exim](http://www.exim.org/) installed by default so it was pretty easy to set
up. I'm not terribly versed at setting up mailing agents so I basically
followed [these instructions](http://wiki.debian.org/GmailAndExim4) on the
[Debian Wiki](http://wiki.debian.org/). After getting that set up it's easy to
set up Mercurial to use exim4 since it's a drop in replacement for
[sendmail](http://www.sendmail.org/).

To set up Mercurial to use exim I followed the
[instructions](http://www.selenic.com/mercurial/wiki/index.cgi/.hgrc?highlight=%28email%29)
on the Mercurial Wiki:

```text
email::
...
method;;
    Optional.  Method to use to send email messages.  If value is
    "smtp" (default), use SMTP (see section "[smtp]" for
    configuration).  Otherwise, use as name of program to run that
    acts like sendmail (takes "-f" option for sender, list of
    recipients on command line, message on stdin).  Normally, setting
    this to "sendmail" or "/usr/sbin/sendmail" is enough to use
    sendmail to send messages.

  Email example:

    [email]
    from = Joseph User <joe.user@example.com>
    method = /usr/sbin/sendmail
```

So here is my very simple ~/.hgrc file:

```ini
[ui]
username = Ian Lewis <IanMLewis@gmail.com>
[email]
from = Ian Lewis <IanMLewis@gmail.com>
method = /usr/sbin/exim4
```

Simple. Now I just enable POP for my gmail and I can use hg email and it will
go through my gmail account. Now only if the Mercurial guys would fix
[this issue](http://www.selenic.com/mercurial/bts/issue814) so I can send the
patch email with the correct encoding.
