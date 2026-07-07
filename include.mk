# Copyright 2026 Ian Lewis
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

# include.mk sets up the environment for the Makefile. It is included at the top
# of the Makefile. It sets up the shell, flags, and other variables that are
# used throughout the Makefile. This file can be included in other Makefiles
# (e.g. in subdirectories) to provide a consistent environment.

# Print a warning if undefined variables are used in the Makefile.
MAKEFLAGS += --warn-undefined-variables
# Disable built-in rules to avoid conflicts with custom rules.
MAKEFLAGS += --no-builtin-rules

# Set the initial shell so we can determine extra options.
SHELL := bash
# TODO(https://github.com/checkmake/checkmake/issues/263): use := assignment
# NOTE: We use recursive assignment to avoid triggering a bug in checkmake.
.SHELLFLAGS = -ueo pipefail -c

GITHUB_ACTIONS ?=

DEBUG_LOGGING ?=
ifeq ($(DEBUG_LOGGING),)
  ifeq ($(GITHUB_ACTIONS),true)
    ifneq ($(RUNNER_DEBUG),)
      DEBUG_LOGGING := true
    else
      ifeq ($(ACTIONS_RUNNER_DEBUG),true)
        DEBUG_LOGGING := true
      else
        ifeq ($(ACTIONS_STEP_DEBUG),true)
          DEBUG_LOGGING := true
        endif
      endif
    endif
  endif
endif

ifeq ($(DEBUG_LOGGING),true)
  .SHELLFLAGS := -x $(.SHELLFLAGS)
endif

# .ONESHELL executes all commands in a recipe in a single shell instance. This
# allows us to use shell variables and functions across multiple lines in a
# recipe.
.ONESHELL:

# .DELETE_ON_ERROR deletes the recipe target files if the recipe fails. This
# makes sure that re-running the recipe will not use a partially created target
# file.
.DELETE_ON_ERROR:

uname_s := $(shell uname -s)
uname_m := $(shell uname -m)
arch.x86_64 := amd64
arch.aarch64 := arm64
arch.arm64 := arm64
arch := $(arch.$(uname_m))
kernel.Linux := linux
kernel.Darwin := darwin
kernel := $(kernel.$(uname_s))

OUTPUT_FORMAT ?= $(shell if [ "$(GITHUB_ACTIONS)" == "true" ]; then echo "github"; else echo ""; fi)
MAKEFILE_ROOT := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
ROOT_NAME := $(shell basename "$(MAKEFILE_ROOT)")

# We want GNU versions of tools so prefer them if present.
GREP := $(shell command -v ggrep 2>/dev/null || command -v grep 2>/dev/null)
AWK := $(shell command -v gawk 2>/dev/null || command -v awk 2>/dev/null)
MKTEMP := $(shell command -v gmktemp 2>/dev/null || command -v mktemp 2>/dev/null)

# The help command prints targets in groups. Help documentation in the Makefile
# uses comments with double hash marks (##). Documentation is printed by the
# help target in the order it appears in the Makefile.
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
	@echo "$(ROOT_NAME) Makefile"
	echo "Usage: $(MAKE) [COMMAND]"
	echo ""
	normal="";
	cyan=""
	if command -v tput >/dev/null 2>&1; then
		if [ -t 1 ]; then
			normal=$$(tput sgr0)
			cyan=$$(tput setaf 6)
		fi
	fi
	$(GREP) --no-filename -E '^([/a-z.A-Z0-9_%-]+:.*?|)##' $(MAKEFILE_LIST) | \
		$(AWK) \
			--assign=normal="$${normal}" \
			--assign=cyan="$${cyan}" \
			'BEGIN {FS = "(:.*?|)## ?"}; {
				if (length($$1) > 0) {
					printf("  " cyan "%-25s" normal " %s\n", $$1, $$2)
				} else {
					if (length($$2) > 0) {
						printf("%s\n", $$2)
					}
				}
			}'
