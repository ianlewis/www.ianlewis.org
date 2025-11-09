---
layout: post
title: "jQueryUIのsortableウィジェット接続の仕方"
date: 2009-04-24 13:10:48 +0000
permalink: /jp/jqueryui-sortable-connect
blog: jp
tags: tech programming javascript
render_with_liquid: false
locale: ja
---

最近、[jQueryUI](http://jqueryui.com/)をバリバリ使ってて、[sortable](http://jqueryui.com/demos/sortable/)というウィジェットで簡単にできることがあまりにも面白い。

```javascript
$("#my-list").sortable({
    axis: "x",
});
```

`axis`は必須じゃないけど、オプションに渡す場合の例にいいのかなと思って入れた

draggableというウィジェットもあって、これであるオブジェクトをsortableウィジェットにdragで入れられる。

```javascript
$("#my-item").draggable({
    connectToSortable: "#my-list",
});
```

同じくsortableはsortableと接続して、一つのsortableから、別のsortableに移動ができる。

```javascript
$("#my-list").sortable({
    connectWith: "#my-other-list",
});
```

同じ書き方で、二つのsortableを接続しあうこともできる。これで、オブジェクトを自由にsortableからdragしたり、dropしたり、結構面白いインタフェースができる。

```javascript
$("#my-list").sortable({
    connectWith: "#my-other-list",
});

$("#my-other-list").sortable({
    connectWith: "#my-list",
});
```

[DEMO >>](/assets/demos/files/sortables/index.html){: target="blank"}
