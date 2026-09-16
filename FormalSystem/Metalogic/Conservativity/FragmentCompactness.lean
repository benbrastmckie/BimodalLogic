/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Conservativity.Fragment
import FormalSystem.Metalogic.Compactness

/-!
# Compactness of the base-language consequence relation at `.Base` and `.Dense`

The base-language mirror of `Metalogic/SetConsequence.lean`'s consequence-form compactness
`Compact fc`, transferred from the landed `compactBase` / `compactDense`
(`Metalogic/Compactness.lean`) along the translation `tr`.

## Main Definitions

- `MinusSetConsequenceOnFrames`, `MinusSetSemanticConsequenceOn` — set-premise consequence for
  `MinusFormula`, binder for binder against `SetConsequenceOnFrames` / `SetSemanticConsequenceOn`
- `MinusCompact fc` — the consequence form of compactness: a set-consequence yields a finite premise
  list whose `foldr`-implication into the conclusion is `MinusValidIn fc`

## Main Results

- `minusSetConsequence_iff_image` — L⁻ set-consequence is L set-consequence of the `tr`-image
- `tr_foldr_imp` — `tr` commutes with the `foldr`-implication
- `minusCompact_of_compact` — `Compact fc → MinusCompact fc`, by pulling the L witness list back
  along `tr`
- `minusCompactBase`, `minusCompactDense` — the two positive rows

## Which form landed

The **consequence form** (the mirror of `Compact`, `SetConsequence.lean`), not the
model-existence form: the witness list pulls back along `tr` by a straightforward induction
(`exists_preimage_list`), because every member of the L witness lies in `tr '' Γ` and `tr`
commutes with `imp` definitionally.

## The `.ZTime` and `.RTime` rows do NOT transfer

L's non-compactness at `.ZTime` (`notCompactZTime`, witness `{F p} ∪ {¬Xⁿ p}`) and at
`.RTime` (`notCompactRTime`, witness built from `K⁺`-shaped `untl` guards) uses formulas
**outside the range of `tr`**: `Formula.next` is `untl bot _` and `K⁺` is a top-level `untl`,
while by `MinusLanguage.tr_ne_untl` nothing in the range of `tr` is a top-level `untl`. So neither
refutation transfers to the base language, and no L⁻ non-compactness claim is made at those two
classes here. Only the two positive rows are delivered; whether `MinusCompact .ZTime` or
`MinusCompact .RTime` holds is left open.

## References

* `FormalSystem/Metalogic/SetConsequence.lean` — `SetConsequenceOnFrames`, `Compact`
* `FormalSystem/Metalogic/Compactness.lean` — `compactBase`, `compactDense`
* `FormalSystem/Metalogic/Conservativity/MinusLanguageSoundness.lean` — `truthAt_tr`,
  `minusValidIn_iff_validIn_tr`
-/

namespace FormalSystem.Metalogic.Conservativity

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.MinusLanguage
open FormalSystem.Semantics
open FormalSystem.Metalogic

/-- Set-premise consequence for the base language over the frames satisfying `P`. Binder-for-binder
mirror of `SetConsequenceOnFrames`, against `MinusTruthAt`. -/
def MinusSetConsequenceOnFrames (P : TaskFrame → Prop) (Γ : Set MinusFormula) (φ : MinusFormula) : Prop :=
  ∀ (F : TaskFrame), P F → ∀ (M : TaskModel F)
    (τ : PartialHistory F) (_ : τ.IsTotal) (t : F.Duration),
    (∀ ψ ∈ Γ, MinusTruthAt M τ t ψ) → MinusTruthAt M τ t φ

/-- Set-premise consequence for the base language at a `FrameClass` tag. Mirror of
`SetSemanticConsequenceOn`. -/
def MinusSetSemanticConsequenceOn (fc : FrameClass) (Γ : Set MinusFormula) (φ : MinusFormula) : Prop :=
  MinusSetConsequenceOnFrames fc.Sat Γ φ

/-- **Compactness of the base-language consequence relation at `fc`**, in the consequence form:
a set-consequence yields a finite premise list whose `foldr`-implication into the conclusion is
`MinusValidIn fc`. Mirror of `Compact`. -/
def MinusCompact (fc : FrameClass) : Prop :=
  ∀ (Γ : Set MinusFormula) (φ : MinusFormula), MinusSetSemanticConsequenceOn fc Γ φ →
    ∃ L : List MinusFormula, (∀ ψ ∈ L, ψ ∈ Γ) ∧ MinusValidIn fc (L.foldr MinusFormula.imp φ)

