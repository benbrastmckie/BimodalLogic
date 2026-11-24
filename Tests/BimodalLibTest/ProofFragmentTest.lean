/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import BimodalLib.ProofFragment
import BimodalLibTest.Fixtures.UnrecordedProofFragment
import FormalSystem.Theorems.Combinators

/-!
# Tests of the proof-fragment check

The check is aimed at the fixture module, which registers one theorem whose statement is in
Until alone and whose derivation passes through `□`. It must fail and name the theorem. A reason
is then recorded here, and the same check must pass. A reason recorded for a theorem whose proof
stays inside the cell of its statement must make the check fail again.
-/

/-! ### The check fails on a proof outside its cell with no reason -/

/--
info: 1 registered theorems; 1 have a proof outside the cell of the statement
---
error: 1 registered theorem(s) have a proof outside the cell of the statement and no reason; add a `record_proof_fragment` line for each:
  BimodalLibTest.Fixtures.nextThroughBox (statement cell: U, S; proof profile: □, U, S; at Base)
-/
#guard_msgs in
assert_proof_fragments_recorded

/-! ### It passes once a reason is recorded -/

record_proof_fragment BimodalLibTest.Fixtures.nextThroughBox "The fixture derives it through □."

/--
info: 1 registered theorems; 1 have a proof outside the cell of the statement
-/
#guard_msgs in
assert_proof_fragments_recorded

/-! ### A reason for a theorem with no row is refused -/

/--
error: record_proof_fragment: FormalSystem.Theorems.Combinators.identity has no registry row
-/
#guard_msgs in
record_proof_fragment FormalSystem.Theorems.Combinators.identity "No row."

/-! ### A reason for a proof that stays inside its cell is reported -/

register_theorem FormalSystem.Theorems.Combinators.identity
record_proof_fragment FormalSystem.Theorems.Combinators.identity "Not needed."

/--
info: 2 registered theorems; 1 have a proof outside the cell of the statement
---
error: 1 recorded reason(s) are for a theorem whose proof stays inside the cell of its statement; remove the `record_proof_fragment` line of each:
  FormalSystem.Theorems.Combinators.identity
-/
#guard_msgs in
assert_proof_fragments_recorded

/-! ### A proved edge out of the statement cell is a reason by itself -/

open BimodalLib in
#guard (ProofFragmentRow.listed
  { decl := `x, frameClass := "Base", statement := {}, proof := some { box := true } }) == true
open BimodalLib in
#guard (ProofFragmentRow.listed
  { decl := `x, frameClass := "Base", statement := { box := true }, proof := some {} }) == false
open BimodalLib in
#guard (ProofFragmentRow.listed
  { decl := `x, frameClass := "Base", statement := {}, proof := none }) == true

open Lean Meta BimodalLib in
run_meta do
  let edges ← provedCellEdges
  let r : ProofFragmentRow :=
    { decl := `BimodalLibTest.noSuchRow, frameClass := "Dense", statement := { box := true },
      proof := some { box := true, temporal := true } }
  let some reason ← proofFragmentReason? edges r
    | throwError "no proved edge was found for the cell with □"
  unless (reason.splitOn "BimodalLib.conservativeEdge_box").length > 1 do
    throwError "the reason does not name the edge theorem: {reason}"
  let t : ProofFragmentRow := { r with statement := { temporal := true } }
  if (← proofFragmentReason? edges t).isSome then
    throwError "a reason was found for the temporal cell, whose edge is not proved"
