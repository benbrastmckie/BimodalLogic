# D-Consistency Weakening Handoff

**Task**: 155 (reynolds_pipeline_activation)
**Session**: sess_1779410766_5a52de
**Date**: 2026-05-21
**Status**: COMPLETED (interface weakening applied, sorry count unchanged)

## What Was Done

Changed d_consistency_left/right and ghr93_strategy_restrict_left/right from a **universal** quantifier over all winning responses to an **existential** quantifier.

### Old Interface (universal)
```
h_d_consistent : forall a_pad, bounds -> a_pad(n) = c ->
  forall a'_full, bounds -> winning_condition -> a'_full(n) = d
```
Required: ALL winning responses must have d at position n. Unprovable for interior case.

### New Interface (existential)
```
h_d_consistent : forall a_pad, bounds -> a_pad(n) = c ->
  exists a'_full, bounds AND winning_condition AND a'_full(n) = d
```
Required: THERE EXISTS a winning response with d at position n. Weaker but sufficient.

## Files Modified

1. **EFGames.lean** (lines ~2914-3284):
   - `ghr93_strategy_restrict_left`: removed `h` parameter (forward strategy), changed `h_d_consistent` to existential form. Proof updated to `obtain` from existential.
   - `ghr93_strategy_restrict_right`: same changes, dual for position 0.

2. **ExpressivenessGeneral.lean** (lines ~1066-1460):
   - `d_consistency_left`: changed conclusion to existential. Proof now applies h_fwd to get a'_full, then wraps in existential for boundary cases.
   - `d_consistency_right`: same changes.
   - `obtain_split_point_props`: simplified call sites, removed explicit type annotations (let Lean infer from d_consistency_left/right).

## Key Design Decisions

1. **Removed `h` parameter from strategy_restrict**: The forward strategy is now folded into `h_d_consistent` (which internally applies h_fwd). This eliminates the redundancy of passing both the strategy AND a consistency property about it.

2. **Boundary cases wrap in existential**: For boundary cases (x'=d, d=y'), the proof applies h_fwd, proves a'_full(n)=d from same_order_type, then packages into the existential tuple.

3. **Interior sorry remains**: The existential form is still unprovable for the interior case without GHR93 Claim 1 infrastructure. The sorry is strictly no harder than before (same proof obligations exist in context).

## Impact

- **Sorry count**: unchanged (185 total, 2 in d_consistency interior cases)
- **Build**: passes
- **Downstream**: strategy_restrict consumers work identically (they only ever needed ONE response)
- **Future**: when Claim 1 infrastructure is built, the existential proof is strictly easier to close than the old universal proof

## Next Action

To close the interior sorry, implement GHR93 Claim 1: define continuation_set C, construct infimum d_bar, prove d_bar = a_bwd(n), then exhibit a winning response with d_bar at position n. Alternatively, explore redefining d as the forward strategy's canonical response (requires reworking hd_eq_an).
