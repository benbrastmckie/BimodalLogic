# Implementation Summary: CanonicalR Recovery from CanonicalTask

**Task**: 13 - canonical_r_recovery_from_canonical_task
**Session**: sess_1774087606_e95408
**Date**: 2026-03-21

## Overview

Created `Theories/Bimodal/Metalogic/StagedConstruction/CanonicalRecovery.lean` establishing
the relationship between the duration-agnostic `CanonicalR` relation and the duration-precise
`CanonicalTask` relation built from Succ-chains.

## Phase Results

| Phase | Status | Notes |
|-------|--------|-------|
| 1: File Structure | COMPLETED | Created CanonicalRecovery.lean with imports |
| 2: Forward Direction | COMPLETED | 4 theorems proven without sorry |
| 3: Backward Direction | PARTIAL | 1 sorry - requires Succ-chain decomposition from g_content |
| 4: Backward-Compat Layer | COMPLETED | 4 theorems proven without sorry |
| 5: Integration | COMPLETED | Full build passes (1024 jobs) |

## Theorems Proven (No Sorry)

### Forward Direction
1. **`canonicalTask_forward_MCS_implies_canonicalR`**: MCS-annotated chain -> identity or CanonicalR
2. **`canonicalTask_forward_one_implies_canonicalR`**: Single-step chain -> CanonicalR
3. **`canonicalTask_forward_MCS_pos_implies_canonicalR`**: Chain of length >= 1 -> CanonicalR
4. **`Succ_to_CanonicalR`**: Convenience re-export of Succ -> CanonicalR

### Backward-Compatibility Layer
5. **`canonical_forward_G_from_succ`**: G-forward via single Succ step
6. **`canonical_forward_G_from_task`**: G-forward via MCS-chain (n >= 1)
7. **`canonical_forward_F_with_canonicalR`**: F-forward re-export
8. **`successor_from_seriality`**: Successor existence re-export

## Sorry Analysis

### `canonicalR_implies_canonicalTask_forward` (1 sorry)

**Reason**: The backward direction (CanonicalR -> exists CanonicalTask chain) is genuinely
harder because CanonicalR only guarantees `g_content u ⊆ v` while Succ additionally
requires `f_content u ⊆ v ∪ f_content v`. Constructing a Succ-chain from a bare
g_content inclusion requires:

1. Iterative use of `successor_exists` to build intermediate worlds
2. A convergence argument showing the chain eventually reaches the target v
3. F-nesting depth bounds for termination of the construction

This is an independent research problem that would benefit from a dedicated subtask.

**Impact**: Low. The forward direction is the commonly needed one in practice, since
CanonicalTask chains are constructed explicitly in the discrete completeness proof,
and one typically needs to derive CanonicalR from them (not the reverse).

## Key Design Decision: Strict Temporal Order

The temporal order in this system is strict (irreflexive): there is NO axiom
`G phi -> phi`. This means:
- `CanonicalR u u` (g_content u ⊆ u) does NOT hold in general
- The G-forward property requires n >= 1 (at least one actual step)
- For n = 0 chains (identity), separate handling is needed

This was discovered during implementation when the planned `canonical_forward_G'`
for arbitrary n would have been unsound for n = 0.

## Verification

- **Build**: `lake build` succeeds (1024 jobs, 0 errors)
- **Sorry count**: 1 (backward direction, documented above)
- **New axioms**: 0
- **Regressions**: None

## Files Modified

- `Theories/Bimodal/Metalogic/StagedConstruction/CanonicalRecovery.lean` (NEW)

## Dependencies Found Complete

Tasks 11 (CanonicalTaskRelation.lean) and 12 (SuccExistence.lean) were found to be
already completed, contrary to the initial task description that said they were not
yet done. This enabled proving the forward direction fully.
