---
layout: post
title: "Using jQuery deferreds with Backbone.js"
date: 2013-07-22 15:00:00 +0000
permalink: /en/using-jquery-deferreds-backbonejs
blog: en
tags: tech programming javascript
render_with_liquid: false
---

[Backbone.js](http://backbonejs.org/) is a neat little JavaScript model framework. It gives you nice way of making Models and allows you to fetch and save them to the server easily using a REST API. One of the nice things about Backbone is that for a while it has returned the the result of calling the ajax function back to the application, which if you are using jQuery is a [jQuery deferred](http://api.jquery.com/category/deferred-object/). This allows you to do cool things like doing work in parallel and then running a callback when all the work is done.

Let's look at an example. Say we have two models we want to save to the server simultaneously but we only want to update the UI when both are finished. We can use jQuery deferreds to set up the pipeline.

```javascript
band = Band({ name: "Yes" });
song = Song({ title: "Parallels" });

$.when(band.save(), song.save()).done(function () {
  alert("You know we've got the power!");
});
```

Of course, you can do lots of more powerful things with jQuery deferreds but the fact that Backbone.js allows you to do use them may not be immediately obvious.
