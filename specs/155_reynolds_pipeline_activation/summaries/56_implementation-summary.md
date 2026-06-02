# Implementation Summary: Task #155 (v56)

- **Task**: 155 - Fix no_gaps_discrete import cycle for sorry-free discrete completeness
- **Status**: [PARTIAL]
- **Plan**: specs/155_reynolds_pipeline_activation/plans/55_implementation-plan.md
- **Session**: sess_1748899200_orchestrate

## What Was Accomplished

### Phase 1: Resolve import cycle and close no_gaps_discrete [COMPLETED]

**Changes**:
- Removed `no_gaps_discrete` and `one_class` from `GoodStructures.lean` (eliminating the explicit sorry at line 855)
- Created `NoGapsDiscreteProof.lean` importing `GoodStructuresModelSurgery.lean`
- `no_gaps_discrete` delegates to `no_gaps_discrete_model_surgery` via `exact`
- `one_class` proved using `no_gaps_discrete` + `no_boundary_at_successor` + `contemp_equiv_is_equiv`
- `no_boundary_at_successor` kept in `GoodStructures.lean` (sorry-free, has downstream callers)

**Files modified**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructures.lean` (removed no_gaps_discrete, one_class; zero sorries)
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/NoGapsDiscreteProof.lean` (new; sorry-free delegation)

**Build**: `lake build` passes (1681 jobs, zero errors)

### Phase 2: Wire cascade to provide IsSuccArchimedean on LimitDomSubtype [BLOCKED]

Phase 2 could not be started due to a fundamental blocker discovered during Phase 1.

## Critical Discovery: Dual Sorry Chains

The research report (round 8) stated: "GoodStructuresModelSurgery.lean: 0 sorry statements (full model surgery complete)." While the file has no `sorry` keyword, investigation revealed it depends on `sorryAx` transitively through the Stavi completeness chain.

### Sorry chain 1: chronicle_gap_contradiction (blocks completeness_discrete)
```
completeness_discrete
  -> countermodel_discrete_reynolds
    -> cantor_bfmcs_discrete_restricted_tc/fuc (sorryAx)
      -> succ_embed_surjective (sorryAx)
        -> limitDomSubtype_isSuccArchimedean (sorryAx)
          -> succ_cofinal (sorryAx)
            -> chronicle_gap_contradiction (EXPLICIT SORRY)
```

### Sorry chain 2: Stavi completeness (blocks model surgery)
```
no_gaps_discrete_model_surgery (sorryAx)
  -> gap_contradicts_prior (sorryAx)
    -> ... (many internal lemmas)
      -> US_expressively_complete_over_prior (sorryAx)
        -> nf_characterizable_by_stavi (sorryAx)
          -> nf_2var_from_interval_data (3 EXPLICIT SORRIES in StaviCompleteness.lean)
```

### Why the plan's approach fails
The plan proposed using model surgery (`gap_contradicts_prior`) to prove `chronicle_gap_contradiction`. This would fix chain 1 but introduce chain 2 into `completeness_discrete`. The net result would still be `sorryAx` in `completeness_discrete`.

## Verification Results

| Check | Result |
|-------|--------|
| Sorry count in modified files | 0 |
| Vacuous definitions | 0 |
| New axioms | 0 |
| `lake build` | Passes (1681 jobs) |
| `#print axioms completeness_discrete` | Still shows `sorryAx` |
| `#print axioms no_gaps_discrete` | Shows `sorryAx` (Stavi chain) |
| `#print axioms no_boundary_at_successor` | No `sorryAx` (sorry-free) |

## Plan Deviations

- Phase 1 Task: Strategy A altered -- created `NoGapsDiscreteProof.lean` instead of `NoGapsDiscrete.lean`; removed both theorems entirely from `GoodStructures.lean` rather than leaving a sorry stub
- Phase 1 Verification: `#print axioms no_gaps_discrete` still shows `sorryAx` due to transitive Stavi dependency, contrary to plan expectation
- Phase 2: Blocked -- cannot use model surgery approach because it introduces Stavi sorry chain

## What Is Needed to Unblock

Three possible paths to sorry-free `completeness_discrete`:

1. **Prove `chronicle_gap_contradiction` directly** (no model surgery): Show that in the Burgess chronicle construction with discrete box-class, the succ-orbit of root covers the entire `LimitDomSubtype`. This requires a chronicle-specific argument about the stage-by-stage construction.

2. **Complete Stavi completeness** (3 sorries): Fix the 4-variable EF-game transfer and GHR bridge lemma in `StaviCompleteness.lean`. This would make model surgery sorry-free, enabling the cascade approach.

3. **Bypass `succ_embed_surjective`** entirely: Rewrite `cantor_bfmcs_discrete_restricted_tc` and `cantor_bfmcs_discrete_restricted_fuc` to avoid needing to convert arbitrary domain witnesses to integers. This would require a fundamentally different proof architecture.

## Artifacts

- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/NoGapsDiscreteProof.lean` (new, sorry-free delegation)
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructures.lean` (modified, zero sorries)
- `specs/155_reynolds_pipeline_activation/plans/55_implementation-plan.md` (updated phase markers)
- `specs/155_reynolds_pipeline_activation/handoffs/phase-1-handoff-20260602.md`
