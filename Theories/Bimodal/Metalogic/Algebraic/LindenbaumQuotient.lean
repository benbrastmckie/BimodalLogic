import Bimodal.ProofSystem
import Bimodal.Metalogic.Core.MaximalConsistent
import Bimodal.Theorems.Propositional
import Bimodal.Theorems.Combinators

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
Provable equivalence respects negation: `φ ≈ₚ ψ → ¬φ ≈ₚ ¬ψ`.
-/
theorem provEquiv_neg_congr {φ ψ : Formula} (h : φ ≈ₚ ψ) : φ.neg ≈ₚ ψ.neg := by
  unfold ProvEquiv Derives at *
  obtain ⟨⟨d_fwd⟩, ⟨d_bwd⟩⟩ := h
  constructor
  · -- Show ⊢ ¬φ → ¬ψ, i.e., ⊢ (φ → ⊥) → (ψ → ⊥)
    -- From ⊢ ψ → φ (d_bwd), derive ⊢ (φ → ⊥) → (ψ → ⊥) by contraposition
    exact ⟨Bimodal.Theorems.Propositional.contraposition d_bwd⟩
  · -- Show ⊢ ¬ψ → ¬φ, i.e., ⊢ (ψ → ⊥) → (φ → ⊥)
    exact ⟨Bimodal.Theorems.Propositional.contraposition d_fwd⟩

/--
Derivability respects negation contravariantly: `Derives ψ φ → Derives φ.neg ψ.neg`.
-/
theorem derives_neg_antitone {φ ψ : Formula} (h : Derives ψ φ) : Derives φ.neg ψ.neg := by
  unfold Derives at *
  obtain ⟨d⟩ := h
  exact ⟨Bimodal.Theorems.Propositional.contraposition d⟩

/--
Provable equivalence respects implication: `φ₁ ≈ₚ φ₂ → ψ₁ ≈ₚ ψ₂ → (φ₁ → ψ₁) ≈ₚ (φ₂ → ψ₂)`.
-/
theorem provEquiv_imp_congr {φ₁ φ₂ ψ₁ ψ₂ : Formula}
    (hφ : φ₁ ≈ₚ φ₂) (hψ : ψ₁ ≈ₚ ψ₂) : φ₁.imp ψ₁ ≈ₚ φ₂.imp ψ₂ := by
  unfold ProvEquiv Derives at *
  obtain ⟨⟨dφ_fwd⟩, ⟨dφ_bwd⟩⟩ := hφ
  obtain ⟨⟨dψ_fwd⟩, ⟨dψ_bwd⟩⟩ := hψ
  constructor
  · -- Show ⊢ (φ₁ → ψ₁) → (φ₂ → ψ₂)
    -- We have ⊢ φ₂ → φ₁ and ⊢ ψ₁ → ψ₂
    -- Use imp_congr: from ⊢ φ₂ → φ₁ and ⊢ ψ₁ → ψ₂, get ⊢ (φ₁ → ψ₁) → (φ₂ → ψ₂)
    exact ⟨Bimodal.Theorems.Propositional.imp_imp_congr dφ_bwd dψ_fwd⟩
  · -- Show ⊢ (φ₂ → ψ₂) → (φ₁ → ψ₁)
    exact ⟨Bimodal.Theorems.Propositional.imp_imp_congr dφ_fwd dψ_bwd⟩

/--
Provable equivalence respects conjunction: `φ₁ ≈ₚ φ₂ → ψ₁ ≈ₚ ψ₂ → (φ₁ ∧ ψ₁) ≈ₚ (φ₂ ∧ ψ₂)`.
-/
theorem provEquiv_and_congr {φ₁ φ₂ ψ₁ ψ₂ : Formula}
    (hφ : φ₁ ≈ₚ φ₂) (hψ : ψ₁ ≈ₚ ψ₂) : φ₁.and ψ₁ ≈ₚ φ₂.and ψ₂ := by
  -- and φ ψ = (φ.imp ψ.neg).neg
  -- Use provEquiv_neg_congr and provEquiv_imp_congr
  have hψ_neg : ψ₁.neg ≈ₚ ψ₂.neg := provEquiv_neg_congr hψ
  have h_imp : φ₁.imp ψ₁.neg ≈ₚ φ₂.imp ψ₂.neg := provEquiv_imp_congr hφ hψ_neg
  exact provEquiv_neg_congr h_imp

