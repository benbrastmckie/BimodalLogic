# Implementation Summary: Task #993

- **Task**: 993 - Declare integration_branch in .claude-extensions.json so that orchestration admission arms instead of falling back
- **Status**: [COMPLETED]
- **Started**: 2026-11-25T00:00:00Z
- **Completed**: 2026-11-25T17:52:00Z
- **Effort**: 1.25 hours
- **Dependencies**: None
- **Artifacts**: plans/01_declare-integration-branch-admission-gate.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Declared `integration_branch` (`"dev/m7-ladder-continuation"`) and `worktree_isolation`
(`"off"`) as top-level sibling keys in the project-root `.claude-extensions.json`, arming
`/orchestrate`'s branch-and-tree admission gate in this repository. The arming was proven by a
two-arm live falsification against the real admission predicate — a deliberately wrong declared
branch (`main`) produced a genuine `off_integration_branch` refusal, and the correct declaration
produced an armed, non-advisory result — rather than by the disarmed-gate advisory merely ceasing
to print. The maintenance obligations the declaration creates were then recorded in a tracked
file, since the manifest itself is gitignored.

## What Changed

- `.claude-extensions.json` — added `integration_branch: "dev/m7-ladder-continuation"` and
  `worktree_isolation: "off"` as top-level sibling keys beside the pre-existing `extensions` and
  `version` keys. **This file is gitignored in this repository and is not carried by any commit**
  — the declaration exists only in this working copy. A fresh clone starts with no declaration
  and must re-declare both keys before admission tests anything.
- `docs/project-info/MAINTENANCE.md` — added a `## Orchestration Branch Declaration` section
  (immediately after `## Commit Message Standards`) recording the re-declaration-on-fresh-clone
  obligation and the declaration-must-move-with-any-branch-rename obligation, since neither
  obligation could otherwise be discovered from the gitignored manifest itself.

## Decisions

- **Declared value `dev/m7-ladder-continuation`, not `main`.** The admission consumer
  (`batch-admission-lib.sh`) tests pure branch-identity equality via
  `git symbolic-ref -q --short HEAD`, with no ancestry or merge-target relation — the declared
  value names the branch the primary tree is required to sit on, not an eventual integration
  target. `main` trails behind via periodic merges and was confirmed, via the refusal arm, to
  refuse essentially every ordinary invocation if declared.
- **`worktree_isolation: "off"`, declared explicitly.** Behaviourally identical to leaving the
  key absent; declaring it records that the key was evaluated rather than overlooked. `"batch"`
  was rejected — it is declared-but-unimplemented and refuses every invocation.
- **Refuse, not warn — accepted, not selected.** The implementation offers no soft mode: once
  `integration_branch` is declared, a mismatch always hard-refuses. This was accepted on its own
  merits (the architecture already claims the primary tree never switches off the integration
  branch during dispatch work; the gate enforces an invariant already claimed, rather than
  letting it drift silently undetected), not chosen between implemented alternatives.
- **Maintenance obligations recorded in `docs/project-info/MAINTENANCE.md`, not beside the
  manifest or in the agent-system's own docs.** Both the manifest and the project-root
  `CLAUDE.md` are gitignored and would not survive a fresh clone; `MAINTENANCE.md` is tracked and
  already holds this repository's workflow standards. The agent-system's own
  `repo-level-declarations.md` was rejected as a target since it is a deployed `.claude/**`
  artifact whose source store resolves to a different repository.

## Plan Deviations

