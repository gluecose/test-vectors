.DEFAULT_GOAL := all

SCHEMA := gluecose-schema.cddl

TESTS := $(wildcard sign1*.json)

EXTRA := misc/gocose-result-sign1-verify-0000.json

include tools.mk

.PHONY: tests
tests: ; for f in $(TESTS) ; do $(cddl) $(SCHEMA) v $$f ; done

.PHONY: extra
extra: ; for f in $(EXTRA) ; do $(cddl) $(SCHEMA) v $$f ; done

.PHONY: spell
spell: ; $(mdspell) --en-us README.md

all: tests extra spell
