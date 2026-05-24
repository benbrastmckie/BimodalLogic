# Implementation Summary: Task 155 - Reynolds Pipeline Activation

- **Task**: 155 - reynolds_pipeline_activation
- **Status**: [PARTIAL]
- **Started**: 2026-05-24T00:00:00Z
- **Completed**: 2026-05-24T01:00:00Z
- **Effort**: ~1 hour (Phase A1 feasibility analysis)
- **Artifacts**:
  - `specs/155_reynolds_pipeline_activation/plans/28_reynolds-pipeline-plan.md` (updated)
  - `specs/155_reynolds_pipeline_activation/progress/phase-A1-progress.json`

## Overview

Phase A1 of the Reynolds Pipeline Activation plan was executed as a deep feasibility analysis of Track A (OrderIso bypass for sorry-free `bx_completeness`). The analysis traced the full sorry chain from `bx_completeness` through `completeness_discrete`, `countermodel_discrete_enriched`, `dd_countermodel_chronicle_discrete`, `cantor_bfmcs_discrete_restricted_tc/fuc`, `succ_embed_surjective`, `limitDomSubtype_isSuccArchimedean`, to the root sorry at `succ_cofinal`. The conclusion is that Track A is not feasible with the current infrastructure.

## What Changed

- `specs/155_reynolds_pipeline_activation/plans/28_reynolds-pipeline-plan.md` — Phase A1 status updated from [NOT STARTED] to [COMPLETED], tasks marked with findings, infeasibility documented inline
- `specs/155_reynolds_pipeline_activation/progress/phase-A1-progress.json` — Created with full analysis results

## Decisions

- **Track A abandoned**: The OrderIso bypass strategy is not feasible because every path from the Burgess chronicle to a countermodel on Int requires `IsSuccArchimedean` for `LimitDomSubtype`, which is exactly the sorry in `succ_cofinal`.
- **Root sorry confirmed**: `succ_cofinal` (ChronicleToCountermodel.lean:1885) is a genuine mathematical gap. The constant-MCS gap scenario satisfies all temporal axioms and cannot be ruled out with the available infrastructure.
- **BUC is already sorry-free**: `cantor_bfmcs_discrete_restricted_buc` has no `sorryAx` — only TC and FUC are blocked.

## Impacts

- **Task 155 goal is blocked**: `bx_completeness` cannot be made sorry-free without either proving `succ_cofinal` or adopting an entirely different model construction (Task 129 Henkin model approach).
- **Both tracks blocked**: Track B (GHR93 pipeline) also requires sorry-free discrete completeness machinery and is similarly blocked at the same root sorry.
- **Track A bypass infeasibility**: The plan's assumption that `chronicle_is_good` provides a sorry-free bypass path is incorrect. `chronicle_is_good` is sorry-free but only when called on a `ChronicleAsPriorModel`, and `extract_chronicle_as_prior` (the only constructor from the Burgess chronicle) has `sorryAx` because it fills `domain_succ_archimedean := limitDomSubtype_isSuccArchimedean`.

## Follow-ups

- **Task 129**: The Henkin canonical model approach (weak/reflexive completeness + conservative extension) would bypass `succ_cofinal` entirely by using a model where `IsSuccArchimedean` holds by construction. This is the recommended next path.
- **succ_cofinal construction-level argument**: The omega-chain construction argument (deep interaction with `omega_chain_elim_result`, `BurgessR3Maximal`) might provide a sorry-free proof of `succ_cofinal`, but this is highly complex and was not pursued here.
- **z_interval_countermodel wiring (Phase 6)**: The Reynolds pipeline `z_interval_countermodel` theorem in `WeakCanonical/Transfer.lean` still needs a caller. Once `succ_cofinal` is resolved, the `h_truth_corr` obligation for the discrete case needs to be discharged.

## Sorry Chain (for reference)

```
bx_completeness
  └─ completeness_discrete (BXCanonical/Completeness.lean:270)
       └─ countermodel_discrete_enriched (BXCanonical/Completeness.lean:227) [sorry]
            └─ WeakCanonical.countermodel_discrete (WeakCanonical/Transfer.lean:481)
                 └─ dd_countermodel_chronicle_discrete (ChronicleToCountermodel.lean:3285)
                      ├─ cantor_bfmcs_discrete_restricted_tc [sorryAx]
                      │    └─ succ_embed_surjective [sorryAx]
                      │         └─ limitDomSubtype_isSuccArchimedean [sorryAx]
                      │              └─ succ_cofinal (ChronicleToCountermodel.lean:1885) [sorry]
                      ├─ cantor_bfmcs_discrete_restricted_fuc [sorryAx] (same chain)
                      └─ cantor_bfmcs_discrete_restricted_buc [sorry-FREE ✓]
```

## References

- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` — root sorry at line 1885
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` — sorry at line 227
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` — z_interval_countermodel (potential future path)
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel.lean` — chronicle_is_good (sorry-free)
- `Theories/Bimodal/Metalogic/WeakCanonical/ChronicleExtraction.lean` — extract_chronicle_as_prior (has sorryAx)