/--
Provable equivalence respects disjunction: `φ₁ ≈ₚ φ₂ → ψ₁ ≈ₚ ψ₂ → (φ₁ ∨ ψ₁) ≈ₚ (φ₂ ∨ ψ₂)`.
-/
theorem provEquiv_or_congr {φ₁ φ₂ ψ₁ ψ₂ : Formula}
    (hφ : φ₁ ≈ₚ φ₂) (hψ : ψ₁ ≈ₚ ψ₂) : φ₁.or ψ₁ ≈ₚ φ₂.or ψ₂ := by
  -- or φ ψ = φ.neg.imp ψ
  have hφ_neg : φ₁.neg ≈ₚ φ₂.neg := provEquiv_neg_congr hφ
  exact provEquiv_imp_congr hφ_neg hψ

/--
Provable equivalence respects box: `φ ≈ₚ ψ → □φ ≈ₚ □ψ`.
-/
theorem provEquiv_box_congr {φ ψ : Formula} (h : φ ≈ₚ ψ) : φ.box ≈ₚ ψ.box := by
  unfold ProvEquiv Derives at *
  obtain ⟨⟨d_fwd⟩, ⟨d_bwd⟩⟩ := h
  constructor
  · -- Show ⊢ □φ → □ψ
    -- From ⊢ φ → ψ, derive ⊢ □(φ → ψ) by necessitation
    have d_box : DerivationTree [] (Formula.box (φ.imp ψ)) :=
      DerivationTree.necessitation (φ.imp ψ) d_fwd
    -- Apply modal K distribution: ⊢ □(φ → ψ) → (□φ → □ψ)
    have d_k : DerivationTree [] ((φ.imp ψ).box.imp (φ.box.imp ψ.box)) :=
      DerivationTree.axiom [] _ (Axiom.modal_k_dist φ ψ)
    -- Modus ponens to get ⊢ □φ → □ψ
    exact ⟨DerivationTree.modus_ponens [] _ _ d_k d_box⟩
  · -- Show ⊢ □ψ → □φ (symmetric)
    have d_box : DerivationTree [] (Formula.box (ψ.imp φ)) :=
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
  · -- Show ⊢ Gφ → Gψ
    -- From ⊢ φ → ψ, derive ⊢ G(φ → ψ) by temporal necessitation
    have d_temp : DerivationTree [] (Formula.all_future (φ.imp ψ)) :=
      DerivationTree.temporal_necessitation (φ.imp ψ) d_fwd
    -- Apply temporal K distribution: ⊢ G(φ → ψ) → (Gφ → Gψ)
    have d_k : DerivationTree [] ((φ.imp ψ).all_future.imp (φ.all_future.imp ψ.all_future)) :=
      DerivationTree.axiom [] _ (Axiom.temp_k_dist φ ψ)
    -- Modus ponens to get ⊢ Gφ → Gψ
    exact ⟨DerivationTree.modus_ponens [] _ _ d_k d_temp⟩
  · -- Show ⊢ Gψ → Gφ (symmetric)
    have d_temp : DerivationTree [] (Formula.all_future (ψ.imp φ)) :=
      DerivationTree.temporal_necessitation (ψ.imp φ) d_bwd
    have d_k : DerivationTree [] ((ψ.imp φ).all_future.imp (ψ.all_future.imp φ.all_future)) :=
      DerivationTree.axiom [] _ (Axiom.temp_k_dist ψ φ)
    exact ⟨DerivationTree.modus_ponens [] _ _ d_k d_temp⟩

