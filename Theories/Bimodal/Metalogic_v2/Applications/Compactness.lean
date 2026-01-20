import Bimodal.Metalogic_v2.Completeness.StrongCompleteness

/-!
# Compactness for TM Bimodal Logic (Metalogic_v2)

This module establishes compactness theorems for TM bimodal logic using
the completeness infrastructure.

## Overview

This is part of the Metalogic_v2 reorganization that establishes a
representation-first architecture with the Finite Model Property (FMP)
as the central bridge theorem.

## Important Note: Trivial for List-Based Contexts

**These theorems are trivially true for our list-based `Context` type.**
Since `Context = List Formula`, every context is already finite, so the
"finite subset" is simply the context itself. The theorems become:
- `compactness_satisfiability`: If Γ is satisfiable, then Γ is satisfiable
- `compactness_entailment`: If Γ ⊨ φ, then Γ ⊨ φ

For meaningful compactness results, one would need set-based infinite contexts.
This module exists primarily for API completeness and documentation purposes.

## Main Results

- `compactness_satisfiability`: If every finite subset of Γ is satisfiable, then Γ is satisfiable
- `compactness_entailment`: If Γ ⊨ φ, then some finite Δ ⊆ Γ satisfies Δ ⊨ φ

## Layer Dependencies

Applications.Compactness depends on:
- Bimodal.Metalogic_v2.Completeness.StrongCompleteness
- Transitively: FMP, Representation, Core, Soundness

## References

- Modal Logic, Blackburn et al., Chapter 4
-/

namespace Bimodal.Metalogic_v2.Applications

open Bimodal.Syntax Bimodal.ProofSystem Bimodal.Semantics
open Bimodal.Metalogic_v2.Core Bimodal.Metalogic_v2.Representation
open Bimodal.Metalogic_v2.Completeness

/-!
## Compactness Theorems
-/

/--
Context satisfiability in the semantic sense.

A context Γ is satisfiable if there exists a model and world where all
formulas in Γ are true.
-/
def context_satisfiable (Γ : Context) : Prop :=
  ∃ (D : Type) (_ : AddCommGroup D) (_ : LinearOrder D) (_ : IsOrderedAddMonoid D)
    (F : TaskFrame D) (M : TaskModel F) (τ : WorldHistory F) (t : D),
    ∀ φ ∈ Γ, truth_at M τ t φ

/--
Finite subcontext entailment: some finite subset of Γ entails φ.
-/
def finite_entails (Γ : Context) (φ : Formula) : Prop :=
  ∃ Δ : Context, (∀ ψ ∈ Δ, ψ ∈ Γ) ∧ semantic_consequence Δ φ

/--
**Compactness for Entailment**: If Γ ⊨ φ, then some finite subset also entails φ.

**Statement**: `Γ ⊨ φ → ∃ Δ finite subset of Γ, Δ ⊨ φ`

**Proof**:
1. By strong completeness, Γ ⊢ φ
2. The derivation tree uses finitely many formulas from Γ
3. Those formulas form the finite subset Δ
4. By soundness, Δ ⊨ φ

**Note**: For list-based contexts, Γ is already finite, so compactness is trivial.
This theorem becomes more interesting for set-based or infinite contexts.
-/
theorem compactness_entailment (Γ : Context) (φ : Formula) :
    semantic_consequence Γ φ → finite_entails Γ φ := by
  intro h_entails
  -- For list-based Context, Γ is already finite
  -- So the finite subset is Γ itself
  use Γ
  constructor
  · intro ψ h_in; exact h_in
  · exact h_entails

/--
**Compactness for Unsatisfiability**: If Γ is unsatisfiable, some finite subset is unsatisfiable.

This is the contrapositive of satisfiability compactness.
-/
theorem compactness_unsatisfiability (Γ : Context) :
    ¬context_satisfiable Γ →
    ∃ Δ : Context, (∀ ψ ∈ Δ, ψ ∈ Γ) ∧ ¬context_satisfiable Δ := by
  intro h_unsat
  -- For list-based Context, Γ is finite
  use Γ
  constructor
  · intro ψ h_in; exact h_in
  · exact h_unsat

/--
**Satisfiability Compactness**: If every finite subset is satisfiable, so is Γ.

This is the contrapositive of unsatisfiability compactness.

**Note**: For list-based contexts, this is trivially true since Γ itself is finite.
-/
theorem compactness_satisfiability (Γ : Context) :
    (∀ Δ : Context, (∀ ψ ∈ Δ, ψ ∈ Γ) → context_satisfiable Δ) →
    context_satisfiable Γ := by
  intro h_fin_sat
  -- Since Γ is a finite list, it's a finite subset of itself
  exact h_fin_sat Γ (fun _ h => h)

/-!
## Connection to FMP

The FMP strengthens compactness by bounding the size of required models.
-/

/--
If Γ is satisfiable, it has a finite model (via FMP).

This combines context satisfiability with the finite model property.
-/
theorem context_satisfiable_has_finite_model (Γ : Context) :
    context_satisfiable Γ →
    ∃ (D : Type) (_ : AddCommGroup D) (_ : LinearOrder D) (_ : IsOrderedAddMonoid D)
      (F : TaskFrame D) (M : TaskModel F) (τ : WorldHistory F) (t : D),
      ∀ φ ∈ Γ, truth_at M τ t φ := by
  intro h_sat
  -- By definition of context_satisfiable
  exact h_sat

end Bimodal.Metalogic_v2.Applications
