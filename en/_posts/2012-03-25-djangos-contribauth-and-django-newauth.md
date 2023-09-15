---
layout: post
title: "Django's contrib.auth and django-newauth"
date: 2012-03-25 12:06:56 +0000
permalink: /en/djangos-contribauth-and-django-newauth
blog: en
---

Recently there have been a lot of conversations on the Django mailing
list about fixing the auth module. Here are some of the recent mailing
list threads:

1.  [authentication by
    email](https://groups.google.com/forum/?fromgroups#!topic/django-developers/YcFTAaidiL4)
2.  [auth.User refactor:
    reboot](https://groups.google.com/forum/?fromgroups#!topic/django-developers/ba21QMpffZs)
3.  [auth.User: The abstract base class
    idea](https://groups.google.com/forum/?fromgroups#!topic/django-developers/Na0AmIGSGQA)

Originally the topic came up because of the fact that you can't really
authenticate effectively using the email address as a username. The
username field is currently required and only allows for 30 characters
which is too short for an email. Developers can put a unique dummy value
in the username field and just use the email field to authenticate the
user but it's really a work around.

However one fixes this though there will be many unhappy people because
everyone wants something different. It's a problem ripe for
customization, but there is a really hard dependency on contrib.auth's
current api.

# contrib.auth sucks

My company, BeProud, ran into problems with auth early on and really
haven't ever used it. We used to implement an auth solution for every
project we worked on but that was just simply wasted work and prone to
security bugs. A reusable solution was needed, but since Django's auth
was so tied to the admin and had concrete models we just couldn't expand
on it. The high-level reasons we never used auth were as follows:

1.  We do custom contract development. We don't often have the choice of
    designing the system around what is convenient to do with the
    framework. We have some leeway but we usually need to implement the
    client's specs.
2.  Even if we could, we don't want to have to design systems around the
    framework.

The detailed explanation:

1.  **Keeping admin users and normal site users in the same table was
    just a non-starter**: Customers got very nervous when we told them
    about the fact that they would be logged into the admin if they
    logged into the site itself. To their (perhaps non-technical minds)
    the admin was a completely separate system and users and logins were
    fundamentally different and managed separately. The fact that normal
    users couldn't log into the admin without an is\_staff flag set to
    true was lost on them. Being in Japan it may be perhaps a cultural
    problem but the fact that Django mandates that behaviour made it
    very difficult for us to use contrib.auth
2.  **Contrib auth's model was set in stone and couldn't be changed**:
    Often we would make systems where users logged in only using Twitter
    auth, or email or whatever. Django's auth.User came with lots of
    cruft that just wasn't needed or wanted. The size and uniqueness of
    fields often had to be worked around. We would get specific
    requirements for the size of a username field which just wasn't
    modifiable with auth.User. etc. We wanted a solution where the
    fields on the user model were not set in stone and could be decided
    by the developer. No working around the existing fields on
    auth.User. No get\_profile() on every damn request because one field
    on the profile was needed every request.
3.  **Permissions are included with contrib auth but are pretty much
    useless to us**: We never used them in a project and they pretty
    much just existed for the admin as far as we were concerned. Having
    authentication and authorization in the same module was annoying at
    best and we often had to build custom solutions anyway. No benefit
    to using contrib.auth here. Ideally permissions would be a separate
    module.
4.  **We sometimes needed multiple user models**: We had more than a
    couple projects were multiple user types were needed. On particular
    site required us to have two separate logins for normal site users
    and for affiliate users. The registration process for both was
    different. You didn't need to be a site user to be an affiliate. It
    just didn't make sense to me that there needed to be only one user
    model. I thought that any model that met the user model contract
    could use the auth machinery.

# newauth

Without a solution we could use we were forced to either implement a
solution for every project or come up with something that met our
requirements and could be reused. This led to be developing what became
my proposal for a django auth system, django-newauth.

# Motivation + Future

django-newauth was a simple module rename and cleanup for a project that
I developed for our internal use. Newauth is meant as a proposal or
reference for new contrib.auth changes but I may decide to continue
working on it. I released it quickly so I really don't want that to
necessarily be a dead set API. I still see it as a work in progress. I'm
really excited about the positive response it got and the discussion it
generated, even if none of the code makes it into Django proper.

Anyone who would like to take a look can check out the
[documentation](http://ianlewis.bitbucket.org/django-newauth/). Anyone
wanting to check out the code or or work on fixing some of the issues
with newauth can fork the project on
[bitbucket](https://bitbucket.org/IanLewis/django-newauth) or
[github](https://github.com/IanLewis/django-newauth).
