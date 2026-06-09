# Phase 1 Handoff: Generalized Zone Match and Matching Data

**Task**: 273
**Plan**: v12 (generalized existential transfer)
**Session**: sess_1781031097_68830a
**Status**: BLOCKED at Phase 1
**Date**: 2026-06-09

## Current State

Phase 1 is blocked at the zone matching extension property (Task 1.3). No code changes were committed -- the codebase is in its original state with the 2 sorry sites in StaviCompleteness.lean (lines 2353, 2435 in `nf_2var_existential_transfer` and line 2805 in `nf_exist_sf_guarded_backward`).

## Key Finding: The Zone Matching Extension Problem

The sorry at `nf_2var_existential_transfer` (lines 2353, 2435) requires showing existential transfer at depth j' for arity 4 given a 3-point configuration (u,x,t)/(u',x',t') with atom agreement at arity 3.

The plan proposes to prove this by strong induction on depth j, universally quantified over arity n. The proof structure is:

1. At depth 0: only atoms matter, zone matching gives atom agreement. Works.
2. At depth j+1: by `nf_fraisse_compression`, need atoms + existential transfer at depth j for arity n+1. Zone-match the new point w to w'. Need the EXTENDED config (w::env)/(w'::env') to have zone matching for the IH.

The obstacle: zone matching for the extended config requires orderings of NEW points relative to w' (and w). Zone matching relative to the ORIGINAL (x,t) pair gives orderings relative to x' and t' but NOT relative to w'. Two independently zone-matched points in the same interval zone may have inconsistent orderings.

## What Was Tried

1. **Direct zone matching extension**: Zone-match v using (x,t) data. Get v' with orderings relative to x', t'. Missing: v < w iff v' < w'. This cannot be derived because v and w could both be in the interval (x,t) with arbitrary relative ordering.

2. **Proof skeleton with `generalized_nf_equality`**: A theorem was coded and tested (compiles with 4 remaining sorries at the zone matching extension points). Reverted because it doesn't reduce the sorry count.

3. **Depth induction approaches**: Tried inducting on k (the bridge depth), on j (the target depth), and on k-j. All hit the same obstacle: at some point, orderings between zone-matched points are needed and cannot be derived from the original bridge data alone.

4. **Literature analysis (GHR93 Prop 7, GHR94 Prop 12.8.18)**: The literature resolves this via decomposition formula matching (Lemma 12.8.14 / Lemma 11). The containing-interval game strategy is used to find the matching point e, and the decomposition formula matching AUTOMATICALLY provides sub-interval game strategies. In NF terms, this corresponds to using 2-var interval types (which encode spatial arrangement) rather than 1-var interval types.

## Recommended Next Steps

### Option A: 2-var interval types (Recommended)

1. Redefine `matching_data` to use `interval_2var_nf_types` (already defined in the codebase at line 1847) for zone matching.
2. Zone-match using 2-var NFs relative to the interval endpoint: given w in (a,b), find w' in (a',b') with `nf_characteristic M k 2 (w :: b) = nf_characteristic M' k 2 (w' :: b')`.
3. The 2-var NF equality provides the interval splitting automatically via the quant part.
4. The bridge hypotheses need to be shown to imply `interval_2var_nf_types` matching. This requires either strengthening the hypotheses or proving derivability.

### Option B: Simultaneous induction on k

Prove `nf_2var_from_interval_data` by induction on k, where the IH at depth k provides 2-var NF equality, from which transfer at depth k-1 is extracted. The step from k to k+1 uses the IH to derive sub-interval data.

### Option C: Plan revision

Revise the plan to use a game-theoretic formulation that directly formalizes GHR93's decomposition formula approach.

## Files

- Plan: `specs/273_chronicle_gap_contradiction_proof/plans/12_generalized-transfer-plan.md` (updated with BLOCKER)
- Main file: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` (unchanged)
- Literature: `literature/Gabbay_Hodkinson_Reynolds_1993_Temporal_expressive_completeness_gaps.md` (Prop 7, pp 114-115)
- Literature: `literature/Gabbay_Hodkinson_Reynolds_1994_Temporal_Logic_Foundations_Vol1_ch12.md` (Prop 12.8.18, pp 26-27)
