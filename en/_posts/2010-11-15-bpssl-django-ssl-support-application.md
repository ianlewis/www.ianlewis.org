---
layout: post
title: "bpssl - The Django SSL Support Application"
date: 2010-11-15 18:31:13 +0000
permalink: /en/bpssl-django-ssl-support-application
blog: en
tags: python django ssl
render_with_liquid: false
---

The other day I released bpssl which is a Django application that helps
you support HTTPS on your website. The main functionality is performing
redirection for HTTPS only URLs and views. For instance, if a request
for your login view '/login' is recieved over HTTP, the provided
middleware can redirect the user to the equivalent HTTPS page.

Specifying views and urls as secure is supported as are
[flatpages](http://docs.djangoproject.com/en/dev/ref/contrib/flatpages/).
[Fastcgi](http://docs.djangoproject.com/en/dev/howto/deployment/fastcgi)
and HTTP proxy setups are also well supported.

Many people support this at the web server level but the pages that
require SSL can change often and it is often easier to manage this at
the application layer.

bpssl draws inspiration from the well known SSL Middleware snippets on
<http://www.djangosnippets.org> . It roughly supports the features of
the following snippets:

- <http://djangosnippets.org/snippets/880/>
- <http://djangosnippets.org/snippets/240/>
- <http://djangosnippets.org/snippets/1999/>

# For the lazy

- [Documentation](http://beproud.bitbucket.org/bpssl-1.0/en/)
- [Source Code](http://bitbucket.org/beproud/bpssl/) (Holy crap\!
  there are tests\!)

# Installation

First install the `bpssl` package using PIP:

```shell
pip install bpssl
```

or easy_install:

```shell
easy_install bpssl
```

Next add `'beproud.django.ssl'` to your
[INSTALLED_APPS](http://djangoproject.jp/doc/ja/1.0/ref/settings.html#installed-apps)
in your `settings.py`.

```python
INSTALLED_APPS = (
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.sites',
    'django.contrib.messages',
    # ...
    'beproud.django.ssl',
    # ...
)
```

Next add `'beproud.django.ssl.middleware.SSLRedirectMiddleware'` to your
[MIDDLEWARE_CLASSES](http://djangoproject.jp/doc/ja/1.0/ref/settings.html#setting-MIDDLEWARE_CLASSES)
setting.

```python
MIDDLEWARE_CLASSES = (
    'django.middleware.common.CommonMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    # ...
    'beproud.django.ssl.middleware.SSLRedirectMiddleware',
    # ...
)
```

Finally add
[SSL_URLS](http://beproud.bitbucket.org/bpssl-1.0/en/settings.html#setting-ssl-urls)
to your settings. SSL_URLS is a list of regular expressions that match
Urls.

```python
SSL_URLS = (
    '^/login/',
    '^/purchase/'
    # ...
)
```

Or if you prefer:

```python
# In the age of Firesheep, you can never be too careful.
SSL_URLS = (
    '.*',
)
```

There is also a
[ssl_view()](http://beproud.bitbucket.org/bpssl-1.0/en/usage.html#beproud.django.ssl.decorators.ssl_view)
decorator which allows you to attach redirection logic to individual
views.

On the Django side this is all you need to setup and run bpssl. There is
some setup required on the web server depending on your setup. Please
check out the
[Documentation](http://beproud.bitbucket.org/bpssl-1.0/en/) or [Source
Code](http://bitbucket.org/beproud/bpssl/) for details.
