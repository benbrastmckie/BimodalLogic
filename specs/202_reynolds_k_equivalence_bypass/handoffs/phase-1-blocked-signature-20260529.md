# Phase 1 Handoff: no_gaps_discrete Signature Blocker

**Date**: 2026-05-29
**Session**: sess_1780118957_3a63e0
**Phase**: 1 (Reynolds Model Surgery)
**Status**: BLOCKED

## Immediate Next Action

Fix the `no_gaps_discrete` signature by adding a predicate accessibility hypothesis, then prove the theorem using the existing infrastructure.

## Critical Finding

**`no_gaps_discrete` (GoodStructures.lean:820) is FALSE as currently stated.**

The theorem is missing a predicate accessibility condition. Without it, a counterexample exists:
- M = Z + Z (two copies of integers)
- sig has two predicates: p1 (accessible via atomMap) and p2 (inaccessible)
- p1 is constant everywhere, p2 is true in copy 1, false in copy 2
- Prior-UZ/SZ trivially satisfied (all temporal formulas constant since p2 inaccessible)
- contemp_equiv classes differ (k-types differ due to p2)
- No successor boundary exists (both copies individually archimedean)

## Required Fix

Add to `no_gaps_discrete` and `one_class`:
```lean
(h_accessible : all_predicates_accessible M atomMap)
```
where `all_predicates_accessible` is defined in `GoodStructuresModelSurgery.lean`:
```lean
def predicate_accessible M atomMap p := ∃ f, ∀ t, temporal_truth M atomMap t f ↔ M.interp p t
def all_predicates_accessible M atomMap := ∀ p, predicate_accessible M atomMap p
```

### Files to modify:
1. `GoodStructures.lean`: Add `h_accessible` to `no_gaps_discrete` (line 820) and `one_class` (line 884)
2. `ShiftAndGlue.lean`: Add `h_accessible` to `chronicle_is_good_direct` (line 949)
3. `Transfer.lean`: Provide `h_accessible` in `countermodel_discrete_reynolds` (line 1053)

### At Transfer.lean call site:
The `atomMap_fwd` in `countermodel_discrete_reynolds` satisfies `all_predicates_accessible`:
- For p = <f, h> where f ∈ φ.predFormulas: use formula f directly. temporal_truth f = M.interp (atomMap_fwd f) = M.interp p
- For p = <Formula.bot, h>: use Formula.bot. temporal_truth bot = False = M.interp <bot,...> (since bot never in MCS)

The second case requires proving `M.interp <Formula.bot, _> t = False` for the chronicle structure, which follows from consistency of MCSs.

Alternatively, change `defaultPred` to `⟨Formula.bot, Finset.mem_cons_self _ _⟩` so atomMap_fwd Formula.bot = <Formula.bot, _>.

## Infrastructure Completed

File: `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructuresModelSurgery.lean`

Lemmas proved (sorry-free):
- `temporal_truth_neg_iff_not`: ψ.neg evaluates as ¬ψ
- `temporal_truth_neg_neg_elim`: double negation elimination
- `prior_UZ_first_transition`: if ψ true at t and false above, successor transition exists
- `contemp_equiv_convex`: classes are convex intervals
- `contemp_equiv_pred_closed`: classes closed under pred
- `contemp_equiv_succ_iterate`: classes closed under succ iteration (given closure)
- `class_gap_exists`: gap exists if class ≠ whole order and class is succ-closed
- `contemp_equiv_succ_closed_of_no_boundary`: no boundary implies succ-closed

The main theorem `no_gaps_discrete_model_surgery` has two sorry sites:
1. a < b case: gap exists, need model surgery contradiction
2. b < a case: symmetric argument needed

## Proof Strategy After Signature Fix

Once `h_accessible` is added, the proof of `no_gaps_discrete` proceeds:

1. By contradiction: assume no successor boundary
2. Class of a is closed under succ (by assumption) and pred (by no_boundary_at_successor)
3. ¬(a ~M b) implies class ≠ whole order, so Gap exists (class_gap_exists)
4. At the gap, find a temporal formula ψ that changes value:
   - Since ¬(a ~M b), some k-type differs across the gap
   - At depth 0, k-type differences correspond to predicate differences
   - By h_accessible, predicate differences are detectable by temporal formulas
   - So ∃ ψ : Formula such that ψ true in class and ¬ψ above gap (or vice versa)
5. Apply prior_UZ_first_transition: ψ has successor transition, contradicting no-boundary assumption

Step 4 is the remaining mathematical content. For k=0, it's straightforward (predicate difference).
For k>0, it requires showing that higher-order k-type differences can be reduced to temporal formulas,
which is where the full Reynolds model surgery (Lemmas 6-13) comes in.

Alternative approach: use US_expressively_complete_over_prior with h_surj derived from h_accessible
(this requires proving h_surj from h_accessible, which may need the accessibility condition to be
strengthened to match h_surj exactly).

## Key Decisions

1. `no_gaps_discrete` needs an additional hypothesis -- this is a THEOREM BUG, not an implementation gap
2. The infrastructure (helper lemmas) is factored into GoodStructuresModelSurgery.lean
3. The plan v13 Phase 1 is BLOCKED pending the signature fix

## Phases Completed

- Phase 1: BLOCKED (infrastructure complete, signature fix needed)
- Phase 2-4: NOT STARTED (depend on Phase 1)
