---
layout: post
title: "Writing Schema migrations for Appengine using the Mapper Class and the deferred Library"
date: 2009-12-27 13:59:03 +0000
permalink: /en/writing-schema-migrations-appengine-using-mapper-c
blog: en
---

One thing that many people using appengine know is that writing schema
migrations is hard. Improving performance on Appengine often revolves
around getting objects by key or key name rather than using filters,
however altering the makeup of an objects key requires pulling all the
objects and saving them in the datastore anew. This also requires
modifying the ReferenceProperties of any objects pointing to your
changed object. On top of that, schema migrations generally require
modifying lots of data and you have limits on the number of objects
returned by a filter, and request timeouts to worry about.

Fortunately, the Appengine SDK provides a task queue and a very
convenient way of using it in the [deferred
library](http://code.google.com/appengine/articles/deferred.html). The
deferred library allows you to set a function to be run by the task
queue in the background. This coupled with the Mapper class provided in
the article make for a powerful way to process large amounts of data in
a safe way. Unfortunately, there are a couple bugs with in the Mapper
class provided in the article. It's missing a couple imports, doesn't
save data properly and throws errors when there is no data to be
processed. I have provided an updated version of the Mapper class here.

``` python
from google.appengine.ext import db

from google.appengine.ext import deferred
from google.appengine.runtime import DeadlineExceededError

class Mapper(object):
    # Subclasses should replace this with a model class (eg, model.Person).
    KIND = None

    # Subclasses can replace this with a list of (property, value) tuples to filter by.
    FILTERS = []

    def __init__(self):
        self.to_put = []
        self.to_delete = []

    def map(self, entity):
        """Updates a single entity.

        Implementers should return a tuple containing two iterables (to_update, to_delete).
        """
        return ([], [])

    def finish(self):
        """Called when the mapper has finished, to allow for any final work to be done."""
        self._batch_write()

    def get_query(self):
        """Returns a query over the specified kind, with any appropriate filters applied."""
        q = self.KIND.all()
        for prop, value in self.FILTERS:
            q.filter("%s =" % prop, value)
        q.order("__key__")
        return q

    def run(self, batch_size=100):
        """Starts the mapper running."""
        self._continue(None, batch_size)

    def _batch_write(self):
        """Writes updates and deletes entities in a batch."""
        if self.to_put:
            db.put(self.to_put)
            self.to_put = []
        if self.to_delete:
            db.delete(self.to_delete)
            self.to_delete = []

    def _continue(self, start_key, batch_size):
        q = self.get_query()
        # If we're resuming, pick up where we left off last time.
        if start_key:
            q.filter("__key__ >", start_key)
        # Keep updating records until we run out of time.
        try:
            # Steps over the results, returning each entity and its index.
            i = None 
            for i, entity in enumerate(q):
                map_updates, map_deletes = self.map(entity)
                self.to_put.extend(map_updates)
                self.to_delete.extend(map_deletes)
            # Do updates and deletes in batches.
            if i is not None and (i + 1) % batch_size == 0:
                self._batch_write()
            # Record the last entity we processed.
                start_key = entity.key()
        except DeadlineExceededError:
            # Write any unfinished updates to the datastore.
            self._batch_write()
            # Queue a new task to pick up where we left off.
            deferred.defer(self._continue, start_key, batch_size)
            return
        self.finish()
```

The Mapper class processes all object by default but you can add filters
using the FILTERS property to only select certain objects. Creating a
Mapper class is easy, you just implement the map() method (and
optionally override the finish method) and return a two tuple containing
a list of objects to update/create and a list of objects to delete.
These objects are then saved in batch automatically by the Mapper class.

Lets create a simple Mapper implementation to update the schema for a
Model.

``` python
from google.appengine.ext import deferred

from mapper import Mapper
from mymod import MyModel

class MyModelMapper(Mapper):
    KIND = MyModel

    def map(self, entity):
        if entity.key().name():
            return ([], [])

        new_entity = MyModel(
            key_name = str(entity.key().id()),
            value = entity.value,
        )

        return ([new_entity], [entity])

def run_migration():
    m = MyModelMapper()
    deferred.defer(m.run)
```

This mapper migrates the data for of the MyModel type to using key names
instead of numeric ids. Of course if any other objects referred to your
MyModel objects you would need to alter those too but this demonstrates
some of the things you can to with the Mapper class. Here you would just
need to run the run\_migration() method and it would add the mapper to
the task queue to be run in the background.
