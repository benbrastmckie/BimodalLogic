import Bimodal.ProofSystem
import Bimodal.Semantics
import Bimodal.Metalogic_v2.Soundness.Soundness
import Bimodal.Metalogic_v2.Core.Provability
import Bimodal.Metalogic_v2.Core.DeductionTheorem
import Bimodal.Metalogic_v2.Core.MaximalConsistent
import Bimodal.Metalogic_v2.Representation.CanonicalModel
import Bimodal.Theorems.Propositional
import Bimodal.Metalogic.Completeness.FiniteCanonicalModel
import Mathlib.Data.List.Basic

/-!
# Context-Based Provability and Representation Theorems (Metalogic_v2)

This module implements context-based provability and connects it to the
representation theorems for bimodal/temporal modal logic.

## Overview

This is part of the Metalogic_v2 reorganization that establishes a
representation-first architecture with the Finite Model Property (FMP)
as the central bridge theorem.

## Main Results

- `context_soundness`: Soundness for context-based provability
- `representation_theorem_forward`: ContextDerivable → semantic consequence
- `representation_theorem_empty`: Equivalence for empty context

## Architecture Design

The hierarchy established here:
1. **Representation Theorem** (Primary): Isomorphism between syntax and semantics
2. **General Completeness** (Context-Sensitive): Γ ⊨ φ ⇒ ContextDerivable Γ φ
3. **Finite Model Property** (Contrapositive): From representation theorem
4. **Decidability** (Finite Search): From FMP + correctness

## Key Features

- **Context-Based Provability**: Lean-idiomatic List Formula approach
- **No Artificial Finiteness**: Lists are naturally finite, avoids constraints
- **Semantic Integration**: Builds on proven SemanticWorldState infrastructure
- **Better Temporal Logic Integration**: Native support for temporal reasoning

## Layer Dependencies

Representation.ContextProvability depends on:
- Bimodal.ProofSystem
- Bimodal.Semantics
- Bimodal.Metalogic_v2.Soundness.Soundness
- Bimodal.Metalogic_v2.Core.Provability
-/

namespace Bimodal.Metalogic_v2.Representation

open Bimodal.Syntax Bimodal.ProofSystem Bimodal.Semantics
open Bimodal.Metalogic_v2.Core Bimodal.Metalogic_v2.Soundness
open Bimodal.Theorems.Propositional
open Bimodal.Metalogic.Completeness (SemanticCanonicalFrame SemanticCanonicalModel
  SemanticWorldState semantic_weak_completeness FiniteTime temporalBound)

/--
Soundness theorem for context-based provability.

If Γ ⊢ φ via ContextDerivable, then Γ ⊨ φ semantically.
-/
theorem context_soundness (Γ : Context) (φ : Formula) :
    ContextDerivable Γ φ → semantic_consequence Γ φ := by
  intro ⟨d⟩
  exact soundness Γ φ d

/--
Forward direction of representation theorem: ContextDerivable → semantic model.

If [] ⊢ φ, then [] ⊨ φ by soundness, establishing the forward direction.
-/
theorem representation_theorem_forward {φ : Formula} :
    ContextDerivable [] φ → semantic_consequence [] φ := by
  intro ⟨d⟩
  exact context_soundness [] φ ⟨d⟩

/-!
## Helper Lemmas for Completeness Proof

The following lemmas establish the key steps of the completeness proof via contrapositive:
1. If φ is not derivable from empty context, then [φ.neg] is consistent
2. (Semantic bridge - handled in RepresentationTheorem.lean)
-/

/--
If a formula is not derivable from the empty context, then its negation is consistent.

