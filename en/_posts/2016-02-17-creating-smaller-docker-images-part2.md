---
layout: post
title: "Creating Smaller Docker Images: Part #2"
date: 2016-02-17 22:00:00 +0000
permalink: /en/creating-smaller-docker-images-part2
blog: en
render_with_liquid: false
---

This is the second post in a series on making smaller Docker images. In my [previous blog post](https://www.ianlewis.org/en/creating-smaller-docker-images) I talked about how to create smaller Docker images but there were limits to
how small we could make the images. I outlined a way in which you can make the
layers you add to your Docker image smaller, but there may be times where it
just isn’t possible. Perhaps you need to run some steps in a particular order.

For Instance, maybe you need to add a file during an intermediate step? 


```docker
RUN ...
ADD some_file /
RUN ...
```
What if I need to do some processing in the first RUN command before adding the
file and then do some more processing before some cleanup in the second RUN
command? In that case I’m out of luck. Docker will create a layer after each
command. You may also have a situation where the base image you want to use
inherits from many other images and each adds their own large layers.

## Docker Squash

Docker doesn’t provide a way to decouple the commands you run and caching of
the layers. Most of the time this is ok, but it can lead to images that are
larger than needed. In order to reduce the number of layers and their sizes
down you can squash the layers much like you would squash git commits. There is
a really cool tool that will do this for you called [docker-squash](https://github.com/jwilder/docker-squash). You can read more about it in the [author’s original blog post](http://jasonwilder.com/blog/2014/08/19/squashing-docker-images/).

![Vise](https://storage.googleapis.com/static.ianlewis.org/prod/img/748/vise.jpg)

*[Creative Commons Attribution](https://creativecommons.org/licenses/by/2.0/) by [Communications Mann](https://www.flickr.com/photos/spenceannaaug18/7069654045/in/photolist-bLHPQZ-aF3qHd-aEq79z-8yQzQt-5jDvQ8-aEYmdF-aEx66j-5EZwFg-dSBZFb-2Ypqdi-5Uw2gF-3b1dmA-3aVF7M-dZF1V5-a55maH-6tXnaY-qAJkzw-bEVr7X-e4dngq-2ystn-eA1PU6-aFMxwn-9YReBh-4jkvuR-efUaTT-dZEXQU-dZFrq5-f4AToE-ngJPnE-7Hc1gx-bDaK7t-dnGexK-d9J17o-kwCjdU-snrBcV-dg7aAX-tTDMUC-7NFwDp-iYLYD7-tTMWt6-cYuZob-64Tpi-ekJEBJ-dvB96q-7NFwRR-8H7DAm-8H7DzL-747sy4-bLjCEX-bxpW8E)*

Docker squash will squash a number of image layers so that any data stored in
the intermediate steps is removed. This is really great when you find yourself
in the situation above. Or you want to make your Dockerfile less complicated.
Let’s give it a try.

## Squashing Python

I’m going to see if I can make the standard [python:2.7.11 image](https://hub.docker.com/_/python/) on docker hub smaller. We can notice from the [Dockerfile](https://github.com/docker-library/python/blob/master/2.7/Dockerfile) is first purging the existing Debian python installation, before downloading
and compiling it’s own version. But since the Debian python is already included
in one of the earlier layers, that space is taken up by our image. The images
also depends on several other Dockerfiles which are each adding their own
layers. Let’s see how much space we can save by squashing it.

First I’m going to pull it down to my local machine.


```console
$ docker pull python:2.7.11
2.7.11: Pulling from library/python
7a01cc5f27b1: Pull complete 
3842411e5c4c: Pull complete 
...
127e6c8b9452: Pull complete 
88690041a8a3: Pull complete 
Digest: sha256:590ee32a8cab49d2e7aaa92513e40a61abc46a81e5fdce678ea74e6d26e574b9
Status: Downloaded newer image for python:2.7.11
```
Right away, can see the image has a good number of layers and is about 676MB.


```console
$ docker images python:2.7.11
REPOSITORY          TAG                 IMAGE ID            CREATED
VIRTUAL SIZE
python              2.7.11              88690041a8a3        2 weeks ago
676.1 MB
```
It’s a little annoying that docker-squash doesn’t let you squash images that
are in your local repository. Instead it requires that the image be exported as
a file. I’m going to go ahead and do that and create a new squashed image.


```console
$ docker save python:2.7.11 > python-2.7.11.tar
$ sudo bin/docker-squash -i python-2.7.11.tar -o python-squashed-2.7.11.tar
```
Now we can see right away that the new file is smaller by about 75MB.


```console
~$ ls -lh python-*.tar
-rw-rw-r-- 1 ian  ian  666M Feb 15 16:32 python-2.7.11.tar
-rw-r--r-- 1 root root 590M Feb 15 16:33 python-squashed-2.7.11.tar
```
Sure enough after we load it back into our local repository, docker reports
that it’s much smaller:


```console
$ cat python-squashed-2.7.11.tar | docker load
$ docker images python-squashed
REPOSITORY          TAG                 IMAGE ID            CREATED
VIRTUAL SIZE
python-squashed     latest              18d8ebf067fd        11 days ago
599.9 MB
```
## Virtual Size

You’ll notice though that docker shows us the “Virtual Size” of our images.
That’s because Docker reuses images that depend on the same layers. Much like
how git has commits and modifying or squashing the commits makes a completely
new commit, docker-squash will create a completely new independent layer that
contains everything.

Docker-squash allows you to mitigate this a little bit by providing a -from
argument. The default of this argument is the first FROM layer. So it the case
above, because there were many FROM layers, it was able to squash out some
unnecessary data but still leave the layer from the first base image. By
specifying this argument you can decide which base image you want to use so
that it doesn’t have to be downloaded each time.


```console
$ docker-squash -from 18d8ebf067fd -i ... -o ...
```

Docker-squash isn’t a panacea but it does add one more tool to your toolbox for
managing Docker image sizes. [Give it a try](https://github.com/jwilder/docker-squash) and let me know what you think in the comments below or by pinging [me on Twitter](https://twitter.com/IanMLewis). In the next couple of blog posts I’ll talk about some more tools and ways to
lower the size of Docker images.
