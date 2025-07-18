---
layout: post
title: "Custom Admin Views and Reversing Django Admin URLs"
date: 2009-08-26 18:08:29 +0000
permalink: /en/reversing-django-admin-urls
blog: en
tags: tech programming python django
render_with_liquid: false
---

I recently used the new feature in Django 1.1 for [reversing django
admin
URLs](http://docs.djangoproject.com/en/dev/ref/contrib/admin/#reversing-admin-urls)
and [specifying custom admin
views](http://docs.djangoproject.com/en/dev/ref/contrib/admin/#adding-views-to-admin-sites)
in my project
[django-lifestream](http://code.google.com/p/django-lifestream-2/).

django-lifestream has a [custom admin
view](http://bitbucket.org/IanLewis/django-lifestream/src/5c632eae0574/lifestream/admin.py#cl-120)
which allows users to update the lifestream manually. The code looks
like the following:

```python
class ItemAdmin(admin.ModelAdmin):
    list_display    = ('title', 'date','published')
    exclude         = ['clean_content',]
    list_filter     = ('feed',)
    search_fields   = ('title','clean_content')
    list_per_page   = 20

    model = Item

    def save_model(self, request, obj, form, change):
        obj.clean_content = strip_tags(obj.content)
        obj.save()

    def admin_update_feeds(self, request):
        from lifestream.feeds import update_feeds
        #TODO: Add better error handling
        update_feeds()
        return HttpResponseRedirect(
                reverse("admin:lifestream_item_changelist")
        )

    def get_urls(self):
        from django.conf.urls.defaults import *
        urls = super(ItemAdmin, self).get_urls()
        my_urls = patterns('',
            url(
                r'update_feeds',
                self.admin_site.admin_view(self.admin_update_feeds),
                name='admin_update_feeds',
            ),
        )
        return my_urls + urls

admin.site.register(Item, ItemAdmin)
```

The key parts are the get_urls function and the admin_update_feeds
view. The get_urls method returns the urls for this admin to which we
are adding our custom view. The custom view does the updating of the
lifestream feeds and returns the user to the Item model's changelist
view. We get the url for that view by calling reverse with the pattern
"\<namespace\>:\<app\>\_\<model\>\_changelist" which in our case is
"admin:lifestream_item_changelist" since the django admin uses the
admin namespace.

I created the button for updating the feeds by overriding the default
admin template with my own [subclassed
template](http://bitbucket.org/IanLewis/django-lifestream/src/tip/lifestream/templates/admin/lifestream/item/change_list.html).
The template like the following:

```django
{% extends "admin/change_list.html" %}
{% load adminmedia admin_list i18n %}

{% block object-tools %}
{% if has_add_permission %}
<ul class="object-tools">
  <li><a href="{% url admin:admin_update_feeds %}">{% blocktrans with cl.opts.verbose_name|escape as name %}Update Items{% endblocktrans %}</a></li>
  <li><a href="add/{% if is_popup %}?_popup=1{% endif %}" class="addlink">{% blocktrans with cl.opts.verbose_name|escape as name %}Add {{ name }}{% endblocktrans %}</a></li>
</ul>
{% endif %}
{% endblock %}
```

Here I'm getting the url for my custom admin view with the code {% url
admin:admin\_update\_feeds %}, "admin_update_feeds" being the name I
supplied in the get_urls method above.
