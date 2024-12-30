---
layout: post
title: "Redis init.d script"
date: 2010-03-20 11:10:03 +0000
permalink: /en/redis-initd-script
blog: en
tags: ubuntu debian redis
render_with_liquid: false
---

<!-- textlint-disable rousseau -->

<p>I edited <a href="http://gist.github.com/261173">this gist</a> which is a redis init.d script used to start and stop a redis server. I edited it so that the redis server could be installed anywhere in the PATH given and  so that it uses the redis-cli to send the server the SHUTDOWN command. You'll need to set daemonize to "on" in your redis.conf so that redis daemonizes properly.</p>

<script type="text/javascript" src="http://www.smipple.net/embed/u7UhzHcPBtJC3FEn"></script>

<!-- textlint-enable rousseau -->
