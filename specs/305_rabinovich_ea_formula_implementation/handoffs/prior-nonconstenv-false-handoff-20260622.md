# Handoff: prior_nonconstenv_2var_agree Is FALSE

**Date**: 2026-06-22
**Session**: sess_1750620000_orch305b
**Agent**: lean-implementation-hard-agent
**Status**: BLOCKED -- theorem statement is false

## Key Discovery

`prior_nonconstenv_2var_agree_until` (PriorComposition.lean line 808) is **FALSE at K=0** and consequently **FALSE at ALL K** (since the recursion on K bottoms out at K=0). The sorry at line 869 is not "hard to prove" -- the theorem's conclusion contradicts its hypotheses on a concrete counterexample.

## Counterexample

**Structure**: Z (integers) with one unary predicate "is_even"

**Parameters**:
- M = N = (Z, <, is_even)
- atomMap maps the single atom to is_even
- t = t' = 0
- x = 4, x' = 2

**Hypotheses satisfied**:
- Prior-UZ/SZ hold on Z (every future/past occurrence has a first/last occurrence on well-ordered integers)
- h_x: depth-2 1-var NFs at x=4 and x'=2 agree (both are even; the translation z -> z+2 is an automorphism of (Z, is_even), so depth-k NF at z depends only on z mod 2)
- h_t: depth-2 1-var NFs at t=0 and t'=0 agree (trivially, same point type)
- h_order_M: t < x (0 < 4)
- h_order_N: t' < x' (0 < 2)

**Conclusion fails**: The depth-2 2-var NF at [x,t] = [4,0] differs from the depth-2 2-var NF at [x',t'] = [2,0]:
- At [4,0]: the depth-0 3-var quantifier condition "exists w in (0,4) with is_even(w)" holds (w=2)
- At [2,0]: the depth-0 3-var quantifier condition "exists w in (0,2) with is_even(w)" fails (only 1 in (0,2), which is odd)
- Therefore the depth-1 2-var NFs at [4,0] and [2,0] differ (different quantifier truth values)
- Therefore the depth-2 2-var NFs also differ

## Scope of Falsity

The same counterexample proves the following theorems are FALSE:

| Theorem | File | Line | False Because |
|---------|------|------|---------------|
| prior_nonconstenv_2var_agree_until | PriorComposition.lean | 808 | K=0 case: zone-3 existential fails |
| prior_nonconstenv_2var_agree_since | PriorComposition.lean | 911 | Mirror of Until |
| zone_compatible_witness (d=0) | PriorComposition.lean | 642 | Same zone-3 issue at depth 0 |
| zone_compatible_witness (d=1) | PriorComposition.lean | 647 | Calls nf_eval_from_lower_agree (d=0) |
| nf_eval_from_lower_agree (d=0) | PriorComposition.lean | 507 | Zone-3 quantifier transfer at depth 0 |
| zone3_exist_transfer | WitnessCount.lean | 219 | Direct zone-3 predicate transfer |
| k0_depth1_2var_agree_until | WitnessCount.lean | 262 | Depends on zone3_exist_transfer |
| k0_depth1_2var_agree_since | WitnessCount.lean | 293 | Mirror |

The recursion in prior_nonconstenv_2var_agree_until/since goes K -> K-1 -> ... -> 0. Since K=0 is false, ALL K values are false.

## Impact on Sorry Chain

```
completeness_discrete (SORRY-FREE in itself)
  -> ... -> existPart_succ_n1_bypass (k' + 1 case, line 646/713)
    -> prior_2var_transfer_until/since (PriorComposition.lean line 999/1032)
      -> prior_nonconstenv_2var_agree_until/since (K = k')
        -> recursion ... -> K = 0 -> FALSE
```

The sorry chain is broken at a FALSE intermediate lemma. The top-level theorem (existPart_succ_n1_bypass) IS true (it's from Rabinovich's paper, Section 5). The issue is the proof strategy, not the theorem.

## Correct Fix Architecture

The backward direction of `existPart_succ_n1_bypass` at k>=1 currently uses:
```
Formula A = char_kp1(nf_t0) AND (char_kp1(nf_x0) U top)
Backward: temporal_truth M t A -> extract x with nf_x0 type -> prior_2var_transfer_until
```

The formula A is TOO WEAK: it only encodes endpoint types, not zone-3 witnesses. The backward direction needs zone-3 witnesses but the formula doesn't provide them.

**Correct formula**: A should include VecEA2 bracket encoding of zone-3 witnesses:
```
A = char_kp1(nf_t0) AND enriched_bracket(sub_nf) U char_kp1(nf_x0)
```
where `enriched_bracket(sub_nf)` is a BracketFormula encoding all zone-3 witnesses from sub_nf's quantifier conditions. The bracket semantics guarantee witnesses are in the correct interval (between t and x) by construction.

**Template**: The k=0 case (`existPart_succ_n1_bypass_k0`) already implements this pattern:
- `enriched_bypass_until` (KampBypassCore.lean:511) builds VecEA2 with brackets
- `backward_holdsLeft_of_nf_eval` (KampBypassUntil.lean:19) proves backward direction
- `forward_nf_eval_of_holdsLeft` (KampBypassUntil.lean:373) proves forward direction

The generalization from k=0 to k>=1 requires:
1. Bracket point types: use `char_fn` at depth k (not depth 0) for witness type encoding
2. Bracket segment types: encode negative zone-3 conditions using `char_fn` formulas
3. Deeper quantifier conditions: the depth-(k+1) sub_nf has nested quantifier structure that must be encoded in the bracket hierarchy

## Estimated Effort for Fix

- Research: 2-3 hours (design enriched bracket generalization, understand depth-k bracket semantics)
- Plan: 1 hour (revise plan v18 to v20 with correct architecture)
- Implementation: 4-8 hours (modify KampBypass.lean backward direction, prove bracket correctness)
- Total: 7-12 hours across 3-5 dispatches

## Immediate Next Action

1. Research dispatch: design the enriched bracket formula for k>=1 backward direction
2. Plan v20: restructure around VecEA-mediated backward direction in KampBypass.lean
3. Implementation: modify `existPart_succ_n1_bypass` k'+1 case

## References

- Plan v18: specs/305_rabinovich_ea_formula_implementation/plans/18_nf-vecEA-bridge-plan.md
- KampBypass.lean lines 477-648 (existPart_succ_n1_bypass k'+1 case)
- KampBypassCore.lean lines 511-524 (enriched_bypass_until template)
- PriorComposition.lean lines 808-908 (false theorem)
- Rabinovich 2014, Section 5 (correct proof architecture)
