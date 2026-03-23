# Implementation Summary: Task #988 Phase 1 Analysis

**Date**: 2026-03-18
**Status**: BLOCKED
**Session**: sess_1773948000_d7e2f1

## Overview

Phase 1 of plan v9 attempted to prove `timelineQuotFMCS_forward_F` and `timelineQuotFMCS_backward_P` using DovetailedCoverage's coverage lemmas. Analysis revealed a fundamental architectural gap that prevents this approach.

## Key Finding: Construction Mismatch

**TimelineQuot** is built from **DenseTimeline** (stagedBuild + density intermediates):
- Uses `stagedBuild` which processes formulas in encoding order
- All points at each stage processed for each formula
- Density intermediates added via `densityWitnessesForSet` (pair-wise)

**DovetailedBuild** uses a different enumeration:
- Uses Cantor pairing to process (point_index, formula_encoding) pairs
- Each pair processed exactly once in pairing order
- Coverage guaranteed by dovetailing

**No proven relationship** exists between `denseTimelineUnion` and `dovetailedTimelineUnion`.

## Analysis of Sorries in ClosureSaturation.lean

### Lines 659, 664, 679: timelineQuotFMCS_forward_F/backward_P

The proof structure for `forward_F`:
1. For point p with F(phi) in mcs(p), find encoding k = encode(phi)
2. Get stage n where p entered denseStage
3. Get stage m where p entered stagedBuild (if from base)

**Case A** (m <= 2k): Uses `forward_witness_at_stage_with_phi` - WORKS
- Formula phi is processed at stage 2k+1
- Point p was in stagedBuild at stage m <= 2k
- Witness containing phi is added and still present

**Case B** (m > 2k): BLOCKED (sorry at line 659)
- Point p was added AFTER formula phi was processed
- No witness containing phi was created for p
- `canonical_forward_F` creates a witness, but it's not in the timeline

**Case C** (density point): BLOCKED (sorry at line 664)
- Point p was added as density intermediate, not from stagedBuild
- P's F-obligations were never processed by stagedBuild
- No witness containing phi exists in the timeline

## Why Plan v9's Bridge Doesn't Work

Plan v9 assumed: "A witness that exists in the dovetailed timeline also exists in the dense timeline."

This is FALSE because:
1. Both constructions use Lindenbaum extension (non-constructive)
2. Even for the same seed, different calls produce different MCSs
3. DovetailedBuild and DenseTimeline/stagedBuild create DIFFERENT witness MCSs
4. There's no proven inclusion relationship between the timelines

## Potential Resolution Paths

### Path A: Modify DenseTimeline to Reprocess Formulas
Add a step after each density insertion that processes F/P-formulas for new points.
- **Complexity**: Significant changes to DenseTimeline.lean
- **Risk**: May break existing density proofs

### Path B: Use DovetailedBuild Exclusively
Replace TimelineQuot with DovetailedTimelineQuot throughout.
- **Issue**: DovetailedTimelineQuot has its own sorry for DenselyOrdered
- **Reason**: Same architectural gap - density_frame_condition creates MCSs not in the construction

### Path C: Prove Timeline Equivalence
Show `denseTimelineUnion = dovetailedTimelineUnion` (as sets of MCSs, ignoring indices).
- **Difficulty**: Very high - requires proving both constructions produce the same MCS family
- **Blocked by**: Non-constructive Lindenbaum extension

### Path D: Weaker Truth Lemma
Prove a forward-only truth lemma that doesn't require backward temporal cases.
- **Status**: Unclear if sufficient for completeness

### Path E: Axiom for Witness Inclusion
Introduce an axiom stating that canonical_forward_F's witness is in the timeline.
- **Trade-off**: Adds another axiom beyond canonicalR_irreflexive
- **Justification**: Mathematically sound but not mechanically verified

## Current State

| File | Sorries | Description |
|------|---------|-------------|
| ClosureSaturation.lean | 4 | forward_F (3), backward_P (1), modal_backward (1) |
| TimelineQuotCompleteness.lean | 1 | timelineQuot_not_valid_of_neg_consistent |
| TimelineQuotCanonical.lean | 1 | timelineQuotMCS_at_zero_eq_root |
| DovetailedTimelineQuot.lean | 1 | DenselyOrdered (has_intermediate) |

## Recommendation

The plan v9 approach is not viable without additional infrastructure. Recommended path:

1. **Short term**: Return `partial` status with documented gap
2. **Medium term**: Investigate Path A (modify DenseTimeline to reprocess)
3. **Long term**: Consider whether the stagedBuild enumeration can be replaced with dovetailing

## Files Analyzed

- `Theories/Bimodal/Metalogic/StagedConstruction/ClosureSaturation.lean`
- `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotCompleteness.lean`
- `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotCanonical.lean`
- `Theories/Bimodal/Metalogic/StagedConstruction/DovetailedCoverage.lean`
- `Theories/Bimodal/Metalogic/StagedConstruction/DovetailedBuild.lean`
- `Theories/Bimodal/Metalogic/StagedConstruction/DenseTimeline.lean`
- `Theories/Bimodal/Metalogic/StagedConstruction/CantorApplication.lean`
- `Theories/Bimodal/Metalogic/StagedConstruction/DovetailedTimelineQuot.lean`
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherence.lean`
- `Theories/Bimodal/Metalogic/Algebraic/ParametricTruthLemma.lean`
