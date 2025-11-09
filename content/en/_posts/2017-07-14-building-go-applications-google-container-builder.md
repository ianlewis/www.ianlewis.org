---
layout: post
title: "Building Go Applications with Google Container Builder"
date: 2017-07-14 10:15:00 +0000
permalink: /en/building-go-applications-google-container-builder
blog: en
tags: tech programming golang cloud
render_with_liquid: false
---

<!-- TODO(#339): Add alt text to images. -->
<!-- markdownlint-disable MD045 -->

<img class="align-center" src="/assets/images/764/container-builder-go.png">

_Gopher image [Creative Commons Attribution 3.0 Unported (ja)](https://creativecommons.org/licenses/by/3.0/deed.ja) by [tenntenn](https://github.com/tenntenn/gopher-stickers)_

Recently I wrote on Twitter about how doing CI right requires you to properly separate your build and run steps for your container images.

[![i.e. you have one Docker image to build your Go static binary, and one that's 3 lines long to copy it into a scratch image ;)](/assets/images/2017-07-14-building-go-applications-google-container-builder/2025-01-01_16.40.57.png)](https://twitter.com/IanMLewis/status/865733243391299585)

The reason for this issue is that you want to keep your final image as small as possible for a number of reasons. The obvious reason is for performance but there are several other reasons. Keeping it small keeps the images simple and reduces the risk of bugs, and reduces the security attack surface.

If you're a Google Cloud junkie like me then [Container Builder](https://cloud.google.com/container-builder/) is really convenient because it integrates really well with [Google Cloud Source Repositories](https://cloud.google.com/source-repositories/) and [Google Container Registry](https://cloud.google.com/container-registry/). But best of all, it makes it easy to separate out our build steps.

Container Builder is a CI/CD tool that let's you kick off build steps manually or based on triggers. So you can kick off builds when you push to your source repo. In this post I'm just going to kick them off manually, but you can read the [docs](https://cloud.google.com/container-builder/docs/how-to/build-triggers) to set up triggers.

Container Builder runs build steps in the order you specify but those build steps can be any Docker image. So it's extremely flexible. There are a bunch of "built-in" supported images you can use (they are also [open source](https://github.com/GoogleCloudPlatform/cloud-builders/)!). Custom build step images are also pretty [easy to create](https://cloud.google.com/container-builder/docs/concepts/custom-build-steps).

Kicking off a build from a simple Dockerfile is easy. This gcloud command will build your Dockerfile and store it with the GCR image name you specify.

```shell
gcloud container builds submit --tag gcr.io/[PROJECT-ID]/[IMAGE] .
```

However, that will build the Docker image in one step. To do more complicated builds you can use a cloudbuild.yaml to define the steps. That way you can build your Go app, run tests, and finally build the image, and push it.

There is a `gcr.io/cloud-builders/go` image that you can use to run the go compiler. Here is a cloudbuild.yaml for a app that I built. Based on the docs for the image, I specify the `PROJECT_ROOT` environment variable so that the image will link my project into the `GOPATH`. From there I can run any Go command. I can run go generate, go test, and finally go install to build the binary.

```yaml
steps:
    - name: "gcr.io/cloud-builders/go"
      args: ["generate"]
      env: ["PROJECT_ROOT=github.com/IanLewis/testapp"]
    - name: "gcr.io/cloud-builders/go"
      args: ["test", "./..."]
      env: ["PROJECT_ROOT=github.com/IanLewis/testapp"]
    - name: "gcr.io/cloud-builders/go"
      args:
          [
              "install",
              "-a",
              "-ldflags",
              "'-s'",
              "-installsuffix",
              "cgo",
              "github.com/IanLewis/testapp",
          ]
      env:
          [
              "PROJECT_ROOT=github.com/IanLewis/testapp",
              "CGO_ENABLED=0",
              "GOOS=linux",
          ]
```

In the final step I build the Docker image.

```yaml
- name: 'gcr.io/cloud-builders/docker'
  args: ['build', '--tag=gcr.io/$PROJECT_ID/testapp', '.']
images: ['gcr.io/$PROJECT_ID/testapp']
```

Here is the Dockerfile. go install puts my binary in gopath/bin so I can copy it into my image from there.

```docker
FROM scratch
COPY gopath/bin/testapp /testapp
CMD ["/testapp"]
```

You can submit a build with a cloudbuild.yaml like so:

```shell
gcloud container builds submit --config cloudbuild.yaml
```

This will build us a nice small image that we can pull from `gcr.io/$PROJECT_ID/testapp`.

<!-- markdownlint-enable MD045 -->
