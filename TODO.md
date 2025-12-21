# Logos Project TODO

**Last Updated**: 2025-12-21
**Status**: Layer 0 (Core TM) MVP Complete - Review in Progress

## Overview

Logos has completed its MVP phase with a functional implementation of the TM bimodal logic proof system. The current focus is on completing the metalogical proofs for completeness and enhancing automation.

- **Layer 0 Completion**: 83% (Soundness & Deduction complete, Completeness infrastructure only)
- **Active Tasks**: 5
- **Next Milestone**: Completeness Proofs

## Quick Links

- [Implementation Status](Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md)
- [Sorry Registry](Documentation/ProjectInfo/SORRY_REGISTRY.md)
- [Maintenance Workflow](Documentation/ProjectInfo/MAINTENANCE.md)

---

## High Priority (Complete within 1 month)

### 1. Completeness Proofs
**Effort**: 70-90 hours
**Status**: INFRASTRUCTURE ONLY
**Blocking**: Decidability
**Dependencies**: Soundness (Complete), Deduction Theorem (Complete)

**Description**: Implement the completeness proof for TM logic using the canonical model method. The infrastructure (types and axiom statements) is present in `Logos/Core/Metalogic/Completeness.lean`.

**Action Items**:
1. Implement `lindenbaum` lemma (extend consistent sets to maximal consistent sets using Zorn's lemma).
2. Prove properties of maximal consistent sets (deductive closure, negation completeness).
3. Construct `canonical_frame` and prove frame properties (nullity, compositionality).
4. Prove `truth_lemma` (correspondence between membership and truth).
5. Prove `weak_completeness` and `strong_completeness`.

**Files**:
- `Logos/Core/Metalogic/Completeness.lean`

---

## Medium Priority (Complete within 3 months)

### 2. Resolve Truth.lean Sorries
**Effort**: 10-20 hours
**Status**: PARTIAL
**Priority**: Medium (Soundness depends on this for full temporal duality)

**Description**: Resolve the 3 remaining `sorry` placeholders in `Logos/Core/Semantics/Truth.lean` related to temporal swap validity. These require handling domain extension for history quantification.

**Action Items**:
1. Resolve `truth_swap_of_valid_at_triple` (implication case).
2. Resolve `truth_swap_of_valid_at_triple` (past case - domain extension).
3. Resolve `truth_swap_of_valid_at_triple` (future case - domain extension).

**Files**:
- `Logos/Core/Semantics/Truth.lean` (lines 697, 776, 798)

---

## Low Priority (Complete within 6-12 months)

### 3. Automation Tactics
**Effort**: 40-60 hours
**Status**: PARTIAL (4/12 implemented)

**Description**: Implement the remaining planned tactics for TM logic to support easier proof construction.

**Action Items**:
1. Implement `modal_k_tactic`, `temporal_k_tactic`.
2. Implement `modal_4_tactic`, `modal_b_tactic`.
3. Implement `temp_4_tactic`, `temp_a_tactic`.
4. Implement `modal_search`, `temporal_search`.
5. Fix Aesop integration (blocked by Batteries dependency).

**Files**:
- `Logos/Core/Automation/Tactics.lean`

### 4. Proof Search
**Effort**: 40-60 hours
**Status**: PLANNED

**Description**: Implement automated proof search for TM logic.

**Action Items**:
1. Implement breadth-first proof search.
2. Implement heuristic-guided search.

**Files**:
- `Logos/Core/Automation/ProofSearch.lean`

### 5. Decidability
**Effort**: 40-60 hours
**Status**: PLANNED

**Description**: Implement decision procedures for TM logic.

**Action Items**:
1. Implement tableau method.
2. Implement satisfiability decision procedure.

**Files**:
- `Logos/Core/Metalogic/Decidability.lean` (to be created)

### 6. ModalS5 Limitation
**Effort**: Low
**Status**: DOCUMENTED LIMITATION

**Description**: The theorem `diamond_mono_imp` in `ModalS5.lean` is marked with `sorry` because it is not valid as an object-level implication. This is a documented limitation.

**Action Items**:
1. Maintain documentation or find alternative formulation if possible.

**Files**:
- `Logos/Core/Theorems/ModalS5.lean`

---

## Completion History

See git history for completed tasks:
```bash
git log --all --grep="Complete Task" --oneline
```
