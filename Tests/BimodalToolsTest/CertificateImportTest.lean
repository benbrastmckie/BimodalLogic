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
2. The non-vacuity family, serialized to JSON and read back, is accepted — as
   `CheckResult.countermodel 0 .entailment`, with the exact accepting JSON line pinned beside it.
3. The separation family is rejected, naming fulfilment at lasso `0`, position `-2`, formula
   `p U q` — the same tuple the research spike's scan produced.
4. A label outside `closureOf (Γ ++ Δ)` is a **structural rejection**, not a parse error.
5. `decodeFormula ∘ encodeFormula` is the identity on the closure members, and
   `parseCertificate ∘ RawCertificate.toJson` is the identity on a whole certificate. Base atoms
   only: `Formula.toJson` drops `Atom.freshIndex`, which is why `mkFamily` rejects a
   fresh-indexed atom outright rather than letting it change identity silently.
-/

namespace BimodalToolsTest.CertificateImport

open FormalSystem.Syntax
open FormalSystem.Metalogic.Decidability
open FormalSystem.Metalogic.Decidability.WitnessFamilyExamples
open BimodalTools.CanonicalWire
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
  target := { premises := gammaPos, conclusions := delPos, time := 0 }
  bx := [(occurs, true), (once, true)]
  lassos := [{ back := [rawBack], mid := [rawMid], fwd := [rawFwd] }]

/-- The separation family as a certificate: one constant label, no `mid`, `q` labelled nowhere. -/
def sepRaw : RawCertificate where
  target := { premises := gammaSep, conclusions := delSep, time := 0 }
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

#guard checkLine posRaw.toJson = CheckResult.countermodel 0 .entailment

#guard checkRaw posRaw = CheckResult.countermodel 0 .entailment

-- The exact accepting line, byte for byte. `"acceptance"` is additive and appears on
-- `countermodel` only; an absent field reads as `"decided"`, which is what keeps stored verdicts
-- and older binaries valid. See `BimodalTools/README.md`'s protocol section.
/-- The exact accepting JSON line, split across two literals only to stay inside the 100-column
limit. -/
def posAcceptedLine : String :=
  "{\"status\":\"countermodel\",\"time\":0," ++
    "\"acceptance\":\"entailment\"}"

#guard (checkRaw posRaw).toJson = posAcceptedLine

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

-- `decodeFormula ∘ encodeFormula = id` on every member of the positive family's closure. These two
-- rows were retargeted from `pFormula ∘ Formula.toJson` when the envelope moved to the verified
-- codec: `Formula.toJson` is no longer on the certificate's path, and the closure of `pFormula`
-- with it is no longer what any certificate round trip runs through.
#guard (closureList gammaPos).all fun φ =>
  match decodeFormula (encodeFormula φ) with
  | .ok ψ => ψ == φ
  | .error _ => false

-- The same, on the separation family's closure.
#guard (closureList gammaSep).all fun φ =>
  match decodeFormula (encodeFormula φ) with
  | .ok ψ => ψ == φ
  | .error _ => false

-- A whole certificate round-trips, field for field.
#guard parseCertificate posRaw.toJson = .ok posRaw

#guard parseCertificate sepRaw.toJson = .ok sepRaw

/-- A wire line whose `"target"` object omits the required `"time"`. -/
def noTimeLine : String :=
  "{\"target\":{\"premises\":[],\"conclusions\":[]},\"lassos\":[]}"

/-- A wire line that omits the required `"target"` object entirely. -/
def noTargetLine : String := "{\"bx\":[],\"lassos\":[]}"

-- `"time"` is REQUIRED on the wire: a `"target"` without it is a protocol error, and the
-- rendered line says `error`, not `rejected`. (This row is the inverse of an earlier one that
-- asserted the same input read as `time = 0`; that contract no longer holds.)
#guard (checkLineToJson noTimeLine).startsWith "{\"status\":\"error\""

-- An absent `"target"` is likewise an error, not a rejection.
#guard (checkLineToJson noTargetLine).startsWith "{\"status\":\"error\""

-- The two messages differ: omitting the whole object and omitting only its time are different
-- producer mistakes.
#guard checkLineToJson noTimeLine != checkLineToJson noTargetLine

-- A negative `"time"` survives the wire: the canonical integer codec carries the sign, and
-- `parseInt_printInt` proves the round trip.
#guard (parseCertificate
    "{\"target\":{\"premises\":[],\"conclusions\":[],\"time\":-7},\"lassos\":[]}").map
  (fun c => c.target.time) = .ok (-7)

-- An unknown field is skipped rather than rejected, so a producer may attach metadata — at
-- both nesting levels, which is new surface the `"target"` object creates.
#guard (parseCertificate
    "{\"note\":{\"a\":[1,2]},\"target\":{\"origin\":\"mc\",\"time\":3},\"lassos\":[]}").map
  (fun c => (c.lassos, c.target.time)) = .ok ([], 3)

-- A fresh-indexed atom is rejected by name, because `Formula.toJson` would drop the index.
-- `Except _ (WitnessFamily ..)` carries no `DecidableEq` (the box guess is a function), so the
-- row matches on the constructor rather than comparing the two `Except` values.
#guard match mkFamily
    { sepRaw with target := { sepRaw.target with premises := [Formula.atom ⟨"p", some 3⟩] } } with
  | .error StructuralFault.atomNotBase => true
  | _ => false

-- An empty lasso list is a structural rejection, not a parse error.
#guard checkRaw { sepRaw with lassos := [] } =
  CheckResult.rejected [{ condition := "structural", detail := "the family has no lassos" }]

end BimodalToolsTest.CertificateImport
