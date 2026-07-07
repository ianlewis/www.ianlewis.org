# Copyright 2024 Ian Lewis
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

include include.mk

# Default port for `make serve`.
SERVE_PORT ?= 8888

# Default build context for `make build` and `make serve`. This is specified in
# an environment variable by Netlify during builds.
# See https://docs.netlify.com/build/configure-builds/environment-variables/#build-metadata
CONTEXT ?= dev
JEKYLL_BUILD_OPTIONS.dev := --drafts --future --unpublished
JEKYLL_BUILD_OPTIONS.deploy-preview := --drafts --future
JEKYLL_BUILD_OPTIONS.production :=
JEKYLL_BUILD_OPTIONS ?= $(JEKYLL_BUILD_OPTIONS.$(CONTEXT))

# renovate: datasource=github-releases depName=aquaproj/aqua versioning=loose
AQUA_VERSION ?= v2.60.1
AQUA_REPO := github.com/aquaproj/aqua
AQUA_CHECKSUM ?= $(AQUA_CHECKSUM.$(kernel).$(arch))
export AQUA_ROOT_DIR = $(MAKEFILE_ROOT)/.aqua

# Ensure that aqua and aqua installed tools are in the PATH.
export PATH := $(AQUA_ROOT_DIR)/bin:$(PATH)

# Node.js setup
#####################################################################

package-lock.json: package.json $(AQUA_ROOT_DIR)/.installed
	@echo "Updating Node.js dependencies..."
	loglevel="notice"
	if [ -n "$(DEBUG_LOGGING)" ]; then
		loglevel="verbose"
	fi
	# NOTE: npm install will happily ignore the fact that integrity hashes are
	# missing in the package-lock.json. We need to check for missing integrity
	# fields ourselves. If any are missing, then we need to regenerate the
	# package-lock.json from scratch.
	nointegrity=""
	noresolved=""
	if [ -f "$@" ]; then
		nointegrity=$$(jq '.packages | del(."") | .[] | select(has("integrity") | not)' < $@)
		noresolved=$$(jq '.packages | del(."") | .[] | select(has("resolved") | not)' < $@)
	fi
	if [ ! -f "$@" ] || [ -n "$${nointegrity}" ] || [ -n "$${noresolved}" ]; then
		# NOTE: package-lock.json is removed to ensure that npm includes the
		# integrity field. npm install will not restore this field if
		# missing in an existing package-lock.json file.
		rm -f $@
		# NOTE: We clean the node_modules directory to ensure that npm install
		#       will not desync between the package.json, package-lock.json
		#       and the node_modules directory. \
		$(MAKE) clean-node-modules
		npm --loglevel="$${loglevel}" install \
			--no-audit \
			--no-fund
	else
		npm --loglevel="$${loglevel}" install \
			--package-lock-only \
			--no-audit \
			--no-fund
	fi

node_modules/.installed: package.json
	@echo "Installing Node.js dependencies..."
	loglevel="silent"
	if [ -n "$(DEBUG_LOGGING)" ]; then
		loglevel="verbose"
	fi
	npm --loglevel="$${loglevel}" clean-install
	npm --loglevel="$${loglevel}" audit signatures
	touch $@

# Python setup
#####################################################################

.uv/venv/bin/activate:
	@echo "Creating Python virtual environment..."
	mkdir -p .uv
	python -m venv .uv/venv
	touch $@

.uv/.installed: requirements-dev.txt .uv/venv/bin/activate
	@echo "Installing Python dependencies..."
	./.uv/venv/bin/pip install -r $< --require-hashes
	touch $@

uv.lock: pyproject.toml .uv/.installed
	@echo "Updating Python dependencies..."
	./.uv/venv/bin/uv lock
	touch $@

.venv/.installed: pyproject.toml .uv/.installed
	@echo "Installing Python dependencies..."
	./.uv/venv/bin/uv sync --locked
	touch $@

# Ruby setup
######################################################################

Gemfile.lock: Gemfile
	@echo "Updating Ruby dependencies..."
	bundle lock --update

