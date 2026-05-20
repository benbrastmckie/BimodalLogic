# Phase 1 Handoff: Rewrite Case 2 to Match GHR94

**Task**: 157 - Formalize expressive completeness of {S,U} over integer time
**Plan**: v27 (Case 2 fix plan)
**Session**: sess_1779254268_6ebef4
**Date**: 2026-05-19
**Status**: Phase 1 COMPLETED

## What was done
- Defined `case2_psi a q A B` in Eliminations.lean producing GHR94's 3-disjunct output
- Rewrote `elim_case_2_gen` to prove equivalence with `case2_psi` directly (semantic proof)
- Simplified `elim_case_2` to delegate to `elim_case_2_gen`
- Full `lake build` passes with zero errors

## Key decisions
- The forward direction splits `neg_until_equiv` at the event point s into G and U' branches
- G branch: `G_s(neg A)` gives `neg U(A,B)` at t (since G(neg A) at s implies no A in future, contradicting U(A,B))
- U' branch: `U_s(neg A ^ neg B, neg A)` case-splits on witness u vs t:
  - u < t: d3 (outer S with event at u)
  - u = t: d2 (neg A and neg B at t with S(a, neg A ^ q))
  - u > t: d1 (neg U(A,B) at t -- proved by trichotomy on any U(A,B) witness v vs u)
- Backward direction: for each disjunct, reconstruct `neg U(A,B)` at event s using `neg A on (s,t)` + `neg U(A,B)` at t (or neg B at t for d2, or neg B at w for d3)

## Output formula properties
- d1 has `neg U(A,B) = .imp (.untl A B) .bot` -- only U is `(.untl A B)`, preserving U-type `(A, B)`
- d2 is U-free
- d3 is U-free
- `has_single_U_type (case2_psi a q A B) A B` will be proved in Phase 2

## Next action
Phase 2: Strengthen `snce_single_U_depth_one_separable` to return `is_separable_with_U_type`. Need `case2_psi_has_single_U_type` lemma.
