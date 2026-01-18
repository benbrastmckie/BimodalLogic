import Bimodal.Metalogic_v2.Representation.CanonicalModel
import Bimodal.Metalogic_v2.Representation.TruthLemma
import Bimodal.Metalogic_v2.Representation.ContextProvability

namespace Bimodal.Metalogic_v2.Representation

open Bimodal.Syntax Bimodal.ProofSystem Bimodal.Semantics
open Bimodal.Metalogic_v2.Core

/-!
# Representation Theorem for TM Bimodal Logic (Metalogic_v2)

This module provides the representation theorem, which establishes that every
consistent context is satisfiable in the canonical model. This is the key
link between syntactic consistency and semantic satisfiability.

## Overview

This is part of the Metalogic_v2 reorganization that establishes a
representation-first architecture with the Finite Model Property (FMP)
as the central bridge theorem.

## Main Results

- `representation_theorem`: Every consistent context is satisfiable in a canonical world
- `strong_representation_theorem`: If Γ ⊬ ¬φ, then Γ ∪ {φ} is satisfiable
- `completeness_corollary`: Every valid formula is derivable

## Layer Dependencies

Representation.RepresentationTheorem depends on:
- Bimodal.Metalogic_v2.Representation.CanonicalModel
- Bimodal.Metalogic_v2.Representation.TruthLemma
- Bimodal.Metalogic_v2.Core.* (via transitive imports)
-/

variable {Γ : Context}

/--
Helper: Convert a list-based context to a set of formulas.

Note: This is also defined in Core.MaximalConsistent, but we provide
a local version for module independence.
-/
def contextToSetLocal (Γ : Context) : Set Formula := {φ | φ ∈ Γ}

/--
If a list context is consistent, its corresponding set is set-consistent.
-/
lemma consistent_implies_set_consistent_local (h : Consistent Γ) :
    SetConsistent (contextToSetLocal Γ) := by
  intro L hL
  -- Need to show any finite subset of contextToSet Γ is consistent
  -- Since L contains only elements from Γ (a context), this follows by weakening
  intro ⟨d⟩
  apply h
  exact ⟨DerivationTree.weakening L Γ Formula.bot d (fun φ hφ => hL φ hφ)⟩

/--
Representation Theorem: Every consistent context is satisfiable in the canonical model.

This is the central theorem of the representation theory. It establishes that
syntactic consistency implies semantic satisfiability via the canonical model
construction.

Given a consistent context Γ, we extend it to a maximal consistent set M using
Lindenbaum's lemma. Then M, viewed as a canonical world state, satisfies all
formulas in Γ.
-/
theorem representation_theorem :
    Consistent Γ → ∃ (w : CanonicalWorldState), ∀ φ ∈ Γ, canonicalTruthAt w φ := by
  intro h_cons
  -- Convert context to set and show it's set-consistent
  let S := contextToSetLocal Γ
  have h_set_cons : SetConsistent S := consistent_implies_set_consistent_local h_cons
  -- Use Lindenbaum's lemma to extend S to a maximal consistent set
  obtain ⟨M, hSM, h_mcs⟩ := set_lindenbaum S h_set_cons
  -- M is a maximal consistent set, so it's a canonical world
  let w : CanonicalWorldState := ⟨M, h_mcs⟩
  use w
  -- Every formula in Γ is in S, so in M, so in w.carrier
  intro φ h_in
  unfold canonicalTruthAt CanonicalWorldState.carrier
  -- Show φ ∈ M by transitivity: φ ∈ Γ → φ ∈ S → φ ∈ M
  apply hSM
  -- Show φ ∈ S (= contextToSet Γ)
  exact h_in

/--
Strong Representation Theorem: For any context Γ and formula φ,
if Γ does not prove ¬φ, then Γ and φ are jointly satisfiable.

