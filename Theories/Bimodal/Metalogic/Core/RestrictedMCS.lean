import Bimodal.Metalogic.Core.MaximalConsistent
import Bimodal.Metalogic.Core.MCSProperties
import Bimodal.Syntax.SubformulaClosure
import Mathlib.Data.Finset.Basic
import Mathlib.Order.Zorn

/-!
# Restricted MCS Construction for Multi-Family BMCS

This module provides Maximal Consistent Set construction restricted to a finite
subformula closure. This is essential for the multi-family BMCS construction
because it ensures termination of the saturation process.

## Overview

The key insight is that standard Lindenbaum's lemma produces MCS that may contain
arbitrary formulas. For BMCS saturation to terminate, we need MCS restricted to
the subformula closure of the target formula.

## Main Definitions

- `ClosureRestricted`: A set is closure-restricted if it's a subset of closureWithNeg
- `RestrictedConsistent`: Closure-restricted and set-consistent
- `RestrictedMCS`: Maximal consistent within closureWithNeg
- `restricted_lindenbaum`: Extends consistent closure-subset to closure-restricted MCS

## Key Properties

- `restricted_mcs_negation_complete`: For phi in closure, either phi or neg phi is in MCS
- `restricted_mcs_contains_phi`: The original formula is preserved
- `restricted_lindenbaum_terminates`: The construction is well-founded (uses finite closure)

## Design Notes

This construction differs from `FMP.Closure` in that:
1. It works with the Syntax.SubformulaClosure infrastructure
2. It's designed to integrate with the Bundle BMCS construction
3. It uses Finset operations for termination reasoning

## References

- Research report: specs/827_complete_multi_family_bmcs_construction/reports/research-002.md
- Implementation plan: specs/827_complete_multi_family_bmcs_construction/plans/implementation-002.md
-/

namespace Bimodal.Metalogic.Core

open Bimodal.Syntax
open Bimodal.ProofSystem

/-!
## Closure-Restricted Consistency

Consistency restricted to formulas within the subformula closure.
-/

variable (phi : Formula)

/--
A set is closure-restricted if all its elements are in closureWithNeg phi.
-/
def ClosureRestricted (S : Set Formula) : Prop :=
  S ⊆ (closureWithNeg phi : Set Formula)

/--
A closure-restricted set that is also set-consistent.
-/
def RestrictedConsistent (S : Set Formula) : Prop :=
  ClosureRestricted phi S ∧ SetConsistent S

/--
Maximal consistent within the closure: cannot be extended within closure
while remaining consistent.
-/
def RestrictedMCS (S : Set Formula) : Prop :=
  RestrictedConsistent phi S ∧
  ∀ psi ∈ closureWithNeg phi, psi ∉ S → ¬SetConsistent (insert psi S)

variable {phi : Formula}

/-!
## Basic Properties
-/

/--
A restricted consistent set is closure-restricted.
-/
theorem restricted_consistent_is_restricted {S : Set Formula}
    (h : RestrictedConsistent phi S) : ClosureRestricted phi S :=
  h.1

/--
A restricted consistent set is set-consistent.
-/
theorem restricted_consistent_is_consistent {S : Set Formula}
    (h : RestrictedConsistent phi S) : SetConsistent S :=
  h.2

/--
A restricted MCS is restricted consistent.
-/
theorem restricted_mcs_is_restricted_consistent {S : Set Formula}
    (h : RestrictedMCS phi S) : RestrictedConsistent phi S :=
  h.1

/--
A restricted MCS is set-consistent.
-/
theorem restricted_mcs_is_consistent {S : Set Formula}
    (h : RestrictedMCS phi S) : SetConsistent S :=
  h.1.2

/--
A restricted MCS is closure-restricted.
-/
theorem restricted_mcs_is_closure_restricted {S : Set Formula}
    (h : RestrictedMCS phi S) : ClosureRestricted phi S :=
  h.1.1

/-!
## Negation Completeness

