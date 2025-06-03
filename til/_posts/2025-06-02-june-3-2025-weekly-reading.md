---
layout: post
title: "TIL: June 3, 2025 - Weekly Reading: AI, NixOS, and more"
date: "2025-06-02 00:00:00 +0900"
blog: til
tags: AI, programming, nixos
render_with_liquid: false
---

## AI

- [I am disappointed in the AI discourse](I am disappointed in the AI discourse) - _Steve Klabnik_

    This post from Steve Klabnik has been popular on Bluesky recently. I
    personally didn't get a lot out of it though. I am pretty skeptical about AI
    and it seems that some folks like Steve really get a lot out of it even if
    it doesn't get everything right.

    I've just found that every time I use it I get really bad results right away
    and it turns me off. I come back to try it every week or so and I still
    haven't found it to be very helpful to what I'm trying to do. Even
    auto-complete style AI when coding produces results that I'd grade at about a
    3/10. I find myself spending more time fixing code that it creates than it
    would have taken to just write it myself in the first place.

    Perhaps I'm just too used to getting instant search results and finding what I
    want quickly that I'm not patient enough to go back and forth with an AI to
    get what I want?

- [The Software Engineering Identity Crisis](https://annievella.com/posts/the-software-engineering-identity-crisis/) - _Annie Vella_

    This is an article linked from Steve's blog post. I found this to be pretty
    close to how I've felt about AI. What I love most about coding is the craft.

    I also love that computers are generally deterministic and produce precise
    results. AI really takes that away in that it produces results that are not
    exacty what you asked for but are maybe good enough for most people.

    I recently heard an analogy that human coding is like tending to a garden. I
    suppose the idea is that with AI, software development will be more like big
    agriculture where only a few farmers mass produce less nutritious food with
    less variety but good enough for most use cases, using highly automated
    expensive machinery. In our case, it's just a few AI overseer engineers who
    use expensive AI tools to mass produce generic low-quality software.

## NixOS

- [How I like to install NixOS (declaratively)](https://michael.stapelberg.ch/posts/2025-06-01-nixos-installation-declarative/) - _Michael Stapelberg_

    Michael describes how he installs NixOS. He describes how to build a NixOS
    install ISO image which is pretty cool since you can customize and build it
    pretty easily.

    The other cool takeaway is the use of `nixos-anywhere` which you can use to
    declaritively describe the installation you want (disk partitions, inital NixOS
    configuration, etc.) and automate it over SSH. You just boot up the
    custom ISO installer image you created and then run `nixos-anywhere` to
    complete the installation.

## Web Development

- [Compiler Explorer and the Promise of URLs That Last Forever](https://xania.org/202505/compiler-explorer-urls-forever) - _Matt Godbolt_

    Matt Godbolt describes how the Compiler Explorer is handling `goog.gl` links
    that are now going away. Previously they used `goog.gl` to create short
    links which redirect to long URLs that contain Compile Explorer state.

    Rather than the specific of how they are handling this, I think the fact
    the idea that URLs should last forever can't be sustained. On a practical
    level, you can't expect someone to pay for every domain name forever. It
    practice URLs often go away even on popular sites.

    Another example is something like Twitter where they are essentially
    licensing your Tweets to display them on their site. In my case, I don't
    want to retain a legal agreement (EULA) with Twitter anymore so I'm planning
    to delete my account at the end of the year. Those URLs will go away
    permanently.

    I think we should just accept that URLs are not permanent and instead build
    a more resilient web that can better handle URLs going away. I'm not sure
    there is enough interest or motivation to fix it though.
