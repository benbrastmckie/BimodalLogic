# Phase 6 handoff — task 417, plan 05, dispatch 6

**Immediate next action**: Phase 7 — `truth_along_annot` in a new
`FormalSystem/Metalogic/Decidability/BiLasso/TruthLemma.lean`. Declared stop-and-escalate point.

## State

Phases 4, 5, 6 `[COMPLETED]`. All new modules build clean and sorry-free; `Basic.lean` verified
byte-identical after every phase.

- `BiLasso/Unfold.lean` — `truth_untl_succ`, `truth_snce_pred`, `Int.rightInduction`,
  `Int.leftInduction`
- `BiLasso/Periodic.lean` — generic `cyc` / `unrollOf` + both periodicities at arbitrary
  `[Inhabited α]`
- `BiLasso/Annotation.lean` — `Annot`, `Annot.label`, `Annot.readIndex`,
  `Annot.label_unroll_aligned`, both label periodicities, `Annot.label_subset_closure`, and the
  three predicates `LocalCoherent`, `Fulfilling`, `BoxOracleSound`
- `BiLasso/Examples.lean` — `posAnnot` (coherent **and** fulfilling), `negAnnot` (coherent, **not**
  fulfilling), `fulfilling_not_implied_by_localCoherent`, `boxOracle_false_not_sound`

No `FormalSystem.Metalogic.BXCanonical.*` import anywhere under `BiLasso/` (only a docstring
mention explaining the non-reuse).

## Key decisions

- The `Quasimodel/` machinery was read and deliberately not reused; the reason is recorded in
  `Annotation.lean`'s module docstring (no atom/imp/box clause; `allFuture`/`allPast` step
  relation rather than the exact ℤ unfolding; `noncomputable` MCS provenance).
- Witnesses use a purpose-built one-state self-looping `loopPresentation` with a constant path,
  so labels are literally constant and the arguments are checkable by inspection. `flipPresentation`
  was unusable: its valuation ignores the atom, so it cannot separate a true guard from a false
  event.
- `negAnnot` carries `p U q` (guard `p`, event `q`) on a loop where `q` never holds — the
  eventuality postponed forever around the forward loop.
- Added `boxOracle_false_not_sound` beyond the plan's task list, to discharge the phase's own
  verification criterion that `BoxOracleSound` not be an unconditional predicate.

## REPORT FOR A SEPARATE TASK (not fixed here, per plan instruction)

The argument roles in `Metalogic/BXCanonical/Quasimodel/Construction.lean` are genuinely stale
against the guard-first migration:

- `:57` — `HintikkaStep`'s until clause reads
  `Formula.untl ψ φ ∈ h1.formulas → ψ ∉ h1.formulas → φ ∈ h1.formulas ∧ Formula.untl ψ φ ∈ h2.formulas`,
  i.e. "guard absent → event present". Guard-first semantics require the transpose: "event
  absent → guard present, obligation propagates".
- `:64` `UntilDefect` and `:68` `SinceDefect` carry the same transposition
  (`Formula.untl ψ φ ∈ h.formulas ∧ ψ ∉ h.formulas` — defect defined by the *guard* being absent
  rather than the *event*).

The surrounding docstrings still use the retired event-first naming, which is how the
transposition survived. Left untouched, as the plan directs.

## Deviations

None.
