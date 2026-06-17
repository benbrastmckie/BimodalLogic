# Handoff: Phase 4d Dispatch 2 - Infrastructure for Fraisse Game Argument

**Session**: sess_1781728602_b12f5c
**Date**: 2026-06-17
**Phase**: 4d (dispatch 2 of N)

## Immediate Next Action

Implement the Fraisse game argument (simultaneous induction on depth and arity)
to prove `exist_transfer_3var_nonconstenv`. The infrastructure is now in place:
hex_t extraction, h_surj threading, and nf_depth0_char_formula import. The next
dispatch should focus on writing a `fraisse_depth_arity_induction` lemma that
proves n-var existential transfer from (n-1)-var transfer at higher depth plus
1-var transfer at even higher depth.

## Current State

- **Phase 4d**: BLOCKED on Fraisse game argument (depth-arity recursion)
- **Sorry count**: 4 in PriorComposition.lean (lines 300, 320, 413, 491)
- **Build status**: `lake build` passes (full project, 1758 jobs)
- **Total sorry in Theories/**: 789 (net change: -1 from baseline 790)

## Work Done This Dispatch

### 1. hex_t Extraction (exist_transfer_3var_nonconstenv)

Added extraction of depth-(K+1) 2-var existential transfer anchored at t/t'
(symmetric to existing hex_x). This gives TWO partial witnesses for the forward
direction:
- c_x: depth-(K+1) 2-var at [y,x]/[c_x,x']. Knows y's predicates and y-vs-x order.
- c_t: depth-(K+1) 2-var at [y,t]/[c_t,t']. Knows y's predicates and y-vs-t order.

For the between-zone (t < y < x): c_x < x' and c_t > t'. If c_x > t' or c_t < x',
the witness is in (t', x'). For Case C (c_x <= t' AND c_t >= x'), Prior-UZ/SZ + 
temporal formulas are needed.

### 2. h_surj Threading

Added `h_surj : forall p : sig.preds, exists a : Atom, atomMap (.atom a) = p`
parameter to:
- `prior_nonconstenv_2var_agree_until`
- `prior_nonconstenv_2var_agree_since`
- `prior_2var_transfer_until`
- `prior_2var_transfer_since`

Updated KampBypass.lean call sites (lines 611, 678) to pass h_surj.

### 3. KampTranslation Import

Added `import Bimodal.Metalogic.WeakCanonical.Separation.KampTranslation` to
PriorComposition.lean. Opened `nf_depth0_char_formula` and
`nf_depth0_char_formula_correct`. No import cycle (verified by build).

### 4. Mathematical Analysis

Thoroughly analyzed the between-zone transfer problem. Key findings:

1. **Depth upgrade is impossible**: Cannot derive depth-(K+1) n-var from
   depth-K n-var + depth-(K+1) 1-var (confirmed by checking quantifier
   structure -- needs depth-K (n+1)-var which is circular).

2. **Zone decomposition is necessary**: For the between-zone (t < w < x),
   the two partial witnesses c_x (from hex_x) and c_t (from hex_t) are in
   the right zone relative to ONE anchor but not the other.

3. **Case C is genuine**: On Prior structures, it IS possible that c_x <= t'
   AND c_t >= x' (no partial witness in (t',x')), while M has w in (t,x).
   This requires the full Prior-UZ/SZ argument with temporal formulas.

4. **The K=0 base case has the SAME blocker**: The depth-0 3-var transfer
   (sorry at line 413) is not simpler than the general case. The purely
   atomic nature doesn't help because the zone-matching problem persists.

5. **The correct approach is the Fraisse game**: Simultaneous induction on
   (depth, arity) where the transfer at (K+1, n) uses (K, n+1) which uses
   (K-1, n+2) etc., terminating at depth 0 where everything is atomic.

## Key Decisions

### 1. h_surj is Essential (Confirmed)

The Prior-UZ/SZ axioms operate on temporal formulas. To express "point s has
predicate pattern P" as a temporal formula, we need atomMap surjectivity to
build atom_literal formulas. Without h_surj, Prior axioms cannot be applied
to predicate matching problems.

### 2. KampTranslation Import is Safe (Confirmed)

The import chain PriorComposition -> KampTranslation -> SemanticBridge ->
NormalForm does not create cycles. KampBypass (which imports PriorComposition)
already imports the Separation module through its KampBypassCore dependency.

### 3. Approach for Next Dispatch (Recommended)

The Fraisse game argument should be formalized as a mutual induction lemma:

```
fraisse_transfer (K n : Nat) :
  -- From depth-(K+n) 1-var agreement at each component
  -- plus depth-(K+i) (n-i+1)-var agreement for 0 <= i < n
  -- derive depth-(K+1) n-var existential transfer
```

The key insight: at each level of the recursion, the arity increases by 1
but the depth decreases by 1. The base case is depth 0, where n-var transfer
is purely atomic (all zones provable using cross_extend + constenv_transfer
for outside zones, and Prior-UZ/SZ + nf_depth0_char_formula for between-zone).

Estimated: 300-500 lines, 2-4 dispatch sessions.

## Sorry Inventory

| File | Line | Statement | Assumption | Why Deferred | Next Dispatch |
|------|------|-----------|------------|--------------|---------------|
| PriorComposition.lean | 300 | exist_transfer_3var_nonconstenv (fwd) | c_x or c_t is in correct zone OR Prior-UZ/SZ finds witness in between-zone | Fraisse game: depth-K 4-var transfer circular without simultaneous (depth, arity) induction | Implement fraisse_transfer lemma |
| PriorComposition.lean | 320 | exist_transfer_3var_nonconstenv (bwd) | Symmetric to forward | Same | Same |
| PriorComposition.lean | 413 | prior_nonconstenv_2var_agree_until K=0 | Depth-0 3-var transfer for between-zone | Same root cause: between-zone at any depth requires higher-arity transfer at lower depth | Same |
| PriorComposition.lean | 491 | prior_nonconstenv_2var_agree_since K=0 | Mirror of Until | Same | Same |

## Files Modified

- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorComposition.lean`:
  - Added KampTranslation import and opened nf_depth0_char_formula
  - Added h_surj parameter to 4 theorems
  - Added hex_t extraction to exist_transfer_3var_nonconstenv
  - Restructured forward/backward proofs to extract c_t alongside c_x
  
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampBypass.lean`:
  - Updated 2 call sites to pass h_surj to prior_2var_transfer_until/since

## References

- Prior handoff: `specs/303_k_gt_0_depth_induction/handoffs/phase-4d-zone-analysis-handoff.md`
- Research: `specs/303_k_gt_0_depth_induction/reports/12_fraisse-game-analysis.md`
- Parallel sorry: `StaviCompleteness.lean:2421` (same mathematical problem)

## Estimated Remaining Effort

| Step | Lines | Sessions |
|------|-------|----------|
| Fraisse game mutual induction lemma | ~300 | 2-3 |
| Apply to exist_transfer_3var_nonconstenv | ~100 | 1 |
| Apply to K=0 base case | ~50 | 0.5 |
| Thread through call chain verification | ~50 | 0.5 |
| Total | ~500 | 4-5 |
