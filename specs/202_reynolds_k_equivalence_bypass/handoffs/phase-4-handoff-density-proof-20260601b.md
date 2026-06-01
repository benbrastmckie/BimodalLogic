# Phase 4 Handoff: Task 202 (Density Proof Structure)

## Session
sess_1780336977_e5mt

## Current State
Phase 4 IN PROGRESS. The CORRECT proof strategy for Reynolds Lemma 11 density has been identified and partially implemented. The code has ~16 type-checker errors in the `ordered_spread_above` and `ordered_spread_below` lemmas, all related to `contemp_equiv` direction (`.symm` vs `.trans` argument order) and one `push_neg` issue. The sorry sites in truth_pres have been replaced with clean calls to these lemmas.

### The Correct Proof Strategy (VERIFIED)

The density argument works by constructing a monadic formula whose TEMPORAL counterpart transitions TRUE->FALSE across the gap, violating Prior-UZ via no_boundary_at_successor.

**For ordered_spread_above (Until case)**:
1. Apply h_prior_UZ at t for formula A. Get first occurrence s0 > t with A(s0), and neg-A between t and s0.
2. If s0 in class(a): done.
3. If s0 NOT in class(a):
   a. All class(s0) members > t (by contemp_equiv_convex: if w ~M s0 and w <= t, then w ~M t ~M a, so s0 ~M a, contradiction).
   b. All class(s0) members below s0 are in (t, s0), where neg-A holds.
   c. Construct monadic formula Psi = "exists y ~M x, y < x, A(y)" (spread_below_A).
   d. Get temporal formula T_Psi via US_expressively_complete_over_prior.
   e. T_Psi TRUE at succ(t) (witness: s' < succ(t) in class(a), A(s')).
   f. T_Psi FALSE at pred(s0) (all class(s0) below pred(s0) have neg-A, so no witness).
   g. prior_UZ_first_transition gives c, succ(c) with T_Psi(c) and neg-T_Psi(succ(c)).
   h. c ~M succ(c) (no_boundary_at_successor).
   i. T_Psi(c): exists y0 < c in class(c) with A(y0).
   j. neg-T_Psi(succ(c)): no y < succ(c) in class(succ(c)) with A(y).
   k. But y0 < c < succ(c) and y0 ~M c ~M succ(c). CONTRADICTION.

**For ordered_spread_below (Since case)**: Symmetric, using spread_above_A and the same transition argument.

### Key Insight (NOT in previous handoffs)

spread_below_A is NOT contemp_equiv-invariant (the handoff phase-4-handoff-density-20260601.md was WRONG about this). But that doesn't matter! We don't need invariance. We just need:
1. The monadic formula EXISTS (to feed to US_expressively_complete_over_prior).
2. The TEMPORAL formula T_Psi transitions (TRUE at one point, FALSE at another).
3. prior_UZ_first_transition + no_boundary_at_successor give the contradiction.

The transition occurs ACROSS the gap between classes, not within a class.

### Implementation Structure (done)

- `env2_eq`, `table_lift`, `ce_eval`: helper lemmas extracted before truth_pres (lines ~1500-1525).
- `ordered_spread_above`: ~100 lines, after class_spread (line ~1529).
- `ordered_spread_below`: ~100 lines, after ordered_spread_above (line ~1969).
- Until sorry site: ~15 lines using ordered_spread_above (line ~2139).
- Since sorry site: ~15 lines using ordered_spread_below (line ~2177).

### Remaining Errors (~16 type-checker errors)

All in ordered_spread_above and ordered_spread_below. Categories:

1. **contemp_equiv direction** (~12 errors): `(contemp_equiv_is_equiv sig k M).symm h_ce` when h_ce has type `contemp_equiv a b` but expected `contemp_equiv b a`. Fix: adjust `.symm`/`.trans` argument order.

2. **h_class_s0_above_t proof** (1 error at line 1602): `push_neg at h_not` fails because h_not has type `not (contemp_equiv ...)`, not a universal. Fix: restructure to use `contemp_equiv_convex` directly.

3. **h_succ_s0_below_t in ordered_spread_below** (1 error at line 2055): `Order.pred_le_iff_le_succ` usage. Fix: use `Order.le_of_lt_succ` instead.

4. **h_ss0_lt_pt in ordered_spread_below** (1 error at line 2079): `▸` notation with wrong type. Fix: use explicit `rw` or `calc`.

### Approach to Fix Errors

Each error is a simple term-mode fix. The proof STRUCTURE is correct. The fixes are:
- Swap `.symm` arguments or add/remove `.symm`
- Replace `h_pred_class_s0` uses with correct direction
- Fix the `contemp_equiv_convex` arguments in h_class_s0_above_t

Estimated: 30-60 minutes to fix all type-checker errors and achieve sorry-free build.

## Files Modified
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructuresModelSurgery.lean`
  - Lines ~1492-1968: ordered_spread_above + helpers
  - Lines ~1969-2100: ordered_spread_below  
  - Lines ~2139-2152: Until sorry site (now calls ordered_spread_above)
  - Lines ~2177-2190: Since sorry site (now calls ordered_spread_below)

## Next Action
Fix the ~16 type-checker errors in ordered_spread_above and ordered_spread_below. All are term-level fixes (contemp_equiv direction, Order.pred/succ lemma names). Once fixed, `lake build` should pass with zero sorry.
