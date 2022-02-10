# SPDX-License-Identifier: MIT

# This Makefile is not really a build tool. It provides shortcuts to run certain
# tasks while developing the application and serves as a convenient way to
# launch different tools with sane default settings.
#
# Actually, some of "make"'s capabilities is used to make sure that the
# tox environments, which are used to run most of the commands, are rebuild, if
# environment specifc configuration or requirements have changed.
#
# The Makefile is self-documenting, using code from here:
# https://gist.github.com/klmr/575726c7e05d8780505a#gistcomment-3586983
# The actual implementation is right at the bottom of this file and should be
# left untouched.

# ### INTERNAL SETTINGS / CONSTANTS
TOX_WORK_DIR := .tox
TOX_UTIL_ENV := $(TOX_WORK_DIR)/util

UTIL_REQUIREMENTS := requirements/coverage.txt requirements/util.txt

# some make settings
.SILENT :
.DELETE_ON_ERROR :
.DEFAULT_GOAL := help
MAKEFLAGS += --no-print-directory
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules


# ### utility targets

## Run bandit on all files (*.py)
## @category Code Quality
util/bandit :
	$(MAKE) util/pre-commit pre-commit_id="bandit" pre-commit_files="--all-files"
.PHONY : util/bandit

## Run black on all files (*.py)
## @category Code Quality
util/black :
	$(MAKE) util/pre-commit pre-commit_id="black" pre-commit_files="--all-files"
.PHONY : util/black

## Run djlint on all files (*.html)
## @category Code Quality
util/djlint :
	$(MAKE) util/pre-commit pre-commit_id="djlint-django" pre-commit_files="--all-files"
.PHONY : util/djlint

## Run doc8 on all files (*.rst)
## @category Code Quality
util/doc8 :
	$(MAKE) util/pre-commit pre-commit_id="doc8" pre-commit_files="--all-files"
.PHONY : util/doc8

## Run flake8 on all files (*.py)
## @category Code Quality
util/flake8 :
	$(MAKE) util/pre-commit pre-commit_id="flake8" pre-commit_files="--all-files"
.PHONY : util/flake8

## Run isort on all files (*.py)
## @category Code Quality
util/isort :
	$(MAKE) util/pre-commit pre-commit_id="isort" pre-commit_files="--all-files"
.PHONY : util/isort

pre-commit_id ?= ""
pre-commit_files ?= ""
## Run all code quality tools as defined in .pre-commit-config.yaml
## @category Code Quality
util/pre-commit : $(TOX_UTIL_ENV)
	tox -q -e util -- pre-commit run $(pre-commit_files) $(pre-commit_id)
.PHONY : util/pre-commit

## Install pre-commit hooks to be executed automatically
## @category Code Quality
util/pre-commit/install : $(TOX_UTIL_ENV)
	tox -q -e util -- pre-commit install
.PHONY : util/pre-commit/install

## Update pre-commit hooks
## @category Code Quality
util/pre-commit/update : $(TOX_UTIL_ENV)
	tox -q -e util -- pre-commit autoupdate
.PHONY : util/pre-commit/update


# ### INTERNAL RECIPES
$(TOX_UTIL_ENV) : $(UTIL_REQUIREMENTS) pyproject.toml .pre-commit-config.yaml
	tox --recreate -e util


# fancy colors
RULE_COLOR := "$$(tput setaf 6)"
VARIABLE_COLOR = "$$(tput setaf 2)"
VALUE_COLOR = "$$(tput setaf 1)"
CLEAR_STYLE := "$$(tput sgr0)"
TARGET_STYLED_HELP_NAME = "$(RULE_COLOR)TARGET$(CLEAR_STYLE)"
ARGUMENTS_HELP_NAME = "$(VARIABLE_COLOR)ARGUMENT$(CLEAR_STYLE)=$(VALUE_COLOR)VALUE$(CLEAR_STYLE)"

# search regex
target_regex = [a-zA-Z0-9%_\/%-]+
variable_regex = [^:=\s ]+
variable_assignment_regex = \s*:?[+:!\?]?=\s*
value_regex = .*
category_annotation_regex = @category\s+
category_regex = [^<]+

