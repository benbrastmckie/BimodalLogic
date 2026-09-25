/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import BimodalTools.CertificateImport

/-!
# Witness-Family Certificate Import: acceptance rows

The acceptance criteria for `lake exe check_certificate`, as `#guard` rows against
`BimodalTools/CertificateImport.lean` rather than as a manual smoke run. The executable root
`BimodalTools/CheckCertificateMain.lean` is deliberately **not** imported: it declares a
root-namespace `main`, and two of those cannot share one environment.

## What the rows cover

1. The label lists below really are the example family's labels — `rawBack.toFinset = labBack`
   and its two siblings, so nothing downstream is checking a different object than
   `WitnessFamilyExamples` proved things about. The imported family's lassos are then literally
   `[posLasso]` and `[sepLasso]`.
2. The non-vacuity family, serialized to JSON and read back, is accepted.
3. The separation family is rejected, naming fulfilment at lasso `0`, position `-2`, formula
   `p U q` — the same tuple the research spike's scan produced.
4. A label outside `closureOf (Γ ++ Δ)` is a **structural rejection**, not a parse error.
5. `pFormula ∘ Formula.toJson` is the identity on the closure members, and
   `parseCertificate ∘ RawCertificate.toJson` is the identity on a whole certificate. Base atoms
   only: `Formula.toJson` drops `Atom.freshIndex`, which is why `mkFamily` rejects a
   fresh-indexed atom outright rather than letting it change identity silently.
-/

namespace BimodalToolsTest.CertificateImport

open FormalSystem.Syntax
open FormalSystem.Metalogic.Decidability
open FormalSystem.Metalogic.Decidability.WitnessFamilyExamples
open BimodalTools.JsonParse
open BimodalTools.CertificateImport

/-! ## The example families, as wire data -/

/-- `labBack` as a list, in the order the Finset literal lists it. -/
def rawBack : List Formula :=
  [Formula.top, pForm.neg, fP, Formula.or fP pP, pP.neg, occurs, occurs.box, once, once.box,
    phiPos]

/-- `labMid` as a list. -/
def rawMid : List Formula :=
  [pForm, Formula.top, fP.neg, pP.neg, occurs, occurs.box, once, once.box, phiPos]

/-- `labFwd` as a list. -/
def rawFwd : List Formula :=
  [Formula.top, pForm.neg, pP, fP.neg, Formula.or fP pP, occurs, occurs.box, once, once.box,
    phiPos]

#guard rawBack.toFinset = labBack
#guard rawMid.toFinset = labMid
#guard rawFwd.toFinset = labFwd

/-- The non-vacuity family as a certificate. The box guess is the two boxed closure members
`posFamily.bx` reports `true` at; everything unlisted reads `false`. -/
def posRaw : RawCertificate where
  premises := gammaPos
  conclusions := delPos
  bx := [(occurs, true), (once, true)]
  lassos := [{ back := [rawBack], mid := [rawMid], fwd := [rawFwd] }]

/-- The separation family as a certificate: one constant label, no `mid`, `q` labelled nowhere. -/
def sepRaw : RawCertificate where
  premises := gammaSep
  conclusions := delSep
  lassos := [{ back := [[pForm, phiSep]], mid := [], fwd := [[pForm, phiSep]] }]

/-- The separation family with `⊥` — outside `closureOf (gammaSep ++ delSep)` — in its back
label. A structural violation, not a malformed document. -/
def outsideRaw : RawCertificate :=
  { sepRaw with lassos := [{ back := [[Formula.bot]], mid := [], fwd := [[pForm, phiSep]] }] }

/-! ## The decoded families are the example families

Not "a family with the same verdict": the same object, field for field. `LabelledLasso` derives
`DecidableEq`, so this is checkable rather than asserted.
-/

#guard (mkFamily posRaw).toOption.map (fun W : WitnessFamily gammaPos delPos => W.lassos) =
  some [posLasso]

#guard (mkFamily sepRaw).toOption.map (fun W : WitnessFamily gammaSep delSep => W.lassos) =
  some [sepLasso]

/-! ## Row (a): the non-vacuity family is accepted

Through the wire format, not around it: serialize, parse, rebuild, decide.
-/

#guard checkLine posRaw.toJson = CheckResult.countermodel 0

#guard checkRaw posRaw = CheckResult.countermodel 0

/-! ## Row (b): the separation family is rejected, naming the obligation

The tuple is `(lasso 0, position -2, p U q)` — fulfilment, at the left end of the scan window,
on the eventuality the family carries forever and never discharges.
-/

/-- The single failure the separation family is expected to produce. -/
def sepExpected : Failure :=
  { condition := "fulfilling", lasso := some 0, position := some (-2), formula := some phiSep,
    detail := "this eventuality is never discharged" }

#guard checkLine sepRaw.toJson = CheckResult.rejected [sepExpected]

#guard checkRaw sepRaw = CheckResult.rejected [sepExpected]

/-! ## Row (c): a label outside the closure is a structural rejection -/

/-- The structural failure a label outside the closure is expected to produce. -/
def outsideExpected : Failure :=
  { condition := "structural", lasso := some 0,
    detail := "a label is not a subset of the closure of the premises and conclusions" }

#guard checkLine outsideRaw.toJson = CheckResult.rejected [outsideExpected]

-- Malformed input is a protocol `error`, never a verdict.
#guard match checkLine "{ nonsense" with
  | CheckResult.error _ => true
  | _ => false

/-! ## Row (d): the wire format round-trips -/

-- `pFormula ∘ Formula.toJson = id` on every member of the positive family's closure.
#guard (closureList gammaPos).all fun φ =>
  match pFormula (mkPState φ.toJson) with
  | .ok (ψ, _) => ψ == φ
  | .error _ => false

-- The same, on the separation family's closure.
#guard (closureList gammaSep).all fun φ =>
  match pFormula (mkPState φ.toJson) with
  | .ok (ψ, _) => ψ == φ
  | .error _ => false

-- A whole certificate round-trips, field for field.
#guard parseCertificate posRaw.toJson = .ok posRaw

#guard parseCertificate sepRaw.toJson = .ok sepRaw

-- `"time"` is optional on the wire and defaults to `0`.
#guard (parseCertificate "{\"premises\":[],\"conclusions\":[],\"bx\":[],\"lassos\":[]}").map
  RawCertificate.time = .ok 0

-- A negative `"time"` survives the wire: `pNat` reads unsigned digits, `pInt` the sign.
#guard (parseCertificate "{\"premises\":[],\"conclusions\":[],\"lassos\":[],\"time\":-7}").map
  RawCertificate.time = .ok (-7)

-- An unknown field is skipped rather than rejected, so a producer may attach metadata.
#guard (parseCertificate "{\"note\":{\"a\":[1,2]},\"premises\":[],\"lassos\":[]}").map
  RawCertificate.lassos = .ok []

-- A fresh-indexed atom is rejected by name, because `Formula.toJson` would drop the index.
-- `Except _ (WitnessFamily ..)` carries no `DecidableEq` (the box guess is a function), so the
-- row matches on the constructor rather than comparing the two `Except` values.
#guard match mkFamily { sepRaw with premises := [Formula.atom ⟨"p", some 3⟩] } with
  | .error StructuralFault.atomNotBase => true
  | _ => false

-- An empty lasso list is a structural rejection, not a parse error.
#guard checkRaw { sepRaw with lassos := [] } =
  CheckResult.rejected [{ condition := "structural", detail := "the family has no lassos" }]

end BimodalToolsTest.CertificateImport
