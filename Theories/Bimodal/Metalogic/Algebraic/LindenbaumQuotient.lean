import Bimodal.ProofSystem
import Bimodal.Metalogic.Core.MaximalConsistent
import Bimodal.Theorems.Propositional
import Bimodal.Theorems.Combinators
import Bimodal.Theorems.Perpetuity

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

## References

- Research report: specs/700_research_algebraic_representation_theorem_proof/reports/research-002.md
-/

namespace Bimodal.Metalogic.Algebraic.LindenbaumQuotient

open Bimodal.Syntax Bimodal.ProofSystem

/-!
## Provable Equivalence
-/

/--
Derives relation: `Derives φ ψ` means `⊢ φ → ψ` (derivable from empty context).

This is the primitive ordering used to define provable equivalence.
-/
def Derives (φ ψ : Formula) : Prop := Nonempty (DerivationTree [] (φ.imp ψ))

/--
Provable equivalence: `ProvEquiv φ ψ` means `⊢ φ ↔ ψ`.

Two formulas are provably equivalent if each implies the other.
-/
def ProvEquiv (φ ψ : Formula) : Prop := Derives φ ψ ∧ Derives ψ φ

-- Notation for provable equivalence
scoped infix:50 " ≈ₚ " => ProvEquiv

/-!
## Equivalence Relation Properties
-/

/--
Identity derivation: `⊢ φ → φ`.
-/
theorem derives_refl (φ : Formula) : Derives φ φ := by
  unfold Derives
  exact ⟨Bimodal.Theorems.Combinators.identity φ⟩

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
  exact ⟨Bimodal.Theorems.Combinators.imp_trans d1 d2⟩

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

-- Notation for quotient classes
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
  exact ⟨Bimodal.Theorems.Propositional.contraposition d⟩

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
    have d_box : DerivationTree [] (Formula.box (φ.imp ψ)) :=
      DerivationTree.necessitation (φ.imp ψ) d_fwd
    have d_k : DerivationTree [] ((φ.imp ψ).box.imp (φ.box.imp ψ.box)) :=
      DerivationTree.axiom [] _ (Axiom.modal_k_dist φ ψ)
    exact ⟨DerivationTree.modus_ponens [] _ _ d_k d_box⟩
  · have d_box : DerivationTree [] (Formula.box (ψ.imp φ)) :=
      DerivationTree.necessitation (ψ.imp φ) d_bwd
    have d_k : DerivationTree [] ((ψ.imp φ).box.imp (ψ.box.imp φ.box)) :=
      DerivationTree.axiom [] _ (Axiom.modal_k_dist ψ φ)
    exact ⟨DerivationTree.modus_ponens [] _ _ d_k d_box⟩

/--
Provable equivalence respects all_future (G): `φ ≈ₚ ψ → Gφ ≈ₚ Gψ`.
-/
theorem provEquiv_all_future_congr {φ ψ : Formula} (h : φ ≈ₚ ψ) :
    φ.all_future ≈ₚ ψ.all_future := by
  unfold ProvEquiv Derives at *
  obtain ⟨⟨d_fwd⟩, ⟨d_bwd⟩⟩ := h
  constructor
  · have d_temp : DerivationTree [] (Formula.all_future (φ.imp ψ)) :=
      DerivationTree.temporal_necessitation (φ.imp ψ) d_fwd
    have d_k : DerivationTree [] ((φ.imp ψ).all_future.imp (φ.all_future.imp ψ.all_future)) :=
      DerivationTree.axiom [] _ (Axiom.temp_k_dist φ ψ)
    exact ⟨DerivationTree.modus_ponens [] _ _ d_k d_temp⟩
  · have d_temp : DerivationTree [] (Formula.all_future (ψ.imp φ)) :=
      DerivationTree.temporal_necessitation (ψ.imp φ) d_bwd
    have d_k : DerivationTree [] ((ψ.imp φ).all_future.imp (ψ.all_future.imp φ.all_future)) :=
      DerivationTree.axiom [] _ (Axiom.temp_k_dist ψ φ)
    exact ⟨DerivationTree.modus_ponens [] _ _ d_k d_temp⟩

