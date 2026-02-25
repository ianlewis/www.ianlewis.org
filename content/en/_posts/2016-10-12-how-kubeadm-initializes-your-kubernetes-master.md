---
layout: post
title: "How kubeadm Initializes Your Kubernetes Master"
date: 2016-10-12 18:00:00 +0000
permalink: /en/how-kubeadm-initializes-your-kubernetes-master
blog: en
tags: tech containers kubernetes
render_with_liquid: false
---

`kubeadm` is a new tool that is part of the Kubernetes distribution as of 1.4.0 which helps you to install and set up a Kubernetes cluster. One of the most frequent criticisms of Kubernetes is that it's hard to install. `kubeadm` really makes this easier so I suggest you give it a try.

The [documentation for kubeadm](http://kubernetes.io/docs/getting-started-guides/kubeadm/) outlines how to set up a cluster but as I was doing that I found how `kubeadm` actually sets up the master to be really interesting so I wanted to share that here.

## The Kubernetes Control Plane

The Kubernetes control plane consists of the Kubernetes API server (`kube-apiserver`), controller manager (`kube-controller-manager`), and scheduler (`kube-scheduler`). The API server depends on `etcd` so an etcd cluster is also required.

![The Kubernetes architecture including control plane components](/assets/images/755/kubernetes-arch.png){: .align-center}

These components need to be installed on your master and can be installed in a number of ways. But there are a number of things you have to think about, like how do you make sure each of them are always running? How do you update the components easily with as little impact to the system as possible? You could install them directly on the host machine by downloading them and running them but if they crash then you'd have to restart them manually.

One way to make sure the control plane components are always running is to use systemd. This will make sure they are always running but won't make it easy to upgrade the components later.

## kubeadm and the kubelet

Fortunately, Kubernetes has a component called the Kubelet which manages containers running on a single host. It uses the API server but it doesn't depend on it so we can actually use the Kubelet to manage the control plane components. This is exactly what `kubeadm` sets us up to do. Let's look at what happens when we run `kubeadm`.

```shell
# kubeadm init
<master/tokens> generated token: "d97591.135ba38594a02df1"
<master/pki> created keys and certificates in "/etc/kubernetes/pki"
<util/kubeconfig> created "/etc/kubernetes/kubelet.conf"
<util/kubeconfig> created "/etc/kubernetes/admin.conf"
<master/apiclient> created API client configuration
<master/apiclient> created API client, waiting for the control plane to become ready
<master/apiclient> all control plane components are healthy after 21.451883 seconds
<master/apiclient> waiting for at least one node to register and become ready
<master/apiclient> first node is ready after 0.503915 seconds
<master/discovery> created essential addon: kube-discovery, waiting for it to become ready
<master/discovery> kube-discovery is ready after 17.003674 seconds
<master/addons> created essential addon: kube-proxy
<master/addons> created essential addon: kube-dns

Kubernetes master initialised successfully!

You can now join any number of machines by running the following on each node:

kubeadm join --token d97591.135ba38594a02df1 10.240.0.2
```

We can see that `kubeadm` created the necessary certificates for the API, started the control plane components, and installed the essential addons. `kubeadm` doesn't mention anything about the Kubelet but we can verify that it's running:

```shell
# ps aux | grep /usr/bin/kubelet | grep -v grep
root      4147  4.4  2.1 473372 82456 ?        Ssl  05:18   1:08 /usr/bin/kubelet --kubeconfig=/etc/kubernetes/kubelet.conf --require-kubeconfig=true --pod-manifest-path=/etc/kubernetes/manifests --allow-privileged=true --network-plugin=cni --cni-conf-dir=/etc/cni/net.d --cni-bin-dir=/opt/cni/bin --cluster-dns=100.64.0.10 --cluster-domain=cluster.local --v=4
```

So our Kubelet was started. But how? The Kubelet will monitor the control plane components but what monitors Kubelet and make sure it's always running? This is where we use systemd. Systemd is started as PID 1 so the OS will make sure it is always running, systemd makes sure the Kubelet is running, and the Kubelet makes sure our containers with the control plane components are running.

We have a process architecture something like the following. It's important to note that this is not a diagram of the process tree but rather a diagram showing which components start and monitor each other.

![systemd initializes the kubelet which starts the control plane components](/assets/images/755/arch.png){: .align-center}

So now we have our Kubelet running our control plane components and it is connected to the API server just like any other Kubelet node. We can verify that:

```shell
# kubectl get nodes
NAME         STATUS    AGE
k8s-master   Ready     2h
```

One thing about the Kubelet running on the master is different though. There is a special annotation on our node telling Kubernetes not to schedule containers on our master node.

```shell
# kubectl get nodes -o json | jq '.items[] | select(.metadata.name=="k8s-master") | .metadata.annotations'
{
  "scheduler.alpha.kubernetes.io/taints": "[{\"key\":\"dedicated\",\"value\":\"master\",\"effect\":\"NoSchedule\"}]",
  "volumes.kubernetes.io/controller-managed-attach-detach": "true"
}
```

The interesting bits are the `scheduler.alpha.kubernetes.io/taints` key which contains information for the scheduler saying that it shouldn't schedule containers on this node. This allows us to view and manage our node through the Kubernetes API but not worry about scheduling regular containers on the master node.

## Verifying the Control Plane Components

We can see that `kubeadm` created a `/etc/kubernetes/` directory so let's check out what's there.

```shell
# ls -lh /etc/kubernetes/
total 32K
-rw------- 1 root root 9.0K Oct 12 05:18 admin.conf
-rw------- 1 root root 9.0K Oct 12 05:18 kubelet.conf
drwxr-xr-x 2 root root 4.0K Oct 12 05:18 manifests
drwx------ 2 root root 4.0K Oct 12 05:18 pki
```

The `admin.conf` and `kubelet.conf` are yaml files that mostly contain certs used for authentication with the API. The `pki` directory contains the certificate authority certs, API server certs, and tokens.

```shell
# ls -lh /etc/kubernetes/pki
total 36K
-rw------- 1 root root 1.7K Oct 12 05:18 apiserver-key.pem
-rw-r--r-- 1 root root 1.2K Oct 12 05:18 apiserver.pem
-rw------- 1 root root  451 Oct 12 05:18 apiserver-pub.pem
-rw------- 1 root root 1.7K Oct 12 05:18 ca-key.pem
-rw-r--r-- 1 root root 1.1K Oct 12 05:18 ca.pem
-rw------- 1 root root  451 Oct 12 05:18 ca-pub.pem
-rw------- 1 root root 1.7K Oct 12 05:18 sa-key.pem
-rw------- 1 root root  451 Oct 12 05:18 sa-pub.pem
-rw------- 1 root root   96 Oct 12 05:18 tokens.csv
```

The `manifests` directory is where things get interesting. In the manifests directory we have a number of json files for our control plane components.

```shell
# ls -lh /etc/kubernetes/manifests/
total 16K
-rw------- 1 root root 1.8K Oct 12 05:18 etcd.json
-rw------- 1 root root 2.1K Oct 12 05:18 kube-apiserver.json
-rw------- 1 root root 1.7K Oct 12 05:18 kube-controller-manager.json
-rw------- 1 root root  970 Oct 12 05:18 kube-scheduler.json
```

If you noticed earlier the Kubelet was passed the `--pod-manifest-path=/etc/kubernetes/manifests` flag which tells it to monitor the files in the `/etc/kubernetes/manifests` directory and makes sure the components defined therein are always running. We can see that they are running my checking with the local Docker to list the running containers.

```shell
# docker ps --format="table {{.ID}}\t{{.Image}}"
CONTAINER ID        IMAGE
dbaf645c0dd4        gcr.io/google_containers/pause-amd64:3.0
186feb8bbb73        gcr.io/google_containers/kube-proxy-amd64:v1.4.0
38644bc269cc        gcr.io/google_containers/pause-amd64:3.0
142dfe6fcba2        gcr.io/google_containers/kube-discovery-amd64:1.0
1f3969d0d773        gcr.io/google_containers/pause-amd64:3.0
bb9e153bcb84        gcr.io/google_containers/kube-controller-manager-amd64:v1.4.0
c37d54f86ab9        gcr.io/google_containers/kube-apiserver-amd64:v1.4.0
a42224e47f84        gcr.io/google_containers/etcd-amd64:2.2.5
d9d109fc62de        gcr.io/google_containers/kube-scheduler-amd64:v1.4.0
a28445c759be        gcr.io/google_containers/pause-amd64:3.0
72f9565d39fb        gcr.io/google_containers/pause-amd64:3.0
33c70feee8ee        gcr.io/google_containers/pause-amd64:3.0
f5383068a4c5        gcr.io/google_containers/pause-amd64:3.0
```

Several other containers are running but if we ignore them we can see that `etcd`, `kube-apiserver`, `kube-controller-manager`, and `kube-scheduler` are running.

How are we able to connect to the containers? If we look at each of the json files in the `/etc/kubernetes/manifests` directory we can see that they each use the `hostNetwork: true` option which allows the applications to bind to ports on the host just as if they were running outside of a container.

```json
{
  "kind": "Pod",
  "apiVersion": "v1",
  ...
  "spec": {
    "containers": [
      {
        "name": "kube-apiserver",
        "image": "gcr.io/google_containers/kube-apiserver-amd64:v1.4.0",
        "volumeMounts": [
          {
            "name": "certs",
            "mountPath": "/etc/ssl/certs"
          },
          {
            "name": "pki",
            "readOnly": true,
            "mountPath": "/etc/kubernetes/"
          }
        ],
        ...
      }
    ],
    "hostNetwork" true,
    ...
  }
}
```

So we can connect to the API server's insecure local port.

```shell
# curl http://127.0.0.1:8080/version
{
  "major": "1",
  "minor": "4",
  "gitVersion": "v1.4.0",
  "gitCommit": "a16c0a7f71a6f93c7e0f222d961f4675cd97a46b",
  "gitTreeState": "clean",
  "buildDate": "2016-09-26T18:10:32Z",
  "goVersion": "go1.6.3",
  "compiler": "gc",
  "platform": "linux/amd64"
}
```

The API server also binds a secure port 443 which requires a client cert and authentication. Be careful to use the public IP for your master here.

```shell
# curl --cacert /etc/kubernetes/pki/ca.pem https://10.240.0.2/version
Unauthorized
```

## What kubeadm Didn't Do

`kubeadm` is a really great tool for setting up a Kubernetes cluster but there are a few things it doesn't do which will be the topic of future work. These are spelled out in the [Limitations](http://kubernetes.io/docs/getting-started-guides/kubeadm/#limitations) section of the documentation.

One of the most important things that `kubeadm` doesn't do yet is set up a multi-node etcd cluster. In order to make your cluster more resistant to failure, you will need to create other etcd nodes. This should be easy enough but it's important to note.

`kubeadm` also doesn't yet install cloud provider integrations so things like [load balancers](http://kubernetes.io/docs/user-guide/load-balancer/) and [persistent volumes](http://kubernetes.io/docs/user-guide/persistent-volumes/walkthrough/) won't work.

Hopefully that gave you an idea of what `kubeadm` is doing. Running the components using the Kubelet is a great practice that ensures the components are running and makes it easier to upgrade them later. When Kubernetes 1.5 comes out we can expect to see relatively painless upgrades for users of `kubeadm`.
