# Phase 3 Handoff: Cases 5-8 Reverted to Bootstrap

## Session
- Session ID: sess_1779084016_ff70c0
- Timestamp: 2026-05-18T08:13:10Z

## What happened
The Round 3 approach for Cases 5-8 (snce_event_eval_pos/neg + replace_untl_with_top/bot) was discovered to be UNSOUND. The `replace_untl_with_top_correct` theorem claimed that replacing U(A,B) with top in a formula preserves truth at a point where U(A,B) holds, but this is false when the formula contains temporal operators (all_past, all_future, snce, untl) that evaluate subformulas at DIFFERENT time points.

Specifically: `S(a ^ U(A,B), q)` inside the event formula `case3_alpha` evaluates `a ^ U(A,B)` at the event point `u`, not at the outer point `s`. At `u`, `U(A,B)(u)` may be false, so replacing `U(A,B)` with `top` changes the semantics.

The entire infrastructure (replace_untl_with_top/bot, snce_event_eval_pos/neg, snce_event_decomp_separable, and the "non-circular" proofs of case5/6/8_separable_Z) has been removed. All Cases 5-8 now use `all_separable _` as a bootstrap.

## Current state
- DedekindZ.lean: 736 lines, compiles clean
  - Phase 1 (K+/K-/Gamma/Q-lemma): COMPLETE, axiom-free
  - case3_equiv_Z_general: COMPLETE, axiom-free 
  - Cases 5-8: all use `all_separable _` bootstrap
- Full `lake build` passes
- No sorries in DedekindZ.lean

## Next action
Proceed to Phase 4: junction-depth hierarchy. The hierarchy does NOT need Cases 5-8. It uses:
1. `abstract_untl` to reduce junction_depth (already in Hierarchy.lean)
2. `untl_s_free_separable` (theorem, not axiom)
3. Boolean closure of `is_separable`
4. Strong induction on junction_depth

After hierarchy is proved (`all_formulas_separable`), replace `all_separable` in Cases 5-8 AND in the 9 SeparationThm.lean axioms.

## Key insight
Cases 5-8 CANNOT be proved non-circularly without the hierarchy. The case3_equiv_Z_general RHS has events containing U(A,B) inside temporal operators. Eliminating these requires either:
(a) The hierarchy (abstract_untl + induction on junction_depth), or  
(b) A correct point-local U-evaluation that only handles Boolean contexts

Approach (a) is the correct GHR94 path.
