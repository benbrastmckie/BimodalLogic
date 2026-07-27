/-
Copyright (c) 2025 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import Mathlib.Algebra.Order.Group.Int
import FormalSystem.Semantics.TaskFrame

/-!
# TaskFrame Tests

Tests for task frame structure and constraints.

## Temporal Type Note

After the temporal generalization, TaskFrame now takes a type parameter `T`
with `LinearOrderedAddCommGroup` constraint. Tests use explicit `Int` annotations
to specify the temporal type.
-/

namespace BimodalTest.Semantics

open FormalSystem.Semantics

/-! ## trivial_frame Tests (using Int time) -/

-- Test: trivial_frame satisfies nullity
example : (TaskFrame.trivial_frame (D := Int)).task_rel () 0 () :=
  (TaskFrame.trivial_frame (D := Int)).nullity ()

-- Test: trivial_frame satisfies compositionality (task relation is always true)
example : (TaskFrame.trivial_frame (D := Int)).task_rel () 5 () := trivial

-- Test: trivial_frame with negative duration
example : (TaskFrame.trivial_frame (D := Int)).task_rel () (-3) () := trivial

/-! ## identity_frame Tests -/

-- Test: identity_frame satisfies nullity (with explicit type annotation)
example : (TaskFrame.identity_frame Nat (D := Int)).task_rel (3 : Nat) 0 (3 : Nat) :=
  (TaskFrame.identity_frame Nat (D := Int)).nullity (3 : Nat)

/-! ## nat_frame Tests (using Int time) -/

-- Test: nat_frame satisfies nullity
example : (TaskFrame.nat_frame (D := Int)).task_rel (5 : Nat) 0 (5 : Nat) :=
  (TaskFrame.nat_frame (D := Int)).nullity (5 : Nat)

-- Test: nat_frame with non-zero duration (task relation always true)
example : (TaskFrame.nat_frame (D := Int)).task_rel (0 : Nat) 10 (42 : Nat) := Or.inl (by decide)

/-! ## Custom Frame Tests -/

-- Test: Construct custom simple task frame with explicit Int time
def customFrame : TaskFrame Int where
  WorldState := Bool
  -- Permissive within non-zero durations; identity at zero duration (mirrors `nat_frame`).
  task_rel := fun w d u => d ≠ 0 ∨ w = u
  nullity_identity := fun w u => by
    constructor
    · intro h
      cases h with
      | inl h => exact absurd rfl h
      | inr h => exact h
    · intro h; right; exact h
  forward_comp := fun w u v x y hx hy h1 h2 => by
    cases h1 with
    | inl hxne =>
      left; intro heq
      have hy_eq : y = -x := (neg_eq_of_add_eq_zero_right heq).symm
      have h1 : 0 ≤ -x := hy_eq ▸ hy
      have h2 : x ≤ 0 := neg_nonneg.mp h1
      exact hxne (le_antisymm h2 hx)
    | inr hw =>
      cases h2 with
      | inl hyne =>
        left; intro heq
        have hx_eq : x = -y := (neg_eq_of_add_eq_zero_left heq).symm
        have h1 : 0 ≤ -y := hx_eq ▸ hx
        have h2 : y ≤ 0 := neg_nonneg.mp h1
        exact hyne (le_antisymm h2 hy)
      | inr hu => right; exact hw.trans hu
  converse := fun w d u => by
    constructor
    · intro h
      cases h with
      | inl hd => left; simp [hd]
      | inr heq => right; exact heq.symm
    · intro h
      cases h with
      | inl hnd => left; simp at hnd; exact hnd
      | inr heq => right; exact heq.symm

-- Test: Custom frame satisfies properties
example : customFrame.task_rel true 0 true := customFrame.nullity true
example : customFrame.task_rel false 5 true := Or.inl (by decide)

/-! ## Polymorphism Tests -/

-- Test: TaskFrame can be instantiated with Int explicitly
example : TaskFrame Int := TaskFrame.trivial_frame

-- Test: Nullity constraint works with explicit type
theorem nullity_test_int : (TaskFrame.trivial_frame (D := Int)).task_rel () 0 () :=
  TaskFrame.trivial_frame.nullity ()

-- Test: Compositionality with Int time (1 + 2 = 3)
theorem compositionality_test_int :
    (TaskFrame.trivial_frame (D := Int)).task_rel () 3 () := by
  -- trivial_frame's task_rel is `True`; forward_comp now also requires 0 ≤ x, 0 ≤ y
  exact (TaskFrame.trivial_frame (D := Int)).forward_comp () () () 1 2 (by decide) (by decide)
    ((TaskFrame.trivial_frame (D := Int)).nullity ())
    ((TaskFrame.trivial_frame (D := Int)).nullity ())

end BimodalTest.Semantics
