/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.ProofSystem
import FormalSystem.Metalogic.Core.MaximalConsistent
import FormalSystem.Theorems.Propositional.Connectives
import FormalSystem.Theorems.Combinators
import FormalSystem.Theorems.Perpetuity

/-!
# Lindenbaum Quotient Construction

This module defines the Lindenbaum-Tarski algebra as the quotient of formulas
by provable equivalence.

## Main Definitions

- `ProvEquiv`: Provable equivalence relation `φ ~ ψ ↔ ⊢ φ ↔ ψ`
- `LindenbaumAlg`: The quotient type `Formula / ProvEquiv`
- Lifted operations on the quotient

## Key Results

- `ProvEquiv` is an equivalence relation
- `ProvEquiv` is a congruence for all logical operations
- Quotient lifts are well-defined

-/

namespace FormalSystem.Metalogic.Algebraic.LindenbaumQuotient

open FormalSystem.Syntax FormalSystem.ProofSystem

/-!
## Provable Equivalence
-/

/--
Derives relation: `Derives φ ψ` means `⊢ φ → ψ` (derivable from empty context).

This is the primitive ordering used to define provable equivalence.
-/
def Derives (φ ψ : Formula) : Prop := Derivable FrameClass.Base [] (φ.imp ψ)

/--
Provable equivalence: `ProvEquiv φ ψ` means `⊢ φ ↔ ψ`.

Two formulas are provably equivalent if each implies the other.
-/
def ProvEquiv (φ ψ : Formula) : Prop := Derives φ ψ ∧ Derives ψ φ

/-- Infix notation for provable equivalence: `φ ≈ₚ ψ` unfolds to `ProvEquiv φ ψ`. -/
scoped infix:50 " ≈ₚ " => ProvEquiv

/-!
## Equivalence Relation Properties
-/

/--
Identity derivation: `⊢ φ → φ`.
-/
theorem derives_refl (φ : Formula) : Derives φ φ := by
  unfold Derives
  exact ⟨FormalSystem.Theorems.Combinators.identity φ⟩

/--
Provable equivalence is reflexive.
-/
theorem provEquiv_refl (φ : Formula) : φ ≈ₚ φ :=
  ⟨derives_refl φ, derives_refl φ⟩

/--
Provable equivalence is symmetric.
-/
theorem provEquiv_symm {φ ψ : Formula} (h : φ ≈ₚ ψ) : ψ ≈ₚ φ :=
  ⟨h.2, h.1⟩

/--
Transitivity of derivability via hypothetical syllogism.
-/
theorem derives_trans {φ ψ χ : Formula} (h1 : Derives φ ψ) (h2 : Derives ψ χ) :
    Derives φ χ := by
  unfold Derives at *
  obtain ⟨d1⟩ := h1
  obtain ⟨d2⟩ := h2
  exact ⟨FormalSystem.Theorems.Combinators.impTrans d1 d2⟩

/--
Provable equivalence is transitive.
-/
theorem provEquiv_trans {φ ψ χ : Formula} (h1 : φ ≈ₚ ψ) (h2 : ψ ≈ₚ χ) : φ ≈ₚ χ :=
  ⟨derives_trans h1.1 h2.1, derives_trans h2.2 h1.2⟩

/--
Provable equivalence is an equivalence relation.
-/
theorem provEquiv_equiv : Equivalence ProvEquiv where
  refl := provEquiv_refl
  symm := provEquiv_symm
  trans := provEquiv_trans

/--
Provable equivalence as a setoid on Formula.
-/
instance provEquivSetoid : Setoid Formula where
  r := ProvEquiv
  iseqv := provEquiv_equiv

/-!
## Lindenbaum Algebra Type
-/

/--
The Lindenbaum-Tarski algebra: quotient of formulas by provable equivalence.

Elements are equivalence classes `[φ]` where two formulas are equivalent
if they are provably equivalent.
-/
def LindenbaumAlg : Type := Quotient provEquivSetoid

