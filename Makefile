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

uname_s := $(shell uname -s)
uname_m := $(shell uname -m)
arch.x86_64 := amd64
arch.aarch64 := arm64
arch = $(arch.$(uname_m))
kernel.Linux := linux
kernel = $(kernel.$(uname_s))

SHELL := /bin/bash
OUTPUT_FORMAT ?= $(shell if [ "${GITHUB_ACTIONS}" == "true" ]; then echo "github"; else echo ""; fi)
REPO_ROOT = $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
REPO_NAME = $(shell basename "$(REPO_ROOT)")

AQUA_VERSION ?= 2.46.0
AQUA_REPO ?= github.com/aquaproj/aqua
AQUA_CHECKSUM.Linux.x86_64 = 6908509aa0c985ea60ed4bfdc69a69f43059a6b539fb16111387e1a7a8d87a9f
AQUA_CHECKSUM ?= $(AQUA_CHECKSUM.$(uname_s).$(uname_m))
AQUA_URL = https://$(AQUA_REPO)/releases/download/v$(AQUA_VERSION)/aqua_$(kernel)_$(arch).tar.gz
AQUA_ROOT_DIR = .aqua

JEKYLL_SERVE_HOST ?= 127.0.0.1

# The help command prints targets in groups. Help documentation in the Makefile
# uses comments with double hash marks (##). Documentation is printed by the
# help target in the order in appears in the Makefile.
#
# Make targets can be documented with double hash marks as follows:
#
#	target-name: ## target documentation.
#
# Groups can be added with the following style:
#
#	## Group name

.PHONY: help
help: ## Print all Makefile targets (this message).
	@echo "$(REPO_NAME) Makefile"
	@echo "Usage: make [COMMAND]"
	@echo ""
	@grep --no-filename -E '^([/a-z.A-Z0-9_%-]+:.*?|)##' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = "(:.*?|)## ?"}; { \
			if (length($$1) > 0) { \
				printf "  \033[36m%-25s\033[0m %s\n", $$1, $$2; \
			} else { \
				if (length($$2) > 0) { \
					printf "%s\n", $$2; \
				} \
			} \
		}'

package-lock.json: package.json
	@npm install

node_modules/.installed: package-lock.json
	@npm ci
	@touch node_modules/.installed

.venv/bin/activate:
	@python -m venv .venv

.venv/.installed: .venv/bin/activate requirements.txt
	@./.venv/bin/pip install -r requirements.txt --require-hashes
	@touch .venv/.installed

.bin/aqua-$(AQUA_VERSION)/aqua:
	@set -euo pipefail; \
		mkdir -p .bin/aqua-$(AQUA_VERSION); \
		tempfile=$$(mktemp --suffix=".aqua-v$(AQUA_VERSION).tar.gz"); \
		curl -sSLo "$${tempfile}" "$(AQUA_URL)"; \
		echo "$(AQUA_CHECKSUM)  $${tempfile}" | sha256sum -c; \
		tar -x -C .bin/aqua-$(AQUA_VERSION) -f "$${tempfile}"

$(AQUA_ROOT_DIR)/.installed: aqua.yaml .bin/aqua-$(AQUA_VERSION)/aqua
	@AQUA_ROOT_DIR="$(AQUA_ROOT_DIR)" ./.bin/aqua-$(AQUA_VERSION)/aqua --config aqua.yaml install
	@touch $@

## Content
#####################################################################

.PHONY: til
til: ## Start a new TIL entry.
	@./til.sh

## Tools
#####################################################################

.PHONY: license-headers
license-headers: ## Update license headers.
	@set -euo pipefail; \
		files=$$( \
			git ls-files --deduplicate \
				'*.go' \
				'*.ts' \
				'*.js' \
				'*.scss' \
				'*.css' \
				'*.py' \
				'*.yaml' \
				'*.yml' \
				'Makefile' \
				':!:assets/demos' \
				':!:_sass/ext' \
				| while IFS='' read -r f; do [ -f "$${f}" ] && echo "$${f}"; done \
		); \
		name=$$(git config user.name); \
		if [ "$${name}" == "" ]; then \
			>&2 echo "git user.name is required."; \
			>&2 echo "Set it up using:"; \
			>&2 echo "git config user.name \"John Doe\""; \
		fi; \
		for filename in $${files}; do \
			if ! ( head "$${filename}" | grep -iL "Copyright" > /dev/null ); then \
				./third_party/mbrukman/autogen/autogen.sh -i --no-code --no-tlc -c "$${name}" -l apache "$${filename}"; \
			fi; \
		done; \
		if ! ( head Makefile | grep -iL "Copyright" > /dev/null ); then \
			third_party/mbrukman/autogen/autogen.sh -i --no-code --no-tlc -c "$${name}" -l apache Makefile; \
		fi;

