---
layout: post
title: "Django template2pdf"
date: 2010-03-01 18:21:14 +0000
permalink: /en/django-template2pdf
blog: en
tags: tech programming python django
render_with_liquid: false
---

This is cool Django application from [Yasushi
Masuda](http://twitter.com/whosaysni) which allows you to render data to
a pdf using [trml2pdf](http://pypi.python.org/pypi/trml2pdf).

[template2pdf](http://code.google.com/p/template2pdf/) provides a
generic view called direct_to_pdf which will render a rml template
directly to pdf.

```python
# coding: utf-8

from django.http import HttpResponse
from django_trml2pdf import direct_to_pdf

from django.shortcuts import render_to_response

def myview(request, template_name='trml2pdf/mytemplate.rml'):
    params = {}
    return HttpResponse(
        direct_to_pdf(request, template_name, params),
        mimetype='application/pdf')
```
