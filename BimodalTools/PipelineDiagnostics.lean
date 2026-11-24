/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import BimodalLib.Diagnostics.Emit
import BimodalLib.Diagnostics.Record
import BimodalTools.TableauBridge

/-!
# The five reserved-stage diagnostics emitters

`BimodalLib/Diagnostics/Record.lean` fixes one record schema for all seven stages of the library
pipeline: a shared `Head` plus a per-stage payload whose field names are listed in
`Stage.reservedKeys`. Two stages, `reprove` and `compare`, are implemented there because they are
the two the proof-mode cost baseline emits. The other five — `enumerate`, `decide`, `extract`,
`certify` and `admit` — have their payload keys reserved and their emitters left to the tableau
pipeline. This module is those five emitters.

## `Stage.reservedKeys` is the authority, not a suggestion

Each structure below carries exactly the fields `Stage.reservedKeys` lists for its stage, in that
order, and each `toJsonFields` emits `Head.toJsonFields` first and then those fields in the same
order. `Tests/BimodalToolsTest/PipelineDiagnosticsTest.lean` asserts the equality
`record.keys = Head.keys ++ Stage.reservedKeys <stage>` for all five, so the schema and these
emitters cannot drift apart. Nothing here edits the schema: `BimodalLib/Diagnostics/Record.lean`
is imported read-only.

## Why these emitters are not under `BimodalLib/Diagnostics/`

Two reasons, and they point the same way. `scripts/proof-mode-cost-baseline.sh` pins the
*directory* `BimodalLib/Diagnostics` in its `SURFACE` array, so any commit writing anywhere under
it reports `STALE BASELINE` (exit 3) until the pin is moved — verified live. And that directory is
the Evaluation lane's territory under `records/proof-mode.md`, while this work is the Library
lane's. Siting the emitters in `BimodalTools/` resolves both at once and needs no schema edit,
since the keys were reserved precisely so a second library could supply the emitter.

## The import edge

This is the first module to use the `BimodalTools → BimodalLib` edge. It is the correct direction:
the *tooling* library borrows the *results* library's vocabulary, rather than the results library
pulling the enumerator and dataset machinery into `lake build BimodalLib`, which CI runs with
`--wfail` as its own step. Check `B3` gates only `FormalSystem → BimodalTools|BimodalLib` and so
has nothing to say about it.

## Closed vocabularies

Three payload fields are closed Lean enumerations rather than strings, in the same spirit as
`Outcome` and `FailureClass` in the schema module:

- `Verdict` — `DecisionResult`'s **own four** constructor names, `valid`, `invalid`,
  `fuelExhausted` and `extractionFailed`. Not `FormulaLabel`'s three. The distinction is
  load-bearing rather than pedantic: `extractionFailed` means the tableau closed, so the formula
  *is* valid, but no `⊢ φ` witness was extracted, and it is 26 of 133 at `ModalBoolean`
  complexity 5 — as large as `fuelExhausted` and larger than `valid`. A three-name vocabulary
  would fold it into one of the others and over-count the admissible yield by exactly that share.
- `Grade` — how a refutation is backed: `gatedTableau` when all eight gates of
  `not_valid_of_hasOpen_int` hold on the open branch, `certificate` when a witness-family
  certificate was accepted by `decidableCertifies`. At `ZTime` only the second is reachable:
  `regionLabel` and `temporalWitness` evaluate `false` on every formula there, so
  `BranchGates.gated` is 0 of 11, while the other three frame classes gate 11 of 11. A `ZTime`
  record therefore carries `certificate` or no grade, never `gatedTableau`.
- `Disposition` — `admitted`, `subsumed` or `conjecture`, with `subsumedBy` naming the subsuming
  row and `conjectureVerdict` carrying the verbatim verdict of a non-admitted outcome.

## Head identifiers

An admitted entry's head `statement` is the registered declaration's fully-qualified name. An
*enumerated* formula has no declaration name at all, so `unregisteredStatementId` — which
produces `"unregistered:" ++ declName` — cannot apply to it; `datasetStatementId` below supplies
the `data/`-style `bmlogic-NNNNN` identifier the datasets already use instead. This leaves
`Stage.carriesFormulaField` as the unexercised obligation `docs/reference/diagnostics.md` already
records: `enumerate` and `extract` are flagged as formula-carrying, but neither stage's reserved
key list holds a formula-valued field, so the formula a record is about is carried by the head's
identifier and nothing here needs a second formula codec.

