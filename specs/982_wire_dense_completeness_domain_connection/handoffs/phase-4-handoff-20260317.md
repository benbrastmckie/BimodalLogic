# Phase 4 Handoff: Closure-Saturated BFMCS Construction

**Task**: 982 - Wire dense completeness domain connection
**Phase**: 4 (Closure-Saturated BFMCS Construction)
**Status**: PARTIAL
**Session**: sess_1773773089_a7e2f9
**Date**: 2026-03-17

## Immediate Next Action

Prove `timelineQuotFMCS_forward_F` by connecting `canonical_forward_F`'s witness to the staged timeline via `forward_witness_at_stage`.

## Current State

**File**: `Theories/Bimodal/Metalogic/StagedConstruction/ClosureSaturation.lean`
**Line**: 262 (sorry in `timelineQuotFMCS_forward_F`)

**Goal state**: Need to show that the witness MCS from `canonical_forward_F` is in the TimelineQuot and at a strictly greater time.

## What Was Accomplished

1. Added `timelineQuotFMCS_forward_F` theorem signature (sorry remains)
2. Added `timelineQuotFMCS_backward_P` theorem signature (sorry remains)
3. Added `timelineQuotSingletonBFMCS` structure (modal_backward sorry)
4. Added `timelineQuotSingletonBFMCS_temporally_coherent` theorem

## Key Decisions Made

### Decision 1: Constant Witness Families Are Flawed

The plan (v5) suggested using constant FMCS (same MCS at every time) for witness families. Analysis revealed this is fundamentally flawed:

- **Issue**: If F(phi) in M but phi not in M, then constant family with MCS=M cannot satisfy forward_F
- **Evidence**: ModalSaturation.lean:193-209 explicitly warns against constant witness families
- **Counterexample**: {F(psi), neg(psi)} is consistent but violates forward_F for constant family

### Decision 2: Singleton BFMCS Cannot Satisfy modal_backward

For a singleton BFMCS:
- `modal_forward` is trivial (T-axiom: Box phi -> phi)
- `modal_backward` requires: phi in mcs(t) -> Box phi in mcs(t)
- This is FALSE in general (not every formula has its Box)

### Decision 3: Need Multi-Family Saturation

Correct approach requires:
1. Build witness families that are NOT constant but follow TimelineQuot structure
2. Each witness family rooted at a Lindenbaum-extended MCS
3. Use `saturated_modal_backward` (already proven axiom-free)

## What NOT to Try

1. **Constant witness families** - Do not attempt this; fundamentally blocked by temporal coherence
2. **Singleton BFMCS for modal_backward** - Cannot be proven without saturation
3. **Direct proof of modal_backward** - Requires saturation infrastructure

## Critical Context

### forward_F Proof Strategy

1. `F(phi) in timelineQuotMCS(t)` gives F formula in an MCS
2. `canonical_forward_F` provides witness W with CanonicalR(t.mcs, W) and phi in W
3. `forward_witness_at_stage` shows W is in stagedBuild at stage 2k+1
4. Witness W becomes a TimelineQuot element s
5. By `canonicalR_implies_timelineQuot_le` + irreflexivity: t < s strictly
6. phi in timelineQuotMCS(s) because W is the MCS at s

### Key Theorems to Use

- `canonical_forward_F` (CanonicalFrame.lean:122-137)
- `forward_witness_at_stage` (CantorPrereqs.lean:467-502)
- `canonicalR_implies_timelineQuot_le` (TimelineQuotCanonical.lean:205-254)
- `canonicalR_irreflexive` (CanonicalIrreflexivityAxiom.lean)

## References

- Plan: `specs/982_wire_dense_completeness_domain_connection/plans/implementation-005.md`
- Research: `specs/982_wire_dense_completeness_domain_connection/reports/research-007.md`
- ClosureSaturation.lean: Lines 220-270 (forward_F theorem)
- CantorPrereqs.lean: Lines 467-502 (forward_witness_at_stage)
