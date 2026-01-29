import Bimodal.Metalogic.Completeness.FiniteStrongCompleteness
import Mathlib.Data.Finset.Basic

/-!
# Infinitary Strong Completeness for TM Bimodal Logic

This module proves strong completeness for TM bimodal logic with
potentially infinite premise sets (contexts represented as `Set Formula`).

## Overview

The key result is that if a Set-based context Gamma semantically implies phi,
then there exists a finite subset Delta ⊆ Gamma such that Delta ⊢ phi.

This bridges the gap between:
- Finite-premise strong completeness (List-based contexts)
- True compactness (infinite premise sets)

## Main Results

- `set_semantic_consequence`: Semantic consequence for Set-based contexts
- `set_satisfiable`: Satisfiability for Set-based contexts
- `infinitary_strong_completeness`: Every Set-based semantic consequence
  has a finite derivation witness

## Proof Strategy

The key insight is that proof-theoretic derivations use only finitely many
premises. The full infinitary strong completeness theorem requires either:
1. Model-theoretic compactness (proved separately)
2. Or: axiomatized as the semantic compactness principle

For finite sets, the theorem follows directly from finite_strong_completeness.

## References

- Finite strong completeness: `Bimodal.Metalogic.Completeness.FiniteStrongCompleteness`
- Modal Logic, Blackburn et al., Chapter 4
-/

namespace Bimodal.Metalogic.Completeness

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Semantics

/-!
## Set-Based Semantic Notions

These definitions extend the finite (List-based) notions to arbitrary sets.
-/

/--
Set-based semantic consequence: phi is a consequence of (possibly infinite) set Gamma.

