/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.WitnessFamily.Basic
import FormalSystem.Semantics.ShiftSet
import FormalSystem.Semantics.Validity
import FormalSystem.Semantics.FrameClassValidity
import Mathlib.Data.Int.SuccPred
import Mathlib.Order.SuccPred.LinearLocallyFinite

/-!
# The Standard Shift-Set Model of a Witness Family

A witness family presents a model directly: the carrier is "a lasso index together with a time",
the shift action translates the time, and the valuation reads the atom part of the label. That is
`WitnessFamily.std`, and every semantic fact the certificate needs comes from
`Semantics/ShiftSet.lean` applied to it — `ShiftSet.frame`, `ShiftSet.model`, `ShiftSet.hist`,
and `ShiftSet.total_eq_orbit`, which is what makes the model's world histories *exactly* the
lassos and their shifts.

## `std` must not be `@[reducible]`

Marking `std` reducible breaks synthesis of `ShiftSet.frame_isRegular`: with `std` transparent,
instance search unfolds through it and fails to see the `ShiftSet.frame` head it is indexed by.
The definition therefore stays semi-reducible, and carrier points are ascribed explicitly
(`((i, 0) : W.std.Carrier)`) wherever the elaborator would otherwise need to unfold.

## Both `SuccPred` imports are load-bearing

`std_isZTime` needs `SuccOrder ℤ`, `PredOrder ℤ`, `IsSuccArchimedean ℤ` and
`IsPredArchimedean ℤ` in scope at once. `Mathlib.Data.Int.SuccPred` supplies the first pair and
`Mathlib.Order.SuccPred.LinearLocallyFinite` the archimedean pair; removing either breaks the
build. The membership is applied with an explicit `@` and four `inferInstanceAs` arguments
rather than through `haveI`, because a `haveI` shadows the very `SuccOrder` instance that
`IsSuccArchimedean` is indexed by and the application then fails to elaborate.

## Main Definitions

- `WitnessFamily.std` — the standard shift set over `intOrder`

## Main Results

- `WitnessFamily.std_isZTime` — the presented frame is a ℤ-time frame
- `WitnessFamily.std_sat_ztime` / `WitnessFamily.std_sat_base` — frame-class membership
- `WitnessFamily.sh_surj` — the shift at a fixed duration is surjective on the carrier
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax FormalSystem.Semantics

namespace WitnessFamily

variable {Γ Del : Context}

/--
The standard shift set presented by a witness family: carrier `Fin |lassos| × ℤ`, shift by time
translation, valuation read off the atom part of the labels.

**Three axioms, not four.** Built through `ShiftSet.ofIntAction`, so the separation field —
`def:frame#Limit` transcribed over the shift action — is discharged by
`ShiftSet.sep_of_succOrder` from the zero-shift law rather than proved here by hand. Every field
*value* is unchanged from the hand-built version this replaces; only the provenance of `sep`
changed, from a hand proof over `Int.abs_lt_one_iff` to a kernel-checked consequence of
discreteness.

**Not `@[reducible]`** — see this module's header.
-/
def std (W : WitnessFamily Γ Del) : ShiftSet intOrder :=
  ShiftSet.ofIntAction (Fin W.lassos.length × ℤ) ⟨(W.mainIdx, 0)⟩
    (fun w d => (w.1, w.2 + d))
    (by intro w; simp)
    (by intro w a b; simp [add_assoc])
    (fun p w => Formula.atom p ∈ W.L w.1 w.2)

/-- **The presented frame is a ℤ-time frame.** Applied with an explicit `@` and four
`inferInstanceAs` arguments; see this module's header for why `haveI` does not work here. -/
theorem std_isZTime (W : WitnessFamily Γ Del) : W.std.frame.IsZTime :=
  @TaskFrame.isZTime_of_instances W.std.frame
    (inferInstanceAs (SuccOrder ℤ)) (inferInstanceAs (PredOrder ℤ))
    (inferInstanceAs (IsSuccArchimedean ℤ)) (inferInstanceAs (IsPredArchimedean ℤ))

/-- The presented frame satisfies the ℤ-time frame class. -/
theorem std_sat_ztime (W : WitnessFamily Γ Del) :
    FormalSystem.ProofSystem.FrameClass.ZTime.Sat W.std.frame :=
  ⟨inferInstance, W.std_isZTime⟩

/-- The presented frame satisfies the unconstrained frame class, by antitonicity. -/
theorem std_sat_base (W : WitnessFamily Γ Del) :
    FormalSystem.ProofSystem.FrameClass.Base.Sat W.std.frame :=
  FormalSystem.ProofSystem.FrameClass.Sat.anti (by decide) W.std_sat_ztime

/-- `sh` at a fixed duration is surjective on the carrier. This is the whole content of the
`box` case of agreement: quantifying over shifted points is quantifying over all points. -/
theorem sh_surj (W : WitnessFamily Γ Del) (t : ℤ) (u : W.std.Carrier) :
    ∃ v : W.std.Carrier, W.std.sh v t = u :=
  ⟨(u.1, u.2 - t), by cases u; simp [std]; rfl⟩

/-- Shifting does not change the lasso coordinate. -/
theorem sh_fst (W : WitnessFamily Γ Del) (w : W.std.Carrier) (t : ℤ) :
    (W.std.sh w t).1 = w.1 := rfl

/-- Shifting translates the time coordinate. -/
theorem sh_snd (W : WitnessFamily Γ Del) (w : W.std.Carrier) (t : ℤ) :
    (W.std.sh w t).2 = w.2 + t := rfl

/-- The label at a carrier point. -/
def lab (W : WitnessFamily Γ Del) (w : W.std.Carrier) : Finset Formula := W.L w.1 w.2

/-- The label at a shifted carrier point is the label at the translated time. -/
theorem lab_sh (W : WitnessFamily Γ Del) (w : W.std.Carrier) (t : ℤ) :
    W.lab (W.std.sh w t) = W.L w.1 (w.2 + t) := rfl

end WitnessFamily

end FormalSystem.Metalogic.Decidability