## Formatting
#####################################################################

.PHONY: format
format: html-format javascript-format json-format md-format sass-format yaml-format ## Format all files

.PHONY: html-format
html-format: node_modules/.installed ## Format HTML files.
	@set -euo pipefail; \
		files=$$( \
			git ls-files --deduplicate \
				'*.html' \
				':!:assets/demos' \
		); \
		npx prettier --write --no-error-on-unmatched-pattern $${files}

.PHONY: javascript-format
javascript-format: node_modules/.installed ## Format Javascript files.
	@set -euo pipefail; \
		files=$$( \
			git ls-files --deduplicate \
				'*.js' \
				':!:*.min.js' \
				':!:assets/demos' \
		); \
		npx prettier --write --no-error-on-unmatched-pattern $${files}

.PHONY: json-format
json-format: node_modules/.installed ## Format JSON files.
	@set -euo pipefail; \
		files=$$( \
			git ls-files --deduplicate \
				'*.json' \
				'*.json5' \
				| while IFS='' read -r f; do [ -f "$${f}" ] && echo "$${f}"; done \
		); \
		npx prettier --write --no-error-on-unmatched-pattern $${files}

.PHONY: md-format
md-format: node_modules/.installed ## Format Markdown files.
	@set -euo pipefail; \
		files=$$( \
			git ls-files --deduplicate \
				'*.md' \
				| while IFS='' read -r f; do [ -f "$${f}" ] && echo "$${f}"; done \
		); \
		npx prettier --write --no-error-on-unmatched-pattern $${files}

.PHONY: sass-format
sass-format: node_modules/.installed ## Format SASS files.
	@set -euo pipefail; \
		files=$$( \
			git ls-files --deduplicate \
				'*.scss' \
				':!:assets/css/style.scss' \
				':!:_sass/ext' \
		); \
		npx prettier --write --no-error-on-unmatched-pattern $${files}

.PHONY: yaml-format
yaml-format: node_modules/.installed ## Format YAML files.
	@set -euo pipefail; \
		files=$$( \
			git ls-files --deduplicate \
				'*.yml' \
				'*.yaml' \
		); \
		npx prettier --write --no-error-on-unmatched-pattern $${files}

## Linting
#####################################################################

.PHONY: lint
lint: actionlint eslint markdownlint renovate-config-validator stylelint textlint yamllint zizmor ## Run all linters.

.PHONY: actionlint
actionlint: $(AQUA_ROOT_DIR)/.installed ## Runs the actionlint linter.
	@# NOTE: We need to ignore config files used in tests.
	@set -euo pipefail;\
		files=$$( \
			git ls-files --deduplicate \
				'.github/workflows/*.yml' \
				'.github/workflows/*.yaml' \
				| while IFS='' read -r f; do [ -f "$${f}" ] && echo "$${f}"; done \
		); \
		PATH="$(REPO_ROOT)/.bin/aqua-$(AQUA_VERSION):$(AQUA_ROOT_DIR)/bin:$${PATH}"; \
		AQUA_ROOT_DIR="$(AQUA_ROOT_DIR)"; \
		if [ "$(OUTPUT_FORMAT)" == "github" ]; then \
			actionlint -format '{{range $$err := .}}::error file={{$$err.Filepath}},line={{$$err.Line}},col={{$$err.Column}}::{{$$err.Message}}%0A```%0A{{replace $$err.Snippet "\\n" "%0A"}}%0A```\n{{end}}' -ignore 'SC2016:' $${files}; \
		else \
			actionlint $${files}; \
		fi

.PHONY: eslint
eslint: node_modules/.installed ## Runs eslint.
	@set -euo pipefail; \
		files=$$( \
			git ls-files \
				'*.js' \
				':!:*.min.js' \
				':!:assets/demos' \
		); \
		if [ "$(OUTPUT_FORMAT)" == "github" ]; then \
			set -euo pipefail; \
			exit_code=0; \
			while IFS="" read -r p && [ -n "$${p}" ]; do \
				file=$$(echo "$${p}" | jq -c '.filePath // empty' | tr -d '"'); \
				while IFS="" read -r m && [ -n "$${m}" ]; do \
					severity=$$(echo "$${m}" | jq -c '.severity // empty' | tr -d '"'); \
					line=$$(echo "$${m}" | jq -c '.line // empty' | tr -d '"'); \
					endline=$$(echo "$${m}" | jq -c '.endLine // empty' | tr -d '"'); \
					col=$$(echo "$${m}" | jq -c '.column // empty' | tr -d '"'); \
					endcol=$$(echo "$${m}" | jq -c '.endColumn // empty' | tr -d '"'); \
					message=$$(echo "$${m}" | jq -c '.message // empty' | tr -d '"'); \
					exit_code=1; \
					case $${severity} in \
					"1") \
						echo "::warning file=$${file},line=$${line},endLine=$${endline},col=$${col},endColumn=$${endcol}::$${message}"; \
						;; \
					"2") \
						echo "::error file=$${file},line=$${line},endLine=$${endline},col=$${col},endColumn=$${endcol}::$${message}"; \
						;; \
					esac; \
				done <<<$$(echo "$${p}" | jq -c '.messages[]'); \
			done <<<$$(npx eslint --max-warnings 0 -f json $${files} | jq -c '.[]'); \
			exit "$${exit_code}"; \
		else \
			npx eslint --max-warnings 0 $${files}; \
		fi

