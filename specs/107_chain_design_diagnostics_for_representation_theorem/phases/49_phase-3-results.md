# Phase 3 Results: Restructure Lemma 2.6 with Burgess D0 Seed

## Status: PARTIAL

## Summary

Phase 3 restructured the Lemma 2.6 splitting infrastructure in
`PointInsertion.lean`. The code was cleaned up and dead code archived,
but the core density gap sorry was NOT eliminated because it is a
genuine limitation of BX without a density axiom.

## What Was Done

### 1. Code Restructuring
- Renamed `g_content_sub_B_of_BurgessR3Maximal` to private `g_content_sub_B`
- Renamed `h_content_sub_B_of_BurgessR3Maximal` to private `h_content_sub_B`
- Updated docstrings with detailed density gap documentation
- Consolidated stale end-of-file comments into single summary block

### 2. Dead Code Archival
- Created `Boneyard/NonBurgessSeed/PointInsertionLegacy.lean`
- Archived old public function signatures and documentation
- Updated removal comments to reference archive location

### 3. Density Gap Analysis
Thorough analysis confirmed the density gap is genuine:
- `G(phi) in A` and `untl(phi.neg, gamma) in A` are semantically
  contradictory on DENSE orders (the guard interval (t,s) is non-empty)
- But BX has no density axiom, so (t,s) may be empty on discrete orders
- The BX5+BX14+BX13 chain (Burgess pp. 370-371) does NOT bypass this:
  it produces `F(event)` formulas but cannot place h_content elements
  at the same future point (h_content elements are "current-time" facts)
- The Burgess D0 seed `{beta.neg} union B` is trivially consistent but
  does not provide g_content inclusions needed for the output type

## Sorry Sites (PointInsertion.lean)

| Line | Function | Sorry Type | Status |
|------|----------|-----------|--------|
| 857 | `g_content_sub_B` | Density gap (inconsistent case) | UNCHANGED |
| 879 | `h_content_sub_B` | Density gap (inconsistent case) | UNCHANGED |
| 1052 | `lemma_2_7` | Full proof pending (Phase 5) | UNCHANGED |

Total: 3 sorry sites (same as before restructuring).

## Why the Sorry Count Did Not Decrease

The plan's approach (Burgess D0 seed) assumes that including B in the seed
provides enough content for the output type. But our output type requires
`g_content(A) subset D` and `g_content(D) subset C`, which need:
1. g_content(A) in the seed (for g_content(A) subset D)
2. h_content(C) in the seed (for g_content(D) subset C via duality)

Proving `{beta.neg} union g_content(A) union h_content(C)` consistent
without `g_content(A) subset B` is not achievable with BX axioms alone:
- The G-lifting trick (forward_temporal_witness_seed_consistent) cannot
  handle h_content elements (which lack G-modality in A)
- The BX5+BX14+BX13 chain gives F(event) in A but cannot place
  h_content elements at the future event point

## Build Status

`lake build` succeeds cleanly. No regressions.

## Files Modified
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean`
  - Renamed public g/h_content_sub_B to private
  - Updated docstrings with density gap documentation
  - Consolidated stale comments
- `Boneyard/NonBurgessSeed/PointInsertionLegacy.lean` (new archive file)

## Recommendation

The density gap sorry requires one of:
1. A density axiom added to BX (changes the logic)
2. Weakening the output type of `lemma_2_6_splitting` to drop g_content
   inclusions (may require downstream adaptations in C4/C4' phases)
3. A fundamentally different proof strategy not yet identified

Option 2 is most promising if downstream phases (C4/C4') don't actually
need the full g_content inclusion output.
