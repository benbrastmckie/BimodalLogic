import Bimodal.Metalogic.Core.MaximalConsistent
import Bimodal.Metalogic.Core.MCSProperties
import Bimodal.Syntax.SubformulaClosure
import Mathlib.Data.Finset.Basic
import Mathlib.Order.Zorn
import Bimodal.Metalogic.Bundle.CanonicalTaskRelation
import Bimodal.Metalogic.Bundle.SuccExistence

/-!
# Restricted MCS Construction for Multi-Family BFMCS

This module provides Maximal Consistent Set construction restricted to a finite
subformula closure. This is essential for the multi-family BFMCS construction
because it ensures termination of the saturation process.

## Overview

The key insight is that standard Lindenbaum's lemma produces MCS that may contain
arbitrary formulas. For BFMCS saturation to terminate, we need MCS restricted to
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

This construction:
1. Works with the Syntax.SubformulaClosure infrastructure
2. Is designed to integrate with the Bundle BFMCS construction
3. Uses Finset operations for termination reasoning

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
process terminates. This is the critical property that enables BFMCS saturation
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

This is the key entry point for BFMCS construction.
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

/-!
## iter_F Boundedness in RestrictedMCS

These lemmas establish that iter_F iterations must eventually leave any RestrictedMCS,
because RestrictedMCS is bounded by closureWithNeg and iter_F eventually leaves
closureWithNeg.
-/

open Bimodal.Metalogic.Bundle

/--
In any RestrictedMCS M over phi, there exists n such that iter_F n phi is not in M.

This follows because:
1. M ⊆ closureWithNeg phi (by definition of RestrictedMCS)
2. iter_F leaves closureWithNeg for large n (by iter_F_not_mem_closureWithNeg)
3. Therefore iter_F leaves M
-/
theorem restricted_mcs_iter_F_bound (phi : Formula) (M : Set Formula)
    (h_mcs : RestrictedMCS phi M) :
    ∃ n : Nat, iter_F n phi ∉ M := by
  use closure_F_bound phi
  intro h_mem
  have h_closure : ClosureRestricted phi M := restricted_mcs_is_closure_restricted h_mcs
  have h_in_closure : iter_F (closure_F_bound phi) phi ∈ closureWithNeg phi := h_closure h_mem
  exact iter_F_leaves_closure phi h_in_closure

