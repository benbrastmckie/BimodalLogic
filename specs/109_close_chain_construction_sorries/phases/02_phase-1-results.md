# Phase 1 Results: Dead Code Cleanup

**Status**: COMPLETED
**Date**: 2026-04-20

## Summary

- Removed 4 dead-code sorry proofs from `CanonicalModel.lean`
- Archived dead code to `Boneyard/DeadCanonicalModel/EnrichedSeedLegacy.lean`
- Also removed associated definitions (`f_carry`, `f_carry_subset`, `p_carry`, `p_carry_subset`) — no callers on the active path
- Removed stale "Dead Code Removed" comment block at end of `CanonicalModel.lean`
- Fixed pre-existing `bx_fmcs` / `shifted_bx_fmcs` FMCS type mismatch (FMCSDef.lean was already updated to use strict `<` in Phase 0 work; CanonicalModel needed to match)
- Build passes with 2 remaining sorries (`g_content_subset_self`, `h_content_subset_self`) as expected
- Updated `specs/ROADMAP.md` sorry counts (23 → 19 total, 18 → 14 irreflexive-consequence)

## Files Modified

- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` — removed dead code, fixed FMCS construction
- `Theories/Bimodal/Boneyard/DeadCanonicalModel/EnrichedSeedLegacy.lean` — created (archive)
- `specs/ROADMAP.md` — updated sorry inventory
- `specs/109_close_chain_construction_sorries/plans/02_implementation-plan.md` — Phase 1 marked [COMPLETED]

## Verification

- `lake build Bimodal.Metalogic.BXCanonical.CanonicalModel` passes
- Grep for dead code names returns only Boneyard/comment hits in active tree
- Sorry count in `CanonicalModel.lean` reduced from 6 to 2

## Notes

The build was broken before Phase 1 started: `FMCSDef.lean` had been changed in Phase 0
to use strict `<` for `forward_G` / `backward_H`, but `CanonicalModel.lean` had not been
updated. The fix (`le_of_lt` adapter in `bx_fmcs`, omega in `shifted_bx_fmcs`) restores
build compatibility. Phase 2 will replace these adapters with native `<` signatures on
`int_chain_forward_G` / `int_chain_backward_H`.
