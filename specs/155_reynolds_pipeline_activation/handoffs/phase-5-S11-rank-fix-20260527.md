# Phase 5 S11: Rank Mismatch Fix (Option A Implementation)

## Status: COMPLETED (rank fix), sorry remains for gap detection assembly

## Summary

Resolved the S11 rank mismatch blocker by extending `h_r1_univ` to be universally
quantified over rank `r'` throughout the call chain. The rank-(r+4) forward game
`h_fwd_r3` is now available in `ghr93_cases_III_IV`, enabling gap detection formula
transfer.

## What Was Done

### 1. Modified `ghr93_forward_to_backward_core` (Theorem6.lean)

Changed `h_r1_univ` from:
```
∀ {x₁ y₁ : ExtendedCarrier M atomMap r} {x₁' y₁' : ...},
  x₁ ≤ y₁ → x₁' ≤ y₁' → game at rank (r + 2)
```
to:
```
∀ (r' : Nat) {x₁ y₁ : ExtendedCarrier M atomMap r'} {x₁' y₁' : ...},
  x₁ ≤ y₁ → x₁' ≤ y₁' → game at rank (r' + 2)
```

Updated the succ case to call `h_r1_univ r hxy hx'y'` (specialize at current rank).

### 2. Modified `ghr93_forward_to_backward` (Theorem6.lean)

Same change to `h_r1_univ` type. Call to core now passes `h_r1_univ` directly.

### 3. Updated `ghr93_forward_to_backward_rank_varying` call (Theorem6.lean)

Now passes `h_r1_univ` directly to `ghr93_forward_to_backward` (no longer
specializes at rank `r`). Both versions already had the same type for `h_r1_univ`.

### 4. Added `h_r1_univ` parameter to call chain (CaseAnalysis.lean)

Threaded `h_r1_univ` (with round count `4 + 3 * n`) through:
- `ghr93_inductive_step` → new parameter, passed to cases II-IV
- `ghr93_cases_II_III_IV` → new parameter, passed to cases III-IV
- `ghr93_cases_III_IV` → new parameter, used to derive `h_fwd_r3`

### 5. Derived `h_fwd_r3` in `ghr93_cases_III_IV` (CaseAnalysis.lean)

Proved rank_embed transitivity inline:
```lean
rank_embed (r+2 ≤ r+4) (rank_embed (r ≤ r+2) e) = rank_embed (r ≤ r+4) e
```
Used `h_r1_univ` at `r' = r+2` to get game at rank `(r+2)+2 = r+4`, then
applied `rank_embed_comp` to align endpoints.

### 6. Updated call site in `ghr93_forward_to_backward_core` (Theorem6.lean)

The call to `ghr93_inductive_step` now passes `h_r1_univ` with round monotonicity
to convert from `rounds_r1` rounds to `4 + 3 * n` rounds.

## Proof State at Sorry (CaseAnalysis.lean, line ~3043)

Available in context:
- `h_fwd_r1` : rank-(r+2) forward game
- `h_r1_univ` : rank-universal forward game factory (∀ r')
- `h_fwd_r3` : rank-(r+4) forward game (NEW)
- `rank_embed_comp` / `rank_embed_comp_N` : rank_embed transitivity
- `resp_tau, hresp_tau_in, hwin_tau` : tau strategy for init positions
- `γ_N, hγ_N_eq` : the gap in N
- `props : SplitPointProps` : all split-point infrastructure

## What Remains (S11 Gap Detection Assembly)

The sorry at line ~3043 needs:

1. **Gap existence in M**: Use `gap_char_formula D` (depth ≤ r+2) + `h_fwd_r1`
   (rank r+2) to show M has a D-defined gap γ_M in [x,y].

2. **Formula agreement**: Use `left_formula A D` / `right_formula A D` (depth ≤ r+4)
   + `h_fwd_r3` (rank r+4) to prove A^mu(γ_M) ↔ A^mu(γ_N) for stavi_depth A ≤ r.

3. **Response construction**: Set a'_resp(n) = Sum.inr γ_M, a'_resp(k) = resp_tau(k)
   for k < n.

4. **Winning condition assembly**: Same order type + gap point agreement + formula
   agreement from tau + gap properties.

## Build Verification

- `lake build` passes (1667 jobs, zero errors)
- Theorem6.lean: fully sorry-free (verified by `lean_verify`)
- CaseAnalysis.lean: 1 sorry at `ghr93_cases_III_IV` (gap detection assembly)
- No regressions in any other file

## Next Action

Implement the gap detection assembly in `ghr93_cases_III_IV`. The rank mismatch
is fully resolved; the remaining work is the mathematical content of Cases III/IV.
