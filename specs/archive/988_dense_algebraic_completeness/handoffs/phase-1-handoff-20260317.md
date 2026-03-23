# Handoff: Phase 1 - CanonicalMCS Embedding Infrastructure

**Task**: 988 - Dense Algebraic Completeness
**Session**: sess_1742152800_988i
**Date**: 2026-03-17 (Updated after Iteration 2)
**Status**: BLOCKED - Architectural issue identified

## CRITICAL: Architectural Blocker Identified

**The TimelineQuot transfer approach CANNOT prove temporal coherence (forward_F/backward_P).**

### Root Cause Analysis (Iteration 2)

The `ratFMCS_forward_F` proof requires showing that for any F(phi) in timelineQuotMCS(t), there exists s > t with phi in timelineQuotMCS(s).

The existing theorems work as follows:
1. `canonical_forward_F` gives witness MCS W with phi in it
2. `forward_witness_at_stage_with_phi` puts W in the staged build at stage 2k+1 (where k = encode(phi))

**The Problem**: `forward_witness_at_stage_with_phi` requires the source point p to be at stage n <= 2k. If a point p arrives at stage n > 2k (which happens when p is created as a witness for some formula j where j > k), then the phi-specific witness is NOT automatically created.

The staged construction was designed for:
- NoMaxOrder (every point has SOME future)
- NoMinOrder (every point has SOME past)
- DenselyOrdered (intermediates exist)
- Countable

It was NOT designed for:
- Temporal coherence: every F(phi) has a phi-specific witness in the construction

### The Fundamental Gap

TimelineQuot is a SUBSET of CanonicalMCS (specifically, the antisymmetrization of DenseTimelineElem). The `canonical_forward_F` witness may lie OUTSIDE this subset.

CanonicalMCS has proven forward_F/backward_P (`canonicalMCS_forward_F`, `canonicalMCS_backward_P` in CanonicalFMCS.lean) because it contains ALL MCSs. But CanonicalMCS is a preorder, not a linear order, so it cannot be embedded into Rat.

## Options for Resolution (Requires User Decision)

### Option A: Modify Staged Construction
Enhance the staged construction to process F(phi) obligations for ALL arriving points, not just those present at stage 2k.
- **Pros**: Keeps the TimelineQuot transfer approach
- **Cons**: Significant changes to staged construction; may require omega-indexed processing

### Option B: Use CanonicalMCS Directly
Prove dense completeness using CanonicalMCS-based BFMCS (which has temporal coherence), then argue this implies completeness over Rat via semantic equivalence.
- **Pros**: Avoids staged construction modifications; canonicalMCS_forward_F already proven
- **Cons**: Need to establish semantic equivalence between CanonicalMCS models and Rat models

### Option C: Semantic Argument
Prove temporal coherence for TimelineQuot via semantic arguments (soundness/completeness of the logic) rather than relying on staged construction witness tracking.
- **Pros**: More abstract, potentially cleaner
- **Cons**: May require significant new infrastructure

### Option D: Abandon Task 988
Accept that TimelineQuot approach doesn't provide temporal coherence; focus on alternative completeness strategies.
- **Pros**: Avoid further effort on blocked path
- **Cons**: Dense completeness via this approach remains unproven

## What NOT to Try

1. **Simple encoding tricks**: The n <= 2k constraint is fundamental to how the staged construction processes formulas
2. **Tracing F(phi) through processForwardObligation**: The Lindenbaum extension in executeForwardStep can add arbitrary formulas, not just those from the source
3. **Assuming witness MCS uniqueness**: Different calls to lindenbaumMCS_set on the same seed may yield different MCSs

## Current State (Unchanged)

**File**: `Theories/Bimodal/Metalogic/Algebraic/CanonicalEmbedding.lean`
**Sorries**: 5 remain (ratFMCS_forward_F, ratFMCS_backward_P, modal_backward, ratFMCS_root_eq, construct_bfmcs_rat_for_root)

## Key Files Reviewed in Iteration 2

- `CantorPrereqs.lean`: `forward_witness_at_stage_with_phi` (requires n <= 2k)
- `CanonicalFMCS.lean`: `canonicalMCS_forward_F` (proven, uses ALL MCSs)
- `DenseTimeline.lean`: `dense_timeline_has_future` (gives SOME future, not phi-specific)
- `ClosureSaturation.lean`: `timelineQuotFMCS_forward_F` (also has sorry at same location)

## References

- **Plan**: `specs/988_dense_algebraic_completeness/plans/implementation-001.md`
- **CanonicalFMCS**: `Theories/Bimodal/Metalogic/Bundle/CanonicalFMCS.lean` (has proven temporal coherence)
- **Staged execution**: `Theories/Bimodal/Metalogic/StagedConstruction/StagedExecution.lean`
- **CantorPrereqs**: `Theories/Bimodal/Metalogic/StagedConstruction/CantorPrereqs.lean` (forward_witness_at_stage_with_phi)
