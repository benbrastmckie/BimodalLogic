# Implementation Summary: Phase 1 Task 1.7 Resolution

**Task**: 155 - reynolds_pipeline_activation
**Phase**: 1 (partial -- Task 1.7 only)
**Session**: sess_1779465184_1afc38
**Date**: 2026-05-22

## What Was Implemented

### Task 1.7: IH h_fwd_r1 Sorry Elimination

**File**: `Theories/Bimodal/Metalogic/WeakCanonical/ExpressivenessGeneral.lean`

Created `ghr93_forward_to_backward_core` (private theorem, ~80 lines) that decouples the rank r+1 forward hypothesis from the induction variable:

1. **Decoupled round count**: Parameter `rounds_r1 : Nat` independent of `n`
2. **Universal rank r+1 hypothesis**: `h_r1_univ : forall {x1 y1 x1' y1'}, x1 <= y1 -> x1' <= y1' -> ghr93_duplicator_wins M N atomMap rounds_r1 (r+1) ...`
3. **Round budget**: `h_enough : 1 + 3 * n <= rounds_r1`

The key insight: `h_r1_univ` does NOT depend on `n` or specific endpoints, so after `revert h_enough x y x' y' ...` + `induction n`, it stays in scope. The IH `ih_gen` is:
```
ih_gen : (1 + 3 * n <= rounds_r1) -> x <= y -> ... -> forward (1+3n) r -> backward n r
```
which is purely rank-r (no rank r+1 obligation).

At each induction step, `h_fwd_r1` for `ghr93_inductive_step` is derived via:
```
ghr93_duplicator_wins_round_mono (by omega) ... (h_r1_univ hxy hx'y')
```

**API change**: `ghr93_forward_to_backward` now takes `h_r1_univ` (universal over endpoints) instead of single-interval `h_r1`. This is necessary because sub-interval restriction at rank r+1 would require d_consistency at rank r+1, which requires Claim 1 at rank r+2, creating an infinite tower.

## Changes

| File | Lines Added | Lines Removed | Net |
|------|------------|---------------|-----|
| ExpressivenessGeneral.lean | 83 | 39 | +44 |

## Verification

- `lake build` passes with zero errors
- No sorry in `ghr93_forward_to_backward_core` or `ghr93_forward_to_backward`
- 8 active sorry sites remain in ExpressivenessGeneral.lean (down from 9)
- No new axioms introduced
- No vacuous definitions

## Plan Deviations

- **Task 1.7**: altered -- Used `h_enough : 1+3*n <= rounds_r1` instead of report 18's `4+3*n <= rounds_r1`. The weaker bound suffices because `1+3*(n+1) = 4+3*n`, so the succ case still derives `4+3*n <= rounds_r1` via omega.

## What Remains (Phase 1)

| Task | Status | Estimated Lines | Depends On |
|------|--------|----------------|------------|
| 1.1 Infimum construction | NOT STARTED | 100-150 | -- |
| 1.4 GHR93 Claim 1 | NOT STARTED | 80-120 | 1.1 |
| 1.5 d_consistency closure | NOT STARTED | 20-40 | 1.4 |
| 1.6 Case II restructure | NOT STARTED | 300-500 | -- |
| 1.8 Verification | NOT STARTED | -- | 1.1-1.7 |
