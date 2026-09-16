# Implementation Summary: Task #598

- **Task**: 598 - Derive nullity_identity instead of carrying it as a FrameOver field
- **Status**: [COMPLETED]
- **Started**: 2026-09-16T11:54:43-07:00
- **Completed**: 2026-09-16T12:55:00-07:00
- **Effort**: ~1 hour
- **Dependencies**: None
- **Artifacts**: plans/01_derive-nullity-identity.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

`FrameOver` no longer has a `nullity_identity` field. The structure now holds exactly the paper's
four `def:frame` axioms (`comp`, `serial`, `limit`, `saturation`), plus `converse` and a nonempty
`WorldState`. `FrameOver.nullity_identity` is now a theorem with the same statement, so every
existing consumer compiles unchanged.

## What Changed

- `FormalSystem/Semantics/TaskFrame.lean` — moved `TaskFrame.nullity_of_serial_limit` here from
  `FrameAxioms.lean`, ahead of the structure, with the same fully qualified name and
  `omit [Nontrivial D]`. Added the derived theorems `FrameOver.nullity` (from `serial` + `limit`),
  `FrameOver.eq_of_taskRel_zero` (from `limit` alone) and `FrameOver.nullity_identity`. Deleted the
  field and its long docstring. `limit_of_succOrder` now takes `R w 0 u → u = w`. Deleted
  `nullity_identity_of_permissive` and the field lines in `trivialFrame`, `staticFrame` and
  `natFrame`. Rewrote the module docstring, the paper-alignment text and the `limit` docstring.
- The field line (or block) was deleted in 15 more places: `Frames/Standard.lean` (2),
  `IntNormalForm.lean`, `IntTransfer.lean`, `ShiftSet.lean`, `Examples/TemporalStructures.lean` (3),
  `Independence/ClockFrame.lean`, `Independence/DriftFrame.lean`,
  `Independence/ForwardDeterministicFrame.lean`, `Algebraic/FlowFrame.lean`,
  `IntegerModel/ReynoldsBridge.lean`, `Bridge/RegionFrame.lean` and `FMP/Filtration.lean`.
- Deleted `fzero_nullity` (DriftFrame). Replaced `fn_nullity` with the one-direction `fn_eq_of_zero`
  (ForwardDeterministicFrame).
- `multiFamGen_limit` (FlowFrame) and `regionFrame_limit` (RegionFrame) now just use the frame's own
  `.limit` field.
- Prose updates (docstrings and comments only) in 19 Lean files, including `Semantics.lean`,
  `Extension/Admissible.lean`, `DeterministicBridge.lean` and `Tests/BimodalTest/Property/Generators.lean`.
  Stale field counts ("six"/"seven") were fixed or replaced with field names. The `compositionality`
  row in the `Semantics.lean` table now says `comp`.
- Updated docs: `README.md`, `FormalSystem/Semantics/README.md`, `docs/reference/API_REFERENCE.md`,
  `docs/user-guide/architecture.md`, `typst/chapters/02-semantics.typ` and `typst/chapters/06-notes.typ`.
  Removed the "strictly stronger" and "construction ergonomics" claims and the `CONFIRM(lean)` comment.

## Decisions

- Weakened `limit_of_succOrder` to the one-direction zero hypothesis, as the plan chose. That made
  `nullity_identity_of_permissive` dead, so it was deleted.
- Renamed `fn_nullity` to `fn_eq_of_zero`, because it now proves only injectivity.
- Another task was moving the tree from `ConvexHistory` to `PartialHistory` in the same files at the
  same time. Phases 2 and 3 were therefore committed from blobs built as HEAD plus this task's own
  text transformations. This kept the other task's hunks out of these commits and left the shared
  index consistent.

## Plan Deviations

- **Phase 1** altered: ran a scoped build of the six touched modules plus `Extension.Admissible`.
  The full build was deferred to Phase 2.
- **Phase 1/2** altered: `fn_nullity` was replaced by `fn_eq_of_zero`.
- **Phase 2** altered: 18 field sites, not 17 (3 in TaskFrame.lean plus 15 elsewhere).
- **Phase 3** skipped: the `ConvexHistory.lean` passage no longer exists, because the concurrent
  history migration folded that file into `PartialHistory.lean`.
- **Phase 3** altered: checked with a full FormalSystem build instead of per-module builds.
- **Phase 4** altered: also fixed the frame paragraph in the top-level `README.md`.
- **Phase 5** skipped: the invariant and README lint scripts do not exist.

## Verification

- Build: Success. Full `lake build` (FormalSystem, 2659 jobs, run without shared results) and
  `lake build BimodalTest` (2717 jobs) both passed on the shared working tree.
- Sorry count: 0 outside `FormalSystem/Boneyard/`, which is not built. No new `sorry` lines in the diff.
- Vacuous count: 0 new. The one existing pattern hit, `int_domain_universal := trivial`, is a
  real proof of a `True` domain and was already there.
- Axiom count: 14 before and 14 after (unchanged).
- `lean_verify`: `FrameOver.nullity`, `FrameOver.eq_of_taskRel_zero`, `FrameOver.nullity_identity`
  and `TaskFrame.nullity_of_serial_limit` use only `[propext]`. `limit_of_succOrder` uses the
  standard `[propext, Classical.choice, Quot.sound]`, which come from the Mathlib order lemmas.
- Structure check: `FrameOver` has exactly `WorldState`, `worldNonempty`, `TaskRel`, `comp`,
  `converse`, `serial`, `limit` and `saturation`.
- Typst: `typst compile typst/BimodalReference.typ` succeeds.
- Files verified: Yes

## Impacts

- Building a frame no longer needs a zero-duration proof. The discharges are the four axioms, `converse`
  and the nonempty carrier.
- `FrameOver.eq_of_taskRel_zero` is a new, directly usable lemma.

## Follow-ups

- None

## References

- specs/598_derive_nullity_identity/plans/01_derive-nullity-identity.md
- specs/598_derive_nullity_identity/reports/01_derive-nullity-identity.md
