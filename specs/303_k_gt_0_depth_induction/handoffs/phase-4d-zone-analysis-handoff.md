# Handoff: Phase 4d Zone Analysis and Architecture Design

**Session**: sess_1781728602_b12f5c
**Date**: 2026-06-17
**Phase**: 4d (depth-0 and general K between-zone transfer)

## Immediate Next Action

Add `atomMap`, `h_surj`, Prior axioms, and `CharPart(K+1)` as parameters to
`exist_transfer_3var_nonconstenv` in PriorComposition.lean. Then prove the between-zone
(zone 3) case using CharPart + Prior-UZ to find a witness in (t', x').

## Current State

- **Phase 4d**: BLOCKED on between-zone transfer
- **Sorry count**: 4 in PriorComposition.lean (lines 289, 297, 380, 457)
- **Build status**: `lake build` passes
- **New infrastructure**: `depth0_3var_witness_check` (sorry-free helper for zone-based proof)

## Key Decisions

### 1. Architecture Assessment (Confirmed)

The 4 sorry sites have a SINGLE root cause: `exist_transfer_3var_nonconstenv` is stated
without Prior hypotheses, but the between-zone (t < w < x) REQUIRES Prior-UZ/SZ.

The same mathematical problem exists in StaviCompleteness.lean at line 2421
(`nf_2var_existential_transfer` has sorry for depth j+1 4-var transfer).

### 2. Zone Decomposition (Zones 1,2,4,5 Proved)

For `∃ w, nf_eval M 0 3 [w,x,t] ssn3 ↔ ∃ w', nf_eval N 0 3 [w',x',t'] ssn3`:

| Zone | w vs (t,x) | Witness | Method | Status |
|------|-----------|---------|--------|--------|
| 1: w < t | below both | cross_extend_bwd(h_t) | w' < t' < x' | PROVED conceptually |
| 2: w = t | at t | t' | preds from h_t | PROVED conceptually |
| 3: t < w < x | between | UNKNOWN | Prior-UZ needed | BLOCKED |
| 4: w = x | at x | x' | preds from h_x | PROVED conceptually |
| 5: w > x | above both | cross_extend_bwd(h_x) | w' > x' > t' | PROVED conceptually |

The `depth0_3var_witness_check` helper verifies that a candidate witness satisfies the
depth-0 3-var NF given predicate and order matching.

### 3. Between-Zone Strategy (NOT Yet Implemented)

The between-zone requires a point in (t', x') with matching predicates. Two partial
witnesses exist:
- w_x from cross_extend(h_x): w_x < x', matching preds, but w_x vs t' unknown
- w_t from cross_extend(h_t): w_t > t', matching preds, but w_t vs x' unknown

If w_t < x' or w_x > t': done (one witness is in the interval).
If w_t >= x' AND w_x <= t' (Case C): need CharPart + Prior-UZ.

**Recommended approach for Case C**:
1. Use CharPart(K+1) to express w's depth-(K+1) 1-var NF type as temporal formula psi
2. Both w_t and w_x satisfy psi. Since w_t > t', psi holds above t' in N.
3. Apply Prior-UZ at t' with psi: get first s > t' with psi(s).
4. Show s < x' (this is the hard step — may need depth-1 structure of transfers)
5. s is the witness: s in (t', x') with matching predicates

### 4. CharPart Availability (Confirmed Well-Founded)

CharPart(K+1) is available when proving `prior_nonconstenv_2var_agree_until` at step K
because the mutual induction structure is:
```
CharPart(0) [sorry-free]
  → ExistPart(0) [uses prior_nonconstenv at K<0, vacuously]
    → CharPart(1) [sorry-free]
      → ...
        → CharPart(K+1) [available]
          → prior_nonconstenv_2var_agree at step K [USES CharPart(K+1)]
            → ExistPart(K+1)
```

No circularity. The key: ExistPart(K) uses prior_nonconstenv at strictly lower depth.

## Sorry Inventory

| File | Line | Statement | Assumption | Why Deferred | Next Dispatch |
|------|------|-----------|------------|--------------|---------------|
| PriorComposition.lean | 289 | exist_transfer_3var_nonconstenv (fwd) | c satisfies sub_nf at [c,x',t'] | Between-zone: c vs t' order unknown | Add Prior + CharPart params; zone decomposition |
| PriorComposition.lean | 297 | exist_transfer_3var_nonconstenv (bwd) | symmetric | Same as fwd | Same |
| PriorComposition.lean | 380 | prior_nonconstenv_2var_agree_until K=0 | depth-0 3-var transfer | Between-zone at depth 0 | Zone decomp + CharPart(0) + Prior-UZ |
| PriorComposition.lean | 457 | prior_nonconstenv_2var_agree_since K=0 | Same, mirrored | Same | Same |

## Files Modified

- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorComposition.lean`:
  Added `depth0_3var_witness_check` helper (sorry-free, ~50 lines)

## References

- Research report: `specs/303_k_gt_0_depth_induction/reports/12_fraisse-game-analysis.md`
- Plan: `specs/303_k_gt_0_depth_induction/plans/09_betweenzone-existpart-plan.md`
- Parallel sorry: `StaviCompleteness.lean:2421` (same mathematical problem)

## Estimated Remaining Effort

| Step | Lines | Sessions |
|------|-------|----------|
| Add Prior/CharPart params to exist_transfer | ~50 | 1 |
| Zone decomposition (non-between zones) | ~150 | 1-2 |
| Between-zone via CharPart + Prior-UZ | ~200 | 2-3 |
| Thread params through call chain | ~50 | 0.5 |
| Total | ~450 | 4-6 |
