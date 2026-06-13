# Backward Direction Analysis: nf_exist_formula_nested_backward

**Date**: 2026-06-12
**Session**: sess_1781325641_3569a1
**Agent**: lean-implementation-hard-agent
**Status**: blocked (formula insufficient)

## Summary

The sorry at NegationClosure.lean:1379 (`nf_exist_formula_nested_backward`) CANNOT be
filled with the current formula `nf_exist_formula_nested`. The formula is mathematically
insufficient for the backward direction.

## Root Cause

The formula `nf_exist_formula_nested` fires for any x whose depth-(k+1) 1-var NF `nf_x`
is atom-compatible and "fully compatible" with `sub_nf`. However, `nf_full_compat_right`
passes `true` for ALL atom-compatible non-interval ssns, regardless of `sub_nf.2 ssn`.
This means the formula fires even when the actual depth-(k+1) 2-var NF at (x, t) differs
from `sub_nf` in its quantifier part.

**Concrete failure**: The formula could fire for x with 1-var NF nf_x where the actual
2-var NF C = nf_characteristic M (k+1) 2 (x, t) has C.2 ssn = true but sub_nf.2 ssn =
false (or vice versa) for some atom-compatible ssn. In that case, h_formula is true but
no x satisfies sub_nf.

**Why composition doesn't help**: The generalized_composition theorem "same depth-(k+1)
1-var NFs + matching orders implies same depth-k n-var NFs" is FALSE (counterexample:
M = (Z, <), env1 = (0, 2), env2 = (0, 1), k = 1). So we cannot deduce the 2-var NF
at (x, t) from nf_x and parent_atoms alone.

## Zone Analysis (for Until case, t < x)

For each ssn : NormalForm sig k 3 in the quantifier condition `h_quant`:

### Zone 1: y > x > t

**Forward** (sub_nf.2 ssn = true -> exists y): At k=0, nf_x.2 (proj ssn to (y,x))
determines this. At k >= 1, the projection is more complex.

**Backward** (exists y -> sub_nf.2 ssn = true): Requires sub_nf to BE the actual char NF.

**Filter fix**: Add check `nf_x.2 (atomProjDrop 2 <2> ssn.1) == sub_nf.2 ssn` for y > x.
This works at k=0 because zone y > x > t has y > t by transitivity, so the 3-var
existential reduces to the 2-var existential at (y, x).

### Zone 2: y = x

The 3-var NF at (x, x, t) is fully determined by atoms (since y = x). If ssn is
atom-compatible with nf_x at var 0 AND nf_x at var 1 AND parent_atoms at var 2 AND
orders match, then y = x always exists as a witness. So sub_nf.2 ssn MUST be true for
atom-compatible y = x ssns.

**Filter fix**: For atom-compatible y = x ssns, require `sub_nf.2 ssn = true`.

### Zone 3: t < y < x (interval)

**Positive** (sub_nf.2 ssn = true): Formula provides y via Since conditions.
At k=0, atoms at (y, x, t) match ssn (preds from char_kp1(nf_y), orders from zone).
At k >= 1, need quantifier conditions too (not provided by the formula).

**Negative** (sub_nf.2 ssn = false): Formula does NOT prevent y from existing in (t, x).

**Fix needed**: Add guard conditions. At k=0, the guard at each r in (t, x) checks:
r does NOT have predicates matching any negative interval ssn at var 0. This works
because at k=0, the 3-var NF is purely atomic, and each preds(y) pattern corresponds
to exactly one interval ssn. At k >= 1, the guard can only check 1-var NF type, which
doesn't determine the full 3-var NF.

### Zone 4: y = t

Same analysis as zone 2: determined by atoms. Sub_nf.2 ssn must be true for
atom-compatible y = t ssns. Filter fix: require sub_nf.2 ssn = true.

### Zone 5: y < t < x

**Positive** (sub_nf.2 ssn = true): Need exists y < t with right preds/NF.
Not provided by the formula. At k=0, could use p2_0 formulas as conjunct at t.