/--
If F(phi) is in a RestrictedMCS M, then there exists d >= 1 such that:
- iter_F d phi is in M (the last F-iteration that's still in M)
- iter_F (d + 1) phi is not in M (the first F-iteration that left M)

This is the key lemma for proving f_nesting_is_bounded in the succ_chain_fam construction.

The proof uses WellFounded.has_min to find the boundary point where iter_F transitions
from being in M to not being in M.
-/
theorem restricted_mcs_F_bounded (phi : Formula) (M : Set Formula)
    (h_mcs : RestrictedMCS phi M)
    (h_F_in : Formula.some_future phi ∈ M) :
    ∃ d : Nat, d ≥ 1 ∧ iter_F d phi ∈ M ∧ iter_F (d + 1) phi ∉ M := by
  -- First, show iter_F 1 phi = F(phi) ∈ M
  have h_one_in : iter_F 1 phi ∈ M := by
    simp only [iter_F_one_eq_some_future]
    exact h_F_in
  -- The set of n >= 2 where iter_F n phi ∉ M is nonempty (contains closure_F_bound phi)
  -- We use the explicit bound from restricted_mcs_iter_F_bound
  let exit_bound := closure_F_bound phi
  have h_exit_bound_not : iter_F exit_bound phi ∉ M := by
    intro h_mem
    have h_closure : ClosureRestricted phi M := restricted_mcs_is_closure_restricted h_mcs
    have h_in_closure : iter_F exit_bound phi ∈ closureWithNeg phi := h_closure h_mem
    exact iter_F_leaves_closure phi h_in_closure

  -- exit_bound >= 1 since closure_F_bound = max_F_depth + 1
  have h_exit_ge1 : exit_bound ≥ 1 := by
    unfold exit_bound closure_F_bound
    omega

  -- If exit_bound = 1, then iter_F 1 phi ∉ M contradicts h_one_in
  -- So exit_bound >= 2
  have h_exit_ge2 : exit_bound ≥ 2 := by
    by_contra h
    push_neg at h
    have h_eq : exit_bound = 1 := by omega
    rw [h_eq] at h_exit_bound_not
    exact h_exit_bound_not h_one_in

  -- Define the set S = { n : Nat | n >= 2 ∧ iter_F n phi ∉ M }
  let S : Set Nat := { n | n ≥ 2 ∧ iter_F n phi ∉ M }
  have h_S_nonempty : S.Nonempty := ⟨exit_bound, h_exit_ge2, h_exit_bound_not⟩

  -- Use well-foundedness of < on Nat to get a minimum element
  have h_wf : WellFounded (· < · : Nat → Nat → Prop) := Nat.lt_wfRel.wf
  obtain ⟨min_n, h_min_mem, h_min_least⟩ := WellFounded.has_min h_wf S h_S_nonempty

  -- Extract properties from h_min_mem : min_n ∈ S
  obtain ⟨h_min_ge2, h_min_not⟩ := h_min_mem

  -- d = min_n - 1 works
  use min_n - 1
  constructor
  · omega
  constructor
  · -- Show iter_F (min_n - 1) phi ∈ M
    -- By minimality of min_n: if min_n - 1 ∈ S, then ¬(min_n - 1 < min_n), contradiction
    -- So min_n - 1 ∉ S, meaning either min_n - 1 < 2 or iter_F (min_n - 1) phi ∈ M
    by_contra h_not_in
    -- If iter_F (min_n - 1) phi ∉ M and min_n - 1 >= 2, then min_n - 1 ∈ S
    have h_pred_lt : min_n - 1 < min_n := by omega
    -- Case split on whether min_n - 1 >= 2
    by_cases h_pred_ge2 : min_n - 1 ≥ 2
    · -- min_n - 1 ∈ S since min_n - 1 >= 2 and iter_F (min_n - 1) phi ∉ M
      have h_pred_in_S : min_n - 1 ∈ S := ⟨h_pred_ge2, h_not_in⟩
      -- But by minimality, ¬(min_n - 1 < min_n), contradiction
      exact h_min_least (min_n - 1) h_pred_in_S h_pred_lt
    · -- min_n - 1 < 2, so min_n - 1 = 0 or 1
      -- Since min_n >= 2, we have min_n - 1 >= 1, so min_n - 1 = 1
      have h_pred_eq1 : min_n - 1 = 1 := by omega
      rw [h_pred_eq1] at h_not_in
      exact h_not_in h_one_in
  · -- Show iter_F min_n phi ∉ M
    have h_eq : min_n - 1 + 1 = min_n := by omega
    rw [h_eq]
    exact h_min_not

/-!
## iter_P Boundedness in RestrictedMCS

These lemmas establish that iter_P iterations must eventually leave any RestrictedMCS,
because RestrictedMCS is bounded by closureWithNeg and iter_P eventually leaves
closureWithNeg. Symmetric to the iter_F boundedness lemmas.
-/

/--
In any RestrictedMCS M over phi, there exists n such that iter_P n phi is not in M.

This follows because:
1. M ⊆ closureWithNeg phi (by definition of RestrictedMCS)
2. iter_P leaves closureWithNeg for large n (by iter_P_not_mem_closureWithNeg)
3. Therefore iter_P leaves M
-/
theorem restricted_mcs_iter_P_bound (phi : Formula) (M : Set Formula)
    (h_mcs : RestrictedMCS phi M) :
    ∃ n : Nat, iter_P n phi ∉ M := by
  use closure_P_bound phi
  intro h_mem
  have h_closure : ClosureRestricted phi M := restricted_mcs_is_closure_restricted h_mcs
  have h_in_closure : iter_P (closure_P_bound phi) phi ∈ closureWithNeg phi := h_closure h_mem
  exact iter_P_leaves_closure phi h_in_closure

/--
If P(phi) is in a RestrictedMCS M, then there exists d >= 1 such that:
- iter_P d phi is in M (the last P-iteration that's still in M)
- iter_P (d + 1) phi is not in M (the first P-iteration that left M)

This is the key lemma for proving p_nesting_is_bounded in the succ_chain_fam construction.
Symmetric to restricted_mcs_F_bounded.

The proof uses WellFounded.has_min to find the boundary point where iter_P transitions
from being in M to not being in M.
-/
theorem restricted_mcs_P_bounded (phi : Formula) (M : Set Formula)
    (h_mcs : RestrictedMCS phi M)
    (h_P_in : Formula.some_past phi ∈ M) :
    ∃ d : Nat, d ≥ 1 ∧ iter_P d phi ∈ M ∧ iter_P (d + 1) phi ∉ M := by
  -- First, show iter_P 1 phi = P(phi) ∈ M
  have h_one_in : iter_P 1 phi ∈ M := by
    simp only [iter_P_one_eq_some_past]
    exact h_P_in
  -- The set of n >= 2 where iter_P n phi ∉ M is nonempty (contains closure_P_bound phi)
  -- We use the explicit bound from restricted_mcs_iter_P_bound
  let exit_bound := closure_P_bound phi
  have h_exit_bound_not : iter_P exit_bound phi ∉ M := by
    intro h_mem
    have h_closure : ClosureRestricted phi M := restricted_mcs_is_closure_restricted h_mcs
    have h_in_closure : iter_P exit_bound phi ∈ closureWithNeg phi := h_closure h_mem
    exact iter_P_leaves_closure phi h_in_closure

  -- exit_bound >= 1 since closure_P_bound = max_P_depth + 1
  have h_exit_ge1 : exit_bound ≥ 1 := by
    unfold exit_bound closure_P_bound
    omega

  -- If exit_bound = 1, then iter_P 1 phi ∉ M contradicts h_one_in
  -- So exit_bound >= 2
  have h_exit_ge2 : exit_bound ≥ 2 := by
    by_contra h
    push_neg at h
    have h_eq : exit_bound = 1 := by omega
    rw [h_eq] at h_exit_bound_not
    exact h_exit_bound_not h_one_in

  -- Define the set S = { n : Nat | n >= 2 ∧ iter_P n phi ∉ M }
  let S : Set Nat := { n | n ≥ 2 ∧ iter_P n phi ∉ M }
  have h_S_nonempty : S.Nonempty := ⟨exit_bound, h_exit_ge2, h_exit_bound_not⟩

  -- Use well-foundedness of < on Nat to get a minimum element
  have h_wf : WellFounded (· < · : Nat → Nat → Prop) := Nat.lt_wfRel.wf
  obtain ⟨min_n, h_min_mem, h_min_least⟩ := WellFounded.has_min h_wf S h_S_nonempty

  -- Extract properties from h_min_mem : min_n ∈ S
  obtain ⟨h_min_ge2, h_min_not⟩ := h_min_mem

  -- d = min_n - 1 works
  use min_n - 1
  constructor
  · omega
  constructor
  · -- Show iter_P (min_n - 1) phi ∈ M
    -- By minimality of min_n: if min_n - 1 ∈ S, then ¬(min_n - 1 < min_n), contradiction
    -- So min_n - 1 ∉ S, meaning either min_n - 1 < 2 or iter_P (min_n - 1) phi ∈ M
    by_contra h_not_in
    -- If iter_P (min_n - 1) phi ∉ M and min_n - 1 >= 2, then min_n - 1 ∈ S
    have h_pred_lt : min_n - 1 < min_n := by omega
    -- Case split on whether min_n - 1 >= 2
    by_cases h_pred_ge2 : min_n - 1 ≥ 2
    · -- min_n - 1 ∈ S since min_n - 1 >= 2 and iter_P (min_n - 1) phi ∉ M
      have h_pred_in_S : min_n - 1 ∈ S := ⟨h_pred_ge2, h_not_in⟩
      -- But by minimality, ¬(min_n - 1 < min_n), contradiction
      exact h_min_least (min_n - 1) h_pred_in_S h_pred_lt
    · -- min_n - 1 < 2, so min_n - 1 = 0 or 1
      -- Since min_n >= 2, we have min_n - 1 >= 1, so min_n - 1 = 1
      have h_pred_eq1 : min_n - 1 = 1 := by omega
      rw [h_pred_eq1] at h_not_in
      exact h_not_in h_one_in
  · -- Show iter_P min_n phi ∉ M
    have h_eq : min_n - 1 + 1 = min_n := by omega
    rw [h_eq]
    exact h_min_not

/-!
## Deferral-Restricted MCS

MCS restricted to deferralClosure(phi) instead of closureWithNeg(phi).
The deferralClosure includes the deferral disjunctions needed by the
successor seed construction while preserving the same F/P-depth bounds.
-/

/--
A set is deferral-restricted if all its elements are in deferralClosure phi.
-/
def DeferralRestricted (phi : Formula) (S : Set Formula) : Prop :=
  S ⊆ (deferralClosure phi : Set Formula)

/--
A deferral-restricted set that is also set-consistent.
-/
def DeferralRestrictedConsistent (phi : Formula) (S : Set Formula) : Prop :=
  DeferralRestricted phi S ∧ SetConsistent S

/--
Maximal consistent within the deferral closure: cannot be extended within
deferralClosure while remaining consistent.
-/
def DeferralRestrictedMCS (phi : Formula) (S : Set Formula) : Prop :=
  DeferralRestrictedConsistent phi S ∧
  ∀ psi ∈ deferralClosure phi, psi ∉ S → ¬SetConsistent (insert psi S)

/--
A deferral restricted MCS is deferral-restricted.
-/
theorem deferral_restricted_mcs_is_restricted {phi : Formula} {S : Set Formula}
    (h : DeferralRestrictedMCS phi S) : DeferralRestricted phi S :=
  h.1.1

/--
A deferral restricted MCS is set-consistent.
-/
theorem deferral_restricted_mcs_is_consistent {phi : Formula} {S : Set Formula}
    (h : DeferralRestrictedMCS phi S) : SetConsistent S :=
  h.1.2

/--
Chain union lemma: The union of a chain of deferral-restricted consistent sets
is deferral-restricted consistent.
-/
theorem deferral_restricted_consistent_chain_union {phi : Formula} {C : Set (Set Formula)}
    (hchain : IsChain (· ⊆ ·) C) (hCne : C.Nonempty)
    (hcons : ∀ S ∈ C, DeferralRestrictedConsistent phi S) :
    DeferralRestrictedConsistent phi (⋃₀ C) := by
  constructor
  · intro psi h_mem
    obtain ⟨S, hS, hpsi⟩ := Set.mem_sUnion.mp h_mem
    exact (hcons S hS).1 hpsi
  · apply consistent_chain_union hchain hCne
    intro S hS
    exact (hcons S hS).2

/--
Deferral-Restricted Lindenbaum's Lemma: Every deferral-restricted consistent set can be
extended to a deferral-restricted maximal consistent set.
-/
theorem deferral_restricted_lindenbaum (phi : Formula) (S : Set Formula)
    (h_restricted : DeferralRestricted phi S) (h_cons : SetConsistent S) :
    ∃ M : Set Formula, S ⊆ M ∧ DeferralRestrictedMCS phi M := by
  -- Define the collection of deferral-restricted consistent supersets
  let RCS := {T | S ⊆ T ∧ DeferralRestrictedConsistent phi T}
  -- Show RCS satisfies the chain condition for Zorn's lemma
  have hchain : ∀ C ⊆ RCS, IsChain (· ⊆ ·) C → C.Nonempty →
      ∃ ub ∈ RCS, ∀ T ∈ C, T ⊆ ub := by
    intro C hCsub hCchain hCne
    use ⋃₀ C
    constructor
    · constructor
      · obtain ⟨T, hT⟩ := hCne
        exact Set.Subset.trans (hCsub hT).1 (Set.subset_sUnion_of_mem hT)
      · apply deferral_restricted_consistent_chain_union hCchain hCne
        intro T hT
        exact (hCsub hT).2
    · intro T hT
      exact Set.subset_sUnion_of_mem hT
  have h_S_rc : DeferralRestrictedConsistent phi S := ⟨h_restricted, h_cons⟩
  have hSmem : S ∈ RCS := ⟨Set.Subset.refl S, h_S_rc⟩
  obtain ⟨M, hSM, hmax⟩ := zorn_subset_nonempty RCS hchain S hSmem
  have hMmem := hmax.prop
  obtain ⟨_, hMrc⟩ := hMmem
  use M
  constructor
  · exact hSM
  · constructor
    · exact hMrc
    · intro psi h_psi_clos h_psi_not_M hcons_insert
      have h_insert_restricted : DeferralRestricted phi (insert psi M) := by
        intro chi h_mem
        cases Set.mem_insert_iff.mp h_mem with
        | inl h_eq => exact h_eq ▸ h_psi_clos
        | inr h_in_M => exact hMrc.1 h_in_M
      have h_insert_mem : insert psi M ∈ RCS := by
        constructor
        · exact Set.Subset.trans hSM (Set.subset_insert psi M)
        · exact ⟨h_insert_restricted, hcons_insert⟩
      have h_le : M ⊆ insert psi M := Set.subset_insert psi M
      have h_subset : insert psi M ⊆ M := hmax.le_of_ge h_insert_mem h_le
      exact h_psi_not_M (h_subset (Set.mem_insert psi M))

/-!
## Negation Completeness for DeferralRestrictedMCS

For formulas in the subformula closure (which is within deferralClosure),
deferral-restricted MCS has negation completeness.
-/

/--
For psi in subformulaClosure phi, either psi or psi.neg is in any DeferralRestrictedMCS.

This is the key property that allows us to treat DeferralRestrictedMCS as
"morally" an MCS within the closure. For formulas in the original subformula
closure, we still get the full MCS behavior.
-/
theorem deferral_restricted_mcs_negation_complete {phi : Formula} {S : Set Formula}
    (h_mcs : DeferralRestrictedMCS phi S) (psi : Formula)
    (h_psi_clos : psi ∈ subformulaClosure phi) :
    psi ∈ S ∨ psi.neg ∈ S := by
  by_cases h : psi ∈ S
  · left; exact h
  · right
    -- Both psi and psi.neg are in deferralClosure
    have h_psi_dc : psi ∈ deferralClosure phi :=
      closureWithNeg_subset_deferralClosure phi
        (subformulaClosure_subset_closureWithNeg phi h_psi_clos)
    have h_neg_dc : psi.neg ∈ deferralClosure phi :=
      closureWithNeg_subset_deferralClosure phi
        (neg_mem_closureWithNeg phi psi h_psi_clos)
    -- By maximality: since psi ∉ S and psi ∈ deferralClosure, insert psi S is inconsistent
    have h_incons := h_mcs.2 psi h_psi_dc h
    by_contra h_neg_not
    -- Same proof structure as restricted_mcs_negation_complete
    unfold SetConsistent at h_incons
    push_neg at h_incons
    obtain ⟨L, h_L_sub, h_L_incons⟩ := h_incons
    have h_bot : Nonempty (DerivationTree L Formula.bot) := inconsistent_derives_bot h_L_incons
    obtain ⟨d_bot⟩ := h_bot
    let Γ := L.filter (· ≠ psi)
    have h_Γ_in_S : ∀ χ ∈ Γ, χ ∈ S := by
      intro χ hχ
      have hχ' := List.mem_filter.mp hχ
      have hχne : χ ≠ psi := by simpa using hχ'.2
      specialize h_L_sub χ hχ'.1
      simp [Set.mem_insert_iff] at h_L_sub
      rcases h_L_sub with rfl | h_in_S
      · exact absurd rfl hχne
      · exact h_in_S
    have h_L_sub_psiGamma : L ⊆ psi :: Γ := by
      intro χ hχ
      by_cases hχpsi : χ = psi
      · simp [hχpsi]
      · simp only [List.mem_cons]
        right
        exact List.mem_filter.mpr ⟨hχ, by simpa⟩
    have d_bot' : DerivationTree (psi :: Γ) Formula.bot :=
      DerivationTree.weakening L (psi :: Γ) Formula.bot d_bot h_L_sub_psiGamma
    have d_neg : DerivationTree Γ psi.neg := deduction_theorem Γ psi Formula.bot d_bot'
    have h_incons_neg := h_mcs.2 psi.neg h_neg_dc h_neg_not
    unfold SetConsistent at h_incons_neg
    push_neg at h_incons_neg
    obtain ⟨L', h_L'_sub, h_L'_incons⟩ := h_incons_neg
    have h_bot'' : Nonempty (DerivationTree L' Formula.bot) := inconsistent_derives_bot h_L'_incons
    obtain ⟨d_bot''⟩ := h_bot''
    let Δ := L'.filter (· ≠ psi.neg)
    have h_Δ_in_S : ∀ χ ∈ Δ, χ ∈ S := by
      intro χ hχ
      have hχ' := List.mem_filter.mp hχ
      have hχne : χ ≠ psi.neg := by simpa using hχ'.2
      specialize h_L'_sub χ hχ'.1
      simp [Set.mem_insert_iff] at h_L'_sub
      rcases h_L'_sub with rfl | h_in_S
      · exact absurd rfl hχne
      · exact h_in_S
    have h_L'_sub_psiΔ : L' ⊆ psi.neg :: Δ := by
      intro χ hχ
      by_cases hχpsi : χ = psi.neg
      · simp [hχpsi]
      · simp only [List.mem_cons]
        right
        exact List.mem_filter.mpr ⟨hχ, by simpa⟩
    have d_bot''' : DerivationTree (psi.neg :: Δ) Formula.bot :=
      DerivationTree.weakening L' (psi.neg :: Δ) Formula.bot d_bot'' h_L'_sub_psiΔ
    have d_neg_neg : DerivationTree Δ psi.neg.neg :=
      deduction_theorem Δ psi.neg Formula.bot d_bot'''
    let ΓΔ := Γ ++ Δ
    have h_ΓΔ_in_S : ∀ χ ∈ ΓΔ, χ ∈ S := by
      intro χ hχ
      simp only [ΓΔ, List.mem_append] at hχ
      rcases hχ with hχΓ | hχΔ
      · exact h_Γ_in_S χ hχΓ
      · exact h_Δ_in_S χ hχΔ
    have d_neg' : DerivationTree ΓΔ psi.neg :=
      DerivationTree.weakening Γ ΓΔ _ d_neg (List.subset_append_left Γ Δ)
    have d_neg_neg' : DerivationTree ΓΔ psi.neg.neg :=
      DerivationTree.weakening Δ ΓΔ _ d_neg_neg (List.subset_append_right Γ Δ)
    have d_bot_final : DerivationTree ΓΔ Formula.bot :=
      derives_bot_from_phi_neg_phi d_neg' d_neg_neg'
    exact h_mcs.1.2 ΓΔ h_ΓΔ_in_S ⟨d_bot_final⟩

/--
Double negation elimination for DeferralRestrictedMCS: if neg(neg psi) is in M
and psi is in deferralClosure phi, then psi is in M.

This follows from maximality within deferralClosure: if psi were not in M,
then inserting psi would be inconsistent. But neg(neg psi) derives psi,
leading to a contradiction with consistency of M.
-/
theorem deferral_restricted_mcs_double_neg_elim {phi : Formula} {M : Set Formula}
    (h_mcs : DeferralRestrictedMCS phi M) (psi : Formula)
    (h_neg_neg : Formula.neg (Formula.neg psi) ∈ M)
    (h_psi_clos : psi ∈ deferralClosure phi) :
    psi ∈ M := by
  by_contra h_not_in
  -- By maximality, insert psi M is inconsistent
  have h_incons := h_mcs.2 psi h_psi_clos h_not_in
  unfold SetConsistent at h_incons
  push_neg at h_incons
  obtain ⟨L, h_L_sub, h_L_incons⟩ := h_incons
  -- L derives bot
  have h_bot : Nonempty (DerivationTree L Formula.bot) := inconsistent_derives_bot h_L_incons
  obtain ⟨d_bot⟩ := h_bot
  -- Extract Gamma = L \ {psi}, so Gamma ⊆ M
  let Γ := L.filter (· ≠ psi)
  have h_Γ_in_M : ∀ χ ∈ Γ, χ ∈ M := by
    intro χ hχ
    have hχ' := List.mem_filter.mp hχ
    have hχne : χ ≠ psi := by simpa using hχ'.2
    specialize h_L_sub χ hχ'.1
    simp [Set.mem_insert_iff] at h_L_sub
    rcases h_L_sub with rfl | h_in_M
    · exact absurd rfl hχne
    · exact h_in_M
  -- L ⊆ psi :: Gamma
  have h_L_sub_psiGamma : L ⊆ psi :: Γ := by
    intro χ hχ
    by_cases hχpsi : χ = psi
    · simp [hχpsi]
    · simp only [List.mem_cons]
      right
      exact List.mem_filter.mpr ⟨hχ, by simpa⟩
  -- Weaken: (psi :: Gamma) derives bot
  have d_bot' : DerivationTree (psi :: Γ) Formula.bot :=
    DerivationTree.weakening L (psi :: Γ) Formula.bot d_bot h_L_sub_psiGamma
  -- By deduction: Gamma derives neg psi
  have d_neg_psi : DerivationTree Γ (Formula.neg psi) :=
    deduction_theorem Γ psi Formula.bot d_bot'
  -- We have neg(neg psi) in M, so from DNE: {neg(neg psi)} derives psi
  have d_dne : [] ⊢ (Formula.neg (Formula.neg psi)).imp psi :=
    Bimodal.Theorems.Propositional.double_negation psi
  have d_dne_ctx : [Formula.neg (Formula.neg psi)] ⊢ (Formula.neg (Formula.neg psi)).imp psi :=
    DerivationTree.weakening [] [Formula.neg (Formula.neg psi)] _ d_dne (List.nil_subset _)
  have d_assumption : [Formula.neg (Formula.neg psi)] ⊢ Formula.neg (Formula.neg psi) :=
    DerivationTree.assumption [Formula.neg (Formula.neg psi)] (Formula.neg (Formula.neg psi))
      (List.mem_singleton.mpr rfl)
  have d_psi_from_neg_neg : DerivationTree [Formula.neg (Formula.neg psi)] psi :=
    DerivationTree.modus_ponens _ _ _ d_dne_ctx d_assumption
  -- Combine: (neg(neg psi) :: Gamma) derives psi and neg psi, hence bot
  let Δ := (Formula.neg (Formula.neg psi)) :: Γ
  have h_Δ_in_M : ∀ χ ∈ Δ, χ ∈ M := by
    intro χ hχ
    simp only [Δ, List.mem_cons] at hχ
    rcases hχ with rfl | hχΓ
    · exact h_neg_neg
    · exact h_Γ_in_M χ hχΓ
  have h_subset1 : [Formula.neg (Formula.neg psi)] ⊆ Δ := by
    intro x hx
    simp only [List.mem_singleton] at hx
    subst hx
    exact @List.mem_cons_self _ (Formula.neg (Formula.neg psi)) Γ
  have d_psi' : DerivationTree Δ psi :=
    DerivationTree.weakening [Formula.neg (Formula.neg psi)] Δ psi d_psi_from_neg_neg h_subset1
  have d_neg_psi' : DerivationTree Δ (Formula.neg psi) :=
    DerivationTree.weakening Γ Δ _ d_neg_psi (List.subset_cons_of_subset _ (List.Subset.refl _))
  have d_bot_final : DerivationTree Δ Formula.bot :=
    derives_bot_from_phi_neg_phi d_psi' d_neg_psi'
  -- Contradiction: Δ ⊆ M but Δ derives bot, contradicting consistency
  exact h_mcs.1.2 Δ h_Δ_in_M ⟨d_bot_final⟩


/--
P-step blocking formulas (restricted) are subset of u for DeferralRestrictedMCS.

This is the corrected version of `p_step_blocking_for_deferral_restricted` that uses
the restricted definition `p_step_blocking_formulas_restricted`, which only considers
formulas where `P(psi)` is in `deferralClosure`.

This is exactly the "Case 1" proof from the original attempt - the case where
`P(psi) ∈ deferralClosure`. The "Case 2" where `P(psi) ∉ deferralClosure`
is now excluded by the definition of `p_step_blocking_formulas_restricted`.

See research report 06_team-research.md for the counterexample showing why
the unrestricted version fails.
-/
theorem p_step_blocking_restricted_subset (phi : Formula) (u : Set Formula)
    (h_mcs : DeferralRestrictedMCS phi u) :
    Bimodal.Metalogic.Bundle.p_step_blocking_formulas_restricted phi u ⊆ u := by
  intro chi h_block
  rw [Bimodal.Metalogic.Bundle.mem_p_step_blocking_formulas_restricted_iff] at h_block
  obtain ⟨psi, h_P_in_dc, h_P_not_in, _, rfl⟩ := h_block
  -- Goal: H(neg psi) = Formula.all_past (Formula.neg psi) ∈ u
  -- This is the same proof as Case 1 in p_step_blocking_for_deferral_restricted,
  -- but now we don't need by_cases because h_P_in_dc is given by the restricted definition.

  -- P(psi) in deferralClosure => P(psi) in closureWithNeg
  have h_P_in_cwn := some_past_in_deferralClosure_is_in_closureWithNeg phi psi h_P_in_dc
  -- Extract: psi in subformulaClosure (from the inner structure)
  have h_psi_in_sub := some_past_in_closureWithNeg_inner_in_subformulaClosure phi psi h_P_in_cwn
  -- Get H(neg psi) in deferralClosure
  have h_H_in_dc : Formula.all_past (Formula.neg psi) ∈ deferralClosure phi := by
    unfold closureWithNeg at h_P_in_cwn
    simp only [Finset.mem_union, Finset.mem_image] at h_P_in_cwn
    rcases h_P_in_cwn with h_sub | ⟨g, h_g_sub, h_g_neg_eq⟩
    · -- P(psi) in subformulaClosure, so H(neg psi) = subformula of P(psi)
      apply closureWithNeg_subset_deferralClosure
      apply subformulaClosure_subset_closureWithNeg
      exact closure_imp_left phi _ _ h_sub
    · -- P(psi) = g.neg for g in subformulaClosure
      -- g.neg = P(psi) = neg(H(neg psi)) implies g = H(neg psi)
      unfold Formula.some_past Formula.neg at h_g_neg_eq
      have h_eq : g = Formula.all_past (Formula.neg psi) := by cases h_g_neg_eq; rfl
      rw [h_eq] at h_g_sub
      exact closureWithNeg_subset_deferralClosure phi
        (subformulaClosure_subset_closureWithNeg phi h_g_sub)
  -- Now use maximality: P(psi) not in u, P(psi) in deferralClosure => insert inconsistent
  have h_insert_incons := h_mcs.2 (Formula.some_past psi) h_P_in_dc h_P_not_in
  -- Extract: from inconsistency, Γ ⊆ u derives neg(P(psi))
  unfold SetConsistent at h_insert_incons
  push_neg at h_insert_incons
  obtain ⟨L, h_L_sub, h_L_incons⟩ := h_insert_incons
  obtain ⟨d_bot⟩ := inconsistent_derives_bot h_L_incons
  let Γ := L.filter (· ≠ Formula.some_past psi)
  have h_Γ_in_u : ∀ χ ∈ Γ, χ ∈ u := by
    intro χ hχ
    have hχ' := List.mem_filter.mp hχ
    have hχne : χ ≠ Formula.some_past psi := by simpa using hχ'.2
    specialize h_L_sub χ hχ'.1
    simp [Set.mem_insert_iff] at h_L_sub
    rcases h_L_sub with rfl | h_in
    · exact absurd rfl hχne
    · exact h_in
  have h_L_sub' : L ⊆ Formula.some_past psi :: Γ := by
    intro χ hχ
    by_cases hχp : χ = Formula.some_past psi
    · simp [hχp]
    · exact List.mem_cons_of_mem _ (List.mem_filter.mpr ⟨hχ, by simpa using hχp⟩)
  have d_bot' := DerivationTree.weakening L _ Formula.bot d_bot h_L_sub'
  have d_neg_P : Γ ⊢ Formula.neg (Formula.some_past psi) :=
    deduction_theorem Γ (Formula.some_past psi) Formula.bot d_bot'
  -- neg(P(psi)) = neg(neg(H(neg psi))) derivable from Γ ⊆ u
  -- We need: H(neg psi) in u, given that Γ ⊢ neg(neg(H(neg psi))) and H(neg psi) in deferralClosure
  by_contra h_H_not_in
  -- H(neg psi) not in u, but in deferralClosure => insert inconsistent
  have h_H_insert_incons := h_mcs.2 _ h_H_in_dc h_H_not_in
  unfold SetConsistent at h_H_insert_incons
  push_neg at h_H_insert_incons
  obtain ⟨L', h_L'_sub, h_L'_incons⟩ := h_H_insert_incons
  obtain ⟨d_bot''⟩ := inconsistent_derives_bot h_L'_incons
  let Δ := L'.filter (· ≠ Formula.all_past (Formula.neg psi))
  have h_Δ_in_u : ∀ χ ∈ Δ, χ ∈ u := by
    intro χ hχ
    have hχ' := List.mem_filter.mp hχ
    have hχne : χ ≠ Formula.all_past (Formula.neg psi) := by simpa using hχ'.2
    specialize h_L'_sub χ hχ'.1
    simp [Set.mem_insert_iff] at h_L'_sub
    rcases h_L'_sub with rfl | h_in
    · exact absurd rfl hχne
    · exact h_in
  have h_L'_sub' : L' ⊆ Formula.all_past (Formula.neg psi) :: Δ := by
    intro χ hχ
    by_cases hχH : χ = Formula.all_past (Formula.neg psi)
    · simp [hχH]
    · exact List.mem_cons_of_mem _ (List.mem_filter.mpr ⟨hχ, by simpa using hχH⟩)
  have d_bot''' := DerivationTree.weakening L' _ Formula.bot d_bot'' h_L'_sub'
  have d_neg_H : Δ ⊢ Formula.neg (Formula.all_past (Formula.neg psi)) :=
    deduction_theorem Δ _ Formula.bot d_bot'''
  -- Now we have: Γ ⊢ neg(neg(H(neg psi))) and Δ ⊢ neg(H(neg psi))
  -- Combine to get contradiction (since both Γ, Δ ⊆ u and u is consistent)
  have h_eq : Formula.neg (Formula.some_past psi) =
      Formula.neg (Formula.neg (Formula.all_past (Formula.neg psi))) := by
    unfold Formula.some_past Formula.neg; rfl
  rw [h_eq] at d_neg_P
  let ΓΔ := Γ ++ Δ
  have h_ΓΔ_in_u : ∀ χ ∈ ΓΔ, χ ∈ u := by
    intro χ hχ
    simp only [ΓΔ, List.mem_append] at hχ
    rcases hχ with hχΓ | hχΔ
    · exact h_Γ_in_u χ hχΓ
    · exact h_Δ_in_u χ hχΔ
  have d_neg_neg_H' : ΓΔ ⊢ Formula.neg (Formula.neg (Formula.all_past (Formula.neg psi))) :=
    DerivationTree.weakening Γ ΓΔ _ d_neg_P (List.subset_append_left Γ Δ)
  have d_neg_H' : ΓΔ ⊢ Formula.neg (Formula.all_past (Formula.neg psi)) :=
    DerivationTree.weakening Δ ΓΔ _ d_neg_H (List.subset_append_right Γ Δ)
  have d_bot_final := derives_bot_from_phi_neg_phi d_neg_H' d_neg_neg_H'
  exact h_mcs.1.2 ΓΔ h_ΓΔ_in_u ⟨d_bot_final⟩

/-!
## iter_F/P Boundedness in DeferralRestrictedMCS

These reuse the same bounds as for RestrictedMCS, since deferralClosure
has the same max F/P-depth as closureWithNeg (proven in SubformulaClosure.lean).
-/

/--
iter_F n phi is not in deferralClosure(phi) for large enough n.

Uses the fact that deferralClosure has the same max F-depth as closureWithNeg.
-/
theorem iter_F_not_mem_deferralClosure (phi : Formula) (n : Nat) (h : n ≥ closure_F_bound phi) :
    iter_F n phi ∉ (deferralClosure phi : Set Formula) := by
  intro h_mem
  have h_depth_bound : f_nesting_depth (iter_F n phi) ≤
      (deferralClosure phi).sup f_nesting_depth :=
    Finset.le_sup h_mem
  rw [max_F_depth_deferralClosure_eq] at h_depth_bound
  have h_exceeds := iter_F_exceeds_max_depth phi n h
  omega

/--
In any DeferralRestrictedMCS M over phi, there exists n such that iter_F n phi is not in M.
-/
theorem deferral_restricted_mcs_iter_F_bound (phi : Formula) (M : Set Formula)
    (h_mcs : DeferralRestrictedMCS phi M) :
    ∃ n : Nat, iter_F n phi ∉ M := by
  use closure_F_bound phi
  intro h_mem
  exact iter_F_not_mem_deferralClosure phi (closure_F_bound phi) (Nat.le_refl _)
    (deferral_restricted_mcs_is_restricted h_mcs h_mem)

/--
If F(phi) is in a DeferralRestrictedMCS M, then there exists d >= 1 such that:
- iter_F d phi is in M (the last F-iteration that's still in M)
- iter_F (d + 1) phi is not in M (the first F-iteration that left M)
-/
theorem deferral_restricted_mcs_F_bounded (phi psi : Formula) (M : Set Formula)
    (h_mcs : DeferralRestrictedMCS phi M)
    (h_F_in : Formula.some_future psi ∈ M) :
    ∃ d : Nat, d ≥ 1 ∧ iter_F d psi ∈ M ∧ iter_F (d + 1) psi ∉ M := by
  -- iter_F 1 psi = F(psi) ∈ M
  have h_one_in : iter_F 1 psi ∈ M := by
    simp only [iter_F_one_eq_some_future]
    exact h_F_in
  -- iter_F at the bound is not in M (since M ⊆ deferralClosure)
  -- But we need the bound for psi, not phi. Since F(psi) ∈ M ⊆ deferralClosure phi,
  -- iter_F n psi has f_nesting_depth = n + f_nesting_depth(psi).
  -- For psi: we need n such that iter_F n psi ∉ M.
  -- Since M ⊆ deferralClosure phi, it suffices that iter_F n psi ∉ deferralClosure phi.
  -- f_nesting_depth(iter_F n psi) = n + f_nesting_depth(psi)
  -- This exceeds max_F_depth_in_closure phi when n > max_F_depth_in_closure phi - f_nesting_depth(psi)
  -- So closure_F_bound phi = max_F_depth_in_closure phi + 1 works.
  let exit_bound := closure_F_bound phi
  have h_exit_bound_not : iter_F exit_bound psi ∉ M := by
    intro h_mem
    have h_in_dc := deferral_restricted_mcs_is_restricted h_mcs h_mem
    have h_depth_bound : f_nesting_depth (iter_F exit_bound psi) ≤
        (deferralClosure phi).sup f_nesting_depth :=
      Finset.le_sup h_in_dc
    rw [max_F_depth_deferralClosure_eq] at h_depth_bound
    rw [iter_F_f_nesting_depth] at h_depth_bound
    unfold exit_bound closure_F_bound at h_depth_bound
    omega
  have h_exit_ge1 : exit_bound ≥ 1 := by
    unfold exit_bound closure_F_bound
    omega
  have h_exit_ge2 : exit_bound ≥ 2 := by
    by_contra h
    push_neg at h
    have h_eq : exit_bound = 1 := by omega
    rw [h_eq] at h_exit_bound_not
    exact h_exit_bound_not h_one_in
  let S : Set Nat := { n | n ≥ 2 ∧ iter_F n psi ∉ M }
  have h_S_nonempty : S.Nonempty := ⟨exit_bound, h_exit_ge2, h_exit_bound_not⟩
  have h_wf : WellFounded (· < · : Nat → Nat → Prop) := Nat.lt_wfRel.wf
  obtain ⟨min_n, h_min_mem, h_min_least⟩ := WellFounded.has_min h_wf S h_S_nonempty
  obtain ⟨h_min_ge2, h_min_not⟩ := h_min_mem
  use min_n - 1
  constructor
  · omega
  constructor
  · by_contra h_not_in
    have h_pred_lt : min_n - 1 < min_n := by omega
    by_cases h_pred_ge2 : min_n - 1 ≥ 2
    · exact h_min_least (min_n - 1) ⟨h_pred_ge2, h_not_in⟩ h_pred_lt
    · have h_pred_eq1 : min_n - 1 = 1 := by omega
      rw [h_pred_eq1] at h_not_in
      exact h_not_in h_one_in
  · have h_eq : min_n - 1 + 1 = min_n := by omega
    rw [h_eq]
    exact h_min_not

/--
iter_P n phi is not in deferralClosure(phi) for large enough n.

Uses the fact that deferralClosure has the same max P-depth as closureWithNeg.
-/
theorem iter_P_not_mem_deferralClosure (phi : Formula) (n : Nat) (h : n ≥ closure_P_bound phi) :
    iter_P n phi ∉ (deferralClosure phi : Set Formula) := by
  intro h_mem
  have h_depth_bound : p_nesting_depth (iter_P n phi) ≤
      (deferralClosure phi).sup p_nesting_depth :=
    Finset.le_sup h_mem
  rw [max_P_depth_deferralClosure_eq] at h_depth_bound
  have h_exceeds := iter_P_exceeds_max_depth phi n h
  omega

/--
If P(phi) is in a DeferralRestrictedMCS M, then there exists d >= 1 such that:
- iter_P d phi is in M (the last P-iteration that's still in M)
- iter_P (d + 1) phi is not in M (the first P-iteration that left M)

Symmetric to deferral_restricted_mcs_F_bounded.
-/
theorem deferral_restricted_mcs_P_bounded (phi psi : Formula) (M : Set Formula)
    (h_mcs : DeferralRestrictedMCS phi M)
    (h_P_in : Formula.some_past psi ∈ M) :
    ∃ d : Nat, d ≥ 1 ∧ iter_P d psi ∈ M ∧ iter_P (d + 1) psi ∉ M := by
  have h_one_in : iter_P 1 psi ∈ M := by
    simp only [iter_P_one_eq_some_past]
    exact h_P_in
  let exit_bound := closure_P_bound phi
  have h_exit_bound_not : iter_P exit_bound psi ∉ M := by
    intro h_mem
    have h_in_dc := deferral_restricted_mcs_is_restricted h_mcs h_mem
    have h_depth_bound : p_nesting_depth (iter_P exit_bound psi) ≤
        (deferralClosure phi).sup p_nesting_depth :=
      Finset.le_sup h_in_dc
    rw [max_P_depth_deferralClosure_eq] at h_depth_bound
    rw [iter_P_p_nesting_depth] at h_depth_bound
    unfold exit_bound closure_P_bound at h_depth_bound
    omega
  have h_exit_ge1 : exit_bound ≥ 1 := by
    unfold exit_bound closure_P_bound
    omega
  have h_exit_ge2 : exit_bound ≥ 2 := by
    by_contra h
    push_neg at h
    have h_eq : exit_bound = 1 := by omega
    rw [h_eq] at h_exit_bound_not
    exact h_exit_bound_not h_one_in
  let S : Set Nat := { n | n ≥ 2 ∧ iter_P n psi ∉ M }
  have h_S_nonempty : S.Nonempty := ⟨exit_bound, h_exit_ge2, h_exit_bound_not⟩
  have h_wf : WellFounded (· < · : Nat → Nat → Prop) := Nat.lt_wfRel.wf
  obtain ⟨min_n, h_min_mem, h_min_least⟩ := WellFounded.has_min h_wf S h_S_nonempty
  obtain ⟨h_min_ge2, h_min_not⟩ := h_min_mem
  use min_n - 1
  constructor
  · omega
  constructor
  · by_contra h_not_in
    have h_pred_lt : min_n - 1 < min_n := by omega
    by_cases h_pred_ge2 : min_n - 1 ≥ 2
    · exact h_min_least (min_n - 1) ⟨h_pred_ge2, h_not_in⟩ h_pred_lt
    · have h_pred_eq1 : min_n - 1 = 1 := by omega
      rw [h_pred_eq1] at h_not_in
      exact h_not_in h_one_in
  · have h_eq : min_n - 1 + 1 = min_n := by omega
    rw [h_eq]
    exact h_min_not

/-!
## DeferralRestrictedMCS Closure Under Derivation

These lemmas establish that DeferralRestrictedMCS is closed under derivation
for formulas within deferralClosure. This enables proving modal duality lemmas
like `neg_FF_implies_GG_neg` for restricted MCS.
-/

/--
DeferralRestrictedMCS is closed under derivation for formulas in deferralClosure.

If L ⊆ M, L ⊢ φ, and φ ∈ deferralClosure, then φ ∈ M.

This is the DRM version of `SetMaximalConsistent.closed_under_derivation`.
The key insight is that DRM maximality within deferralClosure is sufficient:
if φ ∈ deferralClosure and φ ∉ M, then insert φ M is inconsistent,
which contradicts L ⊢ φ when L ⊆ M.
-/
theorem drm_closed_under_derivation {phi : Formula} {M : Set Formula}
    (h_mcs : DeferralRestrictedMCS phi M) {ψ : Formula}
    (L : List Formula) (h_sub : ∀ χ ∈ L, χ ∈ M)
    (h_deriv : DerivationTree L ψ)
    (h_ψ_dc : ψ ∈ deferralClosure phi) : ψ ∈ M := by
  by_contra h_not_mem
  -- By DRM maximality, insert ψ M is inconsistent
  have h_incons : ¬SetConsistent (insert ψ M) := h_mcs.2 ψ h_ψ_dc h_not_mem
  unfold SetConsistent at h_incons
  push_neg at h_incons
  obtain ⟨L', h_L'_sub, h_L'_incons⟩ := h_incons
  -- L' ⊆ insert ψ M and L' is inconsistent
  by_cases h_psi_in_L' : ψ ∈ L'
  · -- ψ ∈ L'. Use exchange to put ψ first, then deduction theorem.
    have ⟨d_bot⟩ : Nonempty (DerivationTree L' Formula.bot) := by
      unfold Consistent at h_L'_incons
      push_neg at h_L'_incons
      exact h_L'_incons
    let L'_filt := L'.filter (fun y => decide (y ≠ ψ))
    have h_perm := cons_filter_neq_perm h_psi_in_L'
    have d_bot_reord : DerivationTree (ψ :: L'_filt) Formula.bot :=
      derivation_exchange d_bot (fun x => (h_perm x).symm)
    have d_neg_psi : DerivationTree L'_filt (Formula.neg ψ) :=
      deduction_theorem L'_filt ψ Formula.bot d_bot_reord
    -- L'_filt ⊆ M
    have h_filt_sub : ∀ χ ∈ L'_filt, χ ∈ M := by
      intro χ hχ
      have hχ' := List.mem_filter.mp hχ
      have hχne : χ ≠ ψ := by simpa using hχ'.2
      have := h_L'_sub χ hχ'.1
      cases Set.mem_insert_iff.mp this with
      | inl h_eq => exact absurd h_eq hχne
      | inr h_in_M => exact h_in_M
    -- Combine: L ∪ L'_filt derives ψ and ¬ψ, hence ⊥
    let LL' := L ++ L'_filt
    have h_LL'_sub : ∀ χ ∈ LL', χ ∈ M := by
      intro χ hχ
      simp only [LL', List.mem_append] at hχ
      cases hχ with
      | inl hL => exact h_sub χ hL
      | inr hL' => exact h_filt_sub χ hL'
    have d_psi' : DerivationTree LL' ψ :=
      DerivationTree.weakening L LL' ψ h_deriv (List.subset_append_left L L'_filt)
    have d_neg_psi' : DerivationTree LL' (Formula.neg ψ) :=
      DerivationTree.weakening L'_filt LL' _ d_neg_psi (List.subset_append_right L L'_filt)
    have d_bot_final : DerivationTree LL' Formula.bot :=
      derives_bot_from_phi_neg_phi d_psi' d_neg_psi'
    exact h_mcs.1.2 LL' h_LL'_sub ⟨d_bot_final⟩
  · -- ψ ∉ L', so L' ⊆ M
    have h_L'_in_M : ∀ χ ∈ L', χ ∈ M := by
      intro χ h_mem
      have := h_L'_sub χ h_mem
      cases Set.mem_insert_iff.mp this with
      | inl h_eq => exact absurd h_eq (fun h' => h_psi_in_L' (h' ▸ h_mem))
      | inr h_in_M => exact h_in_M
    -- L' ⊆ M and L' is inconsistent contradicts M consistent
    unfold Consistent at h_L'_incons
    push_neg at h_L'_incons
    exact h_mcs.1.2 L' h_L'_in_M h_L'_incons

/--
DeferralRestrictedMCS implication property: modus ponens is reflected in membership
when the conclusion is in deferralClosure.

If (φ → ψ) ∈ M and φ ∈ M and ψ ∈ deferralClosure, then ψ ∈ M.
-/
theorem drm_implication_property {phi : Formula} {M : Set Formula}
    (h_mcs : DeferralRestrictedMCS phi M) {ψ χ : Formula}
    (h_imp : (ψ.imp χ) ∈ M) (h_psi : ψ ∈ M)
    (h_χ_dc : χ ∈ deferralClosure phi) : χ ∈ M := by
  have h_sub : ∀ ξ ∈ [ψ, ψ.imp χ], ξ ∈ M := by
    intro ξ h_mem
    simp only [List.mem_cons, List.mem_nil_iff, or_false] at h_mem
    cases h_mem with
    | inl h_eq => exact h_eq ▸ h_psi
    | inr h_eq => exact h_eq ▸ h_imp
  have h_deriv : DerivationTree [ψ, ψ.imp χ] χ := by
    have h_assume_psi : [ψ, ψ.imp χ] ⊢ ψ :=
      DerivationTree.assumption [ψ, ψ.imp χ] ψ (by simp)
    have h_assume_imp : [ψ, ψ.imp χ] ⊢ ψ.imp χ :=
      DerivationTree.assumption [ψ, ψ.imp χ] (ψ.imp χ) (by simp)
    exact DerivationTree.modus_ponens [ψ, ψ.imp χ] ψ χ h_assume_imp h_assume_psi
  exact drm_closed_under_derivation h_mcs [ψ, ψ.imp χ] h_sub h_deriv h_χ_dc

/--
Theorems that are in deferralClosure are in any DeferralRestrictedMCS.

This is the DRM version of `theorem_in_mcs`. If ⊢ ψ and ψ ∈ deferralClosure, then ψ ∈ M.
-/
theorem theorem_in_drm {phi : Formula} {M : Set Formula}
    (h_mcs : DeferralRestrictedMCS phi M) {ψ : Formula}
    (h_thm : [] ⊢ ψ)
    (h_ψ_dc : ψ ∈ deferralClosure phi) : ψ ∈ M := by
  have h_sub : ∀ χ ∈ ([] : List Formula), χ ∈ M := by
    intro χ h
    simp only [List.mem_nil_iff] at h
  exact drm_closed_under_derivation h_mcs [] h_sub h_thm h_ψ_dc

/--
neg(FF(phi)) in DeferralRestrictedMCS implies GG(neg(phi)) in DeferralRestrictedMCS,
provided all intermediate formulas are in deferralClosure.

This is the DRM version of `neg_FF_implies_GG_neg_in_mcs`. The key insight is that
the derivation only uses DNE and modal K distribution, which are provable in the
proof system. When all intermediate formulas are in deferralClosure, the DRM's
closure under derivation applies.

**Formula Structure**:
- neg(FF(psi)) has structure: `psi.neg.all_future.neg.neg.all_future.neg.neg`
- We want: `psi.neg.all_future.all_future` = GG(neg psi)

**Intermediate formulas** (must be in deferralClosure for this to work):
- `psi.neg.all_future.neg.neg.all_future` = G(G(neg psi).neg.neg)
- `psi.neg.all_future.all_future` = GG(neg psi)
-/
theorem neg_FF_implies_GG_neg_in_drm {phi : Formula} {M : Set Formula}
    (h_mcs : DeferralRestrictedMCS phi M) (psi : Formula)
    (h_neg_FF : (Formula.some_future (Formula.some_future psi)).neg ∈ M)
    (h_intermediate_dc : (psi.neg.all_future.neg).neg.all_future ∈ deferralClosure phi)
    (h_GG_dc : psi.neg.all_future.all_future ∈ deferralClosure phi) :
    Formula.all_future (Formula.all_future psi.neg) ∈ M := by
  -- Step A: Apply DNE to get G(G(neg(psi)).neg.neg) ∈ M
  -- Directly derive: [neg(FF(psi))] ⊢ G(G(neg(psi)).neg.neg)
  have h_inner : (psi.neg.all_future.neg).neg.all_future ∈ M := by
    -- Build derivation: [h_neg_FF_formula] ⊢ h_intermediate_formula
    let premise := (psi.neg.all_future.neg).neg.all_future.neg.neg
    let conclusion := (psi.neg.all_future.neg).neg.all_future
    have h_dne : [] ⊢ premise.imp conclusion :=
      Bimodal.Theorems.Propositional.double_negation conclusion
    -- Weaken to context with premise
    have h_dne' : [premise] ⊢ premise.imp conclusion :=
      DerivationTree.weakening [] [premise] _ h_dne (List.nil_subset _)
    have h_assume : [premise] ⊢ premise :=
      DerivationTree.assumption [premise] premise (List.mem_singleton.mpr rfl)
    have h_deriv : [premise] ⊢ conclusion :=
      DerivationTree.modus_ponens [premise] premise conclusion h_dne' h_assume
    -- h_neg_FF has exactly the type of premise
    have h_sub : ∀ χ ∈ [premise], χ ∈ M := by
      intro χ hχ
      simp only [List.mem_singleton] at hχ
      exact hχ ▸ h_neg_FF
    exact drm_closed_under_derivation h_mcs [premise] h_sub h_deriv h_intermediate_dc

  -- Step B: Apply G(DNE) to get GG(neg(psi)) ∈ M
  -- Derive: [G(G(neg psi).neg.neg)] ⊢ GG(neg psi)
  have h_G_dne : [] ⊢ (psi.neg.all_future.neg).neg.all_future.imp (psi.neg.all_future.all_future) := by
    have h_dne_inner : [] ⊢ (psi.neg.all_future).neg.neg.imp (psi.neg.all_future) :=
      Bimodal.Theorems.Propositional.double_negation _
    have h_nec : [] ⊢ ((psi.neg.all_future).neg.neg.imp (psi.neg.all_future)).all_future :=
      Bimodal.ProofSystem.DerivationTree.temporal_necessitation _ h_dne_inner
    have h_k : [] ⊢ ((psi.neg.all_future).neg.neg.imp (psi.neg.all_future)).all_future.imp
                    ((psi.neg.all_future).neg.neg.all_future.imp (psi.neg.all_future).all_future) :=
      Bimodal.ProofSystem.DerivationTree.axiom [] _ (Bimodal.ProofSystem.Axiom.temp_k_dist _ _)
    exact Bimodal.ProofSystem.DerivationTree.modus_ponens [] _ _ h_k h_nec

  let premise2 := (psi.neg.all_future.neg).neg.all_future
  let conclusion2 := psi.neg.all_future.all_future
  have h_deriv2 : [premise2] ⊢ conclusion2 := by
    have h_imp' : [premise2] ⊢ premise2.imp conclusion2 :=
      DerivationTree.weakening [] [premise2] _ h_G_dne (List.nil_subset _)
    have h_assume2 : [premise2] ⊢ premise2 :=
      DerivationTree.assumption [premise2] premise2 (List.mem_singleton.mpr rfl)
    exact DerivationTree.modus_ponens [premise2] premise2 conclusion2 h_imp' h_assume2
  have h_sub2 : ∀ χ ∈ [premise2], χ ∈ M := by
    intro χ hχ
    simp only [List.mem_singleton] at hχ
    exact hχ ▸ h_inner
  exact drm_closed_under_derivation h_mcs [premise2] h_sub2 h_deriv2 h_GG_dc

/--
G(neg phi) in DeferralRestrictedMCS implies F(phi) not in DeferralRestrictedMCS.

This is the DRM version of `G_neg_implies_not_F`. The proof only uses consistency,
which DRM satisfies.
-/
theorem drm_G_neg_implies_not_F {phi : Formula} {M : Set Formula}
    (h_mcs : DeferralRestrictedMCS phi M) (psi : Formula)
    (h_G_neg : Formula.all_future psi.neg ∈ M) :
    Formula.some_future psi ∉ M := by
  intro h_F
  have h_eq : Formula.some_future psi = (Formula.all_future psi.neg).neg := rfl
  rw [h_eq] at h_F
  exact set_consistent_not_both h_mcs.1.2 (Formula.all_future psi.neg) h_G_neg h_F

end Bimodal.Metalogic.Core
