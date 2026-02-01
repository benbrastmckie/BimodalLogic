# Metalogic v4 Completeness Archive

**Archived**: 2026-02-01
**Task**: 777 - complete_weak_completeness_sorry
**Session**: sess_1769987695_38ea66

## Purpose

This directory contains deprecated completeness code from `Theories/Bimodal/Metalogic/Completeness/` that was archived to reduce sorry count in the active codebase. The code is preserved for reference and historical context.

## Archived Files

### FiniteCanonicalModel.lean

**Source**: `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean`
**Sorry Count**: 71 sorries
**Status**: DEPRECATED

**What it contains**:
1. **Syntactic Approach (DEPRECATED)**: `FiniteWorldState`, `finite_task_rel`, `finite_truth_lemma`
   - 6+ sorry gaps in backward directions of truth lemma
   - Fundamental issue: `IsLocallyConsistent` only provides soundness, not negation-completeness

2. **Semantic Approach**: `SemanticWorldState`, `semantic_truth_lemma_v2`, `semantic_weak_completeness`
   - Core theorems are proven (no sorries in the semantic approach core)
   - Bridge lemmas to general `valid` definition have sorries

3. **Helper Definitions**:
   - `FiniteTime k`: Time domain `Fin (2 * k + 1)` for integers from -k to +k
   - `closure`: Subformula closure as a Finset
   - `ClosureConsistent`, `ClosureMaximalConsistent`: Closure-restricted consistency
   - `FiniteHistory`: Histories bounded by temporal/modal depth

**Why Archived**:
- The "semantic approach" definitions in this file are now duplicated/superseded by
  `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean`
- The "syntactic approach" has fundamental gaps that cannot be fixed
- 71 sorries contribute significant technical debt with no path to resolution
- The file imports `Completeness.lean` which creates circular dependency issues

## Sorry Analysis

### Deprecated (Syntactic Approach)
These sorries are in the original syntactic approach, superseded by the semantic approach:
- `IsLocallyConsistent.imp_left` - Transfer property (need negation-completeness)
- `modalConsistentRequirements` - Modal consistency
- `FiniteTaskRel.compositionality` - Mixed-sign temporal cases
- `finite_history_from_state` - History construction from world state
- `FiniteCanonicalFrame.nullity` - Reflexivity proof
- `finite_truth_lemma` - 6 backward direction gaps

### Bridge Lemmas (Minor)
These sorries bridge semantic completeness to general validity definition:
- `finiteHistoryToWorldHistory.respects_task` - Time arithmetic
- `semantic_world_state_has_world_history` - History alignment
- `semantic_truth_implies_truth_at` - Formula induction
- `truth_at_implies_semantic_truth` - Formula induction
- `main_weak_completeness` - Bridge to `valid`
- `main_strong_completeness` - Deduction theorem

## Sorry-Free Alternative

Use `semantic_weak_completeness` from `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean`:

```lean
noncomputable def semantic_weak_completeness (phi : Formula) :
    (forall (w : SemanticWorldState phi),
     semantic_truth_at_v2 phi w (BoundedTime.origin (temporalBound phi)) phi) ->
    |- phi
```

The complete sorry-free completeness chain is:
1. `Soundness.lean` - Soundness theorem
2. `WeakCompleteness.lean` - Weak completeness
3. `FiniteStrongCompleteness.lean` - Finite strong completeness
4. `InfinitaryStrongCompleteness.lean` - Infinitary strong completeness
5. `Compactness.lean` - Compactness

## Historical Context

- **Task 473**: Introduced SemanticWorldState architecture as fix for syntactic approach gaps
- **Task 794**: Established sorry-free completeness chain in main module
- **Task 777**: Archived this file since it's now redundant

The syntactic approach attempted to build world states from local consistency predicates,
but this only captures soundness (derivable formulas are consistent), not the negation-completeness
(maximality) needed for the backward direction of the truth lemma.

The semantic approach sidesteps this by defining world states as quotients of (history, time) pairs,
making truth at a world state definitionally equal to truth in the underlying history.

## References

- Research report: specs/777_complete_weak_completeness_sorry/reports/research-008.md
- Blackburn et al., Modal Logic, Chapter 4 (Finite Model Property)
- Goldblatt, Logics of Time and Computation (Temporal Completeness)