- Phase 1's verification bullet "`verify-touched.sh .claude-extensions.json` exits 0" did not
  hold literally on exit status: the scoped run reported 28 passed, 9 failed (1 EXPECTED per the
  harness's own label, 8 NEW), 2 skipped of 39 suites. The one suite directly subject to this
  task's edit, `test-batch-admission-lib.sh`, PASSED. All 8 NEW failures trace to a single
  pre-existing, unrelated root cause: this repository's `core` extension `source_dir` resolves to
  an external source store (`~/.config/nvim/agent-system/extensions/core`), so no local
  `agent-system/extensions/core` tree exists under the project root, and several suites hardcode
  that project-root-relative path. None reference `integration_branch`, `worktree_isolation`, or
  `batch-admission-lib.sh`. Recorded via `issue-record.sh`; phase closed `[COMPLETED]` on this
  evidence.
- Phase 2's scoped `verify-touched.sh docs/project-info/MAINTENANCE.md` run reported one NEW
  failure (`test-deploy-baseline-lib.sh`), an unrelated warm-cache gate-skip timing assertion,
  recorded via `issue-record.sh`; phase closed `[COMPLETED]` on this evidence.

## Verification

- Build: N/A (meta task, no Lean build affected)
- Tests: Partial pass — the two suites directly subject to this task's edits
  (`test-batch-admission-lib.sh`, and the admission probe falsification itself) passed; two
  unrelated, pre-existing environmental failures were observed in the scoped batteries and
  recorded as issues rather than fixed (out of this task's scope — see Plan Deviations). Per
  this dispatch's Batch Gate Deferral directive, the complete gate set is deferred to the
  orchestration batch close, not independently run here.
- Files verified: Yes — `jq -e '.integration_branch == "dev/m7-ladder-continuation" and
  .worktree_isolation == "off" and has("extensions") and has("version")' .claude-extensions.json`
  exits 0; `grep -n '^## Orchestration Branch Declaration' docs/project-info/MAINTENANCE.md`
  returns exactly one hit; `bash scripts/readme-lint.sh docs` exits 0.
- Falsification evidence: refusal-arm probe (declared `integration_branch: "main"`) produced a
  real `off_integration_branch` stop naming both the checked-out branch
  (`dev/m7-ladder-continuation`) and the declared one (`main`), with `.dispatch == []`. Admit-arm
  probe (declared `integration_branch: "dev/m7-ladder-continuation"`) produced no
  `off_integration_branch` stop and no disarmed-gate advisory; it returned `dirty_primary_tree`
  (naming paths inside a concurrent sibling task's own declared file scope), which is reachable
  only once the branch test itself passes — accepted per the plan's own contingency item as
  positive evidence the branch arm armed.

## Impacts

- Every `/orchestrate` invocation in this working copy now has its branch-and-tree admission gate
  armed: a checked-out branch other than `dev/m7-ladder-continuation`, or an uncommitted dirty
  tree outside the state territory, now refuses admission with a named reason instead of silently
  falling back to an untested, disarmed state.
- The gate's refuse-on-mismatch behaviour means any future rename of the long-lived working
  branch must update `integration_branch` in the same action, or every subsequent invocation
  refuses with `off_integration_branch` — now documented in `docs/project-info/MAINTENANCE.md`.

## Follow-ups

- The declaration in `.claude-extensions.json` is uncommittable (gitignored) and will not survive
  a fresh clone; `docs/project-info/MAINTENANCE.md`'s new section documents the re-declaration
  obligation but nothing mechanically enforces it today.
- Two unrelated, pre-existing test failures were observed and recorded as issues
  (`verification-environment` class, `minor` severity) rather than fixed: (1) several suites
  hardcode a project-root-relative `agent-system/extensions/core` path that does not exist in
  this deploy (this repository's `core` extension resolves its `source_dir` to an external store
  instead); (2) `test-deploy-baseline-lib.sh` has a flaky warm-cache gate-skip timing assertion.
  Both are out of this task's scope.

## References

- Plan: `specs/993_declare_integration_branch_admission_gate/plans/01_declare-integration-branch-admission-gate.md`
- Report: `specs/993_declare_integration_branch_admission_gate/reports/01_declare-integration-branch-admission-gate.md`
- Progress: `specs/993_declare_integration_branch_admission_gate/progress/phase-1-progress.json`, `specs/993_declare_integration_branch_admission_gate/progress/phase-2-progress.json`
- Handoffs: `specs/993_declare_integration_branch_admission_gate/handoffs/phase-1-handoff-20261125T174656Z.md`, `specs/993_declare_integration_branch_admission_gate/handoffs/phase-2-handoff-20261125T175200Z.md`
- `context/standards/repo-level-declarations.md` (consumer semantics reference)
- `.claude/scripts/lib/batch-admission-lib.sh` (admission predicate)
