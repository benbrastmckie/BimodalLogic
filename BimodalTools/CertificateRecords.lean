/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Syntax

/-!
# Witness-Family Certificate Records

The parsed certificate records, field for field, split out of
`BimodalTools/CertificateImport.lean` so that the verified wire codec can sit **below** the
envelope in the import graph rather than above it.

## Why the split exists

`BimodalTools/CanonicalWire/Cert.lean` defines the schema codec — `encodeCert` / `decodeCert`
and the theorems that they invert each other — and it has to mention `RawCertificate`. The
envelope module `CertificateImport.lean` in turn has to mention the codec, because its
`parseCertificate` and `RawCertificate.toJson` are thin wrappers over it. Those two facts are
only compatible if the records live in a module both can import, which is this one.

The namespace is deliberately **unchanged**: everything below declares into
`BimodalTools.CertificateImport`, exactly as it did before the move, so every reference to these
names — including the fully-qualified external ones in `BimodalTools/CheckCertificateMain.lean` —
resolves as it did. This module is a relocation and nothing else: no rename, no signature change,
no change to any doc comment or `deriving` clause.

## Main Definitions

- `RawLasso`, `RawTarget`, `RawCertificate` — the parsed JSON records
- `PartialTarget`, `PartialCertificate`, and the two `complete` functions — the parse-time
  mirrors where every field is optional, and the required-field check
- `hasFreshAtom`, `RawCertificate.formulas` — the atom-shape scan and the formula inventory

## References

* `BimodalTools/CertificateImport.lean` — the envelope, the builders and the verdict
* `BimodalTools/CanonicalWire/Cert.lean` — the verified codec over these records
* `FormalSystem/Metalogic/Decidability/WitnessFamily/Basic.lean` — the structures these mirror,
  and the note that their field names are an export contract
-/

set_option autoImplicit false

namespace BimodalTools.CertificateImport

open FormalSystem.Syntax

/-!
## The parsed records

Field names mirror the Lean structures exactly, which `WitnessFamily/Basic.lean` states is an
export contract rather than a local naming choice.
-/

/-- One lasso, as it arrives: three segments, each a list of label sets, each label set a list
of formula ASTs. -/
structure RawLasso where
  /-- Labels for the leftward cycle. -/
  back : List (List Formula) := []
  /-- Labels for the finite window. -/
  mid : List (List Formula) := []
  /-- Labels for the rightward cycle. -/
  fwd : List (List Formula) := []
  deriving Repr, Inhabited, DecidableEq

/-- The target condition, as it arrives: the three data of `WitnessFamily.Target` in one
object, grouped as they are grouped in Lean. -/
structure RawTarget where
  /-- The premise context `Γ`. -/
  premises : List Formula := []
  /-- The conclusion context `Δ`. -/
  conclusions : List Formula := []
  /-- The target time: the witness of `Target`'s existential. Required on the wire. -/
  time : Int
  deriving Repr, Inhabited, DecidableEq

/-- A whole certificate, as it arrives. -/
structure RawCertificate where
  /-- The target condition. Required on the wire, because its `time` is. -/
  target : RawTarget
  /-- The box guess, as `(formula, bool)` pairs; anything absent reads as `false`. -/
  bx : List (Formula × Bool) := []
  /-- The lassos; lasso `0` is the main one, where the target is read. -/
  lassos : List RawLasso := []
  deriving Repr, Inhabited, DecidableEq

/-!
## The parse-time partial records

`pObjectFields` folds a handler over an accumulator seeded with `{}`, which is ill-formed once a
field loses its default. Parsing therefore lands in these partial mirrors, where every field is
optional, and `complete` turns a partial record into a real one through `Except String` — so a
missing required field reaches `checkLine`'s existing `.error` path and renders
`{"status":"error",...}` rather than a verdict.
-/

/-- `RawTarget` before the required-field check. -/
structure PartialTarget where
  /-- The premise context `Γ`. -/
  premises : List Formula := []
  /-- The conclusion context `Δ`. -/
  conclusions : List Formula := []
  /-- The target time, absent until the `"time"` key is seen. -/
  time : Option Int := none
  deriving Repr, Inhabited, DecidableEq

/-- `RawCertificate` before the required-field check. -/
structure PartialCertificate where
  /-- The target condition, absent until the `"target"` key is seen. -/
  target : Option PartialTarget := none
  /-- The box guess, as `(formula, bool)` pairs. -/
  bx : List (Formula × Bool) := []
  /-- The lassos. -/
  lassos : List RawLasso := []
  deriving Repr, Inhabited, DecidableEq

/-- Check the target's one required field. -/
def PartialTarget.complete (p : PartialTarget) : Except String RawTarget :=
  match p.time with
  | none => .error "certificate field \"target\" is missing its required field \"time\""
  | some t => .ok { premises := p.premises, conclusions := p.conclusions, time := t }

/-- Check the certificate's one required field, then its target's. The two messages are
deliberately distinct: a producer that omitted the whole `"target"` object and one that omitted
only its `"time"` have made different mistakes. -/
def PartialCertificate.complete (p : PartialCertificate) : Except String RawCertificate :=
  match p.target with
  | none => .error "certificate is missing its required field \"target\""
  | some pt => pt.complete.map fun tgt => { target := tgt, bx := p.bx, lassos := p.lassos }

/-!
## Atom shape

`pFormula` can only ever build base atoms, so this is vacuous on parsed input by construction.
It is not vacuous on a `RawCertificate` assembled in Lean, which is how the tests and any future
in-process producer reach `checkRaw`.
-/

/-- Does this formula carry an atom with a fresh index, which `Formula.toJson` would drop? -/
def hasFreshAtom : Formula → Bool
  | .atom a => a.freshIndex.isSome
  | .bot => false
  | .imp a b => hasFreshAtom a || hasFreshAtom b
  | .box χ => hasFreshAtom χ
  | .untl g e => hasFreshAtom g || hasFreshAtom e
  | .snce g e => hasFreshAtom g || hasFreshAtom e

/-- Every formula a certificate mentions, in one list. -/
def RawCertificate.formulas (c : RawCertificate) : List Formula :=
  c.target.premises ++ c.target.conclusions ++ c.bx.map Prod.fst ++
    c.lassos.flatMap (fun Λ => (Λ.back ++ Λ.mid ++ Λ.fwd).flatten)

end BimodalTools.CertificateImport
