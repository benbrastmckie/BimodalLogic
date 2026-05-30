# Phase 2 Handoff: Reynolds Model Surgery Core (continuation e)

## Status: BLOCKED (full model surgery required, 2 core lemmas remain)

## What was done in this session

1. **prior_SZ_last_transition proved sorry-free**: Added the symmetric lemma
   to prior_UZ_first_transition for the past direction. If psi holds at t and
   not-psi holds at some s < t, then there exists c <= t with psi at c and
   not-psi at pred(c). This is needed for gap_contradicts_prior_below.

2. **Thorough mathematical analysis**: Exhaustively analyzed all possible
   approaches to closing gap_contradicts_prior and gap_contradicts_prior_below:
   - Direct predicate argument: FAILS (confirmed report 15 findings)
   - Enriched-signature approach: Prior-UZ does NOT hold for the enriched
     structure because the class membership predicate has no first occurrence
     above points near the gap (the complement of the class has no minimum
     at the gap, violating the first-occurrence property)
   - Direct first-transition on arbitrary formulas: insufficient because
     transition at a successor pair doesn't contradict class succ-closure
   - ALL approaches converge: full Reynolds model surgery IS required

3. **Code cleanup**: Restructured GoodStructuresModelSurgery.lean with clean
   documentation, removed dead code, added prior_SZ_last_transition.

## What remains: TWO sorry sites

### Sorry site 1: `gap_contradicts_prior` (line ~397)
**Signature**:
```lean
theorem gap_contradicts_prior (sig k M atomMap h_surj h_prior_UZ h_prior_SZ
    a h_succ_closed h_bounded_above) : False
```
**What it needs**: Full Reynolds model surgery (Lemmas 6-13 + Theorem 14):
- Construct surgery domain: Q_minus union I union Q_plus (Task 2.7)
- Define OrderedMonadicStructure on surgery domain (Task 2.7)
- Prove truth preservation for atoms/bot/imp/box (Task 2.8, ~30 lines)
- Prove truth preservation for U(A,B) forward (Task 2.9, 7 subcases, ~100 lines)
- Prove truth preservation for U(A,B) backward (Task 2.10, 6 subcases, ~80 lines)
- Prove truth preservation for S(A,B) (Task 2.11, mirror of U, ~80 lines)
- Derive contradiction (Task 2.12, ~40 lines)

### Sorry site 2: `gap_contradicts_prior_below` (line ~436)
**Signature**:
```lean
theorem gap_contradicts_prior_below (sig k M atomMap h_surj h_prior_UZ h_prior_SZ
    a h_succ_closed h_unbounded_above h_bounded_below) : False
```
**What it needs**: Symmetric version of sorry site 1 using Prior-SZ.
Options:
- Order.dual trick to reduce to the upward case (~50 lines if applicable)
- Manual symmetric argument (~400 lines)

## Key mathematical findings from this session

1. **The enriched-signature approach DOES NOT WORK directly**:
   Adding class membership as a new predicate changes temporal_truth.
   The enriched structure does NOT satisfy Prior-UZ because the class
   membership predicate has gap-type transitions (no first occurrence
   at gaps). This is not a technical issue but a mathematical one:
   the gap SPECIFICALLY prevents the first-occurrence property for
   any predicate that detects it.

2. **The model surgery is NECESSARY, not just one approach among many**:
   ALL simpler arguments fail. The model surgery is the mathematical
   content of Reynolds Lemmas 6-13: it constructs a new structure where
   the gap is removed, proves temporal truth preservation, and derives
   a contradiction from the surgery model having different class structure
   than the original.

3. **The surgery construction is well-defined**: Q_minus union I union Q_plus
   (where Q0 is the gap region, I is one class in Q0, Q_minus is everything
   below Q0, Q_plus is everything above Q0). The order is inherited from M.
   Predicates are inherited from M. The key insight is that I is an
   archimedean sub-order, so the surgery model IS archimedean near the
   former gap location.

## Estimated remaining work

- `gap_contradicts_prior`: 400-600 lines (Reynolds Lemmas 6-13)
- `gap_contradicts_prior_below`: 50-100 lines (if using Order.dual) or 400-600 (if manual mirror)
- Total: 450-700 lines, 12+ hours

## File state

- `GoodStructuresModelSurgery.lean`: ~440 lines, builds with 2 sorry warnings
- `prior_SZ_last_transition`: sorry-free (NEW)
- `no_gaps_discrete_model_surgery`: sorry-free (delegates to helper lemmas)
- All existing infrastructure: sorry-free

## Immediate next action for continuation

1. Read the plan Tasks 2.7-2.12 carefully
2. Start with Task 2.7: define the surgery domain type and OrderedMonadicStructure
3. The surgery domain should be a subtype of M.carrier: {t | t in Q_minus or t in I or t in Q_plus}
4. Use Set.Elem for the carrier (plan contingency 3)
5. Prove SuccOrder/PredOrder/NoMaxOrder/NoMinOrder for the surgery domain
6. Then proceed to truth preservation (Tasks 2.8-2.11)

## Key infrastructure available (all sorry-free)

- `US_expressively_complete_over_prior` (PriorExpressiveness.lean:371)
- `contemp_equiv_is_equiv` (GoodStructures.lean)
- `no_boundary_at_successor` (GoodStructures.lean)
- `contemp_equiv_convex` (this file)
- `contemp_equiv_pred_closed` (this file)
- `contemp_equiv_succ_iterate` (this file)
- `class_gap_exists` (this file)
- `prior_UZ_first_transition` (this file)
- `prior_SZ_last_transition` (this file, NEW)
- `temporal_truth_neg_iff_not` (this file)
- `gap_of_not_succ_archimedean` (ReynoldsNoGaps.lean)
- `table_correctness` (Table.lean)
- `stavi_expressive_completeness` (StaviCompleteness.lean)
- `k_equiv_preserves_sentence` (Transfer.lean)