.PHONY: bundle-install
bundle-install:
	@echo "Installing Ruby dependencies..."
	bundle check || bundle install

# Aqua setup
#####################################################################

$(AQUA_ROOT_DIR)/.$(AQUA_VERSION).installed:
	@echo "Installing aqua $(AQUA_VERSION)..."
	./third_party/aquaproj/aqua-installer/aqua-installer -v "$(AQUA_VERSION)"
	touch $@

.aqua-checksums.json: .aqua.yaml $(AQUA_ROOT_DIR)/.$(AQUA_VERSION).installed
	@echo "Updating aqua checksums..."
	loglevel="info"
	if [ -n "$(DEBUG_LOGGING)" ]; then
		loglevel="debug"
	fi
	$(AQUA_ROOT_DIR)/bin/aqua \
		--config ".aqua.yaml" \
		--log-level "$${loglevel}" \
		update-checksum \
		--prune

$(AQUA_ROOT_DIR)/.installed: .aqua.yaml $(AQUA_ROOT_DIR)/.$(AQUA_VERSION).installed
	@echo "Installing aqua tools..."
	loglevel="info"
	if [ -n "$(DEBUG_LOGGING)" ]; then
		loglevel="debug"
	fi
	$(AQUA_ROOT_DIR)/bin/aqua \
		--config ".aqua.yaml" \
		--log-level "$${loglevel}" \
		install
	touch $@

## Content
#####################################################################

.PHONY: post
post: ## Start a new blog post.
	@echo "Starting a new blog post..."
	./scripts/new_content.sh

.PHONY: til
til: ## Start a new TIL entry.
	@echo "Starting a new TIL entry..."
	./scripts/new_content.sh \
		--blog til

.PHONY: draft
draft: ## Start a new draft.
	@echo "Starting a new draft..."
	./scripts/new_content.sh \
		--draft

## Build
#####################################################################

.PHONY: all
all: test build ## Run tests and build the site.

.PHONY: jekyll-serve
jekyll-serve: bundle-install
	@echo "Serving the site with Jekyll for context $(CONTEXT)..."
	bundle exec jekyll serve $(JEKYLL_BUILD_OPTIONS)

.PHONY: jekyll-build
jekyll-build: bundle-install
	@echo "Building the site with Jekyll for context $(CONTEXT)..."
	bundle exec jekyll build $(JEKYLL_BUILD_OPTIONS)

.PHONY: build
build: node_modules/.installed ## Build the site.
	@echo "Building the site for context $(CONTEXT)..."
	debug_options=""
	if [ -n "$(DEBUG_LOGGING)" ]; then
		debug_options="--debug"
	fi
	./node_modules/.bin/netlify build \
		--context "$(CONTEXT)" \
		--offline \
		$${debug_options}

.PHONY: serve
serve: node_modules/.installed bundle-install ## Run local development server.
	@echo "Starting local development server on port $(SERVE_PORT)..."
	debug_options=""
	if [ -n "$(DEBUG_LOGGING)" ]; then
		debug_options="--debug"
	fi
	./node_modules/.bin/netlify dev \
		--skip-gitignore \
		--no-open \
		--context "$(CONTEXT)" \
		--offline \
		--port "$(SERVE_PORT)" \
		$${debug_options}

## Testing
#####################################################################

.PHONY: test
test: lint ## Run all tests.

## Scripts
#####################################################################

recent-posts: .venv/.installed ## Print posts published in the last 24 hours.
	@./.venv/bin/python \
		scripts/check-recent-posts.py \
			--hours 24 \
			 content/en/_posts \
			 content/jp/_posts \
			 content/til/_posts

special-date: .venv/.installed ## Print if today is a special date.
	@./.venv/bin/python \
		scripts/check-special-dates.py \
			content/_data/profile.yaml

## Formatting
#####################################################################

.PHONY: format
format: html-format js-format json-format md-format py-format sass-format shfmt yaml-format ## Format all files