/--
Provable equivalence respects all_past (H): `φ ≈ₚ ψ → Hφ ≈ₚ Hψ`.

This uses `past_mono` from Perpetuity which derives it via temporal duality.
-/
theorem provEquiv_all_past_congr {φ ψ : Formula} (h : φ ≈ₚ ψ) :
    φ.all_past ≈ₚ ψ.all_past := by
  unfold ProvEquiv Derives at *
  obtain ⟨⟨d_fwd⟩, ⟨d_bwd⟩⟩ := h
  constructor
  · exact ⟨Bimodal.Theorems.Perpetuity.past_mono d_fwd⟩
  · exact ⟨Bimodal.Theorems.Perpetuity.past_mono d_bwd⟩

/--
Provable equivalence respects implication.
-/
theorem provEquiv_imp_congr {φ₁ φ₂ ψ₁ ψ₂ : Formula}
    (hφ : φ₁ ≈ₚ φ₂) (hψ : ψ₁ ≈ₚ ψ₂) : φ₁.imp ψ₁ ≈ₚ φ₂.imp ψ₂ := by
  -- Uses b_combinator (composition) to chain the equivalences
  -- (φ₁ → ψ₁) → (φ₂ → ψ₂) requires: φ₂ → φ₁ and ψ₁ → ψ₂
  -- (φ₂ → ψ₂) → (φ₁ → ψ₁) requires: φ₁ → φ₂ and ψ₂ → ψ₁
  unfold ProvEquiv Derives at *
  obtain ⟨⟨d_φ_fwd⟩, ⟨d_φ_bwd⟩⟩ := hφ
  obtain ⟨⟨d_ψ_fwd⟩, ⟨d_ψ_bwd⟩⟩ := hψ
  constructor
  · -- Show ⊢ (φ₁ → ψ₁) → (φ₂ → ψ₂)
    -- b_combinator: ⊢ (B → C) → (A → B) → (A → C)
    -- Step 1: (ψ₁ → ψ₂) → (φ₂ → ψ₁) → (φ₂ → ψ₂)
    have b1 : ⊢ (ψ₁.imp ψ₂).imp ((φ₂.imp ψ₁).imp (φ₂.imp ψ₂)) :=
      Bimodal.Theorems.Combinators.b_combinator
    have h1 : ⊢ (φ₂.imp ψ₁).imp (φ₂.imp ψ₂) :=
      DerivationTree.modus_ponens [] _ _ b1 d_ψ_fwd

    -- Step 2: (φ₂ → φ₁) → (φ₁ → ψ₁) → (φ₂ → ψ₁) via flipped b_combinator
    have b2_pre : ⊢ (φ₁.imp ψ₁).imp ((φ₂.imp φ₁).imp (φ₂.imp ψ₁)) :=
      Bimodal.Theorems.Combinators.b_combinator
    have flip2 : ⊢ ((φ₁.imp ψ₁).imp ((φ₂.imp φ₁).imp (φ₂.imp ψ₁))).imp
                    ((φ₂.imp φ₁).imp ((φ₁.imp ψ₁).imp (φ₂.imp ψ₁))) :=
      Bimodal.Theorems.Combinators.theorem_flip
    have b2 : ⊢ (φ₂.imp φ₁).imp ((φ₁.imp ψ₁).imp (φ₂.imp ψ₁)) :=
      DerivationTree.modus_ponens [] _ _ flip2 b2_pre
    have h2 : ⊢ (φ₁.imp ψ₁).imp (φ₂.imp ψ₁) :=
      DerivationTree.modus_ponens [] _ _ b2 d_φ_bwd

    -- Compose h2 and h1
    exact ⟨Bimodal.Theorems.Combinators.imp_trans h2 h1⟩

  · -- Show ⊢ (φ₂ → ψ₂) → (φ₁ → ψ₁)
    -- Symmetric: use d_φ_fwd and d_ψ_bwd
    have b1 : ⊢ (ψ₂.imp ψ₁).imp ((φ₁.imp ψ₂).imp (φ₁.imp ψ₁)) :=
      Bimodal.Theorems.Combinators.b_combinator
    have h1 : ⊢ (φ₁.imp ψ₂).imp (φ₁.imp ψ₁) :=
      DerivationTree.modus_ponens [] _ _ b1 d_ψ_bwd

    have b2_pre : ⊢ (φ₂.imp ψ₂).imp ((φ₁.imp φ₂).imp (φ₁.imp ψ₂)) :=
      Bimodal.Theorems.Combinators.b_combinator
    have flip2 : ⊢ ((φ₂.imp ψ₂).imp ((φ₁.imp φ₂).imp (φ₁.imp ψ₂))).imp
                    ((φ₁.imp φ₂).imp ((φ₂.imp ψ₂).imp (φ₁.imp ψ₂))) :=
      Bimodal.Theorems.Combinators.theorem_flip
    have b2 : ⊢ (φ₁.imp φ₂).imp ((φ₂.imp ψ₂).imp (φ₁.imp ψ₂)) :=
      DerivationTree.modus_ponens [] _ _ flip2 b2_pre
    have h2 : ⊢ (φ₂.imp ψ₂).imp (φ₁.imp ψ₂) :=
      DerivationTree.modus_ponens [] _ _ b2 d_φ_fwd

    exact ⟨Bimodal.Theorems.Combinators.imp_trans h2 h1⟩

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
def neg_quot : LindenbaumAlg → LindenbaumAlg :=
  Quotient.lift (fun φ => toQuot φ.neg)
    (fun _ _ h => Quotient.sound (provEquiv_neg_congr h))

