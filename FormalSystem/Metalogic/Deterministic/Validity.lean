/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.PlusLanguage.PlusDeterminism
import FormalSystem.Metalogic.Independence.DeterminismUndefinable

/-!
# Validity over the deterministic frames, and the *Determined*-valid frame class

The two frame-predicate-restricted validity notions that the deterministic metatheory of TM⁺ is
stated against, together with the frame class on which the *Determined* schema `φ → ⊡φ` is valid
and the **strict** inclusion of the deterministic frames in it.

## Why the notions are frame-predicate-restricted

`def:deterministic` is a condition on a frame, not on a temporal order, so no `FrameClass` tag
denotes it and none can be added: the tags are the proof side's axiom-gating lattice
(`ProofSystem/Axioms.lean`), and *Determined* is refuted at `.Base`
(`Semantics/PlusLanguage/PlusNonValidities.lean`, `refute_determined`). The validity layer already anticipates
exactly this: `ValidOnFrames` and `PlusValidOnFrames` are the primitives, indexed by a bare
`TaskFrame → Prop`, and `ValidIn fc` / `PlusValidIn fc` are their instances at `fc.Sat`. The
notions below are the instances at `fun F => fc.Sat F ∧ F.Deterministic`, so nothing in the
semantics is touched.

## Main Definitions

- `ValidDetIn fc φ` — L validity over the *deterministic* frames of the class `fc`
- `PlusValidDetIn fc φ` — the L⁺ twin
- `DeterminedValid F` — `F` validates every instance of the *Determined* schema
- `PlusValidDeterminedIn fc φ` — L⁺ validity over the *Determined*-valid frames of `fc`

## Main Results

- `deterministic_determinedValid` — every deterministic frame is *Determined*-valid; this is
  536's `determined_of_deterministic` repackaged, never re-derived
- `determinedValid_not_deterministic` — the inclusion is **strict**: the drift frame `F°`
  (`Metalogic/Independence/DriftFrame.lean`) is *Determined*-valid and not deterministic
- `plusValidDeterminedIn_le_plusValidDetIn` and the L mirror — validity over the larger class
  transports down to the smaller one
- `PlusValidIn.toDet`, `ValidIn.toDet` — unrestricted class validity transports down

## What these notions do NOT say

`DeterminedValid` is **not** a characterization of `TaskFrame.Deterministic`, and no statement in
this subtree may describe it as one: the class it cuts out strictly contains the deterministic
frames (`determinedValid_not_deterministic`), and by `deterministic_not_plusDefinable`
(`Metalogic/Independence/DeterminismUndefinable.lean`) *no* L⁺ formula set defines the
deterministic frames at all. What does hold — and is the sentence the manuscript can use — is that
the two classes have the **same logic**; that coincidence is
`Metalogic/Deterministic/Completeness.lean`'s business, and it is a theorem about validity, not
about frames.

## References

* JPL paper `def:deterministic`, `app:deterministic`, `cor:no-characterization`
* `FormalSystem/Semantics/PlusLanguage/PlusDeterminism.lean` — the landed collapse consumed here
* `FormalSystem/Metalogic/Independence/DeterminismUndefinable.lean` — (T3), the strictness witness

## Tags

determinism · validity · plus-language · stability-modal · app:deterministic
-/

namespace FormalSystem.Metalogic.Deterministic

open FormalSystem.Syntax
open FormalSystem.ProofSystem (FrameClass)
open FormalSystem.PlusLanguage
open FormalSystem.Semantics

/-! ## The deterministic frames of a class -/

/-- The frames of the class `fc` that are additionally deterministic (`def:deterministic`).
Named because it appears in every statement of this subtree and in each of the four engines. -/
def DetSat (fc : FrameClass) (F : TaskFrame) : Prop :=
  fc.Sat F ∧ F.Deterministic

/-- L validity over the deterministic frames of `fc`. `ValidOnFrames` at `DetSat fc` — a
*narrowing* of `ValidIn fc`, so it is a weaker hypothesis and a stronger conclusion. -/
def ValidDetIn (fc : FrameClass) (φ : Formula) : Prop :=
  ValidOnFrames (DetSat fc) φ

