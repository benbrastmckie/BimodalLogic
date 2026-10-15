/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.PlusLanguage.PlusTruth
import FormalSystem.Semantics.ValidityLayer
import FormalSystem.Semantics.Validity

/-!
# L⁺ validity — the `PlusFormula` mirrors of `Semantics/Validity.lean`

Validity for the language L⁺ (`FormalSystem/PlusLanguage/Formula.lean`), stated against the
native `PlusTruthAt` of `PlusLanguage/PlusTruth.lean`, plus the **truth-transfer bridge**
along the embedding `ofFormula : Formula → PlusFormula` and the **semantic conservativity** of L⁺
over L that follows from it at every frame class.

Each predicate here is a binder-for-binder mirror of its counterpart in `Semantics/Validity.lean`
(and of the base-language mirror in `MinusLanguage/MinusValidity.lean`):
`TaskFrame.PlusValidOn` of `TaskFrame.ValidOn`, `PlusValidOnFrames` of `ValidOnFrames`,
`PlusValidIn` of `ValidIn`, `PlusValid` of `Valid`. The frame-predicate form `PlusValidOnFrames` is
the **primitive**, and `PlusValidIn fc := PlusValidOnFrames fc.Sat` its instance at a tag — exactly
the shape that lets one monotonicity lemma serve every bridge, and that lets a validity notion over
a frame class no `FrameClass` tag denotes (for instance the deterministic frames) be stated without
touching the semantics.

## Main Definitions

- `TaskFrame.PlusValidOn`, `PlusValidOnFrames`, `PlusValidIn`, `PlusValid`
- `PlusValidDense`, `PlusValidZTime`, `PlusValidRTime` — the per-class abbreviations

## Main Results

- `PlusValidOnFrames.mono`, `PlusValidIn.mono` — monotonicity
- `PlusValid.of_forall` / `.apply` — the `.Base` binder-shape adapters
- `plusTruthAt_ofFormula` — **the truth-transfer bridge**: an L formula is true in L⁺ exactly
  when it is true in L, at the same model, history and time
- `plusValidIn_ofFormula_iff` — **semantic conservativity of L⁺ over L, at every frame
  class**; `plusValid_ofFormula_iff` is its `.Base` instance
- `after_negation_stable_dstab`, `after_negation_stable_stab` — both readings of
  `cor:after-negation-stable` (cut material, implemented from specification), stated natively in
  L⁺ because the embedding cannot carry a top-level `stab`

## References

* JPL paper `def:frame-validity`, `def:logical-consequence`, `cor:tm-completeness`
* `cor:after-negation-stable` — CUT from the live paper, kept verbatim in
  `JPL/appendix_cut_material.tex`; and `lem:after-negation` / `def:event-operators`, which it
  rests on
* `FormalSystem/Semantics/Validity.lean` — the L predicates these mirror
* `FormalSystem/MinusLanguage/MinusValidity.lean` — the base-language mirror, the same shape

## Tags

validity · plus-language · conservativity · stability-modal
-/

namespace FormalSystem.PlusLanguage

open FormalSystem.Syntax
open FormalSystem.PlusLanguage

open FormalSystem.Semantics

/-! ## `FrameClass`-indexed validity for L⁺ -/

/-- L⁺'s instance of the abstract point-truth class of `Semantics/ValidityLayer.lean`: truth at
the point `(M, τ, t)` is `PlusTruthAt`. Every validity-layer theorem below delegates to the
generic one through this single field. -/
instance : PointTruth PlusFormula where
  sat M τ t φ := PlusTruthAt M τ t φ

end FormalSystem.PlusLanguage

namespace FormalSystem.Semantics

open FormalSystem.PlusLanguage

/-- `def:frame-validity` for L⁺: `φ` is valid over the frame `F` iff it is true at every model
over `F`, every possible world `τ ∈ H_F`, and every time. The L⁺ mirror of
`TaskFrame.ValidOn`. -/
def TaskFrame.PlusValidOn (F : TaskFrame) (φ : PlusFormula) : Prop :=
  ∀ (M : TaskModel F) (τ : WorldHistory F) (x : F.Duration), PlusTruthAt M τ x φ

end FormalSystem.Semantics

namespace FormalSystem.PlusLanguage

open FormalSystem.Syntax
open FormalSystem.PlusLanguage
open FormalSystem.Semantics


