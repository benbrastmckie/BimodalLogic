/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import BimodalLib.Fragment
import BimodalLib.Diagnostics.Size

/-!
# One diagnostics record schema for every stage of the library pipeline

A record is keyed by the statement's identifier and the stage, and carries the fragment, the frame
class, the commit and the command that produced it. That is the **shared head**, and it is the
same for all seven stages: `enumerate`, `decide`, `extract`, `certify`, `admit`, `reprove` and
`compare`. Each stage then adds its own payload.

Two stages are implemented here, `reprove` and `compare`, because they are the two the proof-mode
cost baseline emits. The other five have their payload keys **reserved** in `Stage.reservedKeys`
below, with the field lists taken from the pipeline record's own Diagnostics table, so that the
tableau pipeline extends this schema rather than renegotiating it. A reserved stage is a stage
whose head is already fixed and whose payload names are already agreed; what is missing is only
its emitter.

## Serialization

Every field name is snake_case at the top level, matching the convention of the existing datasets
under `data/` (`frame_class`, `proof_trace`, `decision_method_distribution`). The Lean field names
stay lowerCamelCase, as the rest of the library's do, so the mapping is written out explicitly in
`toJson` rather than derived — a derived instance would emit the Lean spelling and silently
introduce a second convention beside the one the datasets already use.

Records are **printed**, one JSON object per invocation, and collected by the measuring script.
No command in this directory writes a tracked file as an elaboration side effect: a command that
did would be both untestable and non-composable.

## Closed enumerations

`outcome`, `failure_class` and `reference_kind` are closed Lean enumerations rather than strings,
so an invalid value cannot be recorded. The four outcomes and the six failure classes are the
pipeline record's own fixed lists, not a superset invented here.

## No formula codec is imported, and that is deliberate

Neither implemented stage carries a formula-valued field: the shared head is six strings, the
`reprove` payload is scalars plus two string arrays, and the `compare` payload is scalars plus two
fragment names. Reusing `Formula`'s JSON codec would mean a new dependency edge out of this
library for nothing. The reserved stages that **do** carry formula-valued fields — `enumerate` and
`extract` — must reuse the existing `{"tag": ...}` codec rather than invent a second one; that
obligation is recorded here and in `docs/reference/diagnostics.md`, and is discharged by whoever
writes those emitters.
-/

open Lean (Json)
open FormalSystem.ProofSystem (FrameClass)

namespace BimodalLib.Diagnostics

/-! ## The stage key -/

/--
The seven stages of the library pipeline. A record's key is the pair of a statement identifier and
one of these.
-/
inductive Stage where
  /-- Formulas generated, by fragment and complexity. -/
  | enumerate
  /-- A validity verdict from the decision procedure. -/
  | decide
  /-- A derivation or a countermodel pulled out of a closed tableau. -/
  | extract
  /-- The axiom set, or a countermodel's grade and gates. -/
  | certify
  /-- Admitted, subsumed, or registered as a conjecture. -/
  | admit
  /-- A statement re-proved by a proof-mode script. -/
  | reprove
  /-- A script measured against a reference proof. -/
  | compare
  deriving DecidableEq, Repr, Inhabited

/-- The snake_case key a stage is recorded under. -/
def Stage.key : Stage → String
  | .enumerate => "enumerate"
  | .decide => "decide"
  | .extract => "extract"
  | .certify => "certify"
  | .admit => "admit"
  | .reprove => "reprove"
  | .compare => "compare"

/-- Read a stage back from its key. `none` on anything outside the closed list. -/
def Stage.ofKey? : String → Option Stage
  | "enumerate" => some .enumerate
  | "decide" => some .decide
  | "extract" => some .extract
  | "certify" => some .certify
  | "admit" => some .admit
  | "reprove" => some .reprove
  | "compare" => some .compare
  | _ => none

/-- Every stage, in pipeline order. Used to enumerate the schema. -/
def Stage.all : List Stage :=
  [.enumerate, .decide, .extract, .certify, .admit, .reprove, .compare]

/--
Whether a stage has an emitter in this module. `reprove` and `compare` do; the other five are
reserved, with their payload keys fixed by `Stage.reservedKeys` and their emitters written by the
tableau pipeline.
-/
def Stage.isImplemented : Stage → Bool
  | .reprove => true
  | .compare => true
  | _ => false

/--
The payload field names of each stage, in record order.

