# Implementation Summary: Task #1006

**Status**: BLOCKED (Phase 2 of 4)
**Completed**: 2026-03-19
**Duration**: Partial (Phase 1 only)

## Overview

Task 1006 aimed to replace FlagBFMCS `satisfies_at` with a canonical TaskFrame using `truth_at`. The approach was to construct `BFMCS Int` from `FlagBFMCS` via global enumeration of CanonicalMCS and apply the parametric pipeline for completeness.

## Phases Status

| Phase | Name | Status |
|-------|------|--------|
| 1 | Global Countable Enumeration | COMPLETED |
| 2 | Per-Flag FMCS Int Construction | BLOCKED |
| 3 | BFMCS Int Bundle with Modal Coherence | NOT STARTED |
| 4 | Canonical Completeness Theorem | NOT STARTED |

## Completed Work (Phase 1)

### File Created

`Theories/Bimodal/Metalogic/Bundle/FlagBFMCSIntBundle.lean`

### Definitions

- `Countable CanonicalMCS` - Instance via import from CanonicalQuot.lean
- `Encodable CanonicalMCS` - Derived from Countable
- `enum_mcs : CanonicalMCS -> Int` - Global injective enumeration
- `decode_mcs : Int -> Option CanonicalMCS` - Inverse lookup
- `time_in_flag` - Predicate for time membership in Flag image
- `mcs_at_time` - MCS lookup with root fallback
- `mcs_at_time_is_mcs` - Proof that result is always maximal consistent

### Theorems

- `enum_mcs_injective` - Proved: distinct MCSs map to distinct integers
- `decode_enum_mcs` - Proved: decode inverts encode

## Blocking Issue (Phase 2)

### The Problem

The FMCS structure requires `forward_G` and `backward_H` to hold for ALL times s, t with s < t. However, the integer ordering does NOT correspond to the CanonicalMCS Preorder (`CanonicalR`).

### Why This Blocks

1. **Enumeration is not order-preserving**: `enum_mcs` uses `Encodable.encode` which produces arbitrary natural numbers unrelated to the MCS ordering.

2. **Fallback doesn't help**: Using `root` MCS for out-of-range times doesn't satisfy temporal coherence because:
   - G(phi) in some MCS M doesn't imply phi in root (unless M <= root)
   - The G-T axiom is irreflexive, so G(phi) in root doesn't imply phi in root

3. **Case analysis fails**: For integers s < t where s maps to MCS M_s and t maps to MCS M_t:
   - We need: G(phi) in M_s implies phi in M_t
   - This requires: CanonicalR M_s.world M_t.world (g_content inclusion)
   - But integer s < t tells us NOTHING about CanonicalR

### Attempted Solutions

1. **Root fallback**: Fails as described above
2. **Per-Flag custom ordering**: Would require different Preorder on Int per Flag
3. **Partial FMCS**: Not supported (FMCS requires total functions)

## Possible Resolutions (Future Work)

1. **Alternative completeness pathway**: Use FlagBFMCS directly without converting to BFMCS Int. This requires extending the truth lemma to work with FlagBFMCS's native structure.

2. **Order-preserving embedding**: Instead of arbitrary enumeration, use an embedding that preserves the CanonicalR ordering. This is non-trivial because CanonicalMCS is only a Preorder, not a total order.

3. **Interval arithmetic**: Embed each Flag to a rational interval, preserving relative ordering within the Flag. Different Flags can use non-overlapping intervals.

4. **Extend parametric infrastructure**: Modify `ParametricCanonicalTaskFrame` to work with Preorders instead of requiring `AddCommGroup D`.

## Files Modified

- `Theories/Bimodal/Metalogic/Bundle/FlagBFMCSIntBundle.lean` (new)

## Verification

- Phase 1 compiles with no errors
- Phase 2 has documented `sorry` placeholders with blocking explanation
- `lake build Bimodal.Metalogic.Bundle.FlagBFMCSIntBundle` succeeds with warnings

## Dependencies Identified

The blocking issue depends on resolving the fundamental mismatch between:
- The parametric infrastructure's requirement for `AddCommGroup D`
- The FlagBFMCS's native Preorder structure

This may require architectural changes to the completeness approach.

## Recommendations

1. **Mark task as BLOCKED** for user review
2. **Consider alternative approaches** listed above
3. **Do NOT add more sorries** - the blocking issue is architectural, not a missing proof step
