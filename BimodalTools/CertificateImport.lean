/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.WitnessFamily
import BimodalTools.JsonParse
import BimodalTools.DataExport

/-!
# Witness-Family Certificate Import

Decoding, re-verification and serialization for the witness-family certificates the model
checker emits. This is the library half of `lake exe check_certificate`; the executable root
`BimodalTools/CheckCertificateMain.lean` reads stdin and prints, and everything else is here so
it can be tested from `Tests/BimodalToolsTest/`.

## The trust model

Acceptance means the four compiled `Decidable` instances that
`WitnessFamily.joint_countermodel` consumes — `decidableLocalCoherentLab`,
`decidableFulfillingLab`, `decidableBoxFaithful` and `decidableTarget` — all returned `true` on
the family this module rebuilt from the JSON. It is **not** a kernel-checked proof for that
particular certificate, and `rejected` is **never** a validity claim: it says only that the
object handed over is not a certificate.

## Runtime construction

`LabelledLasso` and `WitnessFamily` carry proof fields (`back_ne`, `fwd_ne`, `label_sub`,
`lassos_ne`), all of them decidable propositions over computable data. `mkLasso` and `mkFamily`
discharge each one with a `dite`, so a certificate that fails a structural precondition comes
back as a named rejection rather than as a parse error.

## Why `closureList` rather than `Finset.toList`

`Finset.toList` is noncomputable, so the diagnostic scans cannot enumerate `closureOf` directly.
`closureList` is the computable enumeration of the same members, and `mem_closureList` is the
one-line membership lemma that ties the two together.

## Atom identity

`Formula.toJson` emits an atom's base name and drops `Atom.freshIndex`, and `pFormula` reads it
back as `Atom.mkBase`. A certificate therefore round-trips exactly on base atoms only.
`hasFreshAtom` detects the exception; `checkRaw` rejects on it rather than letting a
`Finset Formula` membership silently change identity.

## Main Definitions

- `closureList`, `intRange` — computable enumerations the scans need
- `RawLasso`, `RawCertificate` — the parsed JSON records, field for field
- `parseCertificate`, `RawCertificate.toJson` — the two directions of the wire format
- `mkLasso`, `mkFamily` — the runtime builders, `dite` on every proof field
- `CheckResult`, `checkRaw` — the verdict and its JSON line

## Main Results

- `mem_closureList` — `closureList` enumerates exactly `closureOf`

## References

* `FormalSystem/Metalogic/Decidability/WitnessFamily/Basic.lean` — the structures, and the note
  that their field names are an export contract
* `FormalSystem/Metalogic/Decidability/WitnessFamily/Decide.lean` — the four instances and the
  per-unit predicates the localization scans reuse
* `BimodalTools/JsonParse.lean` — the tag-format formula parser
* `BimodalTools/README.md` — the wire schema, beside the tableau bridge protocol
-/

set_option autoImplicit false

namespace BimodalTools.CertificateImport

open FormalSystem.Syntax
open FormalSystem.Metalogic.Decidability
open BimodalTools.JsonParse
open BimodalTools.DataExport

/-!
## Computable enumerations

`Finset.toList` is noncomputable, so every scan below enumerates through these two instead.
-/

/-- The closure of a context, as a duplicate-free list. Computable, unlike `Finset.toList`. -/
def closureList (S : Context) : List Formula :=
  (S.flatMap FormalSystem.Syntax.Formula.subformulas).dedup

/-- `closureList` enumerates exactly the members of `closureOf`. -/
theorem mem_closureList {S : Context} {ψ : Formula} :
    ψ ∈ closureList S ↔ ψ ∈ closureOf S := by
  simp [closureList, mem_closureOf, FormalSystem.Syntax.subformulaClosure]

/-- The half-open integer range `[a, b)`, as a list. The scan windows are `Finset.Ico` at `ℤ`. -/
def intRange (a b : Int) : List Int := (List.range (b - a).toNat).map (fun k => a + (k : Int))

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
## The envelope parser

