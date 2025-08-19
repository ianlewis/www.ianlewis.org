---
layout: post
title: "Creating Smaller Docker Images Part #4: Static Binaries"
date: 2017-07-11 16:25:00 +0000
permalink: /en/creating-smaller-docker-images-static-binaries
blog: en
tags: tech programming golang containers docker smaller-docker-images-series
render_with_liquid: false
---

This is the fourth post in a series on making smaller Docker images: static binaries. In the
[first post](/en/creating-smaller-docker-images) I talked about how to create
smaller images by writing better Dockerfiles. In the [second
post](/en/creating-smaller-docker-images-part2) I talked about how to squash
layers using docker-squash to make smaller images. In the [third
post](/en/creating-smaller-docker-images-part-3-alpine-linux) I wrote about how
to use Alpine Linux as a smaller base image.

In this post I'll examine the ultimate when it comes to making smaller images: static binaries.
What if your app didn't have any dependencies and didn't need anything at all
except the app itself? This is what static binaries achieve. They include all the dependencies to running the application _statically compiled_ within the binary itself. Let's take a step back and learn what that means.

## Dynamic Linking

Most applications are built using a process known as Dynamic Linking. Each application when it is compiled is done so in such a way that it defines the libraries that it requires to run but doesn't actually contain the libraries within itself. This is super important for operating system distributions because libraries can be updated independently of applications but when running applications inside a container it's not as important. Each container image contains all of the files it will use so you aren't reusing the libraries anyway.

Let's look at an example. If I create a simple C++ application and compile it as follows I will get a dynamically linked executable.

```shell
ianlewis@test:~$ cat hello.cpp
#include <iostream>

int main() {
    std::cout << "Hello World!\n";
    return 0;
}
ianlewis@test:~$ g++ -o hello hello.cpp
$ ls -lh hello
-rwxrwxr-x 1 ianlewis ianlewis 8.9K Jul  6 07:31 hello
```

`g++` is actually doing two steps. It is compiling my application and linking it. Compiling just creates an normal C++ object file. The linking step is adding the dependencies needed to run the application. Thankfully most build tools do this for us. The compile and link steps can be broken out as follows.

```shell
ianlewis@test:~$ g++ -c hello.cpp -o hello.o
ianlewis@test:~$ g++ -o hello hello.o
ianlewis@test:~$ ls -lh
total 20K
-rwxrwxr-x 1 ianlewis ianlewis 8.9K Jul  6 07:41 hello
-rw-rw-r-- 1 ianlewis ianlewis   85 Jul  6 07:31 hello.cpp
-rw-rw-r-- 1 ianlewis ianlewis 2.5K Jul  6 07:41 hello.o
```

We can see that it is a dynamically liked by running the `ldd` command on it on Linux systems. If you are on Mac OS you can get the same info by running `otool -L`. This shows the dependencies for my binary.

```shell
ianlewis@test:~$ ldd hello
        linux-vdso.so.1 =>  (0x00007ffc0075c000)
        libstdc++.so.6 => /usr/lib/x86_64-linux-gnu/libstdc++.so.6 (0x00007f88c92d0000)
        libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007f88c8f06000)
        libm.so.6 => /lib/x86_64-linux-gnu/libm.so.6 (0x00007f88c8bfc000)
        /lib64/ld-linux-x86-64.so.2 (0x0000558132cbf000)
        libgcc_s.so.1 => /lib/x86_64-linux-gnu/libgcc_s.so.1 (0x00007f88c89e6000)
```

We can see that I'm depending on `libc` and `libstdc++` which are the C and C++ standard libraries.

When I run the application, the dynamic linker finds the libraries I need and links them at runtime. It does this using the configuration normally found at `/etc/ld.so.conf` on Linux systems.

So what happens if we remove one of these libraries or move it to a location that the dynamic linker doesn't know about?

_!! Moving library files around can really break your system so don't try this at home !!_

