# Phase 6A Complete Handoff: Degenerate Cases Closed

**Task**: 155 (Reynolds Pipeline Activation)
**Phase**: 6A (completed)
**Date**: 2026-05-27
**Session**: sess_1748407200_orch155b
**Status**: COMPLETED -- all sorry sites in Composition.lean closed

## What Was Done

Closed the 2 remaining degenerate case sorry sites in `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/Composition.lean`.

### Theorem Signature Change

Added two compatibility hypotheses to `ghr93_strategy_compose`:

```lean
(h_compat_R : (neg exists p : N.carrier, inClosedInterval d y'
    (extendPoint p)) -> c = y)
(h_compat_L : (neg exists p : N.carrier, inClosedInterval x' d
    (extendPoint p)) -> x = c)
```

**Why**: The composition theorem as originally stated was PROVABLY FALSE in the degenerate case. Counter-example: M with carrier {0,1}, N with carrier {0}, one gap each. The right sub-game `h_right` is trivially true (Round 2 vacuous), but the full game's winning condition fails when Spoiler picks a carrier point above c -- there's no matching N-value with correct gap/point status.

**Why the fix is correct**: The hypotheses say "if one sub-interval has no carrier points, the corresponding M-interval is degenerate too." This is satisfied in the GHR93 completeness proof context because the boundaries come from the induction hypothesis and have matching structural properties.

### Degenerate Case Proof Strategy

**Sorry 1 (line 98, right-degenerate)**: `h_no_pt_R` (no carrier point in [d, y'])
1. `c = y` from `h_compat_R`
2. `d = y'` from gap structure: both d and y' must be gaps (otherwise they'd be carrier points in [d,y']), and two distinct gaps have a carrier point between them (`point_between_strict_gaps`), contradiction
3. All selections satisfy `a i <= c` (since `c = y`)
4. Merged game tuples exactly equal left sub-game tuples
5. `hcond_L` directly gives the winning condition

**Sorry 2 (line 112, left-degenerate)**: `h_no_pt_L` (no carrier point in [x', d])
1. `x = c` from `h_compat_L`
2. `x' = d` from gap structure (symmetric argument)
3. `a_R i = a i` for all i (since `c <= a i` from `x = c`)
4. `a' i = a'_R i` for all i (LEFT selections have `a i = c`, forcing `a'_L i = d = a'_R i` from same_order_type)
5. Merged game tuples exactly equal right sub-game tuples
6. `hcond_R` directly gives the winning condition

## Verification

- `lean_verify ghr93_strategy_compose`: axioms = [propext, Classical.choice, Quot.sound] (no sorryAx)
- `lake build`: passes (1667 jobs)
- Sorry count in Composition.lean: 0
- Vacuous definitions: 0
- New axioms: 0

## Impact on Downstream Phases

The new hypotheses `h_compat_R` and `h_compat_L` must be satisfied at all call sites of `ghr93_strategy_compose`. In Phase 6B (Case Analysis), when applying composition:
- The split point comes from game positions with matching structural properties
- The IH guarantees boundary compatibility
- The hypotheses should be straightforwardly provable from the IH context

## Files Modified

- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/Composition.lean` -- closed 2 sorry sites, added 2 hypotheses
- `specs/155_reynolds_pipeline_activation/plans/35_reynolds-pipeline-plan.md` -- Phase 6A marked [COMPLETED]
