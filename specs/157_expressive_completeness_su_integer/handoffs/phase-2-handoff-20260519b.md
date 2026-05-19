# Phase 2 Handoff: DedekindZ Fixed, Hierarchy Partial

**Date**: 2026-05-19
**Session**: sess_1747650662_c4d2a1
**Phase**: 2 (Repair Downstream Files)

## What Was Done

### DedekindZ.lean - FULLY FIXED (17 errors -> 0 errors)
All 17 compilation errors fixed:
1. **Lines 1480-1481**: Changed strong induction from `r - s = n` to `r - s <= n` so omega can prove the step. Restructured the contradiction proof (find minimum, then h_no_min contradicts minimality).
2. **Line 1647**: `and_or_distrib` has type `(a v b) ^ c <-> ...` but needed `c ^ (a v b) <-> ...`. Wrote inline proof for right-factor distribution.
3. **Lines 1737-1741**: After `subst hwt` (where `hwt : w = t`), `t` is replaced by `w` in context. Renamed all `t` references to `w` in the w=t case.
4. **Line 1786**: `int_truth_or_iff.mp hAqnotU |>.2 |>.2` fails because `hAqnotU` is `A.and (q.or ...)` not `or`. Fixed to `(int_truth_and_iff.mp hAqnotU).2`.
5. **Line 1821**: `case8_equiv_Z` used before definition. Moved entire theorem (with section comment) above `case8_separable_Z_gen`.
6. **Lines 1859-1881**: Multiple `Application type mismatch` in `snce_Ufree_event_qNotU_guard_separable`:
   - Added `simp only [int_truth_all_past, Formula.neg, int_truth]` before intro
   - Swapped case 1/3 logic: case s<s1 uses guard_S on s1, case s1<s uses guard1 on s
   - Changed `(hequiv1 M t).mpr hpsi1` to direct destructuring (hpsi1 already has snce type after intro from neg)
   - Changed `hnotPsi1 ((hequiv1 M t).mp hS1)` to `hnotPsi1 hS1` (same type)
7. **Lines 1908-1946**: `simp` on `is_U_free (Formula.and B q)` fails because `Formula.and` unfolds to `imp/neg`. Added `Formula.neg` and `Bool.and_self` to simp lemma sets.
8. **Line 1937**: Second `and_or_distrib` instance in case7_separable_Z with same right-factor issue. Same inline proof fix.

### Hierarchy.lean - PARTIAL (103 errors -> 30 errors)
- Removed 162 lines of dead `.all_past`/`.all_future` match arms and induction cases via Python script
- Fixed `has_no_allpast_allfuture` usage (now trivially True, so `.1`/`.2` projections fail)
- Fixed `Bool.and_eq_false_iff` needed for `rcases` after `simp [is_U_free]`
- Removed unused lemmas: `has_single_U_type_all_past/all_future`, `single_U_all_past_separable`, `multi_U_all_past/future_separable`, `jd_all_past_le/jd_all_future_le`
- 30 remaining errors are deeper structural issues:
  - `abstract_untl_count_lt_of_not_U_free` has a pre-existing proof gap (untl non-matching case, `1 < 1` is false)
  - `is_S_free (.untl A B)` simp calls need `Bool.and_self` or similar
  - `has_no_allpast_allfuture` being True changes structure of `split`/projection proofs throughout

### NormalForm.lean - COMPILES (blocked by DedekindZ, now unblocked)

## Immediate Next Action

Continue fixing Hierarchy.lean errors (30 remaining). The most impactful fixes:
1. Replace remaining `simp [is_S_free, ...]` with `simp only [is_S_free, ..., Bool.and_self, Bool.true_and]`
2. Fix `has_no_allpast_allfuture` projection patterns throughout
3. Address the `abstract_untl_count_lt_of_not_U_free` pre-existing bug (needs theorem reformulation)

Then ExpressiveCompleteness.lean (59 errors, mostly int_truth type changes).

## Key Decisions
- `and_or_distrib` only works for left-factor `(a v b) ^ c`. Right-factor `c ^ (a v b)` needs inline proof.
- `has_single_U_type_all_past/all_future` are no longer provable (expansion introduces untl/snce nodes). Removed since unused.
- `abstract_untl_count_lt_of_not_U_free` has a genuine logical gap for non-matching `untl` nodes. Needs stronger precondition.

## Files Modified
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/DedekindZ.lean` (fixed, compiles)
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean` (30 errors, partially fixed)
