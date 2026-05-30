# Phase 2 Handoff: Reynolds Model Surgery Core (continuation d)

## Status: IN PROGRESS (proof restructured, 2 core lemmas remain)

## What was done in this session

1. **Proof restructuring**: Rewrote `no_gaps_discrete_model_surgery` to cleanly
   dispatch to two helper lemmas instead of having inline sorry sites:
   - `gap_contradicts_prior` (upward): class bounded above + succ-closed -> False
   - `gap_contradicts_prior_below` (downward): class unbounded above, bounded below -> False

2. **Case analysis**: The main theorem now handles three cases:
   - Class bounded above: direct call to `gap_contradicts_prior`
   - Class NOT bounded above, b > a: impossible (h_bdd gives a ~M b, contradiction)
   - Class NOT bounded above, b < a: call to `gap_contradicts_prior_below`

3. **Removed old messy code**: Eliminated ~150 lines of dead comments and broken
   proof attempts from the b < a case.

4. **Mathematical analysis**: Thorough analysis of proof approaches:
   - Direct predicate argument FAILS in Case B (report 15, Section A.4-A.6 confirmed)
   - Enriched signature approach has circularity issues with Prior-UZ/SZ
   - Full Reynolds model surgery (Lemmas 6-13) IS required
   - Key bottleneck: constructing rho(x) as MonadicFormula sig 1

## What remains

### Sorry site 1: `gap_contradicts_prior` (line ~303)
**Signature**:
```
theorem gap_contradicts_prior (sig k M atomMap h_surj h_prior_UZ h_prior_SZ
    a h_succ_closed h_bounded_above) : False
```
**What it needs**: Reynolds Lemmas 6-13 + Theorem 14 (upward direction).
- Construct MonadicFormula encoding right_gap_class (rho(x))
- Apply US_expressively_complete_over_prior to get temporal formula R
- Prove R-interval properties (Lemma 7)
- Perform model surgery (Lemma 12): replace bad interval by one class
- Derive contradiction (Lemma 13): R holds in surgery model but class ends at point

### Sorry site 2: `gap_contradicts_prior_below` (line ~321)
**Signature**:
```
theorem gap_contradicts_prior_below (sig k M atomMap h_surj h_prior_UZ h_prior_SZ
    a h_succ_closed h_unbounded_above h_bounded_below) : False
```
**What it needs**: Symmetric version of sorry site 1, using Prior-SZ (past direction).
- Define left_gap_class and construct its temporal equivalent L
- Mirror all lemmas from the upward case
- Alternatively, use Order.dual to reduce to the upward case

## Key mathematical findings from this session

1. **Z+Z is k-equivalent to Z for all k (constant predicates)**: Gaps are NOT
   detectable by monadic FO of any finite depth. This means "good" (k-equiv to Z)
   does NOT imply "no gaps". The argument "a ~M d implies no gap in [a,d]" is FALSE.

2. **The b < a case genuinely requires a separate downward argument**: When class(a)
   is unbounded above but bounded below, the gap is below the class. The contradiction
   must come from Prior-SZ (past direction), not Prior-UZ.

3. **The MonadicFormula construction is the key bottleneck**: The full proof requires
   expressing `contemp_equiv sig k M` as a `MonadicFormula sig 2`, then composing
   to get `right_gap_class` as `MonadicFormula sig 1`. This goes through the finite
   enumeration of k-types (NormalForm) and relativized quantification.

## Estimated remaining work

- `gap_contradicts_prior`: 400-600 lines (Reynolds Lemmas 6-13 + monadic FO formula)
- `gap_contradicts_prior_below`: 50-100 lines (if using Order.dual) or 400-600 (if manual mirror)
- Total: 450-700 lines

## File state

- `GoodStructuresModelSurgery.lean`: ~366 lines, builds with 2 sorry warnings
- `no_gaps_discrete_model_surgery`: sorry-free (delegates to helper lemmas)
- All existing infrastructure (contemp_equiv_convex, prior_UZ_first_transition, etc.): sorry-free

## Key infrastructure available (all sorry-free)

- `US_expressively_complete_over_prior` (PriorExpressiveness.lean:371)
- `contemp_equiv_is_equiv` (GoodStructures.lean)
- `no_boundary_at_successor` (GoodStructures.lean)
- `contemp_equiv_convex` (this file)
- `contemp_equiv_pred_closed` (this file)
- `contemp_equiv_succ_iterate` (this file)
- `class_gap_exists` (this file)
- `prior_UZ_first_transition` (this file)
- `temporal_truth_neg_iff_not` (this file)
- `gap_of_not_succ_archimedean` (ReynoldsNoGaps.lean)
- `table_correctness` (Table.lean) - connects temporal_truth to MonadicFormula eval
- `stavi_expressive_completeness` (StaviCompleteness.lean) - GHR93 Theorem 9.3.1
- `nf_characteristic` (NormalForm.lean) - k-type computation
- `k_equiv_preserves_sentence` (Transfer.lean)
