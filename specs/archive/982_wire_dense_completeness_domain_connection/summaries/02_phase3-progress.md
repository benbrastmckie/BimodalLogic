# Implementation Progress Summary: Task 982 Phase 3

**Date**: 2026-03-17
**Status**: Phase 4 BLOCKED

## Completed Work

### Phase 1: Dovetailing Infrastructure [COMPLETED]
- Cantor pairing wrappers (dovetailPair, dovetailUnpair)
- ProcessObligation structure
- obligationAtStep, stepForObligation
- forall_obligation_eventually_processed theorem
- All proofs verified, no sorries

### Phase 2: DovetailedBuild.lean [COMPLETED]
- DovetailedPoint structure with point_index
- DovetailedBuildState state machine
- dovetailedStep, dovetailedBuild functions
- Monotonicity proofs (dovetailedBuild_monotone, dovetailedBuild_monotone_le)
- dovetailedTimelineUnion definition
- Countability proof (dovetailedTimeline_countable)

### Phase 3: Timeline Properties [COMPLETED]
- Linearity proofs (dovetailedBuild_linear, dovetailedTimeline_linearly_ordered)
- Point index invariant infrastructure:
  - pointIndexInvariant definition
  - initialState_pointIndexInvariant
  - addPoint_pointIndexInvariant
  - processForwardObligationDovetailed_pointIndexInvariant
  - processBackwardObligationDovetailed_pointIndexInvariant
  - processObligationsDovetailed_pointIndexInvariant
  - processDensityDovetailed_pointIndexInvariant
  - dovetailedStep_pointIndexInvariant
  - dovetailedBuildState_pointIndexInvariant
- Key lookup lemma: getPointAt_of_mem
- Helper theorems for witness addition:
  - processForwardObligationDovetailed_adds_witness
  - dovetailedStep_adds_witness_when_processed

## Blocking Issue: Phase 4 Coverage Gap

### Problem Description
The dovetailing construction has a coverage gap:
- When point p enters at step s with point_index L
- And pair(L, k) < s for some formula encoding k
- The obligation (L, k) was processed at step pair(L, k) when p did not exist
- Therefore F(phi) with encoding k was never processed for p

### Analysis
This happens because:
1. Point indices are assigned based on list length at entry time
2. The list can grow slowly (few points added per step)
3. If point index L is small but point enters late, pair(L, k) may already have passed

### Recommended Resolution: Density Argument
Use the density axiom F(phi) -> F(F(phi)):
- F^i(neg bot) is in every MCS for all i
- Encodings of F^i(neg bot) grow without bound
- For large enough i, pair(L, encoding_i) > s
- At that step, p is in build and gets processed

### Files Modified
- `Theories/Bimodal/Metalogic/StagedConstruction/DovetailedBuild.lean`
  - Added ~50 lines of invariant infrastructure
  - Added helper lemmas for witness addition
  - Two sorries remain (dovetailedTimeline_has_future, dovetailedTimeline_has_past)

### Build Status
- `lake build` passes with warnings only
- No new axioms introduced
- Two sorries in DovetailedBuild.lean (Phase 4 scope)

## Next Steps

1. Implement density-based argument for coverage:
   - Prove encoding growth lemma
   - Show existence of large-encoding formula in p.mcs
   - Complete has_future/has_past proofs

2. Or consider alternative approaches:
   - Construction modification to re-process obligations
   - Different enumeration (step, formula) instead of (point_index, formula)

## Artifacts
- Theories/Bimodal/Metalogic/StagedConstruction/Dovetailing.lean
- Theories/Bimodal/Metalogic/StagedConstruction/DovetailedBuild.lean
- specs/982_wire_dense_completeness_domain_connection/plans/10_full-dovetailing.md (updated with blocking issue)