/-- L⁻ set-consequence over the frames satisfying `P` is L set-consequence of the `tr`-image
over the same frames, by the truth-transfer bridge `truthAt_tr` on every premise and on the
conclusion. -/
theorem minusSetConsequenceOnFrames_iff_image (P : TaskFrame → Prop) (Γ : Set MinusFormula)
    (φ : MinusFormula) :
    MinusSetConsequenceOnFrames P Γ φ ↔ SetConsequenceOnFrames P (tr '' Γ) (tr φ) := by
  constructor
  · intro h F hF M τ hτ t hΓ
    refine (truthAt_tr M φ τ t).mpr (h F hF M τ hτ t ?_)
    intro ψ hψ
    exact (truthAt_tr M ψ τ t).mp (hΓ (tr ψ) ⟨ψ, hψ, rfl⟩)
  · intro h F hF M τ hτ t hΓ
    refine (truthAt_tr M φ τ t).mp (h F hF M τ hτ t ?_)
    intro ψ' hψ'
    obtain ⟨ψ, hψ, rfl⟩ := hψ'
    exact (truthAt_tr M ψ τ t).mpr (hΓ ψ hψ)

/-- `minusSetConsequenceOnFrames_iff_image` at a `FrameClass` tag. -/
theorem minusSetConsequence_iff_image (fc : FrameClass) (Γ : Set MinusFormula) (φ : MinusFormula) :
    MinusSetSemanticConsequenceOn fc Γ φ ↔ SetSemanticConsequenceOn fc (tr '' Γ) (tr φ) :=
  minusSetConsequenceOnFrames_iff_image fc.Sat Γ φ

/-- `tr` commutes with the `foldr`-implication of a premise list, because `tr` is definitional on
`imp`. -/
theorem tr_foldr_imp (L : List MinusFormula) (φ : MinusFormula) :
    tr (L.foldr MinusFormula.imp φ) = (L.map tr).foldr Formula.imp (tr φ) := by
  induction L with
  | nil => rfl
  | cons ψ L ih => simp only [List.foldr_cons, List.map_cons, tr_imp, ih]

/-- Every list of L formulas drawn from `tr '' Γ` is the `tr`-image of a list drawn from `Γ`. -/
theorem exists_preimage_list (Γ : Set MinusFormula) :
    ∀ L' : List Formula, (∀ ψ ∈ L', ψ ∈ tr '' Γ) →
      ∃ L : List MinusFormula, (∀ ψ ∈ L, ψ ∈ Γ) ∧ L.map tr = L'
  | [], _ => ⟨[], fun _ h => absurd h List.not_mem_nil, rfl⟩
  | ψ :: L', h => by
      obtain ⟨χ, hχ, rfl⟩ := h ψ List.mem_cons_self
      obtain ⟨L, hL, hmap⟩ :=
        exists_preimage_list Γ L' (fun ψ' h' => h ψ' (List.mem_cons_of_mem _ h'))
      refine ⟨χ :: L, ?_, by simp [hmap]⟩
      intro x hx
      rcases List.mem_cons.mp hx with rfl | hx
      · exact hχ
      · exact hL x hx

/--
**Transfer of compactness along `tr`.** From `Compact fc`, obtain the L witness list for the
image consequence `tr '' Γ ⊨ tr φ`, pull it back along `tr` (`exists_preimage_list`), and read
the `MinusValidIn` conclusion off `minusValidIn_iff_validIn_tr` after rewriting with `tr_foldr_imp`.
-/
theorem minusCompact_of_compact {fc : FrameClass} (h : Compact fc) : MinusCompact fc := by
  intro Γ φ hcons
  obtain ⟨L', hL', hval⟩ := h (tr '' Γ) (tr φ) ((minusSetConsequence_iff_image fc Γ φ).mp hcons)
  obtain ⟨L, hL, rfl⟩ := exists_preimage_list Γ L' hL'
  refine ⟨L, hL, (minusValidIn_iff_validIn_tr fc _).mpr ?_⟩
  rw [tr_foldr_imp]
  exact hval

/-- **Compactness of the base-language consequence relation at `.Base`.** -/
theorem minusCompactBase : MinusCompact FrameClass.Base :=
  minusCompact_of_compact compactBase

/-- **Compactness of the base-language consequence relation at `.Dense`.** -/
theorem minusCompactDense : MinusCompact FrameClass.Dense :=
  minusCompact_of_compact compactDense

end FormalSystem.Metalogic.Conservativity
