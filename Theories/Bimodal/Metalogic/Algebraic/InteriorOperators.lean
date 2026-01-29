import Bimodal.Metalogic.Algebraic.BooleanStructure

/-!
# Interior Operators for Temporal Modalities

This module proves that G (all_future) and H (all_past) are interior operators
on the Lindenbaum algebra, using the reflexive T-axioms.

## Main Definitions

- `InteriorOperator`: Structure for interior operators (dual of closure operators)
- `G_interior`: Instance showing G is an interior operator
- `H_interior`: Instance showing H is an interior operator

## Key Properties

Interior operators satisfy:
1. **Deflationary**: `c(a) ≤ a` (from T-axiom: `Gφ → φ`)
2. **Monotone**: `a ≤ b → c(a) ≤ c(b)` (from K-distribution)
3. **Idempotent**: `c(c(a)) = c(a)` (from 4-axiom: `Gφ → GGφ` and T-axiom)

## Mathematical Significance

The interior operator property is precisely the S4 characterization:
- T axiom (reflexivity) gives deflation
- K axiom (distribution) gives monotonicity
- 4 axiom (transitivity) + T give idempotence

Since our temporal operators G and H satisfy all these axioms, they are
interior operators on the Lindenbaum algebra.

## References

- Research report: specs/700_research_algebraic_representation_theorem_proof/reports/research-002.md
- Mathlib: Order.Closure.ClosureOperator (for the dual construction)
-/

namespace Bimodal.Metalogic.Algebraic.InteriorOperators

open Bimodal.Syntax Bimodal.ProofSystem
open Bimodal.Metalogic.Algebraic.LindenbaumQuotient
open Bimodal.Metalogic.Algebraic.BooleanStructure

/-!
## Interior Operator Definition

An interior operator is the dual of a closure operator:
- Closure: `a ≤ c(a)`, monotone, idempotent
- Interior: `i(a) ≤ a`, monotone, idempotent
-/

/--
An interior operator on a partial order.

This is the dual of Mathlib's ClosureOperator: instead of inflationary, it's deflationary.
-/
structure InteriorOp (α : Type*) [PartialOrder α] where
  /-- The interior operation -/
  toFun : α → α
  /-- Interior is deflationary: i(a) ≤ a -/
  le_self : ∀ a, toFun a ≤ a
  /-- Interior is monotone: a ≤ b → i(a) ≤ i(b) -/
  monotone : ∀ a b, a ≤ b → toFun a ≤ toFun b
  /-- Interior is idempotent: i(i(a)) = i(a) -/
  idempotent : ∀ a, toFun (toFun a) = toFun a

/-!
## G as Interior Operator

We show that G_quot satisfies the interior operator axioms.
-/

/--
G is deflationary: `⟦Gφ⟧ ≤ ⟦φ⟧`.

Uses T-axiom `temp_t_future`: `Gφ → φ`.
-/
theorem G_le_self (a : LindenbaumAlg) : G_quot a ≤ a := by
  induction a using Quotient.ind
  rename_i φ
  -- Need: Derives φ.all_future φ
  unfold Derives
  exact ⟨DerivationTree.axiom [] _ (Axiom.temp_t_future φ)⟩

/--
G is monotone: `⟦φ⟧ ≤ ⟦ψ⟧ → ⟦Gφ⟧ ≤ ⟦Gψ⟧`.

Uses K-distribution and temporal necessitation.
-/
theorem G_monotone (a b : LindenbaumAlg) (h : a ≤ b) : G_quot a ≤ G_quot b := by
  induction a using Quotient.ind
  induction b using Quotient.ind
  rename_i φ ψ
  -- h : Derives φ ψ
  unfold Derives at *
  obtain ⟨d⟩ := h
  -- From ⊢ φ → ψ, derive ⊢ Gφ → Gψ
  have d_temp : DerivationTree [] (Formula.all_future (φ.imp ψ)) :=
    DerivationTree.temporal_necessitation (φ.imp ψ) d
  have d_k : DerivationTree [] ((φ.imp ψ).all_future.imp (φ.all_future.imp ψ.all_future)) :=
    DerivationTree.axiom [] _ (Axiom.temp_k_dist φ ψ)
  exact ⟨DerivationTree.modus_ponens [] _ _ d_k d_temp⟩

/--
G is idempotent: `G(G⟦φ⟧) = G⟦φ⟧`.

