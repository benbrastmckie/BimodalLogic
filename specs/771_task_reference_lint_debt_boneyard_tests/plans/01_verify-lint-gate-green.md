# Implementation Plan: Task #771

- **Task**: 771 - Task reference lint debt boneyard tests
- **Status**: [IMPLEMENTING]
- **Effort**: 0.5 hours
- **Dependencies**: 766 (completed)
- **Research Inputs**: specs/771_task_reference_lint_debt_boneyard_tests/reports/01_lint-debt-already-cleared.md
- **Artifacts**: plans/01_verify-lint-gate-green.md (this file)
- **Standards**:
  - .claude/context/formats/plan-format.md
  - .claude/context/standards/status-markers.md
  - .claude/context/standards/artifact-management.md
  - .claude/context/standards/tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

This task's acceptance criterion -- `check-task-references.sh --quiet` exits 0 repo-wide so the
lint can serve as a phase gate again -- is already satisfied on the current working tree. The
citation debt this task was created to clear was cleared in full by its dependency task 766,
which rewrote every occurrence to a durable anchor rather than exempting it. The only work left
is to confirm that outcome still holds (nothing has regressed since 766 closed), run the
repository's full gate set once, and record in this task's summary that the fix came from 766 so
a future reader is not misled into thinking a second cleanup pass happened here. Definition of
done: the three lint invocations below exit 0, `verify-deploy.sh` is green, and the summary
attributes the fix correctly.

### Research Integration

The research report (`reports/01_lint-debt-already-cleared.md`) establishes four findings this
plan is built on, and this plan adds a fifth from its own authoring-time re-derivation:

1. `check-task-references.sh --quiet` exits 0 repo-wide, independently re-verified in the
   research pass rather than carried from a prior artifact.
2. The 198-occurrence debt across 53 files under `Boneyard/**` and `Tests/BimodalTest/**` was
   resolved by dependency task 766, which completed before the research dispatch began.
3. 766 chose the "clean" disposition exclusively (durable-anchor rewrites, zero `task-ref-ok`
   markers added), not the "exempt" disposition this task's description listed as preferred for
   archival citations. The report argues -- and this plan accepts -- that cleaning satisfies the
   description's actual exit-code acceptance test as fully as exemption would have, and more
   durably, so the disposition choice is not reopened here.
4. The taxonomy-extension question (should `Boneyard/**` become a named exempt path class) is
   out of scope here and already homed at task 764.
5. **Re-derived at plan-authoring time** (2026-10-12), not carried: all three lint invocations
   below exit 0 with `0 occurrence(s)` reported for each scope. The `198`/`109` figures in this
   task's description are historical and no longer re-derivable, since the occurrences they
   counted no longer exist.

The report's primary recommendation -- that the plan phase be verification-only, citing the
report rather than re-deriving a file list from the description's historical counts -- is adopted
directly as this plan's single phase.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No roadmap context was supplied to this dispatch.

## Goals & Non-Goals

**Goals**:
- Confirm `check-task-references.sh --quiet` exits 0 repo-wide and under both directories named
  in this task's `file_scope`, immediately before closing, so a regression landing between the
  research pass and close is caught rather than assumed away.
- Run the repository's full gate set once to confirm nothing else in the tree is red.
- Record in this task's summary that the citation-debt fix was supplied by task 766, with the
  disposition actually chosen (clean, not exempt) stated explicitly.

**Non-Goals**:
- Any edit to `Boneyard/**`, `Tests/BimodalTest/**`, or `scripts/check-task-references.sh`.
  766's rewrites are build-verified and closed; re-editing them here would produce pure diff
  noise against an already-landed change.
- Retroactively converting any of 766's durable-anchor rewrites into `task-ref-ok` markers to
  match this task's originally stated "exempt preferred" ordering.
- Extending `.claude/context/standards/task-reference-exemptions.md` with a `Boneyard/**` path
  class. That decision belongs to task 764, which names it explicitly.
- Any change to the write-time guard hook or the shared pattern library.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| A new task-number citation lands outside `specs/**` between plan authoring and implementation, flipping the gate non-zero | M | L | The phase re-runs all three lint invocations at implementation time rather than trusting this plan's snapshot; the write-time guard hook (`hooks/validate-no-task-references.sh`) already blocks new citations at write time |
| An implementer reads the description's `198`/`109` figures as current and re-does 766's 53-file rewrite pass | H | L | Both this plan's Non-Goals and its single phase state that no file edits are in scope; the figures are labelled historical in Research Integration above |
| The gate is green but `verify-deploy.sh` is red for an unrelated reason, making it unclear whether this task may close | M | L | The phase separates the two checks: a red gate unrelated to task-reference lint is reported as a finding (and recorded in `issues.jsonl`) rather than silently repaired under this task's scope |
| This task closes with a summary implying it performed its own cleanup | L | M | Attribution to 766 is an explicit, checklisted task in the single phase, not an afterthought |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |

