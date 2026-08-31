/-
Probe: can "the task frames over a FIXED duration type" be expressed in the bundled form?

This is the question Phases 5/6/7/10/12 turn on: ~350 occurrences of `ParamTaskFrame ℤ`
(IntNormalForm, IntTransfer, IntPresentation, FMP, ReynoldsBridge, BiLasso, PeriodicExtension,
Tests) quantify over a VARIABLE frame whose duration type is ℤ, and use `1 : ℤ` inside.
-/
import FormalSystem.Semantics.IntNormalForm
import Mathlib.Algebra.Order.Group.Int

namespace IntFrameProbe
open FormalSystem.Semantics

-- BASELINE (today, parameterized): `F.step` is `F.TaskRel w 1 u`, and `1` elaborates.
example (F : ParamTaskFrame ℤ) (w u : F.WorldState) : Prop := F.TaskRel w 1 u

/-! ### Candidate 1: a bundled frame plus a propositional carrier equation. -/

section Candidate1
variable (F : TaskFrame) (hD : F.Duration = ℤ)

-- Does `1 : F.Duration` elaborate?  (uncomment to reproduce the failure)
-- example (w u : F.WorldState) : Prop := F.TaskRel w 1 u
-- failed to synthesize  OfNat F.Duration 1

-- The equation cannot supply the instance either: `hD` is a Prop, and `OfNat F.Duration 1`
-- is data, so nothing transports it without an explicit `▸` cast at every use site.
example (w u : F.WorldState) : Prop := F.TaskRel w (hD ▸ (1 : ℤ)) u

end Candidate1

/-! ### Candidate 2: quantify over a bundled frame with no constraint at all.
    This is what the abstract phases do, and it is exactly why they worked: nothing in them
    mentions a numeral or `omega` at the duration type. -/

example (F : TaskFrame) (w u : F.WorldState) (d : F.Duration) : Prop := F.TaskRel w d u

end IntFrameProbe