/--
Lifted implication on the Lindenbaum algebra.
-/
def imp_quot : LindenbaumAlg → LindenbaumAlg → LindenbaumAlg :=
  Quotient.lift₂ (fun φ ψ => toQuot (φ.imp ψ))
    (fun _ _ _ _ h1 h2 => Quotient.sound (provEquiv_imp_congr h1 h2))

/--
Lifted conjunction on the Lindenbaum algebra.
-/
def and_quot : LindenbaumAlg → LindenbaumAlg → LindenbaumAlg :=
  Quotient.lift₂ (fun φ ψ => toQuot (φ.and ψ))
    (fun _ _ _ _ h1 h2 => Quotient.sound (provEquiv_and_congr h1 h2))

/--
Lifted disjunction on the Lindenbaum algebra.
-/
def or_quot : LindenbaumAlg → LindenbaumAlg → LindenbaumAlg :=
  Quotient.lift₂ (fun φ ψ => toQuot (φ.or ψ))
    (fun _ _ _ _ h1 h2 => Quotient.sound (provEquiv_or_congr h1 h2))

/--
Lifted box on the Lindenbaum algebra.
-/
def box_quot : LindenbaumAlg → LindenbaumAlg :=
  Quotient.lift (fun φ => toQuot φ.box)
    (fun _ _ h => Quotient.sound (provEquiv_box_congr h))

/--
Lifted all_future (G) on the Lindenbaum algebra.
-/
def G_quot : LindenbaumAlg → LindenbaumAlg :=
  Quotient.lift (fun φ => toQuot φ.all_future)
    (fun _ _ h => Quotient.sound (provEquiv_all_future_congr h))

/--
Lifted all_past (H) on the Lindenbaum algebra.
-/
def H_quot : LindenbaumAlg → LindenbaumAlg :=
  Quotient.lift (fun φ => toQuot φ.all_past)
    (fun _ _ h => Quotient.sound (provEquiv_all_past_congr h))

/--
Top element of the Lindenbaum algebra: the class of ⊤ (Truth).

We use (⊥ → ⊥) as the representation of Truth.
-/
def top_quot : LindenbaumAlg := toQuot (Formula.bot.imp Formula.bot)

/--
Bottom element of the Lindenbaum algebra: the class of ⊥.
-/
def bot_quot : LindenbaumAlg := toQuot Formula.bot

end Bimodal.Metalogic.Algebraic.LindenbaumQuotient