## The two stamp options

`diagnostics.commit` and `diagnostics.zeroTimings` are registered in
`BimodalLib/Diagnostics/Emit.lean` and are read here by `readCommitOption` and
`readZeroTimingsOption`, so a `set_option` in a caller's file reaches these emitters exactly as it
reaches that module's. `zeroTimings` zeroes `decision_time_ms`, which is the only field of these
five payloads that is not a function of the commit and the toolchain, and therefore the only
obstacle to a byte-stable record.

## References

* `BimodalLib/Diagnostics/Record.lean` — the schema: `Head`, `Stage`, `Stage.reservedKeys`
* `BimodalLib/Diagnostics/Emit.lean` — the stamp options and the two implemented stages
* `BimodalTools/TableauBridge.lean` — `BranchGates` and its snake_case JSON
* `docs/reference/diagnostics.md` — the reserved-stage section and the formula-codec obligation

## Tags

diagnostics · theorem-library · pipeline · schema
-/

open Lean (Json)
open BimodalLib.Diagnostics (Head Stage)

namespace BimodalTools.PipelineDiagnostics

open BimodalTools.TableauBridge (BranchGates)

/-! ## Shared JSON helpers

Local copies rather than imports: the schema module's `optNat` and `strArray` are `private`. -/

/-- `Json.null` for `none`, a number for `some`. -/
private def optNat (o : Option Nat) : Json :=
  match o with
  | none => Json.null
  | some n => Json.num (n : Int)

/-- `Json.null` for `none`, a string for `some`. -/
private def optStr (o : Option String) : Json :=
  match o with
  | none => Json.null
  | some s => Json.str s

/-- A list of strings as a JSON array. -/
private def strArray (xs : List String) : Json :=
  Json.arr (xs.map Json.str).toArray

/-- A string-keyed histogram as a JSON object. -/
private def histogram (xs : List (String × Nat)) : Json :=
  Json.mkObj (xs.map (fun p => (p.1, Json.num (p.2 : Int))))

/-- A `Nat`-keyed histogram as a JSON object, the key rendered in decimal. -/
private def natHistogram (xs : List (Nat × Nat)) : Json :=
  histogram (xs.map (fun p => (toString p.1, p.2)))

/-! ## Statement identifiers -/

/-- The `data/`-style identifier of an enumerated formula with no registered row: the dataset
prefix and a zero-padded serial, as `data/bmlogic-c4.jsonl` already spells them. An enumerated
formula has no declaration name, so `unregisteredStatementId` cannot name it. -/
def datasetStatementId (prefixName : String) (serial : Nat) : String :=
  let digits := toString serial
  let pad := String.ofList (List.replicate (5 - min 5 digits.length) '0')
  prefixName ++ "-" ++ pad ++ digits

/-! ## The stamp options -/

/-- The `diagnostics.commit` stamp, or `unstamped` when it was never set. Reads the option
registered in `BimodalLib/Diagnostics/Emit.lean`, so one `set_option` governs both modules. -/
def readCommitOption : Lean.CoreM String := do
  let raw := BimodalLib.Diagnostics.diagnostics.commit.get (← Lean.getOptions)
  return if raw.isEmpty then BimodalLib.Diagnostics.unstamped else raw

/-- Whether `decision_time_ms` is to be zeroed, from `diagnostics.zeroTimings`. -/
def readZeroTimingsOption : Lean.CoreM Bool := do
  return BimodalLib.Diagnostics.diagnostics.zeroTimings.get (← Lean.getOptions)

/-! ## `enumerate` -/

/--
The `enumerate` payload: how many formulas the enumeration produced, split by fragment and by
complexity, and how many canonicalization removed.

A count split by complexity is meaningless without the measure it is in: these are
`Formula.complexity`'s *pattern-aware operator layers*, not primitive nodes. A yield figure is
likewise meaningless without the atom pool it was taken at, which the head's `command` carries.
-/
structure EnumerateRecord where
  /-- The shared head. Its `stage` should be `.enumerate`. -/
  head : Head
  /-- Surviving formulas after canonicalization and the fragment filter. -/
  formulasGenerated : Nat
  /-- Surviving count per fragment name. -/
  byFragment : List (String × Nat)
  /-- Surviving count per `Formula.complexity` layer count. -/
  byComplexity : List (Nat × Nat)
  /-- Representatives discarded by `deduplicateCanonical`. -/
  duplicatesRemoved : Nat
  deriving Repr, Inhabited

