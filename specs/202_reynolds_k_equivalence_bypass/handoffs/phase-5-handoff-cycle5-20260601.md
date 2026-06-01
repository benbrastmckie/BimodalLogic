# Phase 5 Handoff: Task 202 (Cycle 5)

## Session
sess_1780325631_z4lda

## Current State
Phase 5 COMPLETED (final contradiction wired). Phase 4 PARTIAL (ordered spread sorry).

### Accomplishments (this cycle)

1. **contemp_eq_body_correct** -- CLOSED (was sorry). Key technique: `show` + definitional equality to bypass Fin.cons reduction at non-canonical indices (2, 3). Uses `eval_good_rel_lifted`, `good_formula_relativized_correct`, `good_of_very_good_subinterval`, and `subinterval_of_subinterval_k_equiv`.

2. **truth_pres** -- PROVED (2 sorry sub-cases). Full bidirectional truth preservation M <-> N by structural induction on Formula. Cases:
   - atom, bot, box: Iff.rfl (predicates inherited, box is predicate)
   - imp: uses both directions of IH
   - untl backward: convexity of class(a) keeps all intermediate points in N
   - untl forward (s in class): direct via convexity
   - untl forward (s outside class, s' > t): uses class_spread + convexity
   - **untl forward (s outside class, s' <= t): SORRY** (ordered spread)
   - snce: mirror of untl

3. **Prior-UZ/SZ on N** -- PROVED (sorry-free, assuming truth_pres). Uses truth_pres to transfer Prior-UZ/SZ from M to N. Key insight: first/last occurrence s0 is between t and s (both in class(a)), so s0 is in class(a) by convexity.

4. **h_rgcf_false_N** -- PROVED (sorry-free). right_gap_class_formula is false on N because all N-subintervals are good. Uses k_equiv_of_iso to transfer between N.subinterval and M.subinterval (via convexity of class(a)).

5. **Final contradiction** -- WIRED (steps 8-12). R on N (truth_pres + h_R_everywhere) -> right_gap_class_formula on N (US_expressively_complete_over_prior) -> contradiction (h_rgcf_false_N).

### Remaining Sorry (2 sites, same blocker)

**Ordered spread** (Reynolds Lemma 11): When `class_spread` gives a witness s' in class(a) with temporal formula A(s'), but s' is on the wrong side of t (s' <= t for Until, s' >= t for Since), we need to find A at a point on the correct side.

**Location**: Lines ~1530 and ~1556 in GoodStructuresModelSurgery.lean.

**What was tried**:
- class_spread gives A SOMEWHERE in class(a) but not above/below t
- class_spread on U(A, Top) gives U(A, Top) somewhere in class(a), but the witness might still be outside class(a)
- Prior-UZ gives first occurrence of A above t in M, but it might be outside class(a)
- Iterating class_spread doesn't converge

**Why stuck**: class_spread uses invariant_formula_constant which gives UNORDERED spread (A holds somewhere in every class) but NOT ordered spread (A holds above/below a specific point). Ordered spread requires Reynolds Lemma 11 (density): showing that class(a) restricted to [t, inf) has the same k-type as M restricted to [t, inf). This requires a deeper k-equivalence argument.

**What is needed**: Reynolds Lemma 11 formalization. The argument should show that all contemp_equiv classes have the same monadic FO theory WITHIN ANY SUFFIX/PREFIX of the order. This likely requires:
- Showing each class is order-isomorphic to Z
- Showing the Z-intervals within each class above any point t have the same k-type
- Using this to transfer existential formulas (like "A holds") from one suffix to another

## Files Modified
- `GoodStructuresModelSurgery.lean`: ~1700 lines total (was ~1580)
  - Lines ~1017-1045: contemp_guard_iff + contemp_eq_body_correct (sorry-free)
  - Lines ~1492-1560: truth_pres (2 sorry at ~1530, ~1556)
  - Lines ~1562-1601: Prior-UZ/SZ on N (sorry-free)
  - Lines ~1602-1650: Final contradiction chain (sorry-free)

## Next Action
Prove ordered spread (Reynolds Lemma 11) to close the 2 remaining sorry sites. This would make gap_prior_UZ_contradiction sorry-free, enabling Phase 6 (wiring to no_gaps_discrete).
