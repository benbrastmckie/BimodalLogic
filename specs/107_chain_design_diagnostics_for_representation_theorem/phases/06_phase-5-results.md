# Phase 5 Results: Integration -- Replace RootScopedChain Sorry Sites

## Status: COMPLETED

## Summary

Phase 5 wires the Burgess chronicle construction into the BX completeness
theorem, bypassing the 3 sorry sites in `RootScopedChain.lean`. The
integration creates a parallel countermodel path through the chronicle
over Rat instead of the schedule-based Int chain.

## Changes

### New File: `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean`

- `extended_limit_f`: Extends the chronicle's `limit_f` to all rationals
  (domain points use chronicle, non-domain points use root MCS)
- `extended_limit_f_mcs`: Every rational maps to an MCS
- `chronicle_fmcs`: FMCS over Rat from the chronicle (sorry: G/H coherence)
- `shifted_chronicle_fmcs`: Time-shifted chronicle FMCS (places root at offset s)
- `chronicle_bfmcs`: BFMCS over Rat (one family per box-equivalence class)
- `chronicle_bfmcs_restricted_tc`: Restricted temporal coherence (sorry: F/P resolution)
- `chronicle_bfmcs_restricted_buc`: Restricted backward Until/Since (sorry: witness -> membership)
- `chronicle_bfmcs_restricted_fuc`: Restricted forward Until/Since (sorry: uses C5/C5')
- `dd_countermodel_chronicle`: **Main theorem** -- countermodel construction (SORRY-FREE wiring)

### Modified: `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean`

- Added import for `Chronicle.ChronicleToCountermodel`
- Rewired `bx_completeness` to use `dd_countermodel_chronicle` instead of `dd_countermodel`
- Updated documentation to reflect new sorry dependency tree
- Added `#print axioms` for `dd_countermodel_chronicle`

## Sorry Sites in ChronicleToCountermodel.lean

| Sorry Site | Line | Purpose | Depends On |
|-----------|------|---------|------------|
| `chronicle_fmcs.forward_G` | 192 | G-formula propagation | Chronicle g_content structure |
| `chronicle_fmcs.backward_H` | 196 | H-formula propagation | Chronicle h_content structure |
| `box_stable_in_chronicle_fmcs` | 234 | Box stability along FMCS | S5 properties + G/H coherence |
| `chronicle_bfmcs_restricted_tc` (F) | 320 | F-resolution | Chronicle C5 |
| `chronicle_bfmcs_restricted_tc` (P) | 323 | P-resolution | Chronicle C5' |
| `chronicle_bfmcs_restricted_buc` (U) | 342 | Backward Until | until_intro axiom |
| `chronicle_bfmcs_restricted_buc` (S) | 345 | Backward Since | since_intro axiom |
| `chronicle_bfmcs_restricted_fuc` (U) | 374 | Forward Until | Chronicle C5 + guard |
| `chronicle_bfmcs_restricted_fuc` (S) | 377 | Forward Since | Chronicle C5' + guard |

Total: 9 sorry sites (all in components, none in the wiring theorem itself)

## Verification

- `lake build` succeeds with no regressions (956 jobs)
- `bx_completeness` now traces through `dd_countermodel_chronicle`
- The 3 RootScopedChain sorry sites (`bx_bfmcs_restricted_tc`, `bx_bfmcs_restricted_buc`,
  `bx_bfmcs_restricted_fuc`) are NO LONGER on the critical path
- `#print axioms bx_completeness` still shows `sorryAx` (expected, due to Phase 2-4 upstream sorries)
- Once Phase 2-4 chronicle sorries and the 9 ChronicleToCountermodel sorries are resolved,
  `bx_completeness` will become sorry-free

## Architecture Decision

Chose the **parallel path** strategy: created `dd_countermodel_chronicle` alongside the
existing `dd_countermodel`, rather than modifying `RootScopedChain.lean`. Rationale:

1. Cleaner separation: the chronicle is a Rat-based construction, the Int chain is separate
2. No risk of breaking existing code: RootScopedChain.lean is unchanged
3. The old path (`dd_countermodel`) remains available as fallback
4. Clear dependency chain: chronicle -> ChronicleToCountermodel -> Completeness

## Next Steps

To make `bx_completeness` sorry-free, resolve:
1. Phase 2-4 upstream sorries in Chronicle/ modules
2. The 9 integration sorries in ChronicleToCountermodel.lean
3. The G/H coherence for chronicle FMCS (forward_G, backward_H)
4. Box stability along the chronicle FMCS
