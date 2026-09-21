/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.OpenLanguage.OpenTruth
import FormalSystem.PlusLanguage.PlusValidity
import FormalSystem.Semantics.ValidityLayer
import FormalSystem.Semantics.Validity

/-!
# L^▷ validity — conservativity over L⁺, S5 for `▷` and `◁`, and the strength ordering

Validity for the language L^▷ (`FormalSystem/OpenLanguage/Formula.lean`), stated against the
native `OpenTruthAt` of `OpenLanguage/OpenTruth.lean`. Each predicate is a binder-for-binder
mirror of its L⁺ counterpart in `PlusLanguage/PlusValidity.lean`: `TaskFrame.OpenValidOn` of
`TaskFrame.PlusValidOn`, `OpenValidOnFrames` of `PlusValidOnFrames`, `OpenValidIn` of
`PlusValidIn`, `OpenValid` of `PlusValid`.

L^▷ has **no proof system**: every result here is semantic. The S5 laws and the strength ordering
are stated as validities so that they can be compared with, and eventually drive, an
axiomatization; none is claimed here.

## Main Definitions

- `TaskFrame.OpenValidOn`, `OpenValidOnFrames`, `OpenValidIn`, `OpenValid`

## Main Results

- `OpenValidOnFrames.mono`, `OpenValidIn.mono`; `OpenValid.of_forall` / `.apply` / `.of_not`
- `openValidOn_ofPlus_iff`, `openValidOnFrames_ofPlus_iff`, `openValidIn_ofPlus_iff`,
  `openValid_ofPlus_iff` — **semantic conservativity of L^▷ over L⁺**, at a frame, at a frame
  predicate, at every frame class, and at the unconstrained class
- **S5 for `▷`**: `openValid_ofut_k`, `openValid_ofut_t`, `openValid_ofut_four`,
  `openValid_ofut_five`; **S5 for `◁`**: the four `opast` mirrors. The manuscript observes that
  `⟨τ⟩_x` "is an equivalence class", so that "the monomodal logic of `⊡` is also S5"; the same
  argument applies to `|τ⟩_x` and `⟨τ|_x`
- **The strength ordering** `□ ⟹ ⊡ ⟹ ▷` and `⊡ ⟹ ◁`: `openValid_stab_of_box`,
  `openValid_ofut_of_stab`, `openValid_opast_of_stab`. The failure of each converse is in
  `OpenLanguage/OpenOckhamist.lean`

## References

* JPL paper `def:frame-validity` — validity over a frame
* JPL paper `sub:RestrictedModalities` — the three classes and their inclusions
* `FormalSystem/PlusLanguage/PlusValidity.lean` — the L⁺ predicates these mirror
* `FormalSystem/Semantics/ValidityLayer.lean` — the generic layer every theorem body delegates to

## Tags

validity · open-language · conservativity · open-future · open-past
-/

namespace FormalSystem.OpenLanguage

open FormalSystem.Syntax
open FormalSystem.PlusLanguage
open FormalSystem.Semantics

/-! ## `FrameClass`-indexed validity for L^▷ -/

/-- L^▷'s instance of the abstract point-truth class of `Semantics/ValidityLayer.lean`: truth at
the point `(M, τ, t)` is `OpenTruthAt`. -/
instance : PointTruth OpenFormula where
  sat M τ t φ := OpenTruthAt M τ t φ

end FormalSystem.OpenLanguage

namespace FormalSystem.Semantics

open FormalSystem.OpenLanguage

/-- `def:frame-validity` for L^▷: `φ` is valid over the frame `F` iff it is true at every model
over `F`, every possible world `τ ∈ H_F`, and every time. The L^▷ mirror of
`TaskFrame.PlusValidOn`. -/
def TaskFrame.OpenValidOn (F : TaskFrame) (φ : OpenFormula) : Prop :=
  ∀ (M : TaskModel F) (τ : WorldHistory F) (x : F.Duration), OpenTruthAt M τ x φ

end FormalSystem.Semantics

namespace FormalSystem.OpenLanguage

open FormalSystem.Syntax
open FormalSystem.PlusLanguage
open FormalSystem.OpenLanguage.OpenFormula
open FormalSystem.Semantics