Uses 4-axiom `temp_4`: `Gφ → GGφ` and T-axiom for the converse.
-/
theorem G_idempotent (a : LindenbaumAlg) : G_quot (G_quot a) = G_quot a := by
  induction a using Quotient.ind
  rename_i φ
  -- Need: ⟦φ.all_future.all_future⟧ = ⟦φ.all_future⟧
  apply Quotient.sound
  unfold ProvEquiv Derives
  constructor
  · -- ⊢ GGφ → Gφ (from T-axiom)
    exact ⟨DerivationTree.axiom [] _ (Axiom.temp_t_future φ.all_future)⟩
  · -- ⊢ Gφ → GGφ (from 4-axiom)
    exact ⟨DerivationTree.axiom [] _ (Axiom.temp_4 φ)⟩

/--
G is an interior operator on the Lindenbaum algebra.
-/
def G_interior : InteriorOp LindenbaumAlg where
  toFun := G_quot
  le_self := G_le_self
  monotone := G_monotone
  idempotent := G_idempotent

/-!
## H as Interior Operator

We show that H_quot satisfies the interior operator axioms.
-/

/--
H is deflationary: `⟦Hφ⟧ ≤ ⟦φ⟧`.

Uses T-axiom `temp_t_past`: `Hφ → φ`.
-/
theorem H_le_self (a : LindenbaumAlg) : H_quot a ≤ a := by
  induction a using Quotient.ind
  rename_i φ
  -- Need: Derives φ.all_past φ
  unfold Derives
  exact ⟨DerivationTree.axiom [] _ (Axiom.temp_t_past φ)⟩

/--
H is monotone: `⟦φ⟧ ≤ ⟦ψ⟧ → ⟦Hφ⟧ ≤ ⟦Hψ⟧`.

Uses temporal duality from G's monotonicity proof.
-/
theorem H_monotone (a b : LindenbaumAlg) (h : a ≤ b) : H_quot a ≤ H_quot b := by
  induction a using Quotient.ind
  induction b using Quotient.ind
  rename_i φ ψ
  unfold Derives at *
  obtain ⟨d⟩ := h
  -- From ⊢ φ → ψ, derive ⊢ Hφ → Hψ using temporal duality
  -- The proof mirrors provEquiv_all_past_congr
  have d_swap : DerivationTree [] (φ.imp ψ).swap_temporal :=
    DerivationTree.temporal_duality (φ.imp ψ) d
  have d_temp_swap : DerivationTree [] (Formula.all_future ((φ.imp ψ).swap_temporal)) :=
    DerivationTree.temporal_necessitation (φ.imp ψ).swap_temporal d_swap
  have d_H_imp : DerivationTree [] (Formula.all_future ((φ.imp ψ).swap_temporal)).swap_temporal :=
    DerivationTree.temporal_duality _ d_temp_swap
  have h_eq : (Formula.all_future ((φ.imp ψ).swap_temporal)).swap_temporal =
               Formula.all_past (φ.imp ψ) := by
    simp only [Formula.swap_temporal]
    rw [Formula.swap_temporal_involution]
  have d_k_swap : DerivationTree [] ((φ.swap_temporal.imp ψ.swap_temporal).all_future.imp
                  (φ.swap_temporal.all_future.imp ψ.swap_temporal.all_future)) :=
    DerivationTree.axiom [] _ (Axiom.temp_k_dist φ.swap_temporal ψ.swap_temporal)
  have d_k_H : DerivationTree [] ((φ.swap_temporal.imp ψ.swap_temporal).all_future.imp
                (φ.swap_temporal.all_future.imp ψ.swap_temporal.all_future)).swap_temporal :=
    DerivationTree.temporal_duality _ d_k_swap
  have h_k_eq : ((φ.swap_temporal.imp ψ.swap_temporal).all_future.imp
                 (φ.swap_temporal.all_future.imp ψ.swap_temporal.all_future)).swap_temporal =
                (φ.imp ψ).all_past.imp (φ.all_past.imp ψ.all_past) := by
    simp only [Formula.swap_temporal]
    rw [Formula.swap_temporal_involution, Formula.swap_temporal_involution]
  have d_H_impl : DerivationTree [] ((φ.imp ψ).all_past) := by
    rw [← h_eq]; exact d_H_imp
  have d_k_H' : DerivationTree [] ((φ.imp ψ).all_past.imp (φ.all_past.imp ψ.all_past)) := by
    rw [← h_k_eq]; exact d_k_H
  exact ⟨DerivationTree.modus_ponens [] _ _ d_k_H' d_H_impl⟩

/--
H is idempotent: `H(H⟦φ⟧) = H⟦φ⟧`.