/--
The quotient map: embed a formula into the Lindenbaum algebra.
-/
def toQuot (φ : Formula) : LindenbaumAlg := Quotient.mk provEquivSetoid φ

/-- Bracket notation for the Lindenbaum class of a formula: `⟦φ⟧` unfolds to `toQuot φ`. -/
scoped notation "⟦" φ "⟧" => toQuot φ

/-!
## Congruence Properties

We need to show ProvEquiv respects logical operations to lift them to the quotient.
-/

/--
Derivability respects negation contravariantly: `Derives ψ φ → Derives φ.neg ψ.neg`.
-/
theorem derives_neg_antitone {φ ψ : Formula} (h : Derives ψ φ) : Derives φ.neg ψ.neg := by
  unfold Derives at *
  obtain ⟨d⟩ := h
  exact ⟨FormalSystem.Theorems.Propositional.contraposition d⟩

/--
Provable equivalence respects negation: `φ ≈ₚ ψ → ¬φ ≈ₚ ¬ψ`.
-/
theorem provEquiv_neg_congr {φ ψ : Formula} (h : φ ≈ₚ ψ) : φ.neg ≈ₚ ψ.neg := by
  unfold ProvEquiv at *
  exact ⟨derives_neg_antitone h.2, derives_neg_antitone h.1⟩

/--
Provable equivalence respects box: `φ ≈ₚ ψ → □φ ≈ₚ □ψ`.
-/
theorem provEquiv_box_congr {φ ψ : Formula} (h : φ ≈ₚ ψ) : φ.box ≈ₚ ψ.box := by
  unfold ProvEquiv Derives at *
  obtain ⟨⟨d_fwd⟩, ⟨d_bwd⟩⟩ := h
  constructor
  · -- Show ⊢ □φ → □ψ
    have d_box : DerivationTree FrameClass.Base [] (Formula.box (φ.imp ψ)) :=
      DerivationTree.necessitation (φ.imp ψ) d_fwd
    have d_k : DerivationTree FrameClass.Base [] ((φ.imp ψ).box.imp (φ.box.imp ψ.box)) :=
      DerivationTree.axiom [] _ (Axiom.modal_k_dist φ ψ) trivial
    exact ⟨DerivationTree.modus_ponens [] _ _ d_k d_box⟩
  · have d_box : DerivationTree FrameClass.Base [] (Formula.box (ψ.imp φ)) :=
      DerivationTree.necessitation (ψ.imp φ) d_bwd
    have d_k : DerivationTree FrameClass.Base [] ((ψ.imp φ).box.imp (ψ.box.imp φ.box)) :=
      DerivationTree.axiom [] _ (Axiom.modal_k_dist ψ φ) trivial
    exact ⟨DerivationTree.modus_ponens [] _ _ d_k d_box⟩

/--
Provable equivalence respects allPast (H): `φ ≈ₚ ψ → Hφ ≈ₚ Hψ`.

This uses `pastMono` from Perpetuity which derives it via temporal duality.
-/
theorem provEquiv_all_past_congr {φ ψ : Formula} (h : φ ≈ₚ ψ) :
    φ.allPast ≈ₚ ψ.allPast := by
  unfold ProvEquiv Derives at *
  obtain ⟨⟨d_fwd⟩, ⟨d_bwd⟩⟩ := h
  constructor
  · exact ⟨FormalSystem.Theorems.Perpetuity.pastMono d_fwd⟩
  · exact ⟨FormalSystem.Theorems.Perpetuity.pastMono d_bwd⟩

