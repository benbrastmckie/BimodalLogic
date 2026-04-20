# Phase 2 Results: FMCS Strict Ordering

**Status**: COMPLETED
**Date**: 2026-04-20

## Summary

- Changed FMCS `forward_G` and `backward_H` from `≤` to `<` (strict) in FMCSDef.lean
- Updated all downstream consumers: CanonicalModel.lean, RootScopedChain.lean, RestrictedParametricTruthLemma.lean, ParametricTruthLemma.lean, ParametricHistory.lean
- Eliminated `g_content_subset_self` and `h_content_subset_self` sorries (no longer needed with strict ordering)
- Fixed cascade: `Int.toNat_lt_toNat` → `by omega`, `Nat.zero_le` → `by omega`, `sub_pos.mp` for Int conversions
- `dd_chain_g_content` and `dd_chain_h_content` in RootScopedChain.lean now use strict ordering throughout

## Files Modified

- `Theories/Bimodal/Metalogic/Bundle/FMCSDef.lean` — strict `<` in forward_G/backward_H
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` — updated chain lemmas, deleted sorries #5/#6
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` — updated sigma chain lemmas
- `Theories/Bimodal/Metalogic/Algebraic/RestrictedParametricTruthLemma.lean` — updated truth lemma
- `Theories/Bimodal/Metalogic/Algebraic/ParametricTruthLemma.lean` — updated truth lemma
- `Theories/Bimodal/Metalogic/Algebraic/ParametricHistory.lean` — fixed forward_G call
- `specs/ROADMAP.md` — updated sorry inventory

## Verification

- `lake build` succeeds (full project)
- `g_content_subset_self` and `h_content_subset_self` no longer exist
- Sorry count in CanonicalModel.lean: 0
