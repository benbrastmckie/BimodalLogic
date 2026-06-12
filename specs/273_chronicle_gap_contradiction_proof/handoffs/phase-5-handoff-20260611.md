# Phase 5 Handoff: Backward Direction BLOCKED

**Date**: 2026-06-11
**Session**: sess_1781193902_83bc5c
**Phase**: 5 (Backward Direction)
**Status**: BLOCKED

## Summary

Phase 5 attempted to prove the backward direction of `nf_exist_formula_nested`:
formula truth -> existential `exists x, nf_eval_nf M (k+1) 2 (Fin.cons x (fun _ => t)) sub_nf`.

The sorry is at NegationClosure.lean:828.

## Root Cause: Formula is Provably Incorrect

The formula `nf_exist_formula_nested` (defined at lines 421-522 of NegationClosure.lean) does not
encode the full quantifier part `sub_nf.2` of the 2-var NF. Specifically:

1. **Non-interval ssn's are not encoded**: For ssn's placing y outside the interval (t,x) --
   i.e., y > x, y = x, y < t, y = t -- the formula includes NO conditions. Two sub_nf's
   that agree on atom parts and positive-interval ssn patterns but differ on non-interval ssn
   quantifier values produce the SAME formula.

2. **Interval ssn's use only 1-var char**: For interval ssn's (y in (t,x)), the formula uses
   `Since(char_k(nf_y), top)` which only captures the 1-var NF of y. The 3-var NF of (y,x,t)
   at depth k >= 1 is NOT determined by the 1-var NFs of y, x, t plus their order. This was
   established in research (handoff 20260611g).

3. **Guard = Formula.top**: The Phase 4 guard weakening from negative interval conditions to
   `Formula.top` removed the only mechanism for encoding negative conditions. But even with a
   restored guard, issues (1) and (2) remain.

## Concrete Counterexample Argument

Take k = 0, sig with predicate p. Let:
- parent_atoms assigns p = true at t
- sub_nf_1 : NormalForm sig 1 2 with correct quantifier part for actual (x, t)
- sub_nf_2 : same atoms as sub_nf_1, but different sub_nf.2 on a non-interval ssn

Both produce the SAME formula (non-interval ssn's don't appear in the formula). If the formula
for sub_nf_1 is true (existential holds), the formula for sub_nf_2 is also true (same formula).
But the existential for sub_nf_2 may be false. Biconditional fails.

## Approaches Considered and Rejected

### 1. Direct backward proof
Extract x from Until, use char_{k+1}(nf_x) to get 1-var NF. Try to show sub_nf.2 matches
characteristic. FAILS because formula doesn't determine sub_nf.2.

### 2. doets_lemma_1_1 transfer
Define formula as disjList of char_{k+1}(nf_t) for compatible nf_t. Transfer via doets requires
depth k+2 agreement, but only P1(k+1) (depth k+1) is available.

### 3. Composition theorem
Decompose 3-var NFs into 2-var projections (Libkin Lemma 3.7). Not formalized; ~200 lines needed.

## Recommended Fix: Three Options

### Option A: Generalized Arity Induction (Cleanest)
Extend master_induction to prove P_n(k) for all arities n, not just n=1,2. Then P_3(k) handles
3-var existentials directly. Estimated: 300-400 additional lines.

### Option B: Composition Theorem (Medium)
Formalize that 3-var NF of (y,x,t) is determined by 2-var NFs of (y,x) and (y,t) when y is
between x and t. Use P_2(k) to encode the 2-var conditions in the formula. Estimated: 200 lines
for composition + 100 lines formula revision.

### Option C: doets Depth Trick (Shortest, Prior-specific)
Show the existential at depth k+1 is equivalent to a formula of depth k+1 (not k+2) on Prior
structures, using Prior-UZ/SZ to eliminate one quantifier alternation. Then doets at k+1 suffices.
Estimated: 100-150 lines. Most fragile.

## Current State

- Build passes with 1 sorry (NegationClosure.lean:828)
- Forward direction (Phase 4) is sorry-free
- Phases 1-4 are COMPLETED
- Phase 5 is BLOCKED
- Phases 6-7 are NOT STARTED (depend on Phase 5)

## Immediate Next Action

A new plan revision is needed. The formula `nf_exist_formula_nested` must be redesigned before
the backward direction can be attempted. The forward proof will need corresponding updates.
