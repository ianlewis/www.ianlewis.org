---
layout: post
title: "A Quick Look at the Kubernetes Python Client"
date: 2016-12-06 23:30:00 +0000
permalink: /en/quick-look-kubernetes-python-client
blog: en
tags: tech programming python kubernetes
render_with_liquid: false
translations:
    ja: /jp/kubernetes-python
---

For those of you that don't know there is a new Python API client in the kubernetes-incubator project: [client-python](https://github.com/kubernetes-incubator/client-python). There has been some high quality Python clients like [pykube](https://github.com/kelproject/pykube), but client-python can serve as the official Python client.

## The Structure of the Client

client-python is a client that is mostly generated based on the [swagger spec](http://kubernetes.io/kubernetes/swagger-spec/) ([UI](http://kubernetes.io/kubernetes/third_party/swagger-ui/)). While pykube has the benefit of being totally idiomatic, client-python can support [practically all of the endpoints](https://github.com/kubernetes-incubator/client-python/tree/master/kubernetes#documentation-for-api-endpoints) and react quickly to changes in the API. client-python supports Python 3 and is currently [tested against Python 3.4](https://github.com/kubernetes-incubator/client-python/blob/master/.travis.yml).

## Using the Python API Client

Kubernetes provides a JSON REST API so you can control a Kubernetes cluster from essentially any language. I'm particularly excited about the Python client since Python is one of my favorite languages.

Installation is done in the standard, straitforward way:

```shell
pip install kubernetes
```

After that we can easily import and use the client. There are some simple examples on the project's github page and this one is similar but it illustrates how to use the client. Here I use the `list_namespaced_pod()` method to get all the pods in the `default` namespace and list their name, phase, and pod IP. This is pretty straitforward, and after I get the list object I can iterate over the `items` field to get the list of pods.

The client supports all the API endpoints and provides easy to use objects based on the data returned from the API, but one unfortunate aspect of the client is the sheer number of methods. This is because it creates one per endpoint.

```python
import os
from kubernetes import client, config

config.load_kube_config(
    os.path.join(os.environ["HOME"], '.kube/config'))

v1 = client.CoreV1Api()

pod_list = v1.list_namespaced_pod("default")
for pod in pod_list.items:
    print("%s\t%s\t%s" % (pod.metadata.name,
                          pod.status.phase,
                          pod.status.pod_ip))
```

If we execute the program, we get something like this:

```shell
$ python list_pods.py
nginx-2048367498-2000v  Running 10.236.2.16
nginx-2048367498-a4otw  Running 10.236.0.15
nginx-2048367498-eblzn  Running 10.236.1.20
nginx-2048367498-tqy6j  Running 10.236.2.17
nginx-2048367498-zwkfg  Running 10.236.0.16
```

You can also make use of the watch API also, which is quite nice. This makes it easy to create controllers in Python.

```python
import os
from kubernetes import client, config, watch

config.load_kube_config(
    os.path.join(os.environ["HOME"], '.kube/config'))

v1 = client.CoreV1Api()

stream = watch.Watch().stream(v1.list_namespaced_pod, "default")
for event in stream:
    print("Event: %s %s" % (event['type'], event['object'].metadata.name))
```

```shell
$ python watch_pods.py
Event: ADDED nginx-2048367498-zwkfg
Event: ADDED nginx-2048367498-2000v
Event: ADDED nginx-2048367498-a4otw
Event: ADDED nginx-2048367498-eblzn
Event: ADDED nginx-2048367498-tqy6j
Event: MODIFIED nginx-2048367498-a4otw
Event: MODIFIED nginx-2048367498-zwkfg
```

## What's Next?

Up until now most projects in the Kubernetes ecosystem have been using Go. There are a lot of reasons to use Go, it supports writing asynchronous applications easily, and the only stable first-party API client library is written in Go. Python, however, is a great language in it's own right. It's easy to get started, and will be great for scripting up small bits of cluster automation. The Kubernetes API is really powerful and now it's easier than ever to use from Python. The API client is still an incubator project, but I look forward to seeing more projects written in Python that make deep use of the Kubernetes API. I encourage everyone to try out the Python API client and provide feedback.

If you are interested in learning more about Kubernetes, the Python client I suggest joining the [Kubernetes Slack Channel](http://slack.kubernetes.io/). That's where the best Kubernetes developers get together to discuss Kubernetes. For the Python client specifically, check out the `#sig-api-machinery` in Slack. That's where you can ask questions about the client, and more general questions about the API. You can catch me there as well. I'm `@ianlewis` in the Kubernetes Slack team so feel free to say hi!