/-- `φ` is valid on every frame satisfying `P`. **The primitive**: the L⁺ mirror of
`ValidOnFrames`, indexed by a bare frame predicate rather than a `FrameClass` tag so that one
monotonicity lemma serves every bridge and so that validity over a class no tag denotes can be
stated directly. -/
def PlusValidOnFrames (P : TaskFrame → Prop) (φ : PlusFormula) : Prop :=
  ∀ F : TaskFrame, P F → F.PlusValidOn φ

/-- Class-restricted validity `⊨_C` for L⁺, at a `FrameClass` tag. The L⁺ mirror of `ValidIn`,
over the same `FrameClass.Sat`. -/
def PlusValidIn (fc : ProofSystem.FrameClass) (φ : PlusFormula) : Prop :=
  PlusValidOnFrames fc.Sat φ

/-- An L⁺ formula is **valid** if it is true in all models, at all times, at every world
history, over every task frame. `PlusValidIn` at the unconstrained class, exactly as `Valid` is
`ValidIn .Base`. -/
def PlusValid (φ : PlusFormula) : Prop :=
  PlusValidIn ProofSystem.FrameClass.Base φ

/-- Validity over dense frames. Mirror of `ValidDense`. -/
def PlusValidDense (φ : PlusFormula) : Prop := PlusValidIn ProofSystem.FrameClass.Dense φ

/-- Validity over discrete (succ-Archimedean) frames. Mirror of `ValidZTime`. -/
def PlusValidZTime (φ : PlusFormula) : Prop := PlusValidIn ProofSystem.FrameClass.ZTime φ

/-- Validity over dense Dedekind-complete frames. Mirror of `ValidRTime`. -/
def PlusValidRTime (φ : PlusFormula) : Prop := PlusValidIn ProofSystem.FrameClass.RTime φ

/-! ### Monotonicity -/

/-- `PlusValidOnFrames` is antitone in its frame predicate. Mirror of `ValidOnFrames.mono`. -/
theorem PlusValidOnFrames.mono {P Q : TaskFrame → Prop} {φ : PlusFormula}
    (h : ∀ F, Q F → P F) (hP : PlusValidOnFrames P φ) : PlusValidOnFrames Q φ :=
  GenericValidOnFrames.mono (L := PlusFormula) (φ := φ) h hP

/-- L⁺ validity is monotone in the `FrameClass` order. Mirror of `ValidIn.mono`. -/
theorem PlusValidIn.mono {fc₁ fc₂ : ProofSystem.FrameClass} {φ : PlusFormula} (h : fc₁ ≤ fc₂)
    (hv : PlusValidIn fc₁ φ) : PlusValidIn fc₂ φ :=
  GenericValidIn.mono (L := PlusFormula) (φ := φ) h hv

/-! ### Binder-shape adapters

Only the `.Base` pair: it discharges the vacuous `Sat .Base` argument. `PlusValidOnFrames` and
`PlusValidIn` quantify over `WorldHistory F` directly, so `intro` and application open them. -/

/-- Introduce `PlusValid` from its explicit binder shape; the `Sat .Base` argument (`True`) is
discharged here. Mirror of `Valid.of_forall`. -/
theorem PlusValid.of_forall_regular {φ : PlusFormula}
    (h : ∀ (F : TaskFrame) [F.IsRegular] (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration),
      PlusTruthAt M τ t φ) :
    PlusValid φ :=
  GenericValid.of_forall_regular (L := PlusFormula) (φ := φ) h

/-- Introduce `PlusValid` from its pre-abbreviation binder shape at **every** frame — the
sufficient form, for a formula whose truth argument consumes no `def:frame` constraint. -/
theorem PlusValid.of_forall {φ : PlusFormula}
    (h : ∀ (F : TaskFrame) (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration),
      PlusTruthAt M τ t φ) :
    PlusValid φ :=
  GenericValid.of_forall (L := PlusFormula) (φ := φ) h

/-- Eliminate `PlusValid` into its explicit binder shape. Mirror of `Valid.apply`. -/
theorem PlusValid.apply {φ : PlusFormula} (h : PlusValid φ) (F : TaskFrame) [F.IsRegular]
    (M : TaskModel F)
    (τ : WorldHistory F) (t : F.Duration) : PlusTruthAt M τ t φ :=
  GenericValid.apply (L := PlusFormula) (φ := φ) h F M τ t

/-! ## The truth-transfer bridge along `ofFormula` -/

variable {F : TaskFrame}