/--
Provable equivalence respects all_past (H): `φ ≈ₚ ψ → Hφ ≈ₚ Hψ`.
-/
theorem provEquiv_all_past_congr {φ ψ : Formula} (h : φ ≈ₚ ψ) :
    φ.all_past ≈ₚ ψ.all_past := by
  -- Use temporal duality: from ⊢ χ derive ⊢ swap χ
  -- First establish provEquiv for the swapped formulas
  unfold ProvEquiv Derives at *
  obtain ⟨⟨d_fwd⟩, ⟨d_bwd⟩⟩ := h
  constructor
  · -- Show ⊢ Hφ → Hψ
    -- From ⊢ φ → ψ, apply temporal duality to get ⊢ swap(φ → ψ) = swap(φ) → swap(ψ)
    -- Note: swap_temporal (φ.imp ψ) = φ.swap_temporal.imp ψ.swap_temporal
    -- This swaps all_future ↔ all_past in both φ and ψ
    -- For this particular goal, we need the H version of temp_k_dist
    -- The temporal duality rule gives us ⊢ swap(φ → ψ) from ⊢ φ → ψ
    have d_swap : DerivationTree [] (φ.imp ψ).swap_temporal :=
      DerivationTree.temporal_duality (φ.imp ψ) d_fwd
    -- Now apply temporal duality to the temporal necessitation process:
    -- ⊢ G(φ → ψ) dualizes to ⊢ H(swap(φ) → swap(ψ))
    -- The temp_k_dist for H is obtained by temporal duality from G's temp_k_dist
    -- Actually, we need to be more careful here

    -- Use direct approach: temporal necessitation + temporal duality on the result
    -- From ⊢ φ → ψ, derive ⊢ G(φ → ψ) then ⊢ H(swap(φ → ψ)) = H(swap φ → swap ψ)
    -- But we want H on the ORIGINAL formulas, not swapped.

    -- Alternative: Use the fact that temp_k_dist also has a past version by duality
    -- The axiom temp_k_dist gives G(φ → ψ) → (Gφ → Gψ)
    -- By temporal duality on this theorem (with φ and ψ replaced by their swaps),
    -- we get H(φ → ψ) → (Hφ → Hψ) for any φ, ψ.

    -- Let's derive it step by step:
    -- Step 1: ⊢ G(swap φ → swap ψ) → (G(swap φ) → G(swap ψ))  [temp_k_dist]
    -- Step 2: swap gives ⊢ H(φ → ψ) → (Hφ → Hψ)

    -- But we need to start from ⊢ φ → ψ

    -- Actually, the cleanest approach is:
    -- From ⊢ φ → ψ, derive ⊢ H(φ → ψ) using:
    -- 1. Apply swap to get ⊢ swap(φ → ψ) = swap φ → swap ψ
    -- 2. Apply temporal_necessitation to get ⊢ G(swap φ → swap ψ)
    -- 3. Apply swap to get ⊢ H(φ → ψ)

    -- Let's try this:
    -- d_swap : ⊢ swap(φ → ψ) = (swap φ).imp (swap ψ)
    have d_temp_swap : DerivationTree [] (Formula.all_future ((φ.imp ψ).swap_temporal)) :=
      DerivationTree.temporal_necessitation (φ.imp ψ).swap_temporal d_swap
    -- Now swap(G(swap(φ → ψ))) = H(swap(swap(φ → ψ))) = H(φ → ψ)
    have d_H_imp : DerivationTree [] (Formula.all_future ((φ.imp ψ).swap_temporal)).swap_temporal :=
      DerivationTree.temporal_duality _ d_temp_swap
    -- Simplify: swap_temporal(all_future χ) = all_past (swap_temporal χ)
    -- swap_temporal(swap_temporal(φ.imp ψ)) = φ.imp ψ
    -- So we get ⊢ H(φ → ψ)
    have h_eq : (Formula.all_future ((φ.imp ψ).swap_temporal)).swap_temporal =
                 Formula.all_past (φ.imp ψ) := by
      simp only [Formula.swap_temporal]
      rw [Formula.swap_temporal_involution]

    -- Now apply temp_k_dist for H
    -- We need ⊢ H(φ → ψ) → (Hφ → Hψ)
    -- This is derivable by temporal duality from temp_k_dist
    -- temp_k_dist: ⊢ G(φ → ψ) → (Gφ → Gψ)
    -- swap this theorem (with swap φ, swap ψ) to get:
    -- ⊢ H(swap(swap φ) → swap(swap ψ)) → (H(swap(swap φ)) → H(swap(swap ψ)))
    -- = ⊢ H(φ → ψ) → (Hφ → Hψ)

    -- Get temp_k_dist for swapped formulas
    have d_k_swap : DerivationTree [] ((φ.swap_temporal.imp ψ.swap_temporal).all_future.imp
                    (φ.swap_temporal.all_future.imp ψ.swap_temporal.all_future)) :=
      DerivationTree.axiom [] _ (Axiom.temp_k_dist φ.swap_temporal ψ.swap_temporal)
    -- Apply temporal duality
    have d_k_H : DerivationTree [] ((φ.swap_temporal.imp ψ.swap_temporal).all_future.imp
                  (φ.swap_temporal.all_future.imp ψ.swap_temporal.all_future)).swap_temporal :=
      DerivationTree.temporal_duality _ d_k_swap
    -- Simplify the swapped version
    have h_k_eq : ((φ.swap_temporal.imp ψ.swap_temporal).all_future.imp
                   (φ.swap_temporal.all_future.imp ψ.swap_temporal.all_future)).swap_temporal =
                  (φ.imp ψ).all_past.imp (φ.all_past.imp ψ.all_past) := by
      simp only [Formula.swap_temporal]
      rw [Formula.swap_temporal_involution, Formula.swap_temporal_involution]

    -- Combine: from ⊢ H(φ → ψ) and ⊢ H(φ → ψ) → (Hφ → Hψ), get ⊢ Hφ → Hψ
    have d_H_impl : DerivationTree [] ((φ.imp ψ).all_past) := by
      rw [← h_eq]; exact d_H_imp
    have d_k_H' : DerivationTree [] ((φ.imp ψ).all_past.imp (φ.all_past.imp ψ.all_past)) := by
      rw [← h_k_eq]; exact d_k_H
    exact ⟨DerivationTree.modus_ponens [] _ _ d_k_H' d_H_impl⟩
  · -- Show ⊢ Hψ → Hφ (symmetric)
    -- Same construction with φ and ψ swapped
    have d_swap : DerivationTree [] (ψ.imp φ).swap_temporal :=
      DerivationTree.temporal_duality (ψ.imp φ) d_bwd
    have d_temp_swap : DerivationTree [] (Formula.all_future ((ψ.imp φ).swap_temporal)) :=
      DerivationTree.temporal_necessitation (ψ.imp φ).swap_temporal d_swap
    have d_H_imp : DerivationTree [] (Formula.all_future ((ψ.imp φ).swap_temporal)).swap_temporal :=
      DerivationTree.temporal_duality _ d_temp_swap
    have h_eq : (Formula.all_future ((ψ.imp φ).swap_temporal)).swap_temporal =
                 Formula.all_past (ψ.imp φ) := by
      simp only [Formula.swap_temporal]
      rw [Formula.swap_temporal_involution]
    have d_k_swap : DerivationTree [] ((ψ.swap_temporal.imp φ.swap_temporal).all_future.imp
                    (ψ.swap_temporal.all_future.imp φ.swap_temporal.all_future)) :=
      DerivationTree.axiom [] _ (Axiom.temp_k_dist ψ.swap_temporal φ.swap_temporal)
    have d_k_H : DerivationTree [] ((ψ.swap_temporal.imp φ.swap_temporal).all_future.imp
                  (ψ.swap_temporal.all_future.imp φ.swap_temporal.all_future)).swap_temporal :=
      DerivationTree.temporal_duality _ d_k_swap
    have h_k_eq : ((ψ.swap_temporal.imp φ.swap_temporal).all_future.imp
                   (ψ.swap_temporal.all_future.imp φ.swap_temporal.all_future)).swap_temporal =
                  (ψ.imp φ).all_past.imp (ψ.all_past.imp φ.all_past) := by
      simp only [Formula.swap_temporal]
      rw [Formula.swap_temporal_involution, Formula.swap_temporal_involution]
    have d_H_impl : DerivationTree [] ((ψ.imp φ).all_past) := by
      rw [← h_eq]; exact d_H_imp
    have d_k_H' : DerivationTree [] ((ψ.imp φ).all_past.imp (ψ.all_past.imp φ.all_past)) := by
      rw [← h_k_eq]; exact d_k_H
    exact ⟨DerivationTree.modus_ponens [] _ _ d_k_H' d_H_impl⟩

