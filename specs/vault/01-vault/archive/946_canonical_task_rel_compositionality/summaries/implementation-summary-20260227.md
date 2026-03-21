# Implementation Summary: Task 946 - canonical_task_rel_compositionality

- **Task**: 946 - Prove canonical_task_rel_compositionality cross-sign cases
- **Status**: Implemented
- **Session**: sess_1772236750_43e88bd2
- **Date**: 2026-02-27

## What Was Done

Eliminated all 4 sorries in `canonical_task_rel_compositionality` by strengthening the `canonical_task_rel` definition from sign-conditioned to unconditional, then rewriting the compositionality proof as a uniform two-line transitivity argument.

## Changes

### Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean

- **Added** `HContent_chain_transitive` theorem: backward (past) analogue of `canonicalR_transitive`. Proves that if `HContent V ⊆ N` and `HContent N ⊆ M` then `HContent V ⊆ M`, using `temp_4_past` (H phi -> HH phi) and MCS closure properties.

### Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean

- **Changed** `canonical_task_rel` definition: from `(d >= 0 -> GContent M ⊆ N) /\ (d <= 0 -> HContent N ⊆ M)` to `GContent M ⊆ N /\ HContent N ⊆ M` (unconditional). Duration parameter `d` retained for TaskFrame compatibility but does not affect the relation.

- **Simplified** `canonical_task_rel_nullity` proof: single `exact` with pair constructor instead of two conditional branches.

- **Rewrote** `canonical_task_rel_compositionality` proof: replaced 110-line case-analysis with 4 sorry sites with a 2-line transitivity proof using `canonicalR_transitive` (forward) and `HContent_chain_transitive` (backward). All 4 sorries eliminated.

- **Updated** `to_history` `respects_task` proof: backward case now uses `fam.backward_H t s phi hst` directly (for general `s <= t`) instead of the previous approach that forced `s = t` via `le_antisymm`.

- **Updated** `CanonicalTaskFrame` docstring: removed note about sorry status.

## Verification

- `lean_goal` shows "no goals" for all modified theorems
- `lake build` passes with no errors (1001 jobs)
- `grep "\bsorry\b"` returns empty for both modified files
- `grep "^axiom "` returns empty for both modified files
- Zero sorries introduced, 4 sorries eliminated
- No new axioms introduced

## Key Insight

The original sign-conditioned definition was mathematically incorrect -- it could not prove compositionality for cross-sign duration cases (research identified a counter-model). The fix was to require both GContent and HContent conditions unconditionally. This is sound because:
1. Nullity still holds via T-axioms (canonicalR_reflexive, canonicalR_past_reflexive)
2. Compositionality becomes trivial via Temporal 4 transitivity
3. The to_history proof is actually simpler with fam.backward_H than the le_antisymm workaround

## Sorry Debt

| Metric | Before | After | Delta |
|--------|--------|-------|-------|
| Sorries in CanonicalConstruction.lean | 4 | 0 | -4 |
| Sorries in CanonicalFrame.lean | 0 | 0 | 0 |
| New axioms | 0 | 0 | 0 |
