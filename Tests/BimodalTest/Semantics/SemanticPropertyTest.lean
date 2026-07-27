/-
Copyright (c) 2025 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.TaskFrame
import FormalSystem.Semantics.TaskModel
import FormalSystem.Semantics.Truth
import BimodalTest.Property.Generators
import Plausible

/-!
# Semantic Property Tests

Property-based tests for semantic properties of task frames and models.

## Properties Tested

- Frame nullity: ∀ w, task_rel w 0 w
- Frame compositionality: task composition with time addition
- Truth evaluation determinism
- Frame properties hold by construction

## Implementation Notes

TaskFrame properties (nullity, compositionality) are enforced by the
structure definition, so these tests verify the generators produce
valid frames.

## References

* [TaskFrame.lean](../../../Logos/Core/Semantics/TaskFrame.lean)
* [Truth.lean](../../../Logos/Core/Semantics/Truth.lean)
-/


namespace BimodalTest.Semantics.SemanticPropertyTest

open FormalSystem.Syntax
open FormalSystem.Semantics
open BimodalTest.Property.Generators
open Plausible

/-! ## TaskFrame Properties -/

/-!
Property: Frame nullity holds for all frames.

For any frame F and world w, task_rel w 0 w.
This is enforced by the TaskFrame structure.
-/
def frame_nullity_property (F : TaskFrame Int) (w : F.WorldState) :
    F.TaskRel w 0 w :=
  F.nullity w

/-!
Test: Frame nullity (verifies generator produces valid frames).
-/
example : ∀ (F : TaskFrame Int) (w : F.WorldState), F.TaskRel w 0 w := by
  intro F w
  exact F.nullity w

/-!
Property: Frame compositionality holds for all frames.

If task_rel w x u and task_rel u y v, then task_rel w (x+y) v.
This is enforced by the TaskFrame structure.
-/
-- NOTE (Task 365): `compositionality` was replaced by `forward_comp`, which is restricted to
-- non-negative durations (`0 ≤ x`, `0 ≤ y`) — the unrestricted mixed-sign law is no longer a
-- frame property. Added the non-negativity hypotheses to match the current structure.
def frame_compositionality_property (F : TaskFrame Int)
    (w u v : F.WorldState) (x y : Int) (hx : 0 ≤ x) (hy : 0 ≤ y)
    (h1 : F.TaskRel w x u) (h2 : F.TaskRel u y v) :
    F.TaskRel w (x + y) v :=
  F.forward_comp w u v x y hx hy h1 h2

/-!
Test: Frame compositionality (verifies generator produces valid frames).
-/
example : ∀ (F : TaskFrame Int) (w u v : F.WorldState) (x y : Int),
    0 ≤ x → 0 ≤ y → F.TaskRel w x u → F.TaskRel u y v → F.TaskRel w (x + y) v := by
  intro F w u v x y hx hy h1 h2
  exact F.forward_comp w u v x y hx hy h1 h2

/-! ## Trivial Frame Properties -/

/-!
Property: Trivial frame has Unit world states.
-/
example : (TaskFrame.trivialFrame (D := Int)).WorldState = Unit := by
  rfl

/-!
Property: Trivial frame task relation is always true.
-/
example (w u : Unit) (x : Int) :
    (TaskFrame.trivialFrame (D := Int)).TaskRel w x u := by
  trivial

/-! ## Identity Frame Properties -/

/-!
Property: Identity frame task relation requires w = u and x = 0.
-/
example (W : Type) (w u : W) (x : Int) :
    (TaskFrame.identityFrame W (D := Int)).TaskRel w x u ↔ w = u ∧ x = 0 := by
  rfl

/-! ## Nat Frame Properties -/

/-!
Property: Nat frame has Nat world states.
-/
example : (TaskFrame.natFrame (D := Int)).WorldState = Nat := by
  rfl

/-!
Property: Nat frame task relation is permissive.
-/
-- NOTE (Task 365): quarantined — under the current `nat_frame`, `task_rel w x u` is
-- `x ≠ 0 ∨ w = u`, so it is NOT universally permissive (fails when `x = 0 ∧ w ≠ u`). The old
-- unconditional-permissiveness claim is no longer true.
-- example (w u : Nat) (x : Int) :
--     (TaskFrame.nat_frame (D := Int)).task_rel w x u := by
--   trivial

/-! ## Time Addition Properties -/

/-!
Property: Zero is identity for time addition.

For any time x, x + 0 = x.
-/
-- (Task 365) quarantined: bare `∀` no longer carries a `Testable` instance
-- (Plausible now requires `NamedBinder` decoration). The `#eval Testable.check`
-- below exercises the same property at runtime.
-- example : Testable (∀ x : Int, x + 0 = x) := by
--   infer_instance

/-!
Test: Zero is right identity (100 test cases).
-/
#eval Testable.check (∀ x : Int, x + 0 = x) {
  numInst := 100
}

/-!
Property: Time addition is associative.
-/
-- (Task 365) quarantined: bare `∀` no longer carries a `Testable` instance
-- (Plausible now requires `NamedBinder` decoration). The `#eval Testable.check`
-- below exercises the same property at runtime.
-- example : Testable (∀ x y z : Int, (x + y) + z = x + (y + z)) := by
--   infer_instance

/-!
Test: Time addition associativity (100 test cases).
-/
#eval Testable.check (∀ x y z : Int, (x + y) + z = x + (y + z)) {
  numInst := 100
}

