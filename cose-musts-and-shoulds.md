# Conformance notes

MUSTs and SHOULDs from the COSE RFC.

## Protected Header encoding

* protected: Contains parameters about the current layer that are cryptographically protected. This bucket MUST be empty if it is not going to be included in a cryptographic computation. This bucket is encoded in the message as a binary object. This value is obtained by CBOR encoding the protected map and wrapping it in a bstr object.
  * Senders SHOULD encode a zero-length map as a zero-length byte string rather than as a zero-length map (encoded as h'a0'). The zero-length byte string encoding is preferred, because it is both shorter and the version used in the serialization structures for cryptographic computation.
  * Recipients MUST accept both a zero-length byte string and a zero-length map encoded in a byte string.

### Negative conditions

* [:white_check_mark:](sign1-verify-negative-0000.json) outer type is not bstr => rejected by receiver
* [:white_check_mark:](sign1-verify-negative-0001.json) outer type is non-empty bstr but inner type is not map => rejected by receiver
* [ ] outer type is non-empty bstr and inner type is empty map => accepted by receiver even if it's not the preferred encoding

## Map labels

* Labels in each of the maps MUST be unique.
  * When processing messages, if a label appears multiple times, the message MUST be rejected as malformed.
  * Applications SHOULD verify that the same label does not occur in both the protected and unprotected header parameters.
    * If the message is not rejected as malformed, attributes MUST be obtained from the protected bucket, and only if an attribute is not found in the protected bucket are attributes obtained from the unprotected bucket.

### Negative conditions

* [:white_check_mark:](sign1-verify-negative-0002.json) protected header map contains duplicate keys => rejected by receiver
* [:white_check_mark:](sign1-verify-negative-0003.json) unprotected header map contains duplicate keys => rejected by receiver
* label (e.g., alg) occurs in both protected and unprotected with different values => maybe rejected.  if not, value from protected takes precedence (e.g., protected contains the right alg and signature verifies).  Note that the case of "maybe fail" cannot be expressed in the current glucose schema which only allows a boolean choice (`shouldVerify`)

## `alg`

* This header parameter MUST be authenticated where the ability to do so exists.  This support is provided by AEAD algorithms or construction (e.g., COSE_Sign and COSE_Mac0). This authentication can be done either by placing the header parameter in the protected-header-parameters bucket or as part of the externally supplied data.

### Negative conditions

Assuming no out-of-band channel exists:
* [:white_check_mark:](sign1-verify-negative-0004.json) Sign1 message without alg in protected headers => rejected by receiver
*  Sign message without alg in protected headers => rejected by receiver
* [:white_check_mark:](sign1-verify-negative-0005.json) Sign message with alg only in unprotected headers => rejected by receiver
* Sign1 message with alg only in unprotected headers => rejected by receiver

## `crit`

* This header parameter is used to indicate which protected header parameters an application that is processing a message is required to understand. Header parameters defined in this document do not need to be included, as they should be understood by all implementations. When present, the "crit" header parameter MUST be placed in the protected-header-parameters bucket. The array MUST have at least one value in it.

### Negative conditions

n/a

## `content type`

* Applications SHOULD provide this header parameter if the content structure is potentially ambiguous.

### Negative conditions

n/a

## `kid`

* Applications MUST NOT assume that "kid" values are unique. […] This is not a security-critical field. For this reason, it can be placed in the unprotected-header-parameters bucket.

### Negative conditions

n/a

## IV and Partial IV

* The "Initialization Vector" and "Partial Initialization Vector" header parameters MUST NOT both be present in the same security layer.

### Negative conditions

n/a

## Detached payload

* If the payload is transported separately ("detached content"), then a nil CBOR object is placed in this location, and it is the responsibility of the application to ensure that it will be transported without changes.
* Note that when signature w/ message recovery are employed if the algorithm can recover the whole message, then payload is h'' instead of 'nil' 
  * When a signature with a message recovery algorithm is used (Section 8.1), the maximum number of bytes that can be recovered is the length of the original payload. The size of the encoded payload is reduced by the number of bytes that will be recovered. If all of the bytes of the original payload are consumed, then the transmitted payload is encoded as a zero-length byte string rather than as being absent.

### Negative conditions

n/a

## Encoding restrictions for Sig_structure, the Enc_structure, and the MAC_structure

* Encoding MUST be done using definite lengths
  * the length of the (encoded) argument MUST be the minimum possible length. This means that the integer 1 is encoded as "0x01" and not "0x1801".
* Applications MUST NOT generate messages with the same label used twice as a key in a single map.
  * Applications MUST NOT parse and process messages with the same label used twice as a key in a single map.
    * Applications can enforce the parse-and-process requirement by using parsers that will fail the parse step or by using parsers that will pass all keys to the application, and the application can perform the check for duplicate keys.

### Negative conditions

* [:white_check_mark:](sign1-verify-negative-0002.json) map with duplicate entries (1) => rejected by receiver
* [:white_check_mark:](sign1-verify-negative-0003.json) map with duplicate entries (2) => rejected by receiver
