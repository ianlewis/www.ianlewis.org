---
layout: post
title: "App Engine Pull Queues and kombu"
date: 2013-11-05 02:00:00 +0000
permalink: /en/app-engine-pull-queues-and-kombu
blog: en
tags: tech programming python cloud google-cloud appengine
render_with_liquid: false
---

App Engine provides a [pull queue API](https://developers.google.com/appengine/docs/python/taskqueue/overview-pull)
for accessing, leasing, and processing tasks outside of App Engine. You might
do this to perform long running tasks that aren't suited to App Engine's
infrastructure. Or you might want to use a library or system that isn't
available on App Engine. However, the way you would interact with pull queue is
via a REST API. There isn't much in the way of APIs for actually polling the
API, processing the task, and acknowledging to the API that the task is
finished.

I am a fan of Python and so I often use a task queue system called [Celery](http://www.celeryproject.org/). This system or framework provides a full
task queue worker that can use a number of messaging exchanges for getting the
tasks. This is achieved using a library called [kombu](http://kombu.readthedocs.org/) which provides backends for a number of
messaging systems. So I sought to see if it was possible to use Celery as a
background task worker for the pull queue API.

While I couldn't get full Celery support working because of limitations with
the API, I did get a fully functioning kombu backend working which developers
could use, in combination with the standard multiprocessing module, to easily
create a task worker.

I've put the code up on github so you can take a look at it there. It's
available for use under the MIT License.

[`https://github.com/IanLewis/kombu-appengine-pullqueue`](https://github.com/IanLewis/kombu-appengine-pullqueue)

## Installing

You can install the package directly from github:

```shell
pip install -e git+git://github.com/IanLewis/kombu-appengine-pullqueue.git#egg=kombu-appengine-pullqueue
```

## Setup

Some setup is required because you need to authenticate with the task queue
API. You can do that with a tool provided in the distribution. This will create
a credentials file that will be used to authenticate the API.

```shell
pullqueue_authenticate client_secrets.json credentials
```

## Inserting Tasks

After you do that you can insert tasks the normal way on App Engine via the App
Engine SDK:

```python
import json
from google.appengine.api import taskqueue

q = taskqueue.Queue('pull-queue')
payload_str = json.dumps({'message': 'hello world'})
q.add([taskqueue.Task(payload=payload_str, method='PULL')])
```

Or you can use kombu to add tasks. Here I'll assume you are on App Engine and
are storing your credentials on a datastore entity:

```python
from kombu import Connection
from oauth2client.appengine import StorageByKeyName

credentials_storage = StorageByKeyName(CredentialsModel, 'my_key_name', 'credentials')

conn = Connection(
    transport="kombu_appengine:Transport",
    transport_options={
        'project_name': "my_project",
        'credentials_storage': credentials_storage,
    }
)

with conn:
    queue = conn.SimpleQueue('queue_name')
    queue.put(json.dumps({'message': 'hello world'}))
```

## Processing Tasks

You process tasks by leasing the data from the pull queue, processing the task,
and deleting the task once finished. Here is a simple example. I'm assuming you
are running outside of App Engine so credentials are loaded from a file.

We use the `SimpleQueue` class which is part of kombu. It provides a very
simple queue interface that is much like the standard python `Queue` class.

```python
import logging
from kombu import Connection
from oauth2client.file import Storage

logger = logging.getLogger(__name__)

def worker(transport_options):
    conn = Connection(
        transport="kombu_appengine:Transport",
        transport_options=transport_options,
    )

    with conn:
        queue = conn.SimpleQueue('pull-queue')

        # Simply loop forever, processing tasks as they come.
        while True:
            # If there are no tasks, we block here.
            message = queue.get()
            logger.info("Got new task: %s", message)

            payload = json.loads(message.body)
            process_task(payload)

            # ACK the task so it get's deleted.
            message.ack()
            logger.info("Task completed: %s", message)

worker({
    'project_name': 'my_project',
    'num_tasks': 10,
    'credentials_storage': Storage('/path/to/credentials'),
})
```

## A Simple Multiprocess Worker

We can expand upon the example above and create a worker that spawns a number
of processes to run tasks in parallel. We'll use the same worker function from
above. We just create a number of processes that call the worker function.

```python
import multiprocessing

from oauth2client.file import Storage

logger = logging.getLogger(__name__)

def main(project_name, num_processes=None, buffer_size=None, polling_interval=None):
    """
    Main process for coordinating workers.
    """
    transport_options={
        'project_name': project_name,
        'num_tasks': buffer_size,
        'credentials_storage': Storage('credentials'),
    }
    if polling_interval:
        transport_options['polling_interval'] = polling_interval

    if not num_processes:
        num_processes = multiprocessing.cpu_count() * 2 + 1

    print("Starting %s workers." % num_processes)

    processes = [Process(target=worker, args=(transport_options,)) for i in range(num_processes)]

    try:
        for process in processes:
            process.start()

        for process in processes:
            process.join()
    except (KeyboardInterrupt, Exception):
        logging.exception("Error")
        print('Terminating workers...')
        for process in processes:
            process.terminate()
    finally:
        print('Exiting.')
        return

main('my_project', buffer_size=10)
```

Perhaps a little more should be done to better allow for failures, but this
should go a long way towards allowing you to process tasks from the pull queue
API.

The kombu backend should make it a bit easier to create a worker that polls the
pull task queue API and process tasks. I hope you find it useful. If you have
any feedback please let me know. Pull requests are also welcome ;-)
