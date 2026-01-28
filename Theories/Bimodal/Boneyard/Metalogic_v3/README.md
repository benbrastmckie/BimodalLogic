# Metalogic_v3 Boneyard

This directory contains code moved from the active Metalogic implementation that is **NOT REQUIRED for the completeness theorem**.

## Why This Code Is Here

The completeness proof path only exercises specific cases:

```
representation_theorem
    └── truth_lemma_forward
        ├── all_past forward   → backward_H Case 4 (both t, t' < 0) ✅ PROVEN
        └── all_future forward → forward_G Case 1 (both t, t' ≥ 0) ✅ PROVEN
```

All other coherence cases (cross-origin, cross-modal, backward Truth Lemma) are never executed during the completeness proof and have been moved here.

## Contents

### Coherence/

Contains unused coherence cases from `CoherentConstruction.lean`:

- **CrossOriginCases.lean**: Cases that bridge negative and non-negative time indices
  - `forward_G` Cases 3-4 (cross-origin, both < 0)
  - `backward_H` Cases 1-2 (both ≥ 0, cross-origin)
  - `backward_G` Cases 3-4 (cross-origin, both < 0)
  - `forward_H` all cases

### TruthLemma/

Contains unused Truth Lemma directions:

- **BackwardDirection.lean**: The backward Truth Lemma (`truth_at → φ ∈ MCS`)
  - `all_past` backward case
  - `all_future` backward case

## Potential Future Use

If you need:

1. **Backward Truth Lemma** (model is "tight" - no extraneous truths):
   - Useful for soundness, frame correspondence, definability
   - Would need the backward cases from TruthLemma/

2. **Full bidirectional coherence**:
   - Useful for reasoning about formulas spanning past and future
   - Would need the cross-origin cases from Coherence/

## Reference

See `specs/681_redesign_construct_indexed_family_coherent_approach/reports/research-004.md` for the complete gap analysis that determined which sorries are non-blocking for completeness.