.PHONY: stylelint
stylelint: node_modules/.installed ## Runs the stylelint linter.
	@set -euo pipefail; \
		files=$$( \
			git ls-files --deduplicate \
				'*.scss' \
				':!:assets/css/style.scss' \
				':!:_sass/ext' \
		); \
		if [ "$(OUTPUT_FORMAT)" == "github" ]; then \
			npx stylelint --formatter github $${files}; \
		else \
			npx stylelint $${files}; \
		fi

.PHONY: zizmor
zizmor: .venv/.installed ## Runs the zizmor linter.
	@# NOTE: On GitHub actions this outputs SARIF format to zizmor.sarif.json
	@#       in addition to outputting errors to the terminal.
	@set -euo pipefail;\
		files=$$( \
			git ls-files --deduplicate \
				'.github/workflows/*.yml' \
				'.github/workflows/*.yaml' \
				| while IFS='' read -r f; do [ -f "$${f}" ] && echo "$${f}"; done \
		); \
		if [ "$(OUTPUT_FORMAT)" == "github" ]; then \
			.venv/bin/zizmor --quiet --pedantic --format sarif $${files} > zizmor.sarif.json || true; \
		fi; \
		.venv/bin/zizmor --quiet --pedantic --format plain $${files}

.PHONY: markdownlint
markdownlint: node_modules/.installed $(AQUA_ROOT_DIR)/.installed ## Runs the markdownlint linter.
	@# NOTE: Issue and PR templates are handled specially so we can disable
	@# MD041/first-line-heading/first-line-h1 without adding an ugly html comment
	@# at the top of the file.
	@set -euo pipefail;\
		files=$$( \
			git ls-files --deduplicate \
				'*.md' \
				':!:.github/pull_request_template.md' \
				':!:.github/ISSUE_TEMPLATE/*.md' \
				':!:projects.md' \
				':!:en/_posts/*.md' \
				':!:jp/_posts/*.md' \
				':!:til/_posts/*.md' \
				| while IFS='' read -r f; do [ -f "$${f}" ] && echo "$${f}"; done \
		); \
		PATH="$(REPO_ROOT)/.bin/aqua-$(AQUA_VERSION):$(AQUA_ROOT_DIR)/bin:$${PATH}"; \
		AQUA_ROOT_DIR="$(AQUA_ROOT_DIR)"; \
		if [ "$(OUTPUT_FORMAT)" == "github" ]; then \
			exit_code=0; \
			while IFS="" read -r p && [ -n "$$p" ]; do \
				file=$$(echo "$$p" | jq -c -r '.fileName // empty'); \
				line=$$(echo "$$p" | jq -c -r '.lineNumber // empty'); \
				endline=$${line}; \
				message=$$(echo "$$p" | jq -c -r '.ruleNames[0] + "/" + .ruleNames[1] + " " + .ruleDescription + " [Detail: \"" + .errorDetail + "\", Context: \"" + .errorContext + "\"]"'); \
				exit_code=1; \
				echo "::error file=$${file},line=$${line},endLine=$${endline}::$${message}"; \
			done <<< "$$(npx markdownlint --config .markdownlint.yaml --dot --json $${files} 2>&1 | jq -c '.[]')"; \
			if [ "$${exit_code}" != "0" ]; then \
				exit "$${exit_code}"; \
			fi; \
		else \
			npx markdownlint --config .markdownlint.yaml --dot $${files}; \
		fi; \
		files=$$( \
			git ls-files --deduplicate \
				'.github/pull_request_template.md' \
				'.github/ISSUE_TEMPLATE/*.md' \
				| while IFS='' read -r f; do [ -f "$${f}" ] && echo "$${f}"; done \
		); \
		if [ "$(OUTPUT_FORMAT)" == "github" ]; then \
			exit_code=0; \
			while IFS="" read -r p && [ -n "$$p" ]; do \
				file=$$(echo "$$p" | jq -c -r '.fileName // empty'); \
				line=$$(echo "$$p" | jq -c -r '.lineNumber // empty'); \
				endline=$${line}; \
				message=$$(echo "$$p" | jq -c -r '.ruleNames[0] + "/" + .ruleNames[1] + " " + .ruleDescription + " [Detail: \"" + .errorDetail + "\", Context: \"" + .errorContext + "\"]"'); \
				exit_code=1; \
				echo "::error file=$${file},line=$${line},endLine=$${endline}::$${message}"; \
			done <<< "$$(npx markdownlint --config .github/template.markdownlint.yaml --dot --json $${files} 2>&1 | jq -c '.[]')"; \
			if [ "$${exit_code}" != "0" ]; then \
				exit "$${exit_code}"; \
			fi; \
		else \
			npx markdownlint  --config .github/template.markdownlint.yaml --dot $${files}; \
		fi; \
		files=$$( \
			git ls-files --deduplicate \
				'projects.md' \
				'en/_posts/*.md' \
				'jp/_posts/*.md' \
				'til/_posts/*.md' \
				| while IFS='' read -r f; do [ -f "$${f}" ] && echo "$${f}"; done \
		); \
		if [ "$(OUTPUT_FORMAT)" == "github" ]; then \
			exit_code=0; \
			while IFS="" read -r p && [ -n "$$p" ]; do \
				file=$$(echo "$$p" | jq -c -r '.fileName // empty'); \
				line=$$(echo "$$p" | jq -c -r '.lineNumber // empty'); \
				endline=$${line}; \
				message=$$(echo "$$p" | jq -c -r '.ruleNames[0] + "/" + .ruleNames[1] + " " + .ruleDescription + " [Detail: \"" + .errorDetail + "\", Context: \"" + .errorContext + "\"]"'); \
				exit_code=1; \
				echo "::error file=$${file},line=$${line},endLine=$${endline}::$${message}"; \
			done <<< "$$(npx markdownlint --config .posts.markdownlint.yaml --dot --json $${files} 2>&1 | jq -c '.[]')"; \
			if [ "$${exit_code}" != "0" ]; then \
				exit "$${exit_code}"; \
			fi; \
		else \
			npx markdownlint  --config .posts.markdownlint.yaml --dot $${files}; \
		fi

