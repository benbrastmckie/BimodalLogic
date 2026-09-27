# CanonicalWire

The verified wire codec for witness-family certificates: a canonical printer, a total parser,
and the theorems that say the two compose to the identity.

The point of this directory is that deserialization leaves the certificate trust base. The
verified side parses exported JSON to rebuild the witness family it then decides conditions on,
so a defect in that parser means the verified side certifies a *different* certificate than the
one the producing repository exported — and no amount of rigor downstream of the parse detects
it. The parser here is a total `def` with a proved fuel bound, not a `partial def`, so it has
equation lemmas and theorems about it are possible in principle.

## The two layers

1. **A generic canonical JSON value.** `Json.lean` carries the value, the canonical printer and
   the fuel measure; `Parse.lean` the total parser; `RoundTrip.lean` the lexical lemmas and the
   one generic round-trip theorem; `Fuel.lean` the proof that the seeded fuel always suffices.
2. **The certificate schema.** `Cert.lean` carries `encodeCert` / `decodeCert` and the five
   theorems that state the export contract as mathematics rather than as prose. Its proofs are
   structural induction over `RawCertificate` and mention no parser state.

The split is what keeps the work finite: the lexical reasoning is done once, generically, and
the schema layer only applies it.

## Modules

| File | Lines | Description |
|------|-------|-------------|
| `Json.lean` | 265 | The canonical value `CJson`/`CJsonList`/`CJsonObj`, the `Canonical` well-formedness predicate, the escape and decimal codecs' printing halves, the canonical printer, and the fuel measure |

## The canonical form

- Compact: no whitespace is emitted anywhere, so one value has one byte string.
- Fields in encode order: `CJsonObj` is an ordered association list and key order is part of the
  canonical form.
- One escape per character: `"` and `\` as themselves, `\b \f \n \r \t` where JSON names them,
  `\u00XX` (lowercase hex) for every other character below `0x20`, and everything from `0x20` up
  passed through as UTF-8.
- `\uXXXX` outside the control range is **rejected**, not decoded. The joint canonical contract
  therefore pins `ensure_ascii=False` on the producing side; see `../README.md`.
- Integers only: no fraction, no exponent, no leading zero, no `+`, no `-0`.

## Related Documentation

- [Parent README](../README.md) — the certificate protocol and the joint canonical contract
- [CertificateImport](../CertificateImport.lean) — the envelope that consumes this codec

*Last verified: 2026-09-27*
