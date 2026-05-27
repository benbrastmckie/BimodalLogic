# Phase 3C Handoff: U(B,A) Transfer for sel_pn_ord

**Date**: 2026-05-27
**Session**: sess_1748390400_orch155
**Phase**: 3C (U(B,A) Transfer)
**Status**: IN PROGRESS -- preparatory work done, core implementation pending

## What Was Done

1. Added `import Mathlib.Data.Fin.Tuple.Sort` to CaseAnalysis.lean
2. Added `h_r1_univ` parameter to `ghr93_case_II` (needed for higher-rank tau)
3. Updated call site in `ghr93_cases_II_III_IV` to pass `h_r1_univ`
4. Build passes with all existing sorries intact

## Immediate Next Action

Replace the e_n construction in `ghr93_case_II` with U(B,A) witness construction following GHR93 Theorem 12.8.15 Case II (pp. 443-444).

## Key Technical Details

### The Fan Problem (Why All 28 Previous Approaches Failed)

The sel_pn_ord sorry requires proving:
```
(a_init k < extendPoint p_n <-> resp_tau k < e_n) /\
(a_init k = extendPoint p_n <-> resp_tau k = e_n)
```

The issue: `a_init(k)` and `resp_tau(k)` come from the **tau game** on [d,y']/[c,y], while `p_n` and `e_n` come from the **d-compatible forward game** on [x,y]/[x',y']. These are separate games with no direct ordering relationship between tau positions and forward game positions. This creates a "fan": d <= a_init(k) AND d <= p_n, but no chain between a_init(k) and p_n.

### GHR93's Resolution (Theorem 12.8.15, p.444)

GHR93 does NOT construct e_n from a forward game. Instead:

1. Define B = X_{a_n} = conjunction of all rank-r formulas true at a_n (p_n)
2. Define A = X_{(a_{n-1}, a_n)} = disjunction of types realized in (a_{n-1}, a_n)
3. U(B,A) holds at a_{n-1} in N (witness: a_n itself)
4. tau at rank r+4 preserves U(B,A) (which has depth r+2 in our notation)
5. U(B,A) transfers to e_{n-1} in M
6. The U(B,A) M-side witness IS e_n: a point > e_{n-1} satisfying B

With this construction:
- e_n > e_{n-1} >= resp_tau(k) for all k < n-1 (from tau ordering)
- e_n > e_{n-1} = resp_tau(n-1) directly
- So resp_tau(k) < e_n for all k, making sel_pn_ord trivial

### Implementation Steps

#### Step 1: Construct Higher-Rank Tau (~40-60 lines)

From `h_r1_univ`, derive forward game at rank r+2 on the FULL interval [x,y]/[x',y']. Restrict to sub-interval [c,y]/[d,y'] (using strategy restriction). Apply IH to get backward game (tau) at rank r+4 with n rounds on [d,y']/[c,y].

Key type: `tau_r4 : ghr93_duplicator_wins N M atomMap n (r+4) (rank_embed .. d) (rank_embed .. y') (rank_embed .. c) (rank_embed .. y)`

Complication: The tau game at rank r+4 operates on `ExtendedCarrier M atomMap (r+4)`, not `ExtendedCarrier M atomMap r`. Need `rank_embed` to lift positions.

#### Step 2: Build B and A Formulas (~40-80 lines)

B = conjunction of all StaviFormulas of depth <= r true at p_n (using formula agreement from the existing game infrastructure). In practice, B can be taken as `sf_conjList [A | A in depth-r-formulas, A true at p_n]`.

Since there are finitely many inequivalent formulas at each depth (by NormalForm finiteness), this conjunction is finite and has depth <= r.

A = `sf_top` or a disjunction of types (simplification: if intermediate points just need to be mu-points, sf_top suffices since std_untl already requires mu-points).

Actually, std_untl semantics: exists s > t, mu_holds s /\ A^mu(s) /\ forall mu-point u in (t,s), B^mu(u).

For our purpose: A = B (the type), B_guard = sf_top. Formula = std_untl B sf_top. This says: exists a future mu-point satisfying B, with no constraint on intermediate points.

Depth: max(stavi_depth B, stavi_depth sf_top) + 2 = max(r, 0) + 2 = r + 2.

#### Step 3: Show U(B, sf_top) Holds at a_init(k) in N (~30-50 lines)

With sorted distinct selections: a_init(k) < p_n for all k < n.
p_n is a mu-point (since it's extendPoint p_n).
p_n satisfies B (by definition -- B is the conjunction of rank-r formulas true at p_n).
All intermediate mu-points trivially satisfy sf_top.
So U(B, sf_top) holds at a_init(k) with witness p_n.

But wait: this is in ExtendedCarrier at rank r, and U(B, sf_top) has depth r+2. The formula is evaluated as stavi_temporal_truth_mu at rank r+2 (not rank r). Need to lift a_init(k) and p_n to rank r+2 via rank_embed.

#### Step 4: Transfer via Higher-Rank Tau (~40-60 lines)

tau_r4 gives formula agreement at depth <= r+4 >= r+2.
So U(B, sf_top) transfers from a_init(k) (N-side) to resp_tau(k) (M-side).

#### Step 5: Extract Ordering (~30-50 lines)

U(B, sf_top) at resp_tau(k) in M means: exists w > resp_tau(k), mu_holds w, w satisfies B.
This gives resp_tau(k) < w for some w. But we need resp_tau(k) < e_n specifically.

**Critical issue**: We need to either:
(a) Define e_n AS this witness w (restructure e_n construction)
(b) Show that the existing e_n > resp_tau(k) using the witness w indirectly

Option (a) requires replacing the d-compatible forward game e_n with the U(B,A) witness. This is a major restructuring of ghr93_case_II.

Option (b) doesn't work directly -- w != e_n in general.

### Recommended Approach: Replace e_n Construction

Following GHR93 exactly: e_n IS the U(B,A) witness. Do NOT use the d-compatible forward game for e_n.

Steps:
1. Sort selections (WLOG monotone)
2. Play tau on a_init(0)..a_init(n-1) -> get resp_tau(0)..resp_tau(n-1)
3. Build B = type formula of p_n at rank r
4. Build U(B, sf_top) at depth r+2
5. Show U(B, sf_top) holds at a_init(n-1) (or each a_init(k))
6. Transfer via tau_r4 to resp_tau(n-1) (or each resp_tau(k))
7. Extract witness: e_n = some mu-point > resp_tau(n-1) satisfying B
8. e_n satisfies B = same rank-r type as p_n -> formula agreement at rank r
9. e_n is a mu-point = actual carrier point -> gap/point agreement
10. resp_tau(k) < e_n for all k -> sel_pn_ord trivially True <-> True
11. Assemble winning condition using e_n, resp_tau, and the tau + formula data

### What the Current e_n Gives vs What We Need

Current e_n from d-compatible forward game provides:
- hform_en_an: formula agreement between e_n and p_n at rank r (GOOD)
- he_n_in: e_n in [x, y] (GOOD)
- hord_cd_en_pn: (c < e_n <-> d < p_n) (GOOD but insufficient)
- hord_big at (1+k, b): resp_tau(k) < e_n <-> a'_big(k) < p_n (USELESS without a'_big < p_n)

New e_n from U(B,A) witness would provide:
- e_n > resp_tau(n-1) >= resp_tau(k) for all k (GIVES sel_pn_ord)
- e_n satisfies B = same rank-r formulas as p_n (GIVES formula agreement)
- e_n is an actual point (mu-point witness) (GIVES gap/point agreement)
- e_n in [c, y] (from tau's sub-interval) (GIVES interval containment)

### Blast Radius

Replacing e_n construction affects lines ~1218-1340 of CaseAnalysis.lean (current big game setup). The entire block from "Step 3: Construct e_n" through the forward game ordering extraction would be replaced. The same_order_type_grid dispatch (lines ~1380-1500 for Case A, ~1700-2080 for Case B) would be SIMPLIFIED because sel_pn_ord becomes trivial.

### Files Modified

- `CaseAnalysis.lean`: Import + h_r1_univ parameter (DONE), e_n restructuring (TODO)
- No other files need changes.

### Current Sorry Sites Affected

| Line | Description | Status After Phase 3C |
|------|-------------|----------------------|
| 1444 | Case A sel_pn_ord | CLOSED (trivial True <-> True) |
| 1813 | Case B sel_pn_ord | CLOSED (same argument) |
| 2077 | Case B dead code sorry | CLOSED (restructured) |
| 2015 | Case B b_resp vs p_n | NEEDS SEPARATE ANALYSIS |

The b_resp vs p_n sorry (line 2015) may or may not be closed by the U(B,A) approach. It involves b_resp from the tau Round 2, not from tau Round 1 selections. This needs separate investigation.

## Proof State

The file builds successfully with:
- `import Mathlib.Data.Fin.Tuple.Sort` added
- `h_r1_univ` parameter added to `ghr93_case_II`
- All existing sorries still present
- No regressions

## Estimated Remaining Work

4-8 hours for the full e_n replacement + sel_pn_ord closure.
