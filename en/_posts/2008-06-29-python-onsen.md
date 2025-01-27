---
layout: post
title: "Python Onsen"
date: 2008-06-29 10:36:21 +0000
permalink: /en/python-onsen
blog: en
tags: tech events python google-cloud appengine python
render_with_liquid: false
---

![Table of Japanese food](/assets/images/gallery/dcf_0207_big.jpg)

This weekend I went to the Python Onsen (Japanese) organized by
[Voluntas](http://www.twitter.com/voluntas). Python Onsen is an event
where people who like or are interested in python get together at a
Japanese [Ryokan](<http://en.wikipedia.org/wiki/Ryokan_(Japanese_inn)>)
[Onsen](http://en.wikipedia.org/wiki/Onsen) and program/mingle/study
together. The event started Friday but I had to work so I joined
everyone yesterday. If you aren't familiar with the Ryokan experience
check out the Ryokan link. Essentially you have a traditional style room
and traditional meals are served twice a day (with generous
proportions).

![People in a Japanese room on computers](/assets/images/gallery/dcf_0206_big.jpg)

In between meals there was a lot of programming and talk about
programming. I was received pretty well considering that I was the only
non-Japanese in the group of 28 or so people. I spent the time here
working on a form maker project for [Google App
Engine](http://code.google.com/appengine/) which will be using
[JSON](http://en.wikipedia.org/wiki/JSON) quite a bit for server
communication and API interfaces. It is programmed on the client side
using the [Google Web Toolkit](http://code.google.com/webtoolkit/) and
it during the course of development it became clear that there would be
a need for a way to validate incoming JSON on the client and server (for
error checking and security) as well as making the interface easier to
deal with. Currently the typing of the JSON data makes dealing with it
in [Java](http://java.sun.com/) a real pain.

![Japanese mountains](/assets/images/gallery/dcf_0208_big.jpg)

We realized this could be done with a schema, kind of like [XML
Schema](http://en.wikipedia.org/wiki/XML_Schema). Something that could
be used as a way to define the structure of the JSON and thus allow
programs to validate it. So after searching a bit we found the [JSON
Schema proposal](http://www.json.com/json-schema-proposal/). JSON schema
is maintained in JSON and can be maintained inline so if it is, it
doesn't solve any security issues, but it looks like a good way to
validate and do error checking on JSON data that might be coming from an
external (or internal) source. So [one
programmer](http://twitter.com/jbking) whipped up a simple validator in
python which I will hopefully be working on and using on the server side
of my application while I'll be going ahead and creating a client side
schema and JSON parsing library over top of, or separate from, the
existing JSON library for the Google web toolkit.

Pretty good for a two day hackathon.
