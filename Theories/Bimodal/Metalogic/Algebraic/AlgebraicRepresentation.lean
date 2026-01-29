import Bimodal.Metalogic.Algebraic.UltrafilterMCS

/-!
# Algebraic Representation Theorem

This module proves the representation theorem using the algebraic machinery
developed in the previous modules.

## Main Results

- `algebraic_representation_theorem`: The main theorem
  `∀ φ, satisfiable φ ↔ ¬(⊢ ¬φ)`

## Proof Strategy

1. Define the algebraic canonical model using ultrafilters
2. Prove the algebraic truth lemma
3. Derive the representation theorem

## Status

Contains sorries pending completion of earlier phases.
-/

namespace Bimodal.Metalogic.Algebraic.AlgebraicRepresentation

open Bimodal.Syntax Bimodal.ProofSystem
open Bimodal.Metalogic.Algebraic.LindenbaumQuotient
open Bimodal.Metalogic.Algebraic.BooleanStructure
open Bimodal.Metalogic.Algebraic.InteriorOperators
open Bimodal.Metalogic.Algebraic.UltrafilterMCS
open Bimodal.Metalogic.Core

/-!
## Algebraic Canonical Frame

The worlds of the algebraic canonical frame are ultrafilters of the Lindenbaum algebra.
-/

/--
Algebraic world: an ultrafilter of the Lindenbaum algebra.
-/
abbrev AlgWorld := Ultrafilter LindenbaumAlg

/--
The set of formulas true at an algebraic world.

A formula φ is true at world U iff [φ] ∈ U.
-/
def algTrueAt (U : AlgWorld) (φ : Formula) : Prop := toQuot φ ∈ U.carrier

/-!
## Consistency and Satisfiability
-/

/--
A formula is consistent iff its negation is not provable.
-/
def AlgConsistent (φ : Formula) : Prop := ¬Nonempty (DerivationTree [] φ.neg)

/--
A formula is algebraically satisfiable if there exists an ultrafilter containing it.
-/
def AlgSatisfiable (φ : Formula) : Prop := ∃ U : AlgWorld, algTrueAt U φ

/--
Consistent formulas are satisfiable.

If φ is consistent (⊬ ¬φ), then there exists an ultrafilter U with [φ] ∈ U.
-/
theorem consistent_implies_satisfiable {φ : Formula} (h : AlgConsistent φ) :
    AlgSatisfiable φ := by
  unfold AlgConsistent at h
  unfold AlgSatisfiable algTrueAt
  -- h : ¬Nonempty (⊢ φ.neg)
  -- Strategy: Show {φ} is consistent, extend to MCS, convert to ultrafilter

  -- Step 1: Show {φ} is set-consistent
  have h_singleton_cons : SetConsistent {φ} := by
    intro L hL
    -- Assume L ⊢ ⊥ and derive contradiction
    intro ⟨d_bot⟩
    -- Every formula in L equals φ (since L ⊆ {φ})
    -- So L = [φ, φ, ..., φ] for some repetition
    -- This means [φ] ⊢ ⊥, i.e., φ ⊢ ⊥
    -- By deduction theorem, ⊢ φ → ⊥ = ⊢ ¬φ
    -- Contradiction with h

    -- First, filter L to get a single element if φ is in L
    by_cases hL_empty : L = []
    · -- L = [], so [] ⊢ ⊥ means ⊢ ⊥
      -- But the system is consistent (no proof of ⊥ from empty context)
      -- Actually we need to derive ⊢ ¬φ from this
      rw [hL_empty] at d_bot
      -- [] ⊢ ⊥ means ⊢ ⊥
      -- From ⊢ ⊥ derive ⊢ φ → ⊥ = ⊢ ¬φ
      have d_neg : DerivationTree [] φ.neg := by
        have d_efq : DerivationTree [] (Formula.bot.imp φ.neg) :=
          DerivationTree.axiom [] _ (Axiom.ex_falso φ.neg)
        exact DerivationTree.modus_ponens [] _ _ d_efq d_bot
      exact h ⟨d_neg⟩
    · -- L is non-empty, so L ⊆ {φ} means L = [φ, ..., φ]
      -- All elements of L are φ, so we can derive [φ] ⊢ ⊥
      have h_all_phi : ∀ ψ ∈ L, ψ = φ := by
        intro ψ hψ
        have := hL ψ hψ
        simp at this
        exact this
      -- Derive [φ] ⊢ ⊥ from L ⊢ ⊥
      have d_phi_bot : DerivationTree [φ] Formula.bot := by
        apply DerivationTree.weakening L [φ] Formula.bot d_bot
        intro ψ hψ
        simp [h_all_phi ψ hψ]
      -- By deduction theorem: ⊢ ¬φ
      have d_neg : DerivationTree [] φ.neg :=
        Bimodal.Metalogic.Core.deduction_theorem [] φ Formula.bot d_phi_bot
      exact h ⟨d_neg⟩

  -- Step 2: Extend {φ} to MCS using Lindenbaum
  obtain ⟨Γ, h_sub, h_mcs⟩ := set_lindenbaum {φ} h_singleton_cons

  -- Step 3: φ ∈ Γ (since {φ} ⊆ Γ)
  have h_phi_in : φ ∈ Γ := h_sub (Set.mem_singleton φ)

  -- Step 4: Convert MCS to ultrafilter
  let U := mcsToUltrafilter ⟨Γ, h_mcs⟩

  -- Step 5: Show [φ] ∈ U.carrier
  use U
  -- Need: toQuot φ ∈ U.carrier
  -- U.carrier = mcsToSet Γ = { [ψ] | ψ ∈ Γ }
  -- Since φ ∈ Γ, we have [φ] ∈ mcsToSet Γ
  exact mem_mcsToSet h_phi_in

