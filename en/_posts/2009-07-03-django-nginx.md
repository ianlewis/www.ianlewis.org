---
layout: post
title: "Django and nginx settings"
date: 2009-07-03 17:00:13 +0000
permalink: /en/django-nginx
blog: en
---

One problem I keep encountering with setting up fastcgi with Django is
that the default nginx fastcgi parameters cause django to load the top
url no matter what url you try to go to. This is because the default
nginx fastcgi parameters pass the SCRIPT\_NAME parameter to the django
instance which Django interprets incorrectly. In order to fix this you
need to rename the SCRIPT\_NAME parameter to PATH\_INFO.

``` nginx
fastcgi_param PATH_INFO $fastcgi_script_name;
fastcgi_param REQUEST_METHOD $request_method;
fastcgi_param QUERY_STRING $query_string;
fastcgi_param CONTENT_TYPE $content_type;
fastcgi_param CONTENT_LENGTH $content_length;
```
