# Phase 6 Handoff v3: Cases III/IV -- 1 Sorry Remaining

**Date**: 2026-05-28
**Session**: sess_1780001766_2e723d
**Status**: PARTIAL (1 sorry remains in non-degenerate case)
**File**: `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/CaseAnalysis.lean`
**Sorry location**: Line 3359 (non-degenerate case of `case pos` in ghr93_cases_III_IV)

## What Was Done

1. **Closed the degenerate case sorry** (formerly at line ~3453):
   - Proved `x = c` via sigma game contradiction: sigma on `[x', d] = {gamma_N}` times `[x, c]` cannot produce a carrier response in `{gamma_N}` (a gap), so no carrier point exists in `[x, c]`, forcing `x = c` from `h_pt_xc`.
   - Redefined `a'_resp := fun _ => c` (constant function) since all N-selections are identical (`gamma_N = x'`), requiring all M-responses to be identical (`c = x`) for `same_order_type`.
   - Used tau game orderings directly for `same_order_type` via `@same_order_type_of_cases sig N M ...` (explicit N/M swap for backward direction).
   - Gap/point agreement via `gap_point_agreement_of_cases` with `show` to force `a'_resp k` reduction to `c`.
   - Formula agreement via `formula_agreement_of_cases` with `show` for `a'_resp k` reduction.

2. **Build passes** with 1 sorry remaining at line 3359.

## Remaining Sorry (Line 3359): Non-Degenerate Case

### Goal State

```
exists b_resp, inClosedInterval x' y' (extendPoint b_resp) /\
  ghr93_winning_condition (n + 1)
    (game_tuple x' y' a_bwd b_resp) (game_tuple x y a'_resp b_sp)
```

### Available Hypotheses

- `resp_sub : Fin n -> ExtendedCarrier M atomMap r` with `hresp_sub_in : forall k, resp_sub(k) in [x, gamma_M]`
- `hwin_sub`: sub-game on `[x', gamma_N] x [x, gamma_M]` -- for b' in `[x, gamma_M]`, get b in `[x', gamma_N]` with n-round winning condition
- `b_sp : M.carrier` with `hb_sp_in : b_sp in [x, y]`
- `a'_resp(k<n) = resp_sub(k)`, `a'_resp(n) = gamma_M`
- `h_pt_sub : exists p, inClosedInterval x' (Sum.inr gamma_N) (extendPoint p)` (carrier point exists)
- `tau_r`, `hwin_tau`, `resp_tau`, `hresp_tau_in`: tau game on `[d, y'] x [c, y]`
- `props`: SplitPointProps including sigma on `[x', d] x [x, c]`, h_fwd_n1, etc.
- `gamma_M_form`, `gamma_gp`: formula/gap-point agreement at gamma_M/gamma_N

### Strategy

**Case A (b_sp <= gamma_M)**: Use `hwin_sub` to get `b_resp in [x', gamma_N]`.
- Sub-game orderings cover positions 0..n-1, b_sp, and gamma_M.
- Need y/y' orderings: derive from 0-round forward game on `[x, y] x [x', y']` (props.h_fwd_n1 round-mono'd to 0).
- Key lemma needed: `gamma_M < y <-> gamma_N < y'` from forward game on `[gamma_M, y] x [gamma_N, y']`.

**Case B (b_sp > gamma_M)**: Use `hwin_tau` to get `b_resp in [d, y']`.
- Need `c <= b_sp` for tau to apply. This requires `c <= gamma_M`.
- If `c <= gamma_M`: direct from b_sp > gamma_M >= c.
- If `c > gamma_M`: need sigma-based approach for b_sp in `(gamma_M, c)`.
- Alternative: case-split on `c <= b_sp` (tau) vs `b_sp < c` (sigma).

### Key Technical Challenges

1. **Backward direction**: `ghr93_winning_condition` has N as first struct, M as second (backward game). Use `@same_order_type_of_cases sig N M ...` with explicit type params.

2. **a'_resp(k) unfolding**: `a'_resp` is a `let` binding. Use `show` or `change` to force evaluation when needed.

3. **Ordering composition**: For `gamma_M vs y <-> gamma_N vs y'`, use either:
   - Forward game `h_r1_univ` on `[gamma_M, y] x [gamma_N, y']` reduced to 0-round.
   - Or `pivot_chain_order'` composing sub-game and tau orderings.
   - Need carrier point in `[gamma_N, y']` for forward game challenge (or handle `gamma_N = y'` separately).

4. **c vs gamma_M ordering**: Unknown. Must case-split rather than assume.

## Files Modified

- `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/CaseAnalysis.lean`: Degenerate case sorry closed (~100 lines added), non-degenerate sorry remains at line 3359.

## Key Decisions

- Degenerate case: `a'_resp = fun _ => c` (constant). This is correct because `x = c` (proved) and all N-selections are `gamma_N = x'`.
- For `same_order_type_of_cases`, must use `@` with explicit `sig N M` to handle backward direction type swap.
- `order_refl_pair` cannot be used across different types; use explicit `lt_irrefl` construction instead.
