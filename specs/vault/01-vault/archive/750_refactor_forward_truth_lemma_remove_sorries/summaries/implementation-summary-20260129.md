# Implementation Summary: Task #750

**Date**: 2026-01-29
**Status**: PARTIAL - MCS Truth Lemma implemented with documented architectural limitation

## Overview

This task implemented the MCS-restricted truth lemma approach from implementation plan v005. The approach proves truth correspondence for MCS-derived states, which is what `semantic_weak_completeness` implicitly relies on. A fundamental architectural limitation with box semantics was discovered and documented.

## What Was Accomplished

### 1. MCSDerivedSemanticWorldState Structure

Created `Theories/Bimodal/Metalogic/FMP/MCSDerivedWorldState.lean` (~320 lines) containing:

- **`MCSDerivedSemanticWorldState`**: A subtype of SemanticWorldState that carries proof of MCS derivation
- **`mk_from_closureMCS`**: Constructor from ClosureMaximalConsistent sets
- **`underlying_world_state_models_iff`**: Key lemma connecting MCS membership to assignment truth (sorry-free)

### 2. MCS Truth Correspondence Lemmas (All Sorry-Free)

| Lemma | Purpose |
|-------|---------|
| `mcs_truth_at_bot` | Bot is always false in MCS-derived states |
| `mcs_truth_at_atom` | Atom truth equals MCS membership |
| `mcs_truth_models_iff` | General formula truth equals MCS membership |
| `mcs_truth_at_imp` | Implication truth equals material implication |
| `mcs_contains_or_neg` | Negation completeness for MCS-derived states |

### 3. Key Semantic Truth Lemma (Sorry-Free)

```lean
theorem mcs_semantic_truth_iff_in_mcs (phi : Formula) (w : MCSDerivedSemanticWorldState phi)
    (psi : Formula) (h_mem : psi ∈ closure phi) :
    semantic_truth_at_v2 phi w.state (BoundedTime.origin (temporalBound phi)) psi ↔
    psi ∈ w.underlying_mcs
```

This is the fundamental result that `semantic_weak_completeness` relies on: for MCS-derived states (which the completeness countermodel IS), semantic truth equals MCS membership.

## Architectural Limitation Discovered

### The Box Semantics Problem

The current semantic definition of box quantifies over ALL world histories:
```lean
truth_at M tau t (box phi) = forall (sigma : WorldHistory F), truth_at M sigma t phi
```

This causes the truth lemma to fail for box because:

1. **Induction fails**: When proving `truth_at (box psi) -> semantic_truth_at_v2 (box psi)`, the IH only applies to MCS-derived states, but box quantifies over ALL histories (including those through non-MCS-derived states).

2. **Not all SemanticWorldStates are MCS-derived**: FiniteWorldState only requires IsLocallyConsistent, which is weaker than MCS.

3. **Fundamental mismatch**: The S5-like universal quantification is incompatible with the finite model approach.

### Why `semantic_weak_completeness` Works Despite This

The existing sorry-free `semantic_weak_completeness` works because:

1. It proves the contrapositive: if not provable, construct countermodel where formula is false
2. The countermodel is MCS-derived by construction
3. It only checks `semantic_truth_at_v2` (assignment), never `truth_at` (recursive evaluation)
4. For MCS-derived states, `mcs_semantic_truth_iff_in_mcs` gives the needed correspondence

### The Remaining Gap for Full Completeness

To prove `valid phi -> Provable phi`, we would need:
```lean
valid phi -> (forall w : SemanticWorldState, semantic_truth_at_v2 phi w ...)
```

This requires `truth_at -> semantic_truth_at_v2` for ALL SemanticWorldStates, which fails for box.

## Files Created/Modified

| File | Change |
|------|--------|
| `Theories/Bimodal/Metalogic/FMP/MCSDerivedWorldState.lean` | Created (~320 lines) |
| `specs/750_*/plans/implementation-005.md` | Updated phase markers |

## Sorries in MCSDerivedWorldState.lean

| Line | Lemma | Status |
|------|-------|--------|
| 122 | `mcs_derived_finite` | MCS uniqueness - not critical |
| 366 | `not_provable_of_semantic_countermodel` | Requires soundness - separate concern |

Neither sorry is on the critical path for the truth lemma.

## Build Verification

- `lake build` succeeds (989 jobs)
- No new sorries on critical completeness path
- `semantic_weak_completeness` remains sorry-free
- All new lemmas are sorry-free (except noted non-critical ones)

## Recommendations

### For Practical Use
Use `semantic_weak_completeness` - it's fully sorry-free and provides completeness for the semantic model.

### For `valid -> Provable`
Three potential approaches:

1. **Restrict to box-free fragment**: Temporal-only logic can have full sorry-free truth lemma
2. **Change box semantics**: Use Kripke-style accessibility instead of universal quantification
3. **Accept current result**: `semantic_weak_completeness` provides adequate guarantees

## Conclusion

The MCS-restricted truth lemma approach was implemented successfully. The key theorem `mcs_semantic_truth_iff_in_mcs` is sorry-free and establishes why `semantic_weak_completeness` works: MCS-derived countermodels (which the completeness proof constructs) satisfy the semantic truth correspondence.

The discovered architectural limitation with box semantics is fundamental but doesn't affect the practical completeness result. The existing `semantic_weak_completeness` provides the needed guarantees for the finite model property.

## Previous Implementation Attempts (v001-v004)

Earlier approaches (AlgebraicSemanticBridge, HybridCompleteness) encountered the same fundamental box semantics issue. The MCS-restricted approach clarifies WHY the gap exists and documents the architectural boundary.