.PHONY: renovate-config-validator
renovate-config-validator: node_modules/.installed ## Validate Renovate configuration.
	@./node_modules/.bin/renovate-config-validator --strict

.PHONY: textlint
textlint: node_modules/.installed $(AQUA_ROOT_DIR)/.installed ## Runs the textlint linter.
	@set -e;\
		files=$$( \
			git ls-files --deduplicate \
				'*.md' \
				'*.txt' \
				| while IFS='' read -r f; do [ -f "$${f}" ] && echo "$${f}"; done \
		); \
		if [ "$(OUTPUT_FORMAT)" == "github" ]; then \
			exit_code=0; \
			while IFS="" read -r p && [ -n "$$p" ]; do \
				filePath=$$(echo "$$p" | jq -c -r '.filePath // empty'); \
				file=$$(realpath --relative-to="." "$${filePath}"); \
				while IFS="" read -r m && [ -n "$$m" ]; do \
					line=$$(echo "$$m" | jq -c -r '.loc.start.line'); \
					endline=$$(echo "$$m" | jq -c -r '.loc.end.line'); \
					message=$$(echo "$$m" | jq -c -r '.message'); \
					echo "::error file=$${file},line=$${line},endLine=$${endline}::$${message}"; \
				done <<<"$$(echo "$$p" | jq -c -r '.messages[] // empty')"; \
			done <<< "$$(./node_modules/.bin/textlint -c .textlintrc.json --format json $${files} 2>&1 | jq -c '.[]')"; \
			exit "$${exit_code}"; \
		else \
			./node_modules/.bin/textlint -c .textlintrc.json $${files}; \
		fi

.PHONY: yamllint
yamllint: .venv/.installed ## Runs the yamllint linter.
	@set -euo pipefail;\
		extraargs=""; \
		files=$$( \
			git ls-files --deduplicate \
				'*.yml' \
				'*.yaml' \
				| while IFS='' read -r f; do [ -f "$${f}" ] && echo "$${f}"; done \
		); \
		if [ "$(OUTPUT_FORMAT)" == "github" ]; then \
			extraargs="-f github"; \
		fi; \
		.venv/bin/yamllint --strict -c .yamllint.yaml $${extraargs} $${files}

## Maintenance
#####################################################################

.PHONY: build
build: ## Build the site with Jekyll
	@bundle exec jekyll build

.PHONY: serve
serve: ## Run Jekyll test server.
	@bundle exec jekyll serve --future --drafts -H $(JEKYLL_SERVE_HOST)

.PHONY: clean
clean: ## Delete temporary files.
	@rm -rf \
		.bin \
		$(AQUA_ROOT_DIR) \
		.venv \
		node_modules \
		*.sarif.json \
		_site
