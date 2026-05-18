# Phase 2 Handoff: case3_equiv_Z_general Completed, Cases 5-8 Strategy Revised

**Task**: 157
**Session**: sess_1779084016_ff70c0
**Date**: 2026-05-18
**Phase**: 2 (Case 3 General Equivalence)
**Status**: Task 2.1 COMPLETED, Task 2.2 DEFERRED

## What Was Completed

### case3_equiv_Z_general (DedekindZ.lean, ~300 new LOC)

Proved the three-disjunct semantic equivalence for S(a, q v U(A,B)) with ARBITRARY event a:

```
S(a, q v U(A,B)) <->
  S(a, q)
  v [S(alpha, Q_Z(A,B,~q)) ^ (A v (B ^ U(A,B)))]
  v S(A ^ (q v U(A,B)) ^ S(alpha, Q_Z(A,B,~q)), q)
```

where alpha = a v (~q ^ S(a, q) ^ (q v U(A,B))).

Three new theorems, all sorry-free:
- `case3_equiv_Z_fwd`: Forward direction (interval analysis, ~200 LOC)
- `case3_equiv_Z_bwd`: Backward direction (Q_lemma_Z_bwd usage, ~100 LOC)
- `case3_equiv_Z_general`: Combined equivalence

## Critical Finding: Cases 5-8 Cannot Be Proved Before Hierarchy

### Why the Plan's Task 2.2 Must Be Deferred

Exhaustive analysis of all approaches:

1. **neg_since_equiv route**: CIRCULAR between Cases 5 and 8.
   - Case 5 ↔ ~H(~a'v~U) ^ ~Case8
   - Case 8 ↔ ~H(qvU) ^ ~Case5
   - Cannot break this cycle without external input.

2. **case3_equiv_Z_general route**: RHS has SAME junction_depth as LHS.
   - `S(alpha, Q_Z)` in RHS has jd ≥ 1 (alpha contains S(a'^U, q) which has U under S)
   - Cannot reduce jd by applying case3_equiv repeatedly.

3. **Direct RHS separability**: Requires `snce_separable` axiom.
   - `S(alpha_separated, Q_Z)` has separated event but NOT U-free event
   - Showing this is separable requires the temporal closure axiom `snce_separable`
   - That axiom is what we're trying to eliminate.

4. **Case 1 iteration** (GHR94's approach): Works in principle but requires:
   - Replacing S(a'^U, q) with Case 1 separated equivalent psi1
   - Event-splitting on U(A,B)
   - Repeating until all U's are at top level
   - This IS how GHR94 does it, but implementing it Lean is 200+ LOC per case
   - AND it still requires showing the final S-terms are separable, which needs snce_separable

### Correct Architecture

The hierarchy theorem (`junction_depth_separable_aux`) SUBSUMES Cases 5-8:
- It proves ALL formulas are separable by strong induction on junction_depth
- At jd ≥ 1: abstract one operator, reduce jd, apply IH, substitute back
- The substitution back creates U-under-S patterns (Cases 1-8)
- case3_equiv_Z_general handles the hard cases by REWRITING into forms where Case 1-4 apply

Cases 5-8 in DedekindZ.lean should remain as `all_separable _` stubs UNTIL the hierarchy theorem is proved. The hierarchy will provide `all_formulas_separable` which replaces `all_separable`.

## Immediate Next Action

Proceed to Phase 4: prove the hierarchy theorem. The order should be:

1. **Task 4.2**: `no_S_nested_in_U_separable` -- formulas where U-args are S-free
2. **Task 4.3**: `junction_depth_separable_aux` -- the main hierarchy by jd induction
3. **Task 4.4**: `all_formulas_separable` -- wrapper with expand_temporal
4. **Task 4.5**: Wire `multi_U_formula_separable` to hierarchy

The hierarchy's inductive step at jd ≥ 1 uses:
- abstract_untl/abstract_snce to reduce jd (infrastructure already in Hierarchy.lean)
- Cases 1-4 for the resulting U-under-S patterns
- case3_equiv_Z_general when the pattern is S(event, qvU) with complex event
- Boolean closure (or/and/neg/imp_separable)

## Key Files

- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/DedekindZ.lean` (now ~680 lines)
  - Phase 1: K/Gamma triviality, Q-lemma (lines 1-276)
  - Phase 2: case3_alpha, case3_rhs, case3_equiv_Z_fwd/bwd/general (lines 277-680)
  - Cases 5-8 stubs using all_separable (lines 680+)
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean` (1055 lines)
  - Infrastructure: abstract_snce/untl preservation, jd decrease lemmas
  - multi_U_formula_separable (uses all_separable -- to be replaced)
  - Phase 4 work goes after line 1055