.PHONY: html-format
html-format: node_modules/.installed ## Format HTML files.
	@echo "Formatting HTML files..."
	loglevel="log"
	if [ -n "$(DEBUG_LOGGING)" ]; then
		loglevel="debug"
	fi
	files=$$(
		git ls-files --deduplicate \
			'*.html' \
			':!:content/assets/demos' \
			| while IFS='' read -r f; do [ -f "$${f}" ] && echo "$${f}" || true; done
	)
	if [ "$${files}" == "" ]; then
		exit 0
	fi
	./node_modules/.bin/prettier \
		--log-level "$${loglevel}" \
		--no-error-on-unmatched-pattern \
		--write \
		$${files}

.PHONY: js-format
js-format: node_modules/.installed ## Format Javascript files.
	@echo "Formatting Javascript files..."
	loglevel="log"
	if [ -n "$(DEBUG_LOGGING)" ]; then
		loglevel="debug"
	fi
	files=$$(
		git ls-files --deduplicate \
			'*.js' \
			':!:*.min.js' \
			':!:content/assets/demos' \
			| while IFS='' read -r f; do [ -f "$${f}" ] && echo "$${f}" || true; done
	)
	if [ "$${files}" == "" ]; then
		exit 0
	fi
	./node_modules/.bin/prettier \
		--log-level "$${loglevel}" \
		--no-error-on-unmatched-pattern \
		--write \
		$${files}

.PHONY: json-format
json-format: node_modules/.installed ## Format JSON files.
	@echo "Formatting JSON files..."
	loglevel="log"
	if [ -n "$(DEBUG_LOGGING)" ]; then
		loglevel="debug"
	fi
	files=$$(
		git ls-files --deduplicate \
			'*.json' \
			'*.json5' \
			| while IFS='' read -r f; do [ -f "$${f}" ] && echo "$${f}" || true; done
	)
	if [ "$${files}" == "" ]; then
		exit 0
	fi
	./node_modules/.bin/prettier \
		--log-level "$${loglevel}" \
		--no-error-on-unmatched-pattern \
		--write \
		$${files}

.PHONY: license-headers
license-headers: ## Update license headers.
	@echo "Updating license headers..."
	files=$$(
		git ls-files --deduplicate \
			'*.c' \
			'*.cpp' \
			'*.go' \
			'*.h' \
			'*.hpp' \
			'*.js' \
			'*.lua' \
			'*.py' \
			'*.rb' \
			'*.rs' \
			'*.yaml' \
			'*.yml' \
			'Makefile' \
			':!:content/assets/demos' \
			':!:content/_sass/ext' \
			| while IFS='' read -r f; do [ -f "$${f}" ] && echo "$${f}" || true; done
	)
	name=$$(git config user.name)
	if [ "$${name}" == "" ]; then
		>&2 echo "git user.name is required."
		>&2 echo "Set it up using:"
		>&2 echo "git config user.name \"John Doe\""
		exit 1
	fi
	for filename in $${files}; do
		if ! ( head "$${filename}" | $(GREP) -iL "Copyright" > /dev/null ); then
			./third_party/mbrukman/autogen/autogen.sh \
				--in-place \
				--no-code \
				--no-tlc \
				--copyright "$${name}" \
				--license apache \
				"$${filename}"
		fi
	done

.PHONY: md-format
md-format: node_modules/.installed ## Format Markdown files.
	@echo "Formatting Markdown files..."
	loglevel="log"
	if [ -n "$(DEBUG_LOGGING)" ]; then
		loglevel="debug"
	fi
	files=$$(
		git ls-files --deduplicate \
			'*.md' \
			| while IFS='' read -r f; do [ -f "$${f}" ] && echo "$${f}" || true; done
	)
	if [ "$${files}" == "" ]; then
		exit 0
	fi
	# NOTE: prettier uses .editorconfig for tab-width. \
	./node_modules/.bin/prettier \
		--log-level "$${loglevel}" \
		--no-error-on-unmatched-pattern \
		--write \
		$${files}

