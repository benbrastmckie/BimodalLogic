# Phase 2 Handoff: Reynolds Model Surgery Core

## Status: IN PROGRESS (contradiction setup complete, Lemmas 6-13 remaining)

## What was done
- Phase 1 COMPLETED: h_surj sorry closed at Transfer.lean via `mkAtomMapFwd` definitions
- Phase 2 PARTIAL: Set up the contradiction framework in `no_gaps_discrete_model_surgery`:
  - `by_contra` + `push_neg` gives `h_succ_closed : forall c, a ~M c -> a ~M succ(c)`
  - WLOG case split on `a < b` vs `b < a`
  - For `a < b`: gap exists via `class_gap_exists`
  - For `b < a`: gap exists via `gap_of_not_succ_archimedean`
  - Two sorry sites remain: one for each case, both requiring the same model surgery

## Immediate next action
Implement the Reynolds model surgery argument (Lemmas 6-13) in GoodStructuresModelSurgery.lean, starting after the gap construction.

## Current proof state at sorry sites

### Sorry site 1 (line ~378, case a < b):
```
gamma : Gap M.carrier
h_succ_closed : forall c, contemp_equiv sig k M a c -> contemp_equiv sig k M a (Order.succ c)
h_diff_class : not (contemp_equiv sig k M a b)
h_prior_UZ : semantic_prior_UZ M atomMap
h_prior_SZ : semantic_prior_SZ M atomMap
h_surj : forall p, exists a, atomMap (.atom a) = p
-- Need: False
```

### Sorry site 2 (line ~415, case b < a):
Same context but with `gamma` from `gap_of_not_succ_archimedean`.

## Reynolds model surgery outline (Lemmas 6-13)

### Lemma 6 (Gap formula R)
- Use `US_expressively_complete_over_prior` (PriorExpressiveness.lean, sorry-free)
- Need to construct `MonadicFormula sig 1` encoding "right_gap_class"
- `right_gap_class t` = "class(t) is bounded above AND the upper boundary is a gap"
- Apply expressive completeness to get temporal formula R
- Key difficulty: constructing the monadic FO formula

### Lemma 7 (R-intervals)
- R holds at succ(t) when R holds at t (same class, same gap)
- Uses `no_boundary_at_successor` (sorry-free)

### Lemma 8 (No first/last class)
- Uses Lemma 7 + expressive completeness

### Lemma 9 (Class homogeneity)
- Classes in R-intervals are elementarily equivalent
- Uses expressive completeness + Prior-UZ

### Lemmas 10-11 (Bad intervals, formula propagation)
- Define bad_point = R or L
- Both R and L hold throughout bad intervals
- Formula propagation: if B holds near class start, it holds throughout

### Lemma 12 (Model surgery - the big one)
- Construct surgery domain: Q- union I union Q+
- Need OrderedMonadicStructure on surgery domain
- Truth preservation: 7 forward + 6 backward subcases for U(A,B)
- Mirror for S(A,B)
- Estimated ~200 lines for this lemma alone

### Lemma 13 (Contradiction)
- R holds at I in surgery model (by Lemma 12)
- But I's class in surgery model ends at first point of Q+ (a point)
- So right_gap_class does NOT hold at I in surgery model
- R should be false at I. But Lemma 12 says R is preserved. Contradiction.

## Key infrastructure available (all sorry-free)
- `US_expressively_complete_over_prior` (PriorExpressiveness.lean)
- `contemp_equiv_is_equiv` (GoodStructures.lean)
- `no_boundary_at_successor` (GoodStructures.lean)
- `contemp_equiv_convex` (this file)
- `contemp_equiv_succ_closed_of_no_boundary` (this file)
- `contemp_equiv_pred_closed` (this file)
- `contemp_equiv_succ_iterate` (this file)
- `class_gap_exists` (this file)
- `prior_UZ_first_transition` (this file)
- `temporal_truth_neg_iff_not` (this file)
- `gap_of_not_succ_archimedean` (ReynoldsNoGaps.lean)

## Key types
- `MonadicFormula sig n` - monadic FO formula with n free variables
- `eval M env psi` - evaluate monadic formula in structure M with environment
- `Gap T` - Dedekind cut with no max and no complement min
- `OrderedMonadicStructure sig` - carrier + interp : sig.preds -> carrier -> Prop
- `temporal_truth M atomMap t f` - temporal truth of formula f at point t

## File locations
- GoodStructuresModelSurgery.lean: line 315 (sorry) and line ~415 (sorry)
- PriorExpressiveness.lean: US_expressively_complete_over_prior at line 371
- GoodStructures.lean: no_gaps_discrete sorry at line 820 (Phase 3)
- Transfer.lean: packaging sorry at line 1289 (Phase 4)

## Estimated remaining work
- Phase 2 (model surgery core): 400-500 lines, 8-12 hours
- Phase 3 (wire no_gaps_discrete): ~5 lines, trivial once Phase 2 done
- Phase 4 (TaskFrame packaging): 150-300 lines, 4-6 hours
- Phase 5 (completeness rewiring): ~20 lines, 1 hour

## Alternative approaches (from research reports 14-15)
1. The direct Prior-UZ contradiction proof (without model surgery) FAILS in Case B
   (predicate transitions at successor pairs in the complement are legitimate).
   Full model surgery IS required.
2. BX pipeline revival: would require proving IsSuccArchimedean (stronger than
   "no class boundary at gaps"), offering no net savings.
3. Task 224 (finite insertion argument) provides an independent approach.
