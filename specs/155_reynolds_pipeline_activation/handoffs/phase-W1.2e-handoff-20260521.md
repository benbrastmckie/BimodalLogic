# Phase W1.2e Handoff: D-Consistency Partial Progress

**Task**: 155 (reynolds_pipeline_activation)
**Phase**: 4C-W1.2e (D-Consistency Claim 1)
**Session**: sess_1779410766_5a52de
**Date**: 2026-05-21

## Status

PARTIAL. Boundary cases proved; interior case blocked.

## What Was Done

1. **Boundary case x'=d**: Proved in both `d_consistency_left` (line ~1134) and `d_consistency_right` (line ~1218). From `hcd_boundary.1 : x = c ↔ x' = d`, get `x = c`. From `same_order_type` at indices (0, n+1), extract `x = c ↔ x' = t`. Conclude `t = d`.

2. **Boundary case d=y'**: Proved similarly. From `hcd_boundary.2 : c = y ↔ d = y'`, get `c = y`. From `same_order_type` at indices (n+1, n+3), extract `c = y ↔ t = y'`. Conclude `t = d`.

3. **Interior case analysis**: Attempted multiple approaches (Round 2 point challenges, formula_agreement transitivity, h_fwd constructive use). Determined the theorem is unprovable from given hypotheses for interior points.

## Why Interior Case Is Blocked

The theorem universally quantifies: "for ALL a'_full satisfying the winning condition, a'_full(n) = d". This requires that d is the UNIQUE element with certain properties. But:

- **Point case**: Two interior points can have identical rank_type (all rank-r formulas agree) but be distinct. The same_order_type constraints from the winning condition reduce to tautologies (b_t < b_d ↔ p_t < p_d).

- **Gap case**: Two gaps with identical formula truth could conceivably have different cuts. Proving cut equality requires connecting formula truth to cut membership, which needs the infimum characterization.

- **Root cause**: `d = a_bwd(n)` is Spoiler's arbitrary backward choice. In GHR93, d-bar is the INFIMUM of continuation_set, giving an asymmetric characterization that forces uniqueness. The current code conflates d with a_bwd(n).

## Resolution Options

1. **(Easiest) Weaken theorem**: Change from "for all a'_full..." to "the strategy h_fwd applied to a_pad gives a'_full with a'_full(n) = d". Requires updating `ghr93_strategy_restrict_left/right` to pass the strategy explicitly. ~50 lines in EFGames.lean.

2. **(Medium) Add infimum hypothesis**: Add `d_is_infimum` as a hypothesis to d_consistency. Requires establishing infimum property at the call site in `obtain_split_point_props`. ~80-120 lines.

3. **(Hard) Redefine d as infimum**: Change `d := a_bwd(n)` to `d := inf(continuation_set)` in `obtain_split_point_props`. Requires updating `hd_eq_an` (used ~22 times in Case II) to `hd_le_an`. ~170-330 lines.

## Current Proof State

```
d_consistency_left (line ~1076):
  - Boundary x'=d: PROVED
  - Boundary d=y': PROVED
  - Interior: sorry (line 1154)

d_consistency_right (line ~1161):
  - Boundary x'=d: PROVED
  - Boundary d=y': PROVED
  - Interior: sorry (line 1226)
```

## Next Action

Implement one of the three resolution options above. Option 1 (weaken theorem) is recommended as it requires the fewest changes and does not affect the mathematical correctness.

## Key Files

- `Theories/Bimodal/Metalogic/WeakCanonical/ExpressivenessGeneral.lean` (lines 1076-1226)
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames.lean` (lines 3164-3390, strategy_restrict_left/right)
- `specs/155_reynolds_pipeline_activation/reports/22_d-consistency-implementation.md`
