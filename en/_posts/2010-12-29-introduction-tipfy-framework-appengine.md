---
layout: post
title: "An introduction to the Tipfy Framework for Appengine"
date: 2010-12-29 10:31:34 +0000
permalink: /en/introduction-tipfy-framework-appengine
blog: en
---

*(This post is the English translation of the Dec. 24th edition of the*
[Python Web Framework Advent
Calendar 2010](http://atnd.org/events/10465). *Other posts can be found
at: http://atnd.org/events/10465 though they will be in Japanese)*

I usually use the [kay
framework](http://code.google.com/p/kay-framework/) for Appengine
development as I am a developer for the framework, but recently I have
been playing with the [Tipfy](http://www.tipfy.org/) framework
(<http://www.tipfy.org>) written by Rodrigo Moraes. Like Kay, Tipfy is a
framework made specifically for Google Appengine. While Kay has drawn a
lot of it's functionality from [Django](http://www.djangoproject.com),
Tipfy attempts to be as close to the Appengine SDK's [Webapp
Framework](http://code.google.com/intl/en/appengine/docs/python/gettingstarted/usingwebapp.html).

# Install

Tipfy uses the [buildout](http://www.buildout.org/) framework to manage
dependencies and deployment. Installation is covered in the [Tipfy
Guide's Installation
Page](http://www.tipfy.org/wiki/guide/installation/).

First you need to download the [Tipfy "Do-it-yourself
pack"](http://www.tipfy.org/tipfy.zip).

``` text
$ wget http://www.tipfy.org/tipfy.zip
$ unzip tipfy.zip
```

Next, you will need to create the buildout environment. Buildout will
download and install the Appengine SDK and everything you need to get
started from [pypi](http://pypi.python.org/).

``` text
$ cd project
$ python2.5 bootstrap.py --distribute
$ ./bin/buildout
```

After that is over, you can run the development server by running the
`dev_appserver` command found in the `bin` directory.

``` text
$ ./bin/dev_appserver
```

# Directory Structure

At this point, you can explore the directory structure of the Tipfy
project. You can find out more about this in the [Tipfy
Documentation](http://www.tipfy.org/wiki/guide/sitelayout/#default-site-structure).

``` text
app/ - GAE application
    apps/ - application modules
        hello_world - A default "Hello World" application
    lib/ - Third party libraries
    distlib/ - Libraries installed by buildout (buildout clears this directory every time buildout is run)
    locale/ - Translation files
    static/ - Static media files
    templates/ - HTML templates
    main.py - The main() entry point
    app.yaml - GAE application's app.yaml
    config.py - Application settings
    urls.py - URL routing
eggs/ - Python Eggs (libraries) required for development
etc/ - Settings files requried for development
    develop-eggs - Development libraries required by buildout
    downloads - Downloads (appengine SDK etc)
    parts - buildout development parts (required for buildout recipies)
bootstrap.py - buildout bootstrap script
buildout.cfg - buildout settings file
babel.cfg - translations settings file
gaetools.cfg - Settings for the GAE SDK recipe (e.g. default settings for the dev_server) 
versions.cfg - Third party library versions (empty by default)
```

# Settings

Settings are managed in the `app/config.py` file. These settings are
contained in a python dictionary object called `config`. You can find
out more in the [Tipfy documentation for
configuration](http://www.tipfy.org/wiki/guide/configuration/).

Settings for third party modules are stored in a key specified by the
module name. For instance the configuration for Tipfy's extension that
provides support for sessions is stored in the key `tipfy.ext.session`.

`apps_installed` is a list of application modules. This is similar to
Django in that each application can provide it's own handlers and URL
routing rules. Tipfy also allows for applications to provide default
configuration.

``` python
# Configurations for the 'tipfy' module.
config['tipfy'] = {
    # Enable debugger. It will be loaded only in development.
    'middleware': [
        'tipfy.ext.debugger.DebuggerMiddleware',
    ],
    # Enable the Hello, World! app example.
    'apps_installed': [
        'apps.hello_world',
    ],
}
config['tipfy.ext.session'] = {
    'secret_key': '<Secret Key>',
}
```

# URL Routing

URL routing is specified in the `app/urls.py` module in the base of the
project. The default `urls.py` will load all URL routing rules for
installed applications. Applications can provide URL routing rules
similarly to the base rules by implementing a function called
`make_rules()` which returns a list of Rule objects. You can find out
more by reading the [Tipfy documentation on URL
routing](http://www.tipfy.org/docs/api/tipfy.html#url-routing)

This is what the default `app/apps/hello_world/urls.py` looks like:

``` python
from tipfy import Rule

def get_rules(app):
    """Returns a list of URL rules for the Hello, World! application.

    :param app:
        The WSGI application instance.
    :return:
        A list of class:`tipfy.Rule` instances.
    """
    rules = [
        Rule('/', endpoint='hello-world', handler='apps.hello_world.handlers.HelloWorldHandler'),
        Rule('/pretty', endpoint='hello-world-pretty', handler='apps.hello_world.handlers.PrettyHelloWorldHandler'),
    ]

    return rules
```

# Request Handlers

Request handlers implement the application logic by processing HTTP
requests. These request handlers are very similar to the SDK's webapp
framework. Tipfy uses [Jinja2](http://jinja.pocoo.org/) for templating
by default.

``` python
from tipfy import RequestHandler, Response
from tipfy.ext.jinja2 import render_response

class HelloWorldHandler(RequestHandler):
    def get(self):
        """Simply returns a rendered template with an enigmatic salutation."""
        return render_response('hello_world.html', message='Hello, World!')
```

# Using Request Handler Mixins

You can add functionality to request handlers by using
[Mixins](http://en.wikipedia.org/wiki/Mixin). Mixins are classes that
are meant to be extended along with other classes to allow mixing and
matching of class features.

Usually you wouldn't add these mixins for every request handler but have
a base request handler you use for your project that inherits from the
Mixins you need for your project. However, you may have some cases where
you would use mixins only for specific request handlers.

Here we will add support for session handling by adding the appropriate
Mixins to our `BaseHandler` class:

``` python
from tipfy import RequestHandler, Response
from tipfy.ext.jinja2 import Jinja2Mixin 
from tipfy.ext.session import SecureCookieMixin, SessionMixin 

class BaseHandler(RequestHandler, Jinja2Mixin, SecureCookieMixin, SessionMixin):
    middleware = ['tipfy.ext.session.SessionMiddleware']

class HelloWorldHandler(BaseHandler):
    def get(self):
        """Simply returns a rendered template with an enigmatic salutation."""
        return self.render_response('hello_world.html',
            message='Hello, World!',
            somevalue=self.session.get('somevalue')
        )
```

# Extension modules

The `tipfy.ext` modules is an extension namespace module which allows
development of external third party extension modules. These modules can
be added to your project as needed so that they don't end up cluttering
the framework. For instance, handlers for receiving e-mail, and i18n
support are contained in the `tipfy.ext` module. The extensions
installed by default can be found in the `app/distlib/tipfy/ext`
directory.

You can find out more by reading these pages in the Tipfy documentation:

1.  [Extension
    pages](http://www.tipfy.org/wiki/extensions/#extension-pages)
2.  [Adding Or Removing
    Extensions](http://www.tipfy.org/wiki/guide/extensions/#adding-or-removing-extensions)
3.  [Creating
    Extensions](http://www.tipfy.org/wiki/guide/extensions/create/#creating-extensions)

# Conclusion

The use of Mixins, standard python packaging and idioms might be a bit
hard to understand for newcomers to Python (There are many who are using
python for the first time on Appengine). However, given that appengine
projects require all the needed python code to be contained within the
project directory, the use of buildout to allow developers to distribute
and add packages is one of Tipfy's strengths. Tipfy's use of Mixins also
allows code to be divided and reused based on functionality, allowing
developers to add only the required code and modules to their project.

I think that the Kay framework has a lot to learn from the Tipfy project
and I suspect that we will be integrating many of the ideas in Tipfy in
the future.
