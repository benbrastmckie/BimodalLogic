# Phase 7 Handoff: WF Restructure Complete, Atom Elimination Proofs Remain

**Date**: 2026-05-17 (sixth attempt)
**Session**: sess_1779042202_561806
**Status**: PARTIAL (5 sorries remain, formula construction complete)

## What Changed

Restructured `expressiveness_fixed_atomMap` from structural recursion with sorry-pairs (`<sorry, sorry>`) to well-founded induction on quantifier depth with actual formula constructions. The 2 original sorry-pairs (which gave up on both the formula AND the proof) are replaced by 5 sorries that are all in correctness PROOFS with concrete formula constructions.

Key architectural change: inner structural recursion (`expressiveness_inner`) + outer WF recursion (`expressiveness_wf` via `Nat.strongRecOn`).

## Remaining Sorries (5 total)

1. `applySubsts_past_correct` (line ~703) - sequential substitution for past-only formulas
2. `applySubsts_future_correct` (line ~712) - sequential substitution for future-only formulas
3. `.ex` forward direction (line ~817) - eval exists -> int_truth A
4. `.ex` backward direction (line ~821) - int_truth A -> eval exists
5. `.all` case (line ~859) - similar chain with negation

All reduce to proving `atom_elim_correct`: that `elimExtFromSep` correctly translates truth between the extended model `to_int_struct (extIntStruct M t) freshAM` and the original model `to_int_struct M atomMap`.

## Proof Strategy for atom_elim_correct

For matching sigma and properly separated B:
```
int_truth M_orig t (elimExtFromSep subs lt_atom gt_atom B) <-> int_truth M_ext t B
```

By structural induction on B. For temporal cases (all_past phi where is_past_only phi = true):
- Use `past_only_is_pure_past` to show M_mod and M_ext agree at times <= s < t
- The agreement was verified for all 4 atom types (orig, const_at_ref, lt_ref, gt_ref)
- The `applySubsts` connects M_orig to M_mod via `subst_correctness`

## Key Design Decision

Used `freshAM` (canonical atomMap with base "e") instead of `extAtomMap atomMap` to avoid collision issues across recursion levels. Requires explicit orig atom substitution via `origSubsList`.

## Immediate Next Action

Implement `atom_elim_correct` lemma (~150 lines), then close the 5 sorries using it.
