# Phase 3 Handoff: Option Evaluation Complete

**Session**: sess_1781374494_d4f20d
**Date**: 2026-06-13
**Status**: BLOCKED -- all three options reduce to Rabinovich negation closure

## What Was Done

1. Deep analysis of all three Phase 3 options (A, B, C) for resolving the base environment mismatch.
2. Improved documentation of the n>=2 sorry in existPart_succ (RabinovichGeneralized.lean:474) to clarify its dependency on the n=1 case via quantifier projection at mixed base.
3. Updated plan v26 Phase 3 with detailed option evaluation results.
4. Verified critical Kamp modules build clean (994 jobs, 0 errors).

## Option Evaluation Summary

### Option A (Generalize ExistPart to arbitrary bases): REJECTED

Generalizing ExistPart(k) from constant base `(fun _ => t)` to arbitrary base shifts the problem recursively:
- At depth k+1, the quantifier conditions with base (x, t) involve depth-k existentials with base (y, x, t)
- At depth k, the quantifier conditions with base (y, x, t) involve depth-(k-1) existentials with base (w, y, x, t)
- Each level adds one more variable to the base

The recursion does NOT simplify. The mutual induction would need ExistPart at ALL arity/base combinations simultaneously, which is the full Kamp theorem itself.

### Option B (Single ExistsForallSpec encoding): PARTIALLY VIABLE

The ExistsForallSpec translation (Prop 3.5, sorry-free) handles LINEAR witness sequences. The sentence `exists x, nf_eval_nf M (k+1) 2 (x, t) sub_nf` expands to a TREE of witnesses:
- x (outer existential)
  - For each positive ssn: y_i (inner existential)
    - For each positive sub-ssn: w_j (depth-k existential)
    - ...

The positive existential conditions can be encoded (each zone ordering gives a finite ExistsForallSpec). However, the NEGATIVE universals (`forall y, not nf_eval_nf ...`) require expressing `nf_eval_nf M k 3 (y, x, t) ssn` as a temporal formula at y with x and t as known reference points -- which is the SAME base-environment mismatch at one depth lower.

The negative conditions are precisely the negation closure content (Rabinovich Prop 4.2).

### Option C (Rabinovich Section 5 directly): BLOCKED (circular)

Rabinovich Section 5 proves negation closure (Prop 4.2) using:
1. The INF formula (Lemma 5.3) for finding infima of definable sets
2. Interval decomposition with temporal type classification
3. Prior-UZ/SZ for first/last occurrence semantics

Implementing this requires Prop 4.3 (every FO formula is V-exists-forall), which uses Prop 4.2 (negation closure) in the negation case. This creates the circularity: Prop 4.2 IS the mathematical content of the sorry we are trying to fill.

## Root Mathematical Obstacle

The base environment mismatch is mathematically equivalent to the Rabinovich negation closure problem (Prop 4.2). All three options reduce to it. The core issue:

- `ExistPart(k)` provides temporal formulas for `exists y, nf_eval_nf M k (n+1) (Fin.cons y (fun _ => t)) ssn` with ALL base variables equal to t
- The quantifier conditions at depth k+1 require `exists y, nf_eval_nf M k 3 (Fin.cons y (Fin.cons x (fun _ => t))) ssn` where base = (x, t) with x != t
- The abstract composition theorem that could bridge this (same 1-var NFs + order => same n-var NFs) is FALSE (counterexample documented in NfComposition.lean)
- The on-Prior-structures version might be true but requires the full Rabinovich Section 5 argument to prove

## Viable Paths Forward

1. **Implement full Rabinovich Section 5** (~600-1000 lines). This is the paper's actual proof but requires substantial new code: INF formula, interval decomposition, type classification, and the negation closure argument. This is the most principled approach but the highest effort.

2. **Find a novel mathematical insight** that avoids negation closure. Possible angles:
   - Use the fact that we're proving EXISTENCE (classical), not construction. Maybe a counting argument on the finite NF types suffices.
   - Use the depth-(k+2) 1-var NF of t (which records depth-(k+1) 2-var existentials). The condition is a finite Boolean function of the depth-(k+2) type. By P1(k+1) we can distinguish among depth-(k+1) types but NOT depth-(k+2) types.
   - Prove a WEAKER statement that still suffices for the Kamp theorem (e.g., expressiveness modulo a fixed set of NF types).

3. **Plan revision** to declare Phase 3 BLOCKED and pivot to a different proof architecture (e.g., EF-game-based approach from DiscreteStaviCompleteness.lean, or a syntactic separation theorem approach).

## Sorry Inventory

| File | Line | Statement | Assumption | Why Deferred | Next Dispatch |
|------|------|-----------|------------|-------------|--------------|
| NegationClosure.lean | 1712 | nf_exist_formula_nested_backward | Non-interval zone quant conditions | Requires Rabinovich negation closure (Prop 4.2) | Implement Section 5 or find bypass |
| RabinovichGeneralized.lean | 474 | existPart_succ n>=2 at k+1 | Depends on n=1 result | n=1 has same root blocker | Same as above |
| RabinovichNegation.lean | 291 | nf_2var_exist_formula_prior_neg k+1 | Same root cause | Same | Same |
| RabinovichWiring.lean | 359 | nf_2var_exist_via_rabinovich k+1 | Same root cause (also pre-existing build errors) | Same | Same |
| NfCharFormula.lean | 572 | nf_2var_exist_formula_prior | Same root cause | Same | Same |

## Key Files

- `RabinovichGeneralized.lean:474` -- improved sorry documentation
- `plans/26_rabinovich-nvar-reduction.md` -- updated Phase 3 with option eval
- `NfComposition.lean` -- documents FALSE generalized_composition (counterexample)
- `RabinovichTranslation.lean` -- sorry-free ExistsForallSpec.translate_correct
