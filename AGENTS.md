# `AGENTS.md`

This file provides guidance to Coding Agents like Claude Code
([`claude.ai/code`](https://claude.ai/code)) or GitHub Copilot when working with
code in this repository.

## Project Overview

This is Ian Lewis's personal website (https://www.ianlewis.org/) - a
Jekyll-based static site hosted on Netlify. The site features multilingual blog
posts (English and Japanese), a "Today I Learned" section, and personal project
information.

## Key Architecture

- **Jekyll Static Site**: Uses Jekyll with a modified version of the
  `plainwhite` theme. The theme is vendored in this repository.
- **Multi-language Content**:
    - `/en/_posts/` - English blog posts
    - `/jp/_posts/` - Japanese blog posts
    - `/til/_posts/` - Today I Learned posts
- **Configuration**: `_config.yml` contains Jekyll settings, theme config, and
  social links
- **Deployment**: Automatically deployed to Netlify via GitHub Actions

## Essential Commands

### Development

```bash
make serve                    # Start Jekyll development server
make build                    # Build the Jekyll site
make til                      # Create new TIL entry
```

### Linting and Formatting

```bash
make lint                     # Run all linters (actionlint, eslint, markdownlint, textlint, yamllint, etc.)
make format                   # Format all files (HTML, JS, JSON, Markdown, SASS, YAML)
```

### Individual Tools

```bash
make eslint                   # Lint JavaScript files
make markdownlint             # Lint Markdown files
make textlint                 # Check grammar/style in content
make html-validate            # Validate HTML after build
make yamllint                 # Lint YAML files
```

### Maintenance

```bash
make license-headers          # Update license headers on source files
make todos                    # List outstanding TODO comments
make clean                    # Remove temporary files and dependencies
```

## Development Setup

The project uses multiple package managers and tools:

- **Node.js**: Frontend tooling (`eslint`, `prettier`, `textlint`, etc.)
- **Ruby/Jekyll**: Static site generation
- **Python**: Additional linting tools (`yamllint`, `zizmor`)
- **Aqua**: Tool version management

Dependencies are automatically installed via the `Makefile`. Dependencies should
not be installed manually. These dependencies include:

- Node.js packages installed in `node_modules/`.
- Ruby gems installed with Bundler.
- Python packages installed in a virtual environment.

## Content Structure

- Blog posts use Jekyll front matter with categories, dates, and permalinks
- Images stored in `/assets/images/`
- SASS stylesheets in `/_sass/`
- Static pages at root level (`index.md`, `projects.md`, etc.)
- Special directories: `.well-known/` for site verification

## Important Notes

- All content files require proper license headers (Apache 2.0)
- Markdown files must pass `markdownlint` and `textlint` checks
- HTML output is validated after Jekyll builds with `make html-validate`
- GitHub Actions workflow enforces all linting rules
- The site supports both light and dark themes
- Social media links include Bluesky, Mastodon, GitHub, LinkedIn