/-- L⁺ validity over the deterministic frames of `fc`. -/
def PlusValidDetIn (fc : FrameClass) (φ : PlusFormula) : Prop :=
  PlusValidOnFrames (DetSat fc) φ

/-! ## The *Determined*-valid frames -/

/--
`F` validates every instance of the *Determined* schema `φ → ⊡φ`, `φ` an arbitrary `PlusFormula`.

This is a condition on the frame, and a strictly weaker one than `def:deterministic`: see
`determinedValid_not_deterministic`. It is the class TM⁺ + *Determined* is **sound** over
(`Metalogic/Deterministic/Soundness.lean`).
-/
def DeterminedValid (F : TaskFrame) : Prop :=
  ∀ φ : PlusFormula, F.PlusValidOn (φ.imp φ.stab)

/-- The frames of the class `fc` that additionally validate *Determined*. -/
def DeterminedSat (fc : FrameClass) (F : TaskFrame) : Prop :=
  fc.Sat F ∧ DeterminedValid F

/-- L⁺ validity over the *Determined*-valid frames of `fc`. -/
def PlusValidDeterminedIn (fc : FrameClass) (φ : PlusFormula) : Prop :=
  PlusValidOnFrames (DeterminedSat fc) φ

/-! ## The inclusion, and its strictness -/

/-- Every deterministic frame validates every instance of *Determined*. This is 536's
`determined_of_deterministic` (`Semantics/PlusLanguage/PlusDeterminism.lean`) repackaged at the predicate
`DeterminedValid`; the collapse itself is **not** re-derived here. -/
theorem deterministic_determinedValid {F : TaskFrame} (hD : F.Deterministic) :
    DeterminedValid F :=
  fun φ => Semantics.determined_of_deterministic hD φ

/-- The class inclusion at a `FrameClass` tag. -/
theorem determinedSat_of_detSat {fc : FrameClass} {F : TaskFrame} (h : DetSat fc F) :
    DeterminedSat fc F :=
  ⟨h.1, deterministic_determinedValid h.2⟩

/--
**The inclusion is strict.** The drift frame `F°` (`Metalogic/Independence/DriftFrame.lean`)
validates every instance of *Determined* and is not deterministic — 536's (T3),
`determined_valid_on_non_deterministic`.

Consequently no statement in this subtree may describe *Determined* as defining or characterizing
`TaskFrame.Deterministic`; `deterministic_not_plusDefinable` rules out any repair by a different
formula set.
-/
theorem determinedValid_not_deterministic :
    ∃ F : TaskFrame, DeterminedValid F ∧ ¬ F.Deterministic :=
  ⟨Independence.F0, Independence.fzero_determined, Independence.fzero_not_deterministic⟩

/-- The strict inclusion at `.Base`, where `F°` is admitted by every frame class condition
(`Sat .Base` is `True`). -/
theorem determinedSat_not_detSat_base :
    ∃ F : TaskFrame, DeterminedSat FrameClass.Base F ∧ ¬ DetSat FrameClass.Base F :=
  ⟨Independence.F0, ⟨trivial, Independence.fzero_determined⟩,
    fun h => Independence.fzero_not_deterministic h.2⟩

/-! ## Monotonicity

Each of these transports a validity claim *down* a frame-predicate inclusion, i.e. to a smaller
class of frames and hence to a weaker statement. They are `PlusValidOnFrames.mono` /
`ValidOnFrames.mono` at the four inclusions this subtree uses. -/

/-- L⁺ validity over the *Determined*-valid frames of `fc` gives L⁺ validity over its
deterministic frames. -/
theorem PlusValidDetIn.of_determined {fc : FrameClass} {φ : PlusFormula}
    (h : PlusValidDeterminedIn fc φ) : PlusValidDetIn fc φ :=
  PlusValidOnFrames.mono (fun _ hF => determinedSat_of_detSat hF) h

/-- Unrestricted `fc`-validity gives validity over the deterministic frames of `fc`. -/
theorem PlusValidIn.toDet {fc : FrameClass} {φ : PlusFormula} (h : PlusValidIn fc φ) :
    PlusValidDetIn fc φ :=
  PlusValidOnFrames.mono (fun _ hF => hF.1) h