/--
**The truth-transfer bridge.** An L formula embedded into L⁺ is true exactly when it is true in
L, at the same model, history and time.

By induction on `φ`, `generalizing τ t`: the `box` case needs the hypothesis at a different
history and the two temporal cases at a different time. Every case is congruence, because the
six L clauses of `PlusTruthAt` are `TruthAt`'s verbatim and `ofFormula` is
constructor-to-constructor.
-/
theorem plusTruthAt_ofFormula (M : TaskModel F) (φ : Formula) :
    ∀ (τ : WorldHistory F) (t : F.Duration),
      PlusTruthAt M τ t (ofFormula φ) ↔ TruthAt M τ t φ := by
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

/-- The context-level form of the bridge. -/
theorem plusTruthAt_ofCtx (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    {Γ : Context} (h : ∀ ψ ∈ Γ, TruthAt M τ t ψ) :
    ∀ ψ ∈ ofCtx Γ, PlusTruthAt M τ t ψ := by
  intro ψ hψ
  obtain ⟨χ, hχ, rfl⟩ := List.mem_map.mp hψ
  exact (plusTruthAt_ofFormula M χ τ t).mpr (h χ hχ)

/-- **Transfer at a bare frame predicate.** L⁺ validity of an embedded L formula over the frames
satisfying `P` is L validity over the same frames. -/
theorem plusValidOnFrames_ofFormula_iff (P : TaskFrame → Prop) (φ : Formula) :
    PlusValidOnFrames P (ofFormula φ) ↔ ValidOnFrames P φ := by
  constructor
  · intro h F hF M τ t
    exact (plusTruthAt_ofFormula M φ τ t).mp (h F hF M τ t)
  · intro h F hF M τ t
    exact (plusTruthAt_ofFormula M φ τ t).mpr (h F hF M τ t)

/--
**Semantic conservativity of L⁺ over L, at every frame class.** An L formula is L⁺-valid over
the frames of `fc` iff it is L-valid over them. `plusValidOnFrames_ofFormula_iff` at `fc.Sat`.

Paper: — (formalization-native; L⁺ is the ⊡-only fragment of the paper's `\BL^\star`, for which the
paper supplies no logic)
-/
theorem plusValidIn_ofFormula_iff (fc : ProofSystem.FrameClass) (φ : Formula) :
    PlusValidIn fc (ofFormula φ) ↔ ValidIn fc φ :=
  plusValidOnFrames_ofFormula_iff fc.Sat φ

/-- Semantic conservativity at the unconstrained class: `plusValidIn_ofFormula_iff` at `.Base`. -/
theorem plusValid_ofFormula_iff (φ : Formula) : PlusValid (ofFormula φ) ↔ Valid φ :=
  plusValidIn_ofFormula_iff ProofSystem.FrameClass.Base φ

/-! ## The event-operator negation equivalence, stably

`cor:after-negation-stable` is **cut material**: it is not in the tracked paper, but is kept
verbatim in `JPL/appendix_cut_material.tex` under the header "Negation under the event operators,
stably". It is therefore a specification implemented here, not a theorem cited from the published
text. It states that

  `⊝After(φ,⊤) → (⟐¬After(φ,ψ) ↔ ⟐After(φ,¬ψ))`

is valid over every task frame, and likewise with `⊝` in place of both occurrences of `⟐`.

**Why this is stated natively in L⁺ rather than transported along the embedding.**
`plusValid_ofFormula_iff` above transports only formulas in the range of `ofFormula`, and
`ofFormula_ne_stab` (`PlusLanguage/Formula.lean`) proves that nothing in that range is a
top-level `stab`. The schema also ranges over arbitrary L⁺ `φ`, `ψ`, which may themselves
contain `⊝`. Both statements below are therefore transcriptions of the paper's corollary, not
second proofs of it: the mathematics is `TruthClauses.after_negation`, proved once in the
language-generic clause tier, and `Metalogic/SoundnessLemmas/EventOperators.lean` instantiates
the same lemma at L.

The paper's proof opens by observing that `τ ∈ ⟨τ⟩ₓ` makes `⊝χ → χ` valid, so that the guard
holds at `τ` itself. That step is not needed here: the `stab` clause *is*
`∀ σ, τ.state t = σ.state t → …`, so the guard is available at each `σ` directly and the
reflexive instance never has to be extracted.
-/

/--
**`cor:after-negation-stable`, existential (`⟐`) reading**, as an L⁺ validity over every task
frame:

  `⊨  ⊝After(φ,⊤) → (⟐¬After(φ,ψ) ↔ ⟐After(φ,¬ψ))`

Cut material (see the section note above), implemented from specification. Under the stable guard
`TruthClauses.after_negation` holds at every `σ` sharing `τ`'s present state, so the two
existential quantifications over `⟨τ⟩ₜ` are witnessed by the same `σ`.
-/
theorem after_negation_stable_dstab (φ ψ : PlusFormula) :
    PlusValid ((PlusFormula.after φ PlusFormula.top).stab.imp
      (PlusFormula.iff
        (PlusFormula.dstab (PlusFormula.after φ ψ).neg)
        (PlusFormula.dstab (PlusFormula.after φ ψ.neg)))) := by
  refine PlusValid.of_forall fun F M τ t => ?_
  rw [PlusTruth.imp_iff]
  intro hstab
  have hg := (PlusTruth.stab_iff M τ t _).mp hstab
  have hbi : ∀ σ : WorldHistory F, τ.state t = σ.state t →
      ((¬ PlusTruthAt M σ t (PlusFormula.after φ ψ)) ↔
        PlusTruthAt M σ t (PlusFormula.after φ ψ.neg)) :=
    fun σ hσ => TruthClauses.after_negation (L := PlusFormula) M σ t PUnit.unit φ ψ (hg σ hσ)
  rw [PlusFormula.iff, PlusTruth.and_iff, PlusTruth.imp_iff, PlusTruth.imp_iff]
  refine ⟨fun h => ?_, fun h => ?_⟩
  · obtain ⟨σ, hσ, hn⟩ := (PlusTruth.dstab_iff M τ t _).mp h
    exact (PlusTruth.dstab_iff M τ t _).mpr
      ⟨σ, hσ, (hbi σ hσ).mp ((PlusTruth.neg_iff M σ t _).mp hn)⟩
  · obtain ⟨σ, hσ, hp⟩ := (PlusTruth.dstab_iff M τ t _).mp h
    exact (PlusTruth.dstab_iff M τ t _).mpr
      ⟨σ, hσ, (PlusTruth.neg_iff M σ t _).mpr ((hbi σ hσ).mpr hp)⟩

/--
**`cor:after-negation-stable`, universal (`⊝`) reading**, as an L⁺ validity over every task
frame:

  `⊨  ⊝After(φ,⊤) → (⊝¬After(φ,ψ) ↔ ⊝After(φ,¬ψ))`

The paper's "and likewise with `⊝` in place of both occurrences of `⟐`". Same per-`σ`
biconditional as `after_negation_stable_dstab`, quantified universally over `⟨τ⟩ₜ` instead of
existentially.
-/
theorem after_negation_stable_stab (φ ψ : PlusFormula) :
    PlusValid ((PlusFormula.after φ PlusFormula.top).stab.imp
      (PlusFormula.iff
        (PlusFormula.after φ ψ).neg.stab
        (PlusFormula.after φ ψ.neg).stab)) := by
  refine PlusValid.of_forall fun F M τ t => ?_
  rw [PlusTruth.imp_iff]
  intro hstab
  have hg := (PlusTruth.stab_iff M τ t _).mp hstab
  have hbi : ∀ σ : WorldHistory F, τ.state t = σ.state t →
      ((¬ PlusTruthAt M σ t (PlusFormula.after φ ψ)) ↔
        PlusTruthAt M σ t (PlusFormula.after φ ψ.neg)) :=
    fun σ hσ => TruthClauses.after_negation (L := PlusFormula) M σ t PUnit.unit φ ψ (hg σ hσ)
  rw [PlusFormula.iff, PlusTruth.and_iff, PlusTruth.imp_iff, PlusTruth.imp_iff]
  refine ⟨fun h => ?_, fun h => ?_⟩
  · refine (PlusTruth.stab_iff M τ t _).mpr fun σ hσ => ?_
    exact (hbi σ hσ).mp
      ((PlusTruth.neg_iff M σ t _).mp ((PlusTruth.stab_iff M τ t _).mp h σ hσ))
  · refine (PlusTruth.stab_iff M τ t _).mpr fun σ hσ => ?_
    exact (PlusTruth.neg_iff M σ t _).mpr
      ((hbi σ hσ).mpr ((PlusTruth.stab_iff M τ t _).mp h σ hσ))

end FormalSystem.PlusLanguage
