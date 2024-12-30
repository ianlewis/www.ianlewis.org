---
layout: post
title: "python-openvcdiff and Cython"
date: 2010-03-21 18:26:15 +0000
permalink: /en/python-openvcdiff-and-cython
blog: en
tags: python c++ c open-vcdiff
render_with_liquid: false
---

<!-- textlint-disable rousseau -->

I started a project today to implement an interface for the
[open-vcdiff](http://code.google.com/p/open-vcdiff/) using
[Cython](http://www.cython.org/). I'm not a C++ master and the Python C
libraries are pretty new to me but I managed to expose and implement a
few methods of the VCDiffEncoder class. The hardest part so far has been
trying to figure out how to use the C++ standard library types like
std::string. I'm also not sure how I can interface with python in such a
way as to allow fast processing of potentially large binary data.
Normally I would use a file-like object in Python to create a kind of
string but open-vcdiff being C++ has a slightly different interface for
dealing with binary blobs.

The code is over at bitbucket in my
[python-openvcdiff](http://bitbucket.org/IanLewis/python-openvcdiff)
repository.

<!-- textlint-enable rousseau -->