/-- The `enumerate` record's fields, in `Head.keys ++ Stage.reservedKeys .enumerate` order. -/
def EnumerateRecord.toJsonFields (r : EnumerateRecord) : List (String × Json) :=
  r.head.toJsonFields ++
    [ ("formulas_generated", Json.num (r.formulasGenerated : Int))
    , ("by_fragment", histogram r.byFragment)
    , ("by_complexity", natHistogram r.byComplexity)
    , ("duplicates_removed", Json.num (r.duplicatesRemoved : Int)) ]

/-- The `enumerate` record as one JSON object. -/
def EnumerateRecord.toJson (r : EnumerateRecord) : Json :=
  Json.mkObj r.toJsonFields

/-- The field names this emitter actually emits, for the schema-agreement guard. -/
def EnumerateRecord.keys (r : EnumerateRecord) : List String :=
  r.toJsonFields.map (·.1)

/-! ## `decide` -/

/--
A validity verdict, as `DecisionResult`'s own four constructors.

`extractionFailed` is `isKnownValid`: the tableau closed, so the formula is valid, but proof-term
extraction produced no `⊢ φ` witness, which is why such a formula is never admissible and always
lands in the conjecture half. It is a principal outcome, not an edge case, and keeping it distinct
from `fuelExhausted` is what stops `valid + extractionFailed` being read as the admissible yield.
-/
inductive Verdict where
  /-- Valid, with an extracted derivation. -/
  | valid
  /-- Invalid, with a countermodel. -/
  | invalid
  /-- Fuel ran out before any verdict. -/
  | fuelExhausted
  /-- The tableau closed but no proof term was extracted. -/
  | extractionFailed
  deriving DecidableEq, Repr, Inhabited

/-- The snake_case key a verdict is recorded under. -/
def Verdict.key : Verdict → String
  | .valid => "valid"
  | .invalid => "invalid"
  | .fuelExhausted => "fuel_exhausted"
  | .extractionFailed => "extraction_failed"

/-- Read a verdict back from its key. `none` on anything outside the closed list. -/
def Verdict.ofKey? : String → Option Verdict
  | "valid" => some .valid
  | "invalid" => some .invalid
  | "fuel_exhausted" => some .fuelExhausted
  | "extraction_failed" => some .extractionFailed
  | _ => none

/-- Every verdict, in `DecisionResult`'s constructor order. -/
def Verdict.all : List Verdict :=
  [.valid, .invalid, .fuelExhausted, .extractionFailed]

/-- Whether a verdict reports the formula valid. True of `valid` and of `extractionFailed`: the
tableau closed in both cases, and only the witness differs. -/
def Verdict.isKnownValid : Verdict → Bool
  | .valid => true
  | .extractionFailed => true
  | _ => false

/-- Whether a verdict admits a derivation, and so can reach the ADMIT stage at all. -/
def Verdict.admissible : Verdict → Bool
  | .valid => true
  | _ => false

/-- The `decide` payload: the verdict and the cost of reaching it. -/
structure DecideRecord where
  /-- The shared head. Its `stage` should be `.decide`. -/
  head : Head
  /-- The verdict, in the four-name vocabulary. -/
  verdict : Verdict
  /-- Wall-clock decision time; zeroed under `diagnostics.zeroTimings`. -/
  decisionTimeMs : Nat
  /-- Tableau fuel consumed. -/
  fuelUsed : Nat
  /-- Branches the tableau opened. -/
  branchesOpened : Nat
  /-- Branches the tableau closed. -/
  branchesClosed : Nat
  deriving Repr, Inhabited

