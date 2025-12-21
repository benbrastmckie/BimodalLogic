import Mathlib.Algebra.Order.Group.Int
import Logos.Core.Semantics.TaskFrame

/-!
# TaskFrame Tests

Tests for task frame structure and constraints.

## Temporal Type Note

After the temporal generalization, TaskFrame now takes a type parameter `T`
with `LinearOrderedAddCommGroup` constraint. Tests use explicit `Int` annotations
to specify the temporal type.
-/

namespace LogosTest.Core.Semantics

open Logos.Core.Semantics

/-! ## trivial_frame Tests (using Int time) -/

-- Test: trivial_frame satisfies nullity
example : (TaskFrame.trivial_frame (T := Int)).task_rel () 0 () :=
  (TaskFrame.trivial_frame (T := Int)).nullity ()

-- Test: trivial_frame satisfies compositionality (task relation is always true)
example : (TaskFrame.trivial_frame (T := Int)).task_rel () 5 () := trivial

-- Test: trivial_frame with negative duration
example : (TaskFrame.trivial_frame (T := Int)).task_rel () (-3) () := trivial

/-! ## identity_frame Tests -/

-- Test: identity_frame satisfies nullity (with explicit type annotation)
example : (TaskFrame.identity_frame Nat (T := Int)).task_rel (3 : Nat) 0 (3 : Nat) :=
  (TaskFrame.identity_frame Nat (T := Int)).nullity (3 : Nat)

/-! ## nat_frame Tests (using Int time) -/

-- Test: nat_frame satisfies nullity
example : (TaskFrame.nat_frame (T := Int)).task_rel (5 : Nat) 0 (5 : Nat) :=
  (TaskFrame.nat_frame (T := Int)).nullity (5 : Nat)

-- Test: nat_frame with non-zero duration (task relation always true)
example : (TaskFrame.nat_frame (T := Int)).task_rel (0 : Nat) 10 (42 : Nat) := trivial

/-! ## Custom Frame Tests -/

-- Test: Construct custom simple task frame with explicit Int time
def customFrame : TaskFrame Int where
  WorldState := Bool
  task_rel := fun _ _ _ => True
  nullity := fun _ => trivial
  compositionality := fun _ _ _ _ _ _ _ => trivial

-- Test: Custom frame satisfies properties
example : customFrame.task_rel true 0 true := customFrame.nullity true
example : customFrame.task_rel false 5 true := trivial

/-! ## Polymorphism Tests -/

-- Test: TaskFrame can be instantiated with Int explicitly
example : TaskFrame Int := TaskFrame.trivial_frame

-- Test: Nullity constraint works with explicit type
theorem nullity_test_int : (TaskFrame.trivial_frame (T := Int)).task_rel () 0 () :=
  TaskFrame.trivial_frame.nullity ()

-- Test: Compositionality with Int time (1 + 2 = 3)
theorem compositionality_test_int :
    (TaskFrame.trivial_frame (T := Int)).task_rel () 3 () := by
  show (TaskFrame.trivial_frame (T := Int)).task_rel () ((1 : Int) + (2 : Int)) ()
  exact (TaskFrame.trivial_frame (T := Int)).compositionality () () () 1 2
    ((TaskFrame.trivial_frame (T := Int)).nullity ())
    ((TaskFrame.trivial_frame (T := Int)).nullity ())

end LogosTest.Core.Semantics
