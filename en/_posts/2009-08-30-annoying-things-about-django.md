---
layout: post
title: "Annoying things about Django"
date: 2009-08-30 13:08:00 +0000
permalink: /en/annoying-things-about-django
blog: en
tags: django models
render_with_liquid: false
---

<!-- textlint-disable rousseau -->

Since I've been using it for a while now I've gotten a good idea about
what is good and what is annoying about development with django. This
might seem a little trite at parts since some of these gripes are with
features that don't exist in other frameworks but in the spirit of
perhaps making django more flexable without ruining it's ease of use
I've come up with some annoying spots and possible ideas for fixing
them.

# New Password Request Time Limit

The new password request time limit can only be specified in days. This
makes it impossible to use if you want to shorten the new password
request time limit to less than 1 day.

# Admin Users / Site users

This is an issue that largely has to do with winning people over rather
than any kind of technical problem but generally people see admin users
and users of the site differently. This means they get really scared
when they log into the admin and they are automatically logged into the
site and vise-versa.

"You mean if you accidentally flip the staff flag (and allow access to
the admin from internet ips) then a regular user could just log into the
admin?". And I have to answer: Yup. This for some reason scares the shit
out of people. I even have other developers who this scares let alone
managers for websites and customers. They see admins and site users as
completely different identities and they expect the login to the admin
and the login to the site to be completely separate.

I know this really messes up django's design and application philosophy.
For instance, with the contrib.auth module you couldn't be logged into
the admin and the site unless you could specify a session cookie on a
per application basis. But isn't there something that could be done? I'm
forced by other folks to basically reimplement the auth module for every
project because there is only one users table.

# GenericForeignKeys Look Awful in the Admin

Generic foreign keys actually consist of two fields, a link to the
content type and the actual key. But these look like crap in the admin
because they are rendered separately and are shown as a dropdown for the
content type and a integer field. It would be nicer if you could specify
which kinds of models were possible as content type targets and provide
a better widget for them.

# send_mail Uses the DEFAULT_ENCODING Setting

We have had to subclass the EmailMessage object with our own message
format to get it to work with encodings other than the
DEFAULT_ENCODING. Email headers are also always encoded in utf8
regardless of the DEFAULT_ENCODING. This is especially annoying when
sending email to Japanese cellphones, which sometimes expect iso-2022-jp
or ShiftJIS rather than whatever your DEFAULT_ENCODING is. And changing
the DEFAULT_ENCODING just because you have to send some one off emails
is out of the question.

# Can't Filter an Admin List via a JOIN. eg. user\_\_group

It would be cool if you could filter an admin list via a join. Something
like:

```python
class MyAdmin(admin.ModelAdmin):
    list_display    = ('name','user')
    list_filter     = ('user__group',)
    model = MyModel
```

That way you could filter MyModel records by group.

# There is no Good Way to Simply View Data/Fields in the Admin

In the admin there is no good way to have view/read only fields on a
form. There are many instances where you would like to show data in the
admin but not allow it to be edited. Create time fields come to mind.
Right now there are workarounds which show the field and add it as a
hidden field in the form. This mostly works but is a crappy workaround
and potential security problem if you have people using the admin who
aren't fully trusted.

# Applications Don't Have Their Own Settings

This means that other applications can't easily add settings (types
etc.) to other applications. This results in situations like
django-notifications where notification types are stored in the database
and need to be added via syncdb. django-notifications does this because
they want other applications to be able to add notification types
easily. They could do that by providing their own settings for things
like notifications.

<!-- textlint-enable rousseau -->
