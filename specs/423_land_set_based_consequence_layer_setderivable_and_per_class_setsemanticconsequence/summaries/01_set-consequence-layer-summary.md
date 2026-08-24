# Implementation Summary: Task #423 — the set-based consequence layer

- **Task**: 423 - Land the set-based consequence layer (SetDerivable and per-class
  SetSemanticConsequence*)
- **Plan**: `plans/01_set-consequence-layer.md`
- **Research**: `reports/01_set-consequence-layer-research.md`
- **Type**: lean4
- **Session**: sess_1787608533_153fad

## What Landed

`FormalSystem/Metalogic/SetConsequence.lean` (new, 19 declarations, zero sorries):

- `SetDerivable` — finitary derivability from a possibly-infinite premise set.
- Four per-class predicates — `SetSemanticConsequenceBase`, `...Dense`, `...Discrete`,
  `...DedekindDense`.
- Ten basic lemmas — `setDerivable_mono`, the four sibling `_mono` lemmas,
  `setDerivable_iff_exists_finite`, `setDerivable_of_derivable`,
  `derivable_of_setDerivable_contextToSet`, `setDerivable_of_mem`,
  `not_setConsistent_of_setDerivable_bot`.
- Four vocabulary definitions — `StrongCompletenessDense`, `CompactDense`,
  `SatisfiableDenseSet`, `ModelExistenceDense`.

`FormalSystem/Metalogic/StrongCompleteness.lean` (insertions only, 29 lines, 0 deletions):

- `import FormalSystem.Metalogic.SetConsequence`.
- `strongCompletenessDense_of_compact`, placed below `derivable_foldr_imp_iff`.

This is a vocabulary layer. It proves no compactness result and closes no existing proof gap.

## Binding Constraints Honoured

**D1 — `Validity.lean` wins over design/01.** design/01 §3/§5's `Omega`/`ShiftClosed` binder
blocks are stale: `ShiftClosed` exists only under `Boneyard/` and `TruthAt` is four-ary. Every
binder block was sliced mechanically from the live `Validity.lean` (`valid` :94, `ValidDense`
:206, `ValidDiscrete` :222, `ValidDedekindDense` :310, all re-verified by symbol). Recorded diff
output shows each of the four definitions differs from its source in exactly one line — the
conclusion, carrying the inserted premise hypothesis `(∀ ψ ∈ Γ, TruthAt M τ t ψ) →`. Bare `Type`
throughout; zero `Type*`; zero `Omega`/`ShiftClosed` occurrences.

**D2 — Option C, no duplication.** `strongCompletenessDense_of_compact` needs
`derivable_foldr_imp_iff`, which lives only in `StrongCompleteness.lean` — the module that
imports the new one. The theorem therefore went into `StrongCompleteness.lean`. The three
`foldr_imp` lemmas were neither relocated (Option M, rejected) nor duplicated;
`truthAt_foldr_imp` stayed put, its occurrence count unchanged at 6.

## Plan Deviations

- **Phase 2, altered**: the module docstring originally read "no existing `sorry` … is closed by
  this module". Reworded to "no existing proof gap …" so that the Phase 2 and Phase 5
  `grep -c 'sorry'` acceptance gate reads `0` literally rather than matching prose.
- **Phase 3, altered**: the module docstring's "Downstream" paragraph originally named
  `derivable_foldr_imp_iff` when explaining why the one theorem lives in `StrongCompleteness.lean`.
  Reworded to describe it as "the `foldr`-implication bridge" so the Phase 3
  `grep -c 'derivable_foldr_imp'` gate reads `0` literally. The explanation itself is preserved.

Neither reword changes any declaration; both keep the mechanical acceptance gates honest.

## Out of Scope, Confirmed Untouched

No `SetSemanticConsequenceDedekind`; no compactness proof; no `consequence_completeness_*`
additions; no `truthAt_foldr_imp` relocation; no edit to `FormalSystem/Metalogic.lean` (which
already imports `StrongCompleteness`, so the new module is transitively reachable from the
library root).