For the two implemented stages this is the field list `ReproveRecord.toJson` and
`CompareRecord.toJson` actually emit, so the schema and the emitters cannot drift. For the five
reserved stages it is the field list the pipeline record's Diagnostics table names for that stage,
written down here so the eventual emitter has an agreed payload rather than a gap to guess at.
-/
def Stage.reservedKeys : Stage → List String
  | .enumerate =>
      ["formulas_generated", "by_fragment", "by_complexity", "duplicates_removed"]
  | .decide =>
      ["verdict", "decision_time_ms", "fuel_used", "branches_opened", "branches_closed"]
  | .extract =>
      ["derivation_size", "derivation_height", "axiom_schemata", "extraction_route",
       "countermodel_histories", "countermodel_times"]
  | .certify =>
      ["axioms", "countermodel_grade", "gates"]
  | .admit =>
      ["disposition", "subsumed_by", "conjecture_verdict"]
  | .reprove =>
      ["outcome", "failure_class", "tactic_count", "distinct_tactics", "escape_size",
       "heartbeats", "elab_ms", "term_size", "derivation_size", "derivation_height", "axioms"]
  | .compare =>
      ["script_length", "hand_proof_length", "length_ratio", "reference_kind",
       "built_derivation_size", "reference_derivation_size", "statement_fragment",
       "proof_fragment"]

/--
The reserved stages that carry a formula-valued field, and must therefore reuse the existing
`{"tag": ...}` formula codec rather than invent a second one. Neither implemented stage is a
member, which is why no codec is imported here.
-/
def Stage.carriesFormulaField : Stage → Bool
  | .enumerate => true
  | .extract => true
  | _ => false

/-! ## The shared head -/

/--
The head every record carries, whatever its stage. The frame class and the fragment are derived
from the registry row rather than retyped, in the same spirit as `TheoremEntry.profile_eq`'s `rfl`
discipline; a statement with no registered row falls back to the `data/`-style identifier
convention and says so, rather than silently emitting an empty string.
-/
structure Head where
  /-- The registered declaration's fully-qualified name, or a `data/`-style `id` for a statement
  with no row yet. -/
  statement : String
  /-- Which stage of the pipeline produced this record. -/
  stage : Stage
  /-- The fragment of the statement. -/
  fragment : String
  /-- The frame class the statement is stated at. -/
  frameClass : String
  /-- `git rev-parse --short HEAD` at the time of measurement, stamped from outside. -/
  commit : String
  /-- The exact command line that produced the record. -/
  command : String
  deriving Repr, Inhabited

/-- The field names of the shared head, in record order. -/
def Head.keys : List String :=
  ["statement", "stage", "fragment", "frame_class", "commit", "command"]

/-- The string name of a frame class, matching the `frame_class` spelling the datasets use. -/
def frameClassKey : FrameClass → String
  | .Base => "Base"
  | .Dense => "Dense"
  | .ZTime => "ZTime"
  | .RTime => "RTime"

/-- The string name of a fragment, reusing `Fragment.name` rather than restating it. -/
def fragmentKey (f : BimodalLib.Fragment) : String := f.name

/--
The identifier to record for a statement with no registered row: the `data/`-style convention of
a dataset prefix and the declaration's own name, so a reader can tell an unregistered mirror from
a registry key at a glance instead of finding an empty string.
-/
def unregisteredStatementId (declName : String) : String :=
  "unregistered:" ++ declName

/-- The head's six fields as JSON, snake_case. -/
def Head.toJsonFields (h : Head) : List (String × Json) :=
  [ ("statement", Json.str h.statement)
  , ("stage", Json.str h.stage.key)
  , ("fragment", Json.str h.fragment)
  , ("frame_class", Json.str h.frameClass)
  , ("commit", Json.str h.commit)
  , ("command", Json.str h.command) ]

/-! ## The `reprove` payload -/

/--
The outcome of re-proving a statement with a proof-mode script. Closed: these four are the
pipeline record's own list.
-/
inductive Outcome where
  /-- Closed by the mode's rules alone. -/
  | closedByRules
  /-- Closed, with leaf automation. -/
  | closedWithLeafAutomation
  /-- Closed, with a term-mode escape. -/
  | closedWithTermEscape
  /-- Not closed. -/
  | notClosed
  deriving DecidableEq, Repr, Inhabited

/-- The snake_case key an outcome is recorded under. -/
def Outcome.key : Outcome → String
  | .closedByRules => "closed_by_rules"
  | .closedWithLeafAutomation => "closed_with_leaf_automation"
  | .closedWithTermEscape => "closed_with_term_escape"
  | .notClosed => "not_closed"

/-- Read an outcome back from its key. `none` on anything outside the closed list. -/
def Outcome.ofKey? : String → Option Outcome
  | "closed_by_rules" => some .closedByRules
  | "closed_with_leaf_automation" => some .closedWithLeafAutomation
  | "closed_with_term_escape" => some .closedWithTermEscape
  | "not_closed" => some .notClosed
  | _ => none

