import Bimodal.Metalogic.Core.RestrictedMCS
import Bimodal.Metalogic.Core.MCSProperties
import Bimodal.Syntax.SubformulaClosure

/-!
# Closure MCS Infrastructure for FMP

This module provides the Maximal Consistent Set infrastructure restricted to
subformula closure, which is foundational for the Finite Model Property (FMP).

## Overview

For the FMP construction via filtration, we need MCS restricted to the subformula
closure of the target formula. This ensures:
1. The canonical model construction terminates
2. Equivalence classes are determined by finitely many formulas
3. The filtered model has bounded cardinality

## Main Definitions

- `ClosureMCS`: Re-export of `RestrictedMCS` specialized for FMP usage
- Projection theorems for full MCS to closure MCS
- Cardinality bounds

## Integration with FMP

The closure MCS infrastructure connects to filtration as follows:
1. Start with formula phi that is not valid
2. By contrapositive of completeness, phi is not derivable
3. neg phi is consistent, so extends to MCS
4. Restrict MCS to subformula closure of phi
5. Use this as basis for canonical model construction
6. Filter to get finite model satisfying neg phi

## References

- RestrictedMCS.lean: Core restricted MCS construction
- SubformulaClosure.lean: Subformula closure definitions
- Implementation Plan v2 Phase 1
-/

namespace Bimodal.Metalogic.Decidability.FMP

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.ProofSystem

/-!
## Core Closure MCS Definitions

We re-export and specialize the RestrictedMCS infrastructure for FMP usage.
-/

/--
A Closure MCS is a maximal consistent set restricted to the closure of a formula.
This is an alias for RestrictedMCS with explicit documentation for FMP context.

**Properties**:
- Closed under logical consequence within closure
- Negation complete for closure formulas
- Finite (bounded by 2 * |subformulaClosure phi|)
-/
abbrev ClosureMCS (phi : Formula) (S : Set Formula) : Prop :=
  RestrictedMCS phi S

/--
Closure consistency: a set is closure-consistent if it's a subset of
closureWithNeg and is set-consistent.
-/
abbrev ClosureConsistent (phi : Formula) (S : Set Formula) : Prop :=
  RestrictedConsistent phi S

/-!
## Projection from Full MCS to Closure MCS

Key theorem: any full MCS projected to the closure yields a closure MCS.
-/

/--
Project a set to the closure by intersection.
-/
def projectToClosure (phi : Formula) (S : Set Formula) : Set Formula :=
  S ∩ (closureWithNeg phi : Set Formula)

/--
Projection to closure is closure-restricted.
-/
theorem projectToClosure_restricted (phi : Formula) (S : Set Formula) :
    ClosureRestricted phi (projectToClosure phi S) := by
  intro psi h
  exact Set.mem_of_mem_inter_right h

/--
Projection preserves consistency.
-/
theorem projectToClosure_preserves_consistency (phi : Formula) (S : Set Formula)
    (h_cons : SetConsistent S) :
    SetConsistent (projectToClosure phi S) := by
  intro L hL
  apply h_cons L
  intro psi hpsi
  have := hL psi hpsi
  exact Set.mem_of_mem_inter_left this

/--
If S is a full SetMaximalConsistent set, then its projection to closure
is closure-consistent.
-/
theorem full_mcs_projection_consistent (phi : Formula) (S : Set Formula)
    (h_mcs : SetMaximalConsistent S) :
    ClosureConsistent phi (projectToClosure phi S) :=
  ⟨projectToClosure_restricted phi S, projectToClosure_preserves_consistency phi S h_mcs.1⟩

/-!
## Key Properties for FMP

Properties that connect closure MCS to the filtration construction.
-/

/--
For any closure MCS and any formula psi in the subformula closure,
either psi or neg psi is in the MCS.

This is the negation completeness property essential for filtration.
-/
theorem closure_mcs_negation_complete {phi : Formula} {S : Set Formula}
    (h_mcs : ClosureMCS phi S) (psi : Formula)
    (h_psi : psi ∈ subformulaClosure phi) :
    psi ∈ S ∨ psi.neg ∈ S :=
  restricted_mcs_negation_complete h_mcs psi h_psi

/--
A closure MCS contains either phi or neg phi.
-/
theorem closure_mcs_formula_decided {phi : Formula} {S : Set Formula}
    (h_mcs : ClosureMCS phi S) :
    phi ∈ S ∨ phi.neg ∈ S :=
  closure_mcs_negation_complete h_mcs phi (self_mem_subformulaClosure phi)

/--
A closure MCS is set-consistent.
-/
theorem closure_mcs_consistent {phi : Formula} {S : Set Formula}
    (h_mcs : ClosureMCS phi S) :
    SetConsistent S :=
  restricted_mcs_is_consistent h_mcs

/--
A closure MCS is bounded by the closure.
-/
theorem closure_mcs_bounded {phi : Formula} {S : Set Formula}
    (h_mcs : ClosureMCS phi S) :
    S ⊆ (closureWithNeg phi : Set Formula) :=
  restricted_mcs_is_closure_restricted h_mcs

/-!
## Deductive Closure Property

Closure MCS is deductively closed for closure formulas.
-/