/-- The `decide` record's fields, in `Head.keys ++ Stage.reservedKeys .decide` order.
`zeroTimings` zeroes `decision_time_ms`, the one volatile field of these five payloads. -/
def DecideRecord.toJsonFields (r : DecideRecord) (zeroTimings : Bool := false) :
    List (String × Json) :=
  r.head.toJsonFields ++
    [ ("verdict", Json.str r.verdict.key)
    , ("decision_time_ms", Json.num (if zeroTimings then 0 else (r.decisionTimeMs : Int)))
    , ("fuel_used", Json.num (r.fuelUsed : Int))
    , ("branches_opened", Json.num (r.branchesOpened : Int))
    , ("branches_closed", Json.num (r.branchesClosed : Int)) ]

/-- The `decide` record as one JSON object. -/
def DecideRecord.toJson (r : DecideRecord) (zeroTimings : Bool := false) : Json :=
  Json.mkObj (r.toJsonFields zeroTimings)

/-- The field names this emitter actually emits, for the schema-agreement guard. -/
def DecideRecord.keys (r : DecideRecord) : List String :=
  (r.toJsonFields).map (·.1)

/-! ## `extract` -/

/--
The `extract` payload: the measures of whatever came out of the closed tableau, or of the
countermodel on the open branch.

Every field is nullable in exactly one direction. A `valid` verdict yields a derivation and so
reports `derivation_size`/`derivation_height` and the axiom schemata it used, with no countermodel
measures; an `invalid` verdict yields a countermodel and so reports its history and time counts,
with no derivation measures. An `extractionFailed` verdict yields neither, and reports the route
that failed.
-/
structure ExtractRecord where
  /-- The shared head. Its `stage` should be `.extract`. -/
  head : Head
  /-- Node count of the extracted derivation; null when none was extracted. -/
  derivationSize : Option Nat
  /-- Height of the extracted derivation; null when none was extracted. -/
  derivationHeight : Option Nat
  /-- The axiom constructor names the derivation instantiates, in first-use order. -/
  axiomSchemata : List String
  /-- Which extraction route ran: the proof extractor, a countermodel extractor, or neither. -/
  extractionRoute : String
  /-- Distinct world histories in the countermodel; null for a derivation. -/
  countermodelHistories : Option Nat
  /-- Distinct times in the countermodel; null for a derivation. -/
  countermodelTimes : Option Nat
  deriving Repr, Inhabited

/-- The `extract` record's fields, in `Head.keys ++ Stage.reservedKeys .extract` order. -/
def ExtractRecord.toJsonFields (r : ExtractRecord) : List (String × Json) :=
  r.head.toJsonFields ++
    [ ("derivation_size", optNat r.derivationSize)
    , ("derivation_height", optNat r.derivationHeight)
    , ("axiom_schemata", strArray r.axiomSchemata)
    , ("extraction_route", Json.str r.extractionRoute)
    , ("countermodel_histories", optNat r.countermodelHistories)
    , ("countermodel_times", optNat r.countermodelTimes) ]

/-- The `extract` record as one JSON object. -/
def ExtractRecord.toJson (r : ExtractRecord) : Json :=
  Json.mkObj r.toJsonFields

/-- The field names this emitter actually emits, for the schema-agreement guard. -/
def ExtractRecord.keys (r : ExtractRecord) : List String :=
  r.toJsonFields.map (·.1)

/-! ## `certify` -/

/--
How a refutation is backed.

`gatedTableau` is the strong grade: all eight hypotheses of `not_valid_of_hasOpen_int` hold on the
open branch, so the `invalid` verdict is theorem-backed rather than the decision procedure's own.
`certificate` is the witness-family route through `decidableCertifies`.

At `ZTime` the first grade is structurally unavailable, not merely rare: `regionLabel` and
`temporalWitness` come back `false` on every formula there, so `BranchGates.gated` is 0 of 11,
against 11 of 11 at each of `Base`, `Dense` and `RTime`. A `ZTime` refutation is therefore graded
`certificate` or left ungraded, and a `ZTime` count of zero is a finding about
`decidableCertifies`' acceptance rate rather than a pipeline defect.
-/
inductive Grade where
  /-- All eight gates hold on the open branch. -/
  | gatedTableau
  /-- A witness-family certificate was accepted. -/
  | certificate
  deriving DecidableEq, Repr, Inhabited

/-- The snake_case key a grade is recorded under. -/
def Grade.key : Grade → String
  | .gatedTableau => "gated_tableau"
  | .certificate => "certificate"

