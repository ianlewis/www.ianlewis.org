---
layout: post
title: "Deploying Go Servers with Kubernetes on Container Engine"
date: 2015-05-07 02:00:00 +0000
permalink: /en/deploying-go-servers-kubernetes
blog: en
tags: tech programming golang kubernetes containers cloud
render_with_liquid: false
---

> Cross posted on [medium](https://medium.com/@IanMLewis/deploying-go-servers-with-kubernetes-on-container-engine-3fee717a7e2a)

I was trying to get a Go app running on Container Engine and couldn't quite
find what I was looking for. There are guides out there about how to use Go and
Docker, and how to use Kubernetes but but not many about Go apps and Container
Engine. I also found it easy to deploy apps but most guides lacked information
on best practices for how to maintain apps through regular upgrades so I
decided to research it and write a post about it myself.

Be sure to check out the [Container Engine
documentation](https://cloud.google.com/container-engine/docs/) for details
about the concepts and commands used.

This post is a continuation of the [Deploying Go servers with
Docker](https://blog.golang.org/docker) article on the Go blog.
Make sure you run through building the Docker image.

## Pushing the Docker Image to Google Container Registry

You will need the `gcloud` tool so make sure you have the [Google Cloud
SDK](https://cloud.google.com/sdk/#Quick_Start) installed. Next you'll need to
[create a project on the Google Developers
Console](https://developers.google.com/console/help/#creatingdeletingprojects).
Make note of the project id.

Set up your `gcloud` tool with the right configuration. Replace `<project-id>`
below with your project id. Replace `<zone>` with the zone of your choosing:

```shell
gcloud config set project <project-id>
gcloud config set compute/zone <zone>
```

Once you have that done you will need to tag the image using Docker.

```shell
docker tag outyet gcr.io/<project-id>/outyet:v1
```

This will set the repository and tag it with the version `v1`. Next push the
image to the registry. You may get warnings about installing the `preview`
components. Just say `yes` to install them when asked.

```shell
gcloud preview docker push gcr.io/<project-id>/outyet:v1
```

## Kubernetes Configuration

> **UPDATE (2015/07/13)**: Now using the v1 API.

We will create a [replication
controller](https://github.com/GoogleCloudPlatform/kubernetes/blob/master/docs/replication-controller.md)
and [service](https://github.com/GoogleCloudPlatform/kubernetes/blob/master/docs/services.md) for our app.

The replication controller configures how our app will be run and maintained in
Kubernetes and the service allows our containers to be accessed as one logical
service/app. Create a `outyet-rc.yml` file with the contents below. We will use
the new `v1` version of the API:

```yaml
kind: ReplicationController
apiVersion: v1
metadata:
    name: outyet-v1
spec:
    replicas: 3
    selector:
        name: outyet
        version: "1"
    template:
        metadata:
            labels:
                name: outyet
                version: "1"
        spec:
            containers:
                - image: gcr.io/<project-id>/outyet:v1
                  name: outyet
                  ports:
                      - containerPort: 8080
                        hostPort: 8080
                        protocol: TCP
```

Next we'll create a service for our app. Create an `outyet-service.yml` with
the contents below:

```yaml
kind: Service
apiVersion: v1
metadata:
    name: outyet
    labels:
        name: outyet
spec:
    ports:
        - port: 80
          targetPort: 8080
          protocol: TCP
    selector:
        name: outyet
    type: LoadBalancer
```

## Deploy the Container Engine Cluster

Next we'll deploy our container engine cluster. We'll use the `gcloud` tool
again. You may get warnings about installing the `alpha` components. Just say
`yes` to install them when asked.

```shell
gcloud alpha container clusters create outyet
gcloud config set container/cluster outyet
```

## Create the Replication Controller

After the cluster is created we can deploy the app. First we will create the
replication controllers:

```shell
gcloud alpha container kubectl create -f outyet-rc.yml
```

It will take a few minutes for the pods to come up. You can see if the pods are
ready using the following command:

```shell
gcloud alpha container kubectl get pods
```

The pods will say their state is `Pending` at first but will change to
`Running` when they are ready.

## Create the Service

Create the service with the following command.

```shell
gcloud alpha container kubectl create -f outyet-service.yml
```

After the service is created we can see that it is created by viewing the
output of this command:

```shell
gcloud alpha container kubectl get services
```

The service uses the `LoadBalancer` feature of Container Engine to set up a
network load balancer to our service. We can get the external IP of the service
using the following command:

```shell
gcloud compute forwarding-rules list
```

This will show the IP address of our service. Make note of the IP address.
Finally we can create a firewall rule to allow access to our nodes:

```shell
gcloud compute firewall-rules create outyet-http --allow tcp:80 --target-tags k8s-outyet-node
```

Now we can view the app at `http://<IP Address>/`

![Is Go 1.4 out yet? Yes!](/assets/images/734/golang1.4_large.png)

## Upgrading the App

Go 1.4 is already out yet so app isn't really exciting. Let's update it so it
checks for Go 1.5. Let's override the `CMD` for the Dockerfile so it looks like
this:

```dockerfile
FROM golang:onbuild
CMD ["go-wrapper", "run", "-version=1.5"]
EXPOSE 8080
```

Next we will build, tag, and push the updated Docker image:

```shell
docker build -t outyet .
docker tag outyet gcr.io/<project-id>/outyet:v2
gcloud preview docker push gcr.io/<project-id>/outyet:v2
```

Next let's update all the places it says `v1` in our `outyet-rc.yml` and change
it to `v2`.

```yaml
kind: ReplicationController
apiVersion: v1
metadata:
    name: outyet-v2
spec:
    replicas: 3
    selector:
        name: outyet
        version: "2"
    template:
        metadata:
            labels:
                name: outyet
                version: "2"
        spec:
            containers:
                - image: gcr.io/<project-id>/outyet:v2
                  name: outyet
                  ports:
                      - containerPort: 8080
                        hostPort: 8080
                        protocol: TCP
```

Next do a rolling update of our replication controller `outyet-v1` to our new
`outyet-v2`:

```shell
gcloud alpha container kubectl rollingupdate outyet-v1 -f outyet-rc.yml --update-period=10s
```

This should take about 30 seconds to run as we have 3 replicas and we've set
the update period as 10 seconds per replica.

After that runs we can refresh our app again to see if Go 1.5 is out yet :)

![Is Go 1.5 out yet? No :(](/assets/images/734/golang1.5_large.png)

## Cleanup

Make sure you delete your cluster so you don't get charged too much money :)

```shell
gcloud alpha container clusters delete outyet
```

## Conclusion

I really think containers are the way everyone will be developing apps in the
future so hopefully that gave you an idea of how you can deploy a Go app and
upgrade it using Container Engine. As a next step try out some of the many
[example
apps](https://github.com/GoogleCloudPlatform/kubernetes/tree/master/examples)
available in the Kubernetes repo.