/--
Provable equivalence respects implication.
-/
theorem provEquiv_imp_congr {φ₁ φ₂ ψ₁ ψ₂ : Formula}
    (hφ : φ₁ ≈ₚ φ₂) (hψ : ψ₁ ≈ₚ ψ₂) : φ₁.imp ψ₁ ≈ₚ φ₂.imp ψ₂ := by
  -- Uses bCombinator (composition) to chain the equivalences
  -- (φ₁ → ψ₁) → (φ₂ → ψ₂) requires: φ₂ → φ₁ and ψ₁ → ψ₂
  -- (φ₂ → ψ₂) → (φ₁ → ψ₁) requires: φ₁ → φ₂ and ψ₂ → ψ₁
  unfold ProvEquiv Derives at *
  obtain ⟨⟨d_φ_fwd⟩, ⟨d_φ_bwd⟩⟩ := hφ
  obtain ⟨⟨d_ψ_fwd⟩, ⟨d_ψ_bwd⟩⟩ := hψ
  constructor
  · -- Show ⊢ (φ₁ → ψ₁) → (φ₂ → ψ₂)
    -- bCombinator: ⊢ (B → C) → (A → B) → (A → C)
    -- Step 1: (ψ₁ → ψ₂) → (φ₂ → ψ₁) → (φ₂ → ψ₂)
    have b1 : ⊢ (ψ₁.imp ψ₂).imp ((φ₂.imp ψ₁).imp (φ₂.imp ψ₂)) :=
      FormalSystem.Theorems.Combinators.bCombinator
    have h1 : ⊢ (φ₂.imp ψ₁).imp (φ₂.imp ψ₂) :=
      DerivationTree.modus_ponens [] _ _ b1 d_ψ_fwd
    -- Step 2: (φ₂ → φ₁) → (φ₁ → ψ₁) → (φ₂ → ψ₁) via flipped bCombinator
    have b2_pre : ⊢ (φ₁.imp ψ₁).imp ((φ₂.imp φ₁).imp (φ₂.imp ψ₁)) :=
      FormalSystem.Theorems.Combinators.bCombinator
    have flip2 : ⊢ ((φ₁.imp ψ₁).imp ((φ₂.imp φ₁).imp (φ₂.imp ψ₁))).imp
                    ((φ₂.imp φ₁).imp ((φ₁.imp ψ₁).imp (φ₂.imp ψ₁))) :=
      FormalSystem.Theorems.Combinators.theoremFlip
    have b2 : ⊢ (φ₂.imp φ₁).imp ((φ₁.imp ψ₁).imp (φ₂.imp ψ₁)) :=
      DerivationTree.modus_ponens [] _ _ flip2 b2_pre
    have h2 : ⊢ (φ₁.imp ψ₁).imp (φ₂.imp ψ₁) :=
      DerivationTree.modus_ponens [] _ _ b2 d_φ_bwd
    -- Compose h2 and h1
    exact ⟨FormalSystem.Theorems.Combinators.impTrans h2 h1⟩
  · -- Show ⊢ (φ₂ → ψ₂) → (φ₁ → ψ₁)
    -- Symmetric: use d_φ_fwd and d_ψ_bwd
    have b1 : ⊢ (ψ₂.imp ψ₁).imp ((φ₁.imp ψ₂).imp (φ₁.imp ψ₁)) :=
      FormalSystem.Theorems.Combinators.bCombinator
    have h1 : ⊢ (φ₁.imp ψ₂).imp (φ₁.imp ψ₁) :=
      DerivationTree.modus_ponens [] _ _ b1 d_ψ_bwd
    have b2_pre : ⊢ (φ₂.imp ψ₂).imp ((φ₁.imp φ₂).imp (φ₁.imp ψ₂)) :=
      FormalSystem.Theorems.Combinators.bCombinator
    have flip2 : ⊢ ((φ₂.imp ψ₂).imp ((φ₁.imp φ₂).imp (φ₁.imp ψ₂))).imp
                    ((φ₁.imp φ₂).imp ((φ₂.imp ψ₂).imp (φ₁.imp ψ₂))) :=
      FormalSystem.Theorems.Combinators.theoremFlip
    have b2 : ⊢ (φ₁.imp φ₂).imp ((φ₂.imp ψ₂).imp (φ₁.imp ψ₂)) :=
      DerivationTree.modus_ponens [] _ _ flip2 b2_pre
    have h2 : ⊢ (φ₂.imp ψ₂).imp (φ₁.imp ψ₂) :=
      DerivationTree.modus_ponens [] _ _ b2 d_φ_fwd
    exact ⟨FormalSystem.Theorems.Combinators.impTrans h2 h1⟩

