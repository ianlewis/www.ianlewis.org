---
layout: post
title: "Using Kubernetes Health Checks"
date: 2016-05-24 17:50:00 +0000
permalink: /en/using-kubernetes-health-checks
blog: en
render_with_liquid: false
---

I've seen a lot of questions about Kubernetes health checks recently and how
they should be used. I'll do my best to explain them and the difference between
the types of health checks and how each will affect your application.

## Liveness Probes

Kubernetes health checks are divided into liveness and readiness probes. The
purpose of liveness probes are to indicate that your application is running.
Normally your app could just crash and Kubernetes will see that the app has
terminated and restart it but the goal of liveness probes is to catch
situations when an app has crashed or deadlocked without terminating. So a
simple HTTP response should suffice here.

As a simple example here is a health check I often use for my Go applications.

```go
http.HandleFunc("/healthz", func(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("OK"))
}
http.ListenAndServe(":8080", nil)
```

and in the deployment:

```yaml
livenessProbe:
  # an http probe
  httpGet:
    path: /healthz
    port: 8080
  initialDelaySeconds: 15
  timeoutSeconds: 1
```

This just tells Kubernetes that the application is up and running. The
`initialDelaySeconds` tells Kubernetes to delay starting the health checks for
this number of seconds after it sees the pod is started. If your application
takes a while to start up, you can play with this setting to help it out. The
`timeoutSeconds` tells Kubernetes how long it should wait for responses for the
health check. For liveness probes, this shouldn't be very long but you do want
to give your app enough time to respond even in cases where it's under load.

If the app never starts up or responds with an HTTP error code then Kubernetes
will restart the pod. You will want to do your best to not do anything too
fancy in liveness probes since it could cause disruptions in your app if your
liveness probes start failing.

## Readiness Probes

Readiness probes are very similar to liveness probes except that the result of
a failed probe is different. Readiness probes are meant to check if your
application is ready to serve traffic. This is subtly different than
liveness. For instance, say your application depends on a database and
memcached. If both of these need to be up and running for your app to serve
traffic, then you could say that both are required for your app's "readiness".

If the readiness probe for your app fails, then that pod is removed from the endpoints
that make up a service. This makes it so that pods that are not ready will not have
traffic sent to them by Kubernetes' service discovery mechanism. This is really
helpful for situations where a new pod for a service gets started; scale up events, rolling updates, etc. Readiness probes make sure that pods are not sent traffic in the time between when they start up, and and when they are ready to serve traffic.

The definition of a readiness probe is the same as liveness probes. Readiness probes are defined as part of a Deployment like so:

```yaml
readinessProbe:
  # an http probe
  httpGet:
    path: /readiness
    port: 8080
  initialDelaySeconds: 20
  timeoutSeconds: 5
```

You will want to check that you can connect to all of your application's dependencies
in your readiness probe. To use the example where we depend on a database and memcached, we will want
to check that we are able to connect to both.

Here's what that might look like. Here I check memcached and the database and
if one is not available I return a 503 response status.

```go
http.HandleFunc("/readiness", func(w http.ResponseWriter, r *http.Request) {
  ok := true
  errMsg = ""

  // Check memcache
  if mc != nil {
    err := mc.Set(&memcache.Item{Key: "healthz", Value: []byte("test")})
  }
  if mc == nil || err != nil {
    ok = false
    errMsg += "Memcached not ok.¥n"
  }

  // Check database
  if db != nil {
    _, err := db.Query("SELECT 1;")
  }
  if db == nil || err != nil {
    ok = false
    errMsg += "Database not ok.¥n"
  }

  if ok {
    w.Write([]byte("OK"))
  } else {
    // Send 503
    http.Error(w, errMsg, http.StatusServiceUnavailable)
  }
})
http.ListenAndServe(":8080", nil)
```

## More Stable Applications

Liveness and Readiness probes really help with the stability of applications.
They help to make sure that traffic only goes to instances that are ready for
it, as well as self heal when apps become unresponsive. They are a better solution to what my colleage Kelsey Hightower called [12 Fractured Apps](https://medium.com/@kelseyhightower/12-fractured-apps-1080c73d481c). With proper health
checks in place you can deploy your applications in any order without having to
worry about dependencies or complicated entrypoint scripts. And applications
will start serving traffic when they are ready so auto-scaling and rolling
updates work smoothly.
