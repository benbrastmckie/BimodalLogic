/-!
# ARCHIVED - Compactness Theorem

**Archived**: 2026-01-30 (Task 772)
**Original Location**: `Metalogic/Compactness/Compactness.lean`
**Sorry Count**: 0 (this file is sorry-free, but depends on sorried infinitary completeness)
**Reason**: Depends on InfinitaryStrongCompleteness.lean which uses sorried representation theorem

## Why This File Was Archived

The compactness theorem relies on `infinitary_strong_completeness` which states that
for infinite premise sets, semantic consequence has a finite derivation witness. This
theorem in turn depends on the representation theorem infrastructure:

1. **construct_coherent_family** (CoherentConstruction.lean): 8 sorries
2. **truth_lemma** (TruthLemma.lean): 4 sorries

The proof strategy uses:
1. If all finite subsets of Gamma are satisfiable but Gamma is not
2. Then Gamma |= bot (semantic consequence)
3. By infinitary_strong_completeness, some finite Delta ⊆ Gamma derives bot
4. By soundness, Delta |= bot, so Delta is unsatisfiable
5. Contradiction

The key step (3) requires the sorried infinitary strong completeness.

## Key Theorems (Archived)

- `compactness_entailment`: Semantic consequence has finite witness
- `compactness_unsatisfiability`: Unsatisfiability has finite witness
- `compactness`: Main compactness theorem for infinite sets
- `compactness_iff`: Bidirectional equivalence

## What Remains Available

- **Finite compactness** (`compactness_finset`): For finite sets, compactness is trivial
- **Weak completeness**: The core completeness theorem is still available via
  `semantic_weak_completeness` in FMP/SemanticCanonicalModel.lean

## References

- Task 750: Truth bridge analysis confirming architectural limitations
- Task 769: Deprecation of sorried code with DEPRECATED markers
- Task 772: This archival

---
ORIGINAL FILE BELOW
---
-/

import Bimodal.Metalogic.Completeness.InfinitaryStrongCompleteness
import Mathlib.Data.Finset.Basic

/-!
# Compactness Theorem for TM Bimodal Logic

This module proves the compactness theorem for TM bimodal logic:
a set of formulas is satisfiable iff every finite subset is satisfiable.

## Overview

Compactness is a fundamental property that bridges finite and infinite semantics.
For TM logic, we prove:

`(∀ Δ : Finset Formula, ↑Δ ⊆ Γ → set_satisfiable ↑Δ) → set_satisfiable Γ`

## Proof Strategy

The proof uses contraposition:
1. Assume every finite subset of Γ is satisfiable
2. Suppose (for contradiction) Γ is not satisfiable
3. Then Γ |= ⊥ (false is a semantic consequence of Γ)
4. By infinitary strong completeness: some finite Δ ⊆ Γ derives ⊥
5. By soundness: Δ is unsatisfiable
6. Contradiction with assumption

## Main Results

- `compactness_entailment`: Semantic consequence has finite witness
- `compactness_unsatisfiability`: Unsatisfiability has finite witness
- `compactness`: Main compactness theorem
- `compactness_iff`: Bidirectional equivalence form

## References

- Infinitary strong completeness: `Bimodal.Metalogic.Completeness.InfinitaryStrongCompleteness`
- Modal Logic, Blackburn et al., Chapter 4
-/

namespace Bimodal.Metalogic.Compactness

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Semantics
open Bimodal.Metalogic.Completeness

/-!
## Compactness via Entailment

First, we establish that semantic consequence from infinite sets
has finite witnesses.
-/

/--
Compactness for entailment: If Γ |= φ, then some finite Δ ⊆ Γ satisfies Δ |= φ.

This follows directly from infinitary strong completeness plus soundness:
1. Γ |= φ
2. By infinitary strong completeness: ∃ Δ finite ⊆ Γ with Δ ⊢ φ
3. By soundness: Δ |= φ
-/
theorem compactness_entailment (Gamma : Set Formula) (phi : Formula) :
    set_semantic_consequence Gamma phi →
    ∃ (Delta : Finset Formula), ↑Delta ⊆ Gamma ∧ set_semantic_consequence ↑Delta phi := by
  intro h_entails
  -- By infinitary strong completeness, get finite witness for derivation
  obtain ⟨Delta, h_sub, h_deriv⟩ := infinitary_strong_completeness Gamma phi h_entails
  use Delta
  constructor
  · exact h_sub
  · -- Δ ⊢ φ implies Δ |= φ by soundness
    -- Use the bridge lemma: finset set_semantic_consequence ↔ list semantic_consequence
    rw [finset_set_semantic_consequence_iff]
    -- Now need to show: semantic_consequence Delta.toList phi
    intro D _ _ _ F M tau t h_list
    have h_deriv_tree : Nonempty (DerivationTree Delta.toList phi) := h_deriv
    obtain ⟨tree⟩ := h_deriv_tree
    exact soundness Delta.toList phi tree D F M tau t h_list

/-!
## Compactness for Unsatisfiability

If an infinite set is unsatisfiable, then some finite subset is unsatisfiable.
-/

