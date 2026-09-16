# Implementation Summary: Task #599

- **Task**: 599 - Unify total histories on PartialHistory (drop ConvexHistory as a structure)
- **Status**: [COMPLETED]
- **Started**: 2026-09-16T18:54:55Z
- **Completed**: 2026-09-16T20:02:00Z
- **Effort**: ~1.1 hours
- **Dependencies**: None
- **Artifacts**: plans/01_unify-total-histories-partial.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

The `ConvexHistory` structure is gone. The history layer now rests on `PartialHistory` alone:
totality is defined once (`PartialHistory.IsTotal`), convexity is a predicate
(`PartialHistory.IsConvex`), and `TaskFrame.HF := {τ : PartialHistory F // τ.IsTotal}`. Truth
(all four languages), truth transport, the ℤ transfer, and validity range over
`PartialHistory F`. The docs, the decision record, and the PossibleWorlds talk slide now match.

## What Changed

- `FormalSystem/Semantics/PartialHistory.lean`: gained `states_eq_of_time_eq` (explicit times),
  `IsConvex`, `IsTotal.isConvex`, `timeShift`/`timeShift_domain`, `isTotal_timeShift`,
  `isConvex_timeShift`, `ofTotal` (+ simp lemmas, `ofTotal_isTotal`), `trivialFrameHistory`,
  `TaskFrame.HF` / `HF.ofTotal` / `HF.timeShift` / `FrameOver.HF`. Module docstring rewritten
  (paper-to-Lean tier table).
- `FormalSystem/Semantics/PartialHistoryOrder.lean`: lost the moved declarations; only order
  content remains.
- `FormalSystem/Semantics/ConvexHistory.lean`: deleted, including the dead `universal`,
  `universalTrivialFrame`, `universalNatFrame`, `stateAt`, and `timeShift_congr`.
- `FormalSystem/Semantics/Extension/Extension.lean`: deleted `total_isConvex`, `toConvexHistory`
  and its two lemmas. `extension : ∃ σ : F.HF, Extends σ.val τ`, proved by `⟨⟨μ, htot⟩, le_def.mp hle⟩`.
- `IntTransfer.lean`: `PartialHistory.map`/`comap`, with no `convex` blocks. All 12 history
  `convex :=` fields removed. `.toPartialHistory` projections removed.
- About 93 consumer Lean files renamed (Semantics, Metalogic, Automation, Examples, Tests).
  Residual hand fixes: flattened `⟨⟨…⟩, conv⟩` destructurings (ShiftSet, RegionFrame, FlowFrame,
  ReynoldsBridge), `congr 2` changed to `congr 1` after the flattened `change PartialHistory.mk …`
  goals, and `convexHistory_ext` renamed to `partialHistory_ext`.
- Docs: `docs/architecture/total-history-validity-decisions.md` (new Decision B', plus a
  superseded-in-part note on B), `docs/reference/paper-definitions-of-record.md` (body/appendix
  wording note), API_REFERENCE, architecture, tutorial, theorem-index, style guide, READMEs, and
  the typst chapter.
- PossibleWorlds `talks/57_possible_worlds_tense_modal/slides.md` (commit `108c7e5a`): history
  slide uses `IsConvex`/`IsTotal` on `PartialHistory`, `HF` over `PartialHistory`, and
  `TruthAt`/box/`timeShift_preserves_truth` over `PartialHistory`.

## Decisions

- Decision A (the hybrid predicate/subtype encoding) is kept and only re-based onto
  `PartialHistory`. This was the research agent's non-blocking recommendation, adopted by default,
  not an explicit user answer. Full bundling over `F.HF` is recorded as the deferred alternative.
- The abbrev/alias shim was abandoned after a probe. `alias ConvexHistory.timeShift` breaks
  generalized field notation on `τ : ConvexHistory F`, and a typed wrapper def blocks
  `simp [timeShift_domain]`. The plan's atomic-batch fallback was used instead.

## Plan Deviations

- **Phase 1** altered: `isTotal_iff` skipped (no caller).
- **Phases 2-6** altered: merged into one atomic-batch sweep (commit `0688a7a3c`) instead of
  shim-then-rename-by-directory. `ConvexHistory.lean` was deleted outright.
- **Phase 7** altered: also updated `README.md`, `FormalSystem/**/README.md`, and typst prose.
  `docs/development/PHASED_IMPLEMENTATION.md` was left untouched: its `ConvexHistory` mentions
  describe past work.
- **Phase 8** altered: `slides.md` already had another session's uncommitted edits, so only this
  task's hunks were staged (HEAD plus these hunks written into the index). The `.stab`-clause
  binder fix lies inside that other uncommitted hunk. It is applied in the working tree but not
  committed. The slide deck build was not run.

## Verification

- Build: Success. Full `lake build FormalSystem BimodalTest` passed (2718 jobs), after the final Lean edit.
- Sorry count: 0 in live code (census total 160, all in `Boneyard/`, unchanged from baseline)
- Vacuous count: 0 new. The one grep hit, `int_domain_universal`, was there before and is a real lemma.
- Axiom count: unchanged (0 `axiom` declarations. The 11 grep hits are all docstring prose, same as the baseline).
- `lean_verify`: `PartialHistory.extension`, `hF_nonempty`, and `Metalogic.soundness` use
  [propext, Classical.choice, Quot.sound]. `isTotal_timeShift` uses [propext], and `isConvex_timeShift` uses
  [propext, Quot.sound].
- `check-paper-definitions.sh`: 16 drifted + 1 unresolved, the same as the baseline. `check-task-references.sh`: PASS.
- Live `ConvexHistory` identifiers: 0. The one remaining mention in Lean is a deliberate docstring
  sentence in PartialHistory.lean. The decision record and the historical record keep their mentions on purpose.
- Tests: `BimodalTest` builds. Files verified: Yes.

## Impacts

- Downstream code builds histories with `PartialHistory.ofTotal`, or with plain
  `PartialHistory` records that have no `convex` field. The API names `PartialHistory.timeShift`,
  `isTotal_timeShift`, `states_eq_of_time_eq`, `trivialFrameHistory`, `map`, and `comap` replace the
  old `ConvexHistory.*` names.
- `timeShift_domain` is now a simp lemma on every shifted history that truth ranges over.

## Follow-ups

- In the PossibleWorlds repo, commit the `.stab` clause binder fix (`ConvexHistory` changed to
  `PartialHistory`) together with the owner's in-progress slide edits.
- Optional: bundle truth and validity over `F.HF` (Decision A alternative).
- Optional: merge `ShiftSet.wh_ext` and `RegionFrame.partialHistory_ext` into one
  `PartialHistory.ext`.

## References

- specs/599_unify_total_histories_partial/plans/01_unify-total-histories-partial.md
- specs/599_unify_total_histories_partial/reports/01_unify-total-histories-partial.md
- docs/architecture/total-history-validity-decisions.md (Decision B')
