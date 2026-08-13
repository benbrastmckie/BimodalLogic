/-
Copyright (c) 2025 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import Mathlib.Algebra.Order.Group.Int
import Mathlib.Data.Int.SuccPred
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

/-! ## trivialFrame Tests (using Int time) -/

-- Test: trivialFrame satisfies nullity
example : (TaskFrame.trivialFrame (D := Int)).TaskRel () 0 () :=
  (TaskFrame.trivialFrame (D := Int)).nullity ()

-- Test: trivialFrame satisfies compositionality (task relation is always true)
example : (TaskFrame.trivialFrame (D := Int)).TaskRel () 5 () := trivial

-- Test: trivialFrame with negative duration
example : (TaskFrame.trivialFrame (D := Int)).TaskRel () (-3) () := trivial

/-! ## staticFrame Tests -/

-- Test: staticFrame satisfies nullity (with explicit type annotation)
example : (TaskFrame.staticFrame Nat (D := Int)).TaskRel (3 : Nat) 0 (3 : Nat) :=
  (TaskFrame.staticFrame Nat (D := Int)).nullity (3 : Nat)

-- Test: staticFrame is reflexive at every duration (the Seriality witness), unlike the
-- former zero-duration-only identity frame it replaces
example : (TaskFrame.staticFrame Nat (D := Int)).TaskRel (3 : Nat) 7 (3 : Nat) := rfl

/-! ## natFrame Tests (using Int time) -/

-- Test: natFrame satisfies nullity
example : (TaskFrame.natFrame (D := Int)).TaskRel (5 : Nat) 0 (5 : Nat) :=
  (TaskFrame.natFrame (D := Int)).nullity (5 : Nat)

-- Test: natFrame with non-zero duration (task relation always true)
example : (TaskFrame.natFrame (D := Int)).TaskRel (0 : Nat) 10 (42 : Nat) := Or.inl (by decide)

/-! ## Custom Frame Tests -/

-- Test: Construct custom simple task frame with explicit Int time
def customFrame : TaskFrame Int where
  WorldState := Bool
  -- Permissive within non-zero durations; identity at zero duration (mirrors `natFrame`).
  TaskRel := fun w d u => d ≠ 0 ∨ w = u
  nullity_identity := fun w u => by
    constructor
    · intro h
      cases h with
      | inl h => exact absurd rfl h
      | inr h => exact h
    · intro h; right; exact h
  comp := TaskFrame.comp_of (TaskFrame.interpolates_of_permissive fun _ _ _ => Iff.rfl)
    fun w u v x y hx hy h1 h2 => by
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
  serial := TaskFrame.serial_of_permissive fun _ _ _ => Iff.rfl
  limit := TaskFrame.limit_of_permissive fun _ _ _ => Iff.rfl
  spherical := TaskFrame.spherical_of_permissive fun _ _ _ => Iff.rfl
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
example : customFrame.TaskRel true 0 true := customFrame.nullity true
example : customFrame.TaskRel false 5 true := Or.inl (by decide)

/-! ### `customFrame` discharges `def:frame`'s four axioms (permissive class) -/

/-- `customFrame`'s relation is the permissive class, the same class as `natFrame`'s. -/
theorem customFrame_rel_iff :
    ∀ w d u, customFrame.TaskRel w d u ↔ (d ≠ 0 ∨ w = u) := fun _ _ _ => Iff.rfl

/-- *Seriality* (`def:frame#Seriality`, verbatim: "$w \Rightarrow_x u$ and $v \Rightarrow_x w$
for some $u, v \in W$") for `customFrame`. -/
theorem customFrame_serial : TaskFrame.Serial customFrame.TaskRel :=
  TaskFrame.serial_of_permissive customFrame_rel_iff

/-- The interpolation half of *Compositionality* (`def:frame#Compositionality`, verbatim:
"$w \Rightarrow_{x + y} v$ if and only if $w \Rightarrow_x u$ and $u \Rightarrow_y v$ for some
$u \in W$") for `customFrame`. -/
theorem customFrame_interpolates : TaskFrame.Interpolates customFrame.TaskRel :=
  TaskFrame.interpolates_of_permissive customFrame_rel_iff

/-- *Limit* (`def:frame#Limit`, verbatim: "$\bigcap\limits_{x > 0} (w)_x = \set{w}$") for
`customFrame`, in the literal transcribed shape. The duration type is `Int`, which supplies the
`SuccOrder` / `NoMaxOrder` instances the permissive class needs, so no binder change is
required here. -/
theorem customFrame_limit :
    ∀ w u, (∀ x : Int, 0 < x → ∃ y, |y| < x ∧ customFrame.TaskRel w y u) → u = w :=
  TaskFrame.limit_of_permissive customFrame_rel_iff

/-- *Spherical* (`def:frame#Spherical`, verbatim: "$\bigcap \mathcal{S} \neq \emptyset$ for any
directed family $\mathcal{S}$ of nonempty fibers and segments") for `customFrame`. -/
theorem customFrame_spherical : TaskFrame.Spherical customFrame.TaskRel :=
  TaskFrame.spherical_of_permissive customFrame_rel_iff

/-! ## Polymorphism Tests -/

-- Test: TaskFrame can be instantiated with Int explicitly
example : TaskFrame Int := TaskFrame.trivialFrame

-- Test: Nullity constraint works with explicit type
theorem nullity_test_int : (TaskFrame.trivialFrame (D := Int)).TaskRel () 0 () :=
  TaskFrame.trivialFrame.nullity ()

-- Test: Compositionality with Int time (1 + 2 = 3)
theorem compositionality_test_int :
    (TaskFrame.trivialFrame (D := Int)).TaskRel () 3 () := by
  -- trivial_frame's TaskRel is `True`; forward_comp now also requires 0 ≤ x, 0 ≤ y
  exact (TaskFrame.trivialFrame (D := Int)).forward_comp () () () 1 2 (by decide) (by decide)
    ((TaskFrame.trivialFrame (D := Int)).nullity ())
    ((TaskFrame.trivialFrame (D := Int)).nullity ())

end BimodalTest.Semantics
