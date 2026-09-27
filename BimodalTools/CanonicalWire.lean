/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import BimodalTools.CanonicalWire.Json

/-!
# CanonicalWire - the verified certificate wire codec

Aggregator for `BimodalTools/CanonicalWire/`: the canonical printer, the total parser, and the
theorems that say the two compose to the identity. The point of the directory is that
deserialization leaves the certificate trust base — a defect in the parser would mean the
verified side certifies a different certificate than the one the producing repository exported,
and no rigor downstream of the parse could detect it.

## The two layers

1. **A generic canonical JSON value** (`Json.lean`, `Parse.lean`, `RoundTrip.lean`, `Fuel.lean`):
   a compact printer, a fuel-indexed **total** parser, and one lexical round-trip theorem proved
   once.
2. **The certificate schema** (`Cert.lean`): an `encode`/`decode` pair over that value, whose own
   round trip is pure structural induction over `RawCertificate` and mentions no parser state.

## Building

```bash
lake build BimodalTools
```
-/