/-- Every outcome, in record order. -/
def Outcome.all : List Outcome :=
  [.closedByRules, .closedWithLeafAutomation, .closedWithTermEscape, .notClosed]

/--
Whether an outcome permits a `failure_class`. Only `closedByRules` forbids one: a script closed
with leaf automation, with a term-mode escape, or not closed at all has something to report about
why the mode did not carry it alone.
-/
def Outcome.admitsFailureClass : Outcome → Bool
  | .closedByRules => false
  | _ => true

/--
Why the mode did not close a statement on its own. Closed: these six are the pipeline record's own
list.
-/
inductive FailureClass where
  /-- The rule the proof needs is not in the system. -/
  | missingRule
  /-- The rule exists but no tactic reaches it. -/
  | missingTactic
  /-- Leaf automation could not finish a branch. -/
  | automationTooWeak
  /-- The script is writable but too awkward to write. -/
  | scriptTooAwkward
  /-- The script elaborates, but too slowly to use. -/
  | tooSlow
  /-- A defect in the mode itself. -/
  | defectInMode
  deriving DecidableEq, Repr, Inhabited

/-- The snake_case key a failure class is recorded under. -/
def FailureClass.key : FailureClass → String
  | .missingRule => "missing_rule"
  | .missingTactic => "missing_tactic"
  | .automationTooWeak => "automation_too_weak"
  | .scriptTooAwkward => "script_too_awkward"
  | .tooSlow => "too_slow"
  | .defectInMode => "defect_in_mode"

/-- Read a failure class back from its key. `none` on anything outside the closed list. -/
def FailureClass.ofKey? : String → Option FailureClass
  | "missing_rule" => some .missingRule
  | "missing_tactic" => some .missingTactic
  | "automation_too_weak" => some .automationTooWeak
  | "script_too_awkward" => some .scriptTooAwkward
  | "too_slow" => some .tooSlow
  | "defect_in_mode" => some .defectInMode
  | _ => none

/-- Every failure class, in record order. -/
def FailureClass.all : List FailureClass :=
  [.missingRule, .missingTactic, .automationTooWeak, .scriptTooAwkward, .tooSlow, .defectInMode]

/--
The `reprove` payload: what a proof-mode script cost and what it rested on.

`derivationSize` and `derivationHeight` are nullable because both measures need a **closed**
derivation to evaluate, and a schematic mirror has none; see `BimodalLib/Diagnostics/Size.lean`.
`failureClass` is null exactly when the outcome is `closedByRules`.

Two timing fields, not one, and that is deliberate: `heartbeats` is deterministic for a fixed
toolchain and library and is therefore the figure a gate can quote; `elabMs` is wall clock, which
is what "elaboration time" literally asks for but is machine-dependent. Recording both keeps the
reproducible figure separable from the human-legible one.
-/
structure ReproveRecord where
  /-- The shared head. Its `stage` should be `.reprove`. -/
  head : Head
  /-- How the script finished. -/
  outcome : Outcome
  /-- Why the mode did not carry it alone; null iff `outcome = .closedByRules`. -/
  failureClass : Option FailureClass
  /-- Number of tactic invocations in the script. -/
  tacticCount : Nat
  /-- The distinct tactic names used, in first-use order. -/
  distinctTactics : List String
  /-- Elaborated size of any term-mode escape; 0 when there is none. -/
  escapeSize : Nat
  /-- Deterministic elaboration cost. -/
  heartbeats : Nat
  /-- Wall-clock elaboration time in milliseconds. -/
  elabMs : Nat
  /-- Elaborated size of the whole declaration's value. -/
  termSize : Nat
  /-- Node count of the derivation built; null for a schematic mirror. -/
  derivationSize : Option Nat
  /-- Height of the derivation built; null for a schematic mirror. -/
  derivationHeight : Option Nat
  /-- The axiom set the declaration depends on. -/
  axioms : List String
  deriving Repr, Inhabited

/-- `Json.null` for `none`, a number for `some`. -/
private def optNat (o : Option Nat) : Json :=
  match o with
  | none => Json.null
  | some n => Json.num (n : Int)

/-- A list of strings as a JSON array. -/
private def strArray (xs : List String) : Json :=
  Json.arr (xs.map Json.str).toArray

