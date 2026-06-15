# Phase 2 Blocker: enriched_vecEA2_until Witness Ordering Bug

## Status
Phase 2 BLOCKED. The bracket sorry at KampBypass.lean:2096 is unprovable as stated due to a design flaw in `enriched_vecEA2_until`.

## Problem Statement

`enriched_vecEA2_until` builds a `BracketFormula n` where:
- `n = pos_between.length` (number of positive between_tx SSNs)
- `pointTypes i = nfPred atomMap h_surj (nf_y_proj (pos_between[i]))`
- `segmentTypes _ = seg_guard` (uniform)

`IntervalPattern.holds` requires strictly increasing witnesses `w_0 < w_1 < ... < w_{n-1}` where `w_i` satisfies `pointTypes i`.

For the backward direction (`∃ x, nf_eval → holdsLeft`), `h_eval_quant` provides witnesses for each positive between_tx SSN in `(t, x)`. But the witnesses are in the **model's linear order**, which may differ from the `pos_between` order (determined by `Fintype.elems.val.toList.filter`, which is model-independent).

For `n >= 2`, a model can have witness_0 > witness_1 (in the model) while `pos_between` lists SSN_0 before SSN_1. Then the backward direction requires witness_0 < witness_1 (matching pos_between order), which is false.

## Approaches Tried

1. **Direct proof with `split` on `IntervalPattern.holds`**: Produces HEq goals. The n+1 case requires ordered witnesses matching pos_between indices.
2. **Sorting witnesses**: Sorting by model order gives increasing witnesses but with wrong pointType assignments (sorted witness i satisfies alpha_{sigma(i)}, not alpha_i).
3. **Permutation equivalence for uniform segments**: Doesn't hold — IntervalPattern.holds is NOT permutation-invariant in the alpha array, even with uniform segment types.
4. **chainHolds recursive approach**: Requires finding each witness ABOVE the previous one, but witnesses may be in arbitrary model positions.

## Root Cause

The `enriched_vecEA2_until` definition uses `pos_between` in `Fintype.elems` order, but the formula it generates (via `bracketBuildRight`) uses nested `Until` which implicitly requires witnesses in left-to-right (increasing) order. The pos_between order and the model's witness order are unrelated.

## Proposed Fix

**Option A (recommended)**: Replace the bracket-based between_tx encoding with a conjunction of individual existentials:
```
formula_conjList (pos_between.map fun ssn =>
  Formula.untl (nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)) Formula.top)
∧ formula_conjList (neg_between.map fun ssn =>
  (Formula.untl (nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)) Formula.top).neg)
```
This mirrors how `above_x` and `eq_x` zones are already handled in `enriched_vecEA2_until`. Each positive between_tx SSN gets its own `Until` existential, independently. The `seg_guard` becomes explicit negation for negative SSNs. This avoids the ordering issue entirely because each existential is independent.

The `VecEA2` structure would have `n = 0` (no bracket witnesses) with the between_tx conditions folded into `endpointRight` or `endpointLeft`, or the bracket field could be replaced entirely.

**Option B**: Sort `pos_between` at proof time using model-dependent information. This is not possible because `enriched_vecEA2_until` is a `noncomputable def` that doesn't take the model as input.

**Option C**: Prove a permutation-invariance lemma for `IntervalPattern.holds` with uniform segment types. This does NOT hold in general (see analysis above), but might hold if we additionally require the existence of enough witnesses to cover all orderings. This adds complexity without clear benefit.

## Impact on Other Phases

- Phase 3 (forward direction): NOT affected. The forward direction extracts existentials from ordered witnesses, which works regardless of ordering.
- Phase 4 (since case): Affected similarly if it uses the same bracket construction. Check `enriched_vecEA2_since` definition.
- Phase 5 (verification): Blocked until Phases 2-4 complete.

## Sorry Inventory

| File | Line | Statement | Status |
|------|------|-----------|--------|
| KampBypass.lean | 2096 | backward_holdsLeft_of_nf_eval bracket case | BLOCKED (ordering bug) |
| KampBypass.lean | 2154 | forward_nf_eval_of_holdsLeft | Phase 3 (unaffected) |
| KampBypass.lean | 2266 | existPart_succ_n1_bypass_k0_since | Phase 4 (may be affected) |
| KampBypass.lean | 2354 | existPart_succ_n1_bypass (k>0) | Out of scope |

## Recommended Next Steps

1. **Spawn a research task** to investigate Option A: redesigning the between_tx zone encoding to avoid ordered bracket witnesses.
2. **Phase 3** can proceed independently — the forward direction does not have the ordering issue.
3. After the architectural fix, revisit Phase 2 with the new encoding.