Uses temporal duality from the 4-axiom for G.
-/
theorem H_idempotent (a : LindenbaumAlg) : H_quot (H_quot a) = H_quot a := by
  induction a using Quotient.ind
  rename_i φ
  apply Quotient.sound
  unfold ProvEquiv Derives
  constructor
  · -- ⊢ HHφ → Hφ (from T-axiom for H)
    exact ⟨DerivationTree.axiom [] _ (Axiom.temp_t_past φ.all_past)⟩
  · -- ⊢ Hφ → HHφ (from 4-axiom for H via temporal duality)
    -- temp_4 gives ⊢ Gψ → GGψ
    -- Apply temporal duality with ψ = swap φ to get ⊢ Hφ → HHφ
    have d_4_swap : DerivationTree [] ((Formula.all_future φ.swap_temporal).imp
                     (Formula.all_future (Formula.all_future φ.swap_temporal))) :=
      DerivationTree.axiom [] _ (Axiom.temp_4 φ.swap_temporal)
    have d_4_H : DerivationTree [] ((Formula.all_future φ.swap_temporal).imp
                  (Formula.all_future (Formula.all_future φ.swap_temporal))).swap_temporal :=
      DerivationTree.temporal_duality _ d_4_swap
    -- Simplify the swapped formula
    have h_eq : ((Formula.all_future φ.swap_temporal).imp
                 (Formula.all_future (Formula.all_future φ.swap_temporal))).swap_temporal =
                (Formula.all_past φ).imp (Formula.all_past (Formula.all_past φ)) := by
      simp only [Formula.swap_temporal]
      rw [Formula.swap_temporal_involution]
    rw [h_eq] at d_4_H
    exact ⟨d_4_H⟩

/--
H is an interior operator on the Lindenbaum algebra.
-/
def H_interior : InteriorOp LindenbaumAlg where
  toFun := H_quot
  le_self := H_le_self
  monotone := H_monotone
  idempotent := H_idempotent

/-!
## Box as Interior Operator

For completeness, we also show that box is an interior operator.
-/

/--
Box is deflationary: `⟦□φ⟧ ≤ ⟦φ⟧`.

Uses T-axiom `modal_t`: `□φ → φ`.
-/
theorem box_le_self (a : LindenbaumAlg) : box_quot a ≤ a := by
  induction a using Quotient.ind
  rename_i φ
  unfold Derives
  exact ⟨DerivationTree.axiom [] _ (Axiom.modal_t φ)⟩

/--
Box is monotone: `⟦φ⟧ ≤ ⟦ψ⟧ → ⟦□φ⟧ ≤ ⟦□ψ⟧`.

Uses K-distribution and necessitation.
-/
theorem box_monotone (a b : LindenbaumAlg) (h : a ≤ b) : box_quot a ≤ box_quot b := by
  induction a using Quotient.ind
  induction b using Quotient.ind
  rename_i φ ψ
  unfold Derives at *
  obtain ⟨d⟩ := h
  have d_box : DerivationTree [] (Formula.box (φ.imp ψ)) :=
    DerivationTree.necessitation (φ.imp ψ) d
  have d_k : DerivationTree [] ((φ.imp ψ).box.imp (φ.box.imp ψ.box)) :=
    DerivationTree.axiom [] _ (Axiom.modal_k_dist φ ψ)
  exact ⟨DerivationTree.modus_ponens [] _ _ d_k d_box⟩

/--
Box is idempotent: `□(□⟦φ⟧) = □⟦φ⟧`.

Uses 4-axiom `modal_4`: `□φ → □□φ` and T-axiom for the converse.
-/
theorem box_idempotent (a : LindenbaumAlg) : box_quot (box_quot a) = box_quot a := by
  induction a using Quotient.ind
  rename_i φ
  apply Quotient.sound
  unfold ProvEquiv Derives
  constructor
  · exact ⟨DerivationTree.axiom [] _ (Axiom.modal_t φ.box)⟩
  · exact ⟨DerivationTree.axiom [] _ (Axiom.modal_4 φ)⟩

/--
Box is an interior operator on the Lindenbaum algebra.
-/
def box_interior : InteriorOp LindenbaumAlg where
  toFun := box_quot
  le_self := box_le_self
  monotone := box_monotone
  idempotent := box_idempotent

/-!
## Interaction Properties

Properties relating G, H, and box.
-/

/--
G and H interact via temporal duality: they are "dual" interior operators
in the sense that applying temporal swap exchanges them.
-/
theorem G_H_duality (a : LindenbaumAlg) :
    G_quot a = a → H_quot a = a := by
  intro h
  -- If G[φ] = [φ], then ⟦Gφ⟧ = ⟦φ⟧
  -- By temporal symmetry properties and the structure of our logic,
  -- similar fixed point behavior extends to H
  -- This is a placeholder - full proof requires more infrastructure
  sorry

end Bimodal.Metalogic.Algebraic.InteriorOperators
