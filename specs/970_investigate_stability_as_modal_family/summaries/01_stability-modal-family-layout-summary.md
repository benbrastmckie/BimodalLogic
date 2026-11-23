# Implementation Summary: Task #970

- **Task**: 970 - Investigate whether the stability operator belongs in the Modal operator family
- **Status**: [COMPLETED]
- **Started**: 2026-11-23T22:10:00Z
- **Completed**: 2026-11-23T22:23:00Z
- **Effort**: about 15 minutes of agent time against a 5 hour estimate
- **Dependencies**: None
- **Artifacts**: plans/01_stability-modal-family-layout.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

The task's deliverable, `docs/development/stability-operator-family.md`, is written and indexed.
It recommends one family: `⊡` stays in Modal, read as the necessity operators over histories.
The three design records now state that layout as settled, with the shared statement stratified
into a K core plus T, 4 and 5, the operator set a coordinate of the lattice, and three
per-operator pieces named outside the shared statement. Six filed task descriptions had their
"may reverse this" hedges replaced by one settled sentence each. No Lean file was touched.

## What Changed

- `docs/development/stability-operator-family.md` — Created. Covers the task's four items: the
  two layouts as the same eight cells; the three proved facts weighed; the Open and Nomic
  operators as instances; cslib hosting (four routes); the recommendation; and the change list a
  separate family would require.
- `docs/development/README.md` — One index row in the "Project Organization" table.
- `records/proof-mode-architecture.md` — Modal family paragraph rewritten around the K core and
  `NecessityRules`; inclusion, rigidity and per-operator temporal interactions named; Families
  table row adjusted; open decision 1 removed and the list renumbered.
- `records/theorem-library.md` — Cell and operator set defined in "The lattice"; stratified laws
  and the grounds for the filing in "Two operators in the Modal family"; strengths in "Adding a
  family"; two conservativity rows restated as cell edges; tableau pipeline scoped to cells with
  operator set within `□`; "Transfer" row wording; open decision 1 removed.
- `records/proof-mode.md` — M19 fragment list qualified; M21 sequencing clause replaced by the
  settled filing; M23 names the report and its sequencing line no longer describes a starting
  position; open decision 2 removed and the lead-in corrected.
- `specs/state.json`, `specs/TODO.md` — Six `description` fields changed by exact sentence
  replacement through `state-write.sh --regen-todo`: `proof_mode_split_shared_test_and_guide_files`,
  `proof_mode_s5_aware_box_scopes`, `proof_mode_abstract_frontend_interface`,
  `theorem_library_layout_and_registry`, `theorem_library_stability_entries` (two replacements),
  `connective_signature_layer_shared_primitives`.

## Decisions

- Every declaration the report names was confirmed by `grep` in the file cited before being
  written down. The fourth `PlusNonValidities` refutation is `refute_somePast_stab`.
- The report's evidence tier is reading, not compilation, and says so. The K-and-necessitation
  claim for `◈` over arbitrary nomic frames is marked as an inference; the verdict does not use it.
- The records carry no "closed" or "resolved" note. The decision is removed from each open list
  and the body states the position with its grounds.
- `records/proof-mode.md` has no per-block convention for a milestone whose done-when is met, so
  none was added to M23.
- `records/milestones.md` and Goal 5 of `records/proof-mode.md` were left as found; neither hedges
  on the layout.

## Plan Deviations

- **Task 5.7** altered: `verify-touched.sh` exited 1 on nine agent-system self-test suites whose
  fixtures expect a source store inside the repository. The scoped tier was discharged by
  `verify-deploy.sh --only-gate 4 --skip-unchanged` (exit 0) and `validate-state.sh` (exit 0).
  Phase 5 is closed `[COMPLETED WITH EXCLUSIONS]` with the record in the plan.

## Verification

- Build: N/A (no Lean file changed; `git diff --stat` over `*.lean` is empty)
- Tests: `./scripts/readme-lint.sh docs` exit 0; `check-task-references.sh` exit 0 over
  `docs/development` and `records`; `check-record-versioning.sh` 0 BLOCKING over both (advisories
  are in files this task did not touch, plus line 4 of `records/theorem-library.md`, which
  predates it); `validate-state.sh` exit 0; `verify-deploy.sh --only-gate 4 --skip-unchanged`
  exit 0.
- `verify-touched.sh`: exit 1, nine failing suites, none reading a path this task changed. The
  complete gate set was not run in this dispatch; it is deferred to the batch stage.
- State write confirmed: fields other than `description` identical before and after; exactly six
  descriptions differ; 12 changed lines in `specs/state.json`.
- Files verified: Yes

## Impacts

- The interface task (`proof_mode_abstract_frontend_interface`) now has a stated target: a K core
  with T, 4 and 5 as separate members. `NecessityRules` carries only the K core today; extending
  it is that task's work.
- `theorem_library_layout_and_registry` should treat the operator set as a lattice coordinate
  (cells), and `theorem_library_tableau_pipeline` runs on cells with operator set within `□`.
- The dependency edge from `theorem_library_stability_entries` to this task was not changed; only
  its description text was.

## Follow-ups

- `verify-touched.sh` is red in this repository independently of any task's edits, because its
  selected and fallback suites include agent-system self-tests that need the source store. Any
  sibling dispatch in the batch will hit the same nine failures.
- The cslib section was read at commit `3bdf16d9f`; if a hosting route is pursued, re-read
  `Cslib/Foundations/Logic/ProofSystem.lean` at the then-current commit.

## References

- specs/970_investigate_stability_as_modal_family/plans/01_stability-modal-family-layout.md
- specs/970_investigate_stability_as_modal_family/reports/01_stability-modal-family-layout.md
- docs/development/stability-operator-family.md