/-!
Property: Time addition is commutative.
-/
-- (Task 365) quarantined: bare `∀` no longer carries a `Testable` instance
-- (Plausible now requires `NamedBinder` decoration). The `#eval Testable.check`
-- below exercises the same property at runtime.
-- example : Testable (∀ x y : Int, x + y = y + x) := by
--   infer_instance

/-!
Test: Time addition commutativity (100 test cases).
-/
#eval Testable.check (∀ x y : Int, x + y = y + x) {
  numInst := 100
}

/-! ## Time Ordering Properties -/

/-!
Property: Time ordering is transitive.
-/
-- (Task 365) quarantined: bare `∀` no longer carries a `Testable` instance
-- (Plausible now requires `NamedBinder` decoration). The `#eval Testable.check`
-- below exercises the same property at runtime.
-- example : Testable (∀ x y z : Int, x < y → y < z → x < z) := by
--   infer_instance

/-!
Test: Time ordering transitivity (100 test cases).
-/
#eval Testable.check (∀ x y z : Int, x < y → y < z → x < z) {
  numInst := 100
}

/-!
Property: Time ordering is irreflexive.
-/
-- (Task 365) quarantined: bare `∀` no longer carries a `Testable` instance
-- (Plausible now requires `NamedBinder` decoration). The `#eval Testable.check`
-- below exercises the same property at runtime.
-- example : Testable (∀ x : Int, ¬(x < x)) := by
--   infer_instance

/-!
Test: Time ordering irreflexivity (100 test cases).
-/
#eval Testable.check (∀ x : Int, ¬(x < x)) {
  numInst := 100
}

/-!
Property: Time ordering is total.
-/
-- (Task 365) quarantined: bare `∀` no longer carries a `Testable` instance
-- (Plausible now requires `NamedBinder` decoration). The `#eval Testable.check`
-- below exercises the same property at runtime.
-- example : Testable (∀ x y : Int, x < y ∨ x = y ∨ y < x) := by
--   infer_instance

/-!
Test: Time ordering totality (100 test cases).
-/
#eval Testable.check (∀ x y : Int, x < y ∨ x = y ∨ y < x) {
  numInst := 100
}

/-! ## Frame Construction Properties -/

/-!
Property: All constructed frames satisfy nullity.

This is a meta-property: any frame we can construct must satisfy nullity
because it's required by the structure definition.
-/
example (F : TaskFrame Int) : ∀ w, F.TaskRel w 0 w := by
  intro w
  exact F.nullity w

/-!
Property: All constructed frames satisfy compositionality.
-/
example (F : TaskFrame Int) :
    ∀ w u v x y, 0 ≤ x → 0 ≤ y → F.TaskRel w x u → F.TaskRel u y v → F.TaskRel w (x + y) v := by
  intro w u v x y hx hy h1 h2
  exact F.forward_comp w u v x y hx hy h1 h2

/-! ## TaskModel Properties -/

/-!
Property: TaskModel valuation is well-defined for all worlds and atoms.

The valuation function always returns a Prop (decidable truth value).
-/
example : ∀ (M : TaskModel (TaskFrame.natFrame (D := Int))) (w : Nat) (s : Atom),
    M.valuation w s ∨ ¬M.valuation w s := by
  intro M w s
  by_cases h : M.valuation w s
  · left; exact h
  · right; exact h

/-!
Property: Generated TaskModels have the correct frame.

The frame of a generated model is nat_frame.
-/
-- NOTE (Task 365): quarantined — `TaskModel` has no `.frame` projection (the frame is a
-- structure parameter `F`, not a field), and the `where frame (M) := F` helper referenced an
-- out-of-scope `F`. The property as stated is not expressible against the current `TaskModel`.
-- example : ∀ (M : TaskModel (TaskFrame.nat_frame (D := Int))),
--     M.frame = TaskFrame.nat_frame := by
--   intro M
--   rfl

/-!
Property: All-false model has no atoms true.
-/
example : ∀ (w : Nat) (s : Atom),
    ¬(TaskModel.allFalse (F := TaskFrame.natFrame (D := Int))).valuation w s := by
  intro w s
  exact id

/-!
Property: All-true model has all atoms true.
-/
example : ∀ (w : Nat) (s : Atom),
    (TaskModel.allTrue (F := TaskFrame.natFrame (D := Int))).valuation w s := by
  intro w s
  trivial

/-! ## Truth Condition Properties -/

/-!
Property: Bot is always false at any world in any model.

This is a fundamental semantic property.
-/
-- Note: We would need to import Truth evaluation to test this properly
-- Placeholder for when Truth.lean is available with decidable instances

/-! ## Frame Constraint Tests with Larger Test Counts -/

-- NOTE (Task 365): quarantined — these `#eval Testable.check` properties quantify over
-- `w : F.WorldState` for an abstract generated `F`, so Plausible cannot synthesize a
-- `SampleableExt` for the dependent, abstract world-state type. (The second also asserted the
-- now-restricted mixed-sign compositionality law.) The corresponding closed proofs above cover
-- these frame constraints.
-- #eval Testable.check (∀ (F : TaskFrame Int) (w : F.WorldState), F.task_rel w 0 w) {
--   numInst := 200,
--   maxSize := 25
-- }
-- #eval Testable.check (∀ (F : TaskFrame Int) (w u v : F.WorldState) (x y : Int),
--     F.task_rel w x u → F.task_rel u y v → F.task_rel w (x + y) v) {
--   numInst := 200,
--   maxSize := 25
-- }

end BimodalTest.Semantics.SemanticPropertyTest