/--
Compactness for unsatisfiability: If Γ is unsatisfiable, then some finite Δ ⊆ Γ
is unsatisfiable.

**Proof**: If Γ is unsatisfiable, then Γ |= ⊥. By compactness for entailment,
some finite Δ ⊆ Γ satisfies Δ |= ⊥, i.e., Δ is unsatisfiable.
-/
theorem compactness_unsatisfiability (Gamma : Set Formula) :
    ¬set_satisfiable Gamma →
    ∃ (Delta : Finset Formula), ↑Delta ⊆ Gamma ∧ ¬set_satisfiable ↑Delta := by
  intro h_unsat
  -- Unsatisfiability means Γ |= ⊥
  have h_entails_bot : set_semantic_consequence Gamma Formula.bot := by
    intro D _ _ _ F M tau t h_all
    -- If Gamma were satisfiable here, contradiction would arise
    -- So we need to derive ⊥ from the assumption that Γ is unsatisfied
    exfalso
    apply h_unsat
    exact ⟨D, ‹AddCommGroup D›, ‹LinearOrder D›, ‹IsOrderedAddMonoid D›, F, M, tau, t, h_all⟩
  -- By compactness for entailment, get finite Δ ⊆ Γ with Δ |= ⊥
  obtain ⟨Delta, h_sub, h_delta_entails_bot⟩ := compactness_entailment Gamma Formula.bot h_entails_bot
  use Delta
  constructor
  · exact h_sub
  · -- Δ |= ⊥ means Δ is unsatisfiable
    intro h_delta_sat
    obtain ⟨D, _, _, _, F, M, tau, t, h_all⟩ := h_delta_sat
    have h_bot := h_delta_entails_bot D F M tau t h_all
    -- truth_at M tau t Formula.bot = False
    simp only [truth_at] at h_bot

/-!
## Main Compactness Theorem
-/

/--
**Compactness Theorem** for TM bimodal logic:
A set of formulas is satisfiable iff every finite subset is satisfiable.

**Statement** (forward direction proven here):
`(∀ Δ : Finset, ↑Δ ⊆ Γ → set_satisfiable ↑Δ) → set_satisfiable Γ`

**Proof Strategy**:
By contraposition using compactness_unsatisfiability:
- Suppose Γ is not satisfiable
- Then by compactness_unsatisfiability, some finite Δ ⊆ Γ is unsatisfiable
- This contradicts the hypothesis that all finite subsets are satisfiable
-/
theorem compactness (Gamma : Set Formula) :
    (∀ (Delta : Finset Formula), ↑Delta ⊆ Gamma → set_satisfiable ↑Delta) →
    set_satisfiable Gamma := by
  intro h_fin_sat
  -- Contrapositive: suppose Γ is unsatisfiable
  by_contra h_unsat
  -- By compactness_unsatisfiability, get finite unsatisfiable Δ ⊆ Γ
  obtain ⟨Delta, h_sub, h_delta_unsat⟩ := compactness_unsatisfiability Gamma h_unsat
  -- But h_fin_sat says Δ is satisfiable
  exact h_delta_unsat (h_fin_sat Delta h_sub)

/--
Compactness equivalence: A set is satisfiable iff all finite subsets are.

This is the canonical statement of the compactness theorem.
-/
theorem compactness_iff (Gamma : Set Formula) :
    set_satisfiable Gamma ↔
    (∀ (Delta : Finset Formula), ↑Delta ⊆ Gamma → set_satisfiable ↑Delta) := by
  constructor
  · -- Forward: if Γ is satisfiable, so are all its subsets
    intro ⟨D, hAG, hLO, hOM, F, M, tau, t, h_all⟩ Delta h_sub
    exact ⟨D, hAG, hLO, hOM, F, M, tau, t, fun psi h_psi => h_all psi (h_sub h_psi)⟩
  · -- Backward: compactness
    exact compactness Gamma

/--
Corollary: Finite satisfiability is equivalent to satisfiability for finite sets.

For finite Γ (as Finset), set_satisfiable ↑Γ ↔ ∀ finite Δ ⊆ Γ, set_satisfiable ↑Δ
is trivially true since Γ is already finite.
-/
theorem compactness_finset (Gamma : Finset Formula) :
    set_satisfiable ↑Gamma ↔
    (∀ (Delta : Finset Formula), ↑Delta ⊆ (↑Gamma : Set Formula) → set_satisfiable ↑Delta) := by
  constructor
  · -- Forward: if Γ is satisfiable, so are its subsets
    intro ⟨D, hAG, hLO, hOM, F, M, tau, t, h_all⟩ Delta h_sub
    exact ⟨D, hAG, hLO, hOM, F, M, tau, t, fun psi h_psi => h_all psi (h_sub h_psi)⟩
  · -- Backward: for finite sets, this is trivial (use Γ itself as the finite subset)
    intro h_fin_sat
    have h_self : (↑Gamma : Set Formula) ⊆ ↑Gamma := Set.Subset.rfl
    exact h_fin_sat Gamma h_self

end Bimodal.Metalogic.Compactness