```shell
ianlewis@test:~$ sudo mv /usr/lib/x86_64-linux-gnu/libstdc++.so.6 /usr/lib/x86_64-linux-gnu/libstdc++.so.6.bk
ianlewis@test:~$ ldd ./hello
        linux-vdso.so.1 =>  (0x00007ffd511c6000)
        libstdc++.so.6 => not found
        libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007fdace840000)
        /lib64/ld-linux-x86-64.so.2 (0x0000560da65aa000)
```

We can see now that the library is not found by the dynamic linker. What happens if we try to run it?

```shell
ianlewis@test:~$ ./hello
./hello: error while loading shared libraries: libstdc++.so.6: cannot open shared object file: No such file or directory
```

As expected the `libstdc++` library can't be loaded so the app crashes. This brings us to why this is bad for containers.

## Why Dynamic Linking is Bad For Containers

The main reason why dynamic linking is bad for containers is because the system where you built the application may be quite different from the system where you run the application. For Linux distributions they can package applications as dynamically linked executables because they know how the dynamic linker is set up. But even for similar Linux distributions like Ubuntu or Debian copying a binary from one system to the other may cause issues if they are named differently for instance.

This is why most Dockerfiles you'll see build the application inside the same container image it will run in. This is getting better with [Docker multi-stage builds](https://docs.docker.com/engine/userguide/eng-image/multistage-build/) but it's still not widely adopted (as of this writing) and you are still subject to all the issues around copying files between systems. Even with multi-staged builds you will likely still want to run your application on the same Linux distribution as you built it on.

Let's try to run our hello application, compiled on Ubuntu, in something like Alpine Linux.

```shell
ianlewis@test:~$ g++ -o hello hello.cpp
ianlewis@test:~$ cat << EOF > Dockerfile
FROM alpine
COPY hello /hello
ENTRYPOINT [ "/hello" ]
EOF
ianlewis@test:~$ docker build -t hello .
Sending build context to Docker daemon  29.18kB
Step 1/3 : FROM alpine
latest: Pulling from library/alpine
88286f41530e: Pull complete
Digest: sha256:1072e499f3f655a032e88542330cf75b02e7bdf673278f701d7ba61629ee3ebe
Status: Downloaded newer image for alpine:latest
 ---> 7328f6f8b418
Step 2/3 : COPY hello /hello
 ---> 6f5aca4d2acb
Removing intermediate container 904f7c441936
Step 3/3 : ENTRYPOINT /hello
 ---> Running in 635f6cbde8d6
 ---> bbcaa65bf2e5
Removing intermediate container 635f6cbde8d6
Successfully built bbcaa65bf2e5
Successfully tagged hello:latest
ianlewis@test:~$ docker run hello
standard_init_linux.go:187: exec user process caused "no such file or directory"
```

This "no such file or directory" error isn't very descriptive but it's the same error as we saw earlier. The application is saying it couldn't find one of its dynamically linked dependencies.

With containers we want to make our images as small as possible, but managing dependencies for dynamically linked applications is a lot of work and requires a good amount of tooling, like well built package managers that themselves have dependencies. It places a lot of burden on our runtime environment, when all we want to do it run a single application. How do we solve this problem?

## Static Binaries

<img style="width: 75%;" class="align-center" src="/assets/images/763/lightning.jpg" />