/-- Unrestricted `fc`-validity gives validity over the *Determined*-valid frames of `fc`. -/
theorem PlusValidIn.toDetermined {fc : FrameClass} {φ : PlusFormula} (h : PlusValidIn fc φ) :
    PlusValidDeterminedIn fc φ :=
  PlusValidOnFrames.mono (fun _ hF => hF.1) h

/-- The L mirror: unrestricted `fc`-validity gives validity over the deterministic frames. -/
theorem ValidIn.toDet {fc : FrameClass} {φ : Formula} (h : ValidIn fc φ) : ValidDetIn fc φ :=
  ValidOnFrames.mono (fun _ hF => hF.1) h

/-! ### Binder-shape adapters

The same four adapters `Semantics/Validity.lean` and `Semantics/PlusLanguage/PlusValidity.lean` provide, at
the two restricted notions, so that no consumer has to unfold `DetSat`. -/

/-- Introduce `ValidDetIn` from the unbundled shape. -/
theorem ValidDetIn.of_forall_total {fc : FrameClass} {φ : Formula}
    (h : ∀ (F : TaskFrame), fc.Sat F → F.Deterministic → ∀ (M : TaskModel F)
           (τ : PartialHistory F), τ.IsTotal → ∀ t : F.Duration, TruthAt M τ t φ) :
    ValidDetIn fc φ :=
  ValidOnFrames.of_forall_total fun F hF => h F hF.1 hF.2

/-- Eliminate `ValidDetIn` into the unbundled shape. -/
theorem ValidDetIn.apply_total {fc : FrameClass} {φ : Formula} (h : ValidDetIn fc φ)
    (F : TaskFrame) (hF : fc.Sat F) (hD : F.Deterministic) (M : TaskModel F)
    (τ : PartialHistory F) (hτ : τ.IsTotal) (t : F.Duration) : TruthAt M τ t φ :=
  ValidOnFrames.apply_total h F ⟨hF, hD⟩ M τ hτ t

/-- Introduce `PlusValidDetIn` from the unbundled shape. -/
theorem PlusValidDetIn.of_forall_total {fc : FrameClass} {φ : PlusFormula}
    (h : ∀ (F : TaskFrame), fc.Sat F → F.Deterministic → ∀ (M : TaskModel F)
           (τ : PartialHistory F), τ.IsTotal → ∀ t : F.Duration, PlusTruthAt M τ t φ) :
    PlusValidDetIn fc φ :=
  PlusValidOnFrames.of_forall_total fun F hF => h F hF.1 hF.2

/-- Eliminate `PlusValidDetIn` into the unbundled shape. -/
theorem PlusValidDetIn.apply_total {fc : FrameClass} {φ : PlusFormula} (h : PlusValidDetIn fc φ)
    (F : TaskFrame) (hF : fc.Sat F) (hD : F.Deterministic) (M : TaskModel F)
    (τ : PartialHistory F) (hτ : τ.IsTotal) (t : F.Duration) : PlusTruthAt M τ t φ :=
  PlusValidOnFrames.apply_total h F ⟨hF, hD⟩ M τ hτ t

/-- Introduce `PlusValidDeterminedIn` from the unbundled shape. -/
theorem PlusValidDeterminedIn.of_forall_total {fc : FrameClass} {φ : PlusFormula}
    (h : ∀ (F : TaskFrame), fc.Sat F → DeterminedValid F → ∀ (M : TaskModel F)
           (τ : PartialHistory F), τ.IsTotal → ∀ t : F.Duration, PlusTruthAt M τ t φ) :
    PlusValidDeterminedIn fc φ :=
  PlusValidOnFrames.of_forall_total fun F hF => h F hF.1 hF.2

/-- Eliminate `PlusValidDeterminedIn` into the unbundled shape. -/
theorem PlusValidDeterminedIn.apply_total {fc : FrameClass} {φ : PlusFormula}
    (h : PlusValidDeterminedIn fc φ) (F : TaskFrame) (hF : fc.Sat F) (hDV : DeterminedValid F)
    (M : TaskModel F) (τ : PartialHistory F) (hτ : τ.IsTotal) (t : F.Duration) :
    PlusTruthAt M τ t φ :=
  PlusValidOnFrames.apply_total h F ⟨hF, hDV⟩ M τ hτ t

end FormalSystem.Metalogic.Deterministic
