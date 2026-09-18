/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.QTime

/-!
# ℚ-time frames: API regressions

Exercises `TaskFrame.IsQTime` (`Semantics/FrameProperty.lean`), `ValidQTime`
(`Semantics/Validity.lean`), `isQTime_rat` and `derivable_of_validQTime`
(`Metalogic/BXCanonical/Completeness.lean`), and `validQTime_iff_validDense`
(`Metalogic/QTime.lean`).

- Every frame over `ℚ` is ℚ-time, and therefore dense.
- No frame over `ℤ` is ℚ-time: `1` has no half.
- ℚ-time validity and dense validity coincide.
- `#guard_msgs`-gated `#print axioms` blocks pin the axiom profiles to the three standard axioms.
  These are build-breaking.
-/

namespace BimodalTest.Semantics.QTimeTest

open FormalSystem.Semantics
open FormalSystem.Metalogic
open FormalSystem.Metalogic.BXCanonical

/-- A frame over `ℚ` is dense, by way of ℚ-time. -/
example (F : FrameOver (TemporalOrder.of ℚ)) : F.toTaskFrame.IsDense :=
  TaskFrame.isDense_of_isQTime (isQTime_rat F)

/-- A frame over `ℤ` is not ℚ-time: divisibility fails at `n = 2`. -/
example (F : FrameOver (TemporalOrder.of ℤ)) : ¬ F.toTaskFrame.IsQTime := by
  rintro ⟨hdiv, -⟩
  obtain ⟨x, hx⟩ := hdiv 2 two_ne_zero (1 : ℤ)
  change (2 : ℕ) • (x : ℤ) = 1 at hx
  rw [nsmul_eq_mul] at hx
  push_cast at hx
  omega

/-- The two directions of `validQTime_iff_validDense`, used as rewrites. -/
example (φ : FormalSystem.Syntax.Formula) (h : ValidQTime φ) : ValidDense φ :=
  (validQTime_iff_validDense φ).mp h

example (φ : FormalSystem.Syntax.Formula) (h : ValidDense φ) : ValidQTime φ :=
  (validQTime_iff_validDense φ).mpr h

/--
info: 'FormalSystem.Semantics.TaskFrame.isDense_of_isQTime' depends on axioms: [propext, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms FormalSystem.Semantics.TaskFrame.isDense_of_isQTime

/--
info: 'FormalSystem.Metalogic.BXCanonical.isQTime_rat' depends on axioms: [propext, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms FormalSystem.Metalogic.BXCanonical.isQTime_rat

/--
info: 'FormalSystem.Metalogic.BXCanonical.derivable_of_validQTime' depends on axioms: [propext, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms FormalSystem.Metalogic.BXCanonical.derivable_of_validQTime

/--
info: 'FormalSystem.Metalogic.validQTime_iff_validDense' depends on axioms: [propext, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms FormalSystem.Metalogic.validQTime_iff_validDense

end BimodalTest.Semantics.QTimeTest
