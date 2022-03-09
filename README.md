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

* If the `detachedPayload` key is present, load it and Base16 decode it into a
  byte buffer.  This is to be used when constructing the COSE `Sig_Structure` in
  lieu of the `nil` payload in the `taggedCOSESign1`.

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

The assumption is that the sign API exposed by the implementation under test
will use the fields in the `Sign1_sign` object to construct its input.  However,
we assume that implementations will vary the way in which they consume the test
case input data: for example, one could assemble all parameters in one single
object before passing it to the sign interface, another could supply each piece
separately, etc.  Therefore, here we will only describe the semantics of the
`Sign1_sign` object fields and let each implementation deal with the details of
deriving their input parameter(s).  An implementation will then need to go
through the steps specified in [Section 4.4 of
RFC9052](https://www.rfc-editor.org/authors/rfc9052.html#section-4.4) to produce
the signature and the resulting COSE_Sign1 object.

* The `payload` key is a Base16 encoded string corresponding to the payload to
  be signed.  If the `detached` key is `true`, the resulting COSE_Sign1 will
  have a `nil` payload.  Otherwise (`detached` key missing or `true`), the
  resulting COSE_Sign1 has it as its value.

* If present, the `protectedHeaders` key contains the protected headers as a
  serialised CBOR map Base16 encoded.

* If present, the `unprotectedHeaders` key contains the unprotected headers as a
  serialised CBOR map Base16 encoded.

* If present, the `external` key contains the base16 encoded string with any
  externally supplied data.

* The `tbsHex` key is a Base16 encoded string corresponding to the resulting
  COSE `Sig_Structure` canonically serialised as per [Section 9 of
  RFC9052](https://www.rfc-editor.org/authors/rfc9052.html#section-9).  This is
  an intermediated value that is normally invisible to the API caller, therefore
  it is not expected to be used directly by the test driver.  It serves as an
  aid for the developer.

* The `expectedOutput` key contains a Base16 encoded string corresponding to the
  tagged (18) CBOR encoded COSE_Sign1 message.

#### Full-blown

It is expected that the output of the sign API is compared to the full value
contained in the `cborHex` field of the `expectedOutput`.  If the two values
match, set `Result` to `"pass"` in the `TestCaseOutput` payload for this test
case.  Otherwise set `"fail"`.

#### Partial

It is expected that the output of the sign API and the value contained in the
`cborHex` field of the `expectedOutput` are compared up the the 3rd entry of the
COSE_Sign1 array, i.e., excluding the 4th (signature) field.  If the two values
match, set `Result` to `"pass"` in the `TestCaseOutput` payload for this test
case.  Otherwise set `"fail"`.
