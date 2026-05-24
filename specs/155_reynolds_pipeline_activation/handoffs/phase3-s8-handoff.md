# Phase 3 Handoff: S8/S9/S10 Analysis

**Date**: 2026-05-24
**Session**: sess_1779640471_03278b

## Finding

S8 (line 6695) requires proving cross-boundary ordering goals between elements from different sub-games (sigma on [x',d]×[x,c], tau on [d,y']×[c,y], forward on [x,y]×[x',y']).

The specific missing relationships are:
1. `(extendPoint b_resp < extendPoint p_n ↔ extendPoint b_sp < e_n)` — b_resp/b_sp vs p_n/e_n
2. `(extendPoint p_n < extendPoint b_resp ↔ e_n < extendPoint b_sp)` — p_n/e_n vs b_resp/b_sp (reverse)
3. `(a_bwd(i-1) < a_bwd(j-1) ↔ resp_tau(i-1) < e_n)` — tau sel vs e_n/p_n
4. `(extendPoint p_n < a_bwd(j-1) ↔ e_n < resp_tau(j-1))` — p_n/e_n vs tau sel

## Root Cause

These goals require pivoting between b_resp/b_sp and p_n/e_n through d/c:
- `b_resp ≤ d` (from hb_resp_in.2) and `d ≤ p_n` (from h_no_split + hab_n) — N-side chain OK
- `b_sp ≤ c` (from hbc) and **`c ≤ e_n` is NOT available** — M-side chain BROKEN

The forward game produces `e_n` from `hwin_fwd p_n hp_n_in`, but the forward game's `a_M(n) = c` and `e_n_pt` are related only via the winning condition (same_order_type at position n+1 vs n+2 gives `c < e_n ↔ a_N(n) < p_n`). Since `a_N ≠ a_bwd` in general, we cannot derive `a_N(n) ≤ p_n` from `h_no_split`.

## GHR93 Alignment

In GHR93 Case II, e_n is constructed via U(B,A) transfer:
1. From N |= U(B,A)(alpha_{n-1}), transfer via tau to M |= U(B,A)(resp_tau(n-1))
2. Find z > resp_tau(n-1) with M |= B(z) and A on (resp_tau(n-1), z)
3. Set e_n = z

Since resp_tau(n-1) ≥ c (from hc_le_rtau), e_n = z > resp_tau(n-1) ≥ c. So c < e_n BY CONSTRUCTION.

The formalization instead gets e_n from the forward game (hwin_fwd p_n), which does NOT preserve c ≤ e_n.

## Resolution

The fix requires restructuring Case II to construct e_n via U(B,A) transfer (matching GHR93) rather than from the forward game. This is a significant restructure (~200-400 lines). The forward game is currently used for formula agreement at e_n/p_n, but in GHR93, formula agreement at e_n/p_n comes from B(e_n) = B(p_n) (both satisfy the same rank-r formula B = X_{alpha_n}).

This is ANOTHER consequence of the predicate-vs-formula divergence: GHR93 can say "B(e_n)" because B is a formula. The formalization would need formula agreement from the forward game or a restructured construction.

## Sorry Count at S8

The sorry at line 6695 covers approximately 6 sub-goals (multiple case branches from a split_ifs). These are all cross-boundary ordering goals with the same root cause (c ≤ e_n unavailable).

## Recommendation

S8/S9/S10 are BLOCKED on the same architectural issue as S1/S2: the formalization diverges from GHR93 by using the forward game for e_n construction instead of U(B,A) transfer. The correct fix aligns with the cont_holds→formula refactoring: with C as a formula, the e_n construction follows GHR93 exactly and c < e_n holds by construction.

Do NOT attempt to patch S8 without addressing the underlying architectural divergence.