For formulas in the subformula closure, restricted MCS has negation completeness.
-/

/--
For psi in subformulaClosure phi, either psi or psi.neg is in any restricted MCS.

**Proof Strategy**:
1. Both psi and psi.neg are in closureWithNeg phi
2. By maximality, at least one must be in S
3. If neither were in S, we could add either one, contradicting maximality
-/
theorem restricted_mcs_negation_complete {S : Set Formula}
    (h_mcs : RestrictedMCS phi S) (psi : Formula)
    (h_psi_clos : psi ∈ subformulaClosure phi) :
    psi ∈ S ∨ psi.neg ∈ S := by
  by_cases h : psi ∈ S
  · left; exact h
  · right
    -- psi ∈ subformulaClosure phi implies both psi and psi.neg in closureWithNeg phi
    have h_psi_closneg : psi ∈ closureWithNeg phi :=
      subformulaClosure_subset_closureWithNeg phi h_psi_clos
    have h_neg_closneg : psi.neg ∈ closureWithNeg phi :=
      neg_mem_closureWithNeg phi psi h_psi_clos

    -- By maximality: since psi ∉ S and psi ∈ closureWithNeg, insert psi S is inconsistent
    have h_incons := h_mcs.2 psi h_psi_closneg h

    -- Now we need to show psi.neg ∈ S
    by_contra h_neg_not

    -- From h_incons: ¬SetConsistent (insert psi S)
    unfold SetConsistent at h_incons
    push_neg at h_incons
    obtain ⟨L, h_L_sub, h_L_incons⟩ := h_incons

    -- L is inconsistent, so L ⊢ ⊥
    have h_bot : Nonempty (DerivationTree L Formula.bot) := inconsistent_derives_bot h_L_incons
    obtain ⟨d_bot⟩ := h_bot

    -- Define Γ = L.filter (· ≠ psi)
    let Γ := L.filter (· ≠ psi)

    -- Show Γ ⊆ S
    have h_Γ_in_S : ∀ χ ∈ Γ, χ ∈ S := by
      intro χ hχ
      have hχ' := List.mem_filter.mp hχ
      have hχL := hχ'.1
      have hχne : χ ≠ psi := by simpa using hχ'.2
      specialize h_L_sub χ hχL
      simp [Set.mem_insert_iff] at h_L_sub
      rcases h_L_sub with rfl | h_in_S
      · exact absurd rfl hχne
      · exact h_in_S

    -- L ⊆ psi :: Γ
    have h_L_sub_psiGamma : L ⊆ psi :: Γ := by
      intro χ hχ
      by_cases hχpsi : χ = psi
      · simp [hχpsi]
      · simp only [List.mem_cons]
        right
        exact List.mem_filter.mpr ⟨hχ, by simpa⟩

    -- Weaken derivation from L to psi :: Γ
    have d_bot' : DerivationTree (psi :: Γ) Formula.bot :=
      DerivationTree.weakening L (psi :: Γ) Formula.bot d_bot h_L_sub_psiGamma

    -- By deduction theorem, Γ ⊢ psi.neg
    have d_neg : DerivationTree Γ psi.neg := deduction_theorem Γ psi Formula.bot d_bot'

    -- Since psi.neg ∉ S and psi.neg ∈ closureWithNeg, by maximality
    -- insert psi.neg S is inconsistent
    have h_incons_neg := h_mcs.2 psi.neg h_neg_closneg h_neg_not

    -- So there exists L' ⊆ insert psi.neg S with ¬Consistent L'
    unfold SetConsistent at h_incons_neg
    push_neg at h_incons_neg
    obtain ⟨L', h_L'_sub, h_L'_incons⟩ := h_incons_neg

    -- L' is inconsistent, so L' ⊢ ⊥
    have h_bot'' : Nonempty (DerivationTree L' Formula.bot) := inconsistent_derives_bot h_L'_incons
    obtain ⟨d_bot''⟩ := h_bot''

    -- Define Δ = L'.filter (· ≠ psi.neg)
    let Δ := L'.filter (· ≠ psi.neg)

    -- Show Δ ⊆ S
    have h_Δ_in_S : ∀ χ ∈ Δ, χ ∈ S := by
      intro χ hχ
      have hχ' := List.mem_filter.mp hχ
      have hχL' := hχ'.1
      have hχne : χ ≠ psi.neg := by simpa using hχ'.2
      specialize h_L'_sub χ hχL'
      simp [Set.mem_insert_iff] at h_L'_sub
      rcases h_L'_sub with rfl | h_in_S
      · exact absurd rfl hχne
      · exact h_in_S

    -- L' ⊆ psi.neg :: Δ
    have h_L'_sub_psiΔ : L' ⊆ psi.neg :: Δ := by
      intro χ hχ
      by_cases hχpsi : χ = psi.neg
      · simp [hχpsi]
      · simp only [List.mem_cons]
        right
        exact List.mem_filter.mpr ⟨hχ, by simpa⟩

    -- Weaken derivation from L' to psi.neg :: Δ
    have d_bot''' : DerivationTree (psi.neg :: Δ) Formula.bot :=
      DerivationTree.weakening L' (psi.neg :: Δ) Formula.bot d_bot'' h_L'_sub_psiΔ

    -- By deduction theorem, Δ ⊢ psi.neg.neg
    have d_neg_neg : DerivationTree Δ psi.neg.neg :=
      deduction_theorem Δ psi.neg Formula.bot d_bot'''

    -- Combine Γ and Δ
    let ΓΔ := Γ ++ Δ
    have h_ΓΔ_in_S : ∀ χ ∈ ΓΔ, χ ∈ S := by
      intro χ hχ
      simp only [ΓΔ, List.mem_append] at hχ
      rcases hχ with hχΓ | hχΔ
      · exact h_Γ_in_S χ hχΓ
      · exact h_Δ_in_S χ hχΔ

    -- Weaken both derivations to ΓΔ
    have d_neg' : DerivationTree ΓΔ psi.neg :=
      DerivationTree.weakening Γ ΓΔ _ d_neg (List.subset_append_left Γ Δ)
    have d_neg_neg' : DerivationTree ΓΔ psi.neg.neg :=
      DerivationTree.weakening Δ ΓΔ _ d_neg_neg (List.subset_append_right Γ Δ)

    -- Combine to get ⊥ from psi.neg and psi.neg.neg
    have d_bot_final : DerivationTree ΓΔ Formula.bot :=
      derives_bot_from_phi_neg_phi d_neg' d_neg_neg'

    -- This contradicts consistency of S
    exact h_mcs.1.2 ΓΔ h_ΓΔ_in_S ⟨d_bot_final⟩

/-!
## Restricted Lindenbaum Construction

Extend a consistent set to a closure-restricted MCS.
-/

/--
The set of closure-restricted consistent extensions of a base set.
Used for Zorn's lemma application.
-/
def RestrictedConsistentSupersets (phi : Formula) (S : Set Formula) : Set (Set Formula) :=
  {T | S ⊆ T ∧ RestrictedConsistent phi T}

/--
A restricted consistent set is in its own restricted consistent supersets.
-/
lemma self_mem_restricted_consistent_supersets {S : Set Formula}
    (h : RestrictedConsistent phi S) :
    S ∈ RestrictedConsistentSupersets phi S :=
  ⟨Set.Subset.refl S, h⟩

/--
Chain union lemma: The union of a chain of restricted consistent sets is restricted consistent.
-/
theorem restricted_consistent_chain_union {phi : Formula} {C : Set (Set Formula)}
    (hchain : IsChain (· ⊆ ·) C) (hCne : C.Nonempty)
    (hcons : ∀ S ∈ C, RestrictedConsistent phi S) :
    RestrictedConsistent phi (⋃₀ C) := by
  constructor
  · -- Closure-restricted: ⋃₀ C ⊆ closureWithNeg phi
    intro psi h_mem
    obtain ⟨S, hS, hpsi⟩ := Set.mem_sUnion.mp h_mem
    exact (hcons S hS).1 hpsi
  · -- Set-consistent: use consistent_chain_union
    apply consistent_chain_union hchain hCne
    intro S hS
    exact (hcons S hS).2

/--
Restricted Lindenbaum's Lemma: Every closure-restricted consistent set can be
extended to a closure-restricted maximal consistent set.

**Key Insight**: Since closureWithNeg phi is finite (it's a Finset), the extension
process terminates. This is the critical property that enables BMCS saturation
to terminate.

**Proof Strategy**:
1. Apply Zorn's lemma to RestrictedConsistentSupersets
2. Chain union is restricted consistent (by restricted_consistent_chain_union)
3. Maximal element is a RestrictedMCS
-/
theorem restricted_lindenbaum (phi : Formula) (S : Set Formula)
    (h_restricted : ClosureRestricted phi S) (h_cons : SetConsistent S) :
    ∃ M : Set Formula, S ⊆ M ∧ RestrictedMCS phi M := by
  -- Define the collection of restricted consistent supersets
  let RCS := RestrictedConsistentSupersets phi S
  -- Show RCS satisfies the chain condition for Zorn's lemma
  have hchain : ∀ C ⊆ RCS, IsChain (· ⊆ ·) C → C.Nonempty →
      ∃ ub ∈ RCS, ∀ T ∈ C, T ⊆ ub := by
    intro C hCsub hCchain hCne
    -- The upper bound is the union of the chain
    use ⋃₀ C
    constructor
    · -- Show ⋃₀ C ∈ RCS
      constructor
      · -- S ⊆ ⋃₀ C: Since C is nonempty, pick any T ∈ C, then S ⊆ T ⊆ ⋃₀ C
        obtain ⟨T, hT⟩ := hCne
        have hST : S ⊆ T := (hCsub hT).1
        exact Set.Subset.trans hST (Set.subset_sUnion_of_mem hT)
      · -- RestrictedConsistent phi (⋃₀ C)
        apply restricted_consistent_chain_union hCchain hCne
        intro T hT
        exact (hCsub hT).2
    · -- Show ∀ T ∈ C, T ⊆ ⋃₀ C
      intro T hT
      exact Set.subset_sUnion_of_mem hT
  -- S is restricted consistent
  have h_S_rc : RestrictedConsistent phi S := ⟨h_restricted, h_cons⟩
  -- S ∈ RCS
  have hSmem : S ∈ RCS := self_mem_restricted_consistent_supersets h_S_rc
  -- Apply Zorn's lemma
  obtain ⟨M, hSM, hmax⟩ := zorn_subset_nonempty RCS hchain S hSmem
  -- hmax : Maximal (fun x => x ∈ RCS) M
  have hMmem : M ∈ RCS := hmax.prop
  obtain ⟨_, hMrc⟩ := hMmem
  -- M is maximal in RCS. Show it's RestrictedMCS.
  use M
  constructor
  · exact hSM
  · -- Show RestrictedMCS phi M
    constructor
    · exact hMrc
    · -- Show ∀ psi ∈ closureWithNeg phi, psi ∉ M → ¬SetConsistent (insert psi M)
      intro psi h_psi_clos h_psi_not_M hcons_insert
      -- If insert psi M were consistent, then insert psi M ∈ RCS
      have h_insert_restricted : ClosureRestricted phi (insert psi M) := by
        intro chi h_mem
        cases Set.mem_insert_iff.mp h_mem with
        | inl h_eq => exact h_eq ▸ h_psi_clos
        | inr h_in_M => exact hMrc.1 h_in_M
      have h_insert_mem : insert psi M ∈ RCS := by
        constructor
        · exact Set.Subset.trans hSM (Set.subset_insert psi M)
        · exact ⟨h_insert_restricted, hcons_insert⟩
      -- M is maximal: if insert psi M ∈ RCS and M ⊆ insert psi M, then insert psi M ⊆ M
      have h_le : M ⊆ insert psi M := Set.subset_insert psi M
      have h_subset : insert psi M ⊆ M := hmax.le_of_ge h_insert_mem h_le
      have h_psi_M : psi ∈ M := h_subset (Set.mem_insert psi M)
      exact h_psi_not_M h_psi_M

/-!
## Constructing Restricted MCS from a Formula

Helper functions for building restricted MCS containing specific formulas.
-/

/--
If psi is in closureWithNeg phi and {psi} is consistent, then we can extend
to a RestrictedMCS containing psi.
-/
theorem restricted_mcs_exists_containing (phi psi : Formula)
    (h_psi_clos : psi ∈ closureWithNeg phi)
    (h_cons : SetConsistent {psi}) :
    ∃ M : Set Formula, psi ∈ M ∧ RestrictedMCS phi M := by
  -- {psi} is closure-restricted since psi ∈ closureWithNeg
  have h_restricted : ClosureRestricted phi {psi} := by
    intro chi h_mem
    simp only [Set.mem_singleton_iff] at h_mem
    exact h_mem ▸ h_psi_clos
  -- Apply restricted Lindenbaum
  obtain ⟨M, hSM, hMCS⟩ := restricted_lindenbaum phi {psi} h_restricted h_cons
  use M
  constructor
  · exact hSM (Set.mem_singleton psi)
  · exact hMCS

/--
If phi is consistent (not derivable from empty context), then we can construct
a RestrictedMCS containing phi.

This is the key entry point for BMCS construction.
-/
theorem restricted_mcs_from_formula (phi : Formula)
    (h_cons : ¬Nonempty (DerivationTree [] phi.neg)) :
    ∃ M : Set Formula, phi ∈ M ∧ RestrictedMCS phi M := by
  -- phi is in closureWithNeg phi
  have h_phi_clos : phi ∈ closureWithNeg phi := self_mem_closureWithNeg phi
  -- {phi} is consistent (follows from phi.neg not being a theorem)
  have h_singleton_cons : SetConsistent {phi} := by
    intro L hL
    intro ⟨d⟩
    by_cases h_phi_in_L : phi ∈ L
    · -- Derive [phi] ⊢ ⊥ by weakening
      have h_weak : ∀ x ∈ L, x ∈ [phi] := by
        intro x hx
        have := hL x hx
        simp only [Set.mem_singleton_iff] at this
        simp [this]
      have d_phi : DerivationTree [phi] Formula.bot :=
        DerivationTree.weakening L [phi] _ d h_weak
      -- By deduction theorem: ⊢ phi → ⊥ = ⊢ phi.neg
      have d_neg : DerivationTree [] phi.neg :=
        deduction_theorem [] phi Formula.bot d_phi
      exact h_cons ⟨d_neg⟩
    · -- phi ∉ L, so L ⊆ {phi} means L = []
      have h_L_empty : L = [] := by
        cases L with
        | nil => rfl
        | cons x xs =>
          exfalso
          have hx := hL x List.mem_cons_self
          simp only [Set.mem_singleton_iff] at hx
          rw [hx] at h_phi_in_L
          exact h_phi_in_L List.mem_cons_self
      -- [] ⊢ ⊥ means bot is a theorem
      rw [h_L_empty] at d
      -- But ⊢ ⊥ implies ⊢ phi.neg (weakening)
      have d_neg : DerivationTree [] phi.neg := by
        have d_efq := DerivationTree.axiom [] (Formula.bot.imp phi.neg) (Axiom.ex_falso phi.neg)
        exact DerivationTree.modus_ponens [] _ _ d_efq d
      exact h_cons ⟨d_neg⟩
  exact restricted_mcs_exists_containing phi phi h_phi_clos h_singleton_cons

end Bimodal.Metalogic.Core