This quantifies over all temporal types D and all models.
-/
def set_semantic_consequence (Gamma : Set Formula) (phi : Formula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    (F : TaskFrame D) (M : TaskModel F) (tau : WorldHistory F) (t : D),
    (∀ psi ∈ Gamma, truth_at M tau t psi) → truth_at M tau t phi

/--
Set-based satisfiability: a set Gamma is satisfiable if there exists a model
where all formulas in Gamma are true at some point.
-/
def set_satisfiable (Gamma : Set Formula) : Prop :=
  ∃ (D : Type) (_ : AddCommGroup D) (_ : LinearOrder D) (_ : IsOrderedAddMonoid D)
    (F : TaskFrame D) (M : TaskModel F) (tau : WorldHistory F) (t : D),
    ∀ psi ∈ Gamma, truth_at M tau t psi

/--
Set-based consistency: a set is consistent if no finite subset derives ⊥.
-/
def set_consistent (Gamma : Set Formula) : Prop :=
  ∀ (Delta : Finset Formula), ↑Delta ⊆ Gamma → Consistent Delta.toList

/-!
## Bridge Lemmas

These lemmas connect Set-based and List-based notions.
-/

/--
List-based semantic consequence implies Set-based semantic consequence
when the list is viewed as a set.
-/
lemma list_to_set_semantic_consequence (Gamma : Context) (phi : Formula) :
    semantic_consequence Gamma phi →
    set_semantic_consequence (Gamma.toFinset : Set Formula) phi := by
  intro h_list D _ _ _ F M tau t h_set
  apply h_list D F M tau t
  intro psi h_psi
  apply h_set psi
  simp [h_psi]

/--
Monotonicity of semantic consequence: If Delta ⊆ Gamma and Gamma |= phi, then Delta |= phi
only if all formulas in Gamma \ Delta are also satisfied.

**Note**: This is NOT generally true. Semantic consequence is ANTI-monotonic in premises:
If Delta ⊆ Gamma, then Gamma |= phi implies Delta |= phi is FALSE in general.
(More premises = stronger assumption = more consequences.)

What IS true: If Delta ⊇ Gamma (more premises), then Gamma |= phi implies Delta |= phi.

The correct direction is: set_semantic_consequence Delta phi → set_semantic_consequence Gamma phi
when Delta ⊆ Gamma (fewer premises means consequence still holds for more premises).
-/
lemma semantic_consequence_weaken (Gamma Delta : Set Formula) (phi : Formula)
    (h_sub : Delta ⊆ Gamma) :
    set_semantic_consequence Delta phi → set_semantic_consequence Gamma phi := by
  intro h_delta D _ _ _ F M tau t h_gamma
  apply h_delta D F M tau t
  intro psi h_psi
  exact h_gamma psi (h_sub h_psi)

/--
If Gamma is a finite set (as Finset), set_semantic_consequence equals semantic_consequence.
-/
lemma finset_set_semantic_consequence_iff (Gamma : Finset Formula) (phi : Formula) :
    set_semantic_consequence ↑Gamma phi ↔ semantic_consequence Gamma.toList phi := by
  constructor
  · intro h_set D _ _ _ F M tau t h_list
    apply h_set D F M tau t
    intro psi h_psi
    apply h_list psi
    exact Finset.mem_toList.mpr h_psi
  · intro h_list D _ _ _ F M tau t h_set
    apply h_list D F M tau t
    intro psi h_psi
    apply h_set psi
    exact Finset.mem_toList.mp h_psi

/-!
## Infinitary Strong Completeness

The main theorem: Set-based semantic consequence implies existence of a
finite derivation witness.
-/

/--
**Infinitary Strong Completeness**: If phi is a Set-based semantic consequence of Gamma,
then there exists a finite subset Delta ⊆ Gamma such that Delta ⊢ phi.

**Statement**: `set_semantic_consequence Gamma phi →
  ∃ (Delta : Finset Formula), ↑Delta ⊆ Gamma ∧ ContextDerivable Delta.toList phi`

**Proof Status**: Axiomatized with sorry.

The full proof requires either:
1. Model-theoretic compactness (ultraproducts), or
2. A proof-theoretic argument showing derivations use finite premises

For finite Gamma, use `infinitary_strong_completeness_finset` which is fully proven.

**Note**: This theorem together with soundness establishes the semantic compactness
principle for TM logic: if Gamma |= phi, then some finite Delta ⊆ Gamma satisfies Delta |= phi.
-/
theorem infinitary_strong_completeness (Gamma : Set Formula) (phi : Formula) :
    set_semantic_consequence Gamma phi →
    ∃ (Delta : Finset Formula), ↑Delta ⊆ Gamma ∧ ContextDerivable Delta.toList phi := by
  intro h_set_entails
  -- The key insight is that if Gamma |= phi, then:
  -- 1. Either Gamma is finite, and we apply finite_strong_completeness
  -- 2. Or Gamma is infinite, and we need a compactness argument

  -- For the infinite case, the argument is:
  -- If no finite Delta ⊆ Gamma derives phi, then for each finite Delta,
  -- Delta ∪ {¬phi} is consistent. By a compactness/ultraproduct argument,
  -- this gives a model satisfying all of Gamma and ¬phi, contradicting Gamma |= phi.

  -- This requires model-theoretic machinery beyond the current scope.
  -- See Bimodal.Metalogic.Compactness for the full compactness theorem.
  sorry

/--
Special case: For finite sets (Finset), infinitary strong completeness reduces to
finite strong completeness. This case is fully proven.
-/
theorem infinitary_strong_completeness_finset (Gamma : Finset Formula) (phi : Formula) :
    set_semantic_consequence ↑Gamma phi → ContextDerivable Gamma.toList phi := by
  intro h_set_entails
  have h_list_entails : semantic_consequence Gamma.toList phi := by
    intro D _ _ _ F M tau t h_list
    apply h_set_entails D F M tau t
    intro psi h_psi
    apply h_list psi
    exact Finset.mem_toList.mpr h_psi
  exact finite_strong_completeness Gamma.toList phi h_list_entails

/--
Corollary: For finite sets with explicit witness.
-/
theorem infinitary_strong_completeness_finset' (Gamma : Finset Formula) (phi : Formula) :
    set_semantic_consequence ↑Gamma phi →
    ∃ (Delta : Finset Formula), ↑Delta ⊆ (↑Gamma : Set Formula) ∧ ContextDerivable Delta.toList phi := by
  intro h_set_entails
  use Gamma
  constructor
  · rfl
  · exact infinitary_strong_completeness_finset Gamma phi h_set_entails

end Bimodal.Metalogic.Completeness
