# Phase 3C Handoff: sel_pn_ord Definitive Analysis (Cycle 3)

**Date**: 2026-05-27
**Session**: sess_1748390400_orch155
**Phase**: 3C (U(B,A) Transfer)
**Status**: BLOCKED -- sel_pn_ord unprovable from current e_n construction

## Summary

Exhaustive analysis confirms that `sel_pn_ord` CANNOT be derived from the existing hypotheses at line 1450 of CaseAnalysis.lean. The problem is a fundamental structural mismatch between the tau game (which provides `a_init/resp_tau` correspondence) and the d-compatible forward game (which provides `p_n/e_n` correspondence). No combination of the available hypotheses can bridge this gap.

## The Exact Proof Obligation

```lean
-- Goal at line 1450:
-- Given: all hypotheses from the tau game, the d-compatible forward game,
-- sigma game (Case A), and derived cross-boundary orderings.
-- Prove:
forall (k : Fin n),
  (a_init k < extendPoint p_n <-> resp_tau k < e_n) /\
  (a_init k = extendPoint p_n <-> resp_tau k = e_n)
```

## Why It Cannot Be Proved

### The Fan Problem

The available hypotheses give:
1. `d <= a_init k` and `d <= extendPoint p_n` (fan from d)
2. `c <= resp_tau k` and `c <= e_n` (fan from c)
3. `d < a_init k <-> c < resp_tau k` (tau_d_sel: d-to-sel ordering)
4. `d < extendPoint p_n <-> c < e_n` (hord_cd_en_pn: d-to-pn ordering)

These create two "fans": d -> {a_init k, p_n} and c -> {resp_tau k, e_n}. The ordering between the two branches of each fan is NOT determined.

### Case Analysis

- **Case d = a_init k and d = p_n**: Trivially provable (both sides False/equal). OK.
- **Case d = a_init k and d < p_n**: Provable by chaining through d/c. OK.
- **Case d < a_init k and d = p_n**: Provable by chaining through d/c. OK.
- **Case d < a_init k and d < p_n**: UNPROVABLE. Both a_init(k) and p_n are strictly above d, with no ordering between them derivable from any hypothesis.

### Approaches Attempted This Cycle

1. **pivot_chain_order'**: Requires a chain a <= p <= b. The fan d -> {a_init k, p_n} has no chain.

2. **Big game ordering**: `hord_big` at positions (1+k, b-position) gives `resp_tau(k) < e_n <-> a'_big(k) < p_n`. But `a'_big(k)` (the N-response in the forward game) != `a_init(k)` in general. Both have the same rank-r type as `resp_tau(k)`, but same type does not imply same ordering relative to p_n.

3. **Tau at e_n_pt**: Instantiating `hwin_tau` with `e_n_pt` gives `b_tau_resp` in [d,y'] and ordering `a_init(k) < b_tau_resp <-> resp_tau(k) < e_n`. This gives sel_pn_ord if `b_tau_resp = p_n`, but we cannot guarantee this.

4. **Double game combination**: Combining tau-at-e_n_pt with the big game gives `a_init(k) < b_tau_resp <-> a'_big(k) < p_n`, which does NOT give `a_init(k) < p_n <-> a_init(k) < b_tau_resp`.

5. **Ordering transitivity through d, y', x, x'**: All attempted pivot chains either require the fan to be a chain (which it isn't) or introduce NEW surrogate points that have the same problem.

6. **Formula agreement approach**: `b_tau_resp` and `p_n` have the same rank-r type (transitivity through e_n). But same rank-r type does NOT imply same ordering relative to a_init(k) in dense linear orders. (Counterexample: DLO with rank-0 type; all points have the same type but can be anywhere.)

### Affected Sorry Sites

All share the same root cause:

| Line | Description | Root Cause |
|------|-------------|------------|
| 1450 | sel_pn_ord Case A | Fan: d -> {a_init k, p_n} |
| 1819 | sel_pn_ord Case B | Same as 1450 |
| 2030 | b_resp vs p_n Case B | Fan: d -> {b_resp, p_n} (same structure) |
| 2083 | Dead code Case B grid | Already commented out; would have same issue |

## The ONLY Resolution: Restructure e_n

The mathematical resolution (from GHR93 pp.443-444) is to redefine `e_n` so that `resp_tau(k) < e_n` is provable for all k, making sel_pn_ord trivially True <-> True.

### GHR93 Approach (U(B,A) Witness)

1. Sort selections: a_init(0) <= ... <= a_init(n-1) (WLOG via ghr93_winning_condition_perm)
2. Build B = type formula of p_n at rank r (requires formula materialization)
3. Show `std_untl B sf_top` holds at a_init(n-1) in N (witnessed by p_n)
4. Build rank-(r+2) backward game tau_r2 on [d,y']/[c,y] via h_ih_r2
5. Transfer `std_untl B sf_top` from a_init(n-1) to resp_tau(n-1) via tau_r2
6. Extract witness: e_n_new > resp_tau(n-1) with same rank-r type as p_n
7. Since sorted: resp_tau(n-1) >= resp_tau(k) for all k
8. Therefore e_n_new > resp_tau(k) for all k

### Why This Is Hard

- **Formula materialization**: rank_type is a Set StaviFormula. Materializing it as a SINGLE StaviFormula requires enumerating all formulas at depth <= r and taking their conjunction. This requires finiteness of StaviFormula equivalence classes at depth r.
- **std_untl depth**: std_untl B sf_top has depth max(depth B, 0) + 2 = r + 2. The rank-(r+2) game preserves formulas at depth <= r+2, so the transfer works.
- **Sorting assumption**: Requires sorting a_init and showing resp_tau inherits the sorting via same_order_type. ghr93_winning_condition_perm is available for permutations.
- **Blast radius**: Replacing e_n affects ~120 lines of construction (lines 1240-1360) plus the downstream code that uses e_n properties (formula agreement, cross-boundary ordering, interval containment). Total estimated change: 250-400 lines.

## Immediate Next Action for Future Cycle

1. Read TypeFormulas.lean lines 800-1043 for `rank_type_finite` or similar finiteness lemma
2. Determine if rank_type can be materialized as a StaviFormula conjunction
3. If yes: implement the full GHR93 U(B,A) construction per the plan
4. If no: need to first prove StaviFormula finiteness at each depth

## Key Files

- `CaseAnalysis.lean` lines 1200-1450, 1770-1830, 2025-2035 — sorry sites
- `TypeFormulas.lean` lines 340-400 — rank_type, stavi_temporal_truth_mu for std_untl
- `CustomGame.lean` lines 1591-1650 — ghr93_winning_condition_perm
- `SplitPoint.lean` lines 85-112 — SplitPointProps structure

## Files Modified This Cycle

None — this cycle was pure analysis confirming the blocker.
