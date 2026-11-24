/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import BimodalLib.Diagnostics.Emit
import FormalSystem.Automation.ProofMode

/-!
# The diagnostics emitters, in both directions

`#reprove_record` and `#compare_record` have eight `throwError` paths between them, and this file
pins every one with its exact message. The count is not a target: it is
`grep -c 'throwError "' BimodalLib/Diagnostics/Emit.lean`, and a path added there without a row
here is the gap this file exists to prevent.

The eight paths, in the order they appear below:

1. an unknown declaration name (the single `resolveDeclName` gate),
2. a declaration that holds no value to measure (an `axiom`, an `opaque`, a constructor),
3. a stage string outside the closed list,
4. an outcome string outside the closed list,
5. a failure-class string outside the closed list,
6. a reference-kind string outside the closed list,
7. a failure class supplied against an outcome that admits none,
8. a failure class omitted against an outcome that requires one.

Paths 7 and 8 are the schema's nullability rule — `failure_class` is null exactly on
`closed_by_rules` — enforced at the emitter rather than discovered downstream in a collected
record.

Two positive smoke records sit at the top, so that a green run is distinguishable from a run that
emitted nothing at all, and so that the schematic and closed cases are both exercised: a schematic
mirror has no closed instance to evaluate, so its `derivation_size` and `derivation_height` are
null, while a closed mirror reports both. The positive rows pin only the fields that are stable
for a fixed toolchain. Heartbeats and wall-clock milliseconds are deliberately **not** pinned
anywhere: neither is stable across a Lean or Mathlib bump, and a `#guard_msgs` on either would be
a brittle test dressed up as a measurement. The figures live in
`docs/development/proof-mode-cost-baseline.md` instead.
-/

-- Zeroing the two volatile timing fields is what makes a whole record pinnable: everything else
-- in a record is a function of the commit and the toolchain.
set_option diagnostics.zeroTimings true

open FormalSystem.Syntax FormalSystem.ProofSystem

namespace BimodalLibTest.DiagnosticsTest

/-! ### Fixtures

Two atoms and two mirrors: one schematic in its formulas, one closed. A hand-built reference
derivation gives `#compare_record` something real to compare against.
-/

/-- A closed atom, so that a closed mirror can be stated. -/
def p : Formula := .atom ⟨"p", none⟩

/-- A second closed atom. -/
def q : Formula := .atom ⟨"q", none⟩

/-- A schematic mirror: abstracting over its formulas, so it has no closed instance. -/
def schematicMP (A B : Formula) : [A.imp B, A] ⊢ B := by
  lstart hAB hA
  lapply hAB
  lexact hA

/-- A closed mirror of the same script, whose derivation measures can be evaluated. -/
def closedMP : [p.imp q, p] ⊢ q := by
  lstart hAB hA
  lapply hAB
  lexact hA

/-- A hand-built reference derivation of the same judgment. -/
def referenceMP : [p.imp q, p] ⊢ q :=
  .modus_ponens [p.imp q, p] p q
    (.assumption [p.imp q, p] (p.imp q) (by simp))
    (.assumption [p.imp q, p] p (by simp))

/-! ### Positive: one record per implemented stage

The stamp options are unset in a plain `lake build`, so `commit` and `command` read `unstamped`.
That is the point of the sentinel: a record produced without a stamp is identifiable as unstamped
rather than looking like a stamped record whose stamp was lost.
-/

/--
info: {"axioms":["propext"],"command":"unstamped","commit":"unstamped","derivation_height":null,"derivation_size":null,"distinct_tactics":["lstart","lapply","lexact"],"elab_ms":0,"escape_size":0,"failure_class":null,"fragment":"unregistered","frame_class":"Base","heartbeats":0,"outcome":"closed_by_rules","stage":"reprove","statement":"unregistered:BimodalLibTest.DiagnosticsTest.smokeSchematic","tactic_count":3,"term_size":99}
-/
#guard_msgs in
#reprove_record smokeSchematic stage "reprove" outcome "closed_by_rules"
  failure "none" tactics "lstart,lapply,lexact" escape 0 in
def smokeSchematic (A B : Formula) : [A.imp B, A] ⊢ B := by
  lstart hAB hA
  lapply hAB
  lexact hA

/--
info: {"built_derivation_size":3,"command":"unstamped","commit":"unstamped","fragment":"unregistered","frame_class":"Base","hand_proof_length":7,"length_ratio":0.428,"proof_fragment":"unregistered","reference_derivation_size":3,"reference_kind":"hand","script_length":3,"stage":"compare","statement":"unregistered:BimodalLibTest.DiagnosticsTest.closedMP","statement_fragment":"unregistered"}
-/
#guard_msgs in
#compare_record closedMP referenceMP kind "hand" lengths 3 7

