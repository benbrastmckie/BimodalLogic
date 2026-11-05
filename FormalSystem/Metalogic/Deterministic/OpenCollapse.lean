/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Deterministic.Completeness
import FormalSystem.OpenLanguage.OpenErasure
import FormalSystem.OpenLanguage.OpenValidity
import FormalSystem.PlusLanguage.PlusDeterminism

/-!
# The collapse of `▷` and `◁` on a deterministic frame

On a deterministic task frame a world state at one time fixes the whole history through it, so the
three restricted quantifier classes degenerate: `⟨τ⟩_x`, `|τ⟩_x` and `⟨τ|_x` all collapse to
`{τ}`, and `⊡ = ▷ = ◁ = id`. This file states that as a truth-level theorem
(`openTruthAt_eraseOpen_of_deterministic`), composes it with the `⊡`-deleting collapse of
`Deterministic/Erasure.lean` to reach L (`openTruthAt_erasePlus_eraseOpen_of_deterministic`),
reads off the validity-level corollary pair, and recovers the landed deterministic completeness
through the composite erasure.

## Why `eraseOpen` keeps `⊡`

`eraseOpen` deletes `▷` and `◁` and keeps `⊡` primitive, so the `stab` case of the induction below
is **structural** — it does not consume determinism. Determinism is consumed in exactly two cases,
`ofut` and `opast`, through `states_eq_of_deterministic` and the landed `truth_congr_ext`: a
history agreeing with `τ` on a half-line agrees with it at the time of evaluation, hence (by
determinism) everywhere. A `stab` case that consumed determinism would mean `eraseOpen` had been
changed to erase `⊡` as well, which would lose the one-bit-per-cell anchor the decidability front
rests on.

## `Determined` is reached through the frame predicate, never through the axiom type

`Determined` (`φ → ⊡φ`) is **not** and must not become an `OpenAxiom` constructor: it is refuted
over non-deterministic frames (`PlusLanguage/PlusNonValidities.lean`), so admitting it would
falsify soundness at the base class. Everything in this file is stated at `DetSat fc`, the
frame-predicate form, exactly as `PlusLanguage/Axioms.lean`'s extension recipe directs. The same
reason is why `▷◁φ → ⊡φ` is excluded from the axiom type: its erasure *is* `Determined`.

## Main Definitions

- `OpenValidDetIn` — L^▷ validity over the deterministic frames of a class, `OpenValidOnFrames` at
  `DetSat fc`

## Main Results

- `openTruthAt_eraseOpen_of_deterministic` — the pointwise collapse
- `openTruthAt_erasePlus_eraseOpen_of_deterministic` — the composite collapse down to L
- `validDetIn_eraseOpen_of_openValidDetIn`, `openValidDetIn_of_validDetIn_eraseOpen` and
  `openValidDetIn_iff_plusValidDetIn_eraseOpen` — the validity-level corollaries
- `detDerivable_eraseOpen_of_openValidDetIn` — the landed deterministic completeness
  (`detCompleteness`) recovered through the composite erasure

## References

* `FormalSystem/Metalogic/Deterministic/Erasure.lean` — the `⊡`-deleting collapse this one
  composes with, and the shape of its corollary pair
* `FormalSystem/OpenLanguage/OpenErasure.lean` — `eraseOpen`
* `FormalSystem/Metalogic/Deterministic/Completeness.lean` — `detCompleteness`, the row recovered

## Tags

deterministic · collapse · open-future · open-past · erasure
-/

namespace FormalSystem.Metalogic.Deterministic

open FormalSystem.Syntax
open FormalSystem.ProofSystem (FrameClass)
open FormalSystem.PlusLanguage
open FormalSystem.OpenLanguage
open FormalSystem.Semantics

variable {F : TaskFrame}

/-! ## The pointwise collapse -/

/--
**The pointwise collapse.** Over a deterministic frame, `OpenTruthAt` of `φ` and `PlusTruthAt` of
its `▷`/`◁`-erasure coincide at every world history and time.

