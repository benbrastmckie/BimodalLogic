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
**Backward direction for empty context**: semantic entailment → provability.

**Statement**: `[] ⊨ φ → ContextDerivable [] φ`

**Proof Strategy** (via contrapositive):

The standard completeness proof proceeds by contrapositive:
1. Show `¬ContextDerivable [] φ → ¬semantic_consequence [] φ`
2. Use `Function.mtr` to convert to the forward direction

**Proof Sketch**:
```
Given: ¬ContextDerivable [] φ

Step 1: By `not_derivable_implies_neg_consistent`: Consistent [φ.neg]

Step 2: By `representation_theorem`: ∃ w : CanonicalWorldState, φ.neg ∈ w.carrier

Step 3: Need to show: ¬semantic_consequence [] φ
        i.e., exhibit a model M and time t where φ is false

        This requires constructing a TaskFrame D / TaskModel from the canonical world.
        The semantic_consequence quantifies over ALL types D, so we need to:
        - Choose a concrete D (e.g., Int)
        - Construct a TaskFrame D from canonical model
        - Show truth in canonical model implies truth in TaskModel
        - The canonical world w where φ.neg is true provides the countermodel
```

**Gap**: Step 3 requires bridging canonical model truth (set membership) to
polymorphic semantic validity (quantified over all temporal types). This
"semantic embedding" is non-trivial because:
- `CanonicalWorldState` is an MCS (maximal consistent set of formulas)
- `TaskFrame D` requires temporal structure with duration algebra
- The canonical model accessibility relations need to be embedded into task relations

**Status**: Axiom pending completion of semantic embedding infrastructure.
The helper lemma `not_derivable_implies_neg_consistent` completes the first half
of the contrapositive proof (syntactic side). The remaining work is the semantic
embedding (connecting canonical worlds to TaskModel).

**Dependencies**:
- `not_derivable_implies_neg_consistent` (proven above)
- `representation_theorem` (from RepresentationTheorem.lean)
- Semantic embedding (TODO: construct TaskFrame from canonical model)

**References**:
- Blackburn et al., Modal Logic, Chapter 4.8 (Canonical Model Construction)
- Research report: specs/560_axiom_elimination/reports/research-001.md
-/
axiom representation_theorem_backward_empty {φ : Formula} :
    semantic_consequence [] φ → ContextDerivable [] φ

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
