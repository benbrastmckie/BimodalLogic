# Bridge Analysis Handoff

**Date**: 2026-05-28
**Session**: NF-Game Bridge Analysis
**Status**: Partial - helpers built, full bridge architecture documented

## What Was Done

1. **Exhaustive analysis of the sub-interval splitting problem** confirming that:
   - The 3 sorries in StaviCompleteness.lean (lines 2347, 2429, 2787) all stem from the same root cause
   - The direct NF induction approach CANNOT work because sub-interval types are not determined by full-interval types
   - No refactoring of the existing approach (strong induction, variable threading, etc.) can overcome this

2. **Created NFGameBridge.lean** (`Theories/Bimodal/Metalogic/WeakCanonical/EFGames/NFGameBridge.lean`):
   - 173 lines, sorry-free, builds cleanly
   - Helper lemmas: `nf_agreement_from_nf_char_eq`, `nf_char_eq_implies_stavi_char_agree`, `pred_agree_from_nf_char`, `nf_char_depth_le`, `nvar_nf_eq_depth_zero`, `atom_agree_from_pointwise_nf`, `nvar_nf_eq_depth_zero_from_pointwise`
   - These are the building blocks for Bridge A and Bridge B

## Root Cause Analysis

### The Sub-Interval Problem (Definitive)

The sorry at line 2347 needs:
```
(exists w', nf_eval_nf M' j' 4 (w'::u'::x'::t') sub_nf) <->
(exists w, nf_eval_nf M j' 4 (w::u::x::t) sub_nf)
```

Zone matching finds w' with matching 1-var NF and orderings. But the 4-var NF requires sub-interval types for pairs (w,u), (u,x), etc. These are sub-intervals of (x,t), and:

**A type realized in (x,t) at depth k might only appear in (u,t) but not in (x,u).**

No amount of strong induction, IH threading, or reformulation can overcome this within the pure NF framework. The information about which types appear in which sub-interval is lost when we record only the SET of types in the full interval.

### Why the Game Works

The game (Composition.lean, Decomposition.lean) handles sub-intervals because:
1. Spoiler picks a point a splitting [x,y] into [x,a] and [a,y]
2. Duplicator responds with a' splitting [x',y'] into [x',a'] and [a',y']
3. The game's compositional structure (`ghr93_strategy_compose`) gives winning strategies for BOTH sub-intervals
4. This automatically propagates type information to sub-intervals

## Architecture for the Full Bridge

### Bridge A: NF hypotheses -> decomposition_agreement (n=0)

`decomposition_agreement` at n=0 requires:
- `rank_type` agreement at boundary points x,y / x',y'
- Point challenge: for any actual point b' in [x',y'], find b in [x,y] with `ghr93_winning_condition`

**Connection needed**: `rank_type M atomMap r (extendPoint x)` is the set of StaviFormulas A with `stavi_depth A <= r` true at x under mu-relativization. At actual points, `stavi_truth_mu_at_point` gives `stavi_temporal_truth_mu ... (extendPoint x) A <-> stavi_temporal_truth ... x A`.

So `rank_type` agreement at actual points = StaviFormula agreement at depth <= r. From `char_k_correct` (the Stavi completeness IH), NF agreement at depth k implies StaviFormula agreement for all characteristic formulas.

**Key subtlety**: `rank_type` uses `stavi_temporal_truth_mu` on `ExtendedCarrier`, while NFs use `MonadicFormula` on M.carrier. The connection goes through:
1. `nf_determines_stavi_truth` (Claim1.lean): same NF at depth 2*r over muSig -> same StaviFormula truth at depth <= r
2. `stavi_truth_mu_at_point` (GapDetection.lean): mu-relativized truth at actual points = standard truth

**Implementation estimate**: ~150 lines

### Bridge B: ghr93_duplicator_wins -> NF agreement

Game winning at n=0 with rank r gives formula agreement at all positions in the game tuple. At boundary positions (x,t) and (x',t'), this gives:
```
forall A, stavi_depth A <= r ->
  stavi_temporal_truth_mu M atomMap r (extendPoint x) A <->
  stavi_temporal_truth_mu M' atomMap r (extendPoint x') A
```

Via `stavi_truth_mu_at_point`, this becomes StaviFormula agreement on the base structures. Via `nf_determines_stavi_truth`, this gives NF agreement (at appropriate depth).

For the 2-var NF equality, we need game winning at n >= 1 (to get interior point matching). The composition lemma then gives sub-interval matching automatically.

**Implementation estimate**: ~150 lines

### Integration: Replacing the sorries

Once Bridges A and B are implemented:

1. `nf_2var_from_interval_data` can be reproved by:
   - Convert NF hypotheses -> decomposition_agreement (Bridge A)
   - Apply `ghr93_decomposition_implies_game` (already sorry-free)
   - Convert game winning back -> NF equality (Bridge B)

2. This makes `nf_2var_existential_transfer` unnecessary (its sorries are bypassed)

3. `nf_exist_sf_guarded_backward` (line 2787) can be proved by:
   - Extract witness x from the formula
   - Use `nf_2var_from_interval_data` to get 2-var NF equality
   - Conclude nf_eval_nf for sub_nf

## Immediate Next Action

Start implementing Bridge A: the conversion from NF hypotheses to `decomposition_agreement`. The key steps are:

1. Define `nf_to_rank_type_agree`: show that depth-k 1-var NF agreement implies `rank_type` agreement at rank r (for appropriate r related to k via the game_depth function and `stavi_table_mu_depth`)

2. Define `nf_to_interval_types_agree`: show that `interval_nf_types M k lo hi` agreement implies game-world `interval_types M atomMap r (extendPoint lo) (extendPoint hi)` agreement

3. Compose these into `nf_hyp_to_decomposition_agreement`: the full conversion

The starting point file is `NFGameBridge.lean`. The imports needed are `Decomposition.lean` and `GapDetection.lean` (already imported), plus `Claim1.lean` for `nf_determines_stavi_truth`.

## Files Modified

- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/NFGameBridge.lean` (NEW, sorry-free)

## Sorry Count

Unchanged: 3 sorries in StaviCompleteness.lean (lines 2347, 2429, 2787)
No new sorries introduced.
