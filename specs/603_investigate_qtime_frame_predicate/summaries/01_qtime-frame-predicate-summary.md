# Implementation Summary: Task #603

- **Task**: 603 - Investigate a ℚ-time frame predicate (`TaskFrame.IsQTime`)
- **Status**: [COMPLETED]
- **Started**: 2026-09-18T07:12:12Z
- **Completed**: 2026-09-18T07:42:49Z
- **Effort**: ~30 minutes
- **Dependencies**: None
- **Artifacts**: plans/01_qtime-frame-predicate.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Added the intrinsic ℚ-time frame predicate `TaskFrame.IsQTime` (divisible + pairwise
commensurable, research candidate (a)) beside `IsZTime`/`IsRTime`, its validity notion
`ValidQTime`, and proved `ValidQTime φ ↔ ValidDense φ` sorry-free with standard axioms only.
The dense completeness engine now runs through ℚ-time. No `FrameClass` constructor was added and
`FrameClass.Sat` is untouched.

## What Changed

- `FormalSystem/Semantics/FrameProperty.lean` — `def TaskFrame.IsQTime` (plain `def`, docstring
  records near-miss groups, why it is intrinsic, why it has no density conjunct, and why it is not a tag);
  `theorem TaskFrame.isDense_of_isQTime`; module docstring updated (six predicates, narrowed
  classes). No imports added; the `assert_not_exists` guard is intact.
- `FormalSystem/Semantics/Validity.lean` — `def ValidQTime := ValidOnFrames TaskFrame.IsQTime`
  (docstring: equals `ValidDense`, only weak completeness transfers, set-based strong completeness
  over ℚ-time open); `theorem Validity.validQTime_of_validDense`.
- `FormalSystem/Metalogic/BXCanonical/Completeness.lean` — `theorem isQTime_rat`,
  `theorem derivable_of_validQTime`; `derivable_of_validDense` is now a one-liner through them
  (same name and signature).
- `FormalSystem/Metalogic/QTime.lean` (new) — `theorem validQTime_iff_validDense`; registered in
  `FormalSystem/Metalogic.lean` (import + results bullet).
- `Tests/BimodalTest/Semantics/QTimeTest.lean` (new) — ℚ frames are ℚ-time and dense; no ℤ frame
  is ℚ-time; both directions of the iff; four `#guard_msgs`-gated `#print axioms` pins. Registered
  in `Tests/BimodalTest.lean` and the Semantics test README.
- Generated inventory blocks regenerated (`README.md`, `FormalSystem/README.md`,
  `FormalSystem/Metalogic/README.md`, `FormalSystem/Metalogic/Independence/README.md`). This also
  absorbed some small line-count drift from earlier commits in other directories.

## Decisions

- `IsQTime` is a plain `def`: it is never a `Sat` target, so `abbrev` and `class` are unnecessary.
- `QTime.lean` is a new module because `Completeness.lean` does not reach `soundness_dense_valid`
  (checked: the identifier is unknown under that import alone).
- The unplanned corollary `derivable_iff_validQTime` was drafted and then removed to keep to the plan.

## Plan Deviations

- **Task 2.3** altered: `validQTime_of_validDense` placed in `namespace Validity` (beside
  `validRTime_of_validComplete`, local convention); full name `Validity.validQTime_of_validDense`.

## Verification

- Build: Success (full `lake build`, 2660 jobs; `BimodalTest.Semantics.QTimeTest` also built)
- Sorry count: 0 in live code and touched files (the only census hits are pre-existing ones in `Boneyard/`)
- Vacuous count: 0
- Axiom count: 14, unchanged from base
- Tests: Passed (`#guard_msgs` pins `[propext, Classical.choice, Quot.sound]` for
  `isDense_of_isQTime`, `isQTime_rat`, `derivable_of_validQTime`, `validQTime_iff_validDense`)
- `scripts/check-module-invariants.sh`: all groups PASS (incl. C9, no task-number citations)
- Files verified: Yes

## Impacts

- `ValidQTime` is now available as a named ℚ-time validity class equal to `ValidDense`.
- `derivable_of_validQTime` is the dense completeness engine at its natural strength.

## Follow-ups

- Optional `ratIso : F.IsQTime → Nonempty (F.Duration ≃+o ℚ)` in `DurationClassification.lean`
  and a `ValidRat` transfer (deferred per plan).
- Finite-context consequence completeness over ℚ-time needs a frame-predicate-indexed consequence
  layer. Set-based strong completeness over ℚ-time is open research.
- Paper-sync: `metalogic.tex` (l.349-352) sketches strong completeness of TM^d with T^c = ℚ. The
  tree does not establish this for infinite sets. Flag it to the paper-alignment chain.

## References

- specs/603_investigate_qtime_frame_predicate/reports/01_qtime-frame-predicate.md
- specs/603_investigate_qtime_frame_predicate/plans/01_qtime-frame-predicate.md