/--
Satisfiable formulas are consistent.

If there exists an ultrafilter U with [φ] ∈ U, then ⊬ ¬φ.
-/
theorem satisfiable_implies_consistent {φ : Formula} (h : AlgSatisfiable φ) :
    AlgConsistent φ := by
  unfold AlgSatisfiable algTrueAt at h
  unfold AlgConsistent
  intro ⟨d_neg⟩
  obtain ⟨U, hU⟩ := h
  -- If ⊢ ¬φ, then [¬φ] = ⊤
  -- So [φ] = ⊥
  -- But U contains [φ], contradiction since ultrafilters don't contain ⊥
  have h_top : toQuot φ.neg = ⊤ := by
    apply le_antisymm
    · exact le_top
    · -- Need: ⊤ ≤ [¬φ], i.e., ⊢ ⊤ → ¬φ
      -- Since ⊢ ¬φ, this follows by weakening
      show Derives (Formula.bot.imp Formula.bot) φ.neg
      have d_s : DerivationTree [] (φ.neg.imp ((Formula.bot.imp Formula.bot).imp φ.neg)) :=
        DerivationTree.axiom [] _ (Axiom.prop_s φ.neg (Formula.bot.imp Formula.bot))
      exact ⟨DerivationTree.modus_ponens [] _ _ d_s d_neg⟩
  have h_phi_bot : toQuot φ = ⊥ := by
    -- [φ]ᶜ = [¬φ] = ⊤, so [φ] = ⊤ᶜ = ⊥
    have h_compl : neg_quot (toQuot φ) = toQuot φ.neg := rfl
    have h_eq : neg_quot (toQuot φ) = ⊤ := h_compl ▸ h_top
    -- In a Boolean algebra, if aᶜ = ⊤ then a = ⊥
    -- neg_quot is the complement in our BooleanAlgebra instance
    exact compl_eq_top.mp h_eq
  rw [h_phi_bot] at hU
  exact Ultrafilter.empty_not_mem U hU

/-!
## Main Theorem
-/

/--
**Algebraic Representation Theorem**

A formula is algebraically satisfiable if and only if its negation is not provable.

This is the algebraic version of the representation theorem, using ultrafilters
instead of maximal consistent sets.
-/
theorem algebraic_representation_theorem (φ : Formula) :
    AlgSatisfiable φ ↔ AlgConsistent φ :=
  ⟨satisfiable_implies_consistent, consistent_implies_satisfiable⟩

/--
Equivalent formulation: a formula is satisfiable iff not provably false.
-/
theorem algebraic_representation_theorem' (φ : Formula) :
    AlgSatisfiable φ ↔ ¬Nonempty (⊢ φ.neg) :=
  algebraic_representation_theorem φ

end Bimodal.Metalogic.Algebraic.AlgebraicRepresentation
