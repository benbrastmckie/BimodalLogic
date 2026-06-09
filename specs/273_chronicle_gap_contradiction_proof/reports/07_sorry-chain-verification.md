# Sorry Chain Verification: completeness_discrete

## Summary

**Key Finding**: The sorry at `nf_exist_sf_guarded_backward` (StaviCompleteness.lean:2805) IS on the critical path of `completeness_discrete`. The axiom audit comment claiming the sorry traces through `chronicle_gap_contradiction` is OUTDATED.

There is exactly ONE sorry chain affecting `completeness_discrete`, not two independent chains.

## lean_verify Results

### Primary Chain (completeness_discrete)

| Theorem | File | sorryAx? | Notes |
|---------|------|----------|-------|
| `completeness_discrete` | Completeness.lean:309 | YES | Top-level target |
| `countermodel_discrete_reynolds_v2` | ReynoldsBridge.lean:724 | YES | Called at line 369 |
| `limitdom_is_good` | ReynoldsBridge.lean:346 | YES | Called at line 749 |
| `no_gaps_discrete_model_surgery` | GoodStructuresModelSurgery.lean:2133 | YES | Called at line 361 |
| `gap_prior_UZ_contradiction` | GoodStructuresModelSurgery.lean:1169 | YES | Called at line 2101 |
| `gap_prior_SZ_contradiction` | GoodStructuresModelSurgery.lean:2012 | YES | Delegates to UZ version |
| `reynolds_model_surgery_core` | GoodStructuresModelSurgery.lean:2058 | YES | Calls both UZ and SZ |
| `US_expressively_complete_over_prior` | PriorExpressiveness.lean:371 | YES | Called at line 1266 |
| `stavi_expressive_completeness` | StaviCompleteness.lean:3188 | YES | Called at line 384 |
| `nf_characterizable_by_stavi` | StaviCompleteness.lean:3078 | YES | Called at line 3198 |
| `nf_2var_existence_characterizable` | StaviCompleteness.lean:2847 | YES | Called at line 3102 |
| `nf_2var_exist_sf_classical` | StaviCompleteness.lean:2810 | YES | Called at line 3057 |
| `nf_exist_sf_guarded_backward` | StaviCompleteness.lean:2778 | YES | **ROOT SORRY** (line 2805) |

### Sorry-Free Components on the Path

| Theorem | File | sorryAx? |
|---------|------|----------|
| `mcs_mixed_case_absurd` | ChronicleToCountermodel.lean:2222 | NO |
| `one_class_implies_very_good` | ShiftAndGlue.lean:918 | NO |
| `very_good_implies_good` | ShiftAndGlue.lean:830 | NO |
| `limitdom_root_neg_truth` | ReynoldsBridge.lean:578 | NO |
| `nf_exist_sf_guarded_forward` | StaviCompleteness.lean:2643 | NO |
| `effectiveFormula_id_of_sub` | ReynoldsBridge.lean:382 | NO |
| `cantor_bfmcs_discrete_restricted_buc` | ChronicleToCountermodel.lean:1961 | NO |

### Declarations NOT on completeness_discrete Path

| Theorem | File | sorryAx? | Why Not on Path |
|---------|------|----------|-----------------|
| `chronicle_gap_contradiction` | ChronicleToCountermodel.lean:523 | YES | Used by deprecated `countermodel_discrete` (not v2) |
| `countermodel_discrete_reynolds` | Transfer.lean:1203 | YES | Used by general `completeness`, not `completeness_discrete` |
| `cantor_bfmcs_discrete_restricted_tc` | ChronicleToCountermodel.lean:2037 | YES | Used by `countermodel_discrete_reynolds`, not v2 |
| `cantor_bfmcs_discrete_restricted_fuc` | ChronicleToCountermodel.lean:2093 | YES | Same as above |
| `nf_2var_existential_transfer` | StaviCompleteness.lean:2214 | YES | Used only by `nf_2var_from_interval_data` -> `nf_2var_transfer` (dead end) |
| `nf_2var_from_interval_data` | StaviCompleteness.lean:2448 | YES | Not on stavi_expressive_completeness path |
| `nf_2var_transfer` | StaviCompleteness.lean:2524 | YES | Not used by anything on the critical path |

## Full Sorry Chain (completeness_discrete)

```
completeness_discrete (Completeness.lean:309)
  |-- countermodel_discrete_reynolds_v2 (ReynoldsBridge.lean:724)
        |-- limitdom_is_good (ReynoldsBridge.lean:346)
              |-- no_gaps_discrete_model_surgery (GoodStructuresModelSurgery.lean:2133)
                    |-- gap_prior_UZ_contradiction (GoodStructuresModelSurgery.lean:1169)
                          |-- invariant_formula_constant (local have, line 1259)
                                |-- US_expressively_complete_over_prior (PriorExpressiveness.lean:371)
                                      |-- stavi_expressive_completeness (StaviCompleteness.lean:3188)
                                            |-- nf_characterizable_by_stavi (StaviCompleteness.lean:3078)
                                                  |-- nf_2var_existence_characterizable (StaviCompleteness.lean:2847)
                                                        |-- nf_2var_exist_sf_classical (StaviCompleteness.lean:2810)
                                                              |-- nf_exist_sf_guarded_backward *** SORRY ***
                                                              |-- nf_exist_sf_guarded_forward (sorry-free)
```