`JsonParse` supplies the formula reader and the scalar primitives; these are the certificate's
own array, object and signed-integer readers on top of them.
-/

/-- Match a bare keyword at the current position, consuming it on success. -/
def pKeyword (kw : String) (st : PState) : Option PState :=
  let n := kw.length
  let seen := String.ofList ((List.range n).filterMap (fun i => st.chars[st.pos + i]?))
  if seen == kw then some { st with pos := st.pos + n } else none

/-- Parse a JSON boolean. -/
def pBool (st : PState) : Except String (Bool × PState) :=
  let st := pSkipWS st
  match pKeyword "true" st with
  | some st => .ok (true, st)
  | none =>
    match pKeyword "false" st with
    | some st => .ok (false, st)
    | none => .error s!"expected boolean at pos {st.pos}"

/-- Parse a signed JSON integer. `pNat` reads unsigned digits only, and positions go negative. -/
def pInt (st : PState) : Except String (Int × PState) := do
  let st := pSkipWS st
  match pPeek st with
  | some '-' =>
    let (n, st) ← pNat (pAdvance st)
    return (-(n : Int), st)
  | _ =>
    let (n, st) ← pNat st
    return ((n : Int), st)

/-- Parse a JSON array whose elements are read by `p`. -/
partial def pArrayOf {α : Type} (p : PState → Except String (α × PState))
    (st : PState) : Except String (List α × PState) := do
  let st ← pExpect '[' st
  let stw := pSkipWS st
  match pPeek stw with
  | some ']' => return ([], pAdvance stw)
  | _ =>
    let mut acc : List α := []
    let mut st := st
    while true do
      let (x, st') ← p st
      acc := x :: acc
      let st' := pSkipWS st'
      match pPeek st' with
      | some ',' => st := pAdvance st'
      | some ']' => return (acc.reverse, pAdvance st')
      | _ => throw s!"expected , or ] in array at pos {st'.pos}"
    throw "unreachable"

/-- Parse a JSON object, folding each recognised field into `acc` through `handler`. Unknown
fields are skipped, so a producer may attach metadata this checker does not read. -/
partial def pObjectFields {α : Type}
    (handler : String → α → PState → Except String (α × PState))
    (init : α) (st : PState) : Except String (α × PState) := do
  let st ← pExpect '{' st
  let stw := pSkipWS st
  match pPeek stw with
  | some '}' => return (init, pAdvance stw)
  | _ =>
    let mut acc := init
    let mut st := st
    while true do
      let (key, st') ← pString st
      let st' := pSkipWS st'
      let st' ← pExpect ':' st'
      let (acc', st') ← handler key acc st'
      acc := acc'
      let st' := pSkipWS st'
      match pPeek st' with
      | some ',' => st := pAdvance st'
      | some '}' => return (acc, pAdvance st')
      | _ => throw s!"expected , or }} at pos {st'.pos}"
    throw "unreachable"

/-- Parse one label set: an array of formula ASTs. -/
def pLabel : PState → Except String (List Formula × PState) := pArrayOf pFormula

/-- Parse one segment: an array of label sets. -/
def pSegment : PState → Except String (List (List Formula) × PState) := pArrayOf pLabel

/-- Parse one box-guess entry: the two-element array `[formula, bool]`. -/
def pBxPair (st : PState) : Except String ((Formula × Bool) × PState) := do
  let st ← pExpect '[' st
  let (φ, st) ← pFormula st
  let st ← pExpect ',' st
  let (b, st) ← pBool st
  let st ← pExpect ']' st
  return ((φ, b), st)

/-- Parse one lasso object. -/
def pRawLasso : PState → Except String (RawLasso × PState) :=
  pObjectFields (fun key acc st => do
    if key == "back" then
      let (v, st) ← pSegment st
      return ({ acc with back := v }, st)
    else if key == "mid" then
      let (v, st) ← pSegment st
      return ({ acc with mid := v }, st)
    else if key == "fwd" then
      let (v, st) ← pSegment st
      return ({ acc with fwd := v }, st)
    else
      let st ← pSkipValue st
      return (acc, st)) {}

/-- Parse the `"target"` object. An absent `"time"` leaves `none`, which `complete` reports. -/
def pRawTarget : PState → Except String (PartialTarget × PState) :=
  pObjectFields (fun key acc st => do
    if key == "premises" then
      let (v, st) ← pArrayOf pFormula st
      return ({ acc with premises := v }, st)
    else if key == "conclusions" then
      let (v, st) ← pArrayOf pFormula st
      return ({ acc with conclusions := v }, st)
    else if key == "time" then
      let (v, st) ← pInt st
      return ({ acc with time := some v }, st)
    else
      let st ← pSkipValue st
      return (acc, st)) {}

/-- Parse the certificate envelope. Unknown fields are skipped at both nesting levels. -/
def pRawCertificate : PState → Except String (PartialCertificate × PState) :=
  pObjectFields (fun key acc st => do
    if key == "target" then
      let (v, st) ← pRawTarget st
      return ({ acc with target := some v }, st)
    else if key == "bx" then
      let (v, st) ← pArrayOf pBxPair st
      return ({ acc with bx := v }, st)
    else if key == "lassos" then
      let (v, st) ← pArrayOf pRawLasso st
      return ({ acc with lassos := v }, st)
    else
      let st ← pSkipValue st
      return (acc, st)) {}

/-- Parse a whole certificate from one JSON line, checking its required fields. -/
def parseCertificate (s : String) : Except String RawCertificate := do
  let (c, _) ← pRawCertificate (mkPState s)
  c.complete

/-!
## Serialization, the inverse direction

The wire format is pinned executably rather than only in prose: `parseCertificate` composed with
`RawCertificate.toJson` is the identity on base-atom certificates, and
`Tests/BimodalToolsTest/CertificateImportTest.lean` checks that as a `#guard`.
-/

/-- Wrap a list of already-serialized items as a JSON array. -/
def jsonArray (items : List String) : String := "[" ++ String.intercalate "," items ++ "]"

/-- Serialize a label set. -/
def labelToJson (X : List Formula) : String := jsonArray (X.map Formula.toJson)

/-- Serialize a segment. -/
def segmentToJson (seg : List (List Formula)) : String := jsonArray (seg.map labelToJson)

/-- Serialize one lasso. -/
def RawLasso.toJson (Λ : RawLasso) : String :=
  "{\"back\":" ++ segmentToJson Λ.back ++
  ",\"mid\":" ++ segmentToJson Λ.mid ++
  ",\"fwd\":" ++ segmentToJson Λ.fwd ++ "}"

/-- Serialize one box-guess entry. -/
def bxPairToJson (p : Formula × Bool) : String :=
  "[" ++ p.1.toJson ++ "," ++ (if p.2 then "true" else "false") ++ "]"

/-- Serialize the target condition. -/
def RawTarget.toJson (tgt : RawTarget) : String :=
  "{\"premises\":" ++ jsonArray (tgt.premises.map Formula.toJson) ++
  ",\"conclusions\":" ++ jsonArray (tgt.conclusions.map Formula.toJson) ++
  ",\"time\":" ++ toString tgt.time ++ "}"

/-- Serialize a whole certificate. -/
def RawCertificate.toJson (c : RawCertificate) : String :=
  "{\"target\":" ++ RawTarget.toJson c.target ++
  ",\"bx\":" ++ jsonArray (c.bx.map bxPairToJson) ++
  ",\"lassos\":" ++ jsonArray (c.lassos.map RawLasso.toJson) ++ "}"

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

/-!
## The runtime builders

Each structure field is discharged by a `dite` on its own `Decidable` instance, so a structural
violation is reported by name instead of aborting the decode.
-/

/-- Why one lasso could not be built. -/
inductive LassoFault where
  /-- `back` is empty, so leftward decoding would not be periodic. -/
  | backEmpty
  /-- `fwd` is empty, so rightward decoding would not be periodic. -/
  | fwdEmpty
  /-- Some listed label is not a subset of `closureOf (Γ ++ Δ)`. -/
  | labelOutsideClosure
  deriving Repr, DecidableEq

/-- Why the certificate could not be rebuilt as a `WitnessFamily`. -/
inductive StructuralFault where
  /-- The lasso at this index failed a structural precondition. -/
  | lasso (idx : Nat) (fault : LassoFault)
  /-- The family has no lassos, so the presented carrier would be empty. -/
  | lassosEmpty
  /-- Some formula carries a fresh-indexed atom, which does not survive the wire format. -/
  | atomNotBase
  deriving Repr, DecidableEq

/-- The box guess as a function, from the pairs on the wire. Anything unlisted reads `false`. -/
def bxOf (pairs : List (Formula × Bool)) : Formula → Bool :=
  fun φ => (pairs.find? (·.1 == φ)).map Prod.snd |>.getD false

/-- Rebuild one labelled lasso, or name the structural precondition it violates. -/
def mkLasso (C : Finset Formula) (raw : RawLasso) : Except LassoFault (LabelledLasso C) :=
  let back := raw.back.map List.toFinset
  let mid := raw.mid.map List.toFinset
  let fwd := raw.fwd.map List.toFinset
  if hb : back = [] then .error .backEmpty
  else if hf : fwd = [] then .error .fwdEmpty
  else if hs : ∀ X ∈ back ++ mid ++ fwd, X ⊆ C then
    .ok { back := back, mid := mid, fwd := fwd, back_ne := hb, fwd_ne := hf, label_sub := hs }
  else .error .labelOutsideClosure

/-- Rebuild the whole family, or name the structural precondition it violates. -/
def mkFamily (raw : RawCertificate) :
    Except StructuralFault (WitnessFamily raw.target.premises raw.target.conclusions) := do
  if raw.formulas.any hasFreshAtom then .error .atomNotBase
  else
    let lassos ← raw.lassos.zipIdx.mapM fun p =>
      match mkLasso (closureOf (raw.target.premises ++ raw.target.conclusions)) p.1 with
      | .ok Λ => .ok Λ
      | .error f => .error (.lasso p.2 f)
    if hl : lassos = [] then .error .lassosEmpty
    else return { bx := bxOf raw.bx, lassos := lassos, lassos_ne := hl }

/-!
## The verdict, and where a rejection happened

The verdict is the four top-level `Decidable` instances and nothing else, evaluated in order and
short-circuiting on the first `false`. The scans below run only to localize a rejection: each one
ranges over exactly the units its instance decides — `CoherentAt` over
`[labCohWindowLo, labCohWindowHi)`, `eventClauseAt` over `[labFulWindowLo, labFulWindowHi)`,
`boxClause` over the closure, `Target` at the single target time — so a scan cannot disagree with
the verdict it is explaining. When an instance says `false` and its scan finds nothing, the
`"unlocalized"` record is emitted rather than an empty `failed` list.
-/

/-- One failed condition, localized as far as the scan could take it. -/
structure Failure where
  /-- Which condition failed: `structural`, `local_coherent`, `fulfilling`, `box_faithful`,
  `target`, or `unlocalized`. -/
  condition : String
  /-- The lasso index, when the failure is tied to one. -/
  lasso : Option Nat := none
  /-- The position, when the failure is tied to one. -/
  position : Option Int := none
  /-- The closure member whose clause failed, when the scan found one. -/
  formula : Option Formula := none
  /-- A short human-readable note. -/
  detail : String := ""
  deriving Repr, Inhabited, DecidableEq

/-- The checker's answer. Note the absence of any "valid" constructor: this checker is one-sided
by construction and never makes a validity claim. -/
inductive CheckResult where
  /-- Every condition decided `true` at the given target time. -/
  | countermodel (time : Int)
  /-- Some condition decided `false`, or a structural precondition was violated. -/
  | rejected (failed : List Failure)
  /-- The input was not a well-formed certificate object. A protocol failure, not a verdict. -/
  | error (message : String)
  deriving Repr, Inhabited, DecidableEq

section Scans

variable {Γ Del : Context}

/-- The first position at which local coherence fails, with the offending closure member. -/
def cohFailure (W : WitnessFamily Γ Del) : Option Failure :=
  (List.finRange W.lassos.length).findSome? fun i =>
    let Λ := W.lassos.get i
    (intRange (LabelledLasso.labCohWindowLo Λ) (LabelledLasso.labCohWindowHi Λ)).findSome? fun t =>
      if LabelledLasso.CoherentAt W.bx Λ t then none
      else if Formula.bot ∈ Λ.lab t then
        some { condition := "local_coherent", lasso := some i.val, position := some t,
               formula := some Formula.bot, detail := "⊥ is labelled at this position" }
      else
        let bad := (closureList (Γ ++ Del)).find? fun ψ =>
          ! decide (LabelledLasso.labClauseAt W.bx (Λ.lab (t - 1)) (Λ.lab t) (Λ.lab (t + 1)) ψ)
        some { condition := "local_coherent", lasso := some i.val, position := some t,
               formula := bad, detail := "the local clause of this closure member fails here" }

/-- The first position at which an eventuality is left undischarged. -/
def fulFailure (W : WitnessFamily Γ Del) : Option Failure :=
  (List.finRange W.lassos.length).findSome? fun i =>
    let Λ := W.lassos.get i
    (intRange (LabelledLasso.labFulWindowLo Λ) (LabelledLasso.labFulWindowHi Λ)).findSome? fun t =>
      match (closureList (Γ ++ Del)).find? fun ψ =>
          ! decide (LabelledLasso.eventClauseAt Λ t ψ) with
      | some ψ =>
        some { condition := "fulfilling", lasso := some i.val, position := some t,
               formula := some ψ, detail := "this eventuality is never discharged" }
      | none => none

/-- The first closure member whose box clause fails, with a counter-position when one exists. -/
def boxFailure (W : WitnessFamily Γ Del) : Option Failure :=
  (closureList (Γ ++ Del)).findSome? fun ψ =>
    if W.boxClause ψ then none
    else
      match ψ with
      | .box χ =>
        let counter := (List.finRange W.lassos.length).findSome? fun i =>
          let Λ := W.lassos.get i
          (intRange (-Λ.nb) (Λ.nm + Λ.nf)).findSome? fun t =>
            if χ ∈ W.L i t then none else some (i.val, t)
        some { condition := "box_faithful", lasso := counter.map Prod.fst,
               position := counter.map Prod.snd, formula := some ψ,
               detail := "the box guess disagrees with global label membership" }
      | _ => none

/-- The first premise missing from, or conclusion present in, the main label at the target. -/
def targetFailure (W : WitnessFamily Γ Del) (t : Int) : Option Failure :=
  match Γ.find? (fun γ => ! decide (γ ∈ W.main t)) with
  | some γ =>
    some { condition := "target", lasso := some 0, position := some t, formula := some γ,
           detail := "this premise is not labelled at the target position" }
  | none =>
    match Del.find? (fun σ => decide (σ ∈ W.main t)) with
    | some σ =>
      some { condition := "target", lasso := some 0, position := some t, formula := some σ,
             detail := "this conclusion is labelled at the target position" }
    | none => none

end Scans

/-- The `failed` entry for an instance that returned `false` whose scan found nothing. -/
def unlocalized (condition : String) : Failure :=
  { condition := "unlocalized",
    detail := s!"the {condition} instance decided false, but the scan localized no failure" }

/-- Render a structural fault as a `failed` entry. -/
def StructuralFault.toFailure : StructuralFault → Failure
  | .lasso idx .backEmpty =>
    { condition := "structural", lasso := some idx, detail := "back segment is empty" }
  | .lasso idx .fwdEmpty =>
    { condition := "structural", lasso := some idx, detail := "fwd segment is empty" }
  | .lasso idx .labelOutsideClosure =>
    { condition := "structural", lasso := some idx,
      detail := "a label is not a subset of the closure of the premises and conclusions" }
  | .lassosEmpty =>
    { condition := "structural", detail := "the family has no lassos" }
  | .atomNotBase =>
    { condition := "structural",
      detail := "an atom carries a fresh index, which the wire format does not preserve" }

/--
Re-verify a decoded certificate.

The verdict is `decidableLocalCoherentLab`, `decidableFulfillingLab`, `decidableBoxFaithful` and
`decidableTarget`, in that order, short-circuiting on the first `false`. Acceptance means those
four compiled instances returned `true` — it is not a kernel-checked proof for this certificate,
and a rejection is never a claim that the consequence holds.
-/
def checkRaw (raw : RawCertificate) : CheckResult :=
  match mkFamily raw with
  | .error f => .rejected [f.toFailure]
  | .ok W =>
    if ! @Decidable.decide _ (WitnessFamily.decidableLocalCoherentLab W) then
      .rejected [(cohFailure W).getD (unlocalized "local_coherent")]
    else if ! @Decidable.decide _ (WitnessFamily.decidableFulfillingLab W) then
      .rejected [(fulFailure W).getD (unlocalized "fulfilling")]
    else if ! @Decidable.decide _ (WitnessFamily.decidableBoxFaithful W) then
      .rejected [(boxFailure W).getD (unlocalized "box_faithful")]
    else if ! @Decidable.decide _ (WitnessFamily.decidableTarget W raw.target.time) then
      .rejected [(targetFailure W raw.target.time).getD (unlocalized "target")]
    else
      .countermodel raw.target.time

/-- Parse and re-verify one JSON line. Malformed input is an `error`, never a verdict. -/
def checkLine (line : String) : CheckResult :=
  match parseCertificate line with
  | .error msg => .error msg
  | .ok raw => checkRaw raw

/-!
## The output line
-/

/-- Serialize an optional natural number as a JSON value. -/
def optNatToJson : Option Nat → String
  | none => "null"
  | some n => toString n

/-- Serialize an optional integer as a JSON value. -/
def optIntToJson : Option Int → String
  | none => "null"
  | some n => toString n

/-- Serialize an optional formula as a JSON value. -/
def optFormulaToJson : Option Formula → String
  | none => "null"
  | some φ => φ.toJson

/-- Serialize one failure record. -/
def Failure.toJson (f : Failure) : String :=
  "{\"condition\":\"" ++ escapeJsonString f.condition ++
  "\",\"lasso\":" ++ optNatToJson f.lasso ++
  ",\"position\":" ++ optIntToJson f.position ++
  ",\"formula\":" ++ optFormulaToJson f.formula ++
  ",\"detail\":\"" ++ escapeJsonString f.detail ++ "\"}"

/-- Serialize the verdict as the single JSON line the executable prints. -/
def CheckResult.toJson : CheckResult → String
  | .countermodel t => "{\"status\":\"countermodel\",\"time\":" ++ toString t ++ "}"
  | .rejected fs =>
    "{\"status\":\"rejected\",\"failed\":" ++ jsonArray (fs.map Failure.toJson) ++ "}"
  | .error m => "{\"status\":\"error\",\"message\":\"" ++ escapeJsonString m ++ "\"}"

/-- Parse, re-verify and serialize: the whole executable, minus the IO. -/
def checkLineToJson (line : String) : String := (checkLine line).toJson

end BimodalTools.CertificateImport
