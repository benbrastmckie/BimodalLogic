# Phase 2-3 Handoff: Cases 5,6,8 Non-Circular, Case 7 Blocked

**Date**: 2026-05-18T01:00Z
**Session**: sess_1779084016_ff70c0
**Status**: PARTIAL - 3 of 4 circular cases eliminated

## Summary of Changes

### New Infrastructure in DedekindZ.lean (lines 677-860)

1. **replace_untl_with_top/bot**: Syntactic U(A,B) replacement functions.
   Replace all `untl A B` nodes with `neg bot` (top) or `bot` in a formula.

2. **replace_untl_with_top_correct / replace_untl_with_bot_correct**:
   Semantic correctness. When U(A,B) holds at time t, phi(t) <-> phi[U:=top](t).
   When ~U(A,B) holds, phi(t) <-> phi[U:=bot](t).

3. **replace_untl_with_top_U_free / replace_untl_with_bot_U_free**:
   The replaced formula is always U-free (all untl nodes removed or replaced).

4. **snce_event_eval_pos / snce_event_eval_neg**:
   When U (or ~U) is conjoined with the event of S, we can replace U inside
   the event formula: S(C^U, F) <-> S(C[U:=top]^U, F).

5. **snce_event_decomp_separable**: The main workhorse. Given S(C, F) with
   U-free guard F, decomposes via:
   - since_event_split on U(A,B)
   - U-evaluation in each branch
   - elim_case_1_gen / elim_case_2_gen for the U-free results

### Cases Proved Non-Circularly

- **Case 5** (case5_separable_Z): via case3_equiv_Z_general + snce_event_decomp_separable
- **Case 6** (case6_separable_Z): same approach with a := a ^ ~U
- **Case 8** (case8_separable_Z): via case8_decomp_Z (neg_since_equiv decomposition
  with well-founded descent backward proof) + Case 5 + snce_event_decomp_separable

### Case 7: BLOCKED

Case 7: S(a ^ U(A,B), q v ~U(A,B)). The guard contains ~U(A,B).

**Why it's blocked**: neg_until_equiv rewrites ~U(A,B) as G(~A) v U(~A^~B, ~A),
introducing a SECOND U-type U(~A^~B, ~A). After applying case3_equiv_Z_general
and snce_event_decomp_separable for the first U-type, the resulting formula
still contains U(~A^~B, ~A) inside snce arguments, breaking syntactic separation.

**What is needed**: Either:
1. The full junction_depth hierarchy (Phase 4) which handles arbitrary formulas
   by strong induction, automatically dealing with multiple U-types.
2. A two-level event decomposition that handles both U-types simultaneously.
3. A direct equivalence specific to Case 7 on Z that avoids introducing new U-types.

## Verification Status

- `lake build`: passes (1647 jobs)
- DedekindZ.lean sorry count: 0 (only `all_separable` reference in Case 7)
- DedekindZ.lean `all_separable` usage: 1 (case7_separable_Z only)

## Files Modified

- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/DedekindZ.lean` (1086 lines)

## Immediate Next Action

1. Phase 4 (junction_depth hierarchy) can now proceed with 7 of 8 cases non-circular.
   The hierarchy theorem would give all_formulas_separable which replaces all_separable,
   automatically handling Case 7 through the inductive structure.
2. Alternatively, a targeted Case 7 proof could be developed using the
   neg_until_equiv + two-level decomposition approach.
