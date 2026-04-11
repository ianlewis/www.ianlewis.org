---
layout: post
title: "The Rise of Confusion Attacks"
# TODO(#540): Set the date to the actual date of publication.
date: 2026-04-07 09:00:00 +0900
permalink: /en/the-rise-of-confusion-attacks
blog: en
tags: security
render_with_liquid: false
# TODO(#540): Japanese translation.
# translations:
#     ja: /jp/the-rise-of-confusion-attacks
---

<!--
Outline:

-->

I've recently seen an uptake in examples of confusion attacks. Confusion
attacks are an interesting class of attacks where different people or systems
interpret things differently. I think this kind of attack is particularly
interesting because it takes advantage of differences in implementation rather
than bugs in software. Two different servers could be implemented correctly, but
still be vulnerable to attack simply due to their differences.

Some people refer to these as "desync" attacks, parsing differential, or [parsing
mismatch](https://www.brainonfire.net/blog/2022/04/11/what-is-parser-mismatch/)
attacks. They are referring to how two parsing systems become "desynchronized".
However, the actual name isn't that important.

## HTTP Smuggling

A good example of this is HTTP 1.1 request smuggling. This is where the
differences between the frontend and back end in how HTTP headers are handled
can be exploited to “smuggle” sensitive headers to the backend. This happens
because HTTP 1.1 allows for two different ways to indicate the length of the
body of a request. One is the `Content-Length` header and the other is specified
in the body of the request when the request is sent with a
`Transfer-Encoding: chunked` header.

If the frontend and back end handle the content length and transfer encoding
headers differently then they can be made to disagree about where the request
ends. This lets an attacker “smuggle” a second malicious request into the
backend.

Take the following request for example:

```text
POST / HTTP/1.1
Host: example.com
Content-Type: application/x-www-form-urlencoded
Content-length: 89
Transfer-Encoding: chunked

0
POST / HTTP/1.1
Content-Type: application/x-www-form-urlencoded
Content-Length: 15

x=1
```

Let's suppose that the frontend server prioritizes the `Content-Length` header and
the backend server prioritizes the `Transfer-Encoding` header. The frontend will
see the above request as a single request with a body of length 89. The backend
will see the above request as two separate requests. The second request was
"smuggled" into the backend and could potentially access sensitive endpoints
that the frontend was supposed to protect.

It turns out that it's really hard to fix this problem in HTTP 1.1. James Kettle
has written a lot on this topic over at PortSwigger. He has a whole
[website](https://http1mustdie.com/) devoted to HTTP smuggling.

<!-- textlint-disable spelling -->

- [HTTP Desync Attacks: Request Smuggling Reborn](https://portswigger.net/research/http-desync-attacks-request-smuggling-reborn)
- [HTTP/1.1 must die: the desync endgame](https://portswigger.net/research/http1-must-die)

<!-- textlint-enable spelling -->

## A Class of Attacks

A confusion attack is not just one type of attack. It's a whole class of
attacks. They affect not just the implementation of network protocols like HTTP
but also file formats. Basically anything that communicates between two
different systems could be vulnerable.

Another recent confusion attack targeted python packages called Wheels. Wheels
are a packaging format that utilize zip file compression. The attack targeted
differences in how ZIP files were read by The `uv` package manager and the `pip`
package manager.

The problem arose in the way that Python's `zipfile` module handles ZIP files,
when compared to the `uv` package manager.