/--
If Γ ⊆ S and Γ ⊢ chi and chi ∈ closureWithNeg phi, then chi ∈ S.
-/
theorem closure_mcs_deductively_closed {phi : Formula} {S : Set Formula}
    (h_mcs : ClosureMCS phi S)
    {Γ : List Formula} {chi : Formula}
    (h_Γ_sub : ∀ ψ ∈ Γ, ψ ∈ S)
    (h_deriv : DerivationTree Γ chi)
    (h_chi_clos : chi ∈ closureWithNeg phi) :
    chi ∈ S := by
  by_contra h_chi_not
  -- By maximality, insert chi S is inconsistent
  have h_incons := h_mcs.2 chi h_chi_clos h_chi_not
  -- Show insert chi S is consistent, contradiction
  apply h_incons
  intro L hL ⟨d⟩
  -- d : DerivationTree L Formula.bot
  -- L ⊆ insert chi S
  let L' := L.filter (· ≠ chi)
  have hL'_in_S : ∀ ψ ∈ L', ψ ∈ S := by
    intro ψ hψ
    have hψ' := List.mem_filter.mp hψ
    have hψne : ψ ≠ chi := by simpa using hψ'.2
    specialize hL ψ hψ'.1
    cases Set.mem_insert_iff.mp hL with
    | inl h_eq => exact absurd h_eq hψne
    | inr h_in_S => exact h_in_S
  have hL_sub : L ⊆ chi :: L' := by
    intro ψ hψ
    by_cases h : ψ = chi
    · simp [h]
    · simp only [List.mem_cons]; right
      exact List.mem_filter.mpr ⟨hψ, by simpa⟩
  have d' : DerivationTree (chi :: L') Formula.bot :=
    DerivationTree.weakening L (chi :: L') Formula.bot d hL_sub
  have d_neg : DerivationTree L' chi.neg := deduction_theorem L' chi Formula.bot d'
  -- Weaken Γ ⊢ chi to L' ++ Γ ⊢ chi
  have h_deriv' : DerivationTree (L' ++ Γ) chi :=
    DerivationTree.weakening Γ (L' ++ Γ) chi h_deriv (List.subset_append_right L' Γ)
  -- Weaken d_neg to L' ++ Γ
  have d_neg' : DerivationTree (L' ++ Γ) chi.neg :=
    DerivationTree.weakening L' (L' ++ Γ) chi.neg d_neg (List.subset_append_left L' Γ)
  -- Combine to get ⊥
  have d_bot : DerivationTree (L' ++ Γ) Formula.bot :=
    derives_bot_from_phi_neg_phi h_deriv' d_neg'
  -- But L' ++ Γ ⊆ S, contradicting consistency
  have h_LΓ_in_S : ∀ ψ ∈ L' ++ Γ, ψ ∈ S := by
    intro ψ hψ
    simp only [List.mem_append] at hψ
    cases hψ with
    | inl h => exact hL'_in_S ψ h
    | inr h => exact h_Γ_sub ψ h
  exact h_mcs.1.2 (L' ++ Γ) h_LΓ_in_S ⟨d_bot⟩

/-!
## Constructing Closure MCS

Helper functions for constructing closure MCS containing specific formulas.
-/

/--
If phi is satisfiable (not a theorem that neg phi), then there exists a
closure MCS containing phi.
-/
theorem closure_mcs_exists_from_consistent_formula (phi : Formula)
    (h_cons : ¬Nonempty (DerivationTree [] phi.neg)) :
    ∃ S : Set Formula, phi ∈ S ∧ ClosureMCS phi S :=
  restricted_mcs_from_formula phi h_cons

/--
For any formula in closureWithNeg phi that is consistent (singleton is consistent),
there exists a closure MCS containing it.
-/
theorem closure_mcs_exists_containing (phi psi : Formula)
    (h_psi_clos : psi ∈ closureWithNeg phi)
    (h_cons : SetConsistent {psi}) :
    ∃ S : Set Formula, psi ∈ S ∧ ClosureMCS phi S :=
  restricted_mcs_exists_containing phi psi h_psi_clos h_cons

/--
Extend any closure-consistent set to a closure MCS.
-/
theorem closure_mcs_extension (phi : Formula) (S : Set Formula)
    (h_restricted : ClosureRestricted phi S) (h_cons : SetConsistent S) :
    ∃ M : Set Formula, S ⊆ M ∧ ClosureMCS phi M :=
  restricted_lindenbaum phi S h_restricted h_cons

/-!
## Cardinality Bounds

The closure MCS has bounded cardinality.
-/

/--
Any closure MCS is bounded by closureWithNeg, which is finite.
-/
theorem closure_mcs_finite_bound {phi : Formula} {S : Set Formula}
    (h_mcs : ClosureMCS phi S) :
    S ⊆ (closureWithNeg phi : Set Formula) :=
  closure_mcs_bounded h_mcs

/--
The cardinality bound for closure MCS.
Since S ⊆ closureWithNeg phi, we have |S| ≤ |closureWithNeg phi|.
And |closureWithNeg phi| ≤ 2 * |subformulaClosure phi|.
-/
theorem closure_mcs_card_bound (phi : Formula) :
    (closureWithNeg phi).card ≤ 2 * (subformulaClosure phi).card := by
  unfold closureWithNeg
  calc (subformulaClosure phi ∪ (subformulaClosure phi).image Formula.neg).card
      ≤ (subformulaClosure phi).card + ((subformulaClosure phi).image Formula.neg).card := by
        exact Finset.card_union_le _ _
    _ ≤ (subformulaClosure phi).card + (subformulaClosure phi).card := by
        apply Nat.add_le_add_left
        exact Finset.card_image_le
    _ = 2 * (subformulaClosure phi).card := by omega

end Bimodal.Metalogic.Decidability.FMP
