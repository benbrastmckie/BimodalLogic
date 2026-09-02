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
# Frame Tests

Tests for task frame structure and constraints.

## Temporal Type Note

After the temporal generalization, the frame is a fibre `FrameOver D` over a temporal order
with `LinearOrderedAddCommGroup` constraint. Tests use explicit `Int` annotations
to specify the temporal type.
-/

namespace BimodalTest.Semantics

open FormalSystem.Semantics

/-! ## trivialFrame Tests (using Int time) -/

-- Test: trivialFrame satisfies nullity
example : (FrameOver.trivialFrame (D := Int)).TaskRel () 0 () :=
  (FrameOver.trivialFrame (D := Int)).nullity ()

-- Test: trivialFrame satisfies compositionality (task relation is always true)
example : (FrameOver.trivialFrame (D := Int)).TaskRel () 5 () := trivial

-- Test: trivialFrame with negative duration
example : (FrameOver.trivialFrame (D := Int)).TaskRel () (-3) () := trivial

/-! ## staticFrame Tests -/

-- Test: staticFrame satisfies nullity (with explicit type annotation)
example : (FrameOver.staticFrame Nat (D := Int)).TaskRel (3 : Nat) 0 (3 : Nat) :=
  (FrameOver.staticFrame Nat (D := Int)).nullity (3 : Nat)

-- Test: staticFrame is reflexive at every duration (the Seriality witness), unlike the
-- former zero-duration-only identity frame it replaces
example : (FrameOver.staticFrame Nat (D := Int)).TaskRel (3 : Nat) 7 (3 : Nat) := rfl

/-! ## natFrame Tests (using Int time) -/

-- Test: natFrame satisfies nullity
example : (FrameOver.natFrame (D := Int)).TaskRel (5 : Nat) 0 (5 : Nat) :=
  (FrameOver.natFrame (D := Int)).nullity (5 : Nat)

-- Test: natFrame with non-zero duration (task relation always true)
example : (FrameOver.natFrame (D := Int)).TaskRel (0 : Nat) 10 (42 : Nat) := Or.inl (by decide)

/-! ## Custom Frame Tests -/

-- Test: the custom two-state Int frame. Its definition has been promoted into the library as
-- `FormalSystem.Semantics.intBoolFrame` (Examples/TemporalStructures.lean), where it is the
-- canonical off-zero-universal two-state Z witness; this is now an alias, so every assertion
-- below still exercises the same frame and the same relation, definitionally.
def customFrame : FrameOver intOrder := FormalSystem.Examples.TemporalStructures.intBoolFrame

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

/-- *Saturation* (`def:frame#Saturation`, verbatim: "$\bigcap \mathcal{S} \neq \emptyset$ for any
$\supseteq$-directed family $\mathcal{S}$ of nonempty fibers and segments") for `customFrame`. -/
theorem customFrame_saturation : TaskFrame.Saturation customFrame.TaskRel :=
  TaskFrame.saturation_of_permissive customFrame_rel_iff

/-! ## Polymorphism Tests -/

-- Test: the fibre can be instantiated at the ℤ temporal order explicitly
example : FrameOver intOrder := FrameOver.trivialFrame

-- Test: Nullity constraint works with explicit type
theorem nullity_test_int : (FrameOver.trivialFrame (D := Int)).TaskRel () 0 () :=
  FrameOver.trivialFrame.nullity ()

-- Test: Compositionality with Int time (1 + 2 = 3)
theorem compositionality_test_int :
    (FrameOver.trivialFrame (D := Int)).TaskRel () 3 () := by
  -- trivial_frame's TaskRel is `True`; forward_comp now also requires 0 ≤ x, 0 ≤ y
  exact (FrameOver.trivialFrame (D := Int)).forward_comp () () () 1 2 (by decide) (by decide)
    ((FrameOver.trivialFrame (D := Int)).nullity ())
    ((FrameOver.trivialFrame (D := Int)).nullity ())

end BimodalTest.Semantics
