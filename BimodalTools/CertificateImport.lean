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

/-- A whole certificate, as it arrives. -/
structure RawCertificate where
  /-- The premise context `Γ`. -/
  premises : List Formula := []
  /-- The conclusion context `Δ`. -/
  conclusions : List Formula := []
  /-- The box guess, as `(formula, bool)` pairs; anything absent reads as `false`. -/
  bx : List (Formula × Bool) := []
  /-- The lassos; lasso `0` is the main one, where the target is read. -/
  lassos : List RawLasso := []
  /-- The target time. Optional on the wire, defaulting to `0`. -/
  time : Int := 0
  deriving Repr, Inhabited, DecidableEq

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

/-- Parse the certificate envelope. `"time"` may be absent, in which case it reads as `0`. -/
def pRawCertificate : PState → Except String (RawCertificate × PState) :=
  pObjectFields (fun key acc st => do
    if key == "premises" then
      let (v, st) ← pArrayOf pFormula st
      return ({ acc with premises := v }, st)
    else if key == "conclusions" then
      let (v, st) ← pArrayOf pFormula st
      return ({ acc with conclusions := v }, st)
    else if key == "bx" then
      let (v, st) ← pArrayOf pBxPair st
      return ({ acc with bx := v }, st)
    else if key == "lassos" then
      let (v, st) ← pArrayOf pRawLasso st
      return ({ acc with lassos := v }, st)
    else if key == "time" then
      let (v, st) ← pInt st
      return ({ acc with time := v }, st)
    else
      let st ← pSkipValue st
      return (acc, st)) {}

/-- Parse a whole certificate from one JSON line. -/
def parseCertificate (s : String) : Except String RawCertificate := do
  let (c, _) ← pRawCertificate (mkPState s)
  return c

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

/-- Serialize a whole certificate. -/
def RawCertificate.toJson (c : RawCertificate) : String :=
  "{\"premises\":" ++ jsonArray (c.premises.map Formula.toJson) ++
  ",\"conclusions\":" ++ jsonArray (c.conclusions.map Formula.toJson) ++
  ",\"bx\":" ++ jsonArray (c.bx.map bxPairToJson) ++
  ",\"lassos\":" ++ jsonArray (c.lassos.map RawLasso.toJson) ++
  ",\"time\":" ++ toString c.time ++ "}"

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
  c.premises ++ c.conclusions ++ c.bx.map Prod.fst ++
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
    Except StructuralFault (WitnessFamily raw.premises raw.conclusions) := do
  if raw.formulas.any hasFreshAtom then .error .atomNotBase
  else
    let lassos ← raw.lassos.zipIdx.mapM fun p =>
      match mkLasso (closureOf (raw.premises ++ raw.conclusions)) p.1 with
      | .ok Λ => .ok Λ
      | .error f => .error (.lasso p.2 f)
    if hl : lassos = [] then .error .lassosEmpty
    else return { bx := bxOf raw.bx, lassos := lassos, lassos_ne := hl }

end BimodalTools.CertificateImport
