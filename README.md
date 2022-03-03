# GlueCOSE Validation Suite

**Caution: this is a work in progress in its very early stage.**

This is a repository of GlueCOSE test cases.  Eventually, this will morph in to
the GlueCOSE validation suite.

Here's a first stab at the [CDDL schema](gluecose-schema.cddl) for specifying
test cases as well as their results.

And here's the first test case for a [successful Sign1](sign1-0000.json) that
has been [validated](misc/gocose-result-sign1-0000.json) using the go-cose
implementation.

Implementation note: use `/dev/zero` as PRNG in order to make the randomised
test deterministic.
