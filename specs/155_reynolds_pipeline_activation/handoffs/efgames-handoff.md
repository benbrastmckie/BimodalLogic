# EFGames.lean: stavi_expressive_completeness Handoff

**Date**: 2026-05-23
**Session**: sess_1779565373_9bf0c5
**File**: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames.lean`

## What Was Done

The `stavi_expressive_completeness` sorry was refactored into a modular proof:

1. **New helper definitions** (lines 9138-9182):
   - `sf_disj`: StaviFormula disjunction via De Morgan
   - `sf_disjList`: Iterated StaviFormula disjunction
   - `sf_disj_iff`, `sf_disjList_iff`: Correctness proofs

2. **Key lemma extracted** (lines 9186-9194):
   - `nf_characterizable_by_stavi`: For every NormalForm at depth k with 1 variable,
     there exists a StaviFormula characterizing it.
   - This is the game-theoretic core of GHR93 Theorem 9.3.1.
   - Currently sorry'd.

3. **Assembly proof completed** (lines 9196-9275):
   - `stavi_expressive_completeness` is now sorry-free modulo `nf_characterizable_by_stavi`.
   - Uses NormalForm partition + `doets_lemma_1_1` + finiteness.
   - Signature changed: added `h_surj` parameter for atom-surjectivity of atomMap.

## Signature Change

The function signature changed from:
```
(sig : MonadicSignature) (atomMap : Formula → sig.preds)
(psi : MonadicFormula sig 1)
```
to:
```
(sig : MonadicSignature) (atomMap : Formula → sig.preds)
(h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
(psi : MonadicFormula sig 1)
```

The `h_surj` parameter is necessary: without it, the theorem is provably false
(predicates not in the range of atomMap cannot be distinguished by StaviFormulas).
No downstream callers exist yet.

## Remaining Sorry

One sorry in `nf_characterizable_by_stavi` (line 9194). This is the game-theoretic
core of GHR93: constructing StaviFormulas that characterize NormalForms. The proof
requires:
- k = 0: conjunction of predicate atoms/negations (straightforward)
- k + 1: encoding quantifier structure using U/S/U'/S' (game theory needed)

## Build Status

`lake build` passes with warnings only. No errors.
