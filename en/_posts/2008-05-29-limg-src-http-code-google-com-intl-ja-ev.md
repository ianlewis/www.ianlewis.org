---
layout: post
title: "Google Developer Day 2008"
date: 2008-05-29 20:39:03 +0000
permalink: /en/limg-src-http-code-google-com-intl-ja-ev
blog: en
tags: python google javascript appengine google developer day 2008
render_with_liquid: false
---

<!-- textlint-disable rousseau -->

[Google Developer Day Japan
2008](http://code.google.com/intl/ja/events/developerday/2008/home.html) is
being held on June 10th at Google's offices in Shibuya and I've registered to
attend this year. There were a number of sessions that people could take part
in but I decided to register for a
[Google appengine](http://code.google.com/appengine/) hackathon. I'm pretty
curious about appengine since I've been working at becoming more familiar with
really newly evolving technologies and not necessarily ones that have been
around a while. Newly evolving technologies is something I've always felt I've
had to catch up on since starting programming in high school. Going to high
school with folks like Bob Ippolito ([Mochikit](http://www.mochikit.com),
[simplejson](http://undefined.org/python/#simplejson)) and
[Konrad Rokicki](http://www.facebook.com/profile.php?id=5317298) who started
coding stuff when they were in early middle school didn't help my self esteem.

Anyway, in the spirit of learning about Appengine I took a dive into the
[documentation](http://code.google.com/appengine/docs/) and learned a few of
appengines [silly](http://twitter.com/IanMLewis/statuses/821766091)
[limitations](http://twitter.com/IanMLewis/statuses/821750608) but I came up
with a simple application that utilizes the simple python library I created for
[prefix](http://prefix.sourceforge.net/) back in college. I put it up in my
mercurial repository under `/hg/prefix-appengine/` (_Update (2023-10-02): Link
removed as I seem to have removed it long ago_) if you care to take a look.

The main work is done in two handlers which are essentially the controller part
of the MVC pattern. One simply renders the page as a template, which is really
simple since there isn't any template code, and the other implements a simple
rest API that I use for an AJAX call to evaluate an expression given by the
user. Using JSON seemed like a waste since there was only one returned value.

```python
class PrefixHandler(webapp.RequestHandler):
    def get(self):
        self.response.out.write(template.render("main.tpl", {}))

    # def post(self):
    #     self.redirect('/')

class EvalHandler(webapp.RequestHandler):
    def get(self):
        expression = self.request.get("exp")
        values = {}
        try:
            output = prefix.parser.parse(expression).evaluate()
            values = {
                "value": output
            }
        except ValueError, arg:
            output = "ERROR: " + str(arg)
            values = {
                "error": output
            }
        self.response.out.write(simplejson.dumps(values))
```

The rest of the code is in the javascript which I just wrote strait into the
template file because I was lazy. The javascript uses
[jquery](http://jquery.com) to do an AJAX call when the button is pressed and
update the HTML DOM.

```javascript
var lastvalue = "";

$(document).ready(function() {
  $("#eval").click(function() {
    expression = $("#exp").val();
    $("#output").html("Loading..");
    uri = "eval?exp=";
    uri += encodeURIComponent(expression.replace("Ans", lastvalue));
    uri = uri.replace(/%20/g|>, '+');

    $.getJSON(uri,
      // Callback
      function (data) {
        output = "<font color='#FF0000'>ERROR: Invalid response from server</font>";
        if (data.value != null) {
          output = expression + " = <font color='#00FF00'>" + data.value + "</font>";
          lastvalue = data.value;
        } else {
          if (data.error &amp;&amp; data.error.length>0) {
            output = "<font color='#FF0000'>"+ data.error +"</font>";
          }
        }
        $("#output").html(output);
      }
    );
  });
});
```

<!-- textlint-enable rousseau -->
