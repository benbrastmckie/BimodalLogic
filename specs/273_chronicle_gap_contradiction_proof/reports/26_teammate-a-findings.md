# Teammate A Findings: Zone-Aware Enriched Formula Soundness Defect

## Key Findings

### 1. Root Cause: Missing Transitivity and Equality Consistency Checks

The `ssn_xt_compatible` filter (KampBypass.lean:78-91) checks:
- Predicate compatibility at variables x and t
- The x-t order booleans match the expected zone (Until/Since/Eq)

It does **NOT** check:
- **Transitivity**: if ssn says y < t AND t < x, then ssn must say y < x
- **Equality consistency**: if ssn says y = x (both order(y,x)=F and order(x,y)=F), then y's order relative to t must match x's order relative to t

This allows 3-variable depth-0 NF values (ssn) that encode **unrealizable orderings** to pass the filter and generate incorrect formula conjuncts.

### 2. Exhaustive Enumeration of Defective SSN Values

For 3 variables (0=y, 1=x, 2=t) with 6 order booleans, there are 64 possible boolean assignments. Only 13 are realizable on a strict linear order. `ssn_xt_compatible` fixes 2 of the 6 booleans (the x-t pair), leaving 16 combinations per zone. Of these 16, exactly 5 are realizable in the Until zone (t < x):

| y<x | x<y | y<t | t<y | Zone | Ordering |
|-----|-----|-----|-----|------|----------|
| T   | F   | T   | F   | below_t    | y < t < x |
| T   | F   | F   | F   | eq_t       | y = t < x |
| T   | F   | F   | T   | between_tx | t < y < x |
| F   | F   | F   | T   | eq_x       | t < y = x |
| F   | T   | F   | T   | above_x    | t < x < y |

The 3 defective ssn values that pass `ssn_xt_compatible` but are unrealizable:

**Case A** (y<x=F, x<y=F, y<t=F, t<y=F): ssn says y=x AND y=t, implying x=t. But `ssn_xt_compatible` requires t<x (Until zone). Contradiction: x=t and t<x.
- `ssn_zone_until` classifies this as `eq_t`
- Enters `pre_conditions_at_t_until` with `zone == .eq_t`

**Case B** (y<x=F, x<y=F, y<t=T, t<y=F): ssn says y=x AND y<t. Since y=x and t<x (from filter), we get t<y. But ssn says NOT(t<y). Contradiction.
- `ssn_zone_until` classifies this as `below_t`
- Enters `pre_conditions_at_t_until` with `zone == .below_t`

**Case C** (y<x=F, x<y=T, y<t=T, t<y=F): ssn says x<y AND y<t. By transitivity x<t. But `ssn_xt_compatible` requires t<x. Contradiction.
- `ssn_zone_until` classifies this as `below_t`
- Enters `pre_conditions_at_t_until` with `zone == .below_t`

### 3. Impact on Formulas

When a defective ssn enters the zone formulas:
- If `sub_nf.2 ssn = true`: a formula for a non-existent existential is asserted (too strong)
- If `sub_nf.2 ssn = false`: the negation of a vacuously-true statement is asserted (makes the conjunction false when it should be true)

The negated case is worse: it can make `pre_conditions_at_t_until` evaluate to false at t even when all realizable ssn conditions are satisfied, breaking the backward direction of the correctness proof.

### 4. Since Direction Has Same Defect

The inline zone logic in `enriched_bypass_since` (lines 524-583) also processes unrealizable ssn values. With `ssn_xt_compatible(false, true)` (x < t), 4 defective ssn values pass both `ssn_xt_compatible` and pairwise y-checks, and ALL emit formulas:

| y<x | x<y | y<t | t<y | Problem | Emits |
|-----|-----|-----|-----|---------|-------|
| F   | F   | F   | F   | y=x, x<t => y<t but y_lt_t=F | pre_at_t(y=t) + pt_x(y=x) |
| F   | F   | F   | T   | y=x, x<t => NOT(t<y) but t_lt_y=T | pre_at_t(y>t) + pt_x(y=x) |
| T   | F   | F   | F   | y<x, x<t => y<t but y_lt_t=F | pre_at_t(y=t) + pt_x(y<x) |
| T   | F   | F   | T   | t<y AND y<x => t<x but x<t given | pre_at_t(y>t) + pt_x(y<x) |

### 5. Equality Direction Has Same Defect

The `enriched_bypass_eq` (lines 586-618) with `ssn_xt_compatible(false, false)` (x = t) has 6 defective ssn values where y's order relative to x differs from y's order relative to t, violating x=t. All 6 emit formulas:

| y<x | x<y | y<t | t<y | Problem | Emits |
|-----|-----|-----|-----|---------|-------|
| F   | F   | F   | T   | y=x but t<y, yet x=t | char_y direct |
| F   | F   | T   | F   | y=x but y<t, yet x=t | char_y direct |
| F   | T   | F   | F   | x<y but y=t => x<t, yet x=t | Until(char_y) |
| F   | T   | T   | F   | x<y but y<t, yet x=t | Until(char_y) |
| T   | F   | F   | F   | y<x but y=t => y<x=t, yet x=t | Since(char_y) |
| T   | F   | F   | T   | y<x but t<y, yet x=t | Since(char_y) |

### 6. ssn_zone_until Is Correct on Realizable Inputs

Importantly, `ssn_zone_until` classifies all 5 realizable Until orderings correctly. The defect is entirely in the **filter** not excluding unrealizable inputs, not in the zone classification logic itself.

## Recommended Approach

### Strategy: Add `ssn_order_consistent` filter to `ssn_xt_compatible`

