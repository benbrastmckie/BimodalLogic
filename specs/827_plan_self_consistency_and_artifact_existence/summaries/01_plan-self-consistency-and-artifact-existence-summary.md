# Implementation Summary: Task #827

- **Task**: 827 - Require a plan phase to agree with its own Scope Hypothesis and to name only artifacts that exist
- **Status**: [COMPLETED]
- **Started**: 2026-11-07T20:20:00Z
- **Completed**: 2026-11-07T21:28:00Z
- **Effort**: ~1.1 hours
- **Dependencies**: 769, 772, 774 (task-level; none blocked this record's own edit territory)
- **Artifacts**: plans/01_plan-self-consistency-and-artifact-existence.md
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Two plan-authoring truthfulness provisions were landed as prose in the core extension's
`context/formats/plan-format.md`, each sited beside the section that already owns its
vocabulary, plus two short generation-time pointer items in `agents/planner-agent.md`'s Stage 4
checklist so the author meets both provisions while writing a phase, not only at review time.
`index-entries.json`'s `line_count` for `plan-format.md` was reconciled to the landed figure, and
the three edited files were confirmed clean of task-number references, record-versioning
language, and absence-asserting phrasing. The source-store repository redeployed to
`RESULT=landed_verify_clean` and the full gate set passed with 0 failures.

## What Changed

- `/home/benjamin/.config/nvim/agent-system/extensions/core/context/formats/plan-format.md` —
  added the "Scope-Hypothesis / task-list self-consistency obligation" subsection (between
  "Counts-are-hypotheses obligation" and "Cross-phase ceiling consistency obligation"), stating
  the authoring obligation (condition a) and the implementer's rule (condition b) as two
  separately labelled paragraphs, plus the non-transfer paragraph pointing at the lean
  extension's `rules/plan-compliance.md` "Statement Fidelity" section; added one sentence to
  "Reasoned Exclusions (format)"'s "Relationship to Scope Hypothesis" paragraph pointing forward
  to the new subsection; added the "Correction-target existence obligation." paragraph after the
  `Files to modify` field's "Consumers of this field" subsection, stating rule (a) (confirm
  existence at authoring time) and rule (b) (the dispatch-created-sidecar prohibition, naming
  `specs/state.json`'s task description and a task's `records/` directory as the sanctioned
  carriers) as separately labelled paragraphs, plus the moving-quantity sentence. File grew from
  1020 to 1083 lines.
- `/home/benjamin/.config/nvim/agent-system/extensions/core/agents/planner-agent.md` — appended
  two numbered checklist items (10, 11) to the Stage 4 phase-authoring checklist, mirroring item
  9's shape (statement, `MUST NOT` bullet, pointer by section name), with no renumbering of
  existing items.
- `/home/benjamin/.config/nvim/agent-system/extensions/core/index-entries.json` — reconciled the
  `formats/plan-format.md` entry's `line_count` from 1020 to 1083.
- `specs/827_plan_self_consistency_and_artifact_existence/plans/01_plan-self-consistency-and-artifact-existence.md`
  — all four phases checked off and marked `[COMPLETED]`.

## Decisions

- The mechanical-check question (whether a lint can soundly discriminate a correction-target
  path, which must exist, from a creation-target path, which must not, in `Files to modify`) is
  DECIDED: no sound discrimination is buildable, and nothing was built. Reasons: (1) the
  `Files to modify` grammar carries no structured intent signal beyond an optional free-text
  annotation, and the live plan corpus shows no consistent vocabulary a keyword lint could key
  on without high false-positive/false-negative rates in both directions; (2)
  `plan-file-scope-harvest.sh`'s own design already correctly treats a not-yet-existing path as
  a legitimate creation target — a check that flagged every such path would fire on every
  legitimately new file in every plan and would be worse than no check at all; (3) adding a new
  plan-format field to make a check possible is a larger format change and was explicitly out of
  scope. This decision carries no built artifact; the prose provisions alone are the complete
  deliverable for item 2's mechanical-check question.
- The `.blocker-research.json` filename shape was deliberately NOT cited in the landed prose,
  even though the dispatch permitted citing it conditionally — describing the sidecar class
  without any filename avoided any risk of a sentence reading as an assertion about that file's
  current presence or absence.
- No commit was made in the source-store repository (`/home/benjamin/.config/nvim`) for the
  three landed edits. That repository is a separate, concurrently-active git repository with its
  own unrelated dirty/untracked state from other sessions; the dispatch names no git-commit
  requirement for the source store, and a "task 827: ..." commit message there would misattribute
  provenance since task 827 is not a task in that repository's own numbering. The edits are left
  as uncommitted working-tree changes there, which `deploy-headless.sh` reads directly.

## Plan Deviations

- None (implementation followed the plan). All four phases' Scope Hypothesis predictions held
  without correction; every task-list item was completed as written.

## Verification

- Build: N/A (no code/script changes)
- Tests: Phases 1-2's selected suite run (`test-lean-challenge-snapshot.sh`,
  `test-phase-heading-patterns.sh`, `test-plan-file-scope-harvest.sh`,
  `test-resume-scan-nonconformance.sh`) — 3 of 4 passed; `test-resume-scan-nonconformance.sh`
  fails in this repo for a reason unrelated to this record's edits (it requires a local
  `agent-system/extensions/` checkout under the BimodalLogic repo root, which this repo does not
  have — the source store lives only at `/home/benjamin/.config/nvim/agent-system/`). Recorded as
  a `minor` issue via `issue-record.sh`. Phase 3's selected suite (`test-plan-file-scope-harvest.sh`)
  passed clean. Phase 4's full gate (`verify-deploy.sh`) passed: 15 checks, 0 failures.
- Files verified: Yes — diff read-through confirmed every hunk is pure prose with no executable
  surface; hygiene greps for task-number references, record-versioning language, and
  absence-asserting phrasing all returned clean across the three edited files.
- Deploy: `deploy-headless.sh` reported `RESULT=landed_verify_clean`.

## Impacts

- A plan author writing a Scope Hypothesis that excludes something now has an explicit,
  pointed-to obligation to check that exclusion against the same phase's task list before
  writing the phase, and an implementer who finds the contradiction anyway has a stated rule
  (preserve the task list, record the deviation, propagate the consequence) rather than an
  undocumented judgment call.
- A plan author naming an existing artifact as a correction/amendment/retirement target now has
  an explicit obligation to confirm it exists at authoring time, with a stronger named
  prohibition against making a phase's goal turn on a dispatch-created orchestration sidecar —
  closing exactly the two authoring-defect classes the originating run encountered, for future
  plans in any task space that reads this format.
- No script, hook, lint, or plan-format field was added; `plan-file-scope-harvest.sh`,
  `validate-artifact.sh`, and `verify-deploy.sh` are unchanged.

## Follow-ups

- None. The mechanical-check question was investigated and decided (no check built); no new
  plan-format field was added; the originating plan was not re-edited.

## References

- Plan: `specs/827_plan_self_consistency_and_artifact_existence/plans/01_plan-self-consistency-and-artifact-existence.md`
- Research: `specs/827_plan_self_consistency_and_artifact_existence/reports/01_plan-self-consistency-and-artifact-existence.md`
- Dispatch: `specs/827_plan_self_consistency_and_artifact_existence/.dispatch/16.md`
- Landed files (source store):
  `/home/benjamin/.config/nvim/agent-system/extensions/core/context/formats/plan-format.md`,
  `/home/benjamin/.config/nvim/agent-system/extensions/core/agents/planner-agent.md`,
  `/home/benjamin/.config/nvim/agent-system/extensions/core/index-entries.json`
