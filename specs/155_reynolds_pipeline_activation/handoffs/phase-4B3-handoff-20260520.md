# Phase 4B.3 Handoff: Relativized Formulas and Type Formulas

**Task**: 155 (Reynolds Pipeline Activation)
**Phase**: 4B.3
**Session**: sess_1779304083_f28ee0
**Status**: COMPLETED
**Date**: 2026-05-20

## What Was Done

Implemented GHR93 Definitions 8.4 and 8.8 in `EFGames.lean`:

1. **`extendedStructure`** (line ~598): Wraps `ExtendedCarrier M atomMap r` as an `OrderedMonadicStructure sig`. Predicates at gaps are false; predicates at actual points inherit from M.

2. **`mu_holds`** (line ~609): The mu predicate, true at actual points (IsPoint), false at gaps. With helper theorems `mu_holds_point` and `not_mu_holds_gap`.

3. **`temporal_truth_mu`** (line ~650): Mu-relativized temporal truth for standard `Formula` type. Atoms use extended structure interpretation (false at gaps). Until/Since quantify only over mu-points. This is needed because `stavi_temporal_truth_mu` delegates to it for `.base` formulas.

4. **`stavi_temporal_truth_mu`** (line ~680): Mu-relativized temporal truth for `StaviFormula`. The A^mu evaluation from GHR93 Def 8.4. All connectives (U, S, U', S') restricted to mu-points.

5. **`rank_type`** (line ~715): The rank-r type X_t -- the set of StaviFormulas of depth <= r that are true at t under mu-relativization.

6. **`interval_types`** (line ~725): The set of rank-r types X_{(t,u)} realized by actual points in the open interval (t,u).

7. Helper theorems: `rank_type_eq_iff`, `mem_rank_type_iff`, `stavi_depth_neg`, `neg_mem_rank_type_of_not`.

## Key Design Decisions

- **Types as sets, not formulas**: `rank_type` returns `Set StaviFormula` rather than constructing a conjunction formula. This is more natural for Lean and matches the semantic approach: we compare types by set equality rather than formula equivalence.

- **`temporal_truth_mu` separated from `temporal_truth`**: Rather than reusing the existing `temporal_truth` on `extendedStructure` (which quantifies over ALL elements including gaps), we define a separate `temporal_truth_mu` that restricts Until/Since to mu-points. This correctly implements the A^mu relativization.

- **Point agreement deferred**: The theorem "for actual point t, A(t) <-> A^mu(t)" was described in the plan but deferred because it requires careful handling of the embedding between M and M_r. This will be needed in Phase 4C.

## Immediate Next Action

**Task 4B.4**: Gap Detection Formulas -- left() and right() (GHR93 Def 8.5 + Lemma 9).
- Define `left_formula` by structural induction on StaviFormula
- Define `right_formula` by duality
- Prove rank bound
- Prove Lemma 9 (gap detection equivalence)

## Build Status

`lake build` passes. Zero new sorries. Zero axioms. Zero vacuous definitions.

## Files Modified

- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames.lean` (lines 577-781 added, ~200 lines)
