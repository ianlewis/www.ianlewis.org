---
layout: post
title: "TIL: fx: the JSON/YAML navigator"
date: "2025-11-11 07:30:00 +0900"
blog: til
tags: programming
render_with_liquid: false
---

I have recently been doing more with YAML (you may be able to guess why). I
wanted something that would help me with navigating large complicated YAML
objects and [`fx`](https://fx.wtf/) is exactly what I was looking for.

`fx` can help with viewing JSON or YAML and allows you to collapse and expand
sections of the file.

```bash
# now it's obvious isn't it
$ kubectl get pods -o json | fx
$ kubectl get pods -o yaml | fx --yaml
```

The GIF from their website shows what it looks like pretty well.

![An animated GIF showing how fx can be used to collapse and expand various parts of a JSON file. The contents of the file are a lorem ipsum article sample with structured data for the author and tags.](/assets/images/2025-11-10-fx-the-json-yaml-navigator/preview.gif)