**Negative** (sub_nf.2 ssn = false): Need not-exists y < t. Not encoded.

**Fix needed**: Add pre-condition at t using p2_k formulas. For sub_nf.2 ssn = true:
add the p2_k formula for the (y, t) projection. For sub_nf.2 ssn = false: add the
negation of the p2_k formula.

## Implementation Plan

### Phase A: Filter Strengthening (zones 1, 2, 4)

Modify `nf_full_compat_right` and `nf_full_compat_left`:
- Zone 1 (y > x): check `nf_x.2 (atomProjDrop 2 <2> ssn.1) == sub_nf.2 ssn`
  (only correct at k=0; need different check at k >= 1)
- Zone 2 (y = x): require `sub_nf.2 ssn = true` for atom-compatible ssns
- Zone 4 (y = t): require `sub_nf.2 ssn = true` for atom-compatible ssns

Also update `nf_full_compat_right_of_eval` to prove the actual x passes.

Estimated: ~150 lines

### Phase B: Guard Modification (zone 3 negatives)

Modify `build_event_guard_right/left` in `nf_exist_formula_nested`:
- Compute negative interval ssns: `sub_nf.2 ssn = false && ssn_in_interval_right ssn`
- For each, compute the set of compat nf_y preds
- Guard = conjunction of negations: ~disj[char_kp1(nf_y) | nf_y compat with neg ssn]

Estimated: ~100 lines for definition, ~200 lines for forward proof update

### Phase C: Zone 5 Pre-conditions

Modify `nf_exist_formula_nested` to add pre-conditions at t:
- For each y < t ssn: use `p2_k parent_atoms (proj_yt ssn)` formula
- Add as conjunct at t (before the Until)
- Requires passing p2_k to the formula constructor

Estimated: ~100 lines for definition, ~200 lines for forward proof update

### Phase D: Backward Proof (k=0)

With phases A-C complete, prove backward at k=0:
- Extract x from Until
- Atom part: from filter (unchanged from current analysis)
- Quantifier part: each zone handled by the corresponding fix
  - Zone 1: from filter + nf_x.2 projection
  - Zone 2: from filter (sub_nf.2 = true, witness is x)
  - Zone 3+: from guard (negatives prevented) + Since (positives provided)
  - Zone 4: from filter (sub_nf.2 = true, witness is t)
  - Zone 5: from pre-condition at t

Estimated: ~200-300 lines

### Phase E: Backward Proof (k >= 1)

At k >= 1, zones 1, 3, 5 are insufficiently handled because:
- Zone 1: nf_x.2 projection only gives necessary, not sufficient condition for 3-var NF
- Zone 3: guard checks 1-var NF type, not full 3-var NF
- Zone 5: p2_k formulas handle 2-var existentials, not 3-var

Fixing k >= 1 requires either:
(a) Adding P2(k, n) for all arities n to the mutual induction
(b) Implementing the full Rabinovich Section 5 proof at the formula level
(c) Finding the correct composition theorem for Prior structures (if one exists)

Estimated: 600-1000+ lines

## Recommended Next Steps

1. Implement Phase A (filter strengthening) -- lowest risk, helps all k
2. Implement Phases B-C (guard + zone 5) -- moderate risk, fixes k=0
3. Implement Phase D (backward at k=0) -- makes P2(1) sorry-free
4. Research Phase E approach before implementing

## Files Modified

- `NegationClosure.lean:1379` -- updated sorry comment with analysis
- This handoff document

## Sorry Inventory

| File | Line | Statement | Why Deferred |
|------|------|-----------|-------------|
| NegationClosure.lean | 1379 | nf_exist_formula_nested_backward | Formula insufficient; needs modification per this analysis |
| NfCharFormula.lean | 572 | nf_2var_exist_formula_prior | Dependent on NegationClosure.lean:1379 via master_induction |
