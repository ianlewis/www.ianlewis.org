# `www.ianlewis.org`

[![tests](https://github.com/ianlewis/www.ianlewis.org/actions/workflows/pull_request.tests.yml/badge.svg)](https://github.com/ianlewis/www.ianlewis.org/actions/workflows/pull_request.tests.yml)
[![Netlify Status](https://api.netlify.com/api/v1/badges/9e982427-95f4-4ddd-8853-a843296da510/deploy-status)](https://app.netlify.com/sites/www-ianlewis-org/deploys)
[![OpenSSF Scorecard](https://api.securityscorecards.dev/projects/github.com/ianlewis/www.ianlewis.org/badge)](https://securityscorecards.dev/viewer/?uri=github.com%2Fianlewis%2Fwww.ianlewis.org)

This repository holds the contents for
[`https://www.ianlewis.org/`](https://www.ianlewis.org/). It is a
[Jekyll](https://jekyllrb.com/) static website and is deployed on
[Netlify](https://www.netlify.com/).

## Getting Started

### Prerequisites

This project requires the following tools to be installed:

- **Node.js** 22.20.0 (see [`.node-version`](.node-version))
- **Ruby** 3.4.6 (see [`.ruby-version`](.ruby-version))
- **Python** 3.13.7 (see [`.python-version`](.python-version))
- **Make** (for running build commands)

You can use version managers like [nvm](https://github.com/nvm-sh/nvm),
[rbenv](https://github.com/rbenv/rbenv), or [pyenv](https://github.com/pyenv/pyenv)
to install the correct versions.

### Initial Setup

The project uses a `Makefile` to automate dependency installation and common
tasks. Dependencies are automatically installed when you run make commands, so
manual installation is not required.

To verify your setup, run:

```shell
make help
```

This will display all available make commands.

### Building the Site

To build the static site:

```shell
make build
```

This will:

- Install Node.js dependencies (if needed)
- Install Ruby gems via Bundler (if needed)
- Build the Jekyll site using Netlify's build configuration
- Output the built site to the `_site` directory

### Running the Development Server

To start a local development server:

```shell
make serve
```

The site will be available at `http://localhost:8888` by default. The server
includes live reload functionality for development.

You can customize the port:

```shell
SERVE_PORT=3000 make serve
```

### Testing Your Changes

Before submitting changes, run all linters and tests:

```shell
make test
```

This runs:

- All linters (actionlint, eslint, markdownlint, textlint, yamllint, etc.)
- Format checks
- HTML validation (after building)

You can also run individual linters:

```shell
make markdownlint    # Lint Markdown files
make eslint          # Lint JavaScript files
make textlint        # Check grammar/style in content
```

### Formatting Code

To automatically format all files:

```shell
make format
```

This will format HTML, JavaScript, JSON, Markdown, SASS, and YAML files
according to the project's style guidelines.

### Creating Content

To create a new "Today I Learned" (TIL) entry:

```shell
make til
```

This will launch an interactive script to create a new TIL post.

### Additional Resources

- See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed contribution guidelines
- See [AGENTS.md](AGENTS.md) for information about the project architecture
- Run `make help` to see all available commands