The cleanest fix is to extend `ssn_xt_compatible` with a call to a new `ssn_order_consistent` function that checks all 3-variable order consistency. This is the single gatekeeper used at every site (13 call sites in KampBypass.lean).

### Proposed Definition

```lean
/-- Check that a 3-var depth-0 NF's order atoms are consistent with a
    strict linear order. Returns false for ssn values that encode
    unrealizable orderings (transitivity violations or equality
    inconsistencies).

    Variables: 0=y, 1=x, 2=t.

    Checks:
    1. Pairwise: NOT (order(i,j) AND order(j,i)) for all pairs
    2. Transitivity: order(i,j) AND order(j,k) => order(i,k)
    3. Equality: if NOT order(i,j) AND NOT order(j,i) then
       order(i,k) = order(j,k) AND order(k,i) = order(k,j) -/
noncomputable def ssn_order_consistent {sig : MonadicSignature}
    (ssn : NormalForm sig 0 3) : Bool :=
  let o01 := ssn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide))  -- y < x
  let o10 := ssn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide))  -- x < y
  let o02 := ssn (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide))  -- y < t
  let o20 := ssn (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide))  -- t < y
  let o12 := ssn (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide))  -- x < t
  let o21 := ssn (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide))  -- t < x
  -- 1. Pairwise consistency
  !(o01 && o10) && !(o02 && o20) && !(o12 && o21) &&
  -- 2. Transitivity (6 implications)
  (!o01 || !o12 || o02) &&   -- y<x AND x<t => y<t
  (!o02 || !o21 || o01) &&   -- y<t AND t<x => y<x
  (!o10 || !o02 || o12) &&   -- x<y AND y<t => x<t
  (!o20 || !o01 || o21) &&   -- t<y AND y<x => t<x
  (!o21 || !o10 || o20) &&   -- t<x AND x<y => t<y
  (!o12 || !o20 || o10) &&   -- x<t AND t<y => x<y
  -- 3. Equality consistency
  (o01 || o10 || (o02 == o12 && o20 == o21)) &&  -- y=x => same t-order
  (o02 || o20 || (o01 == o21 && o10 == o12)) &&  -- y=t => same x-order
  (o12 || o21 || (o01 == o02 && o10 == o20))     -- x=t => same y-order
```

### Integration Point

Add `&& ssn_order_consistent ssn` to `ssn_xt_compatible`:

```lean
noncomputable def ssn_xt_compatible {sig : MonadicSignature}
    (ssn : NormalForm sig 0 3)
    (nf_x_1var : NormalForm sig 0 1)
    (parent_atoms : AtomKind sig 1 → Bool)
    (x_gt_t x_lt_t : Bool) : Bool :=
  -- Existing checks...
  (predicate checks) &&
  (order checks) &&
  -- NEW: full order consistency
  ssn_order_consistent ssn
```

### Required Proof Updates

1. **New theorem `ssn_order_consistent_correct`**: If `ssn_order_consistent ssn = false`, then for all M, y, x, t: `not nf_eval_nf M 0 3 (y, x, t) ssn`. Proof uses `nf_3var_order_contradiction` (existing, for pairwise), plus new transitivity and equality lemmas.

2. **Existing proofs unchanged**: Since the filter only removes unrealizable ssn values, all existing proofs in the backward direction (semantic model implies formula) remain valid -- the ssn arising from actual model evaluation always passes the filter. Forward direction proofs only need to verify that filtered ssn values contribute vacuously true conjuncts.

3. **`zone_3var_exist_iff_1var` (line 814)**: The sorry here becomes easier because the filter guarantees only realizable orderings reach the case analysis.

### Alternative: Fix `ssn_zone_until` Directly

Instead of filtering upstream, one could modify `ssn_zone_until` to check transitivity with the fixed x-t order. However, this is harder because `ssn_zone_until` doesn't take x-t order as a parameter -- it's a standalone classification. Adding the filter to `ssn_xt_compatible` is both simpler and more robust (it protects all call sites uniformly, including the Since and equality directions which do inline zone logic).

## Evidence/Examples

### Concrete Counterexample (Case A, Until direction)

Consider a signature with one predicate `p` and the Until zone (t < x).

Let ssn encode the following 6 order booleans:
- y<x=F, x<y=F (y=x), y<t=F, t<y=F (y=t), x<t=F, **t<x=T**

`ssn_xt_compatible` with x_gt_t=true, x_lt_t=false checks:
- `ssn(.order(2,1)) == true`: ssn has order(2,1)=T (t<x), so T==T passes
- `ssn(.order(1,2)) == false`: ssn has order(1,2)=F, so F==F passes
- Predicate checks also pass (assuming compatible predicates)

Result: ssn passes `ssn_xt_compatible`. But the ordering is unrealizable:
- y=x (both order(0,1) and order(1,0) are false)
- y=t (both order(0,2) and order(2,0) are false)
- Therefore x=t, yet order(2,1)=T says t<x. Contradiction.

This ssn enters `pre_conditions_at_t_until` classified as `eq_t` zone. If `sub_nf.2 ssn = false`, a negated conjunct `neg char_y` is emitted. Since no actual witness y can satisfy this ssn, the negated formula is a constraint on a non-existent condition, potentially making the entire conjunction false when it should be true.

## Confidence Level

**High confidence** (95%+) in the defect analysis and filter design. The exhaustive enumeration covers all 64 possible 3-variable order assignments and all 16 combinations per fixed x-t zone. The filter was verified to pass exactly the 13 globally realizable orderings (5 per strict zone, 3 for equality zones with one pair).

The correctness proof strategy follows established patterns already in the codebase (`nf_3var_order_contradiction` for pairwise, extended to transitivity and equality).
