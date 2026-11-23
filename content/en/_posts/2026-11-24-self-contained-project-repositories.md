---
layout: post
title: "Self-Contained Project Repositories"
date: "2026-11-24 00:00:00 +0900"
blog: en
tags:
    - tech
    - programming
permalink: /en/self-contained-project-repositories
render_with_liquid: false
---

Recently I've been obsessed with the idea of self-contained project repositories
— repositories that contain (almost) everything needed to build the project and
run tests reproducibly.

In the past I had issues maintaining a `Makefile` for local development in
addition to the GitHub Actions workflows for continuous integration. Both do the
same thing but because the environments were so different, they necessitated
duplicate code and added a maintenance burden.

Dependencies for each environment were also installed differently so each
dependency might be installed at a different version. This made it difficult to
reproduce issues locally that might be failing in CI.

Multiple environments that install various versions of dependencies also makes
it hard to maintain the security of development and CI/CD environments
against supply chain attacks. Many OSS projects have been the target of supply
chain attacks and this can easily flow to downstream projects.

## Self-Containment

The solution I have come up with is self-contained projects. The core of the
idea is to install pinned versions of dependencies into the project directory
itself, including any additional tools needed to manage those dependencies.

Many existing tools like [`mise`](https://mise.jdx.dev/),
[`asdf`](https://asdf-vm.com/) and [`nix`](https://nixos.org/) incorporate ideas
like this but I wanted my projects to be as self-contained as possible, rely on
as few outside tools as possible, and work in as many environments as possible.
Another goal is to ensure that all dependencies are pinned and verified which is
not always possible with existing tools[^1].

For example, most developer machines will have `bash`, `git`, `make`, `awk`,
`sed` etc. installed. That makes it possible to write a `Makefile` and write
short Bash scripts for recipes (macOS will require that we install `coreutils`
and a modern Bash and GNU Make via Homebrew but that is relatively easy and many
have done it already).

These recipes can first bootstrap the project by downloading and installing
dependencies into a local directory. After that, they can use the locally
installed dependencies to build the project and run tests. The goal is that a
developer can clone the repository, run a single command, and have a fully
working development environment without needing to install anything else.

By way of example, this recipe installs the `actionlint` linter into a local
directory and runs it on all Git-tracked GitHub Actions workflow files.

```make
# 1. Bootstrap the aqua tool manager into a local directory.
.aqua/.$(AQUA_VERSION).installed:
    @echo "Installing aqua $(AQUA_VERSION)..."
    ./third_party/aqua-installer/aqua-installer -v "$(AQUA_VERSION)"
    touch $@

# 2. Install tools managed by aqua into a local directory.
.aqua/.installed: .aqua.yaml .aqua/.$(AQUA_VERSION).installed
    @echo "Installing aqua tools..."
    .aqua/bin/aqua \
        --config .aqua.yaml \
        install
    touch $@

# 3. Run linters and build tools using the locally installed dependencies.
.PHONY: actionlint
actionlint: .aqua/.installed ## Runs the actionlint linter.
    @echo "Running actionlint..."
    actionlint \
        -ignore 'SC2016:' \
        .github/workflows/*.yml \
        .github/workflows/*.yaml
```

This has the added benefit of being very easy to use for AI agents and CI/CD
pipelines. The pipeline can just clone the repository and run the same command
to set up the environment and run tests. For example, this simple GitHub Actions
workflow will run exactly same in GitHub Actions as it does on a developer
machine:

```yaml
jobs:
    actionlint:
        runs-on: ubuntu-latest
        steps:
            - uses: actions/checkout@v7
            - run: make actionlint
```

AI agents running in sandboxed environments can similarly clone the repository
and run the same command to set up a consistent environment.

## Static Binaries

Static binaries make it really easy to create self-contained project
repositories. You can just download the binary and run it without needing to
install anything else. However, it can be a bit tricky to do this securely. At a
minimum, you should verify the checksum of the downloaded binary. Ideally the
project provides [SLSA provenance attestations](https://slsa.dev/).

My favorite tool for managing and verifying static binaries is
[`aqua`](https://aquaproj.github.io/)[^2]. Aqua allows you to specify the tools
you want to install and their versions in a single configuration file. It also
supports requiring checksums which are stored in `aqua-checksums.json` lockfile.
Downloads can then be validated against the checksums to ensure they haven't
been tampered with. It also has support for
[SLSA provenance attestations](https://slsa.dev/) including
[GitHub Artifact Attestations](https://docs.github.com/en/actions/concepts/security/artifact-attestations).

```yaml
# aqua.yaml
checksum:
    enabled: true
    require_checksum: true
    supported_envs:
        - all
registries:
    - type: standard
      ref: v4.539.0 # renovate: depName=aquaproj/aqua-registry
packages:
    - name: rhysd/actionlint@v1.7.12
    - name: jqlang/jq@jq-1.8.2
    - name: ianlewis/todos@v0.14.0
    - name: checkmake/checkmake@v0.3.2
```

## Language Runtimes

Projects may use various tools for linting and building the project. Regardless,
of the primary language of the project, you might use a linter written in
Python, a formatter written in TypeScript, and a build tool written in Rust.

For this we will want to support using these tools while only relying on the
fact that the runtime itself is installed. We can further encourage the use of
specific versions of the runtime using the
[`.tool-versions` file convention](https://asdf-vm.com/manage/configuration.html#tool-versions)[^3].
This allows us to install the right version of the runtime for each project
using tools like `asdf`, `pyenv`, `rbenv`, etc. This is also easy to support in
CI/CD pipelines like GitHub Actions by passing the file to the appropriate
`setup` action (`setup-python`, etc.).

I prefer the `pyenv`, `rbenv`, and `nodenv` tools for managing language
runtimes. They have few dependencies, and incorporate verifying checksums of the
downloaded runtime archives.

## Virtual Environments

Various languages have their own virtual environment tools. For example, Python
can install packages into a local `venv`, Node installs packages into
`node_modules`; Ruby has `bundler` which can be configured to install in a local
repository. Using these tools allows us to install a specific set of pinned
dependencies without polluting the global environment.

Each of these tools can be configured to save and require checksums in their
respective lockfiles much like we already do for static binaries.

The nature of the self-contained project repository also means that we can clean
these up and reinstall them at any time. This helps engineers keep a clean
environment and ensure reproducibility.

## Automation

Using tools like [`renovate`](https://mend.io/renovate),
[`dependabot`](https://github.com/dependabot), and
[`autofix.ci`](https://autofix.ci/) can help keep dependencies up to date and
reduce the maintenance burden of project repositories. Renovate will create PRs
to update dependencies and can be configured to automatically merge them if the
tests pass. `autofix.ci` can apply automatically fixed linter errors and
formatting issues and on PRs.

```yaml
- name: format code
  run: make format

- name: update lockfiles
  run: make update-lockfiles

- uses: autofix-ci/action@v1
  with:
      commit-message: "ci(deps): auto updates"
```

Languages like Go also include tools like [`go fix`](https://go.dev/blog/gofix)
which can be incorporated to update and apply modernizations to your codebase
automatically. With this, your codebase could automatically get a PR to updated
dependencies which is also modernized and updated to use the latest language
features and best practices.

## Clutter

This style of self-contained project repositories are not without their
downsides. The local space used by the dependencies can be significant,
especially for Node.js dependencies. The repository will also be cluttered with
a good number of dependency files (e.g. `.aqua.yaml`, `package.json`,
`pyproject.toml`, `Gemfile`), their associated lockfiles, configuration files
etc.

Overall, I think the benefits of self-contained project repositories outweigh
the downsides but you may want to make judicious use of subdirectories to
organize project source files.

## Putting It into Practice

I have put these ideas into practice in a set of repository templates on GitHub.

- [`ianlewis/repo-template`](https://github.com/ianlewis/repo-template) - A
  generic repository template for any language.
- [`ianlewis/repo-template-go`](https://github.com/ianlewis/repo-template-go) - A
  repository template for Go projects.
- [`ianlewis/repo-template-py`](https://github.com/ianlewis/repo-template-py) - A
  repository template for Python projects.
- [`ianlewis/repo-template-ts`](https://github.com/ianlewis/repo-template-ts) - A
  repository template for JavaScript & TypeScript projects.

Each of these templates includes a `Makefile` with recipes to install
dependencies, run linters, and run tests. They also include GitHub Actions
workflows that use same recipes in CI/CD pipelines.

Language-specific templates also include the appropriate configuration files for
the language runtime and virtual environment tools. For example, the Go template
includes `go.mod` and `go.sum` files, and workflows for running `go test` and
`golangci-lint`.

Please check out the templates and let me know if you have any feedback or
suggestions for improvements.

[^1]:
    [Mise-en-place lacks support](https://mise.jdx.dev/dev-tools/mise-lock.html#backend-support)
    for strict pinning and checksum verification and SLSA provenance
    attestations for all backends.

[^2]:
    Mise-en-place is more popular but actually uses the
    [Aqua registry](https://github.com/aquaproj/aqua-registry) under the hood
    for most of its supported tools

[^3]:
    Unfortunately, the `.tool-versions` file convention is not supported by
    the `pyenv`, `rbenv`, and `nodenv` tools which use the `.python-version`,
    `.ruby-version`, and `.node-version` files respectively. However, the `asdf`
    tool supports all of these languages and can read the `.tool-versions` file
    so I tend to conservatively use separate files.
