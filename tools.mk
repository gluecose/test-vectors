# cddl and curl are prerequisite
# fail hard if they are not found

cddl ?= $(shell command -v cddl)
ifeq ($(strip $(cddl)),)
$(error cddl not found. To install cddl: 'gem install cddl')
endif

mdspell ?= $(shell command -v mdspell)
ifeq ($(strip $(mdspell)),)
$(error mdspell not found. To install mdspell: 'npm i markdown-spellcheck -g')
endif

