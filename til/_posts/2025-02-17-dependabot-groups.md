---
layout: post
title: "TIL: Grouping Dependabot updates"
date: "2025-02-17 00:00:00 +0900"
blog: til
tags: github
render_with_liquid: false
---

Today I learned, Dependabot has a way to group updates by type. This page has
some examples of how to do this.

[Optimizing the creation of pull requests for Dependabot version updates](https://docs.github.com/en/code-security/dependabot/dependabot-version-updates/optimizing-pr-creation-version-updates)

I had some experience using [Renovate](https://www.mend.io/renovate/) to group
updates when working on `slsa-github-generator`
([`renovate.json`](https://github.com/slsa-framework/slsa-github-generator/blob/main/renovate.json))
but I didn't realize that Dependabot has this feature too. I think it's a
somewhat recent feature.

For npm I group minor and patch updates into PRs by development dependencies and
production dependencies. Major version updates get their own PRs.

```yaml
- package-ecosystem: "npm"
  directory: "/"
  schedule:
      interval: "monthly"
  groups:
      # Group all dependencies by with minor or patch version updates into one
      # PR with production and development dependencies grouped into separate
      # PRs.
      # All security updates and major updates are on separate PRs
      production-dependencies:
          dependency-type: "production"
          applies-to: "version-updates"
          patterns:
              - "*"
          update-types:
              - "minor"
              - "patch"
      development-dependencies:
          dependency-type: "development"
          applies-to: "version-updates"
          patterns:
              - "*"
          update-types:
              - "minor"
              - "patch"
```