This is a key lemma for the completeness proof. The proof proceeds by contradiction:
1. Assume ¬ContextDerivable [] φ and ¬Consistent [φ.neg]
2. From ¬Consistent [φ.neg], we have [φ.neg] ⊢ ⊥
3. By deduction theorem: [] ⊢ φ.neg → ⊥ = [] ⊢ φ.neg.neg
4. By double negation elimination: [] ⊢ φ
5. This contradicts ¬ContextDerivable [] φ
-/
theorem not_derivable_implies_neg_consistent {φ : Formula} :
    ¬ContextDerivable [] φ → Consistent [φ.neg] := by
  intro h_not_deriv
  -- Consistent means ¬Nonempty (DerivationTree [φ.neg] Formula.bot)
  intro ⟨d_bot⟩
  apply h_not_deriv
  -- From [φ.neg] ⊢ ⊥, by deduction theorem, [] ⊢ φ.neg → ⊥ = [] ⊢ φ.neg.neg
  have d_neg_neg : DerivationTree [] (Formula.neg φ).neg :=
    deduction_theorem [] φ.neg Formula.bot d_bot
  -- By double negation elimination: ⊢ φ.neg.neg → φ
  have dne : ⊢ φ.neg.neg.imp φ := double_negation φ
  -- Weaken DNE to empty context (trivial since it's already from empty context)
  -- Apply modus ponens: [] ⊢ φ
  have d_phi : DerivationTree [] φ :=
    DerivationTree.modus_ponens [] φ.neg.neg φ
      (DerivationTree.weakening [] [] (φ.neg.neg.imp φ) dne (List.nil_subset []))
      d_neg_neg
  exact ⟨d_phi⟩

/--
Helper lemma: If phi is true at all SemanticWorldStates, then it's provable.

This is a direct application of `semantic_weak_completeness` from FiniteCanonicalModel.lean.
The key is that `semantic_weak_completeness` already contains the full contrapositive proof
showing that if phi is not provable, there exists a SemanticWorldState where phi is false.

Note: This is a `def` rather than `theorem` because the codomain `⊢ φ` is `Type` (not `Prop`).
-/
noncomputable def semantic_world_validity_implies_provable (φ : Formula) :
    (∀ (w : SemanticWorldState φ),
     Bimodal.Metalogic.Completeness.semantic_truth_at_v2 φ w
       (FiniteTime.origin (temporalBound φ)) φ) →
    ⊢ φ := by
  exact semantic_weak_completeness φ

/--
**Bridge Lemma**: semantic_consequence implies truth at all SemanticWorldStates.

This is the key connection between polymorphic validity (quantified over all types D)
and truth in the specific semantic canonical model.

**Proof Strategy**:
1. Given `semantic_consequence [] φ`, instantiate with:
   - `D := Int`
   - `F := SemanticCanonicalFrame φ`
   - `M := SemanticCanonicalModel φ`
2. For each `SemanticWorldState φ`, use `semantic_world_state_has_world_history`
   to get a WorldHistory containing that state
3. Apply the hypothesis to get truth at that history
4. Convert back to `semantic_truth_at_v2`

**Gap**: This requires the bridge lemmas `semantic_world_state_has_world_history`
and `semantic_truth_implies_truth_at` from FiniteCanonicalModel.lean, which currently
have sorries. These sorries arise from complexity in handling time shifts and clamping.

**Status**: Currently uses `sorry` pending completion of bridge infrastructure.
-/
theorem semantic_consequence_implies_semantic_world_truth {φ : Formula} :
    semantic_consequence [] φ →
    ∀ (w : SemanticWorldState φ),
      Bimodal.Metalogic.Completeness.semantic_truth_at_v2 φ w
        (FiniteTime.origin (temporalBound φ)) φ := by
  intro h_sem w
  -- semantic_truth_at_v2 is defined as:
  -- ∃ h_mem : φ ∈ closure φ, (SemanticWorldState.toFiniteWorldState w).models φ h_mem

  -- First, φ ∈ closure φ is trivial
  have h_mem : φ ∈ Bimodal.Metalogic.Completeness.closure φ :=
    Bimodal.Metalogic.Completeness.self_mem_closure φ

  use h_mem

  -- Now need to show: (SemanticWorldState.toFiniteWorldState w).models φ h_mem
  --
  -- Strategy:
  -- 1. Get a WorldHistory τ containing w at time 0 (semantic_world_state_has_world_history)
  -- 2. Apply h_sem with D = Int, F = SemanticCanonicalFrame φ, M = SemanticCanonicalModel φ
  -- 3. Use truth_at_implies_semantic_truth to convert back

  -- Step 1: Get a WorldHistory containing w at time 0
  obtain ⟨tau, ht, h_eq⟩ := Bimodal.Metalogic.Completeness.semantic_world_state_has_world_history φ w

  -- Step 2: Apply h_sem to get truth_at
  have h_truth : truth_at (SemanticCanonicalModel φ) tau 0 φ := by
    apply h_sem Int (SemanticCanonicalFrame φ) (SemanticCanonicalModel φ) tau 0
    -- Need to show: all formulas in [] are true (vacuously true)
    intro psi h_psi_in_ctx
    cases h_psi_in_ctx

  -- Step 3: Convert from truth_at to models
  -- Since tau.states 0 ht = w, we need:
  -- (tau.states 0 ht).toFiniteWorldState.models φ h_mem
  -- which equals w.toFiniteWorldState.models φ h_mem after substitution

  have h_models := Bimodal.Metalogic.Completeness.truth_at_implies_semantic_truth φ tau ht h_mem h_truth

  -- Now h_models : (tau.states 0 ht).toFiniteWorldState.models φ h_mem
  -- We need: w.toFiniteWorldState.models φ h_mem
  -- Since h_eq : tau.states 0 ht = w, we can substitute

  rw [← h_eq]
  exact h_models

/--
**Backward direction for empty context**: semantic entailment → provability.

**Statement**: `[] ⊨ φ → ContextDerivable [] φ`

**Proof Strategy**:
1. By `semantic_consequence_implies_semantic_world_truth`:
   `semantic_consequence [] φ` implies φ is true at all `SemanticWorldState φ`
2. By `semantic_world_validity_implies_provable` (which wraps `semantic_weak_completeness`):
   Truth at all SemanticWorldStates implies `⊢ φ`
3. Wrap in `ContextDerivable` constructor

**Dependencies**:
- `semantic_weak_completeness` (PROVEN in FiniteCanonicalModel.lean)
- `semantic_consequence_implies_semantic_world_truth` (has sorry pending bridge lemmas)

**Status**: Proof structure complete, but depends on bridge lemma with sorry.

**References**:
- Blackburn et al., Modal Logic, Chapter 4.8 (Canonical Model Construction)
- Research report: specs/566_complete_semantic_embedding_for_completeness_proof/reports/research-001.md
- FiniteCanonicalModel.lean: `semantic_weak_completeness` (lines 3280-3349, PROVEN)
-/
theorem representation_theorem_backward_empty {φ : Formula} :
    semantic_consequence [] φ → ContextDerivable [] φ := by
  intro h_sem
  -- Step 1: From semantic_consequence to truth at all SemanticWorldStates
  have h_all_sw : ∀ (w : SemanticWorldState φ),
      Bimodal.Metalogic.Completeness.semantic_truth_at_v2 φ w
        (FiniteTime.origin (temporalBound φ)) φ :=
    semantic_consequence_implies_semantic_world_truth h_sem
  -- Step 2: By semantic_weak_completeness, get provability
  have h_prov : ⊢ φ := semantic_world_validity_implies_provable φ h_all_sw
  -- Step 3: Wrap in ContextDerivable
  exact ⟨h_prov⟩

/--
Simplified representation theorem for empty context.

Focuses on the core equivalence between provability and semantic entailment.
-/
theorem representation_theorem_empty {φ : Formula} :
    ContextDerivable [] φ ↔ semantic_consequence [] φ := by
  constructor
  · exact representation_theorem_forward
  · exact representation_theorem_backward_empty

/--
Validity implies context derivability (from empty context).

If φ is valid (true in all models), then [] ⊢ φ.
-/
theorem valid_implies_derivable {φ : Formula} :
    valid φ → ContextDerivable [] φ := by
  intro h_valid
  apply representation_theorem_backward_empty
  intro D _ _ _ F M τ t _
  exact h_valid D F M τ t

/--
Context derivability implies validity (soundness direction).

If [] ⊢ φ, then φ is valid.
-/
theorem derivable_implies_valid {φ : Formula} :
    ContextDerivable [] φ → valid φ := by
  intro ⟨d⟩
  intro D _ _ _ F M τ t
  have h_sem := soundness [] φ d
  exact h_sem D F M τ t (fun _ h => (List.not_mem_nil h).elim)

/--
Representation theorem stated in terms of validity.

[] ⊢ φ ↔ ⊨ φ
-/
theorem representation_validity {φ : Formula} :
    ContextDerivable [] φ ↔ valid φ := by
  constructor
  · exact derivable_implies_valid
  · exact valid_implies_derivable

end Bimodal.Metalogic_v2.Representation
