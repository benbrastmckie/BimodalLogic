# Implementation Summary: Task #600

- **Task**: 600 - Rename dense extension to QTime (investigate first)
- **Status**: [COMPLETED]
- **Started**: 2026-09-18T14:36:04Z
- **Completed**: 2026-09-18T15:10:00Z
- **Effort**: ~35 minutes
- **Dependencies**: Task 603 (ℚ-time frame predicate investigation), completed
- **Artifacts**: plans/02_dense-rationale-qtime-predicate.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

`FrameClass.Dense` keeps its name. Nothing was renamed. The naming rationale is now recorded once,
on the `FrameClass` docstring, and it cites the machine-checked theorem
`Metalogic.validQTime_iff_validDense` rather than asserting "the dense logic is the ℚ-time logic"
in prose. All of the ℚ-time Lean content the plan asked for (Phases 1-2) had already been delivered,
sorry-free, by task 603's implementation. This run verified it in place and did not duplicate it.

## What Changed

- `FormalSystem/ProofSystem/Axioms.lean`: added the paragraph "**Why this class is named `Dense` and not
  `QTime`.**" to the `FrameClass` docstring. It covers (a) `ZTime`/`RTime` are named for their carriers
  because they are categorical; (b) the dense class is not categorical and cannot be narrowed to ℚ,
  because `Dense ≤ RTime`; (c) its validity equals ℚ-time validity (`validQTime_iff_validDense`, via
  `derivable_of_validQTime`), for validity only, since set-based strong completeness over ℚ-time is open;
  ℚ-time is a predicate, not a tag; (d) the name follows the paper's d/z/r subscripts
  (`def:frame-properties`, `def:BX-d`); (e) the paper says "ℚ-time" only where ℚ and the dense class
  differ (Kamp).
- `FormalSystem/Semantics/FrameProperty.lean`: added a pointer to the `TaskFrame.IsDense` docstring
  (it is a bare paper clause, its ℚ-time narrowing is `IsQTime`, and the full argument is on
  `FrameClass`).
- `FormalSystem/Semantics/FrameClassValidity.lean`: added a one-sentence pointer on the `.Dense` bullet.
- `docs/theorem-index.md`: added a naming note on the TM_d row that cites
  `FormalSystem.Metalogic.validQTime_iff_validDense`.
- Pre-existing and verified, not written here: `TaskFrame.IsQTime`, `TaskFrame.isDense_of_isQTime`
  (FrameProperty.lean); `ValidQTime`, `Validity.validQTime_of_validDense` (Validity.lean);
  `BXCanonical.isQTime_rat`, `BXCanonical.derivable_of_validQTime` (BXCanonical/Completeness.lean);
  `Metalogic.validQTime_iff_validDense` (Metalogic/QTime.lean).

## Decisions

- Did not add an alias `validDense_iff_validQTime` (the plan's provisional name). Task 603's name and
  orientation (`validQTime_iff_validDense`) already exist. The plan's Goals and Challenge block were
  updated to match, as the plan allows.
- The `IsQTime` docstring already says it is not a tag, so the `IsQTime`-to-`FrameClass` back-pointer
  was not added separately. The `IsDense` pointer and the module docstring cross-reference it.

## Plan Deviations

- **Phase 1** altered: the declarations already existed (task 603). They were verified, not written. The
  ℚ witness is named `isQTime_rat` and lives in BXCanonical/Completeness.lean.
- **Phase 2** altered: already delivered. The equivalence is `validQTime_iff_validDense` in
  Metalogic/QTime.lean, not StrongCompleteness.lean.
- **Phase 3** excluded: 603 report, `ratIso` costs ~120-200 lines, recommend deferring.
- **Phase 4** excluded: 603 report, strong completeness over ℚ-time is not nearly free (ultrapowers of ℚ
  are non-Archimedean).
- Lean Challenge Statements were never finalized, so this task ran without a Comparator Challenge.

## Verification

- Build: Success (full `lake build`, 2661 jobs; a first run hit transient olean-write races from a concurrent invariants run and was rerun clean)
- `scripts/check-module-invariants.sh`: all groups PASS after regenerating the README inventory block (comment-line count)
- Sorry count: 0 in touched files (the changes are docstrings only)
- Vacuous count: 0
- Axiom count: 15 `^axiom` lines, unchanged (no Lean declarations added)
- `lean_verify` `Metalogic.validQTime_iff_validDense`: `[propext, Classical.choice, Quot.sound]`
- Task-reference check: no task-number citations in the changed deliverables (manual diff grep; the
  repository lint's path scope does not cover `FormalSystem/`)
- Paper-anchor lint (`scripts/check-paper-definitions.sh`): pass
- No identifier renamed; `FrameClass` still has four constructors
- Files verified: Yes

## Impacts

- Readers who ask "why not `QTime`?" now find the answer on `FrameClass`, backed by a theorem.

## Follow-ups

- Optional `ratIso` (`≃+o ℚ` classification) and set-based strong completeness over ℚ-time remain open.

## References

- specs/600_rename_dense_extension_qtime/reports/01_dense-vs-qtime-naming.md
- specs/603_investigate_qtime_frame_predicate/reports/01_qtime-frame-predicate.md
- specs/600_rename_dense_extension_qtime/plans/02_dense-rationale-qtime-predicate.md
