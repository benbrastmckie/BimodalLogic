# Task994_DovetailedQuot

**Archived**: 2026-03-19 (Task 994)

## Files

- **DovetailedTimelineQuot.lean**: Dovetailed timeline quotient construction with witness chain proofs
- **DovetailedFMCS.lean**: FMCS wrapper for the dovetailed timeline construction

## Original Purpose

These files implemented an alternative approach to the canonical model construction for completeness, using **dovetailed witness enumeration**. The core idea was to interleave forward (F-formula) and backward (P-formula) witness processing in a dovetailed sequence, building up the timeline incrementally.

### Key Concepts

1. **Dovetailed Construction**: Rather than processing all F-witnesses then all P-witnesses, the approach interleaved them: F_1, P_1, F_2, P_2, ... This was intended to ensure coverage of both directions simultaneously.

2. **Timeline Quotient**: The construction built a `DovetailedTimelineQuot` type that quotients the raw timeline by temporal equivalence, with the goal of obtaining a dense linear order.

3. **Strong Induction Pattern**: The witness chain proofs used strong induction on the depth of iterated modalities (F^n, P^n), with the induction hypothesis applied to smaller depths.

## Why Archived

### 1. Orphaned from Completeness Chain

The main completeness proof (`Completeness.lean`) uses the `TimelineQuot` path via `DFromCantor.lean`, not this dovetailed approach. Neither file is imported by any active code in the completeness chain.

### 2. Unsolvable Sorries

All sorries in these files trace to the same fundamental issue: proving that density witnesses from `density_frame_condition` are contained in the dovetailed timeline union. This requires an enumeration completeness argument that was never completed.

Key sorry locations:
- `dovetailedTimeline_has_intermediate` (line 295): Gap connecting density_frame_condition to timeline membership
- `forward_F_core` (line 806): Termination proof for j > 0 case in recursion
- `forward_F_chain_witness` (line 959): j > 0 case in strong induction
- `backward_P_chain_witness` (line 1028): Symmetric j > 0 case

### 3. Code Duplication

DovetailedFMCS.lean appears to be an incomplete refactoring of DovetailedTimelineQuot.lean, with duplicated definitions for FMCS construction, forward_G/backward_H proofs, and canonicalR implications.

## Mathematical Patterns Preserved

### Strong Induction on Iterated Modalities

The `forward_F_chain_witness` and `backward_P_chain_witness` proofs demonstrate a pattern for proving properties of formulas with iterated modalities (F^n phi, P^n phi):

```lean
-- Induction on j (number of iterations)
-- Base case: j = 0 (no modalities to satisfy)
-- Inductive case: j > 0, use IH for j-1
```

### Density-via-Encoding-Overflow Technique

The approach attempted to leverage the Cantor density of rationals to ensure density witnesses exist in the timeline:

1. Encode MCS + formula pairs as natural numbers
2. Use dovetailed enumeration to ensure all witnesses eventually appear
3. Apply density_frame_condition to obtain intermediate points

This technique may be useful for future approaches to density proofs.

## Restoration Notes

To restore these files for exploration:

```bash
cp Theories/Bimodal/Boneyard/Task994_DovetailedQuot/DovetailedTimelineQuot.lean \
   Theories/Bimodal/Metalogic/StagedConstruction/DovetailedTimelineQuot.lean

cp Theories/Bimodal/Boneyard/Task994_DovetailedQuot/DovetailedFMCS.lean \
   Theories/Bimodal/Metalogic/StagedConstruction/DovetailedFMCS.lean
```

**Warning**: These files depend on `DovetailedCoverage.lean` and related files in StagedConstruction. They may not build cleanly with current Mathlib versions.

To complete the approach, one would need to prove that the dovetailed enumeration is complete - that every density witness required by `density_frame_condition` eventually appears in the timeline union.

---

*Last updated: 2026-03-19*
*Task: 994 (archive_dead_code_in_staged_construction)*
