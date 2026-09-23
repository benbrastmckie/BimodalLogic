/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.HybridLanguage.HybridTruth
import FormalSystem.PlusLanguage.PlusValidity
import FormalSystem.Semantics.ValidityLayer
import FormalSystem.Semantics.Validity

/-!
# Validity for the hybrid state language, and conservativity over L⁺

Validity for `HybridFormula` (`FormalSystem/HybridLanguage/Formula.lean`), stated against the
native `HybridTruthAt` of `HybridLanguage/HybridTruth.lean`. Each predicate is a binder-for-binder
mirror of its L⋆ counterpart in `StarLanguage/StarValidity.lean`, with the register vector
`r : ℕ → WorldState` as the innermost binder where L⋆ has its stored-time vector:
`TaskFrame.HybridValidOn` of `TaskFrame.StarValidOn`, `HybridValidOnFrames` of
`StarValidOnFrames`, `HybridValidIn` of `StarValidIn`, `HybridValid` of `StarValid`.

**Validity quantifies over every register vector.** That is what makes a free register a state
nominal: a formula with a free `reg i` is valid iff it is true however `i` is assigned.

The language has **no proof system**: every result here is semantic.

## Main Definitions

- `TaskFrame.HybridValidOn`, `HybridValidOnFrames`, `HybridValidIn`, `HybridValid`

## Main Results

- `HybridValidOnFrames.mono`, `HybridValidIn.mono`; `HybridValid.of_forall` / `.apply`
- `hybridValidOn_ofPlus_iff`, `hybridValidOnFrames_ofPlus_iff`, `hybridValidIn_ofPlus_iff`,
  `hybridValid_ofPlus_iff` — **semantic conservativity over L⁺**, at a frame, at a frame
  predicate, at every frame class, and at the unconstrained class

## References

* JPL paper `def:frame-validity` — validity over a frame
* `FormalSystem/StarLanguage/StarValidity.lean` — the L⋆ predicates these mirror, with the same
  extra innermost binder
* `FormalSystem/PlusLanguage/PlusValidity.lean` — the L⁺ predicates conservativity lands in
* `FormalSystem/Semantics/ValidityLayer.lean` — the generic layer every theorem body delegates to

## Tags

validity · hybrid-language · conservativity · state-nominal
-/

namespace FormalSystem.HybridLanguage

open FormalSystem.Syntax
open FormalSystem.PlusLanguage
open FormalSystem.Semantics

/-! ## `FrameClass`-indexed validity -/

/-- The hybrid state language's instance of the abstract point-truth class of
`Semantics/ValidityLayer.lean`: truth at the point `(M, τ, t)` is truth at **every register
vector**. The register vector is folded in as the innermost binder, exactly as L⋆ folds in its
stored-time vector, so `TaskFrame.HybridValidOn` below is definitionally the generic
`TaskFrame.GenericValidOn` at this instance. -/
instance : PointTruth HybridFormula where
  sat {F} M τ t φ := ∀ r : ℕ → F.WorldState, HybridTruthAt M τ t r φ

end FormalSystem.HybridLanguage

namespace FormalSystem.Semantics

open FormalSystem.HybridLanguage

/-- `def:frame-validity` for the hybrid state language: `φ` is valid over the frame `F` iff it is
true at every model over `F`, every possible world `τ ∈ H_F`, every time, and **every register
vector**. The mirror of `TaskFrame.StarValidOn`. -/
def TaskFrame.HybridValidOn (F : TaskFrame) (φ : HybridFormula) : Prop :=
  ∀ (M : TaskModel F) (τ : WorldHistory F) (x : F.Duration) (r : ℕ → F.WorldState),
    HybridTruthAt M τ x r φ

end FormalSystem.Semantics

namespace FormalSystem.HybridLanguage

open FormalSystem.Syntax
open FormalSystem.PlusLanguage
open FormalSystem.Semantics

/-- `φ` is valid on every frame satisfying `P`. **The primitive**, indexed by a bare frame
predicate rather than a `FrameClass` tag — which is what lets validity over the recurrence-free
members of a class, a class no tag denotes, be stated directly. -/
def HybridValidOnFrames (P : TaskFrame → Prop) (φ : HybridFormula) : Prop :=
  ∀ F : TaskFrame, P F → F.HybridValidOn φ

/-- Class-restricted validity, at a `FrameClass` tag. The mirror of `StarValidIn`. -/
def HybridValidIn (fc : ProofSystem.FrameClass) (φ : HybridFormula) : Prop :=
  HybridValidOnFrames fc.Sat φ

