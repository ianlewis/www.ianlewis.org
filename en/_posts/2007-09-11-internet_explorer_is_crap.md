---
layout: post
title: "Internet Explorer is CRAP!!"
date: 2007-09-11 18:29:20 +0000
permalink: /en/internet_explorer_is_crap
blog: en
render_with_liquid: false
---

Basically the title says it all. Since I started doing web development I've lost count of the number of bugs that I've found in Internet Explorer but I want to highlight a couple that were especially annoying to me.

1.) The `<button>` tag doesn't work. The button tag has a value attribute which is supposed to be sent as the value of the post when I submit a form but it's not. The display value of the button is sent instead. So if you have a form like so:

```html
<button name="time" value="1030">Click here</button>
```

and you submit the form that the button is contained in, the post value of time is set to "Click here" instead of "1030" like it's supposed to. Basically in IE you can't have a button submit a form and post a value different from the displayed value. This makes it very hard to have an array of buttons and post a different value based on what button you push.

2.) For e-mail links that contain Japanese characters you have to change the characters to the %0000; equivalent value. So if you have a mailto with a subject line in Japanese you can't write:

```html
<a href="mailto:myperson@mymail.com?subject=おはようございます">e-mail me</a>
```

and expect it to work. Internet Explorer simply does nothing. No error message. No e-mail client. You have to url encode the link to something look something like:

```html
<a
  href="mailto:myperson@mymail.com?subject=%E3%81%8A%E3%81%AF%E3%82%88%E3%81%86%E3%81%94%E3%81%96%E3%81%84%E3%81%BE%E3%81%99%26"
  >e-mail me</a
>
```

which if you are using [php](http://www.php.net/) is not so bad since you just call [urlencode()](http://www.php.net/manual/en/function.urlencode.php) but it's just plain annoying to get stuff like this to work when there isn't really a good reason why you need to encode it (at least I haven't heard one so far).

That's just the 2 most annoying bugs/issues. I can't imagine how the button bug got though the testing phase for IE but probably there are too many applications that depend on the bug working as is for Microsoft to ever change it to work the way it's supposed to.

I realize I shouldn't hold my breath, but the sooner everyone stops using IE the better.
