# Phase 1 Analysis: ClosureSaturation.lean Sorries

**Date**: 2026-03-17
**Task**: 988 - dense_algebraic_completeness
**Session**: sess_1773792880_132dac

## Executive Summary

Phase 1 is **BLOCKED**. The 4 sorries in ClosureSaturation.lean represent fundamental architectural gaps that cannot be resolved with existing infrastructure. Full resolution requires the dovetailing approach from task 982 plan v10.

## Sorries Analyzed

### 1. Line 659: `timelineQuotFMCS_forward_F` (m > 2k case)

**Goal**: Show F(phi) witness exists when point enters at stage m > 2k (where k = encode(phi))

**Issue**: The staged construction processes formula phi at stage 2k+1. Points entering at stage m > 2k+1 miss having their F(phi) obligations processed. The code comments (lines 378-659) explain this in detail.

**Why Not Fixable**: The current architecture has no mechanism to ensure F(phi) witnesses for late-entering points. The "witnesses beget witnesses" idea requires g_content transfer, but F(phi) doesn't transfer via g_content (only G-shaped formulas do).

### 2. Line 664: `timelineQuotFMCS_forward_F` (density point case)

**Goal**: Show F(phi) witness exists when p is a density intermediate point

**Issue**: Density points are inserted for DenselyOrdered property, not for F-witness obligations. They may have F(phi) in their MCS without corresponding witnesses in the timeline.

**Why Not Fixable**: Same as line 659 - no existing mechanism ensures these witnesses exist.

### 3. Line 679: `timelineQuotFMCS_backward_P`

**Goal**: Show P(phi) witness exists (symmetric to forward_F)

**Issue**: Symmetric to forward_F. The `backward_witness_at_stage_with_phi` lemma exists but only works when the point is in stagedBuild at stage <= 2k.

**Why Not Fixable**: Same architectural gap applies to backward witnesses.

### 4. Line 724: `timelineQuotSingletonBFMCS.modal_backward`

**Goal**: Show phi in the (single) family implies Box(phi) in that family

**Issue**: This is fundamentally unprovable for a singleton BFMCS. `modal_backward` requires showing "phi in ALL families implies Box(phi)". With one family, this reduces to "phi in mcs implies Box(phi) in mcs", which is NOT a valid inference.

**Why Not Fixable**: Need either:
- Multi-family BFMCS with modal saturation (use `saturated_modal_backward`)
- Different truth lemma architecture that doesn't require `modal_backward`

## Architectural Analysis

### Current Architecture

```
stagedBuild n = process formula with encoding k = n/2 at stage 2k+1
denseStage n = stagedBuild n + density intermediates
timelineQuotFMCS = antisymmetrization of denseStage union
```

### The Gap

When a point p enters at stage m, only formulas with encoding k < m/2 have been processed. But p may have F(phi) for formulas with encoding k > m/2 (inherited via MCS construction). These F-obligations have no witnesses.

### Task 982 Resolution (Plan v10)

Task 982 plan v10 proposes "full dovetailing" using Cantor pairing:
- Process (point_index, formula_encoding) pairs via Nat.pair/unpair
- Every (point, formula) pair is eventually processed
- This ensures ALL F-obligations get witnesses

This requires ~22 hours of work across 6 phases to implement.

## Relationship to Plan v6

Plan v6 assumed these sorries could be "fixed" directly. After analysis:

- **Lines 659, 664, 679**: Require new infrastructure (dovetailing) per task 982
- **Line 724**: Requires architectural change to multi-family BFMCS or different truth lemma

Plan v6's approach of "fix within existing types" (Option A in the plan) is not viable without the dovetailing infrastructure.

## Recommendations

1. **Merge with Task 982**: The Phase 1 work required here IS task 982's dovetailing construction. These should be unified.

2. **Alternative Path**: If dovetailing is too complex, consider using the existing `CanonicalMCS`-based BFMCS (which is over all MCSs, hence multi-family and modally saturated), then transport results to TimelineQuot.

3. **Status**: Mark task 988 Phase 1 as BLOCKED pending task 982 completion.

## Files Examined

- Theories/Bimodal/Metalogic/StagedConstruction/ClosureSaturation.lean
- Theories/Bimodal/Metalogic/StagedConstruction/DFromCantor.lean
- Theories/Bimodal/Metalogic/Algebraic/DenseInstantiation.lean
- Theories/Bimodal/Metalogic/Algebraic/ParametricRepresentation.lean
- Theories/Bimodal/Metalogic/Bundle/ModalSaturation.lean
- specs/982_wire_dense_completeness_domain_connection/plans/10_full-dovetailing.md
