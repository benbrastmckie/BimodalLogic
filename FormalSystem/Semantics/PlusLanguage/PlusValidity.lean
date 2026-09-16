/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.PlusLanguage.PlusTruth
import FormalSystem.Semantics.ValidityLayer
import FormalSystem.Semantics.Validity

/-!
# L⁺ validity — the `PlusFormula` mirrors of `Semantics/Validity.lean`

Validity for the language L⁺ (`FormalSystem/PlusLanguage/Formula.lean`), stated against the
native `PlusTruthAt` of `Semantics/PlusLanguage/PlusTruth.lean`, plus the **truth-transfer bridge** along the
embedding `ofFormula : Formula → PlusFormula` and the **semantic conservativity** of L⁺ over
L that follows from it at every frame class.

Each predicate here is a binder-for-binder mirror of its counterpart in `Semantics/Validity.lean`
(and of the base-language mirror in `Semantics/MinusLanguage/MinusValidity.lean`): `TaskFrame.PlusValidOn` of
`TaskFrame.ValidOn`, `PlusValidOnFrames` of `ValidOnFrames`, `PlusValidIn` of `ValidIn`,
`PlusValid` of `Valid`. The frame-predicate form `PlusValidOnFrames` is the **primitive**, and
`PlusValidIn fc := PlusValidOnFrames fc.Sat` its instance at a tag — exactly the shape that lets
one monotonicity lemma serve every bridge, and that lets a validity notion over a frame class no
`FrameClass` tag denotes (for instance the deterministic frames) be stated without touching the
semantics.

## Main Definitions

- `TaskFrame.PlusValidOn`, `PlusValidOnFrames`, `PlusValidIn`, `PlusValid`
- `PlusValidDense`, `PlusValidZTime`, `PlusValidRTime` — the per-class abbreviations

## Main Results

- `PlusValidOnFrames.mono`, `PlusValidIn.mono` — monotonicity
- `PlusValidIn.of_forall_total` / `.apply_total` and the `PlusValidOnFrames` forms — the
  binder-shape adapters
- `plusTruthAt_ofFormula` — **the truth-transfer bridge**: an L formula is true in L⁺ exactly
  when it is true in L, at the same model, history and time
- `plusValidIn_ofFormula_iff` — **semantic conservativity of L⁺ over L, at every frame
  class**; `plusValid_ofFormula_iff` is its `.Base` instance

## References

* JPL paper `def:frame-validity`, `def:logical-consequence`, `cor:tm-completeness`
* `FormalSystem/Semantics/Validity.lean` — the L predicates these mirror
* `FormalSystem/Semantics/MinusLanguage/MinusValidity.lean` — the base-language mirror, the same shape

## Tags

validity · plus-language · conservativity · stability-modal
-/

namespace FormalSystem.Semantics

open FormalSystem.Syntax
open FormalSystem.PlusLanguage

/-! ## `FrameClass`-indexed validity for L⁺ -/

/-- L⁺'s instance of the abstract point-truth class of `Semantics/ValidityLayer.lean`: truth at
the point `(M, τ, t)` is `PlusTruthAt`. Every validity-layer theorem below delegates to the
generic one through this single field. -/
instance : PointTruth PlusFormula where
  sat M τ t φ := PlusTruthAt M τ t φ

/-- `def:frame-validity` for L⁺: `φ` is valid over the frame `F` iff it is true at every model
over `F`, every possible world `τ ∈ H_F`, and every time. The L⁺ mirror of
`TaskFrame.ValidOn`. -/
def TaskFrame.PlusValidOn (F : TaskFrame) (φ : PlusFormula) : Prop :=
  ∀ (M : TaskModel F) (τ : WorldHistory F) (x : F.Duration), PlusTruthAt M τ.val x φ

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

/-- An L⁺ formula is **valid** if it is true in all models, at all times, at every **total**
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

`PlusValidOnFrames` is stated over the bundled `(τ : WorldHistory F)`; every proof that consumes
or produces it works with the unbundled pair `(τ : PartialHistory F) (hτ : τ.IsTotal)`. These four
are the adapters, exactly as on the L and L⁻ sides. -/

/-- Introduce `PlusValidOnFrames` from the unbundled shape. -/
theorem PlusValidOnFrames.of_forall_total {P : TaskFrame → Prop} {φ : PlusFormula}
    (h : ∀ (F : TaskFrame), P F → ∀ (M : TaskModel F) (τ : PartialHistory F),
           τ.IsTotal → ∀ t : F.Duration, PlusTruthAt M τ t φ) :
    PlusValidOnFrames P φ :=
  GenericValidOnFrames.of_forall_total (L := PlusFormula) (φ := φ) h