Determinism enters only in the `ofut` and `opast` cases, through
`states_eq_of_deterministic` and the landed `truth_congr_ext`. The history and time binders sit
**inside** the statement rather than in the signature, exactly as in
`plusTruthAt_erasePlus_of_deterministic`, so that the `box` and `stab` cases can apply the
induction hypothesis at a different history.
-/
theorem openTruthAt_eraseOpen_of_deterministic (hD : F.Deterministic) (M : TaskModel F)
    (φ : OpenFormula) :
    ∀ (τ : WorldHistory F) (t : F.Duration),
      OpenTruthAt M τ t φ ↔ PlusTruthAt M τ t (eraseOpen φ) := by
  induction φ with
  | atom p => intro τ t; exact Iff.rfl
  | bot => intro τ t; exact Iff.rfl
  | imp φ ψ ihφ ihψ => intro τ t; exact Iff.imp (ihφ τ t) (ihψ τ t)
  | box φ ih => intro τ t; exact forall_congr' fun σ => ih σ t
  | untl ψ φ ihψ ihφ =>
    intro τ t
    exact exists_congr fun s => and_congr_right fun _ =>
      and_congr (ihφ τ s)
        (forall_congr' fun r => imp_congr_right fun _ => imp_congr_right fun _ => ihψ τ r)
  | snce ψ φ ihψ ihφ =>
    intro τ t
    exact exists_congr fun s => and_congr_right fun _ =>
      and_congr (ihφ τ s)
        (forall_congr' fun r => imp_congr_right fun _ => imp_congr_right fun _ => ihψ τ r)
  | stab φ ih =>
    intro τ t
    exact forall_congr' fun σ => imp_congr_right fun _ => ih σ t
  | ofut φ ih =>
    intro τ t
    constructor
    · intro h; exact (ih τ t).mp (h τ (fun _ _ => rfl))
    · intro h σ hag
      exact (ih σ t).mpr
        ((truth_congr_ext M (eraseOpen φ) τ σ t
          (states_eq_of_deterministic hD (hag t le_rfl))).mp h)
  | opast φ ih =>
    intro τ t
    constructor
    · intro h; exact (ih τ t).mp (h τ (fun _ _ => rfl))
    · intro h σ hag
      exact (ih σ t).mpr
        ((truth_congr_ext M (eraseOpen φ) τ σ t
          (states_eq_of_deterministic hD (hag t le_rfl))).mp h)

/-- The composite collapse all the way down to L: over a deterministic frame an L^▷ formula is
true exactly where the L formula obtained by deleting `▷`, `◁` and `⊡` is. -/
theorem openTruthAt_erasePlus_eraseOpen_of_deterministic (hD : F.Deterministic)
    (M : TaskModel F) (φ : OpenFormula) (τ : WorldHistory F) (t : F.Duration) :
    OpenTruthAt M τ t φ ↔ TruthAt M τ t (erasePlus (eraseOpen φ)) :=
  (openTruthAt_eraseOpen_of_deterministic hD M φ τ t).trans
    (plusTruthAt_erasePlus_of_deterministic hD M (eraseOpen φ) τ t)

/-! ## The validity-level corollaries

`OpenValidDetIn` is the L^▷ mirror of `PlusValidDetIn`: `OpenValidOnFrames` at `DetSat fc`, a
*narrowing* of `OpenValidIn fc`, so it is a weaker hypothesis and a stronger conclusion. -/

/-- L^▷ validity over the deterministic frames of `fc`. -/
def OpenValidDetIn (fc : FrameClass) (φ : OpenFormula) : Prop :=
  OpenValidOnFrames (DetSat fc) φ

/-- Introduce `OpenValidDetIn` from the unbundled shape. -/
theorem OpenValidDetIn.of_forall {fc : FrameClass} {φ : OpenFormula}
    (h : ∀ (F : TaskFrame), fc.Sat F → F.Deterministic → ∀ (M : TaskModel F)
           (τ : WorldHistory F) (t : F.Duration), OpenTruthAt M τ t φ) :
    OpenValidDetIn fc φ :=
  fun F hF => h F hF.1 hF.2

/-- Eliminate `OpenValidDetIn` into the unbundled shape. -/
theorem OpenValidDetIn.apply {fc : FrameClass} {φ : OpenFormula} (h : OpenValidDetIn fc φ)
    (F : TaskFrame) (hF : fc.Sat F) (hD : F.Deterministic) (M : TaskModel F)
    (τ : WorldHistory F) (t : F.Duration) : OpenTruthAt M τ t φ :=
  h F ⟨hF, hD⟩ M τ t

/-- L^▷ validity over the deterministic frames of `fc` gives L⁺ validity of the `▷`/`◁`-erasure
over the same frames. -/
theorem validDetIn_eraseOpen_of_openValidDetIn {fc : FrameClass} {φ : OpenFormula}
    (h : OpenValidDetIn fc φ) : PlusValidDetIn fc (eraseOpen φ) :=
  PlusValidDetIn.of_forall fun F hF hD M τ t =>
    (openTruthAt_eraseOpen_of_deterministic hD M φ τ t).mp
      (OpenValidDetIn.apply h F hF hD M τ t)

/-- The converse: L⁺ validity of the erasure over the deterministic frames of `fc` gives L^▷
validity of the original over the same frames. -/
theorem openValidDetIn_of_validDetIn_eraseOpen {fc : FrameClass} {φ : OpenFormula}
    (h : PlusValidDetIn fc (eraseOpen φ)) : OpenValidDetIn fc φ :=
  OpenValidDetIn.of_forall fun F hF hD M τ t =>
    (openTruthAt_eraseOpen_of_deterministic hD M φ τ t).mpr
      (PlusValidDetIn.apply h F hF hD M τ t)

/-- The two directions packaged: over the deterministic frames of any class, an L^▷ formula and
its `▷`/`◁`-erasure are equivalid. -/
theorem openValidDetIn_iff_plusValidDetIn_eraseOpen (fc : FrameClass) (φ : OpenFormula) :
    OpenValidDetIn fc φ ↔ PlusValidDetIn fc (eraseOpen φ) :=
  ⟨validDetIn_eraseOpen_of_openValidDetIn, openValidDetIn_of_validDetIn_eraseOpen⟩

/-- The composite, down to L: over the deterministic frames of any class an L^▷ formula is
equivalid with the L formula obtained by deleting `▷`, `◁` and `⊡`. -/
theorem openValidDetIn_iff_validDetIn_erasePlus_eraseOpen (fc : FrameClass) (φ : OpenFormula) :
    OpenValidDetIn fc φ ↔ ValidDetIn fc (erasePlus (eraseOpen φ)) :=
  (openValidDetIn_iff_plusValidDetIn_eraseOpen fc φ).trans
    (plusValidDetIn_iff_validDetIn_erasePlus fc (eraseOpen φ))

/-! ## The landed deterministic completeness, recovered -/

/-- **`detCompleteness` recovered through the composite erasure.** An L^▷ formula valid over the
deterministic frames of any class has its `▷`/`◁`-erasure derivable in the deterministic system at
that class. This is the landed row of `Deterministic/Completeness.lean` read one language out: the
collapse supplies the hypothesis, nothing new is proved about the engine, and no completeness is
claimed for the L^▷ system itself — the conclusion is about `eraseOpen φ`, an L⁺ formula. -/
theorem detDerivable_eraseOpen_of_openValidDetIn (fc : FrameClass) {φ : OpenFormula}
    (h : OpenValidDetIn fc φ) : DetDerivable fc [] (eraseOpen φ) :=
  detCompleteness fc (eraseOpen φ) (validDetIn_eraseOpen_of_openValidDetIn h)

end FormalSystem.Metalogic.Deterministic
