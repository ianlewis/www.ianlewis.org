---
layout: post
title: "Cross-Region HTTP Services on Container Engine"
date: 2015-08-06 02:00:00 +0000
permalink: /en/cross-region-http-services-container-engine
blog: en
tags: kubernetes google-container-engine
render_with_liquid: false
---

<!--
Conversion notes (using libgdc version 59):

  * source doc: https://docs.google.com/a/google.com/open?id=1GReoH2_4DGMcSH-kZwsYi8kDWR3M2Vw_8NgvcX0yy70

General notes:
  * NOTE: Check tables and code blocks for accurate conversion.
  * Check for XXX image in any img tags.
  * Please report any bugs (See go/gdocs-convert for more information).
    Note in bug report that this is libgdc version 59.
  * doMarkdown(): 4.346 seconds.
-->

We recently released a new [tutorial](https://cloud.google.com/container-engine/docs/tutorials/http-balancer) on using Google Cloud Platform’s HTTP load balancer with Container Engine.
This is really exciting because it opens up lots of possibilities based on the
features of the HTTP load balancer. The HTTP load balancer enables you to route
traffic to different backends (Container Engine clusters, normal Compute Engine
instances, etc.) based on the URL. But, the most interesting feature of the
HTTP load balancer is that it provides a global IP address and routes traffic
to the closest instances in the backend.

This article is very similar to the new HTTP load balancer tutorial, but it
explains how to use the load balancer across regions. Follow the steps below
to see how cross-region HTTP load balancing works with Container Engine.

## Create the Cluster

Start by creating two Container Engine clusters in different zones. Since I’m
from the U.S. but live in Japan, I’ll create one in the U.S. and one in APAC.

```shell
gcloud beta container clusters create us-cluster \
  --zone=us-central1-b
gcloud beta container clusters create asia-cluster \
  --zone=asia-east1-b
```

## Run the Service

Start an [nginx](http://nginx.org/) server with a replication controller in each cluster and expose it as a
service. You need to change the context used by kubectl so that it connects to
the right cluster.

```shell
kubectl config use-context gke_${PROJECT}_us-central1-b_us-cluster
kubectl run my-nginx \
  --image=nginx \
  --port=80
kubectl expose rc my-nginx \
  --target-port=80 \
  --type=NodePort
```

After creating the cluster and running the service, the first thing you’ll do
is set up some variables that you’ll use later. You are getting the exposed
port for the service, the cluster’s instance group name, and instance tag name
for each region.

```shell
export US_NODE_PORT=$(kubectl get -t "{{(index .spec.ports 0).nodePort}}"
services my-nginx)

export US_GROUP_NAME=$(basename `gcloud beta container clusters describe us-cluster --zone us-central1-b | grep gke | awk '{print $2}'`)
export US_NODE_TAG=`echo $US_GROUP_NAME | sed 's/group/node/'`
export US_POD_NAME=`kubectl get -t "{{(index .items 0).metadata.name}}" pods`
```

Then do all that for the Asia cluster as well:

```shell
kubectl config use-context gke_${PROJECT}_asia-east1-b_asia-cluster
kubectl run my-nginx \
  --image=nginx \
  --port=80
kubectl expose rc my-nginx \
  --target-port=80 \
  --type=NodePort

export ASIA_NODE_PORT=$(kubectl get -t "{{(index .spec.ports 0).nodePort}}" services my-nginx)
export ASIA_GROUP_NAME=$(basename `gcloud beta container clusters describe asia-cluster --zone asia-east1-b | grep gke | awk '{print $2}'`)
export ASIA_NODE_TAG=`echo $ASIA_GROUP_NAME | sed 's/group/node/'`
export ASIA_POD_NAME=`kubectl get -t "{{(index .items 0).metadata.name}}" pods`
```

## Set Up the HTTP Load Balancer

Add the HTTP service to the instance group:

```shell
gcloud preview instance-groups add-service ${US_GROUP_NAME} \
  --zone us-central1-b \
  --port ${US_NODE_PORT} \
  --service http
gcloud preview instance-groups add-service ${ASIA_GROUP_NAME} \
  --zone asia-east1-b \
  --port ${ASIA_NODE_PORT} \
  --service http
```

Next, create a health check and add the backend service for the load balancer:

```shell
gcloud compute http-health-checks create http-basic-check
gcloud beta compute backend-services create web-map-backend-service \
  --protocol HTTP \
  --port-name http \
  --http-health-check http-basic-check
```

Create a backend for the instance groups for each cluster:

```shell
gcloud beta compute backend-services add-backend web-map-backend-service \
  --balancing-mode UTILIZATION \
  --max-utilization 0.8 \
  --capacity-scaler 1 \
  --group ${US_GROUP_NAME} \
  --zone us-central1-b
gcloud beta compute backend-services add-backend web-map-backend-service \
  --balancing-mode UTILIZATION \
  --max-utilization 0.8 \
  --capacity-scaler 1 \
  --group ${ASIA_GROUP_NAME} \
  --zone asia-east1-b
```

Create a URL map, proxy, and forwarding rules for the load balancer. You don’t
have execute these commands for each region because they act on the global HTTP
load balancer:

```shell
gcloud beta compute url-maps create web-map \
  --default-service web-map-backend-service
gcloud beta compute target-http-proxies create http-lb-proxy \
  --url-map web-map
gcloud beta compute forwarding-rules create http-content-rule \
  --global \
  --target-http-proxy http-lb-proxy \
  --port-range 80
```

## Firewall Rules

Finally, allow HTTP traffic to your instances by setting up firewall rules for
each cluster’s instance group:

```shell
gcloud compute firewall-rules create nginx-http-us \
  --allow tcp:${US_NODE_PORT} \
  --target-tags ${US_NODE_TAG}
gcloud compute firewall-rules create nginx-http-asia \
  --allow tcp:${ASIA_NODE_PORT} \
  --target-tags ${ASIA_NODE_TAG}
```

## Access the Service

You can now get the IP address of your service. Accessing this IP address in
your browser should give you the default nginx page.

```shell
$ gcloud compute forwarding-rules list
NAME              REGION IP_ADDRESS      IP_PROTOCOL TARGET
http-content-rule        107.178.219.122  TCP         http-lb-proxy
```

![Nginx](/assets/images/741/nginx.png)

You can then verify that your requests are going to the appropriate backend by
viewing the logs for the nginx container.

```shell
kubectl config use-context gke_${PROJECT}_us-central1-b_us-cluster
kubectl logs $US_POD_NAME
kubectl config use-context gke_${PROJECT}_asia-east1-b_asia-cluster
kubectl logs $ASIA_POD_NAME
```

The HTTP load balancer is a global load balancer so it will route traffic
automatically to the closest kubernetes cluster. In my case I saw that my
traffic was going to the pod in Asia:

```shell
$ kubectl logs $ASIA_POD_NAME
...
10.240.70.87 - - [29/Jul/2015:06:47:03 +0000] "GET / HTTP/1.1" 200 612 "-"
"Google-GCLB/1.0" "-"
10.240.48.94 - - [29/Jul/2015:06:47:03 +0000] "GET / HTTP/1.1" 304 0 "-"
"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_4) AppleWebKit/537.36 (KHTML,
like Gecko) Chrome/44.0.2403.107 Safari/537.36" "72.14.229.161,
107.178.245.158"
10.4.1.1 - - [29/Jul/2015:06:47:03 +0000] "GET / HTTP/1.1" 200 612 "-"
"Google-GCLB/1.0" "-"
...
```

If the health check fails for one of the clusters, the HTTP load balancer will
automatically reroute traffic to the healthy cluster.

Let’s shut down the pods in the closest cluster and see what happens:

```shell
kubectl config use-context gke_${PROJECT}_asia-east1-b_asia-cluster
kubectl delete rc my-nginx
```

Now if I access the IP for the load balancer again and check the logs I can see
that the request was routed to the US cluster:

```shell
$ kubectl logs $US_NODE_NAME
...
10.20.2.1 - - [29/Jul/2015:08:55:30 +0000] "GET / HTTP/1.1" 200 612 "-"
"Google-GCLB/1.0" "-"
10.240.239.252 - - [29/Jul/2015:08:55:31 +0000] "GET / HTTP/1.1" 304 0 "-"
"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_4) AppleWebKit/537.36 (KHTML,
like Gecko) Chrome/44.0.2403.107 Safari/537.36" "72.14.229.161,
107.178.245.158"
10.240.217.81 - - [29/Jul/2015:08:55:31 +0000] "GET / HTTP/1.1" 200 612 "-"
"Google-GCLB/1.0" "-"
...
```

## What’s Next?

Read more about cross-region HTTP load balancing in the Google Cloud Platform [docs](https://cloud.google.com/compute/docs/load-balancing/http/cross-region-example). In the docs, you’ll find great info on how to [restrict access to your instances from everywhere except the load balancer
service](https://cloud.google.com/compute/docs/load-balancing/http/cross-region-example#shut_off_https_access_from_everywhere_but_the_load_balancing_service) as well as how to [simulate outages using iptables](https://cloud.google.com/compute/docs/load-balancing/http/cross-region-example#simulate_an_outage).

You can support more complicated setups with the HTTP load balancer. Check out
the docs on [content-based load balancing](https://cloud.google.com/compute/docs/load-balancing/http/content-based-example) or [setting up SSL certificates](https://cloud.google.com/compute/docs/load-balancing/http/ssl-certificates) for HTTPS load balancing.