/--
A `reprove` record as one JSON object. Field order is `Head.keys ++ Stage.reservedKeys .reprove`,
which is what makes the reserved-key list checkable against the emitter rather than decorative.
-/
def ReproveRecord.toJson (r : ReproveRecord) : Json :=
  Json.mkObj <| r.head.toJsonFields ++
    [ ("outcome", Json.str r.outcome.key)
    , ("failure_class", match r.failureClass with
        | none => Json.null
        | some f => Json.str f.key)
    , ("tactic_count", Json.num (r.tacticCount : Int))
    , ("distinct_tactics", strArray r.distinctTactics)
    , ("escape_size", Json.num (r.escapeSize : Int))
    , ("heartbeats", Json.num (r.heartbeats : Int))
    , ("elab_ms", Json.num (r.elabMs : Int))
    , ("term_size", Json.num (r.termSize : Int))
    , ("derivation_size", optNat r.derivationSize)
    , ("derivation_height", optNat r.derivationHeight)
    , ("axioms", strArray r.axioms) ]

/--
Whether a `reprove` record's nullability rule holds: `failureClass` is present exactly when the
outcome admits one.
-/
def ReproveRecord.failureClassWellFormed (r : ReproveRecord) : Bool :=
  r.failureClass.isSome == r.outcome.admitsFailureClass

/-! ## The `compare` payload -/

/--
What a script's length is compared against. The pipeline record is explicit that length is
compared against **hand proofs only**: against a tableau-extracted proof a script is measured for
coverage and built-derivation size, not brevity.
-/
inductive ReferenceKind where
  /-- A hand-written reference proof; a length ratio is meaningful. -/
  | hand
  /-- A tableau-extracted reference proof; a length ratio is not meaningful. -/
  | extracted
  deriving DecidableEq, Repr, Inhabited

/-- The snake_case key a reference kind is recorded under. -/
def ReferenceKind.key : ReferenceKind → String
  | .hand => "hand"
  | .extracted => "extracted"

/-- Read a reference kind back from its key. `none` on anything outside the closed list. -/
def ReferenceKind.ofKey? : String → Option ReferenceKind
  | "hand" => some .hand
  | "extracted" => some .extracted
  | _ => none

/-- Every reference kind. -/
def ReferenceKind.all : List ReferenceKind := [.hand, .extracted]

/-- Whether a length ratio is meaningful against this kind of reference. -/
def ReferenceKind.admitsLengthRatio : ReferenceKind → Bool
  | .hand => true
  | .extracted => false

/--
The `compare` payload: a script measured against a reference proof.

`lengthRatio` is nullable and paired with `referenceKind`: it is present exactly when the
reference is a hand proof. Against an extracted reference the record still carries both
derivation sizes and both fragments, which is the coverage comparison that *is* meaningful there.
-/
structure CompareRecord where
  /-- The shared head. Its `stage` should be `.compare`. -/
  head : Head
  /-- Length of the proof-mode script, in tactic invocations. -/
  scriptLength : Nat
  /-- Length of the reference proof, in the same unit. -/
  handProofLength : Nat
  /-- Script length over reference length, scaled by 1000 to stay exact in `Nat`; null when the
  reference is extracted rather than hand-written. -/
  lengthRatioMilli : Option Nat
  /-- Which kind of reference the comparison is against. -/
  referenceKind : ReferenceKind
  /-- Node count of the derivation the script built. -/
  builtDerivationSize : Option Nat
  /-- Node count of the reference derivation. -/
  referenceDerivationSize : Option Nat
  /-- The fragment of the statement. -/
  statementFragment : String
  /-- The fragment the proof actually stays within, which may be larger. -/
  proofFragment : String
  deriving Repr, Inhabited

/--
A `compare` record as one JSON object. `length_ratio` is emitted as a decimal built from
`lengthRatioMilli`, so the figure is exact rather than a float with a rounding story.
-/
def CompareRecord.toJson (r : CompareRecord) : Json :=
  Json.mkObj <| r.head.toJsonFields ++
    [ ("script_length", Json.num (r.scriptLength : Int))
    , ("hand_proof_length", Json.num (r.handProofLength : Int))
    , ("length_ratio", match r.lengthRatioMilli with
        | none => Json.null
        | some m => Json.num ⟨(m : Int), 3⟩)
    , ("reference_kind", Json.str r.referenceKind.key)
    , ("built_derivation_size", optNat r.builtDerivationSize)
    , ("reference_derivation_size", optNat r.referenceDerivationSize)
    , ("statement_fragment", Json.str r.statementFragment)
    , ("proof_fragment", Json.str r.proofFragment) ]

/--
Whether a `compare` record's nullability rule holds: `lengthRatio` is present exactly when the
reference kind admits one.
-/
def CompareRecord.lengthRatioWellFormed (r : CompareRecord) : Bool :=
  r.lengthRatioMilli.isSome == r.referenceKind.admitsLengthRatio

/-- The exact ratio of a script's length to its reference's, scaled by 1000. -/
def lengthRatioMilliOf (scriptLength handProofLength : Nat) : Option Nat :=
  if handProofLength = 0 then none else some (scriptLength * 1000 / handProofLength)

end BimodalLib.Diagnostics