.PHONY: py-format
py-format: $(AQUA_ROOT_DIR)/.installed ## Format Python files.
	@echo "Formatting Python files..."
	files=$$(
		git ls-files --deduplicate \
			'*.py' \
			| while IFS='' read -r f; do [ -f "$${f}" ] && echo "$${f}" || true; done
	)
	if [ "$${files}" == "" ]; then
		exit 0
	fi
	ruff check --select I --fix $${files}
	ruff format $${files}

.PHONY: sass-format
sass-format: node_modules/.installed ## Format SASS files.
	@echo "Formatting SASS files..."
	loglevel="log"
	if [ -n "$(DEBUG_LOGGING)" ]; then
		loglevel="debug"
	fi
	files=$$( \
		git ls-files --deduplicate \
			'*.scss' \
			':!:content/assets/css/style.scss' \
			':!:content/_sass/ext' \
			| while IFS='' read -r f; do [ -f "$${f}" ] && echo "$${f}" || true; done
	)
	if [ "$${files}" == "" ]; then
		exit 0
	fi
	./node_modules/.bin/prettier \
		--log-level "$${loglevel}" \
		--no-error-on-unmatched-pattern \
		--write \
		$${files}

.PHONY: shfmt
shfmt: $(AQUA_ROOT_DIR)/.installed ## Format bash files.
	@echo "Formatting shell scripts..."
	files=()
	while IFS= read -r -d '' f; do
		if [ -f "$${f}" ] && file "$${f}" | $(GREP) -q -e ':.*shell'; then
			files+=("$${f}")
		fi
	done < <(git ls-files --deduplicate -z ':!:third_party')
	if [ "$${#files[@]}" -eq 0 ]; then
		exit 0
	fi
	shfmt --write --simplify --indent 4 "$${files[@]}"

.PHONY: yaml-format
yaml-format: node_modules/.installed ## Format YAML files.
	@echo "Formatting YAML files..."
	loglevel="log"
	if [ -n "$(DEBUG_LOGGING)" ]; then
		loglevel="debug"
	fi
	files=$$(
		git ls-files --deduplicate \
			'*.yml' \
			'*.yaml' \
	)
	if [ "$${files}" == "" ]; then
		exit 0
	fi
	./node_modules/.bin/prettier \
		--log-level "$${loglevel}" \
		--no-error-on-unmatched-pattern \
		--write \
		$${files}

## Linting
#####################################################################

.PHONY: lint
lint: actionlint check-redirects checkmake commitlint eslint fixme format-check html-validate markdownlint mypy renovate-config-validator ruff shellcheck stylelint textlint yamllint zizmor ## Run all linters.

.PHONY: actionlint
actionlint: $(AQUA_ROOT_DIR)/.installed ## Runs the actionlint linter.
	@echo "Running actionlint..."
	files=$$(
		git ls-files --deduplicate \
			'.github/workflows/*.yml' \
			'.github/workflows/*.yaml' \
			| while IFS='' read -r f; do [ -f "$${f}" ] && echo "$${f}" || true; done
	)
	if [ "$${files}" == "" ]; then
		exit 0
	fi
	actionlint \
		-ignore 'SC2016:' \
		$${files}

.PHONY: check-redirects
check-redirects: .venv/.installed ## Check for redirect loops.
	@echo "Checking for redirect loops..."
	./.venv/bin/python \
		scripts/check-redirects.py

.PHONY: checkmake
checkmake: $(AQUA_ROOT_DIR)/.installed ## Runs the checkmake linter.
	@echo "Running checkmake..."
	files=$$(
		git ls-files --deduplicate \
			'Makefile' \
			'GNUmakefile' \
			| while IFS='' read -r f; do [ -f "$${f}" ] && echo "$${f}" || true; done \
	)
	if [ "$${files}" == "" ]; then
		exit 0
	fi
	if [ "$(OUTPUT_FORMAT)" == "github" ]; then
		checkmake \
			--format '::error file={{.FileName}},line={{.LineNumber}}::{{.Rule}}: {{.Violation}}' \
			$${files}
	else
		checkmake $${files}
	fi

COMMITLINT_FROM_REF ?=
COMMITLINT_TO_REF ?=