/--
Provable equivalence respects conjunction.
-/
theorem provEquiv_and_congr {φ₁ φ₂ ψ₁ ψ₂ : Formula}
    (hφ : φ₁ ≈ₚ φ₂) (hψ : ψ₁ ≈ₚ ψ₂) : φ₁.and ψ₁ ≈ₚ φ₂.and ψ₂ := by
  -- and φ ψ = (φ.imp ψ.neg).neg
  have hψ_neg : ψ₁.neg ≈ₚ ψ₂.neg := provEquiv_neg_congr hψ
  have h_imp : φ₁.imp ψ₁.neg ≈ₚ φ₂.imp ψ₂.neg := provEquiv_imp_congr hφ hψ_neg
  exact provEquiv_neg_congr h_imp

/--
Provable equivalence respects disjunction.
-/
theorem provEquiv_or_congr {φ₁ φ₂ ψ₁ ψ₂ : Formula}
    (hφ : φ₁ ≈ₚ φ₂) (hψ : ψ₁ ≈ₚ ψ₂) : φ₁.or ψ₁ ≈ₚ φ₂.or ψ₂ := by
  -- or φ ψ = φ.neg.imp ψ
  have hφ_neg : φ₁.neg ≈ₚ φ₂.neg := provEquiv_neg_congr hφ
  exact provEquiv_imp_congr hφ_neg hψ

/-!
## Lifted Operations on Quotient

We now lift the logical operations to the quotient type.
-/

/--
Lifted negation on the Lindenbaum algebra.
-/
def negQuot : LindenbaumAlg → LindenbaumAlg :=
  Quotient.lift (fun φ => toQuot φ.neg)
    (fun _ _ h => Quotient.sound (provEquiv_neg_congr h))

/--
Lifted implication on the Lindenbaum algebra.
-/
def impQuot : LindenbaumAlg → LindenbaumAlg → LindenbaumAlg :=
  Quotient.lift₂ (fun φ ψ => toQuot (φ.imp ψ))
    (fun _ _ _ _ h1 h2 => Quotient.sound (provEquiv_imp_congr h1 h2))

/--
Lifted conjunction on the Lindenbaum algebra.
-/
def andQuot : LindenbaumAlg → LindenbaumAlg → LindenbaumAlg :=
  Quotient.lift₂ (fun φ ψ => toQuot (φ.and ψ))
    (fun _ _ _ _ h1 h2 => Quotient.sound (provEquiv_and_congr h1 h2))

/--
Lifted disjunction on the Lindenbaum algebra.
-/
def orQuot : LindenbaumAlg → LindenbaumAlg → LindenbaumAlg :=
  Quotient.lift₂ (fun φ ψ => toQuot (φ.or ψ))
    (fun _ _ _ _ h1 h2 => Quotient.sound (provEquiv_or_congr h1 h2))

/--
Lifted box on the Lindenbaum algebra.
-/
def boxQuot : LindenbaumAlg → LindenbaumAlg :=
  Quotient.lift (fun φ => toQuot φ.box)
    (fun _ _ h => Quotient.sound (provEquiv_box_congr h))

/--
Lifted allPast (H) on the Lindenbaum algebra.
-/
def hQuot : LindenbaumAlg → LindenbaumAlg :=
  Quotient.lift (fun φ => toQuot φ.allPast)
    (fun _ _ h => Quotient.sound (provEquiv_all_past_congr h))

/--
Top element of the Lindenbaum algebra: the class of ⊤ (Truth).

We use (⊥ → ⊥) as the representation of Truth.
-/
def topQuot : LindenbaumAlg := toQuot (Formula.bot.imp Formula.bot)

