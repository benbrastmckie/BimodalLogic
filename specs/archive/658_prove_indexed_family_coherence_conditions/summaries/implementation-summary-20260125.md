# Implementation Summary: Task #658

**Task**: Prove indexed family coherence conditions
**Status**: BLOCKED
**Date**: 2026-01-25
**Duration**: ~2 hours

## Overview

Attempted to prove the four coherence condition sorries in `construct_indexed_family` (IndexedMCSFamily.lean lines 433, 439, 448, 456). The implementation was blocked due to a fundamental issue with the construction approach.

## Changes Made

### File Modifications

1. **IndexedMCSFamily.lean**:
   - Added import for `Bimodal.Boneyard.Metalogic.Completeness` to access MCS closure lemmas
   - Updated coherence condition proof stubs with detailed documentation explaining:
     - The proof strategy (contrapositive with MCS negation completeness)
     - Why the strategy is blocked
     - What infrastructure would be needed

2. **plans/implementation-001.md**:
   - Marked all four phases as [BLOCKED]
   - Added detailed blocker analysis explaining the fundamental construction issue

## Blocker Analysis

### Root Cause: Independent Lindenbaum Extensions

The `construct_indexed_family` function creates MCS at each time point using INDEPENDENT Lindenbaum extensions:

```
mcs_at_time D Gamma h_mcs t = extendToMCS (time_seed D Gamma t) ...
```

- `mcs(0)` = extension of Gamma
- `mcs(t > 0)` = extension of future_seed(Gamma)
- `mcs(t < 0)` = extension of past_seed(Gamma)

These extensions are **not coordinated**. Different invocations of `extendToMCS` can add different formulas, breaking temporal coherence.

### Why Coherence Proofs Fail

The coherence condition `G phi in mcs(t) -> phi in mcs(t')` requires formulas in `mcs(t)` to appear in `mcs(t')`. However:

1. If `G phi` is added by Lindenbaum to `mcs(t)` (not from seed), there's no guarantee `phi` is in `mcs(t')`
2. The seeds are based on the ROOT Gamma, not the extended MCS
3. Using contrapositive leads to circularity (need coherence to prove coherence)

### Comparison with Boneyard Approach

The Boneyard's `canonical_task_rel` uses a different pattern:
- Defines relations BETWEEN existing MCS (forward_seed/backward_seed)
- Each transition creates a new MCS extending the appropriate seed from the CURRENT state
- Coherence is built into the relation definition, not proven after the fact

## Recommendations

### Option A: Modify Construction (Recommended)

Redefine `construct_indexed_family` to use a **single coherent MCS construction** that satisfies all temporal requirements from the start, similar to how canonical model constructions typically work.

### Option B: Adopt Boneyard Pattern

Use the `canonical_task_rel` pattern from the Boneyard, which defines relations between world states rather than constructing a pre-determined family.

### Option C: Weaken Theorem

Add an axiom/assumption that the Lindenbaum extensions are temporally coherent. This weakens the theorem but may be acceptable for some use cases.

## Files Modified

- `Theories/Bimodal/Metalogic/Representation/IndexedMCSFamily.lean` - Added import, updated sorries with documentation
- `specs/658_prove_indexed_family_coherence_conditions/plans/implementation-001.md` - Updated phase statuses

## Next Steps

1. **Create new task** to redesign `construct_indexed_family` using a coherent construction approach
2. **Consult with domain expert** on the intended semantics and whether the Boneyard approach is suitable
3. **Consider alternative**: Prove coherence as a property of the canonical_task_rel construction instead

## Verification

- `lake build Bimodal.Metalogic.Representation.IndexedMCSFamily` - Succeeds with expected sorry warnings
- All existing functionality preserved
- No regressions introduced

## Notes

The coherence conditions are semantically correct requirements for an indexed MCS family. The issue is that the construction method (independent Lindenbaum extensions) doesn't guarantee these conditions. This is a design issue, not a proof difficulty.

The sorries remain but now include comprehensive documentation explaining the blocking issue and potential solutions.