.PHONY: commitlint
commitlint: node_modules/.installed ## Run commitlint linter.
	@echo "Running commitlint..."
	commitlint_from=$(COMMITLINT_FROM_REF)
	commitlint_to=$(COMMITLINT_TO_REF)
	if [ "$${commitlint_from}" == "" ]; then
		# Try to get the default branch without hitting the remote server
		if git symbolic-ref --short refs/remotes/origin/HEAD >/dev/null 2>&1; then
			commitlint_from=$$(git symbolic-ref --short refs/remotes/origin/HEAD)
		elif git show-ref refs/remotes/origin/master >/dev/null 2>&1; then
			commitlint_from="origin/master"
		else
			commitlint_from="origin/main"
		fi
	fi
	if [ "$${commitlint_to}" == "" ]; then
		# If upstream of HEAD is on the commitlint_from branch, then we will
		# lint the last commit by default.
		current_branch=$$(git rev-parse --abbrev-ref @{u})
		if [ "$${commitlint_from}" == "$${current_branch}" ]; then
			commitlint_from="HEAD~1"
		fi
		commitlint_to="HEAD"
	fi
	./node_modules/.bin/commitlint \
		--from "$${commitlint_from}" \
		--to "$${commitlint_to}" \
		--verbose \
		--strict

.PHONY: eslint
eslint: node_modules/.installed ## Runs eslint.
	@echo "Running eslint..."
	extraargs=""
	if [ -n "$(DEBUG_LOGGING)" ]; then
		extraargs="--debug"
	fi
	files=$$(
		git ls-files --deduplicate \
			'*.js' \
			'*.cjs' \
			'*.mjs' \
			'*.jsx' \
			'*.mjsx' \
			'*.ts' \
			'*.cts' \
			'*.mts' \
			'*.tsx' \
			'*.mtsx' \
			':!:*.min.js' \
			':!:content/assets/demos' \
			| while IFS='' read -r f; do [ -f "$${f}" ] && echo "$${f}" || true; done
	)
	if [ "$${files}" == "" ]; then
		exit 0
	fi
	if [ "$(OUTPUT_FORMAT)" == "github" ]; then
		exit_code=0
		while IFS="" read -r p && [ -n "$${p}" ]; do
			file=$$(echo "$${p}" | jq -c '.filePath // empty' | tr -d '"')
			while IFS="" read -r m && [ -n "$${m}" ]; do
				severity=$$(echo "$${m}" | jq -c '.severity // empty' | tr -d '"')
				line=$$(echo "$${m}" | jq -c '.line // empty' | tr -d '"')
				endline=$$(echo "$${m}" | jq -c '.endLine // empty' | tr -d '"')
				col=$$(echo "$${m}" | jq -c '.column // empty' | tr -d '"')
				endcol=$$(echo "$${m}" | jq -c '.endColumn // empty' | tr -d '"')
				message=$$(echo "$${m}" | jq -c '.message // empty' | tr -d '"')
				exit_code=1
				case $${severity} in
				"1")
					echo "::warning file=$${file},line=$${line},endLine=$${endline},col=$${col},endColumn=$${endcol}::$${message}"
					;;
				"2")
					echo "::error file=$${file},line=$${line},endLine=$${endline},col=$${col},endColumn=$${endcol}::$${message}"
					;;
				esac
			done <<<$$(echo "$${p}" | jq -c '.messages[]')
		done <<<$$(./node_modules/.bin/eslint \
			--max-warnings 0 \
			--format json \
			$${extraargs} \
			$${files} | jq -c '.[]')
		exit "$${exit_code}"
	else
		./node_modules/.bin/eslint \
			--max-warnings 0 \
			$${extraargs} \
			$${files}
	fi

.PHONY: fixme
fixme: $(AQUA_ROOT_DIR)/.installed ## Check for outstanding FIXMEs.
	@echo "Checking for outstanding FIXMEs..."
	output="default"
	if [ "$(OUTPUT_FORMAT)" == "github" ]; then
		output="github"
	fi
	# NOTE: todos does not use `git ls-files` because many files might be
	# 		unsupported and generate an error if passed directly on the
	# 		command line.
	todos \
		--output "$${output}" \
		--todo-types="FIXME,Fixme,fixme,BUG,Bug,bug,XXX,COMBAK"

