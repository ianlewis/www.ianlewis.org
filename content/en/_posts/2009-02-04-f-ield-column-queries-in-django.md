---
layout: post
title: "Field/column Queries in Django"
date: 2009-02-04 23:24:38 +0000
permalink: /en/f-ield-column-queries-in-django
blog: en
tags: tech programming python django
render_with_liquid: false
---

One of the neat things making it's way into Django 1.1 is [F object
queries](http://docs.djangoproject.com/en/dev/topics/db/queries/#filters-can-reference-fields-on-the-model).
The F object is kind of like the Q object as it can be used it queries but it
represents a database field on the right hand side of an equality/inequality.

For the example I'll use the example models from the "[Making Queries](http://docs.djangoproject.com/en/dev/topics/db/queries/)" section of the Django Documentation.

```python
class Blog(models.Model):
    name = models.CharField(max_length=100)
    tagline = models.TextField()

    def __unicode__(self):
        return self.name

class Author(models.Model):
    name = models.CharField(max_length=50)
    email = models.EmailField()

    def __unicode__(self):
        return self.name

class Entry(models.Model):
    blog = models.ForeignKey(Blog)
    headline = models.CharField(max_length=255)
    body_text = models.TextField()
    pub_date = models.DateTimeField()
    authors = models.ManyToManyField(Author)
    n_comments = models.IntegerField()
    n_pingbacks = models.IntegerField()
    rating = models.IntegerField()

    def __unicode__(self):
        return self.headline
```

Here we can do cool stuff like query for blog entries where the number of comments equals the number of pingbacks.

```python
>>> from django.db.models import F
>>> Entry.objects.filter(n_pingbacks__lt=F('n_comments'))
```

You can perform operations on columns or add columns together.

```python
>>> Entry.objects.filter(n_pingbacks__lt=F('n_comments') * 2)
>>> Entry.objects.filter(rating__lt=F('n_comments') + F('n_pingbacks'))
```

You can even span relationships across tables.

```python
>>> Entry.objects.filter(author__name=F('blog__name'))
```

This query ended up like this. ftester is the name of the application I made to test this.

```sql
SELECT `ftester_entry`.`id`, `ftester_entry`.`blog_id`, `ftester_entry`.`headline`, `ftester_entry`.`body_text`, `ftester_entry`.`pub_date`, `ftester_entry`.`n_comments`, `ftester_entry`.`n_pingbacks`, `ftester_entry`.`rating` FROM `ftester_entry` INNER JOIN `ftester_blog` ON (`ftester_entry`.`blog_id` = `ftester_blog`.`id`) INNER JOIN `ftester_entry_authors` ON (`ftester_entry`.`id` = `ftester_entry_authors`.`entry_id`) INNER JOIN `ftester_author` ON (`ftester_entry_authors`.`author_id` = `ftester_author`.`id`) WHERE `ftester_author`.`name` =  `ftester_blog`.`name` LIMIT 21
```

> Note: As an aside it's interesting to note the limit on this query which
> actually only gets 21 records. I haven't tested it but I suppose that Django
> only gets a set of records at a time for performance reasons.

But the reason the F() object was created was to allow using the value of one
column in another column during an update. This allows you do do things like
add 1 to the pingbacks for every entry in one go without selecting the whole
batch and updating the field.

```python
Entry.objects.all().update(n_pingbacks=F('n_pingbacks') + 1)
```
