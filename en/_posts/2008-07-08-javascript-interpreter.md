---
layout: post
title: "Javascript Interpreter"
date: 2008-07-08 19:45:46 +0000
permalink: /en/javascript-interpreter
blog: en
render_with_liquid: false
---

I wanted a convenient way to test out some javascript by running it in a
browser and being able to play with it via an interpreter like python has. As
it turns out the almighty [Bob](http://bob.pythonmac.org/) created a nice
interpreter for playing around with [Mochikit](http://mochikit.com/)
but I wanted something a bit more generic that would allow me to import any
kind of javascript and play with it. It turns out this is really easy so I
added one simple function to the
[interpreter.js](http://static.ianlewis.org/prod/demos/files/view-source/view-source.html#interpreter/interpreter.js)
file called importjs.

You just call importjs like so:

```javascript
importjs(url);
```

This will import a javascript file from the url given. It's a very simple
function that just adds a script tag to the document wrapped in div tag. You
can load up the interpreter and type `importjs` to see the code.

```javascript
function (jssource) {
  importdiv = DIV();
  importdiv.innerHTML = "Importing " + jssource + " <script type='text/javascript' src='" + jssource + "'></script>";
  writeln(importdiv);
}
```

Check out the slightly modified interpreter [here](http://static.ianlewis.org/prod/demos/files/interpreter/index.html)