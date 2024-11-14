---
layout: post
title: "Testing Django Views Without Using the Test Client"
date: 2015-07-21 16:00:00 +0000
permalink: /en/testing-django-views-without-using-test-client
blog: en
tags: python django testing
render_with_liquid: false
---

The normal way to test Django views is via the [test client](https://docs.djangoproject.com/en/1.8/topics/testing/tools/). The test client fakes being a wsgi server and actually makes an HTTP request through all of Django’s request routing machinery. There are a number of reasons why this isn’t an ideal approach.

## Tests are Slow

When you use the Django test server, you are making an HTTP request from the WSGI server level on up. This invokes logic for parsing the WSGI parameters, middleware, view resolution, error handling and more.

This will make your tests slower than they need to be because of code that you don’t need to test. Django has it’s own tests after all.

## Your Tests Depend on urls.py

When using the Django test client, you are giving it a URL to access to all the settings for URLs must be loaded. This means you depend on your `urls.py`. But if you have developed a somewhat complex website, you may have run into instances where you need to run different versions of the site with different url settings.

For instance, maybe you want to run your user facing app instance without the admin loaded, and have the Django admin loaded on a separate instance that only you can access. In that case you would not be able to write tests against custom admin views using the `urls.py` for your user facing site.

You can [set the urls module](https://docs.djangoproject.com/en/1.8/topics/testing/tools/#urlconf-configuration) for each test but that’s just silly.

## Your Tests Depend on Middleware

The Django test server will execute all of Django’s middleware logic, so your tests will depend on the middleware being loaded. This will make your tests brittle and break when you refactor what middleware you use.

## Test Views Directly

Fortunately, Django provides tools that make it easy to skip unnecessary logic and test views directly. We can use the [RequestFactory class](https://docs.djangoproject.com/en/1.8/topics/testing/advanced/#django.test.RequestFactory) to create a mock request that we can pass to our view directly.

```python
from django.contrib.auth.models import User
from django.test import TestCase, RequestFactory

from .views import my_view

class SimpleTest(TestCase):
    def setUp(self):
        # Every test needs access to the request factory.
        self.factory = RequestFactory()
        self.user = User.objects.create_user(
            username='jacob', email='jacob@…', password='top_secret')

    def test_details(self):
        # Create an instance of a GET request.
        request = self.factory.get('/customer/details')

        # Recall that middleware are not supported. You can simulate a
        # logged-in user by setting request.user manually.
        request.user = self.user

        # Test my_view() as if it were deployed at /customer/details
        response = my_view(request)
        self.assertEqual(response.status_code, 200)
```

In this example from the Django documentation, I created a request using the factory by providing it a URL. By doing this we test the view as if it was deployed at that URL in `urls.py`. This works because, in practice, views generally don’t look at the URL directly but change their behavior based on the parameters passed to them.

I am also testing as if a user was logged in so I attached the user to the request. I can then call the view function directly with the provided request. In this way I can emulate `AuthenticationMiddleware`. This way is actually better because the view only depends on looking at `request.user` and doesn’t actually depend on the logic in `AuthenticationMiddleware`.

**Update (2015/08/31)**: You can also test class based views this way.

```python
request = self.factory.get('/')
response = MyView.as_view()(request)
```

> _Thanks to Matt Deacalion for the comment_

## Clean, Stable Tests

Testing views this way produces tests that are faster, cleaner, more stable, and have the right dependencies. Because the test only depends on what the view itself depends on, and only tests the logic of the view itself, the tests will be stable and continue to work even when refactoring middleware or `urls.py`.
