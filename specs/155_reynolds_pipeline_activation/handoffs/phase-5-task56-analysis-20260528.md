# Phase 5 Handoff: Tasks 5.6-5.8 Analysis

**Date**: 2026-05-28
**Session**: sess_1780001766_2e723d
**Phase**: 5 -- GHR93-Faithful Case II Rewrite (Path C)
**Status**: PARTIAL (Tasks 5.0-5.5, 5.8 completed; Tasks 5.6-5.7 blocked)

## Summary

Tasks 5.6-5.8 were analyzed in depth. Tasks 5.6 (delete tau_left/tau_right/forward game) and 5.7 (rewrite Round 2 with 5-way case split using resp_tau) are **mathematically infeasible** as specified. Task 5.8 (verification) confirms the current proof is axiom-clean and sorry-free.

## Why Tasks 5.6-5.7 Are Blocked

### The Biconditional Ordering Problem

The `same_order_type_of_cases` helper in EFGameTactics.lean requires `hord_sel_sel`:
```
forall (k k' : Fin (n+1)),
  (a_bwd k < a_bwd k' <-> a'_resp k < a'_resp k') /\
  (a_bwd k = a_bwd k' <-> a'_resp k = a'_resp k')
```

When `a'_resp(k) = resp_tau(k)` for k < n and `a'_resp(n) = e_n`, the pair (k, n) requires:
```
(a_init k < extendPoint p_n <-> resp_tau k < e_n) /\
(a_init k = extendPoint p_n <-> resp_tau k = e_n)
```

### Why tau_r Cannot Provide This

`tau_r` is a backward game on `[d, y'] -> [c, y]`. It maps `a_init` to `resp_tau` with orderings:
- `(a_init j < a_init j' <-> resp_tau j < resp_tau j')` -- YES (sel vs sel)
- `(d < a_init k <-> c < resp_tau k)` -- YES (endpoint)
- `(a_init k < y' <-> resp_tau k < y)` -- YES (endpoint)

But `p_n` and `e_n` are NOT positions in tau_r's game. tau_r provides NO orderings relative to p_n/e_n.

### Why tau_left IS Necessary

`tau_left` is a backward game on `[d, p_n] -> [c, e_n]`. It maps `a_init` to `resp_left` with orderings:
- `(a_init k < p_n <-> resp_left k < e_n)` -- THIS is the critical biconditional

Without tau_left (or an equivalent mechanism), the biconditional cannot be established. Three alternatives were analyzed and all fail:

1. **pivot_chain_order**: Requires `resp_tau(k) <= e_n` (unknown from tau_r)
2. **Forward game orderings**: Gives `(resp_tau(k) < e_n <-> a'_big(k) < p_n)` but `a'_big(k) != a_init(k)`
3. **Extended tau_r**: Playing tau_r with n+1 positions including p_n would give a different e_n

### Why tau_right Cannot Be Deleted Either

Case B2 (b_sp > e_n) needs `(p_n < b_resp <-> e_n < b_sp)`. tau_r gives `(d < b_resp <-> c < b_sp)` but NOT the p_n/e_n ordering. `pivot_chain_order` requires `p_n <= b_resp` which is unknown from tau_r.

### Why the Forward Game Cannot Be Replaced

`ghr93_construct_en` internally uses a forward game but returns a potentially DIFFERENT e_n (via `untl_witness_bounded`) without forward game ordering data. The orderings `hord_fwd_x_en`, `hord_fwd_en_y`, `hord_cd_en_pn`, `hform_fwd_x`, `hform_fwd_y`, `hgp_fwd_x`, `hgp_fwd_y` are ALL used in Round 2 dispatch and cannot be obtained from `ghr93_construct_en`.

## Current State

- `ghr93_case_II`: 733 lines (lines 1368-2136), sorry-free, axiom-clean
- `ghr93_construct_en`: proved (lines 1268-1357), axiom-clean, available as infrastructure
- `ghr93_untl_transfer`: proved (lines 1191-1250), axiom-clean, available as infrastructure
- `untl_witness_bounded`: proved (CharacteristicFormula.lean), axiom-clean
- Round 2 structure: Case A (sigma), Case B1 (tau_left, b_sp <= e_n), Case B2 (tau_right, b_sp > e_n)
- Build: passes
- Sorries in CaseAnalysis.lean: 1 (line 3318, Cases III/IV -- Phase 6 scope)

## What Tasks 5.0-5.5 Accomplished

The GHR93 Until approach infrastructure IS valuable even though it cannot replace the inline machinery:

1. **untl_witness_bounded**: Resolves the Until witness containment problem (z in (t, bound])
2. **ghr93_untl_transfer**: Transfers U(B,A) from N to M through tau at rank r+delta
3. **ghr93_construct_en**: End-to-end e_n construction via U(B,A) + bounded witness

These theorems are reusable infrastructure for any future proof that needs Until-based arguments in ExtendedCarrier.

## Recommendations

1. **Accept Phase 5 as PARTIAL**: Tasks 5.0-5.5 and 5.8 are done. Tasks 5.6-5.7 are blocked by a fundamental mathematical constraint.

2. **Proceed to Phase 6** (Cases III/IV): This is independent of the Phase 5 code transformation. The existing ghr93_case_II is sorry-free and correct.

3. **Future plan revision**: If a future plan revision wants to simplify ghr93_case_II, the approach should be to enhance `ghr93_construct_en` to ALSO return forward game ordering data (making it a combined constructor + ordering helper), OR to restructure `same_order_type_of_cases` to accept one-directional orderings with supplementary inequality proofs.

## Immediate Next Action

Proceed to Phase 6 (Cases III/IV gap handling) or Phase 7 (Transfer.lean wiring), both of which are independent of the Phase 5 code transformation.
