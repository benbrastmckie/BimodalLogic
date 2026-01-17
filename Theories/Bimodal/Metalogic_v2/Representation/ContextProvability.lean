import Bimodal.ProofSystem
import Bimodal.Semantics
import Bimodal.Metalogic_v2.Soundness.Soundness
import Bimodal.Metalogic_v2.Core.Provability
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

/--
Backward direction for empty context: semantic entailment → provability.

This requires the completeness theorem. In Metalogic_v2, we will establish
this through the FMP bridge once it's built.

For now, this is stated as an axiom that will be proven once the full
completeness machinery is in place.
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
