.DEFAULT_GOAL := all

SCHEMA := gluecose-schema.cddl

TESTS := sign1-verify-0000.json
TESTS += sign1-sign-0000.json

EXTRA := misc/gocose-result-sign1-verify-0000.json

.PHONY: tests
tests: ; for f in $(TESTS) ; do $(cddl) $(SCHEMA) v $t ; done

.PHONY: extra
extra: ; for f in $(EXTRA) ; do $(cddl) $(SCHEMA) v $t ; done

.PHONY: spell
spell: ; $(mdspell) --en-us README.md

all: tests extra spell

include tools.mk