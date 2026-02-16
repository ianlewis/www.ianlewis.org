---
layout: post
title: "Ok/Cancel buttons with jqModal"
date: 2008-09-22 00:12:22 +0000
permalink: /en/ok-cancel-buttons-with-jqmodal
blog: en
tags: tech programming javascript
render_with_liquid: false
---

I recently quit using [Google Web Toolkit](http://code.google.com/webtoolkit/)
and started using jQuery for a personal project of mine and I wanted to be able
to show some modal dialog boxes using jQuery. As it turns out there is an easy
to use plugin that does exactly this called
[jqModal](http://dev.iceburg.net/jquery/jqModal/). jqModal makes it simple to
create a modal dialog by simply setting a CSS class on the tag you want to open
the dialog and on the tag in the dialog that you want to close it.

```html
<a href="#" class="jqModal">view</a>
...
<div class="jqmWindow" id="dialog">
    <p>This is my dialog.</p>
    <a href="#" class="jqmClose">Close</a>
</div>
```

```javascript
$().ready(function () {
    $("#dialog").jqm();
});
```

That's easy but gives you a pretty minimalistic popup dialog. Any tag with the
jqmClose class will simply close the dialog. What if you want to do something
with OK and Cancel options? What if you want to do some fancy fade in/fade out
no matter what happens? This tripped me up for a but much luckily only took
about a few minutes to straiten out and test.

```html
<a href="#" class="jqModal">Update</a>
...
<div class="jqmWindow" id="dialog">
    <p>I'm going to update. Is that ok?</p>
    <a href="#" class="dialogok">OK</a> <a href="#" class="jqmClose">Cancel</a>
</div>
```

```javascript
$("#dialog #dialogok").bind("click", function () {
    /* Do your update logic here. */
    $("#dialog").jqmHide();
});
```

So I'm basically closing the dialog manually in the "OK" case and closing it
automatically using the `jqmClose` class in the "Cancel" case. In both
cases the `onHide` trigger is called and fades out the dialog.
