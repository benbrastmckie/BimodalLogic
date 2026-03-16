# Implementation Summary: Task 973

**Task**: Prove NoMaxOrder and NoMinOrder on ConstructiveQuotient
**Status**: Completed
**Date**: 2026-03-16
**Session**: sess_1773686041_712a02

## Overview

Implemented `NoMaxOrder` and `NoMinOrder` instances for `ConstructiveQuotient` by creating a new file `CanonicalSerialFrameInstance.lean`. This approach avoids an elaboration-order conflict that occurs when `ConstructiveFragment.lean` imports `CanonicalIrreflexivityAxiom`.

## Changes

### Created Files

- `Theories/Bimodal/Metalogic/Canonical/CanonicalSerialFrameInstance.lean`
  - `NoMaxOrder (ConstructiveQuotient M₀ h_mcs₀)` instance
  - `NoMinOrder (ConstructiveQuotient M₀ h_mcs₀)` instance

### Modified Files

- `Theories/Bimodal/Metalogic/Canonical/ConstructiveFragment.lean`
  - Removed 2 sorry'd instances (NoMaxOrder, NoMinOrder)
  - Fixed pre-existing bugs in `encode_determines` proof (added `generalizing M₂` to induction)
  - Fixed pre-existing bugs in `Preorder` instance (replaced `rfl` pattern with explicit handling)
  - Fixed pre-existing bugs in `Countable` instance (proper use of `h₁.some`)

## Proof Technique

Both proofs follow the same pattern from research-002.md:

1. **Seriality Witness**: Use `SetMaximalConsistent.contains_seriality_future/past` to get `F(neg bot)` or `P(neg bot)` in any MCS
2. **Execute Step**: Use `executeForwardStep` or `executeBackwardStep` to construct successor/predecessor MCS N
3. **Strictness**: Use `canonicalR_strict` to show the reverse relation doesn't hold
4. **Construct Quotient Element**: Build `ConstructiveFragment` element `w'` with `N` and reachability proof
5. **Show Strict Order**: Prove `w < w'` (or `w' < w`) using the preorder definition and strictness

## Verification

- `lake build` passes with no errors
- Zero sorries in `CanonicalSerialFrameInstance.lean`
- Zero sorries in `ConstructiveFragment.lean`
- No new axioms introduced

## Design Notes

The file separation foreshadows task 978's `SerialFrame` typeclass architecture:
- `ConstructiveFragment.lean`: Concrete representation (encoding, Countable, Preorder)
- `CanonicalSerialFrameInstance.lean`: Frame condition instances (NoMaxOrder, NoMinOrder)

## Phases Completed

1. Phase 1: Create new file with module structure [COMPLETED]
2. Phase 2: Implement NoMaxOrder instance [COMPLETED]
3. Phase 3: Implement NoMinOrder instance [COMPLETED]
4. Phase 4: Remove sorry instances from ConstructiveFragment.lean [COMPLETED]
5. Phase 5: Final verification [COMPLETED]
