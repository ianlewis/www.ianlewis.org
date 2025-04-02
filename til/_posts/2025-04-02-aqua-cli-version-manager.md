---
layout: post
title: "TIL: Aqua CLI Version Manager"
date: "2025-04-02 00:00:00 +0900"
blog: til
tags: tools
render_with_liquid: false
---

When I worked on the [SLSA](https://slsa.dev/) project I came across the [Aqua](https://aquaproj.github.io/) CLI version manager. It's a pretty cool tool that acts sort of like a package manager for CLI binaries.

The `aqua generate -i` command allows you to search for commands via the [Aqua registry](https://github.com/aquaproj/aqua-registry) and saves the tool dependency in `aqua.yaml`.

```yaml
checksum:
  enabled: true
  require_checksum: true
  supported_envs:
    - all
registries:
  - type: standard
    ref: v4.333.3 # renovate: depName=aquaproj/aqua-registry
packages:
  - name: rhysd/actionlint@v1.7.7
  - name: koalaman/shellcheck@v0.10.0
  - name: jqlang/jq@jq-1.7.1
  - name: mvdan/sh@v3.11.0
  - name: JohnnyMorganz/StyLua@v2.0.2
  - name: Kampfkarren/selene@0.28.0
```

Another thing that's cool is that it can keep a checksum of the dependency in `aqua-checksums.json` or use SLSA provenence to verify the integrity of the downloaded binary tools. There are a lot of features like managing tool versions per project as well. The only downside I've found so far is that it can only really support tools that can be compiled to a binary so it can't really manage tools written in interpretet languages like JavaScript, or Python.