This is equivalent to: If Γ ⊬ ¬φ, then there exists a world in the canonical
model where both Γ is true and φ is also true.
-/
theorem strong_representation_theorem {φ : Formula} :
    ¬ContextDerivable Γ (Formula.neg φ) →
    ∃ (w : CanonicalWorldState), (∀ ψ ∈ Γ, canonicalTruthAt w ψ) ∧ (canonicalTruthAt w φ) := by
  intro h_not_derivable
  -- Show Γ ∪ {φ} is consistent
  have h_cons : Consistent (Γ ++ [φ]) := by
    -- If we could derive ⊥ from Γ ∪ {φ}, then by deduction theorem, Γ ⊢ φ → ⊥ = ¬φ
    -- But we assumed Γ ⊬ ¬φ, contradiction
    intro ⟨d_bot⟩
    apply h_not_derivable
    -- Use deduction theorem: (φ :: Γ) ⊢ ⊥ implies Γ ⊢ ¬φ
    -- Note: Γ ++ [φ] and φ :: Γ have the same elements
    have h_perm : ∀ ψ ∈ (φ :: Γ), ψ ∈ (Γ ++ [φ]) := by
      intro ψ h_mem
      cases List.mem_cons.mp h_mem with
      | inl h => simp [h]
      | inr h => simp [h]
    have h_perm' : ∀ ψ ∈ (Γ ++ [φ]), ψ ∈ (φ :: Γ) := by
      intro ψ h_mem
      cases List.mem_append.mp h_mem with
      | inl h => exact List.mem_cons_of_mem _ h
      | inr h => simp at h; simp [h]
    -- Weaken from Γ ++ [φ] to φ :: Γ
    have d_bot' : DerivationTree (φ :: Γ) Formula.bot :=
      DerivationTree.weakening (Γ ++ [φ]) (φ :: Γ) Formula.bot d_bot h_perm'
    -- Apply deduction theorem
    have d_neg : DerivationTree Γ (Formula.neg φ) := deduction_theorem Γ φ Formula.bot d_bot'
    exact ⟨d_neg⟩
  -- Apply representation theorem to Γ ∪ {φ}
  obtain ⟨w, h_truth⟩ := representation_theorem h_cons
  exact ⟨w,
    fun ψ h_in => h_truth ψ (List.mem_append.2 (Or.inl h_in)),
    h_truth φ (List.mem_append.2 (Or.inr (List.mem_singleton_self _)))⟩

/--
Corollary: Every valid formula is derivable.

This is the completeness direction specialized to the empty context.
It follows directly from `valid_implies_derivable` in ContextProvability.
-/
theorem completeness_corollary {φ : Formula} :
    valid φ → ContextDerivable [] φ :=
  valid_implies_derivable

/--
Satisfiability for canonical model.

A formula is satisfiable if it is true at some canonical world.
-/
def canonicalSatisfiable (φ : Formula) : Prop :=
  ∃ w : CanonicalWorldState, canonicalTruthAt w φ

/--
Context satisfiability for canonical model.

A context is satisfiable if all its formulas are true at some canonical world.
-/
def canonicalContextSatisfiable (Γ : Context) : Prop :=
  ∃ w : CanonicalWorldState, ∀ φ ∈ Γ, canonicalTruthAt w φ

/--
Representation theorem restated in terms of canonical satisfiability.
-/
theorem representation_satisfiability :
    Consistent Γ ↔ canonicalContextSatisfiable Γ := by
  constructor
  · exact representation_theorem
  · intro ⟨w, h_sat⟩
    -- If Γ is satisfiable in canonical model, it's consistent
    -- This follows from the canonical world being a MCS
    intro ⟨d_bot⟩
    -- h_sat says all formulas in Γ are in w.carrier
    -- d_bot is a derivation of ⊥ from Γ
    -- But w.carrier is consistent and contains Γ (via h_sat)
    have h_cons := w.is_consistent
    unfold SetConsistent at h_cons
    have h_all_in : ∀ ψ ∈ Γ, ψ ∈ w.carrier := fun ψ h => h_sat ψ h
    -- Use weakening to show Γ ⊢ ⊥ implies w.carrier ⊢ ⊥
    -- But w.carrier is consistent, contradiction
    apply h_cons Γ h_all_in
    exact ⟨d_bot⟩

/--
MCS membership property for representation.

If Γ is consistent and φ ∈ Γ, then in any MCS extension, φ is true.
-/
theorem mcs_extension_truth {φ : Formula} (h_cons : Consistent Γ) (h_in : φ ∈ Γ) :
    ∃ w : CanonicalWorldState, canonicalTruthAt w φ := by
  obtain ⟨w, h_sat⟩ := representation_theorem h_cons
  exact ⟨w, h_sat φ h_in⟩

end Bimodal.Metalogic_v2.Representation
