/-
Copyright (c) 2025 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import Mathlib.Algebra.Order.Group.Int
import Mathlib.Data.Int.SuccPred
import FormalSystem.Semantics.TaskFrame
import FormalSystem.Examples.TemporalStructures

/-!
# ParamTaskFrame Tests

Tests for task frame structure and constraints.

## Temporal Type Note

After the temporal generalization, ParamTaskFrame now takes a type parameter `T`
with `LinearOrderedAddCommGroup` constraint. Tests use explicit `Int` annotations
to specify the temporal type.
-/

namespace BimodalTest.Semantics

open FormalSystem.Semantics

/-! ## trivialFrame Tests (using Int time) -/

-- Test: trivialFrame satisfies nullity
example : (ParamTaskFrame.trivialFrame (D := Int)).TaskRel () 0 () :=
  (ParamTaskFrame.trivialFrame (D := Int)).nullity ()

-- Test: trivialFrame satisfies compositionality (task relation is always true)
example : (ParamTaskFrame.trivialFrame (D := Int)).TaskRel () 5 () := trivial

-- Test: trivialFrame with negative duration
example : (ParamTaskFrame.trivialFrame (D := Int)).TaskRel () (-3) () := trivial

/-! ## staticFrame Tests -/

-- Test: staticFrame satisfies nullity (with explicit type annotation)
example : (ParamTaskFrame.staticFrame Nat (D := Int)).TaskRel (3 : Nat) 0 (3 : Nat) :=
  (ParamTaskFrame.staticFrame Nat (D := Int)).nullity (3 : Nat)

-- Test: staticFrame is reflexive at every duration (the Seriality witness), unlike the
-- former zero-duration-only identity frame it replaces
example : (ParamTaskFrame.staticFrame Nat (D := Int)).TaskRel (3 : Nat) 7 (3 : Nat) := rfl

/-! ## natFrame Tests (using Int time) -/

-- Test: natFrame satisfies nullity
example : (ParamTaskFrame.natFrame (D := Int)).TaskRel (5 : Nat) 0 (5 : Nat) :=
  (ParamTaskFrame.natFrame (D := Int)).nullity (5 : Nat)

-- Test: natFrame with non-zero duration (task relation always true)
example : (ParamTaskFrame.natFrame (D := Int)).TaskRel (0 : Nat) 10 (42 : Nat) := Or.inl (by decide)

/-! ## Custom Frame Tests -/

-- Test: the custom two-state Int frame. Its definition has been promoted into the library as
-- `FormalSystem.Semantics.intBoolFrame` (Examples/TemporalStructures.lean), where it is the
-- canonical off-zero-universal two-state Z witness; this is now an alias, so every assertion
-- below still exercises the same frame and the same relation, definitionally.
def customFrame : ParamTaskFrame Int := FormalSystem.Examples.TemporalStructures.intBoolFrame

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
  ParamTaskFrame.serial_of_permissive customFrame_rel_iff

/-- The interpolation half of *Compositionality* (`def:frame#Compositionality`, verbatim:
"$w \Rightarrow_{x + y} v$ if and only if $w \Rightarrow_x u$ and $u \Rightarrow_y v$ for some
$u \in W$") for `customFrame`. -/
theorem customFrame_interpolates : TaskFrame.Interpolates customFrame.TaskRel :=
  ParamTaskFrame.interpolates_of_permissive customFrame_rel_iff

/-- *Limit* (`def:frame#Limit`, verbatim: "$\bigcap\limits_{x > 0} (w)_x = \set{w}$") for
`customFrame`, in the literal transcribed shape. The duration type is `Int`, which supplies the
`SuccOrder` / `NoMaxOrder` instances the permissive class needs, so no binder change is
required here. -/
theorem customFrame_limit :
    ∀ w u, (∀ x : Int, 0 < x → ∃ y, |y| < x ∧ customFrame.TaskRel w y u) → u = w :=
  ParamTaskFrame.limit_of_permissive customFrame_rel_iff

/-- *Spherical* (`def:frame#Spherical`, verbatim: "$\bigcap \mathcal{S} \neq \emptyset$ for any
$\supseteq$-directed family $\mathcal{S}$ of nonempty fibers and segments") for `customFrame`. -/
theorem customFrame_spherical : TaskFrame.Spherical customFrame.TaskRel :=
  ParamTaskFrame.spherical_of_permissive customFrame_rel_iff

/-! ## Polymorphism Tests -/

-- Test: ParamTaskFrame can be instantiated with Int explicitly
example : ParamTaskFrame Int := ParamTaskFrame.trivialFrame

-- Test: Nullity constraint works with explicit type
theorem nullity_test_int : (ParamTaskFrame.trivialFrame (D := Int)).TaskRel () 0 () :=
  ParamTaskFrame.trivialFrame.nullity ()

-- Test: Compositionality with Int time (1 + 2 = 3)
theorem compositionality_test_int :
    (ParamTaskFrame.trivialFrame (D := Int)).TaskRel () 3 () := by
  -- trivial_frame's TaskRel is `True`; forward_comp now also requires 0 ≤ x, 0 ≤ y
  exact (ParamTaskFrame.trivialFrame (D := Int)).forward_comp () () () 1 2 (by decide) (by decide)
    ((ParamTaskFrame.trivialFrame (D := Int)).nullity ())
    ((ParamTaskFrame.trivialFrame (D := Int)).nullity ())

end BimodalTest.Semantics