/-!
## Lifted Operations on Quotient

We now lift the logical operations to the quotient type.
-/

/--
Lifted negation on the Lindenbaum algebra.
-/
def neg_quot : LindenbaumAlg → LindenbaumAlg :=
  Quotient.lift (fun φ => ⟦φ.neg⟧)
    (fun _ _ h => Quotient.sound (provEquiv_neg_congr h))

/--
Lifted implication on the Lindenbaum algebra.
-/
def imp_quot : LindenbaumAlg → LindenbaumAlg → LindenbaumAlg :=
  Quotient.lift₂ (fun φ ψ => ⟦φ.imp ψ⟧)
    (fun _ _ _ _ h1 h2 => Quotient.sound (provEquiv_imp_congr h1 h2))

/--
Lifted conjunction on the Lindenbaum algebra.
-/
def and_quot : LindenbaumAlg → LindenbaumAlg → LindenbaumAlg :=
  Quotient.lift₂ (fun φ ψ => ⟦φ.and ψ⟧)
    (fun _ _ _ _ h1 h2 => Quotient.sound (provEquiv_and_congr h1 h2))

/--
Lifted disjunction on the Lindenbaum algebra.
-/
def or_quot : LindenbaumAlg → LindenbaumAlg → LindenbaumAlg :=
  Quotient.lift₂ (fun φ ψ => ⟦φ.or ψ⟧)
    (fun _ _ _ _ h1 h2 => Quotient.sound (provEquiv_or_congr h1 h2))

