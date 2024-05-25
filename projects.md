---
# Feel free to add content and custom Front Matter to this file.
# To modify the layout, see https://jekyllrb.com/docs/themes/#overriding-theme-defaults
# title: Ian Lewis

layout: page
permalink: /projects
---

# Projects

These are some of my current and past projects.

## Current Projects

<img align="left" src="/assets/images/slsa-logo-green.svg" height="80" style="margin-right: 10px">

[SLSA](https://slsa.dev/) is a security framework, a checklist of standards and controls to prevent
tampering, improve integrity, and secure packages and infrastructure. It’s how
you get from "safe enough" to being as resilient as possible, at any link in
the chain.

I am working on SLSA tooling for GitHub that supports [SLSA v1.0 Build
L3](https://slsa.dev/spec/v1.0/levels#build-l3) at
[slsa-framework/slsa-github-generator](https://github.com/slsa-framework/slsa-github-generator)
and SLSA provenance verification at
[slsa-framework/slsa-verifier](https://github.com/slsa-framework/slsa-verifier).

## Past Projects

<img align="left" src="/assets/images/gvisor.png" height="80" style="margin-right: 10px">

[gVisor](https://gvisor.dev/) is an open-source Linux-compatible sandbox that
runs anywhere existing container tooling does. It enables cloud-native
container security and portability. gVisor leverages years of experience
isolating production workloads at Google.

I made major improvements to gVisor in the areas of Linux kernel compatibility,
DOS prevention through resource management, crash reporting, OCI seccomp
support, and Kubernetes integrations including the [minikube
addon](https://github.com/kubernetes/minikube/tree/master/deploy/addons/gvisor),
[containerd shim](https://github.com/google/gvisor/tree/master/shim), Docker,
and [Knative](https://gvisor.dev/docs/tutorials/knative/).

### Connpass

<img align="left" src="/assets/images/connpass_logo_1.png" height="80" style="margin-right: 10px">

Connpass is an IT events platform developed while at
[BeProud](https://www.beproud.jp/). It made early use of social media
connections as a way to recommend events, and provided unique features needed
by the IT community.

I began and led early development starting from scratch through [launch in Oct
2011](/jp/connpass), and continuing until 2014. I led technical development and design,
proposing, designing, developing and launching numerous features including
social network integration, multiple attendee types, access analytics, and
community group management.

### PyCon JP

<img align="left" src="/assets/images/pyconjp_logo.png" height="80" style="margin-right: 10px">

PyCon JP is the largest event for the Python Community in Japan which boasts
10s of thousands of members thanks in large part to it's efforts. It is
currently supported by the PyCon JP non-profit foundation which helps new
developers through bootcamps, learning events, and sponsorships.

I [co-founded PyCon JP with Manabu Terada, Iqbal Abdullah, and Yasushi Masuda
while at PyCon Singapore in
2010](https://www.pycon.jp/history.html#pycon-apac-in-singapore). After that I
held various roles in the event, serving mostly as international liason,
recruiting international speakers, but also contributing to the program
committee. I was media lead for [PyCon JP 2014](https://pycon.jp/2014/) where I
re-built the website, CFP, and presentation session management. I served on the
board of the PyCon JP non-profit foundation as Vice Chair from it's inception
in 2013 until 2019.
