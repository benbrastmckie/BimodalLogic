# Phase 4C-W1 Degenerate Interval Fix Handoff

**Session**: sess_1779368619_a65efa
**Date**: 2026-05-21
**Status**: PARTIAL -- 4 degenerate N-side sorries eliminated, 2 new M-side degenerate sorries added

## Summary of Work Done

### Degenerate Interval Restructuring

Restructured `obtain_split_point_props` in ExpressivenessGeneral.lean to handle degenerate sub-intervals (x'=d or d=y') using `ghr93_duplicator_wins_degenerate_gap` instead of requiring point witnesses that don't exist.

**Changes**:
1. Added boundary order correspondence to `h_exists`: `(x = c <-> x' = d) /\ (c = y <-> d = y')`
2. Proved boundary correspondence in the point case from same_order_type at indices (0,2) and (2,3)
3. Constructed sigma and tau via case split: degenerate (use degenerate_gap lemma) vs non-degenerate (use IH with point witness)
4. Eliminated 4 N-side degenerate sorries (old lines 352, 372, 392, 409)

**Net sorry change**: 9 -> 7 (eliminated 4, added 2 new)

### New Sorries (M-side degenerate point witnesses)

Lines 430, 447: When x = c (or c = y) and both are gaps, `SplitPointProps` demands `h_pt_xc` (existence of actual point in [x,c]) and `h_pt_cy` (in [c,y]). These don't exist when the interval is degenerate. SplitPointProps needs restructuring to make these optional.

### Remaining Sorries (7 total)

| Line | Content | Status |
|------|---------|--------|
| 306 | d-consistency left | UNCHANGED -- requires Claim 1 or architecture change |
| 316 | d-consistency right | UNCHANGED -- same as above |
| 430 | h_pt_xc degenerate (x=c, both gaps) | NEW -- SplitPointProps needs optional h_pt_xc |
| 447 | h_pt_cy degenerate (c=y, both gaps) | NEW -- SplitPointProps needs optional h_pt_cy |
| 551 | c construction when d is gap | UNCHANGED -- needs Lemma 9 |
| 2455 | Cases III/IV | UNCHANGED |
| 2676 | rank-varying Thm 6 | UNCHANGED |

## Key Technical Findings

### 1. D-Consistency is Genuinely Unprovable for d = a_bwd(n)

Extensive analysis confirmed: `d = a_bwd(n)` (Spoiler's arbitrary backward selection) cannot be proved equal to the forward strategy's response at the boundary. The GHR93 paper defines d as an infimum, not as a_bwd(n). D-consistency (Claim 1) only works when d IS the infimum.

**Two correct paths forward**:
A. **Redefine d as infimum or canonical response** + replace hd_eq_an with hd_le_an + rewrite Case II (28 sites). ~250-380 lines.
B. **Implement full Claim 1 argument** (infimum infrastructure for ExtendedCarrier + formula C construction). ~150-200 lines of new infrastructure. Keeps hd_eq_an IF a_bwd(n) can be shown to be the infimum (unlikely since a_bwd is arbitrary).

**Recommended**: Option A. Redefine d from the canonical response, prove d <= a_bwd(n), change SplitPointProps, fix Case II.

### 2. M-side Degenerate Point Witnesses

When x = c (both gaps), [x,c] has no actual points. SplitPointProps.h_pt_xc demands one. Fix: make h_pt_xc and h_pt_cy conditional (Option type or separate degenerate/non-degenerate branches).

### 3. Boundary Order Correspondence

Successfully proved that the forward strategy's same_order_type gives `x = c <-> x' = d` and `c = y <-> d = y'`. This is essential for the degenerate case (deriving x=c from x'=d). The proof uses the 1-round play's winning condition at game_tuple indices (0,2) and (2,3).

## Immediate Next Actions

1. **Fix M-side degenerate sorries (lines 430, 447)**: Make h_pt_xc/h_pt_cy optional in SplitPointProps. When the M-side interval is degenerate, Case I and Case II don't need these witnesses (they use sigma/tau at the d boundary, not at the x boundary).

2. **Address d-consistency (lines 306, 316)**: Implement Option A -- redefine d as canonical response, add hd_le_an, fix Case II.

## Files Modified

- `Theories/Bimodal/Metalogic/WeakCanonical/ExpressivenessGeneral.lean` -- restructured obtain_split_point_props sigma/tau construction
