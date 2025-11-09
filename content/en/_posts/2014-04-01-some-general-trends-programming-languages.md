---
layout: post
title: "Some General Trends in Programming Languages"
date: 2014-04-01 03:00:00 +0000
permalink: /en/some-general-trends-programming-languages
blog: en
tags: tech programming golang rust typescript
render_with_liquid: false
---

<!-- TODO(#339): Add alt text to images. -->
<!-- markdownlint-disable MD045 -->

There are a number of next generation of languages that have come out and are
becoming popular in recent years that are trying to use what has been learned
from large development projects. Some of the more popular languages aimed at
servers are [Go](http://golang.org), [Rust](http://www.rust-lang.org/) and
[Haskell](http://www.haskell.org/). Others like
[TypeScript](http://www.typescriptlang.org/), and
[Dart](https://www.dartlang.org/) are targeting the client side as well as
server side applications.

![A Gopher character. The Go language mascot.](/assets/images/715/gopher_thumbnail.jpg)
![The Rust language logo.](/assets/images/715/rust-logo-128x128-blk-v2_thumbnail.png)
![The Haskell language logo.](/assets/images/715/haskell-logo_thumbnail.png)

There are some common threads in these new languages here that I don't really
see talked about much but I think are useful to talk about because they
highlight the direction that technology is heading. An old high school
classmate Bob Ippolito provided an interesting [answer](http://qr.ae/GgtRL)
on Quora to a question about languages that illustrates some of the ideas
nicely. His answer inspired me to do some research and write this post.

I'm sure there are lots of new languages with various properties, but I'm going
to focus on the recent general-purpose languages that that seem to be gaining
traction with a large number of developers.

## Statically-Typed

The first thing that all of these have in common is some form of [static type
checking](http://en.wikipedia.org/wiki/Type_system#Static_type-checking). The
only recently released major language that doesn't have compile-time checking
is Dart which provides a runtime mode that adds assertions about a variable's
type. In any case, all of them generally have type checking in mind.

![Statically Typed Duck](/assets/images/715/ducktyping_small.jpeg)

*http://geek-and-poke.com/*

The thinking is that type checking allows tools like the compiler to tell you
that you have made incorrect assumptions about how the program works. These
include calling a method on a type that doesn't define it or making a call
type to a function that doesn't match the function signature.

Personally, I'm not a big fan of type checking and I generally prefer that the
compiler/VM stay out of my way. I have a feeling that the benefit to building
correct software comes from the fact that the compiler keeps you honest, and
that you can write perfectly correct software without type checking if you
have a bit of discipline.

That said, declaring types provides the dual benefit of allowing the compiler
to optimize code easier, as well as checking the logic itself for errors. Some
new languages, like Go, can also do some interesting things, like type inference, to
make it less cumbersome to declare types so I think it's safe to say typed
languages will be a general trend in the future.

## Native code compilation

Along with type checking another trend is native code compilation. Type
checking allows you to generate code that's relatively safe because it's
checked at compile time. The "write once run everywhere" idea that beget Java
doesn't provide much benefit over simply compiling for each platform of which
you have only one or two you care about anyway. Native code also has the
benefit of being faster, having shorter startup times, using less memory, and
having more predictable performance than pure VMs or just-in-time compilers;
all of those properties are important when building scaleable systems. There
just doesn't seem to be much benefit to having a VM now-a-days.

Languages that implement compiling to native code include Go, Rust, and
Haskell.

## Cheap threads

---

Having some kind of cheap way to create processes or threads is critical for
writing concurrent programs. This could be in the form of green-threads, like
in Go (goroutine)/Rust (task)/Haskell (threads) or "green-processes" erlang
that don't require a full operating system thread/process. It could be an
event driven/callback system like Node.js, but the trend seems to be going
towards green-threads as they can be more easily made to utilize multiple
cores.

![](/assets/images/715/cheap_threads_small.jpg)

The other thing that these cheap threads have in common is that they don't rely
on locking to achieve parallelism. Each language exposes a way to communicate
between threads without using locks. In Go there are
[channels](http://golang.org/doc/effective_go.html#channels) which are
essentially a type of queue. Haskell has something similar called an
[MVar](http://hackage.haskell.org/package/base-4.6.0.1/docs/Control-Concurrent-MVar.html),
and Rust has a message passing interface in the [std::comm
package](http://static.rust-lang.org/doc/master/std/comm/index.html).

## Verifiable Code

This is another interesting idea that is just starting to gain traction but
that I think will continue to become popular in the future; Newer languages are
making some effort to not only enforce type checking, but also do style
checking, and verification that code is correct.

The authors of Go have made the Go compiler quite strict such that unused
variables and imports cause compiler errors. The community also provides
tools such as gofmt which is the de-facto standard style for Go code. Go
was also meant to be easy to parse so that languages tools such as debuggers,
linters, and verifiers could be easily written.

See: [Why are declarations
backwards?](http://golang.org/doc/faq#declarations_backwards) and [Why is the
syntax so different from C?](http://golang.org/doc/faq#different_syntax)

Haskell implements a fully functional programming language which means that
functions do not have side effects (unless you declare that they do). This
makes it easier to programatically demonstrate the correctness of a program.
Conceptually, you could write tests easier. Perhaps in the future people will
write compilers and parsers that give you good feedback about whether a
function is actually correct or not or writes tests automatically for you.

## Corporate Stewardship

---

![](/assets/images/715/golang_small.jpg)

I noticed that a lot of new open source languages and programming environments
have been started by and stewarded by corporations to solve their business
needs. Go and Dart were created by folks at [Google](http://www.google.com/).
Rust was created by an independent developer working at Mozilla but is
currently stewarded by [Mozilla](http://www.mozilla.com/). TypeScript was
created by people at [Microsoft](http://www.microsoft.com/). Erlang isn't new
but fits this pattern as it was created at [Ericsson](http://www.ericsson.com/)
as a language for telephony applications.

While not languages per se, the Node.js, Android and iOS development
environments are similar in that the tools and development is stewarded by a
corporation; [Joyent](http://www.joyent.com/),
[Google](http://www.google.com/), and [Apple](http://www.apple.com/)
respectively.

With the exception of Haskell, practically all major languages gaining traction
have or had a corporate steward. Given the increase in the number of new
languages that fit this pattern, and the complexity of creating a language and
the surrounding ecosystem, I think that, at least for popular languages, this
will continue to be a trend in the future.

## Conclusion

So that's it. Just a few patterns I noticed in programming languages and
environments. What do you think? I'm sure I missed something so if there is
something on your mind just leave a comment below or get in touch on ~~Twitter~~
[Bluesky](https://bsky.app/profile/ianlewis.org)

<!-- markdownlint-enable MD045 -->
