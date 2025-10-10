---
layout: post
title: "Transactions on App Engine"
date: 2009-03-19 01:44:52 +0000
permalink: /en/transactions-on-appengine
blog: en
tags: tech programming python google appengine
render_with_liquid: false
---

The way to store data on [App Engine](http://code.google.com/appengine/) is with
Google's [BigTable
Datastore](http://code.google.com/appengine/docs/python/datastore/) which has
support for transactions. However, the transactions are quite limited in that,

1. You can only execute callables inside transactions. Which means you
   basically call `run_in_transaction()` on a function. This can sometimes be a
   pain but can generally be worked around with decorators and the like.

    ```python
    def my_update_function():
      # Some update code here
      ent.put()

    run_in_transaction(my_update_function)
    ```

2. You can only update entities in the same entity group. This means all
   entities must be in the same ancestor tree. This can make updating entities
   with various relationships hard or impossible to do in a general way in a
   transaction.

3. You cannot do filters in a transaction. This means you cannot do any kind of
   select, _period_. This means you cannot do the following:

    ```python
    class ModelA(db.Model):
      pass

    class ModelB(db.Model):
      modela = ReferenceProperty(ModelA)

    def update_func():
      # Sorry this won't work
      modelas = ModelA.all()

      # This is the only thing that works
      modela = ModelA.get_by_id(123)

      # Jeez, you can't do this either!
      modelb = ModelB.filter('modela =', modela)
    ```

    You can only do gets based on the key of an entity. Which means if you have
    a relationship like the one above you need to be able to derive the key to
    ModelB given the key for ModelA. And since you cannot chose numeric keys with
    which to save entities (numeric keys are always assigned), you will need to
    assign
    [key names](http://code.google.com/appengine/docs/python/datastore/keysandentitygroups.html#Kinds_Names_and_IDs)
    for both entities.

All this makes transactions a bit of a pain in
[App Engine](http://code.google.com/appengine/) but workable if you put a bit of
effort into it. In the end you'll want to use key names for most every entity
that matters as current backup solutions for App Engine rely on key names to
maintain the keys of entities when backing up and restoring. It wouldn't be to
fun if all the urls for an entity that had numeric ids changed after restoring
the data from a backup.
