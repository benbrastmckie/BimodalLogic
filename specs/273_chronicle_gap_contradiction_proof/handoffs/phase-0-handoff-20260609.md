# Phase 0 Handoff: Plan Analysis and Blocker Discovery

**Task**: 273
**Session**: sess_1781028711_17425a
**Date**: 2026-06-09

## Status

BLOCKED -- The plan (v11) has two fundamental architectural issues that prevent implementation as written.

## Blocker 1: Phase 4 (Wiring) is Unsound

The plan proposes replacing `stavi_expressive_completeness` with `discrete_stavi_expressive_completeness` in `US_expressively_complete_over_prior`. This fails because:

1. `US_expressively_complete_over_prior` (PriorExpressiveness.lean:384) returns a formula that must work for ALL Prior structures (models with `semantic_prior_UZ` and `semantic_prior_SZ`).
2. `discrete_stavi_expressive_completeness` only proves correctness for discrete models (with `SuccOrder`, `PredOrder`, `NoMaxOrder`, `NoMinOrder`, `IsSuccArchimedean`).
3. `US_expressively_complete_over_prior` is used in `gap_prior_UZ_contradiction` (GoodStructuresModelSurgery.lean:1266) for a sub-structure N that is a convex suborder of a discrete model. This sub-structure N does NOT have `IsSuccArchimedean`.
4. Adding `IsSuccArchimedean` to `US_expressively_complete_over_prior`'s hypotheses would break this usage, since the very purpose of `gap_prior_UZ_contradiction` is to show there are no gaps (which implies IsSuccArchimedean).

## Blocker 2: Phase 3 (Game Pipeline to NF) has a Gap

The plan's Phase 3 step 8 assumes `nf_fraisse_compression` can be applied after game wins. However:

1. `nf_fraisse_compression` requires `h_transfer : forall j < k, forall chi, (exists u, nf_eval M j (n+1) (u::env_M) chi) <-> (exists u', nf_eval M' j (n+1) (u'::env_M') chi)`.
2. The game pipeline produces `ghr93_duplicator_wins` (a game-theoretic result), not existential NF transfer.
3. Bridge B (NFGameBridge.lean:1198-1210) -- converting game wins to existential NF transfer -- is explicitly documented as BLOCKED in the codebase.
4. The comment at NFGameBridge.lean:1198 explains: "Full Bridge B is blocked because the game at n=0 only gives formula_agreement at 3 specific positions. Converting this to 4-variable existential transfer requires sub-interval splitting, which is the same problem the original proof faces."

## Sorry Chain Analysis

```
completeness_discrete (Completeness.lean:309)
  -> countermodel_discrete_reynolds_v2 (ReynoldsBridge.lean:724)
    -> limitdom_is_good -> ... -> no_gaps_discrete_model_surgery (GoodStructuresModelSurgery.lean:2133)
      -> gap_contradicts_prior (GoodStructuresModelSurgery.lean:2087)
        -> reynolds_model_surgery_core
          -> gap_prior_UZ_contradiction (GoodStructuresModelSurgery.lean:1169)
            -> US_expressively_complete_over_prior (PriorExpressiveness.lean:371)
              -> stavi_expressive_completeness (StaviCompleteness.lean:3188) [SORRY]
                -> nf_characterizable_by_stavi (StaviCompleteness.lean)
                  -> nf_exist_sf_guarded_backward (StaviCompleteness.lean:2778) [SORRY]
                    -> nf_2var_from_interval_data (StaviCompleteness.lean:2448)
                      -> nf_2var_existential_transfer (StaviCompleteness.lean:2214) [ROOT SORRY at lines 2353, 2435]
```

The ROOT cause is `nf_2var_existential_transfer` at lines 2353 and 2435 of StaviCompleteness.lean. These sorry sites are in the j>=1 case of the existential transfer, requiring 4-variable matching at depth j' for the 3-point configuration (u,x,t).

## Viable Alternative Approaches

### Approach A: Prove `nf_2var_existential_transfer` for General Models
- Close the sorry at StaviCompleteness.lean:2353,2435
- This would make the general `stavi_expressive_completeness` sorry-free
- ALL downstream theorems become sorry-free automatically
- Difficulty: Very high (~500+ lines). Requires solving the 4-var sub-interval matching problem.

### Approach B: Prove `discrete_nf_2var_existential_transfer`
- A discrete-only version using zone_match_witness + strong induction on j
- Makes `discrete_stavi_expressive_completeness` sorry-free
- Does NOT fix `US_expressively_complete_over_prior` (the Phase 4 blocker remains)
- Difficulty: High (~300-500 lines)

### Approach C: Restructure Reynolds Model Surgery
- Avoid using `US_expressively_complete_over_prior` for non-discrete sub-models
- Would require a fundamentally different proof of `gap_prior_UZ_contradiction`
- Difficulty: Unknown, potentially very high

### Approach D: Close General Sorry Chain via CaseAnalysis.lean
- Fix Cases III/IV gap detection (~8 sorry sites)
- Makes `ghr93_inductive_step` sorry-free, unblocking the general pipeline
- Difficulty: Very high (~500+ lines of gap detection logic)

## Recommendation

Approach A is the cleanest: prove `nf_2var_existential_transfer` for general models. This single fix makes the entire sorry chain collapse. However, it requires solving the deep 4-var sub-interval matching problem that has been open since the inception of the EF game infrastructure.

A revised plan should focus on Approach A, not the discrete bypass strategy.

## Key Files Analyzed

- `/home/benjamin/Projects/BimodalLogic/Theories/Bimodal/Metalogic/WeakCanonical/EFGames/DiscreteStaviCompleteness.lean` (sorry at line 338)
- `/home/benjamin/Projects/BimodalLogic/Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` (root sorry at lines 2353, 2435)
- `/home/benjamin/Projects/BimodalLogic/Theories/Bimodal/Metalogic/WeakCanonical/EFGames/NFGameBridge.lean` (Bridge B blocked at line 1198)
- `/home/benjamin/Projects/BimodalLogic/Theories/Bimodal/Metalogic/WeakCanonical/PriorExpressiveness.lean` (US_expressively_complete_over_prior at line 371)
- `/home/benjamin/Projects/BimodalLogic/Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructuresModelSurgery.lean` (gap_prior_UZ_contradiction at line 1169, uses US_expressively_complete_over_prior for non-discrete sub-model at line 1266)
