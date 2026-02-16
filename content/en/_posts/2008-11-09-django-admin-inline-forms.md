---
layout: post
title: "Django admin inline forms"
date: 2008-11-09 01:09:55 +0000
permalink: /en/django-admin-inline-forms
blog: en
tags: tech programming python django
render_with_liquid: false
---

For my new project `dlife` (**Update:** Now
[`django-lifestream`](http://bitbucket.org/IanLewis/django-lifestream/)), I went
about implementing a simple comments interface that would allow users to make
comments on imported feed items. I wanted to support this in the admin in the
typical manner such that when you click on an item in the admin, you can see all
the comments and edit them from the item's page.

I found that you can use [inline
forms](http://docs.djangoproject.com/en/dev/ref/contrib/admin/#inlinemodeladmin-objects)
in the admin but it seems to show a bunch of forms (3 by default) even though I
don't have any comments for the item yet. I'll mess with this more a bit later
to try to get the behavior I want.

```python
# models.py

class Comment(models.Model):
  '''An item comment'''
  comment_item = models.ForeignKey(Item)
  comment_date = models.DateTimeField()
  comment_user = models.ForeignKey(User, null=True, blank=True)
  comment_name = models.CharField(max_length=30)
  comment_email = models.EmailField()
  comment_homepage = models.URLField(max_length=300)
  comment_content = models.TextField(null=True, blank=True)

  class Meta:
    db_table="comments"
    ordering=["comment_item", "-comment_date"]
```

```python
# admin.py

class CommentInline(admin.StackedInline):
  model           = Comment
  max_num         = 1   #TODO: Fix this
  exclude         = ['comment_item','content_type','object_id']

class ItemAdmin(admin.ModelAdmin):
  list_display    = ('item_title', 'item_date')
  exclude         = ['item_clean_content',]
  list_filter     = ('item_feed',)
  search_fields   = ('item_title','item_clean_content')
  list_per_page   = 20

  inlines         = [CommentInline,]
```