-- A length ratio is not meaningful against an extracted reference, and is recorded null.
/--
info: {"built_derivation_size":3,"command":"unstamped","commit":"unstamped","fragment":"unregistered","frame_class":"Base","hand_proof_length":7,"length_ratio":null,"proof_fragment":"unregistered","reference_derivation_size":3,"reference_kind":"extracted","script_length":3,"stage":"compare","statement":"unregistered:BimodalLibTest.DiagnosticsTest.closedMP","statement_fragment":"unregistered"}
-/
#guard_msgs in
#compare_record closedMP referenceMP kind "extracted" lengths 3 7

/-! ### Negative path 1: an unknown declaration name -/

/-- error: diagnostics: unknown declaration `noSuchDeclaration` -/
#guard_msgs in
#compare_record noSuchDeclaration referenceMP kind "hand" lengths 1 1

/-! ### Negative path 2: a declaration that holds no value -/

-- `Nat` is an inductive type, so the constant is in the environment and holds no value. A fixture
-- `axiom` would do as well, but it would also add a row to this repository's own axiom census,
-- which is exactly the kind of drift the audit module next door exists to catch.
/-- error: diagnostics: declaration `Nat` has no value to measure -/
#guard_msgs in
#compare_record Nat referenceMP kind "hand" lengths 1 1

/-! ### Negative path 3: a stage outside the closed list -/

/--
error: diagnostics: `bogus_stage` is not a stage; expected one of [enumerate,
 decide,
 extract,
 certify,
 admit,
 reprove,
 compare]
-/
#guard_msgs in
#reprove_record closedMP stage "bogus_stage" outcome "closed_by_rules"
  failure "none" tactics "lexact" escape 0 in
def unreachedByBadStage : Nat := 1

/-! ### Negative path 4: an outcome outside the closed list -/

/--
error: diagnostics: `bogus_outcome` is not an outcome; expected one of [closed_by_rules,
 closed_with_leaf_automation,
 closed_with_term_escape,
 not_closed]
-/
#guard_msgs in
#reprove_record closedMP stage "reprove" outcome "bogus_outcome"
  failure "none" tactics "lexact" escape 0 in
def unreachedByBadOutcome : Nat := 1

/-! ### Negative path 5: a failure class outside the closed list -/

/--
error: diagnostics: `bogus_failure` is not a failure class; expected `none` or one of [missing_rule,
 missing_tactic,
 automation_too_weak,
 script_too_awkward,
 too_slow,
 defect_in_mode]
-/
#guard_msgs in
#reprove_record closedMP stage "reprove" outcome "not_closed"
  failure "bogus_failure" tactics "lexact" escape 0 in
def unreachedByBadFailure : Nat := 1

/-! ### Negative path 6: a reference kind outside the closed list -/

/-- error: diagnostics: `bogus_kind` is not a reference kind; expected one of [hand, extracted] -/
#guard_msgs in
#compare_record closedMP referenceMP kind "bogus_kind" lengths 1 1

/-! ### Negative path 7: a failure class against an outcome that admits none -/

/--
error: diagnostics: outcome `closed_by_rules` admits no failure class, but `too_slow` was given
-/
#guard_msgs in
#reprove_record closedMP stage "reprove" outcome "closed_by_rules"
  failure "too_slow" tactics "lexact" escape 0 in
def unreachedBySurplusFailure : Nat := 1

/-! ### Negative path 8: no failure class against an outcome that requires one -/

/--
error: diagnostics: outcome `not_closed` requires a failure class, but `none` was given
-/
#guard_msgs in
#reprove_record closedMP stage "reprove" outcome "not_closed"
  failure "none" tactics "lexact" escape 0 in
def unreachedByMissingFailure : Nat := 1

/-! ### The reserved stages are reserved, not empty

A record schema whose unimplemented stages carry no field list is a gap rather than a
reservation, so the five reserved stages' key lists are asserted here too: the tableau pipeline
builds against these names.
-/

/-- info: true -/
#guard_msgs in
#eval BimodalLib.Diagnostics.Stage.all.length == 7

/-- info: true -/
#guard_msgs in
#eval (BimodalLib.Diagnostics.Stage.all.filter
  (fun s => BimodalLib.Diagnostics.Stage.isImplemented s)).length == 2

/-- info: true -/
#guard_msgs in
#eval BimodalLib.Diagnostics.Stage.all.all
  (fun s => !(BimodalLib.Diagnostics.Stage.reservedKeys s).isEmpty)

/-- info: true -/
#guard_msgs in
#eval BimodalLib.Diagnostics.Stage.all.all
  (fun s => BimodalLib.Diagnostics.Stage.ofKey? (BimodalLib.Diagnostics.Stage.key s) == some s)

end BimodalLibTest.DiagnosticsTest