/-- A formula of the hybrid state language is **valid** if it is true in all models, at all
times, at every register vector, at every possible world, over every task frame. -/
def HybridValid (φ : HybridFormula) : Prop :=
  HybridValidIn ProofSystem.FrameClass.Base φ

/-! ### Monotonicity -/

/-- `HybridValidOnFrames` is antitone in its frame predicate. -/
theorem HybridValidOnFrames.mono {P Q : TaskFrame → Prop} {φ : HybridFormula}
    (h : ∀ F, Q F → P F) (hP : HybridValidOnFrames P φ) : HybridValidOnFrames Q φ :=
  GenericValidOnFrames.mono (L := HybridFormula) (φ := φ) h hP

/-- Validity is monotone in the `FrameClass` order. -/
theorem HybridValidIn.mono {fc₁ fc₂ : ProofSystem.FrameClass} {φ : HybridFormula}
    (h : fc₁ ≤ fc₂) (hv : HybridValidIn fc₁ φ) : HybridValidIn fc₂ φ :=
  GenericValidIn.mono (L := HybridFormula) (φ := φ) h hv

/-! ### Binder-shape adapters -/

/-- Introduce `HybridValid` from its explicit binder shape; the `Sat .Base` argument (`True`) is
discharged here. -/
theorem HybridValid.of_forall_regular {φ : HybridFormula}
    (h : ∀ (F : TaskFrame) [F.IsRegular] (M : TaskModel F) (τ : WorldHistory F) (x : F.Duration)
      (r : ℕ → F.WorldState), HybridTruthAt M τ x r φ) :
    HybridValid φ :=
  GenericValid.of_forall_regular (L := HybridFormula) (φ := φ) h

/-- Introduce `HybridValid` from its explicit binder shape at **every** frame — the sufficient
form. -/
theorem HybridValid.of_forall {φ : HybridFormula}
    (h : ∀ (F : TaskFrame) (M : TaskModel F) (τ : WorldHistory F) (x : F.Duration)
      (r : ℕ → F.WorldState), HybridTruthAt M τ x r φ) :
    HybridValid φ :=
  GenericValid.of_forall (L := HybridFormula) (φ := φ) h

/-- Eliminate `HybridValid` into its explicit binder shape. -/
theorem HybridValid.apply {φ : HybridFormula} (h : HybridValid φ) (F : TaskFrame) [F.IsRegular]
    (M : TaskModel F) (τ : WorldHistory F) (x : F.Duration) (r : ℕ → F.WorldState) :
    HybridTruthAt M τ x r φ :=
  GenericValid.apply (L := HybridFormula) (φ := φ) h F M τ x r

/-! ## Semantic conservativity over L⁺ -/

/-- Conservativity at a single frame. Immediate from `hybridTruthAt_ofPlus`, the register binder
being vacuous on the image of `ofPlus`; the `→` direction needs some register vector, and the
constant vector at the present world state is one. -/
theorem hybridValidOn_ofPlus_iff (F : TaskFrame) (φ : PlusFormula) :
    F.HybridValidOn (HybridFormula.ofPlus φ) ↔ F.PlusValidOn φ := by
  constructor
  · intro h M τ x
    exact (hybridTruthAt_ofPlus M τ x (fun _ => τ.state x) φ).mp (h M τ x (fun _ => τ.state x))
  · intro h M τ x r
    exact (hybridTruthAt_ofPlus M τ x r φ).mpr (h M τ x)

/-- Conservativity at a bare frame predicate. -/
theorem hybridValidOnFrames_ofPlus_iff (P : TaskFrame → Prop) (φ : PlusFormula) :
    HybridValidOnFrames P (HybridFormula.ofPlus φ) ↔ PlusValidOnFrames P φ :=
  forall_congr' fun F => imp_congr_right fun _ => hybridValidOn_ofPlus_iff F φ

/-- **Semantic conservativity of the hybrid state language over L⁺, at every frame class.**

Paper: — (formalization-native; the paper has no state registers) -/
theorem hybridValidIn_ofPlus_iff (fc : ProofSystem.FrameClass) (φ : PlusFormula) :
    HybridValidIn fc (HybridFormula.ofPlus φ) ↔ PlusValidIn fc φ :=
  hybridValidOnFrames_ofPlus_iff fc.Sat φ

/-- Semantic conservativity at the unconstrained class: an L⁺ formula is valid in the hybrid
state language iff it is L⁺-valid. -/
theorem hybridValid_ofPlus_iff (φ : PlusFormula) :
    HybridValid (HybridFormula.ofPlus φ) ↔ PlusValid φ :=
  hybridValidIn_ofPlus_iff ProofSystem.FrameClass.Base φ

end FormalSystem.HybridLanguage
