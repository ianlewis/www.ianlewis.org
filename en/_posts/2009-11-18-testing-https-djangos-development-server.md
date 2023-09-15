---
layout: post
title: "Testing HTTPS with Django's Development Server"
date: 2009-11-18 21:36:14 +0000
permalink: /en/testing-https-djangos-development-server
blog: en
---

Django's development server doesn't normally support HTTPS so it's hard
to test applications with HTTPS without deploying the application to a
real web server that supports HTTPS. The secret is to use two
development server instances, one for http and one for https, and to use
a tool called [stunnel](http://www.stunnel.org/) to can create an ssl
tunnel to the development server to support HTTPS.

First we need to set up stunnel using the
[documentation](http://www.stunnel.org/examples/https_windows.html) .

After it's installed you can create a pem for stunnel.

``` text
openssl req -new -days 365 -nodes -out newreq.pem -keyout /etc/stunnel/stunnel.pem
```

After that we create a settings file (which I saved to a file called
dev\_https). The "accept" setting is the port of the HTTPS connection.
The "connect" is the port of the development server instance we are
using for https.

``` text
pid = 

[https]
accept=8002
connect=8003
```

After that we start the stunnel daemon.

``` text
stunnel dev_https
```

Now we start the Django development server instance we are going to use
for https. The HTTPS=on environment variable allows request.is\_secure()
to return True properly.

``` text
HTTPS=on python manage.py runserver 8003
```

Then we start the http server.

``` text
python manage.py runserver 8000
```

So now you can connect to <http://localhost:8000> and
<https://localhost:8002> to test your application using https.
