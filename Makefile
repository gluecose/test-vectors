all: check spell

SCHEMA := gluecose-schema.cddl
TESTS := $(wildcard sign1*.json)
EXTRA := misc/gocose-result-sign1-verify-0000.json
DOCS := README.md

include tools.mk

check::

# $(1): check targets infix (e.g., "x" creates targets "check-x-schema"
#       and "check-x-files")
# $(2): reference CDDL schema
# $(3): files to be checked against the reference schema
define check_validity

.PHONY: check-$(1)-schema
check-$(1)-schema: $(2)
	@echo "><> validating schema: $$<" ; \
	$$(cddl) $$< g 1 &>/dev/null

.PHONY: check-$(1)-files
check-$(1)-files: $(2) $(3)
	@for f in $(3) ; do \
		echo "><> validating file: $$$$f against $$< schema" ; \
		$$(cddl) $$< v $$$$f &>/dev/null || exit 1 ; \
	done

check:: check-$(1)-schema check-$(1)-files

endef

$(eval $(call check_validity,test,$(SCHEMA),$(TESTS)))
$(eval $(call check_validity,extra,$(SCHEMA),$(EXTRA)))

.PHONY: spell
spell: $(DOCS) ; @$(mdspell) --en-us $^

help:
	@echo
	@echo "Available targets:"
	@echo "  check              - run all validations"
	@echo "  check-test-schema  - validate the test vectors schema"
	@echo "  check-test-files   - validate tests against the schema"
	@echo "  check-extra-files  - validate any extra files against the schema"
	@echo "  spell              - check documentation for spelling errors"
	@echo
