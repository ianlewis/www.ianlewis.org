---
layout: post
title: "UTF-8 with guile"
date: 2008-11-19 23:03:47 +0000
permalink: /en/utf-8-with-guile
blog: en
tags: tech programming scheme
render_with_liquid: false
---

Getting UTF-8 to work with guile is a bit of a stretch as guile doesn't have
any real encoding or UTF-8 support to speak of, but I was able to get at least
some basic stuff working by using the [Unicode
Manipulation](http://www.gnu.org/software/guile-gnome/docs/glib/html/Unicode-Manipulation.html#Unicode-Manipulation)
routines which are part of the
[Guile-Glib](http://www.gnu.org/software/guile-gnome/docs/glib/html/index.html)
module.

This requires that you have your `LD_LIBRARY_PATH` and `GUILE_LOAD_PATH` set
properly so that it can load the glib libraries. This didn't work for me out of
the box with guile, but Ubuntu's `guile-gnome0-glib` package provides a script
called `guile-gnome-0` for setting these values for you and running guile. If
you just run guile as is...

```shell
ian@laptop:~# guile
guile> (use-modules (gnome glib))

Backtrace:
In standard input:
   1: 0* (use-modules (gnome glib))
   1: 1  (eval-case (# # *unspecified*) (else #))
   1: 2  (begin (process-use-modules (list (list #))) *unspecified*)
In unknown file:
   ?: 3* [process-use-modules (((gnome glib)))]

<unnamed port>: In procedure process-use-modules in expression (process-use-modules (list #)):
<unnamed port>: no code for module (gnome glib)
ABORT: (misc-error)
guile>
```

Anyway you can run guile with the right paths on Ubuntu by running
`guile-gnome-0`. After getting that running I made use of the Guile-Glib module
to do some operations of utf8 data. I did this from a utf8 console. Beware. The
terminal was not to friendly with me about things like arrow keys and
backspaces over multibyte characters etc.

```shell
guile> (use-modules (gnome glib))
WARNING: (gnome gw generics): imported module (gnome gobject generics) overrides core binding `connect'
guile> (string-length "テスト")
9
guile> (g-utf8-strlen "テスト" -1)
3
guile> (g-utf8-validate "テスト" -1 #f)
#t
guile> (g-unichar-validate (g-utf8-get-char "手"))
#t
```
