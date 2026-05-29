# Phase 4 Partial Handoff - Task 202

## Session: sess_1748555900_orch202
## Date: 2026-05-29
## Status: Phase 4 partially completed (Task 4.3 done, Tasks 4.1-4.2, 4.4 remaining)

## What Was Accomplished

### Task 4.3: Prior-UZ/SZ Discharge (COMPLETED)
- Defined `effectiveFormula` in Transfer.lean: computes the formula whose MCS membership corresponds to `temporal_truth` under an arbitrary atomMap, even without the section property
- Proved `chronicle_temporal_truth_effective`: `temporal_truth M atomMap_fwd t psi <-> effectiveFormula atomMap_rev atomMap_fwd psi in fmcs(t)` for ALL formulas psi
- Proved `chronicle_semantic_prior_UZ` and `chronicle_semantic_prior_SZ`: semantic Prior-UZ/SZ hold for temporal_truth on the chronicle with ANY atomMap
- Modified `chronicle_is_good_direct` in ShiftAndGlue.lean: made Prior-UZ/SZ explicit parameters instead of internal sorry sites
- Updated call site in `countermodel_discrete_reynolds` (Transfer.lean) to provide Prior-UZ/SZ proofs
- Result: 2 sorry sites eliminated (ShiftAndGlue.lean:985, 991)

### Files Modified
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` (+227 lines, -1 sorry): Added effectiveFormula, chronicle_temporal_truth_effective, chronicle_semantic_prior_UZ, chronicle_semantic_prior_SZ
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/ShiftAndGlue.lean` (-55 lines, -2 sorry): chronicle_is_good_direct now takes Prior-UZ/SZ as parameters

### Build Status
- `lake build Bimodal.Metalogic.WeakCanonical.Transfer` succeeds
- `lake build Bimodal.Metalogic.WeakCanonical.IntegerModel.ShiftAndGlue` succeeds

## Remaining Sorry Sites on Critical Path

### 1. `no_gaps_discrete` (GoodStructures.lean:842) - BLOCKING
- Requires Reynolds Theorem 14 (Lemmas 6-13 model surgery argument)
- Full Reynolds proof: ~700-950 new lines
- Alternative approaches explored and ruled out:
  - Direct proof via succ-closure + archimedean: requires IsSuccArchimedean (sorry via succ_cofinal)
  - Direct proof via k-type partition: still requires no-gaps property
  - Simpler proof via convexity + Prior-UZ: works for archimedean case only
- The model surgery argument is the standard/only known proof for non-archimedean case

### 2. `countermodel_discrete_reynolds` packaging (Transfer.lean:1081) - BLOCKED BY #1
- Needs TaskFrame construction with truth_at <-> temporal_truth correspondence
- Singleton WorldState forced by TaskFrame nullity_identity axiom (S5 -> trivial task_rel -> Unit)
- With Unit WorldState: truth_at atoms are position-independent, temporal_truth atoms are position-dependent
- z_interval_countermodel's h_truth_corr requires universal formula correspondence (not achievable with Unit)
- Plan v7 Phase 5 explores alternatives but all hit the same fundamental issue
- May need the parametric BFMCS path (countermodel_discrete_enriched) which needs succ_embed_surjective

## Immediate Next Action

The blocking item is `no_gaps_discrete`. Two approaches:

### Approach A: Full Reynolds Model Surgery (Plan Phases 2-3)
- Implement Lemmas 6-13 in ReynoldsNoGaps.lean (~700 lines)
- Time estimate: 20+ hours
- High confidence of success (well-documented mathematical argument)

### Approach B: Bypass via succ_cofinal
- Prove `succ_cofinal` in ChronicleToCountermodel.lean (currently sorry at line 1508)
- This would make `IsSuccArchimedean` sorry-free
- Then `countermodel_discrete_enriched` works without `no_gaps_discrete`
- Avoids both sorry sites simultaneously
- But `succ_cofinal` is itself a deep theorem that multiple prior attempts have failed to prove

### Approach C: Alternative discrete countermodel construction
- Build countermodel directly from BFMCS without going through Z-interval compression
- Similar to dense case (countermodel_dense_enriched) but with Int
- Needs restricted_tc/fuc without succ_embed_surjective
- May be possible by defining FMCS families differently (avoiding succ_embed)

## Key Decisions Made
1. effectiveFormula approach (instead of section property parameter): cleaner, more general
2. Prior-UZ/SZ as parameters of chronicle_is_good_direct (instead of internal proof): separates concerns
3. Explored but rejected: simplifying no_gaps_discrete to avoid model surgery (mathematically impossible without archimedean or Prior-UZ structural argument)
