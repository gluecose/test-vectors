# GlueCOSE Validation Suite

**Caution: this is a work in progress in its very early stages.**

This is a repository of GlueCOSE test cases.  Eventually, this will morph in to
the GlueCOSE validation suite.

Here's a first stab at the [CDDL schema](gluecose-schema.cddl) for specifying
test cases as well as their results.

And here's the first test case for a [Sign1 verify](sign1-verify-0000.json) that
has been [validated](misc/gocose-result-sign1-verify-0000.json) using the
go-cose implementation.

## Sign1 Tests

Signing and verification test cases depend on the key material and signature
scheme specified in the corresponding `TestCaseInput`.

All tests shall:

* Load and decode the [JWK](https://www.rfc-editor.org/info/rfc7517) contained
  in the `key` object

* Set the signature scheme to the algorithm specified in the `alg` string.  The
  label is the same as the corresponding *Name* in the [COSE Algorithms
  Registry](https://www.iana.org/assignments/cose/cose.xhtml#algorithms).

### Verify

This section describes how the GlueCOSE test writer consumes a `Sign1_verify`
object to create the test driver for verifying COSE Sign1 payloads.

All the keys in the remainder of this section are relative to the
`Sign1_verify` object associated with the `"sign1::verify"` key.

* The `cborHex` string in the `taggedCOSESign1` object contains the
  [Base16](https://www.rfc-editor.org/info/rfc4648) encoding of the tagged (18)
  COSE_Sign1 data that needs to be verified.  Load it and Base16 decode it into
  a byte buffer.  (Note that a CBOR diagnostic version of the same exact content
  is optionally provided in the `cborDiag` string within the same `input`.  This
  is only intended for human consumption and has no bearing on the test logics.)

* If the `external` key is present, load it and Base16 decode it into a byte
  buffer.  This represents what COSE calls "Externally Supplied Data".

* Call the verify API exposed by your implementation passing the key, the
  signature scheme, the tagged COSE_Sign1 data, and the optional externally
  supplied data.

* Check that the result is compatible with the boolean carried in the
  `shouldVerify` key.  If so, set `Result` to `"pass"` in the `TestCaseOutput`
  payload for this test case.  Otherwise set `"fail"`.

### Sign

This section describes how the GlueCOSE test writer consumes a `Sign1_sign`
object to create the test driver for signing data into COSE Sign1 payloads.

All the keys in the remainder of this section are relative to the
`Sign1_sign` object associated with the `"sign1::sign"` key.

There are two types of platforms / implementations considered here:

1. Those that expose an interface to the PRNG
1. Those that don't

The first type MUST use a "zero reader" (e.g., `/dev/zero` on UNIX-like OSes) as
PRNG to make the randomised tests deterministic, and shall implement the
[full-blown](#full-blown) version of the test.

For the second type, an [alternative](#partial) to the full-blown test is
specified.

#### Full-blown

See [Section 4.4 of
RFC9052](https://www.rfc-editor.org/authors/rfc9052.html#section-4.4)

#### Partial

See [Section 4.4 of
RFC9052](https://www.rfc-editor.org/authors/rfc9052.html#section-4.4) up to
ToBeSigned