.PHONY: format-check
format-check: ## Check that files are properly formatted.
	@echo "Checking that files are properly formatted..."
	if [ -n "$$(git diff)" ]; then
		>&2 echo "The working directory is dirty. Please commit, stage, or stash changes and try again."
		exit 1
	fi
	$(MAKE) format
	exit_code=0
	if [ -n "$$(git diff)" ]; then
		>&2 echo "Some files need to be formatted. Please run '$(MAKE) format' and try again."
		if [ "$(OUTPUT_FORMAT)" == "github" ]; then
			echo "::group::git diff"
		fi
		git --no-pager diff
		if [ "$(OUTPUT_FORMAT)" == "github" ]; then
			echo "::endgroup::"
		fi
		exit_code=1
	fi
	git restore .
	exit "$${exit_code}"

.PHONY: html-validate
html-validate: build node_modules/.installed ## Runs the html-validate linter.
	@echo "Running html-validate..."
	./node_modules/.bin/html-validate \
		--config htmlvalidate.mjs \
		_site

.PHONY: shellcheck
shellcheck: $(AQUA_ROOT_DIR)/.installed ## Runs the shellcheck linter.
	@echo "Running shellcheck..."
	files=()
	while IFS= read -r -d '' f; do
		if [ -f "$${f}" ] && file "$${f}" | $(GREP) -q -e ':.*shell'; then
			files+=("$${f}")
		fi
	done < <(git ls-files --deduplicate -z ':!:third_party')
	if [ "$${#files[@]}" -eq 0 ]; then
		exit 0
	fi
	shellcheck \
		--severity=style \
		--external-sources \
		"$${files[@]}"

.PHONY: stylelint
stylelint: node_modules/.installed ## Runs the stylelint linter.
	@echo "Running stylelint..."
	files=$$(
		git ls-files --deduplicate \
			'*.scss' \
			':!:content/assets/css/style.scss' \
			':!:content/_sass/ext' \
	)
	if [ "$(OUTPUT_FORMAT)" == "github" ]; then
		./node_modules/.bin/stylelint \
			--custom-formatter=@csstools/stylelint-formatter-github \
			$${files}
	else
		./node_modules/.bin/stylelint $${files}
	fi

.PHONY: markdownlint
markdownlint: node_modules/.installed $(AQUA_ROOT_DIR)/.installed ## Runs the markdownlint linter.
	@echo "Running markdownlint..."
	# NOTE: Issue and PR templates are handled specially so we can disable
	# MD041/first-line-heading/first-line-h1 without adding an ugly html comment
	# at the top of the file.
	files=$$( \
		git ls-files --deduplicate \
			'*.md' \
			| while IFS='' read -r f; do [ -f "$${f}" ] && echo "$${f}" || true; done
	)
	if [ "$${files}" == "" ]; then
		exit 0
	fi
	./node_modules/.bin/markdownlint-cli2 $${files}

.PHONY: mypy
mypy: .venv/.installed ## Runs the mypy type checker.
	@echo "Running mypy..."
	files=$$(
		git ls-files --deduplicate \
			'*.py' \
			| while IFS='' read -r f; do [ -f "$${f}" ] && echo "$${f}" || true; done
	)
	if [ "$${files}" == "" ]; then
		exit 0
	fi
	./.venv/bin/mypy \
		--config-file mypy.ini \
		$${files}

.PHONY: renovate-config-validator
renovate-config-validator: node_modules/.installed ## Validate Renovate configuration.
	@echo "Validating Renovate configuration..."
	./node_modules/.bin/renovate-config-validator \
		--strict

