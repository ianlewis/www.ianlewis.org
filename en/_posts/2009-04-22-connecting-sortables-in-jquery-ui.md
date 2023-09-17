---
layout: post
title: "Connecting Sortables in jQuery UI"
date: 2009-04-22 11:26:41 +0000
permalink: /en/connecting-sortables-in-jquery-ui
blog: en
tags: jquery sortable jquery ui
render_with_liquid: false
---

[jQuery](http://jquery.com/) has a UI framework called
[jQueryUI](http://jqueryui.com/) which provides a number of UI controls and
widgets that you can use to create cool user interfaces. I've been using
jQueryUI a fair bit for work recently and wanted to share a pretty cool feature
that jQueryUI has.

jQueryUI has a widget called a [sortable](http://jqueryui.com/demos/sortable/)
which is just a list of sortable dom elements. It allows you to drag the items
around and resort them in a list. Options are passed in an object that you give
to the sortable constructor/initializer. You can initialize a sortable like so:

```javascript
$("#my-list").sortable({
  axis: "x",
});
```

In this case the options object and contained `axis` option are optional but it
gives you a good idea what a widget initializer looks like.

jQueryUI also has a draggable widget which allows you to easily create
draggable items. This draggable can also be connected to a sortable object so
you can drag an object onto a sortable widget.

```javascript
$("#my-item").draggable({
  connectToSortable: "#my-list",
});
```

jQueryUI also allows you to connect sortables to each other which creates the
potential for some interesting user interfaces.

```javascript
$("#my-list").sortable({
  connectWith: "#my-other-list",
});
```

You can even connect the sortables together so you can drag items back and
forth between the sortables:

```javascript
$("#my-list").sortable({
  connectWith: "#my-other-list",
});

$("#my-other-list").sortable({
  connectWith: "#my-list",
});
```

You can check out a demo that connects two sortables together here: [DEMO >>](/assets/demos/files/sortables/index.html)
