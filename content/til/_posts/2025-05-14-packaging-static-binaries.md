---
layout: post
title: "TIL: Packaging Static Binaries"
date: "2025-05-14 00:00:00 +0900"
blog: til
tags: programming python rust
render_with_liquid: false
---

I have been using the [`zizmor`](https://github.com/zizmorcore/zizmor) project
for a while to lint GitHub Actions workflows for security issues. Zizmor is a
(mostly) static binary written in Rust so it should be a relatively
straightforward install. But I noticed that it can be installed via unexpected
ways like by Python package.

Recently the company Astral has been building many Python tools in Rust, like
[`uv`](https://docs.astral.sh/uv/) and [`ruff`](https://docs.astral.sh/ruff/),
and creating many integrations between the two languages. Further integrations
are made possible by [`PyO3`](https://pyo3.rs/) and
[`maturin`](https://maturin.rs/).

Maturin is a build backend for Python packages that supports Rust crates. It
also has another feature that allows you to build a pure Rust binary and package
it as a Python package.

```shell
pip install zizmor
```

This makes it really easy to install in places where you have Python already
installed, and `zizmor` is easily added to the `$PATH`.. It occurred to me that
you could do this [with npm as
well](https://github.com/getsentry/sentry.engineering/blob/main/data/blog/publishing-binaries-on-npm.md).