/-- Read a grade back from its key. `none` on anything outside the closed list. -/
def Grade.ofKey? : String → Option Grade
  | "gated_tableau" => some .gatedTableau
  | "certificate" => some .certificate
  | _ => none

/-- Every grade. -/
def Grade.all : List Grade := [.gatedTableau, .certificate]

/-- The gates as the value of the `gates` key: `BranchGates.toJson`'s own snake_case object,
reused verbatim rather than restated. Its output is a string literal built field by field, so the
parse cannot fail; the error arm records the raw text rather than silently emitting `null`. -/
def gatesValue : Option BranchGates → Json
  | none => Json.null
  | some g =>
      match Json.parse g.toJson with
      | .ok j => j
      | .error _ => Json.str g.toJson

/--
The `certify` payload: the axiom set a derivation depends on, or a refutation's grade and the
eight gate `Bool`s.

A theorem-side record carries `axioms` and no grade; a countermodel-side record carries a grade
and `gates` and no axioms.
-/
structure CertifyRecord where
  /-- The shared head. Its `stage` should be `.certify`. -/
  head : Head
  /-- The axiom set the admitted derivation depends on. -/
  axioms : List String
  /-- How the refutation is backed; null on the theorem side. -/
  countermodelGrade : Option Grade
  /-- The eight gates, `BranchGates.toJson` verbatim; null when gates were not evaluated, which
  is every `ZTime` record by construction. -/
  gates : Option BranchGates
  deriving Repr

/-- The `certify` record's fields, in `Head.keys ++ Stage.reservedKeys .certify` order. -/
def CertifyRecord.toJsonFields (r : CertifyRecord) : List (String × Json) :=
  r.head.toJsonFields ++
    [ ("axioms", strArray r.axioms)
    , ("countermodel_grade", optStr (r.countermodelGrade.map Grade.key))
    , ("gates", gatesValue r.gates) ]

/-- The `certify` record as one JSON object. -/
def CertifyRecord.toJson (r : CertifyRecord) : Json :=
  Json.mkObj r.toJsonFields

/-- The field names this emitter actually emits, for the schema-agreement guard. -/
def CertifyRecord.keys (r : CertifyRecord) : List String :=
  r.toJsonFields.map (·.1)

/-- Whether a `certify` record's `ZTime` rule holds: no `ZTime` record claims the
`gatedTableau` grade, and no `ZTime` record carries evaluated gates. -/
def CertifyRecord.zTimeWellFormed (r : CertifyRecord) : Bool :=
  if r.head.frameClass == "ZTime" then
    r.countermodelGrade != some Grade.gatedTableau && r.gates.isNone
  else true

/-! ## `admit` -/

/-- What became of a decided formula. Closed: these three are the whole vocabulary. -/
inductive Disposition where
  /-- Generalized and registered as a theorem entry. -/
  | admitted
  /-- A substitution instance of an entry already present, so not registered. -/
  | subsumed
  /-- Registered as a conjecture with its verdict, never as a result. -/
  | conjecture
  deriving DecidableEq, Repr, Inhabited

/-- The snake_case key a disposition is recorded under. -/
def Disposition.key : Disposition → String
  | .admitted => "admitted"
  | .subsumed => "subsumed"
  | .conjecture => "conjecture"

/-- Read a disposition back from its key. `none` on anything outside the closed list. -/
def Disposition.ofKey? : String → Option Disposition
  | "admitted" => some .admitted
  | "subsumed" => some .subsumed
  | "conjecture" => some .conjecture
  | _ => none

/-- Every disposition. -/
def Disposition.all : List Disposition := [.admitted, .subsumed, .conjecture]

/--
The `admit` payload.

`subsumedBy` names the subsuming row and is present exactly when the disposition is `subsumed`;
`conjectureVerdict` carries the verbatim verdict and is present exactly when the disposition is
`conjecture`. The conjecture half is expected to dominate the admitted half: `extractionFailed`
alone is 26 of 133 at `ModalBoolean` complexity 5, and every `fuelExhausted` and every ungated
`invalid` lands here too.
-/
structure AdmitRecord where
  /-- The shared head. Its `stage` should be `.admit`. -/
  head : Head
  /-- What became of the formula. -/
  disposition : Disposition
  /-- The subsuming row's name; null unless the disposition is `subsumed`. -/
  subsumedBy : Option String
  /-- The verdict a conjecture is registered with; null unless the disposition is `conjecture`. -/
  conjectureVerdict : Option Verdict
  deriving Repr, Inhabited

