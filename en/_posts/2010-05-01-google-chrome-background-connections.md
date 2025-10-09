---
layout: post
title: "Google Chrome Background Connections"
date: 2010-05-01 11:21:30 +0000
permalink: /en/google-chrome-background-connections
blog: en
tags: tech google
render_with_liquid: false
---

Today I found that Google Chrome was making lots of background connections to
`1e100.net`. I was a little worried at first but this seems to be a google owned
domain and these connections are used for their anti-phishing/malware feature.

But even after disabling the feature I still noticed lots of connections open to
`1e100.net`:

```shell
ian@macbook-ian:~$ lsof -i4 | grep chrome
chrome  5294  ian   70u  IPv4  82734      0t0  TCP macbook-ian.local:54753->nrt04s01-in-f99.1e100.net:www (ESTABLISHED)
chrome  5294  ian   81u  IPv4  82735      0t0  TCP macbook-ian.local:54754->nrt04s01-in-f99.1e100.net:www (ESTABLISHED)
chrome  5294  ian   82u  IPv4  82736      0t0  TCP macbook-ian.local:54755->nrt04s01-in-f99.1e100.net:www (ESTABLISHED)
chrome  5294  ian   89u  IPv4  83365      0t0  TCP macbook-ian.local:56139->tx-in-f100.1e100.net:www (ESTABLISHED)
chrome  5294  ian   94u  IPv4  83413      0t0  TCP macbook-ian.local:46004->tx-in-f138.1e100.net:www (ESTABLISHED)
```

Google seems to be doing a lot of user tracking via Google Chrome.

As for `1e100.net`, it seems to be a domain used by google as a gateway to their
server infrastructure. Simply pinging `www.google.com` reveals that it's aliased
to a `1e100.net` subdomain:

```shell
ian@macbook-ian:~$ ping www.google.com
PING www.google.com (66.249.89.104) 56(84) bytes of data.
64 bytes from nrt04s01-in-f104.1e100.net (66.249.89.104): icmp_seq=1 ttl=51 time=10.2 ms
...
```
