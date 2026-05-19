# JD Induction Restructuring Handoff

## Status: PARTIAL - 2 sorry calls remain

## What Was Done

Restructured `all_formulas_separable_aux` in `Hierarchy.lean` to eliminate the non-terminating self-referential `no_S_nested_sep_callback`. The new proof uses `Nat.strongRecOn` on `junction_depth` combined with structural induction within each JD level.

### New Infrastructure Created

1. **`callback_jd_le_one`** (line 1579): Proves callback formulas from `subst_in_separated_separable` have `junction_depth <= 1`. Key helper: `subst_u_free_jdS_le_one`.

2. **`subst_in_separated_separable_jd`** (line 1620): Version of `subst_in_separated_separable` where the callback also receives a `junction_depth <= 1` bound. Uses `callback_jd_le_one` for the `.snce` case.

3. **`no_S_nested_in_U_separable_param_jd`** (line 1656): Version of `no_S_nested_in_U_separable_param` with JD-bounded callback. Same count_U induction but passes JD bound to callback.

### Removed

- `no_S_nested_sep_callback` (was at line 1584, had `decreasing_by sorry`)
- `no_S_nested_sep_all` (was at line 1593, used `no_S_nested_sep_callback`)

### What Works (n >= 2 case)

For `junction_depth >= 2`: callback formulas have JD <= 1 < 2 <= n, so `ih_jd 1 (by omega)` handles them. Fully proved, no sorry.

### What's Left (n = 1 case)

Lines 1773 and 1806 have `by sorry` where the goal is `junction_depth zeta <= 0` but we only have `hjd_zeta : junction_depth zeta <= 1`.

## The Core Problem at n = 1

At JD level 1, `no_S_nested_in_U_separable_param_jd` invokes callbacks that have JD <= 1. The strong induction IH (`ih_jd`) only handles JD < n = 1, i.e., JD = 0. So JD = 1 callbacks cannot be handled by the IH.

The callback formula at n = 1 is `.snce (subst c p (.untl A B)) (subst d p (.untl A B))` where:
- c, d are U-free (from separated formula)
- A, B are S-free (from `no_S_nested_in_U`)
- The formula has single U-type `.untl A B` (since c, d are U-free)

For single-U-type formulas, the abstract-substitute roundtrip is an IDENTITY (abstracting all `.untl A B` and substituting back gives the same formula), creating a genuine infinite loop. No formula-based measure decreases.

## Approaches to Fix the n = 1 Gap

### Option A: Direct Event-Guard Decomposition (Recommended)

Prove a self-contained lemma for `.snce E F` with `no_S_nested_in_U`, JD <= 1, where ALL `.untl` args are S-free. The proof would:
1. Event-split on each `.untl A B` type
2. Use `single_U_eval_when_U_true/false` (valid since `snce_depth_of_U = 0` for separated formulas)
3. Reduce to Cases 1-8 (all proved in DedekindZ.lean and NormalForm.lean)

Key requirement: Cases 1-8 need A, B to be U-free AND S-free. Current `extract_U_type` only guarantees S-free. Need `extract_deepest_U_type` that guarantees both.

### Option B: Modify Callback Signature Further

Pass the original formula's identity to the callback, so the callback can detect when it's receiving the same formula and break the cycle directly.

### Option C: Use Fuel/Gas Parameter

Add a fuel parameter that decreases on each callback invocation. At fuel = 0, use a direct argument. This is mathematically sound because the callback chain is finite (bounded by the number of `.snce` nodes in the separated form).

## Key Verified Facts

- `callback_jd_le_one`: callback JD <= 1 (proved, no sorry)
- `snce_of_boxfree_sep_jd_le_one`: `.snce chi_a chi_b` from box-normalized separated forms has JD <= 1 (proved)
- S-free formulas have JD = 0: `s_free_junction_depth_zero` (in TemporalClosure.lean)
- U-free formulas have JD = 0: `u_free_junction_depth_zero` (in TemporalClosure.lean)
- Cases 1-8 are axiom-free: verified with `lean_verify`

## Files Modified

- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean` (lines 1573-1817)
