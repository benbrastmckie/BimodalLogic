# Handoff: Task 961 Phase 1

**Session**: sess_1773435293_9a4f1c
**Created**: 2026-03-13
**Status**: PARTIAL

## Immediate Next Action

Complete the `strict_intermediate_aux` lemma by filling sorries at lines 226, 248, 253, 274, 278 in CantorApplication.lean. These require proving existence of a strict intermediate when all density intermediates fall into equivalence classes with endpoints.

## Current State

**File**: `Theories/Bimodal/Metalogic/StagedConstruction/CantorApplication.lean`

**Key Structures Added**:
1. `canonicalR_T4_chain` (line ~116): Helper proving transitivity via Temporal 4
2. `strict_intermediate_aux` (line ~156): Bounded-depth iteration for finding strict intermediates
3. `strict_intermediate_exists` (line ~287): Now delegates to `strict_intermediate_aux`

**Sorries** (7 total):
- Line 226: Branch where d ~ c ~ a and d not b (need Classical existence)
- Line 248: Branch where e ~ a, e not d (recursive iteration)
- Line 253: Branch where e not a, e ~ b (recursive iteration)
- Line 274: Branch where d ~ a (recursive iteration)
- Line 278: Branch where d not a, d ~ b (recursive iteration)
- Line 423: NoMaxOrder reflexive case
- Line 482: NoMinOrder reflexive case

## Key Decisions Made

1. **Replaced case-tree with bounded helper**: The original 320+ line case-tree was removed and replaced with `strict_intermediate_aux` which has cleaner structure
2. **T4-based transitivity**: Added `canonicalR_T4_chain` lemma to prove transitivity via Temporal 4 axiom
3. **Classical existence approach**: The plan recommends proving existence by contradiction

## What NOT to Try

1. **Deeper case trees**: The original approach of expanding cases manually doesn't terminate
2. **Direct construction of witness**: The strict intermediate cannot be directly constructed
3. **Finite equivalence class argument**: Research-003 showed equivalence classes are NOT provably finite

## Critical Context

### Mathematical Insight
When [p] < [q] in the quotient and all density intermediates are ~ p or ~ q (but not both), the quotient would collapse to a single point. Since [p] != [q], this is a contradiction. Therefore, a strict intermediate MUST exist.

### Key Lemmas Available
- `intermediate_not_both_equiv`: Intermediate cannot be ~ both endpoints
- `canonicalR_T4_chain`: Transitivity via T4 (a -> b -> c implies a -> c)
- `dense_timeline_has_intermediate`: Gets non-strict intermediate from density
- `mutual_canonicalR_implies_reflexive`: Bidirectional CanonicalR implies reflexivity

### Proof Strategy for Sorries
1. Use `by_contra h_none` to assume no strict intermediate exists
2. `push_neg at h_none` to get: every intermediate is ~ p or ~ q
3. Apply density repeatedly to show quotient collapse
4. Derive `False` from [p] != [q]

## References

- Plan: `specs/961_quotient_density_iteration_no_max_min_dense/plans/implementation-003.md`
- Research: `specs/961_quotient_density_iteration_no_max_min_dense/reports/research-003.md`
- File: `Theories/Bimodal/Metalogic/StagedConstruction/CantorApplication.lean`

## Build Status

lake build passes with 7 sorries (warnings)
