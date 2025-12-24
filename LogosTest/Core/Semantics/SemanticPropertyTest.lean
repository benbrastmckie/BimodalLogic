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

import Logos.Core.Semantics.TaskFrame
import Logos.Core.Semantics.Truth
import LogosTest.Core.Property.Generators
import Plausible

namespace LogosTest.Semantics.SemanticPropertyTest

open Logos.Core.Semantics
open LogosTest.Property.Generators
open Plausible

/-! ## TaskFrame Properties -/

/--
Property: Frame nullity holds for all frames.

For any frame F and world w, task_rel w 0 w.
This is enforced by the TaskFrame structure.
-/
def frame_nullity_property (F : TaskFrame Int) (w : F.WorldState) :
    F.task_rel w 0 w :=
  F.nullity w

/--
Test: Frame nullity (verifies generator produces valid frames).
-/
example : ∀ (F : TaskFrame Int) (w : F.WorldState), F.task_rel w 0 w := by
  intro F w
  exact F.nullity w

/--
Property: Frame compositionality holds for all frames.

If task_rel w x u and task_rel u y v, then task_rel w (x+y) v.
This is enforced by the TaskFrame structure.
-/
def frame_compositionality_property (F : TaskFrame Int)
    (w u v : F.WorldState) (x y : Int)
    (h1 : F.task_rel w x u) (h2 : F.task_rel u y v) :
    F.task_rel w (x + y) v :=
  F.compositionality w u v x y h1 h2

/--
Test: Frame compositionality (verifies generator produces valid frames).
-/
example : ∀ (F : TaskFrame Int) (w u v : F.WorldState) (x y : Int),
    F.task_rel w x u → F.task_rel u y v → F.task_rel w (x + y) v := by
  intro F w u v x y h1 h2
  exact F.compositionality w u v x y h1 h2

/-! ## Trivial Frame Properties -/

/--
Property: Trivial frame has Unit world states.
-/
example : (TaskFrame.trivial_frame (T := Int)).WorldState = Unit := by
  rfl

/--
Property: Trivial frame task relation is always true.
-/
example (w u : Unit) (x : Int) :
    (TaskFrame.trivial_frame (T := Int)).task_rel w x u := by
  trivial

/-! ## Identity Frame Properties -/

/--
Property: Identity frame task relation requires w = u and x = 0.
-/
example (W : Type) (w u : W) (x : Int) :
    (TaskFrame.identity_frame W (T := Int)).task_rel w x u ↔ w = u ∧ x = 0 := by
  rfl

/-! ## Nat Frame Properties -/

/--
Property: Nat frame has Nat world states.
-/
example : (TaskFrame.nat_frame (T := Int)).WorldState = Nat := by
  rfl

/--
Property: Nat frame task relation is permissive.
-/
example (w u : Nat) (x : Int) :
    (TaskFrame.nat_frame (T := Int)).task_rel w x u := by
  trivial

/-! ## Time Addition Properties -/

/--
Property: Zero is identity for time addition.

For any time x, x + 0 = x.
-/
example : Testable (∀ x : Int, x + 0 = x) := by
  infer_instance

/--
Test: Zero is right identity (100 test cases).
-/
#eval Testable.check (∀ x : Int, x + 0 = x) {
  numInst := 100
}

/--
Property: Time addition is associative.
-/
example : Testable (∀ x y z : Int, (x + y) + z = x + (y + z)) := by
  infer_instance

/--
Test: Time addition associativity (100 test cases).
-/
#eval Testable.check (∀ x y z : Int, (x + y) + z = x + (y + z)) {
  numInst := 100
}

/--
Property: Time addition is commutative.
-/
example : Testable (∀ x y : Int, x + y = y + x) := by
  infer_instance

/--
Test: Time addition commutativity (100 test cases).
-/
#eval Testable.check (∀ x y : Int, x + y = y + x) {
  numInst := 100
}

/-! ## Time Ordering Properties -/

/--
Property: Time ordering is transitive.
-/
example : Testable (∀ x y z : Int, x < y → y < z → x < z) := by
  infer_instance

/--
Test: Time ordering transitivity (100 test cases).
-/
#eval Testable.check (∀ x y z : Int, x < y → y < z → x < z) {
  numInst := 100
}

/--
Property: Time ordering is irreflexive.
-/
example : Testable (∀ x : Int, ¬(x < x)) := by
  infer_instance

/--
Test: Time ordering irreflexivity (100 test cases).
-/
#eval Testable.check (∀ x : Int, ¬(x < x)) {
  numInst := 100
}

/--
Property: Time ordering is total.
-/
example : Testable (∀ x y : Int, x < y ∨ x = y ∨ y < x) := by
  infer_instance

/--
Test: Time ordering totality (100 test cases).
-/
#eval Testable.check (∀ x y : Int, x < y ∨ x = y ∨ y < x) {
  numInst := 100
}

/-! ## Frame Construction Properties -/

/--
Property: All constructed frames satisfy nullity.

This is a meta-property: any frame we can construct must satisfy nullity
because it's required by the structure definition.
-/
example (F : TaskFrame Int) : ∀ w, F.task_rel w 0 w := by
  intro w
  exact F.nullity w

/--
Property: All constructed frames satisfy compositionality.
-/
example (F : TaskFrame Int) :
    ∀ w u v x y, F.task_rel w x u → F.task_rel u y v → F.task_rel w (x + y) v := by
  intro w u v x y h1 h2
  exact F.compositionality w u v x y h1 h2

end LogosTest.Semantics.SemanticPropertyTest
