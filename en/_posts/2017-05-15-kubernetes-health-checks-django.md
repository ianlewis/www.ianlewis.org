---
layout: post
title: "Kubernetes Health Checks in Django"
date: 2017-05-15 16:07:14 +0000
permalink: /en/kubernetes-health-checks-django
blog: en
tags: python django kubernetes
render_with_liquid: false
---

<!-- textlint-disable rousseau -->

<img alt="Kubernetes + Django" title="Kubernetes + Django" class="align-center" src="/assets/images/752/kube-django.png">

In a previous post I wrote about [Kubernetes health checks](/en/using-kubernetes-health-checks). Since I'm a Python developer and a fan, I went about implementing it in Django. Health checks are a great way to help Kubernetes help your app to have high availability, and that includes Django apps. However, with Django it's not quite as simple as it sounds.

Health checks are a way for Kubernetes to ask your app if it's healthy. They assume that your app can start up without being ready, and so don't assume any ordering to the starting of apps. For that reason we need to be able to check for things like if the database or memcached have gone away and are no longer accessible to the app.

# Healthcheck Views

The naive way to write a health check would be to write a view for it. Something like this:

```python
def liveliness(request):
    return HttpResponse("OK")

def readiness(request):
    try:
        # Connect to database
        return HttpResponse("OK")
    except Exception, e:
        return HttpResponseServerError("db: cannot connect to database.")
```

But Django runs a lot of user code like [Middleware](https://docs.djangoproject.com/en/1.11/topics/http/middleware/) and decorators before a view gets run. So failures in those can generate responses that we don't want with our readiness probe.

# Solving Healthchecks with Middleware

Because a lot of Django middleware such as Django's [AuthenticationMiddleware](https://github.com/django/django/blob/master/django/contrib/auth/middleware.py) use the database, implementing liveness and readiness checks as a simple view wouldn't work. When the your app fails to access the database, Django generates an exception and returns a 500 error page long before Django executes your view. This doesn't provide the best developer experience for Kubernetes.

To partially solve health checks for Django apps I wrote a little piece of middleware to implement health checks. I wanted to perform a database check without assuming the use of any particular Django model so I generated queries directly.

I was also able to check if cache servers are available by calling `get_stats()` to ping the server since the memcached client doesn' t support a `ping` method.

```python
import logging

from django.http import HttpResponse, HttpResponseServerError

logger = logging.getLogger("healthz")

class HealthCheckMiddleware(object):
    def __init__(self, get_response):
        self.get_response = get_response
        # One-time configuration and initialization.

    def __call__(self, request):
        if request.method == "GET":
            if request.path == "/readiness":
                return self.readiness(request)
            elif request.path == "/healthz":
                return self.healthz(request)
        return self.get_response(request)

    def healthz(self, request):
        """
        Returns that the server is alive.
        """
        return HttpResponse("OK")

    def readiness(self, request):
        # Connect to each database and do a generic standard SQL query
        # that doesn't write any data and doesn't depend on any tables
        # being present.
        try:
            from django.db import connections
            for name in connections:
                cursor = connections[name].cursor()
                cursor.execute("SELECT 1;")
                row = cursor.fetchone()
                if row is None:
                    return HttpResponseServerError("db: invalid response")
        except Exception, e:
            logger.exception(e)
            return HttpResponseServerError("db: cannot connect to database.")

        # Call get_stats() to connect to each memcached instance and get it's stats.
        # This can effectively check if each is online.
        try:
            from django.core.cache import caches
            from django.core.cache.backends.memcached import BaseMemcachedCache
            for cache in caches.all():
                if isinstance(cache, BaseMemcachedCache):
                    stats = cache._cache.get_stats()
                    if len(stats) != len(cache._servers):
                        return HttpResponseServerError("cache: cannot connect to cache.")
        except Exception, e:
            logger.exception(e)
            return HttpResponseServerError("cache: cannot connect to cache.")

        return HttpResponse("OK")
```

You can add this to the beginning of your `MIDDLEWARE_CLASSES` to add health checks to your app. Putting it at the beginning of `MIDDLEWARE_CLASSES` ensures it gets run before other Middleware classes that might access the database.

# Supporting Health Checks

There is a bit more we need to do to support health checks. Django, by default, connects to the DB on every connection. Even if using connection pools it lazily connects to the db when the request comes. In Kubernetes, if your [Service](https://kubernetes.io/docs/concepts/services-networking/service/) has no endpoints (i.e. all mysql or memcached pods are failing readiness checks) your cluster IP for the service will simply be unreachable when you connect to it. Because it's a virtual IP there is no machine to reject the connection.

One of the biggest problem with Python is that there are no default socket timeouts. If your DB has no healthy endpoints your Django app could hang forever waiting to connect to it. What we need to do is make sure we set connection timeouts properly (hint: you should be doing this anyway) in your settings.py. This may be a bit different depending on the database backend you use so read the documentation.

```python
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': 'myapp',
        'USER': 'myapp',
        'PASSWORD': os.environ.get('DB_PASS'),
        'HOST': 'mysql',
        'PORT': '3306',
        'OPTIONS': {
            'connect_timeout': 3,
        }
    }
}
```

Then you need to make sure your `timeoutSeconds` for your health checks are longer than that.

```yaml
readinessProbe:
  # an http probe
  httpGet:
    path: /readiness
    port: 8080
  initialDelaySeconds: 20
  timeoutSeconds: 5
```

# Resilient Django Websites

Hopefully that helps you write more resilient Django websites! Django was written well before Docker, Kubernetes and containerization became popular but Django applications can easily be adapted to work with them. Some PaaS solutions like [Eldarion Cloud](http://eldarion.cloud/) are already making it easy to deploy Python apps using Kubernetes under the hood.

If you are interested in learning more about Kubernetes check out the [Kubernetes Slack](http://slack.kubernetes.io/). That's where the best Kubernetes developers get together to discuss all things Kubernetes. Check out the #sig-apps channel for discussion about deploying applications on Kubernetes.

<!-- textlint-enable rousseau -->
