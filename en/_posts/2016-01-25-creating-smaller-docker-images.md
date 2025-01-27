---
layout: post
title: "Creating Smaller Docker Images"
date: 2016-01-25 22:00:00 +0000
permalink: /en/creating-smaller-docker-images
blog: en
tags: tech containers docker smaller-docker-images-series
render_with_liquid: false
---

![Docker](/assets/images/docker/large_v-trans.png)

Recently I've been working with containers a lot and the most popular technology out there is, of course, Docker. On top of allowing you to easily run containers using the `docker run` command, Docker provides a method to build container images and a format for the resulting image. By writing a `Dockerfile` and executing the `docker build` command you can easily create images that can be run anywhere (within some constraints) Docker is installed.

For instance, here is a DockerFile for running a simple file server.

```docker
FROM debian:jessie

RUN apt-get update
RUN apt-get install -y python
RUN mkdir -p /data

VOLUME ["/data"]

WORKDIR /data

EXPOSE 8000

CMD [ "python", "-m", "SimpleHTTPServer", "8000" ]
```

This is a really simple docker file but if you actually build it and look at the size you'll notice it's pretty big?

```text
VIRTUAL SIZE
167.4 MB
```

## Why so Big？

On the first line of the Dockerfile above you'll notice that it says `FROM debian:jessie`. This is significant because what this means is that we are basing our Docker image off of the `debian:jessie` image on Docker Hub. What makes it so big is that the image contains an entire Debian 8.x installation. If you then install things like gcc, g++ or other build tools the size will get even bigger.

Ok. so let's take a look at how we might create a Docker image for Redis. The Dockerfile is pretty straightforward. We download the redis source code compile and install it. Then at the end we delete all the tools we used to build it since they aren't needed to run it. So we're good right?

```docker
FROM debian:jessie

RUN apt-get update
RUN apt-get install -y gcc libc6-dev make
RUN curl -sSL "http://download.redis.io/releases/redis-3.0.5.tar.gz" -o
redis.tar.gz
RUN mkdir -p /usr/src/redis
RUN tar -xzf redis.tar.gz -C /usr/src/redis
RUN make -C /usr/src/redis
RUN make -C /usr/src/redis install

# 全部削除
RUN rm -f redis.tar.gz
RUN rm -f /usr/src/redis
RUN apt-get purge -y --auto-remove gcc libc6-dev make

...

```

Well, no. Whenever you have a RUN command in your Dockerfile, Docker will create an image layer in your image. Essentially, your image is a bunch of diffs where each layer contains information on the difference between each layer. So here even if we delete the build tools at the end, they are still contained in a previous layer that Docker needs to built up the current layer. So all our work to make the image smaller makes no difference!

## How to Make it Smaller?

You may have guessed the right solution, but the way to make the image smaller is to only create a layer after we have deleted the build tools & libraries. You can do that by executing all the commands in one single RUN command in your Dockerfile.

Here's an excerpt from the [actual redis Dockerfile](https://github.com/docker-library/redis/blob/8929846148513a1e35e4212003965758112f8b55/3.0/Dockerfile) ([Docker BSD LICENSE](https://github.com/docker-library/redis/blob/8929846148513a1e35e4212003965758112f8b55/LICENSE)) on Docker Hub:

```docker
ENV REDIS_VERSION 3.0.5
ENV REDIS_DOWNLOAD_URL http://download.redis.io/releases/redis-3.0.5.tar.gz
ENV REDIS_DOWNLOAD_SHA1 ad3ee178c42bfcfd310c72bbddffbbe35db9b4a6

# for redis-sentinel see: http://redis.io/topics/sentinel
RUN buildDeps='gcc libc6-dev make' \
  && set -x \
  && apt-get update && apt-get install -y $buildDeps --no-install-recommends \
  && rm -rf /var/lib/apt/lists/* \
  && mkdir -p /usr/src/redis \
  && curl -sSL "$REDIS_DOWNLOAD_URL" -o redis.tar.gz \
  && echo "$REDIS_DOWNLOAD_SHA1 *redis.tar.gz" | sha1sum -c - \
  && tar -xzf redis.tar.gz -C /usr/src/redis --strip-components=1 \
  && rm redis.tar.gz \
  && make -C /usr/src/redis \
  && make -C /usr/src/redis install \
  && rm -r /usr/src/redis \
  && apt-get purge -y --auto-remove $buildDeps
```

You can see here that it installs all the build dependencies, downloads the Redis source code, builds Redis, and then deletes all the build tools & clears the apt cache all in one RUN command. This ensures that Docker will create an image layer only after all the unnecessary bits have been deleted.

This won't fix the problem of including the entire operating system but at least solves the problem of having extra build dependencies included in the image.

## Dependency Hell

Docker images usually inherit from a Debian or Ubuntu image. One reason that they are needed is that the application is linked to a number of libraries dynamically and these are required for the app to run. Other reasons why this is the case is that all the normal Linux tools are installed so it's easier to debug and install new software with apt.

At Google, all of the applications that are run in the datacenter are [run inside a container](https://speakerdeck.com/jbeda/containers-at-scale?slide=2). Including a bunch of stuff in the container image or archive is a waste that increases network usage as the binaries are copied to machines that need to run them. In order to make the applications work they are all built as static binaries. I think this is a pretty awesome way to do things as it allows the app to have all the necessary parts built into the image and reduces complexity. You can probably think of the reason why Go compiles apps statically by default as being due to the culture of building cloud applications this way.

I'll go into this a bit more in later blog posts on the subject.
