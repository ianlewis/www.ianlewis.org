---
layout: post
title: "Self-Contained Project Repositories"
date: "2026-08-24 00:00:00 +0900"
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

The core of the idea is to bootstrap dependency management tools that allow you
install pinned versions of dependencies into the project directory itself.

Many existing tools like [`mise`](https://mise.jdx.dev/) and
[`nix`](https://nixos.org/) incorporate ideas like this but I wanted my projects
to be as self-contained as possible, rely on as few outside tools as possible,
and work in as many environments as possible. Another goal is to ensure that all
dependencies are pinned and verified which is not always possible with existing
tools[^1].

For example, most developer machines will have `bash`, `git`, `make`, `awk`,
`sed` etc. installed. That makes it possible to write a `Makefile` and write
short Bash scripts for recipes (macOS will require that we install `coreutils`
and a modern Bash and GNU Make via Homebrew but that is relatively easy and many
have done it already).

These recipes can bootstrap the project by downloading and installing
dependencies into a local directory. After, that they can be run to build the
project and run tests. The goal is that a developer can clone the repository,
run a single command, and have a fully working development environment without
needing to install anything else.

By way of example, this recipe installs the `actionlint` linter into a local
directory and runs it on all Git-tracked GitHub Actions workflow files.

```make
.PHONY: actionlint
actionlint: $(AQUA_ROOT_DIR)/.installed ## Runs the actionlint linter.
    @echo "Running actionlint..."
    files=$$(
        git ls-files --deduplicate \
            '.github/workflows/*.yml' \
            '.github/workflows/*.yaml'
    )
    if [ "$${files}" == "" ]; then
        exit 0
    fi
    actionlint \
        -ignore 'SC2016:' \
        $${files}
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
            - uses: actions/checkout@3d3c42e5aac5ba805825da76410c181273ba90b1 # v7.0.1
            - run: make actionlint
```

# Static Binaries

Static binaries make it really easy to create self-contained project
repositories. You can just download the binary and run it without needing to
install anything else. However, it's a bit tricky to do this securely. At a
minimum, you should verify the checksum of the downloaded binary. Ideally the
project provides [SLSA provenance attestations](https://slsa.dev/).

My favorite tool for managing and verifying static binaries is
[`aqua`](https://aquaproj.gitub.io/)[^2]. Aqua allows you to specify the tools
you want to install and their versions in a single configuration file. It also
supports a `aqua-checksums.json` lockfile that allows you to verify the
checksums of the downloaded binaries. It also has support for
[SLSA provenance attestations](https://slsa.dev/) including
[GitHub Artifact Attestations](https://docs.github.com/en/actions/concepts/security/artifact-attestations)

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

# Language Runtimes

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

# Virtual Environments

Various languages have their own virtual environment tools. For example, Python
can install packages into a local `venv`; Node.js installs packages into
`node_modules`; Ruby has `bundler` which can be configured to install in a local
repository etc. Using these tools allows us to install a specific set of pinned
dependencies without polluting the global environment.

The nature of the self-contained project repository means that we can clean
these up and reinstall them at any time. This helps engineers keep a clean
environment and ensure reproducibility.

# Clutter

This style of self-contained project repositories are not without their
downsides. The local space used by the dependencies can be significant,
especially for Node.js dependencies. The repository will also be cluttered with
a good number of dependency files (e.g. `package.json`, `pyproject.toml`,
`Gemfile`), their associated lockfiles, configuration files etc.

Overall, I think the benefits of self-contained project repositories outweigh
the downsides but you may want to make judicious use of subdirectories to
organize project source files.

# Automation

Using tools like [`renovate`](https://mend.io/renovate),
[`dependabot`](https://github.com/dependabot),
and
[`autofix.ci`](https://autofix.ci/) can help keep dependencies up to date and
reduce the maintenance burden of project repositories. Renovate will create PRs
to update dependencies and can be configured to automatically merge them if the
tests pass. `autofix.ci` can automatically fix linting errors and formatting
issues and update the PR. Languages like Go also include tools like `go fix`
which can be incorporated to update and apply modernizations to your codebase
automatically.

[^1]:
    [Mise-en-place lacks support](https://mise.jdx.dev/dev-tools/mise-lock.html#backend-support)
    for checksum verification and SLSA provenance attestations for all backends.

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
