---
layout: post
title: "Kay 1.1 Released!"
date: 2011-03-07 15:41:01 +0000
permalink: /en/kay-11-released
blog: en
tags: python appengine
render_with_liquid: false
---

The Kay team just just released Kay 1.1\! I want to thank Takashi
Matsuo, Nickolas Daskalou, Tasuku Suenaga, and Yosuke Suzuki for their
hard work on this release.

_Kay is a web framework made specifically for Google App Engine. The
basic design of Kay is based on the Django framework, such as
middleware, settings, pluggable applications, etc. Kay uses Werkzeug as
lower level framework, Jinja2 as template engine, and babel for handling
language translations._

Kay 1.1 contains a number of new features and bug fixes. You can see the
[Release Notes
here](http://code.google.com/p/kay-framework/wiki/ReleaseNotes#Kay-1.1.0rc2_-_March_3rd_2011)
and can [download the release
here](http://code.google.com/p/kay-framework/downloads/list).

We're excited about this release so I would like to introduce a few of
Kay's new features.

# cron_only

Kay has a new utility decorator for securing cron views so they can only
be run by the cron system on Appengine.

```python
@cron_only
def my_cron_view(request):
    # ...
    return response
```

You can see the [documentation for the cron_only decorator
here](http://kay-docs.shehas.net/decorators.html#kay.utils.decorators.cron_only).

# Pagination API

We added a new Pagination API which will allow developers to quickly and
easily implement pagination in their views.

```python
from kay.utils.paginator import Paginator, InvalidPage, EmptyPage
from kay.utils import render_to_response

def listing(request):
    contact_list = Contacts.all()
    paginator = Paginator(contact_list, 25) # Show 25 contacts per page

    # Make sure page request is an int. If not, deliver first page.
    try:
        page = int(request.args.get('page', '1'))
    except ValueError:
        page = 1

    # If page request (9999) is out of range, deliver last page of results.
    try:
        contacts = paginator.page(page)
    except (EmptyPage, InvalidPage):
        contacts = paginator.page(paginator.num_pages)

    return render_to_response('list.html', {"contacts": contacts})
```

Page objects can be used in views to display information about the
current page and item indexes.

```html+django
{% for contact in contacts.object_list %}
{# Each "contact" is a Contact model object. #}
{{ contact.full_name|upper }}<br />
...
{% endfor %}

<div class="pagination">
    <span class="step-links">
        {% if contacts.has_previous %}
            <a href="?page={{ contacts.previous_page_number }}">previous</a>
        {% endif %}

        <span class="current">
            Page {{ contacts.number }} of {{ contacts.paginator.num_pages }}.
        </span>

        {% if contacts.has_next %}
            <a href="?page={{ contacts.next_page_number }}">next</a>
        {% endif %}
    </span>
</div>
```

The Pagination API is designed to make as few Datastore RPC calls as
possible. For instance, if you don't use the `num_pages` or `count`
properties, the Pagination API will not make a count() RPC call.

You can view the [Pagination API documentation
here](http://kay-docs.shehas.net/pagination.html).

# Live Settings

Redeploying applications can create latency spikes in your application
because it requires stopping and restarting all of your application
instances. Kay 1.1 adds a new `kay.ext.live_settings` application which
provides an API for storing global settings that can be changed without
redeploying your application.

Live Settings are stored with a unicode key to unicode value, and work
much like memcached, but provide a fast, persistent, and eventually
consistent way of storing and getting settings. Live Settings can be
changed programmatically:

```python
from kay.ext.live_settings import live_settings

value = live_settings.get("my.settings.key", "default_value")

live_settings.set("my.settings.key", "new-value")
```

Or they can be managed via a custom Admin page:

---

![image](http://static.ianlewis.org/prod/img/652/live_settings.png)

---

You can read the [Live Settings documentation
here](http://kay-docs.shehas.net/extensions.html#module-kay.ext.live_settings)

# AppStatsMiddleware

Kay 1.1 adds a new `AppStatsMiddleware` that allows you to easily enable
[Appstats](http://code.google.com/intl/en/appengine/docs/python/tools/appstats.html).
You simply add the middleware to your `MIDDLEWARE_CLASSES` in order to
enable Appstats.

```python
MIDDLEWARE_CLASSES = (
    # ...
    'kay.ext.appstats.middleware.AppStatsMiddleware',
    # ...
)
```

The `AppStatsMiddleware` can work with the Live Settings API and can be
enabled and disabled without redeploying your application. You can read
the [documentation for the AppStats extension
here](http://kay-docs.shehas.net/extensions.html#module-kay.ext.appstats)

# EReporter

Kay 1.1 adds a new `kay.ext.ereporter` application which will catch and
save information about errors for later viewing and can send out daily
error reports. The EReporter application works much like the [EReporter
in the Appengine
SDK](http://code.google.com/intl/en/appengine/articles/python/recording_exceptions_with_ereporter.html)
but provides a convenient way of viewing the errors via a custom admin
page and integrates with Kay's `ADMINS` and email related settings.

---

![image](http://static.ianlewis.org/prod/img/652/ereporter.png)

---

You can read the [documentation for the EReporter extension
here](http://kay-docs.shehas.net/extensions.html#module-kay.ext.ereporter).

# Conclusion

Kay 1.1 adds a number of new features which we hope will make
development and management of applications on Appengine easier.

As always we would love to hear from you\! Please check out [Kay's
project page](http://code.google.com/p/kay-framework/). We encourage you
to send us bug reports and feature requests via our [issues
page](http://code.google.com/p/kay-framework/issues/list) as well as
give us feedback on the [mailing
list](https://groups.google.com/group/kay-users). We are also looking
forward to Kay 2.0 so if you have any suggestions about any large new
features now is the time to let us know\!

We look forward to hearing feedback about Kay\!