Phases within the same wave can execute in parallel. This plan has one phase, which is
therefore also its final phase.

### Phase 1: Verify Lint Gate Green and Attribute the Fix [COMPLETED]

**Goal**: Confirm, on the tree as it stands at implementation time, that the task-reference lint
exits 0 repo-wide and under both `file_scope` directories; confirm the repository's full gate set
is green; and record correct attribution of the citation-debt fix to task 766.

**Tasks**:
- [x] Re-run `bash .claude/scripts/check-task-references.sh --quiet` and capture its exit code.
      *(completed: rc=0, 0 occurrence(s))*
- [x] Re-run `bash .claude/scripts/check-task-references.sh --quiet Boneyard` and capture its
      exit code. *(completed: rc=0, 0 occurrence(s))*
- [x] Re-run `bash .claude/scripts/check-task-references.sh --quiet Tests/BimodalTest` and
      capture its exit code. *(completed: rc=0, 0 occurrence(s))*
- [x] If any of the three is non-zero, enumerate the offending occurrences and stop: report them
      as a finding rather than editing `Boneyard/**` or `Tests/BimodalTest/**` under this task.
      Record the regression via `issue-record.sh` and surface it in the summary; a regression
      from an unrelated tree is not this task's cleanup to absorb silently.
      *(completed: not applicable -- all three invocations exited 0)*
- [x] Run `bash .claude/scripts/verify-deploy.sh` and confirm the complete gate set is green.
      *(completed: PASS -- 14 check(s), 0 failure(s))*
- [x] Write the task summary, stating explicitly that the 198-occurrence citation debt was
      cleared by task 766 via durable-anchor rewrites (zero `task-ref-ok` markers added), that
      this task performed verification only and made no file edits, and that the
      `Boneyard/**`-exemption-taxonomy question remains with task 764. *(completed)*

**Timing**: 0.5 hours (dominated by the `verify-deploy.sh` run, not by the lint invocations).

**Depends on**: none

**Verification Tier**: full

**Scope Hypothesis**: The hypothesis is that all three lint invocations exit 0 with
`0 occurrence(s)` and that zero file edits are required -- re-derived at plan-authoring time on
2026-10-12 (not carried), and corroborated by `reports/01_lint-debt-already-cleared.md`, which is
also the source of the now-historical `198`-occurrence / `53`-file / `109`-in-`Tests/BimodalTest`
figures originating in this task's description. Confirm at implementation time by re-running the
three commands in the Verification list below; those exit codes, not this plan's snapshot, are
authoritative.

**Files to modify**:
- None planned. This phase is verification-only: no file under `Boneyard/**`,
  `Tests/BimodalTest/**`, or `.claude/scripts/check-task-references.sh` is edited. The task
  summary artifact is written at postflight, outside this phase's edit scope.

**Verification**:
- `bash .claude/scripts/check-task-references.sh --quiet` exits 0.
- `bash .claude/scripts/check-task-references.sh --quiet Boneyard` exits 0.
- `bash .claude/scripts/check-task-references.sh --quiet Tests/BimodalTest` exits 0.
- `bash .claude/scripts/verify-deploy.sh` -- the complete gate set this script aggregates -- runs
  and is green.
- The summary names task 766 as the source of the fix and names "clean / durable-anchor rewrite"
  as the disposition actually used.

---

## Testing & Validation

- [ ] Repo-wide task-reference lint exits 0 (`check-task-references.sh --quiet`).
- [ ] Path-scoped lint exits 0 for `Boneyard` and for `Tests/BimodalTest`.
- [ ] `verify-deploy.sh` full gate set green.
- [ ] No tracked file under `Boneyard/**`, `Tests/BimodalTest/**`, or
      `.claude/scripts/check-task-references.sh` appears in this task's diff
      (`git status --short` clean for those paths).
- [ ] Summary attributes the fix to task 766 and records the clean-not-exempt disposition.

## Artifacts & Outputs

- `specs/771_task_reference_lint_debt_boneyard_tests/plans/01_verify-lint-gate-green.md` (this
  file).
- `specs/771_task_reference_lint_debt_boneyard_tests/summaries/01_verify-lint-gate-green-summary.md`
  (written at implementation close; must carry the task-766 attribution).
- Captured exit codes / output of the three lint invocations and of `verify-deploy.sh`, quoted in
  the summary as the evidence of record.
- No source-tree changes.

## Rollback/Contingency

This plan makes no file edits, so there is nothing to revert: the contingency is a reporting
decision, not a git operation.

- If a lint invocation is non-zero at implementation time, do **not** clean or exempt the new
  occurrences under this task. Enumerate them, record the regression in `issues.jsonl`, and
  return `partial` or `blocked` with the offending paths named, so the regression is routed to
  whichever task introduced it rather than absorbed here.
- If `verify-deploy.sh` is red for a reason unrelated to task-reference lint, report it as a
  finding and return `partial`; repairing an unrelated gate failure is outside this task's
  `file_scope`.
