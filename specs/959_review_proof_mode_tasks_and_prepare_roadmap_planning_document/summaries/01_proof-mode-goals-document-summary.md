# Implementation Summary: Task #959

- **Task**: 959 - Review proof mode tasks and prepare roadmap planning document
- **Status**: [COMPLETED]
- **Started**: 2026-11-20T06:44:04Z
- **Completed**: 2026-11-20T07:05:00Z
- **Effort**: about 0.5 hours of agent time against a 3.5-hour plan
- **Dependencies**: None
- **Artifacts**: plans/01_proof-mode-goals-document.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

`records/proof-mode.md` is written: a 578-line goals document for the derivation proof mode with
ten sections (Aim, Where it stands, Dimensions, Milestones, Dependency picture, Gates, Lanes,
Open decisions, Not yet filed, Using this document with the roadmap). It defines 20 milestones,
separates hard from sequencing-only dependencies, and gives seven `/task`-ready entries for work
that has no filed record. No Lean, no task record and no dependency edge was changed.

## What Changed

- `records/proof-mode.md` — written from empty (the deliverable)

## Decisions

- **All report figures re-measured and unchanged**: 21 tactics; 5 elaborator files, 1,013 lines;
  8 pure-rule files, 1,157 lines; 624 lines in `Plus*.lean`; 65 `throwError` sites; 31 examples;
  2 `fail_if_success`, 0 `#guard_msgs`; no `#print axioms`; no `typst/` coverage. One figure
  differs: 43 `ruleName` occurrences against the report's 42; it is not used in the document.
- **Import invariant confirmed and sourced**: no file under `FormalSystem/Theorems/` imports
  `FormalSystem.Automation`; `ORGANISATION.md` puts `Theorems/` at layer 2 and `Automation/` and
  `Metalogic/` at layer 3. The document cites that table.
- **Edge (a), linearity case split before Until/Since**: sequencing for introduction and
  unfolding (`left_mono_until_G`, `unfoldForward`, `unfoldBackward`, `unfoldBackwardSince` take
  no linearity premise; `DiscreteUnfolding.lean` does not import `LinearityDerived`);
  undetermined for induction, whose formula is not yet stated.
- **Edge (b), other-language instances before the leads-to library**: sequencing. The library's
  done-when names TM and TM⁺ only.
- **Edge (c), Until/Since rules and usability before Dense and real-time rules**: sequencing.
  `density` takes `Dense ≤ fc`, `coDerived` takes `RTime ≤ fc`, `prior_U_gap` and `sep` are axiom
  constructors at RTime.
- **M7 before M8 moved from hard (report) to sequencing-only**, with the order listed as an open
  decision. The interface record says to extract the interface after the adequacy tests, which
  names M5 and not M7; and M7 after M8 would write the frame rules once instead of twice.
- **Two facts found in the sources and not in the report**: `unfoldBackward` is stated at
  `FrameClass.Base`, not `ZTime` as the filed Until/Since description says; and the Minus
  deduction theorem is under `FormalSystem/Metalogic/` (layer 3), so a Minus instance cannot sit
  under `FormalSystem/Theorems/`. The second is in the document as open decision 6.

## Plan Deviations

- **Task 2.2** altered: M14 is split into M14a (closers from the decision procedures, hard
  dependency M2) and M14b (countermodel bridge, hard dependency M11). The halves have different
  hard dependencies. The document has 20 blocks, not 19, and seven unfiled milestones, not six.
- **Phase 2 verification** altered: `verify-touched.sh` was not re-run in Phase 2; the Phase 3
  run covers the final file.
- **Task 3.7** altered: the path check has three accepted hits, the globs
  `FormalSystem/*Language/` and `Plus*.lean` and the directory
  `Tests/BimodalTest/Automation/ProofMode/`, which M0 creates and the text calls new.
- **Task 3.10** altered: `verify-touched.sh` fails on suites unrelated to the deliverable. All
  three phases are closed `[COMPLETED WITH EXCLUSIONS]` with a Reasoned Exclusions record for
  that one criterion.

## Verification

- Build: N/A (no Lean changed)
- Tests: N/A for the deliverable
- Task-reference lint (`check-task-references.sh`): no finding for `records/proof-mode.md`
- Draft-history grep: no hit
- Slug check: all 14 `proof_mode_*` slugs are `project_name` values in `specs/state.json`
- Structure: 20 milestone blocks, each with all six fields; every dependency ID has a block; the
  diagram matches the blocks' hard dependencies and has no cycle
- `scripts/check-module-invariants.sh`: ALL CHECKS PASSED; no finding names `records/`
- `verify-touched.sh records/proof-mode.md`: fails. No suite maps to the path; the 95-suite
  fallback gives 84 passed and 11 failed in Phase 1, and 83 passed and 12 failed on the final
  file. The 11 are agent-system fixture tests that need the source store `agent-system/extensions/`,
  absent from this repository. The twelfth, `test-lint-state-writer-boundary.sh`, passed when run
  alone.
- Full gate set: deferred to the batch stage under the dispatch's Batch Gate Deferral directive;
  not run in this dispatch.
- Files verified: Yes

## Impacts

- `/roadmap` can be given the quoted instruction in the document's last section.
- The seven "Not yet filed" entries can be passed to `/task`.
- The document lists eight open decisions for the user; none blocks this task.

## Follow-ups

- The 11 failing agent-system suites will also appear in the batch-level gate; they are a
  property of this deploy-only repository, not of this task.
- `records/` has no row in `ORGANISATION.md` (open decision 7 in the document). The invariant
  lint does not object.
- The filed description of `proof_mode_until_since_intro_unfold_induction` says the unfolding
  theorems are all at `ZTime`; `unfoldBackward` is at `Base`. Not edited here.

## References

- `specs/959_review_proof_mode_tasks_and_prepare_roadmap_planning_document/plans/01_proof-mode-goals-document.md`
- `specs/959_review_proof_mode_tasks_and_prepare_roadmap_planning_document/reports/01_proof-mode-roadmap-review.md`
- `records/proof-mode.md`
