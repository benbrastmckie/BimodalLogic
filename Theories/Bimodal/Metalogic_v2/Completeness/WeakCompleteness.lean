import Bimodal.Metalogic_v2.FMP
import Bimodal.Metalogic_v2.Representation.ContextProvability

/-!
# Weak Completeness for TM Bimodal Logic (Metalogic_v2)

This module proves the weak completeness theorem for TM bimodal logic:
valid formulas are provable (⊨ φ → ⊢ φ).

## Overview

This is part of the Metalogic_v2 reorganization that establishes a
representation-first architecture with the Finite Model Property (FMP)
as the central bridge theorem.

## Main Results

- `weak_completeness`: `⊨ φ → ⊢ φ` (valid implies provable)
- `provable_iff_valid`: `⊢ φ ↔ ⊨ φ` (equivalence)

## Layer Dependencies

Completeness.WeakCompleteness depends on:
- Bimodal.Metalogic_v2.FMP (central hub)
- Bimodal.Metalogic_v2.Representation.ContextProvability (context soundness)

## Proof Strategy

The completeness proof uses the representation theorem approach:
1. Assume ⊨ φ (φ is valid in all models)
2. Contrapositive: if ⊬ φ, then [¬φ] is consistent
3. By representation theorem, [¬φ] is satisfiable in canonical model
4. Therefore ¬φ is true somewhere, contradicting validity of φ
5. Hence ⊢ φ

## References

- Modal Logic, Blackburn et al., Chapter 4 (Completeness via Canonical Models)
-/

namespace Bimodal.Metalogic_v2.Completeness

open Bimodal.Syntax Bimodal.ProofSystem Bimodal.Semantics
open Bimodal.Metalogic_v2.Core Bimodal.Metalogic_v2.Representation

/-!
## Weak Completeness

The main completeness result for the empty context.
-/

/--
**Weak Completeness**: Valid formulas are provable from the empty context.

**Statement**: `⊨ φ → Nonempty ([] ⊢ φ)`

**Proof Strategy** (via contrapositive):
1. Assume φ is not provable from []
2. Show [¬φ] is consistent (cannot derive ⊥ from it)
3. By representation theorem, [¬φ] has a canonical world w where ¬φ is true
4. The canonical world gives rise to a model where φ is false
5. This contradicts validity of φ

**Implementation Status**:
Uses representation_theorem_backward_empty from ContextProvability (proven).
-/
theorem weak_completeness (φ : Formula) : valid φ → ContextDerivable [] φ := by
  intro h_valid
  -- Use the backward direction of representation theorem
  -- h_valid says φ is true in all models
  -- Therefore [] ⊨ φ (semantic consequence from empty context)
  have h_sem : semantic_consequence [] φ := by
    intro D _ _ _ F M τ t _
    exact h_valid D F M τ t
  -- By representation_theorem_backward_empty, [] ⊨ φ implies ContextDerivable [] φ
  exact representation_theorem_backward_empty h_sem

/--
**Soundness-Completeness Equivalence**: Provability and validity are equivalent.

**Statement**: `ContextDerivable [] φ ↔ ⊨ φ`

This combines soundness (from Soundness.lean) with weak completeness (this module).
-/
theorem provable_iff_valid (φ : Formula) : ContextDerivable [] φ ↔ valid φ := by
  constructor
  · -- Soundness: derivable implies valid
    intro ⟨d⟩
    have h_sem := Soundness.soundness [] φ d
    intro D _ _ _ F M τ t
    exact h_sem D F M τ t (fun _ h => (List.not_mem_nil h).elim)
  · -- Completeness: valid implies derivable
    exact weak_completeness φ

end Bimodal.Metalogic_v2.Completeness