# tags used to delimit each parts
target_tag_start = "\<target-definition\>"
target_tag_end = "\<\\\/target-definition\>"
target_variable_tag_start = "\<target-variable\>"
target_variable_tag_end = "\<\\\/target-variable\>"
variable_tag_start = "\<variable\>"
variable_tag_end = "\<\\\/variable\>"
global_variable_tag_start = "\<global-variable\>"
global_variable_tag_end = "\<\\\/global-variable\>"
value_tag_start = "\<value\>"
value_tag_end = "\<\\\/value\>"
prerequisites_tag_start = "\<prerequisites\>"
prerequisites_tag_end = "\<\\\/prerequisites\>"
doc_tag_start = "\<doc\>"
doc_tag_end = "\<\\\/doc\>"
category_tag_start = "\<category-other\>"
category_tag_end = "\<\\\/category-other\>"
default_category_tag_start = "\<category-default\>"
default_category_tag_end = "\<\\\/category-default\>"

DEFAULT_CATEGORY = Targets and Arguments

## Show this help
help:
	@echo "Usage: make [$(TARGET_STYLED_HELP_NAME) [$(TARGET_STYLED_HELP_NAME) ...]] [$(ARGUMENTS_HELP_NAME) [$(ARGUMENTS_HELP_NAME) ...]]"
	@sed -n -e "/^## / { \
		h; \
		s/.*/##/; \
		:doc" \
		-E -e "H; \
		n; \
		s/^##\s*(.*)/$(doc_tag_start)\1$(doc_tag_end)/; \
		t doc" \
		-e "s/\s*#[^#].*//; " \
		-E -e "s/^(define\s*)?($(variable_regex))$(variable_assignment_regex)($(value_regex))/$(global_variable_tag_start)\2$(global_variable_tag_end)$(value_tag_start)\3$(value_tag_end)/;" \
		-E -e "s/^($(target_regex))\s*:?:\s*(($(variable_regex))$(variable_assignment_regex)($(value_regex)))/$(target_variable_tag_start)\1$(target_variable_tag_end)$(variable_tag_start)\3$(variable_tag_end)$(value_tag_start)\4$(value_tag_end)/;" \
		-E -e "s/^($(target_regex))\s*:?:\s*($(target_regex)(\s*$(target_regex))*)?/$(target_tag_start)\1$(target_tag_end)$(prerequisites_tag_start)\2$(prerequisites_tag_end)/;" \
		-E -e " \
		G; \
		s/##\s*(.*)\s*##/$(doc_tag_start)\1$(doc_tag_end)/; \
		s/\\n//g;" \
		-E -e "/$(category_annotation_regex)/!s/.*/$(default_category_tag_start)$(DEFAULT_CATEGORY)$(default_category_tag_end)&/" \
		-E -e "s/^(.*)$(doc_tag_start)$(category_annotation_regex)($(category_regex))$(doc_tag_end)/$(category_tag_start)\2$(category_tag_end)\1/" \
		-e "p; \
	}"  ${MAKEFILE_LIST} \
	| sort  \
	| sed -n \
		-e "s/$(default_category_tag_start)/$(category_tag_start)/" \
		-e "s/$(default_category_tag_end)/$(category_tag_end)/" \
		-E -e "{G; s/($(category_tag_start)$(category_regex)$(category_tag_end))(.*)\n\1/\2/; s/\n.*//; H; }" \
		-e "s/$(category_tag_start)//" \
		-e "s/$(category_tag_end)/:\n/" \
		-e "s/$(target_variable_tag_start)/$(target_tag_start)/" \
		-e "s/$(target_variable_tag_end)/$(target_tag_end)/" \
		-e "s/$(target_tag_start)/    $(RULE_COLOR)/" \
		-e "s/$(target_tag_end)/$(CLEAR_STYLE) /" \
		-e "s/$(prerequisites_tag_start)$(prerequisites_tag_end)//" \
		-e "s/$(prerequisites_tag_start)/[/" \
		-e "s/$(prerequisites_tag_end)/]/" \
		-E -e "s/$(variable_tag_start)/$(VARIABLE_COLOR)/g" \
		-E -e "s/$(variable_tag_end)/$(CLEAR_STYLE)/" \
		-E -e "s/$(global_variable_tag_start)/    $(VARIABLE_COLOR)/g" \
		-E -e "s/$(global_variable_tag_end)/$(CLEAR_STYLE)/" \
		-e "s/$(value_tag_start)/ (default: $(VALUE_COLOR)/" \
		-e "s/$(value_tag_end)/$(CLEAR_STYLE))/" \
		-e "s/$(doc_tag_start)/\n        /g" \
		-e "s/$(doc_tag_end)//g" \
		-e "p"
.PHONY : help