/--
Bottom element of the Lindenbaum algebra: the class of ⊥.
-/
def botQuot : LindenbaumAlg := toQuot Formula.bot

/-!
## Temporal Duality (sigma)

We lift the `swapTemporal` operation to the quotient, establishing temporal duality
on the Lindenbaum algebra. This is essential for the STSA (Shift-closed Tense S5 Algebra) structure.
-/

/--
Derivability respects swapTemporal: if `⊢ φ → ψ`, then `⊢ swapTemporal(φ) → swapTemporal(ψ)`.

This follows from the temporal_duality inference rule.
-/
theorem swap_temporal_derives {φ ψ : Formula} (h : Derives φ ψ) :
    Derives φ.swapTemporal ψ.swapTemporal := by
  unfold Derives at *
  obtain ⟨d⟩ := h
  have d_swap : DerivationTree FrameClass.Base [] (φ.imp ψ).swapTemporal :=
    DerivationTree.temporal_duality (φ.imp ψ) d
  simp only [Formula.swapTemporal] at d_swap
  exact ⟨d_swap⟩

/--
Provable equivalence respects swapTemporal: `φ ≈ₚ ψ → swapTemporal(φ) ≈ₚ swapTemporal(ψ)`.
-/
theorem provEquiv_swap_temporal_congr {φ ψ : Formula} (h : φ ≈ₚ ψ) :
    φ.swapTemporal ≈ₚ ψ.swapTemporal :=
  ⟨swap_temporal_derives h.1, swap_temporal_derives h.2⟩

/--
Lifted temporal duality (sigma) on the Lindenbaum algebra.

This swaps G (allFuture) and H (allPast) operators throughout a formula,
implementing the temporal duality principle.
-/
def sigmaQuot : LindenbaumAlg → LindenbaumAlg :=
  Quotient.lift (fun φ => toQuot φ.swapTemporal)
    (fun _ _ h => Quotient.sound (provEquiv_swap_temporal_congr h))

/--
Sigma is an involution: applying it twice gives the identity.
-/
theorem sigma_quot_involution (a : LindenbaumAlg) : sigmaQuot (sigmaQuot a) = a := by
  induction a using Quotient.ind
  rename_i φ
  change toQuot (φ.swapTemporal.swapTemporal) = toQuot φ
  rw [Formula.swap_temporal_involution]

/--
Sigma respects negation: `σ(¬a) = ¬σ(a)`.
-/
theorem sigma_quot_neg (a : LindenbaumAlg) :
    sigmaQuot (negQuot a) = negQuot (sigmaQuot a) := by
  induction a using Quotient.ind
  rename_i φ
  change toQuot (φ.neg.swapTemporal) = negQuot (toQuot (φ.swapTemporal))
  simp only [Formula.neg, Formula.swapTemporal]
  rfl

/--
Sigma respects disjunction: `σ(a ∨ b) = σ(a) ∨ σ(b)`.
-/
theorem sigma_quot_sup (a b : LindenbaumAlg) :
    sigmaQuot (orQuot a b) = orQuot (sigmaQuot a) (sigmaQuot b) := by
  induction a using Quotient.ind
  induction b using Quotient.ind
  rename_i φ ψ
  change toQuot ((φ.or ψ).swapTemporal) = orQuot (toQuot φ.swapTemporal) (toQuot ψ.swapTemporal)
  simp only [Formula.or, Formula.neg, Formula.swapTemporal]
  rfl

/--
Sigma commutes with box: `σ(□a) = □(σ a)`.
-/
theorem sigma_quot_box (a : LindenbaumAlg) :
    sigmaQuot (boxQuot a) = boxQuot (sigmaQuot a) := by
  induction a using Quotient.ind
  rename_i φ
  change toQuot (φ.box.swapTemporal) = boxQuot (toQuot φ.swapTemporal)
  simp only [Formula.swapTemporal]
  rfl

end FormalSystem.Metalogic.Algebraic.LindenbaumQuotient
