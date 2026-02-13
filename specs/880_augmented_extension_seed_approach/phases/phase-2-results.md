# Phase 2 Results: Restructure Theorem Signature

**Task**: 880 - Augmented Extension Seed Approach
**Phase**: 2 of 4
**Status**: COMPLETED

## Summary

Fixed a critical gap in the `buildSeedAux` construction and updated the consistency proof to explicitly track the new intermediate seed (`seed4`).

## Changes Made

### 1. Construction Fix (buildSeedAux)

**File**: `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed.lean`

**G case (Formula.all_future)** - Lines 505-512:
- Added `seed4 := seed3.addToAllFutureTimes famIdx timeIdx phi`
- Construction now propagates both G psi AND psi to future times
- Recursion changed from `buildSeedAux psi famIdx timeIdx seed3` to `seed4`

**H case (Formula.all_past)** - Lines 513-520:
- Added `seed4 := seed3.addToAllPastTimes famIdx timeIdx phi`
- Construction now propagates both H psi AND psi to past times
- Recursion changed from `buildSeedAux psi famIdx timeIdx seed3` to `seed4`

### 2. Proof Updates (buildSeedAux_preserves_seedConsistent)

**G case** - Lines 3741-3770:
- Added explicit `seed4` definition in proof
- Added `h_seed4_eq : seed4 = seed3` showing propagation is no-op (single-time invariant)
- Added properties: `h_seed4_cons`, `h_seed4_wf`, `h_psi_in_seed4`, `h_seed4_single`, `h_seed4_single_time`
- IH now applied with `seed4` instead of `seed3`

**H case** - Lines 3905-3934:
- Symmetric changes to G case

### 3. Documentation Update

Updated the docstring at lines 2771-2783 to reflect that the construction gap has been fixed.

## Verification

- `lake build Bimodal` completed successfully (999 jobs)
- No new errors introduced
- No new sorries introduced

## Why This Fix Matters

The construction now correctly propagates G psi (and H psi) to future (and past) times. This ensures that:

1. At any future time where psi needs to hold, G psi is also present
2. psi can be derived from G psi via `temp_t_future` axiom
3. The consistency proof can appeal to this derivation

In the current implementation, the single-time invariant means there are no future/past times to propagate to, so `seed4 = seed3`. However, the construction is now semantically correct and will work when extended to handle multiple times.

## Remaining Work

- Phase 3: Prove remaining sorry-marked lemmas (`addToAllFutureTimes_preserves_seedConsistent_with_gpsi`, etc.)
- Phase 4: Final verification and cleanup

## Sorries in RecursiveSeed.lean

The file still contains sorries at:
- Lines 2810, 2827: Supporting lemmas (templates for multi-time case)
- Lines 3974, 4059, 4140, 4224, 4290, 4354: Dead code paths (marked as structural)

These are pre-existing and not introduced by Phase 2.
