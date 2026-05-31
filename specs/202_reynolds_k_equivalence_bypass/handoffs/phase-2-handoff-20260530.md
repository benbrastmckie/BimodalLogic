# Phase 2 Handoff: Reynolds Model Surgery (Task 202)

## Session: sess_1780191780_e5661e
## Date: 2026-05-30

## Status
- Phase 1 [COMPLETED]: gap formula construction (eval_good_rel_lifted, right_gap_class_formula_correct, gap_formula_R)
- Phase 2 [COMPLETED]: R-interval analysis (R_holds_at_a proved, SZ reduced to UZ)
- Phases 3-6 [NOT STARTED]: model surgery construction, truth preservation, contradiction, wiring

## Key Achievement
**Reduced from 2 sorry sites to 1**: `gap_prior_SZ_contradiction` now delegates to `gap_prior_UZ_contradiction` via symmetry of contemp_equiv + no_boundary_at_successor. Only `gap_prior_UZ_contradiction` (line ~1045) remains sorry'd.

## Remaining Sorry
File: `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructuresModelSurgery.lean`
Line: ~1045
Theorem: `gap_prior_UZ_contradiction`
Content: Reynolds Lemmas 6-13, upward case (~400 lines of model surgery)

### What's proved inside the sorry'd theorem
- `R` (gap_formula_R) is defined
- `h_R_at_a : temporal_truth M atomMap a R` is proved
- Remaining: R_false_somewhere, R_first_transition, model surgery, contradiction

## Immediate Next Action
The successor agent should attempt to prove `gap_prior_UZ_contradiction` by:

1. **R_false_somewhere**: Find z such that R fails at z. The argument: since `no_boundary_at_successor` gives `c ~M succ(c)` for all c, every class is succ-closed. R at z means "class(z) bounded above". In a NoMaxOrder, at least one class must be unbounded above. The challenge is formalizing this.

2. **R_first_transition**: Once R_false_somewhere is established, apply `prior_UZ_first_transition` to get transition point c with R at c and not R at succ(c).

3. **Model surgery**: This is the hard part (~300 lines). Define surgery domain, prove truth preservation across 30 subcases.

4. **Contradiction**: R holds at c in M. By truth preservation, R holds at c in the surgery model N. But in N, the class boundary at c is a successor pair (not a gap), so right_gap_class_prop is false at c in N. Contradiction.

## Key Decisions Made
1. **SZ reduction**: gap_prior_SZ_contradiction reduces to gap_prior_UZ_contradiction because contemp_equiv is symmetric and no_boundary_at_successor gives succ-closure for every class.
2. **eval_good_rel_lifted**: Proved via two applications of lift_eval with explicit insertEnv decomposition (the De Bruijn fix).
3. **right_gap_class_formula_correct**: Connected formula evaluation to bad-subinterval existence.
4. **gap_formula_R_iff_rgcp**: Full correctness connecting temporal R to right_gap_class_prop (given succ-closed hypothesis).

## Proven Infrastructure (sorry-free)
- `eval_good_rel_lifted` -- De Bruijn index composition
- `right_gap_class_formula_correct` -- formula semantics
- `right_gap_class_formula_implies_bounded` -- formula → bounded class
- `bounded_implies_right_gap_class_formula` -- bounded class → formula
- `gap_formula_R` + `gap_formula_R_correct` -- temporal formula for right_gap_class
- `gap_formula_R_iff_rgcp` -- full correctness with succ-closed
- `gap_prior_SZ_contradiction` -- reduced to UZ case

## Files Modified
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructuresModelSurgery.lean` (+201 lines, -4 lines)

## Anti-Patterns (from failure history)
- DO NOT try to bypass model surgery
- DO NOT construct class membership formula
- DO NOT enrich signature with right_gap_class as predicate
- DO NOT attempt no_gaps_prior or no_gaps_faithful (false as stated)