.PHONY: ruff
ruff: $(AQUA_ROOT_DIR)/.installed ## Runs the ruff linter.
	@echo "Running ruff..."
	files=$$(
		git ls-files --deduplicate \
			'*.py' \
			| while IFS='' read -r f; do [ -f "$${f}" ] && echo "$${f}" || true; done
	)
	if [ "$${files}" == "" ]; then
		exit 0
	fi
	if [ "$(OUTPUT_FORMAT)" == "github" ]; then
		ruff check --output-format=github $${files}
	else
		ruff check $${files}
	fi

.PHONY: textlint
textlint: node_modules/.installed $(AQUA_ROOT_DIR)/.installed ## Runs the textlint linter.
	@echo "Running textlint..."
	files=$$(
		git ls-files --deduplicate \
			'*.md' \
			'*.txt' \
			':!:requirements*.txt' \
			':!:content/robots.txt' \
			':!:content/.well-known' \
			':!:content/*.pem.pub.txt' \
			':!:content/_drafts' \
			| while IFS='' read -r f; do [ -f "$${f}" ] && echo "$${f}" || true; done
	)
	if [ "$${files}" == "" ]; then
		exit 0
	fi
	./node_modules/.bin/textlint $${files}

.PHONY: yamllint
yamllint: .venv/.installed ## Runs the yamllint linter.
	@echo "Running yamllint..."
	files=$$(
		git ls-files --deduplicate \
			'*.yml' \
			'*.yaml' \
			| while IFS='' read -r f; do [ -f "$${f}" ] && echo "$${f}" || true; done
	)
	if [ "$${files}" == "" ]; then
		exit 0
	fi
	format="standard"
	if [ "$(OUTPUT_FORMAT)" == "github" ]; then
		format="github"
	fi
	./.venv/bin/yamllint \
		--strict \
		--format "$${format}" \
		$${files}

.PHONY: zizmor
zizmor: .venv/.installed ## Runs the zizmor linter.
	@echo "Running zizmor..."
	# NOTE: On GitHub actions this outputs SARIF format to zizmor.sarif.json
	#       in addition to outputting errors to the terminal.
	files=$$(
		git ls-files --deduplicate \
			'.github/workflows/*.yml' \
			'.github/workflows/*.yaml' \
			| while IFS='' read -r f; do [ -f "$${f}" ] && echo "$${f}" || true; done
	)
	if [ "$${files}" == "" ]; then
		exit 0
	fi
	format="plain"
	if [ "$(OUTPUT_FORMAT)" == "github" ]; then
		./.venv/bin/zizmor \
			--quiet \
			--pedantic \
			--format sarif \
			$${files} > zizmor.sarif.json
		format="github"
	fi
	./.venv/bin/zizmor \
		--quiet \
		--pedantic \
		--format "$${format}" \
		$${files}

## Maintenance
#####################################################################

.PHONY: update-lockfiles
update-lockfiles: .aqua-checksums.json Gemfile.lock package-lock.json uv.lock ## Update lockfiles.

.PHONY: todos
todos: $(AQUA_ROOT_DIR)/.installed ## Print outstanding TODOs.
	@echo "Checking for outstanding TODOs..."
	output="default"
	if [ "$(OUTPUT_FORMAT)" == "github" ]; then
		output="github"
	fi
	# NOTE: todos does not use `git ls-files` because many files might be
	# 		unsupported and generate an error if passed directly on the command
	# 		line.
	todos \
		--output "$${output}" \
		--todo-types="TODO,Todo,todo,FIXME,Fixme,fixme,BUG,Bug,bug,XXX,COMBAK"

.PHONY: clean-node-modules
clean-node-modules:
	@echo "Cleaning up node_modules..."
	$(RM) -r node_modules

.PHONY: clean
clean: clean-node-modules ## Delete temporary files.
	@echo "Cleaning up temporary files..."
	$(RM) -r .bin
	$(RM) -r $(AQUA_ROOT_DIR)
	$(RM) -r .venv
	$(RM) -r .uv
	$(RM) *.sarif.json
	@$(RM) -r _site
	@$(RM) -r .netlify
	@$(RM) -r deno.lock
	@$(RM) -r content/.jekyll-cache