/-- `φ` is valid on every frame satisfying `P`. **The primitive**: the L^▷ mirror of
`PlusValidOnFrames`. -/
def OpenValidOnFrames (P : TaskFrame → Prop) (φ : OpenFormula) : Prop :=
  ∀ F : TaskFrame, P F → F.OpenValidOn φ

/-- Class-restricted validity for L^▷, at a `FrameClass` tag. The L^▷ mirror of `PlusValidIn`. -/
def OpenValidIn (fc : ProofSystem.FrameClass) (φ : OpenFormula) : Prop :=
  OpenValidOnFrames fc.Sat φ

/-- An L^▷ formula is **valid** if it is true in all models, at all times, at every world
history, over every task frame. `OpenValidIn` at the unconstrained class. -/
def OpenValid (φ : OpenFormula) : Prop :=
  OpenValidIn ProofSystem.FrameClass.Base φ

/-! ### Monotonicity -/

/-- `OpenValidOnFrames` is antitone in its frame predicate. -/
theorem OpenValidOnFrames.mono {P Q : TaskFrame → Prop} {φ : OpenFormula}
    (h : ∀ F, Q F → P F) (hP : OpenValidOnFrames P φ) : OpenValidOnFrames Q φ :=
  GenericValidOnFrames.mono (L := OpenFormula) (φ := φ) h hP

/-- L^▷ validity is monotone in the `FrameClass` order. -/
theorem OpenValidIn.mono {fc₁ fc₂ : ProofSystem.FrameClass} {φ : OpenFormula} (h : fc₁ ≤ fc₂)
    (hv : OpenValidIn fc₁ φ) : OpenValidIn fc₂ φ :=
  GenericValidIn.mono (L := OpenFormula) (φ := φ) h hv

/-! ### Binder-shape adapters -/

/-- Introduce `OpenValid` from its explicit binder shape; the `Sat .Base` argument (`True`) is
discharged here. -/
theorem OpenValid.of_forall {φ : OpenFormula}
    (h : ∀ (F : TaskFrame) (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration),
      OpenTruthAt M τ t φ) :
    OpenValid φ :=
  GenericValid.of_forall (L := OpenFormula) (φ := φ) h

/-- Eliminate `OpenValid` into its explicit binder shape. -/
theorem OpenValid.apply {φ : OpenFormula} (h : OpenValid φ) (F : TaskFrame) (M : TaskModel F)
    (τ : WorldHistory F) (t : F.Duration) : OpenTruthAt M τ t φ :=
  GenericValid.apply (L := OpenFormula) (φ := φ) h F M τ t

/-- The contrapositive of `OpenValid.of_forall`, in the shape a countermodel extraction wants. -/
theorem OpenValid.of_not {φ : OpenFormula} (h : ¬ OpenValid φ) :
    ¬ ∀ (F : TaskFrame) (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration),
        OpenTruthAt M τ t φ :=
  GenericValid.of_not (L := OpenFormula) (φ := φ) h

/-! ## Semantic conservativity of L^▷ over L⁺ -/

/-- Conservativity at a single frame. -/
theorem openValidOn_ofPlus_iff (F : TaskFrame) (φ : PlusFormula) :
    F.OpenValidOn (ofPlus φ) ↔ F.PlusValidOn φ :=
  ⟨fun h M τ t => (openTruthAt_ofPlus M τ t φ).mp (h M τ t),
    fun h M τ t => (openTruthAt_ofPlus M τ t φ).mpr (h M τ t)⟩

/-- Conservativity at a bare frame predicate. -/
theorem openValidOnFrames_ofPlus_iff (P : TaskFrame → Prop) (φ : PlusFormula) :
    OpenValidOnFrames P (ofPlus φ) ↔ PlusValidOnFrames P φ :=
  ⟨fun h F hF => (openValidOn_ofPlus_iff F φ).mp (h F hF),
    fun h F hF => (openValidOn_ofPlus_iff F φ).mpr (h F hF)⟩

