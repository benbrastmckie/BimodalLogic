# Phase 5 Handoff: Depth-0 Between-Zone Transfer

## Status: BLOCKED (Partial Progress)

## What Was Accomplished

1. **Created two standalone helper lemmas** in PriorComposition.lean:
   - `depth0_3var_exist_transfer_until` (line ~200): handles depth-0 3-var existential transfer for Until zone (t < x, t' < x')
   - `depth0_3var_exist_transfer_since` (line ~277): mirror for Since zone (x < t, x' < t')

2. **Eliminated all inconsistency cases** (4 checks each):
   - Pairwise order contradictions (w vs x, w vs t, x vs t) are proved vacuously false
   - Anchor order consistency (ssn3's x-t order vs h_order_M/N) proved vacuously false

3. **Replaced original S3/S4 sorry** at former lines 413 and 491 with calls to the new helper lemmas

4. **Build succeeds** with 4 sorry (unchanged count, but reorganized):
   - Lines 274, 345: Between-zone cases in new helper lemmas (NEW)
   - Lines 460, 480: General-K sorry S1/S2 in `exist_transfer_3var_nonconstenv` (UNCHANGED - Phase 6)

## What Is Blocked

The between-zone depth-0 3-var existential transfer: given depth-2 1-var agreement at x/x' and t/t' with t < x, t' < x', and Prior-UZ/SZ, prove:

```
(exists w, t < w < x, predicates tau at w) <-> (exists w', t' < w' < x', predicates tau at w')
```

### Why It's Hard

The between-zone existential involves TWO anchor points (t and x) simultaneously. The available hypotheses give:
- From h_t (depth-2 1-var): transfer of temporal formulas of operator_depth <= 2 at t/t'
- From h_x (depth-2 1-var): transfer of temporal formulas of operator_depth <= 2 at x/x'

Using these separately:
- `Formula.untl psi top` at t (depth 2) transfers: exists w' > t' with preds tau in N
- `Formula.snce psi top` at x (depth 2) transfers: exists w' < x' with preds tau in N

But these give SEPARATE witnesses. The w' > t' might be >= x', and the w' < x' might be <= t'.

### What Was Tried

1. **Prior-UZ/SZ first/last occurrence**: Get first tau above t' (s0') and last tau below x' (u0'). If s0' < x' we're done. But s0' >= x' is consistent: all tau-points above t' are above x', and all below x' are below t'.

2. **cross_extend_bwd_1var from h_x**: Gets w'_x < x' with depth-1 2-var matching. The depth-0 3-var quantifier part at [_,w,x]/[_,w'_x,x'] was explored for forcing w'_x > t'. This doesn't follow from the available hypotheses.

3. **Temporal formula encoding the between-zone as 1-var formula**: Requires operator_depth > 2 (nested Until/Since), exceeding the depth-2 budget from h_t/h_x.

4. **Direct depth-1 2-var agreement from h_t quantifier part**: Gives `(exists y, nf_eval M 1 2 [y,t] ssn2) <-> (exists y', nf_eval N 1 2 [y',t'] ssn2)` which is about existentials over the FIRST variable of a 2-var NF, not the between-zone of a 3-var NF.

### Recommended Next Steps

1. **Research whether interval_nf_types matching follows from Prior + depth-2 1-var agreement**. The Stavi pipeline (StaviCompleteness.lean) requires interval_nf_types as a SEPARATE hypothesis. The Prior pipeline should derive it from Prior axioms, but the derivation is non-trivial.

2. **Consider using nf_characterizable_temporal_prior at depth 1** to express the between-zone existential as a temporal formula. The formula involves the depth-1 characteristic formulas (which have operator_depth <= 2), and the VecEA2 translation infrastructure from VecEADecomp.lean encodes the between-zone as a bracket witness in VecEA2.holds.

3. **Alternative: Restructure the base case entirely** to avoid the between-zone by using the KampBypass infrastructure (`existPart_succ_n1_bypass_k0`) which handles the depth-1 2-var existential via temporal formulas that bypass the zone decomposition.

## Key Files

- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorComposition.lean` — main file
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/VecEADecomp.lean` — zone decomposition infrastructure
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampBypass.lean` — bypass infrastructure
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` — parallel approach with interval_nf_types
