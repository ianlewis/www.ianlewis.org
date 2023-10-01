---
layout: post
title: "Creating Smaller Docker Images Part #3: Alpine Linux"
date: 2017-05-31 16:25:00 +0000
permalink: /en/creating-smaller-docker-images-part-3-alpine-linux
blog: en
tags: docker smaller-docker-images-series
render_with_liquid: false
---

<img alt="alpine linux" title="alpine linux" class="align-center" src="/assets/images/761/alpinelinux-logo.png">

This is the third post in a series on making smaller Docker images. In the [first post](/en/creating-smaller-docker-images) I talked about how to create smaller images by writing better Dockerfiles. In the [second post](/en/creating-smaller-docker-images-part2) I talked about how to squash layers using docker-squash to make smaller images. These methods are great but they won't help us if we choose large base images to start with!

Let's look at the example from the second post, the standard `python` image on Docker hub. If we look at the [Dockerfile](https://github.com/docker-library/python/blob/cd1f11aa745a05ddf6329678d5b12a097084681b/2.7/Dockerfile) for this image, as of this writing, it's based on a Debian jessie base image.

```docker
FROM buildpack-deps:jessie

# ensure local python is preferred over distribution python
ENV PATH /usr/local/bin:$PATH

...
```

The `buildpack-deps:jessie` image includes a full Debian jessie distribution install and is quite large.

```shell
~$ docker images buildpack-deps:jessie
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
buildpack-deps      jessie              3b84923989a0        3 weeks ago         614 MB
```

We can see here that it's 614MB to start. Even squashing it isn't going to help much because there's just a lot of data in the base distribution.

## Alpine Linux

Alpine Linux is a distribution of Linux that is built to be very small for the base install. But even though it's small it still has a nice package repository with lots of packages. It also has a tool much like `apt-get` or `yum` to easily install those packages.

```shell
~$ docker images alpine:3.6
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
alpine              3.6                 a41a7446062d        5 days ago          3.966 MB
```

It's only 3.96 MB. That's a huge difference from the 600+ Debian jessie image. Many standard Docker images conveniently have an Alpine Linux version. Usually it has an `-alpine` suffix. Let's look at our python example.

```shell
~$ docker images python:2.7.13-alpine
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
python              2.7.13-alpine       3dd614730c9c        4 days ago          72.02 MB
```

The Python VM takes up about 72MB but that's still much better than the 670 MB for the Debian based python image.

## Building Images with Alpine

You can build images with Alpine and install Alpine packages using the `apk` tool in your Dockerfile. You might do something like the following to get a checkout of a git repo.

```docker
FROM alpine:3.6

RUN apk add --update git && \
    git clone https://github.com/example/myrepo.git && \
    rm myrepo/.git && \
    apk del git && \
    rm -rf /var/cache/apk/*

CMD ['/myrepo/myapp']
```

You can view the available packages for Alpine at [https://pkgs.alpinelinux.org/](https://pkgs.alpinelinux.org/)
