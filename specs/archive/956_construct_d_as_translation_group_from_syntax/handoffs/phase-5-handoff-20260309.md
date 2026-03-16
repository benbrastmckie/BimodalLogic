# Handoff: Phase 5 (No Endpoints) Partial

**Task**: 956
**Phase**: 5 (No Endpoints)
**Status**: PARTIAL
**Session**: sess_1741536300_i956impl
**Date**: 2026-03-09

## Immediate Next Action

Complete the `NoMaxOrder` and `NoMinOrder` instances in `RestrictedFragment.lean` by:
1. First fixing `CanonicalCompleteness.lean` build errors (references to removed `temp_t_future`/`temp_t_past` axiom constructors)
2. Importing `mcs_has_F_top` and `mcs_has_P_top` from fixed CanonicalCompleteness
3. Completing the proof for the reflexive case

## Current State

**File**: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/RestrictedFragment.lean`
**Lines**: ~430
**Sorries**: 2 (lines 423 and 434)

The sorry is in the `exists_gt`/`exists_lt` proofs inside the `NoMaxOrder`/`NoMinOrder` instances.

## Key Issue: Reflexive Case in No-Endpoints

The proof structure for NoMaxOrder:
1. Every MCS M has `F(neg bot) in M` (from `mcs_has_F_top`)
2. `forward_F_stays_in_restricted_fragment` gives successor `b` with `CanonicalR a b`
3. If NOT(CanonicalR b a): done, `[a] < [b]` in quotient
4. **If CanonicalR b a**: `[a] = [b]` in quotient, need DIFFERENT successor

The reflexive case (step 4) is the blocker. Possible approaches:
- **Enriched formula**: Use a formula that distinguishes the witness from the original MCS
- **Use temp_a**: `phi -> G(P_exists(phi))` gives `G(P_exists(neg bot)) in a`, propagate through witnesses
- **Use density (DN)**: `F(neg bot) -> FF(neg bot)` gives a two-step witness that may escape the equivalence class

Note: The plan says Phase 5 is independent of Phase 4 (density), but the proof may actually need density or a similar argument.

## What NOT to Try

- Don't try to show `canonicalFWorld` gives a different MCS than the input -- it can return the same MCS if the input is reflexive
- Don't rely on `CanonicalCompleteness.lean` without fixing its build errors first

## Critical Context

1. `CanonicalCompleteness.lean` references removed axiom constructors `temp_t_future`/`temp_t_past` -- these were removed in an earlier refactoring session (irreflexive G/H refactoring)
2. `RestrictedFragment.lean` has zero sorries for Phases 2-3 (countability, linear order, totality)
3. The `DenseQuotient.lean` file has 4 pre-existing sorries and compilation errors -- this is a separate concern (Phase 4)

## References

- Plan: `specs/956_construct_d_as_translation_group_from_syntax/plans/implementation-005.md`
- Summary: `specs/956_construct_d_as_translation_group_from_syntax/summaries/implementation-summary-20260309b.md`
- RestrictedFragment: `Theories/Bimodal/Metalogic/Bundle/RestrictedFragment.lean`
- CanonicalCompleteness (broken): `Theories/Bimodal/Metalogic/Bundle/CanonicalCompleteness.lean`
