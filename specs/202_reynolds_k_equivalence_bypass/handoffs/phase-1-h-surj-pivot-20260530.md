# Phase 1 Handoff: h_surj Pivot -- prior_implies_archimedean_of_accessible is FALSE

**Date**: 2026-05-30
**Session**: sess_1780118957_3a63e0
**Phase**: 1 (Reynolds Model Surgery)
**Status**: PARTIAL (critical mathematical error identified and corrected)

## Critical Discovery

### prior_implies_archimedean_of_accessible is MATHEMATICALLY FALSE

The theorem `prior_implies_archimedean_of_accessible` (GoodStructuresModelSurgery.lean)
claimed: Prior-UZ + Prior-SZ + h_accessible -> IsSuccArchimedean.

**Counterexample**: M.carrier = Z + Z (two disjoint copies of integers), with
M.interp p t = True for ALL predicates p and ALL points t (constant predicates).

- h_accessible HOLDS: for each p, use f = (.atom a) where atomMap(.atom a) = p.
  temporal_truth f t = M.interp p t = True for all t. So f detects p.
- Prior-UZ HOLDS: all temporal formulas evaluate to constants (True or False at all points).
  If psi is True everywhere, first occurrence above t is succ(t), guard vacuous.
  If psi is False everywhere, antecedent F(psi) is False.
- Prior-SZ HOLDS: symmetric.
- BUT Z+Z is NOT IsSuccArchimedean. The gap between the two copies is a genuine
  Dedekind gap.

### Root Cause Analysis

The error was confusing two related but distinct properties:
1. **Reynolds Theorem 14**: contemp_equiv class boundaries don't end at gaps (TRUE with h_surj)
2. **IsSuccArchimedean**: no gaps exist at all (FALSE with h_accessible alone)

In Z+Z with constant predicates, all k-types are the same everywhere, so
contemp_equiv holds for ALL pairs. There are NO class boundaries at all.
Theorem 14 is vacuously true. But IsSuccArchimedean is FALSE (the gap exists).

### Correct Approach: h_surj replaces h_accessible

The correct hypothesis for the Reynolds model surgery is:
```
h_surj : forall p : sig.preds, exists a : Atom, atomMap (.atom a) = p
```

h_surj (atom-level surjectivity) enables `US_expressively_complete_over_prior`
(GHR93 Theorem 9.3.1), which is essential for:
- Lemma 6: constructing the gap formula R from monadic FO
- Lemmas 7-11: constructing auxiliary formulas B, C
- Lemma 12: model surgery truth preservation (induction base case)

h_accessible (formula-level detectability) does NOT provide this capability.
The `stavi_expressive_completeness` theorem requires atoms mapping to predicates,
not arbitrary formulas.

## Changes Made This Cycle

### 1. GoodStructures.lean -- no_gaps_discrete signature updated
- Replaced `h_accessible` with `h_surj` in the theorem signature
- Updated documentation with correct proof strategy
- Sorry retained (pending model surgery implementation)

### 2. GoodStructures.lean -- one_class signature updated  
- Replaced `h_accessible` with `h_surj` (passes through to no_gaps_discrete)
- Removed h_accessible parameter entirely

### 3. GoodStructuresModelSurgery.lean -- FALSE theorem removed
- Removed `prior_implies_archimedean_of_accessible` (documented as FALSE with counterexample)
- Updated `no_gaps_discrete_model_surgery` to use `h_surj` instead of `h_accessible`
- Updated module docstring with three critical findings

### 4. ShiftAndGlue.lean -- chronicle_is_good_direct updated
- Replaced `h_accessible` with `h_surj` parameter
- Updated one_class call to match new signature

### 5. Transfer.lean -- call site updated
- Added h_surj sorry at countermodel_discrete_reynolds call site
- Documented need for surjective atomMap construction via fresh atoms
- Removed h_acc (h_accessible) proof block (no longer needed by one_class)

## Remaining Sorry Sites (4)

| # | File | Line | Theorem | Nature |
|---|------|------|---------|--------|
| 1 | GoodStructuresModelSurgery.lean | 348 | `no_gaps_discrete_model_surgery` | Reynolds Theorem 14 core (model surgery). Now correctly requires h_surj. Provable via Lemmas 6-13 + US_expressively_complete_over_prior. ~500 lines. |
| 2 | GoodStructures.lean | 852 | `no_gaps_discrete` | Same theorem, different location. Also correctly requires h_surj. |
| 3 | Transfer.lean | 1116 | `h_surj` construction | Engineering: construct surjective atomMap using fresh atoms for non-atom predicates (bot, box formulas). Atom is Infinite, sig.preds is Fintype. ~50 lines. |
| 4 | Transfer.lean | 1161 | `countermodel_discrete_reynolds` | Z-interval to TaskFrame packaging. Pre-existing sorry. |

## Next Steps (Priority Order)

### 1. Construct h_surj at call site (Transfer.lean:1116) -- ~50 lines
- Enumerate non-atom predicates in sig.preds
- Use Atom.fresh_for to assign distinct fresh atoms
- Modify atomMap_fwd to map fresh atoms to non-atom predicates
- Prove surjectivity

### 2. Implement Reynolds model surgery (GoodStructuresModelSurgery.lean) -- ~500 lines
- Lemma 6: Gap formula R via US_expressively_complete_over_prior
- Lemma 7: R-interval structure (open intervals, excluded endpoints)
- Lemma 8: No first/last class in R-intervals
- Lemma 9: Class homogeneity (classes elementarily equivalent)
- Lemma 10: Bad interval definition and properties
- Lemma 11: Formula propagation in bad intervals
- Lemma 12: Model surgery (domain surgery + truth preservation, 7 subcases for U(A,B))
- Lemma 13: Contradiction (R holds but class doesn't end at gap in surgery model)

### 3. Close no_gaps_discrete (GoodStructures.lean) -- ~10 lines
- Either import from GoodStructuresModelSurgery, or duplicate the proof
- Circular import issue may require restructuring

### 4. Close completeness_discrete pipeline
- Either fix countermodel_discrete_reynolds packaging (Transfer.lean:1161)
- Or use the BX pipeline (dd_countermodel_chronicle_discrete) which also needs h_surj
  propagated through succ_embed_surjective -> limitDomSubtype_isSuccArchimedean

## Build Status

Full `lake build` passes with 0 errors and 1679 jobs.