/--
Lifted box on the Lindenbaum algebra.
-/
def box_quot : LindenbaumAlg → LindenbaumAlg :=
  Quotient.lift (fun φ => ⟦φ.box⟧)
    (fun _ _ h => Quotient.sound (provEquiv_box_congr h))

/--
Lifted all_future (G) on the Lindenbaum algebra.
-/
def G_quot : LindenbaumAlg → LindenbaumAlg :=
  Quotient.lift (fun φ => ⟦φ.all_future⟧)
    (fun _ _ h => Quotient.sound (provEquiv_all_future_congr h))

/--
Lifted all_past (H) on the Lindenbaum algebra.
-/
def H_quot : LindenbaumAlg → LindenbaumAlg :=
  Quotient.lift (fun φ => ⟦φ.all_past⟧)
    (fun _ _ h => Quotient.sound (provEquiv_all_past_congr h))

/--
Top element of the Lindenbaum algebra: the class of ⊤ (Truth).

We use (⊥ → ⊥) as the representation of Truth.
-/
def top_quot : LindenbaumAlg := ⟦Formula.bot.imp Formula.bot⟧

/--
Bottom element of the Lindenbaum algebra: the class of ⊥.
-/
def bot_quot : LindenbaumAlg := ⟦Formula.bot⟧

end Bimodal.Metalogic.Algebraic.LindenbaumQuotient
