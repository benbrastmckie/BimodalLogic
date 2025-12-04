import Mathlib.Algebra.Order.Group.Int
import Logos.Semantics.TaskFrame

/-!
# TaskFrame Tests

Tests for task frame structure and constraints.

## Temporal Type Note

After the temporal generalization, TaskFrame now takes a type parameter `T`
with `LinearOrderedAddCommGroup` constraint. Tests use explicit `Int` annotations
to specify the temporal type.
-/

namespace LogosTest.Semantics

open Logos.Semantics

/-! ## trivialFrame Tests (using Int time) -/

-- Test: trivialFrame satisfies nullity
example : (TaskFrame.trivialFrame (T := Int)).task_rel () 0 () :=
  (TaskFrame.trivialFrame (T := Int)).nullity ()

-- Test: trivialFrame satisfies compositionality (task relation is always true)
example : (TaskFrame.trivialFrame (T := Int)).task_rel () 5 () := trivial

-- Test: trivialFrame with negative duration
example : (TaskFrame.trivialFrame (T := Int)).task_rel () (-3) () := trivial

/-! ## identityFrame Tests -/

-- Test: identityFrame satisfies nullity (with explicit type annotation)
example : (TaskFrame.identityFrame Nat (T := Int)).task_rel (3 : Nat) 0 (3 : Nat) :=
  (TaskFrame.identityFrame Nat (T := Int)).nullity (3 : Nat)

/-! ## natFrame Tests (using Int time) -/

-- Test: natFrame satisfies nullity
example : (TaskFrame.natFrame (T := Int)).task_rel (5 : Nat) 0 (5 : Nat) :=
  (TaskFrame.natFrame (T := Int)).nullity (5 : Nat)

-- Test: natFrame with non-zero duration (task relation always true)
example : (TaskFrame.natFrame (T := Int)).task_rel (0 : Nat) 10 (42 : Nat) := trivial

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
example : TaskFrame Int := TaskFrame.trivialFrame

-- Test: Nullity constraint works with explicit type
theorem nullity_test_int : (TaskFrame.trivialFrame (T := Int)).task_rel () 0 () :=
  TaskFrame.trivialFrame.nullity ()

-- Test: Compositionality with Int time (1 + 2 = 3)
theorem compositionality_test_int :
    (TaskFrame.trivialFrame (T := Int)).task_rel () 3 () := by
  show (TaskFrame.trivialFrame (T := Int)).task_rel () ((1 : Int) + (2 : Int)) ()
  exact (TaskFrame.trivialFrame (T := Int)).compositionality () () () 1 2
    ((TaskFrame.trivialFrame (T := Int)).nullity ())
    ((TaskFrame.trivialFrame (T := Int)).nullity ())

end LogosTest.Semantics