## Key Answers

### Q1: Does `nf_exist_sf_guarded_backward` appear in the sorryAx chain of `completeness_discrete`?

**YES.** The chain is:
`completeness_discrete` -> `countermodel_discrete_reynolds_v2` -> `limitdom_is_good` -> `no_gaps_discrete_model_surgery` -> `gap_prior_UZ_contradiction` -> `US_expressively_complete_over_prior` -> `stavi_expressive_completeness` -> `nf_characterizable_by_stavi` -> `nf_2var_existence_characterizable` -> `nf_2var_exist_sf_classical` -> `nf_exist_sf_guarded_backward` -> sorry.

The connection point is `gap_prior_UZ_contradiction` (GoodStructuresModelSurgery.lean:1169), which has a local `have invariant_formula_constant` (line 1259) that calls `US_expressively_complete_over_prior` (line 1266) to show that contemp_equiv-invariant formulas are constant. This requires the full Stavi expressive completeness machinery.

### Q2: Does `US_expressively_complete_over_prior` carry sorryAx?

**YES.** It calls `stavi_expressive_completeness` at PriorExpressiveness.lean:384, which transitively depends on `nf_exist_sf_guarded_backward`.

### Q3: Are there two independent sorry chains?

**NO.** There is only ONE sorry chain for `completeness_discrete`. The `chronicle_gap_contradiction` sorry is NOT on the `completeness_discrete` path. The axiom audit comment at Completeness.lean:388 is outdated -- it was written before `countermodel_discrete_reynolds_v2` replaced the old `countermodel_discrete_enriched` path.

`chronicle_gap_contradiction` has 4 sorry instances (lines 531, 545, 786, 806) but these are used only by `succ_cofinal` -> `limitDomSubtype_isSuccArchimedean`, which feeds into the DEPRECATED `countermodel_discrete` (Transfer.lean:1283). The current `completeness_discrete` uses `countermodel_discrete_reynolds_v2` which bypasses this entire chain.

### Q4: Exactly which sorries need to be eliminated?

To make `completeness_discrete` sorry-free, exactly ONE sorry must be eliminated:

**`nf_exist_sf_guarded_backward`** (StaviCompleteness.lean:2805)

This is the backward direction of the guarded existence formula: given that the Stavi temporal formula holds at t, extract a witness x such that nf_eval_nf holds for the 2-variable normal form. The proof sketch (lines 2795-2804) requires the GHR93 bridge lemma (`nf_2var_from_interval_data`), which itself has 2 sorries in `nf_2var_existential_transfer`.

**Alternative path**: The discrete-only version in DiscreteStaviCompleteness.lean (`discrete_nf_characterizable_by_stavi`) also has a sorry at line 338 with the same essential blocker. If a discrete-only proof of the backward direction could be achieved (e.g., via the game pipeline), then `US_expressively_complete_over_prior` could be replaced with a discrete-specific version, avoiding the general `stavi_expressive_completeness` sorry entirely.

## Sorry Inventory Summary

### Sorries on `completeness_discrete` critical path: 1
1. `nf_exist_sf_guarded_backward` (StaviCompleteness.lean:2805)

### Sorries in the codebase but NOT on `completeness_discrete` path: 5
1. `chronicle_gap_contradiction` (ChronicleToCountermodel.lean:531) -- 4 sorry instances
2. `nf_2var_existential_transfer` (StaviCompleteness.lean:2353) -- forward case
3. `nf_2var_existential_transfer` (StaviCompleteness.lean:2435) -- backward case
4. `discrete_nf_characterizable_by_stavi` (DiscreteStaviCompleteness.lean:338) -- not used yet

### Strategic Observation

The `gap_prior_UZ_contradiction` proof (GoodStructuresModelSurgery.lean:1169-1408) uses `US_expressively_complete_over_prior` ONLY to prove `invariant_formula_constant` (line 1259): that any contemp_equiv-invariant monadic FO formula is constant on M. If this lemma could be proved WITHOUT Stavi expressive completeness (e.g., by a direct argument on the ordered structure M), then the entire Stavi sorry chain would be decoupled from `completeness_discrete`.

However, this appears to be the mathematically essential step: the Stavi completeness theorem (GHR93 9.3.1) is precisely the tool that converts between monadic FO formulas and temporal formulas, enabling the prior-UZ/SZ transition-point arguments.
