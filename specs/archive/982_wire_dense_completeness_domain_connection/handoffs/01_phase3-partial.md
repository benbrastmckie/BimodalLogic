# Handoff: Task 982 Dovetailing Implementation - Phase 3 Partial

**Date**: 2026-03-17
**Session ID**: sess_1773793904_121124
**Phase**: 3 (Partial)

## Completed Work

### Phase 1: Dovetailing Infrastructure (COMPLETE)
- Created `Theories/Bimodal/Metalogic/StagedConstruction/Dovetailing.lean`
- Cantor pairing wrappers: `dovetailPair`, `dovetailUnpair`
- `ProcessObligation` structure with `point_index` and `formula_encoding`
- `obligationAtStep` and `stepForObligation` functions
- Key theorem: `forall_obligation_eventually_processed`
- All proofs complete, no sorries

### Phase 2: Dovetailed Staged Build (COMPLETE)
- Created `Theories/Bimodal/Metalogic/StagedConstruction/DovetailedBuild.lean`
- `DovetailedPoint` structure with explicit point index
- `DovetailedBuildState` state machine
- `processObligationsDovetailed`, `processDensityDovetailed`
- `dovetailedStep`, `dovetailedBuildState`, `dovetailedBuild`
- Monotonicity theorems proven without sorry
- `dovetailedTimelineUnion` definition
- `dovetailedTimeline_countable` proven

### Phase 3: Linearity and Density (PARTIAL)
- Added linearity infrastructure to DovetailedBuild.lean
- `dovetailedPoint_le_of_mcs_comparable` proven
- `dovetailedBuild_linear` proven (depends on root comparability)
- `dovetailedTimeline_linearly_ordered` proven (depends on above)

## Remaining Sorries

### 1. `dovetailedBuildState_all_comparable_with_root` (line ~539)
**Goal**: Show that all points added at step n+1 are MCS-comparable with root

**Context**:
- `point` is in the build at step n and is comparable with root (IH)
- `p` is a new point added at step n+1 from processing `point` with formula `phi`
- `p` is either a forward witness, backward witness, or density witness from `point`

**Strategy**:
```lean
-- Case split on which witness p is
-- For forward witness:
have h_F : phi.some_future ∈ point.mcs := by split at hp; exact ...
exact forwardWitness_comparable_with_root_dovetailed ... h_point_comp
-- For backward witness: similar
-- For density witness: similar
```

**Difficulty**: Complex case analysis on the nested if-then-else structure

### 2. `dovetailedTimeline_has_future` (line ~621)
**Goal**: Show every point has a CanonicalR-future in the timeline

**Strategy**:
- Use seriality: F(neg bot) is in every MCS
- Show the forward witness for F(neg bot) is eventually added via dovetailing
- Key: use `forall_obligation_eventually_processed` with point's index and F(neg bot)'s encoding

### 3. `dovetailedTimeline_has_past` (line ~632)
**Goal**: Show every point has a CanonicalR-past in the timeline
**Strategy**: Symmetric to has_future using P(neg bot)

## Next Steps

1. Complete `dovetailedBuildState_all_comparable_with_root`:
   - Need to case split on the `hp` membership
   - Use `forwardWitness_comparable_with_root_dovetailed`, `backwardWitness_comparable_with_root_dovetailed`, `densityWitness_comparable_with_root_dovetailed`

2. Complete `dovetailedTimeline_has_future`:
   - Key insight: point at index p with F(phi) where phi has encoding k
   - At step `Nat.pair p k`, this obligation is processed
   - The forward witness is added to the timeline

3. Continue to Phase 4-6:
   - DovetailedForwardF.lean: Prove forward_F coverage theorem
   - DovetailedBackwardP.lean: Prove backward_P
   - DovetailedTimelineQuot.lean: Antisymmetrization and FMCS
   - DovetailedCompleteness.lean: Wire completeness theorem

## Build Status
- `lake build Bimodal.Metalogic.StagedConstruction.DovetailedBuild` succeeds
- 3 sorries remaining in DovetailedBuild.lean
- All other proofs complete

## Key Files
- `Theories/Bimodal/Metalogic/StagedConstruction/Dovetailing.lean` (COMPLETE)
- `Theories/Bimodal/Metalogic/StagedConstruction/DovetailedBuild.lean` (3 sorries)