/-- The `admit` record's fields, in `Head.keys ++ Stage.reservedKeys .admit` order. -/
def AdmitRecord.toJsonFields (r : AdmitRecord) : List (String × Json) :=
  r.head.toJsonFields ++
    [ ("disposition", Json.str r.disposition.key)
    , ("subsumed_by", optStr r.subsumedBy)
    , ("conjecture_verdict", optStr (r.conjectureVerdict.map Verdict.key)) ]

/-- The `admit` record as one JSON object. -/
def AdmitRecord.toJson (r : AdmitRecord) : Json :=
  Json.mkObj r.toJsonFields

/-- The field names this emitter actually emits, for the schema-agreement guard. -/
def AdmitRecord.keys (r : AdmitRecord) : List String :=
  r.toJsonFields.map (·.1)

/--
Whether an `admit` record's nullability rule holds: the two optional fields are present exactly
on their own disposition, so a `subsumed_by` on an `admitted` row, or a missing
`conjecture_verdict` on a `conjecture` row, is caught at the emitter.
-/
def AdmitRecord.dispositionWellFormed (r : AdmitRecord) : Bool :=
  (r.subsumedBy.isSome == (r.disposition == Disposition.subsumed))
    && (r.conjectureVerdict.isSome == (r.disposition == Disposition.conjecture))

/-! ## Schema agreement, asserted here as well as in the test

The test module holds the same checks as `#guard`s. These are `example`s because
`lean_lib BimodalTools` carries no `linter.hashCommand` opt-out and CI builds `--wfail`, so a
`#`-command in this library is a warning and therefore a failure. -/

/-- A head whose fields are all empty, for the key-order assertions below. -/
private def blankHead (s : Stage) : Head :=
  { statement := ""
    stage := s
    fragment := ""
    frameClass := ""
    commit := ""
    command := "" }

/-- A zeroed `enumerate` record, for the key-order assertion. -/
private def blankEnumerate : EnumerateRecord :=
  { head := blankHead .enumerate
    formulasGenerated := 0
    byFragment := []
    byComplexity := []
    duplicatesRemoved := 0 }

/-- A zeroed `decide` record, for the key-order assertion. -/
private def blankDecide : DecideRecord :=
  { head := blankHead .decide
    verdict := .valid
    decisionTimeMs := 0
    fuelUsed := 0
    branchesOpened := 0
    branchesClosed := 0 }

/-- A zeroed `extract` record, for the key-order assertion. -/
private def blankExtract : ExtractRecord :=
  { head := blankHead .extract
    derivationSize := none
    derivationHeight := none
    axiomSchemata := []
    extractionRoute := ""
    countermodelHistories := none
    countermodelTimes := none }

/-- A zeroed `certify` record, for the key-order assertion. -/
private def blankCertify : CertifyRecord :=
  { head := blankHead .certify
    axioms := []
    countermodelGrade := none
    gates := none }

/-- A zeroed `admit` record, for the key-order assertion. -/
private def blankAdmit : AdmitRecord :=
  { head := blankHead .admit
    disposition := .admitted
    subsumedBy := none
    conjectureVerdict := none }

example : blankEnumerate.keys = Head.keys ++ Stage.reservedKeys .enumerate := by rfl
example : blankDecide.keys = Head.keys ++ Stage.reservedKeys .decide := by rfl
example : blankExtract.keys = Head.keys ++ Stage.reservedKeys .extract := by rfl
example : blankCertify.keys = Head.keys ++ Stage.reservedKeys .certify := by rfl
example : blankAdmit.keys = Head.keys ++ Stage.reservedKeys .admit := by rfl

-- The verdict vocabulary is `DecisionResult`'s four constructor names, not `FormulaLabel`'s three.
example : Verdict.all.length = 4 := by rfl
example : Verdict.all.map Verdict.key
    = ["valid", "invalid", "fuel_exhausted", "extraction_failed"] := by rfl
example : Verdict.all.all (fun v => Verdict.ofKey? v.key == some v) = true := by rfl

end BimodalTools.PipelineDiagnostics