/-- Eliminate `PlusValidOnFrames` into the unbundled shape. -/
theorem PlusValidOnFrames.apply_total {P : TaskFrame → Prop} {φ : PlusFormula}
    (h : PlusValidOnFrames P φ) (F : TaskFrame) (hF : P F) (M : TaskModel F)
    (τ : PartialHistory F) (hτ : τ.IsTotal) (t : F.Duration) : PlusTruthAt M τ t φ :=
  GenericValidOnFrames.apply_total (L := PlusFormula) (φ := φ) h F hF M τ hτ t

/-- `PlusValidOnFrames.of_forall_total` at a `FrameClass` tag. -/
theorem PlusValidIn.of_forall_total {fc : ProofSystem.FrameClass} {φ : PlusFormula}
    (h : ∀ (F : TaskFrame), fc.Sat F → ∀ (M : TaskModel F) (τ : PartialHistory F),
           τ.IsTotal → ∀ t : F.Duration, PlusTruthAt M τ t φ) :
    PlusValidIn fc φ :=
  GenericValidIn.of_forall_total (L := PlusFormula) (φ := φ) h

/-- `PlusValidOnFrames.apply_total` at a `FrameClass` tag. -/
theorem PlusValidIn.apply_total {fc : ProofSystem.FrameClass} {φ : PlusFormula}
    (h : PlusValidIn fc φ) (F : TaskFrame) (hF : fc.Sat F) (M : TaskModel F)
    (τ : PartialHistory F) (hτ : τ.IsTotal) (t : F.Duration) : PlusTruthAt M τ t φ :=
  GenericValidIn.apply_total (L := PlusFormula) (φ := φ) h F hF M τ hτ t

/-- Introduce `PlusValid` from the unbundled shape; the `Sat .Base` argument (`True`) is
discharged here. Mirror of `Valid.of_forall_total`. -/
theorem PlusValid.of_forall_total {φ : PlusFormula}
    (h : ∀ (F : TaskFrame) (M : TaskModel F) (τ : PartialHistory F),
           τ.IsTotal → ∀ t : F.Duration, PlusTruthAt M τ t φ) :
    PlusValid φ :=
  GenericValid.of_forall_total (L := PlusFormula) (φ := φ) h

/-- Eliminate `PlusValid` into the unbundled shape. Mirror of `Valid.apply`. -/
theorem PlusValid.apply {φ : PlusFormula} (h : PlusValid φ) (F : TaskFrame) (M : TaskModel F)
    (τ : PartialHistory F) (hτ : τ.IsTotal) (t : F.Duration) : PlusTruthAt M τ t φ :=
  GenericValid.apply (L := PlusFormula) (φ := φ) h F M τ hτ t

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
    ∀ (τ : PartialHistory F) (t : F.Duration),
      PlusTruthAt M τ t (ofFormula φ) ↔ TruthAt M τ t φ := by
  induction φ with
  | atom p => intro τ t; exact Iff.rfl
  | bot => intro τ t; exact Iff.rfl
  | imp φ ψ ihφ ihψ => intro τ t; exact Iff.imp (ihφ τ t) (ihψ τ t)
  | box φ ih => intro τ t; exact forall_congr' fun σ => imp_congr_right fun _ => ih σ t
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
theorem plusTruthAt_ofCtx (M : TaskModel F) (τ : PartialHistory F) (t : F.Duration)
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
  · intro h
    refine ValidOnFrames.of_forall_total ?_
    intro F hF M τ hτ t
    exact (plusTruthAt_ofFormula M φ τ t).mp (PlusValidOnFrames.apply_total h F hF M τ hτ t)
  · intro h
    refine PlusValidOnFrames.of_forall_total ?_
    intro F hF M τ hτ t
    exact (plusTruthAt_ofFormula M φ τ t).mpr (ValidOnFrames.apply_total h F hF M τ hτ t)

/--
**Semantic conservativity of L⁺ over L, at every frame class.** An L formula is L⁺-valid over
the frames of `fc` iff it is L-valid over them. `plusValidOnFrames_ofFormula_iff` at `fc.Sat`.

Paper: — (formalization-native; L⁺ is the ⊡-only fragment of the paper's `\BL^\star`, for which the paper supplies no logic)
-/
theorem plusValidIn_ofFormula_iff (fc : ProofSystem.FrameClass) (φ : Formula) :
    PlusValidIn fc (ofFormula φ) ↔ ValidIn fc φ :=
  plusValidOnFrames_ofFormula_iff fc.Sat φ

/-- Semantic conservativity at the unconstrained class: `plusValidIn_ofFormula_iff` at `.Base`. -/
theorem plusValid_ofFormula_iff (φ : Formula) : PlusValid (ofFormula φ) ↔ Valid φ :=
  plusValidIn_ofFormula_iff ProofSystem.FrameClass.Base φ

end FormalSystem.Semantics