> [Creative Commons
> Attribution](https://creativecommons.org/licenses/by/2.0/deed.en) by [John
> Fowler](<https://commons.wikimedia.org/wiki/File:Lightning_(3762193048).jpg>)

Statically linking allows us to bundle all the libraries our application relies on into a single binary. This will allow us to copy the application code and all of its dependencies around in a single binary while still being runnable. Let's try it out.

```shell
ianlewis@test:~$ g++ -o hello -static hello.cpp
ianlewis@test:~$ ls -lh
total 2.1M
-rwxrwxr-x 1 ianlewis ianlewis 2.1M Jul  6 08:08 hello
-rw-rw-r-- 1 ianlewis ianlewis   85 Jul  6 07:31 hello.cpp
ianlewis@test:~$ ./hello
Hello World!
ianlewis@test:~$ ldd hello
        not a dynamic executable
```

Awesome. This means we have a binary executable that we can just copy inside of any container image (even a scratch image) and it will just work!

```shell
ianlewis@test:~$ cat << EOF > Dockerfile
> FROM scratch
> COPY hello /hello
> ENTRYPOINT [ "/hello" ]
> EOF
ianlewis@test:~$ docker build -t hello .
Sending build context to Docker daemon  2.202MB
Step 1/3 : FROM scratch
 --->
Step 2/3 : COPY hello /hello
 ---> d3b2040b4df0
Removing intermediate container 78e434104023
Step 3/3 : ENTRYPOINT /hello
 ---> Running in b6340a5907f5
 ---> 88af34342471
Removing intermediate container b6340a5907f5
Successfully built 88af34342471
Successfully tagged hello:latest
ianlewis@test:~$ docker run hello
Hello World!
```

As was said earlier, the application now contains all of its dependencies so it can essentially run on any other Linux machine! A few caveats exist, such as the application needs to be run on a server with the same CPU architecture that it was compiled for, but for the most part we can just copy it around!

## Image Size

Total size of images for static binaries written in compiled languages can be much smaller than apps written in a language like Python or Java that require a VM to run. In the previous post we looked at the base Python image based on Alpine Linux for deploying Python apps.

```shell
ianlewis@test:~$ docker images python:2.7.13-alpine
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
python              2.7.13-alpine       3dd614730c9c        4 days ago          72.02 MB
```

This is 72MB for just the base python image. Our application code will only add to that. If we include only our static binary our image can be much smaller. Our image only need be as big as our binary file.

```shell
ianlewis@test:~$ ls -lh hello
-rwxrwxr-x 1 ianlewis ianlewis 2.1M Jul  6 08:41 hello
ianlewis@test:~$ docker images hello
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
hello               latest              88af34342471        5 minutes ago       2.18MB
```

Now we are finally getting to a level where we have very little waste in our image sizes.

However, practically speaking you may want to include other applications in your image to aid with troubleshooting and debugging. in that case you may want to combine the use of Alpine Linux for installing build tools with static binaries for your application. Including tools like shells, tracing tools, etc. may be very helpful down the line.

## Write Containerized Apps in Go

I couldn't write a post on writing statically linked applications without mentioning [Go](https://golang.org/). For reasons that are well out of scope for this blog post, without a lot of dedication and willpower, it can be impractical to compile large C++ applications into static binaries. Many third-party or OSS applications don't even provide a way to compile the application as a static binary so you are forced to deploy with images based on a large Linux distribution.

Go makes it really easy to compile statically linked binaries as part of its tooling. It isn't a stretch to say that Go was created this way because Google deploys statically linked binaries in containers as part of it's production systems, and Go was specifically written to make it easy to do that; even for large applications like Kubernetes.

```shell
ianlewis@test:~$ git clone https://github.com/kubernetes/kubernetes
Cloning into 'kubernetes'...
...
ianlewis@test:~$ cd kubernetes/
ianlewis@test:~/kubernetes$ make quick-release
+++ [0711 06:33:32] Verifying Prerequisites....
+++ [0711 06:33:32] Building Docker image kube-build:build-36cca30eef-5-v1.8.3-1
+++ [0711 06:34:18] Creating data container kube-build-data-36cca30eef-5-v1.8.3-1
+++ [0711 06:34:19] Syncing sources to container
+++ [0711 06:34:22] Running build command...
...
ianlewis@test:~/kubernetes$ ldd _output/dockerized/bin/linux/amd64/kube-apiserver
        not a dynamic executable
```

So to summarize, static binaries are smaller, include all of their runtime dependencies so they can be run in containers easily, and can now be built easily with modern languages like Go. What's not to like?
