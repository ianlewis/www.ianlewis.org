---
layout: post
title: "TIL: Syncing with GitHub Repository Templates"
date: "2025-04-11 00:00:00 +0900"
blog: til
tags: git programming
render_with_liquid: false
---

GitHub allows you to create repositories from a [template
repository](https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-repository-from-a-template).
This is useful because the template repository can include various tools and
configuration specific to your type of project. One good example is the
[`typescript-action`](https://github.com/actions/typescript-action) template for
GitHub Actions written in TypeScript.

However, when creating a repository from a repository template, your new
repository is not a fork. Instead, it is a squashed version of the template
repository with one commit and is totally unrelated to the new repository.

This is fine for most situations where you want to create a new repository as a
one off and continue development from there. However, you may want to
incorporate changes made to the repository template since your repository was
created.

You can do this by using `git merge --squash --allow-unrelated-histories`. This
allows you to merge the repository template as a single commit on the `HEAD` of
your repository. If merge conflicts occur you can resolve them as with any
merge.

Here is an example using my
[`repo-template`](https://github.com/ianlewis/repo-template) template
repository.

```shell
# One time step: Add the repository template as a remote.
git remote add repo-template git@github.com:ianlewis/repo-template.git

# Fetch the latest version of the repo-template.
git fetch repo-template main

# Create a new squash merge commit.
git merge --no-edit --signoff --squash \
    --allow-unrelated-histories repo-template/main
```