/-- **Semantic conservativity of L^▷ over L⁺, at every frame class.** -/
theorem openValidIn_ofPlus_iff (fc : ProofSystem.FrameClass) (φ : PlusFormula) :
    OpenValidIn fc (ofPlus φ) ↔ PlusValidIn fc φ :=
  openValidOnFrames_ofPlus_iff fc.Sat φ

/-- Semantic conservativity at the unconstrained class: an L⁺ formula is L^▷-valid iff it is
L⁺-valid. -/
theorem openValid_ofPlus_iff (φ : PlusFormula) : OpenValid (ofPlus φ) ↔ PlusValid φ :=
  openValidIn_ofPlus_iff ProofSystem.FrameClass.Base φ

/-! ## S5 for `▷` -/

/-- **K for `▷`**. -/
theorem openValid_ofut_k (φ ψ : OpenFormula) :
    OpenValid (imp (ofut (imp φ ψ)) (imp (ofut φ) (ofut ψ))) :=
  OpenValid.of_forall fun _ M τ t h hφ => ofut_k M τ t φ ψ h hφ

/-- **T for `▷`**: `▷φ → φ`. -/
theorem openValid_ofut_t (φ : OpenFormula) : OpenValid (imp (ofut φ) φ) :=
  OpenValid.of_forall fun _ M τ t h => of_ofut M τ t φ h

/-- **4 for `▷`**: `▷φ → ▷▷φ`. -/
theorem openValid_ofut_four (φ : OpenFormula) : OpenValid (imp (ofut φ) (ofut (ofut φ))) :=
  OpenValid.of_forall fun _ M τ t h => ofut_four M τ t φ h

/-- **5 for `▷`**: `▷̂φ → ▷▷̂φ`. -/
theorem openValid_ofut_five (φ : OpenFormula) :
    OpenValid (imp (dofut φ) (ofut (dofut φ))) :=
  OpenValid.of_forall fun _ M τ t h => ofut_five M τ t φ h

/-! ## S5 for `◁` -/

/-- **K for `◁`**. -/
theorem openValid_opast_k (φ ψ : OpenFormula) :
    OpenValid (imp (opast (imp φ ψ)) (imp (opast φ) (opast ψ))) :=
  OpenValid.of_forall fun _ M τ t h hφ => opast_k M τ t φ ψ h hφ

/-- **T for `◁`**: `◁φ → φ`. -/
theorem openValid_opast_t (φ : OpenFormula) : OpenValid (imp (opast φ) φ) :=
  OpenValid.of_forall fun _ M τ t h => of_opast M τ t φ h

/-- **4 for `◁`**: `◁φ → ◁◁φ`. -/
theorem openValid_opast_four (φ : OpenFormula) :
    OpenValid (imp (opast φ) (opast (opast φ))) :=
  OpenValid.of_forall fun _ M τ t h => opast_four M τ t φ h

/-- **5 for `◁`**: `◁̂φ → ◁◁̂φ`. -/
theorem openValid_opast_five (φ : OpenFormula) :
    OpenValid (imp (dopast φ) (opast (dopast φ))) :=
  OpenValid.of_forall fun _ M τ t h => opast_five M τ t φ h

/-! ## The strength ordering `□ ⟹ ⊡ ⟹ ▷` and `⊡ ⟹ ◁` -/

/-- **`□φ → ⊡φ`**. -/
theorem openValid_stab_of_box (φ : OpenFormula) : OpenValid (imp (box φ) (stab φ)) :=
  OpenValid.of_forall fun _ M τ t h => stab_of_box M τ t φ h

/-- **`⊡φ → ▷φ`**: stability is the stronger necessity. -/
theorem openValid_ofut_of_stab (φ : OpenFormula) : OpenValid (imp (stab φ) (ofut φ)) :=
  OpenValid.of_forall fun _ M τ t h => ofut_of_stab M τ t φ h

/-- **`⊡φ → ◁φ`**. -/
theorem openValid_opast_of_stab (φ : OpenFormula) : OpenValid (imp (stab φ) (opast φ)) :=
  OpenValid.of_forall fun _ M τ t h => opast_of_stab M τ t φ h

end FormalSystem.OpenLanguage
