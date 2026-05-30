# Phase 2 Handoff: class_temporal_formula Analysis

**Date**: 2026-05-30
**Session**: sess_1780151044_orch202r3
**Phase**: 2 (Reynolds Model Surgery Core)
**Status**: BLOCKED

## Analysis Summary

`class_temporal_formula` at GoodStructuresModelSurgery.lean:537 is **unprovable as stated**.
Five approaches were analyzed; all fail due to fundamental obstructions.

## Why class_temporal_formula is Unprovable

### The Statement

```lean
private noncomputable def class_temporal_formula
    {sig : MonadicSignature} {k : Nat}
    (M : OrderedMonadicStructure sig) [SuccOrder M.carrier] [PredOrder M.carrier]
    [NoMaxOrder M.carrier] [NoMinOrder M.carrier]
    (atomMap : Formula -> sig.preds)
    (h_surj : forall p, exists a, atomMap (.atom a) = p)
    (h_prior_UZ : semantic_prior_UZ M atomMap)
    (h_prior_SZ : semantic_prior_SZ M atomMap)
    (a : M.carrier) :
    { R : Formula //
      forall t, temporal_truth M atomMap t R <-> contemp_equiv sig k M a t }
```

### Fundamental Obstruction: Parameter Reference

`contemp_equiv sig k M a t` depends on the fixed element `a`. A temporal formula
R is evaluated via `temporal_truth M atomMap t R`, which depends only on M and t
(not on any specific carrier element). The formula R cannot "know about" the
specific element a.

The pipeline `US_expressively_complete_over_prior` converts MonadicFormula sig 1
to Formula, but MonadicFormula sig 1 has ONE free variable (for t) and cannot
reference specific carrier elements. `eval M (fun _ => t) psi` depends only on
M's structure at/around t -- not on any distinguished element.

### Why Enriched Signature Fails

Adding class membership as a new predicate to get M' : OrderedMonadicStructure sig':

- M'.interp p_class t := contemp_equiv sig k M a t
- atomMap' maps fresh_atom to p_class
- Need semantic_prior_UZ for M' and atomMap'

Prior-UZ for `.atom fresh_atom` requires: if class(a) holds at some s > t, there
is a FIRST occurrence of class(a) above t.

class(a) is convex. If t is not in class(a) and class(a) starts above t, the
left boundary of class(a) may be a gap (no minimum). In that case, there is NO
first occurrence -- Prior-UZ FAILS.

This is CIRCULAR: Prior-UZ for class membership requires class boundaries to be
at successor pairs, which IS Theorem 14 (what we're trying to prove).

### Why is_a Predicate Fails

Adding is_a (true only at a) to the signature: the is_a predicate transitions at
successor pairs (pred(a), a) and (a, succ(a)), so Prior-UZ holds for is_a alone.
But compound formulas like "exists y, is_a(y) and ... y ... t ..." still face the
class membership circularity when encoding contemp_equiv.

### Why Direct MonadicFormula sig 1 Construction Fails

contemp_equiv sig k M a t = very_good of [min a t, max a t]. The very_good check
requires inspecting ALL subintervals between a and t. This involves bounded
quantification "forall x y, a <= x <= y <= t -> ..." which references a. But
MonadicFormula sig 1 has no variable for a. The formula would need:

  forall x y, (??? <= x) and (x <= y) and (y <= t) -> k_type [x,y] in G

where ??? must identify a. With only predicates and order, a cannot be uniquely
identified in an infinite structure with finitely many predicates.

### Why Non-constructive Existence Fails

Classical.choice requires proving `exists R, forall t, temporal_truth t R <-> contemp_equiv a t`.
The existence itself is the hard claim. It amounts to: the set class(a) is
temporally definable in M. This appears to be false in general (without further
hypotheses), and proving it requires essentially Theorem 14 itself.

## What Reynolds Actually Does

Reynolds 1994, Lemma 6 constructs a DIFFERENT formula. Not class(a) membership,
but right_gap_class:

  rho(x) := "x's ~M-class ends in a gap on the right"

This is definable because ~M has a defining formula epsilon(x,y) with TWO free
variables. Then:

  rho(x) = exists y > x, not epsilon(x,y) and not exists z > x (epsilon(x,z) and not epsilon(x, succ(z)))

rho(x) is a MonadicFormula sig 1 (x free, y and z quantified). It does NOT
reference any fixed carrier element. It characterizes a STRUCTURAL PROPERTY of
the equivalence class, not membership in a specific class.

US_expressively_complete_over_prior converts rho to temporal R. Then Lemmas 7-13
use model surgery (not Prior-UZ first-transition) to derive the contradiction.

## Correct Path Forward

### Step 1: Construct epsilon(x,y) : MonadicFormula sig 2

contemp_equiv sig k M a b = very_good of [min a b, max a b]. This is:
forall x y, min(a,b) <= x <= y <= max(a,b) -> good [x,y]. And good means
k-equiv to some Z-interval. Since NormalForm sig k 0 is Fintype, this is a
finite disjunction of k-type patterns, expressible in monadic FO.

### Step 2: Construct rho(x) : MonadicFormula sig 1

From epsilon, build rho as described above.

### Step 3: Get temporal R via US_expressively_complete_over_prior

Apply US_expressively_complete_over_prior to rho to get temporal formula R.

### Step 4: Implement Lemmas 7-13 (model surgery)

This is the main work (~400 lines):
- Lemma 7: R-intervals are open, bounded by M-elements
- Lemma 8: No first/last class in R-intervals
- Lemma 9: Class homogeneity in R-intervals
- Lemmas 10-11: Bad intervals and formula propagation
- Lemma 12: Model surgery construction
- Lemma 12 (cont): Truth preservation (13 subcases for U/S)
- Lemma 13 + Theorem 14: Contradiction

### Step 5: Restructure proof

DELETE class_temporal_formula and reynolds_model_surgery_core. Prove
no_gaps_discrete_model_surgery directly using the model surgery.

## Estimated Effort

- Step 1-3: ~100 lines, 3-4 hours
- Step 4: ~300-400 lines, 8-10 hours
- Step 5: ~20 lines, 0.5 hours
- Total: ~400-500 lines, 12-14 hours

## Immediate Next Action

Create a new plan (v15) that restructures Phase 2 to follow Reynolds' original
argument. The current proof architecture (class_temporal_formula + simple
first-transition) must be replaced by (right_gap_class_formula + model surgery).

## Files Modified This Session

- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructuresModelSurgery.lean`
  - Updated docstring for class_temporal_formula: documents why it's unprovable
  - Updated section comment: describes correct path forward
- `specs/202_reynolds_k_equivalence_bypass/plans/14_reynolds-model-surgery-definitive.md`
  - Updated Phase 2 blocker with full analysis of 5 failed approaches
  - Root cause identified: wrong intermediate lemma
