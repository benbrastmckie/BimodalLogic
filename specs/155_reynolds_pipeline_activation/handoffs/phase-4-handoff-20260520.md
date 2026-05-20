# Phase 4 Handoff: Gap Elimination (Reynolds Theorem 14)

**Date**: 2026-05-20
**Status**: PARTIAL — Task 4.7 complete, Tasks 4.2-4.6 blocked

## What Was Done

### Task 4.1 (confirmed done, pre-existing)
`no_gaps_discrete` already had `IsSuccArchimedean` removed and Prior-UZ/SZ hypotheses added before this phase.

### Task 4.7 (COMPLETED)
Rewrote `one_class` in `IntegerModel.lean` (line 882-923):
- Removed `[IsSuccArchimedean M.carrier]` from signature
- Added `atomMap`, `h_prior_UZ`, `h_prior_SZ` parameters (same as `no_gaps_discrete`)
- New proof: `by_contra h_diff` → `obtain from no_gaps_discrete` → `no_boundary_at_successor` gives `c ~M succ c` → transitivity gives `a ~M succ c` → contradiction

The proof structure is:
```lean
by_contra h_diff
obtain ⟨c, hac, h_not_succ⟩ := no_gaps_discrete sig k M atomMap h_prior_UZ h_prior_SZ a b h_diff
have hc_succ : contemp_equiv sig k M c (Order.succ c) := no_boundary_at_successor sig k M c
have hac_succ : contemp_equiv sig k M a (Order.succ c) := (contemp_equiv_is_equiv sig k M).trans hac hc_succ
exact h_not_succ hac_succ
```

Build passes. New sorry count: 3 (all pre-existing in IntegerModel.lean).

## Key Blocker: Reynolds Theorem 5

Tasks 4.2-4.6 (Lemmas 6-13, full `no_gaps_discrete` proof) are blocked by:

**Reynolds Theorem 5** (expressive completeness of {U,S} for Prior structures in general):
- Our `US_expressively_complete_over_Z` only works for structures with carrier = ℤ
- Reynolds proof needs: for any monadic FO formula rho, there exists temporal R such that R holds at t iff rho(t), in an ARBITRARY Prior structure M
- Without this, step 1 of Theorem 14 proof (defining formula R for "class ends in a gap") cannot be formalized

## What Is Needed to Unblock

Formalize Reynolds Theorem 5 for arbitrary Prior structures:
1. U'(A,B) ≡ ⊥ in any Prior structure (via Prior-UZ applied to B)
2. S'(A,B) ≡ ⊥ in any Prior structure (via Prior-SZ applied to B)  
3. {U,S,U',S'} expressive completeness over all linear structures (Theorem 4 = GHR94 9.3.1) already available
4. Therefore {U,S} is expressively complete over Prior structures

This requires extending `US_expressively_complete_over_Z` to handle:
- `int_truth` vs `temporal_truth` connection for arbitrary Prior structures
- The reduction from {U,S,U',S'} to {U,S} using Prior axioms

## Files Modified

- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel.lean` — rewrote `one_class` (lines 882-923)
- `specs/155_reynolds_pipeline_activation/plans/03_reynolds-pipeline-plan.md` — updated task status, added blocker

## Next Action for Resume

The next phase for a successor agent should be either:
1. **Implement Reynolds Theorem 5** for arbitrary Prior structures (unblocks Phase 4)
2. **Continue to Phase 5** (IntegerModel.lean helper sorries) which does NOT depend on Theorem 5
3. **Continue to Phase 1 or 2** (chronicle truth lemma, Nonempty fix) which also do not depend on this blocker
