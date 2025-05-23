---
layout: post
title: "Using Kubernetes Namespaces to Manage Environments"
date: 2015-07-15 16:00:00 +0000
permalink: /en/using-kubernetes-namespaces-manage-environments
blog: en
tags: tech containers kubernetes
render_with_liquid: false
---

One of the advantages that Kubernetes provides is the ability to manage various environments easier and better than you have been doing. For most nontrivial applications, you have test, staging, and production environments. You can spin up a separate cluster of resources, such as VMs, with the same configuration in staging and production, but that can be costly and managing the differences between the environments can be difficult.

Kubernetes includes a cool feature called [namespaces](https://github.com/GoogleCloudPlatform/kubernetes/blob/master/docs/design/namespaces.md), which enable you to manage different environments within the same cluster. For example, you can have different test and staging environments in the same cluster of machines, potentially saving resources. You can also run different types of server, batch, or other jobs in the same cluster without worrying about them affecting each other.

## The Default Namespace

Using a namespace is optional in Kubernetes because by default Kubernetes uses the "default" namespace. If you've just created a cluster, you can check that the default namespace exists using this command:

```shell
$ kubectl get namespaces
NAME      LABELS    STATUS
default   <none>    Active
```

Here you can see that the `default` namespace exists and is active. The status of the namespace is used later when turning down and deleting the namespace.

## Creating a New Namespace

You can create a new namespace a couple ways. The easiest way to create a namespace is to just specify the namespace when creating another kind of resource, such as a pod, replication controller, or service.

```shell
kubectl create -f my-pod.yaml --namespace=my-namespace
```

This will create a new namespace called `my-namespace` if that namespace doesn't exist.

If you are simply creating a namespace that you want to be able to show in the namespace list later, or if you want to attach other metadata like labels to it, then you can create it like you would any other resource. Create a `my-namespace.yaml` file and add these contents:

```yaml
kind: Namespace
apiVersion: v1
metadata:
    name: my-namespace
    labels:
        name: my-namespace
```

Then you can run this command to create it:

```shell
kubectl create -f my-namespace.yaml
```

## Service Names

With namespaces you can have your apps point to static service endpoints that don't change based on the environment. For instance, your MySQL database service could be named `mysql` in production and staging even though it runs on the same infrastructure.

This works because each of the resources in the cluster will by default only "see" the other resources in the same namespace. This means that you can avoid naming collisions by creating pods, services, and replication controllers with the same names provided they are in separate namespaces. Within a namespace, names of services resolve via DNS to the IP of the service within that namespace. You can still access services in other namespaces by looking it up via SERVICE-NAME.NAMESPACE-NAME.

## An Example

As of this writing, I'm running this website in a Container Engine cluster. I have my production and staging environment as well as some one-off apps running in the same cluster. I can show you a bit of what I mean by running some commands:

```shell
$ kubectl get namespaces
NAME                    LABELS    STATUS
default                 <none>    Active
homepage-prod           <none>    Active
homepage-staging        <none>    Active
twilio-forwarder-prod   <none>    Active
```

Here you can see that I have a few namespaces running. Next let’s list the services in staging (IP addresses have been changed to protect the innocent):

```shell
$ kubectl get services --namespace=homepage-staging
NAME          LABELS                    SELECTOR        IP(S)             PORT(S)
homepage-v1   name=homepage,version=1   name=homepage   10.43.250.14      80/TCP
                                                        104.185.824.125
mysql         name=mysql                name=mysql      10.43.250.63      3306/TCP
```

When I check production:

```shell
$ kubectl get services --namespace=homepage-prod
NAME          LABELS                    SELECTOR        IP(S)             PORT(S)
homepage-v1   name=homepage,version=1   name=homepage   10.43.241.145     80/TCP
                                                        104.199.132.213
mysql         name=mysql                name=mysql      10.43.245.77      3306/TCP
```

Notice that the IP addresses are different depending on which namespace I use even though the names of the services themselves are the same. This capability makes configuring your app extremely easy—since you only have to point your app at the service name—and has the potential to allow you to configure your app exactly the same in your staging or test environments as you do in production.

## Caveats

While you can run staging and production environments in the same cluster and save resources and money by doing so, you will need to be careful to set up resource limits so that your staging environment doesn't starve production for CPU, memory, or disk resources. Setting resource limits properly, and testing that they are working takes a lot of time and effort so unless you can measurably save money by running production in the same cluster as staging or test, you may not really want to do that.

Whether or not you run staging and production in the same cluster, namespaces are a great way to isolate different apps within the same cluster. Namespaces will also serve as a level where you can apply resource limits so look for more resource management features at the namespace level in the future.
