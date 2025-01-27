---
layout: post
title: "Javascript Templating Languages"
date: 2014-12-22 00:00:00 +0000
permalink: /en/javascript-templating-languages
blog: en
tags: tech programming javascript templates
render_with_liquid: false
---

I have been looking at JavaScript templating libraries recently for a personal
project and I'd like to write about my thoughts here.

Up until now, I had only really needed to use JavaScript on the client side, in
the browser. While most libraries will work on the server side as a matter of
course, many aren't particularly good at rendering entire documents. I wanted
something that would be easy to render entire html documents without having to
write the same base html in every template.

As a secondary requirement, I wanted something that could be cached/pre-compiled to
JavaScript for speed.

## Underscore.js

For partial html in the browser I have often used [Underscore.js templates](http://underscorejs.org/#template). Underscore's templates are pretty
simple and the logic is written in JavaScript so it's pretty fast.

```html
<html lang="en">
  <head>
    <link rel="stylesheet" type="text/css" href="style.css" />
  </head>
  <body>
    <h1><%- title %></h1>
    <ul>
      <% _.each(items, function(item) { %>
      <li><%- item %></li>
      <% }); %>
    </ul>
  </body>
</html>
```

But Underscore.js' templates have no good way of including templates in other
templates, and reusing template logic. That makes it difficult to use as a template
language on the server side.

## Mustache

[Mustache](http://mustache.github.io/) and the template languages like it are
generally logicless or light on logic. Mustache has partials which can be used
to include sub-templates or other kinds of logic.

```html
<html lang="en">
  <head>
    <link rel="stylesheet" type="text/css" href="style.css" />
  </head>
  <body>
    <h1>{{title}}</h1>
    <ul>
      {{#items}}
      <li>{{item}}</li>
      {{/items}}
    </ul>
  </body>
</html>
```

Mustache is logicless and so is easy to port to other languages but in order to
do anything even moderately complex you will eventually have to implement
partials which are pretty awkward. They also aren't very easy to reuse.

## Jade

[Jade](http://jade-lang.com/) is the default template language used by the
Express framework. Jade is much like haml templates in that you don't write
html but tag names in a short format.

```text
    html(lang="en")
      head
        link(rel="stylesheet", type="text/css", href="style.css")
      body
        h1 #{title}
        ul
          each item in items
            li #{item}
```

Jade supports template inheritance so reusing logic is easier and that makes it
easier to use as a server side templating language.

```text
    html(lang="en")
      head
        link(rel="stylesheet", type="text/css", href="style.css")
      body
        h1 #{title}
        block content
```

```text
    extends ./layout.jade

    block content
      ul
        each item in items
          li #{item}
```

However, It may be a personal preference but I'm not really fond of templating
languages that make writing html shorter. I think it needlessly makes the
template harder to understand as you need to learn how to write html in jade
templates along with how to write logic. Templates are also harder to write and
understand for text other than html.

## Swig

[Swig](http://paularmstrong.github.io/swig/) is a templating language
inspired by Django templates. I immediately liked Swig since I've used Django
and Jinja2 templates quite often as a Python developer.

```jinja
    <h1>{{ pagename|title }}</h1>
    <ul>
    {% for author in authors %}
      <li{% if loop.first %} class="first"{% endif %}>
        {{ author }}
      </li>
    {% endfor %}
    </ul>
```

Swig supports template inheritance and seems to do everything I want but lacks
an easy way to pre-compile templates which is a bit of a bummer but not a
deal breaker for server side templating.

## Nunjucks

[Nunjucks](http://mozilla.github.io/nunjucks/) is a templating language
written by some folks at Mozilla which is heavily inspired by Jinja2. I
immediately liked Nunjucks since I've used Django and Jinja2 templates quite
often as a Python developer.

```jinja
    {% extends "base.html" %}

    {% block header %}
    <h1>{{ title }}</h1>
    {% endblock %}

    {% block content %}
    <ul>
      {% for name, item in items %}
      <li>{{ name }}: {{ item }}</li>
      {% endfor %}
    </ul>
    {% endblock %}
```

Nunjucks also supports template inheritance so it's very easy to use as a
server side template language. When [compared](https://github.com/mozilla/nunjucks/issues/179)
[to](https://github.com/mozilla/nunjucks/issues/83)
[swig](https://github.com/popomore/nunjucks-vs-swig), nunjucks seems to be faster,
has better support for caching and pre-compiling, and looks like the API is a bit better.

## Conclusion

JavaScript has _a lot_ of templating languages. However, maybe because users
are often just rendering small bits of content in the browser, few support very
many features and are often left wanting. For server side rendering of entire
documents, template inheritance is pretty much a must in my mind and that
leaves only Jade, Swig, and Nunjucks. Jade seems nice but I don't like the
shorthand html. That leaves Swig and Nunjucks and when compared Nunjucks seems
to be the winner.
