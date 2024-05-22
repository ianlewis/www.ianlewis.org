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

### Supply-chain Levels for Software Artifacts (SLSA)

<img align="left" src="/assets/images/slsa-logo-mono.svg" width="140" height="140" style="margin-right: 10px">

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

### gVisor

<img align="left" src="/assets/images/gvisor.png" height="140" style="margin-right: 10px">

[gVisor](https://gvisor.dev/) is an open-source Linux-compatible sandbox that
runs anywhere existing container tooling does. It enables cloud-native
container security and portability. gVisor leverages years of experience
isolating production workloads at Google.

I made major improvements to gVisor in the areas of Linux kernel compatibility,
DOS prevention through resource management, crash reporting, OCI seccomp
support, and Kubernetes integrations including the minikube addon, containerd
shim, Docker, and Knative.

### Connpass

TODO

### PyCon JP

TODO
