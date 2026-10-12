# Research Report: Task #771

**Task**: 771 - Task reference lint debt boneyard tests
**Started**: 2026-10-12T00:00:00Z
**Completed**: 2026-10-12T00:00:00Z
**Effort**: small (verification only; this report documents a near-zero-remaining-work finding)
**Dependencies**: Task 766 (completed)
**Sources/Inputs**:
- `.claude/scripts/check-task-references.sh` (run repo-wide and path-scoped)
- `.claude/scripts/lib/task-reference-patterns.sh` (shared pattern/exemption library)
- `.claude/context/standards/task-reference-exemptions.md` (exemption taxonomy)
- `specs/state.json` (task 764/766/771 status, dependencies, file_scope)
- `specs/TODO.md` (task 764/771 description text)
- `specs/766_clear_task_reference_citation_debt/summaries/01_clear-task-citation-debt-summary.md`
- `specs/766_clear_task_reference_citation_debt/plans/01_clear-task-citation-debt.md`
- `git log` (commit history for tasks 766, 764->771->766 dependency-edge commit)
**Artifacts**:
- `specs/771_task_reference_lint_debt_boneyard_tests/reports/01_lint-debt-already-cleared.md` (this report)
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **The acceptance criterion this task names is already satisfied.** `check-task-references.sh
  --quiet` exits 0 repo-wide, right now, on this working tree — re-verified independently in
  this research pass, not merely asserted from a prior artifact.
- **The work was done by dependency task 766**, which completed before this research dispatch
  began (`specs/state.json`: `project_number: 766, status: "completed"`). Task 766's summary
  records that it resolved all 198 of the citations this task's description names, across the
  same 53 files under `Boneyard/**` and `Tests/BimodalTest/**` this task's own `file_scope`
  names.
- **766 chose the "clean" disposition exclusively, not the "exempt" disposition** this task's
  description lists as preferred for archival citations: every occurrence was rewritten to a
  durable anchor (filename, section heading, named theorem/refactor) rather than wrapped in a
  `task-ref-ok` marker. 766's own marker-delta audit confirms zero markers were added.
- **No further cleaning, exemption-taxonomy edits, or script changes are required** to make
  `check-task-references.sh --quiet` exit 0 and serve as a gate again — that outcome already
  holds.
- **Recommendation**: treat the remaining plan/implement phases for this task as
  verification-only (re-run the three checks below, confirm no regression, close). There is no
  code change this task needs to make on top of what 766 already did.

## Context & Scope

This task (771) was split out of a broader meta record (task 764, "Specs only gate and task
reference lint debt") specifically to carry the task-reference-lint-debt half of that record's
two findings. A prior orchestration round recorded a second, narrower split — task 766 — and
added a serializing dependency chain `766 -> 771 -> 764` (commit `fe6021a30`) because the three
tasks share file territory (`Boneyard/`, `Tests/BimodalTest/`, and the lint script itself). 766
was dispatched and completed first; this research dispatch for 771 is the first dispatch against
771 since 766 closed.

The scope of this research was: re-derive the current state of the lint gate from first
principles (not from 766's or 771's own prose) and determine what, if anything, remains for 771
to do.

**Task 771's `file_scope`** (`specs/state.json`): `Boneyard/`, `Tests/BimodalTest/`,
`scripts/check-task-references.sh` — the same tree 766 touched.

## Findings

### The lint gate currently passes, repo-wide and scoped

Re-run in this research session (not carried from any prior artifact):

```
$ bash .claude/scripts/check-task-references.sh --quiet
  repo (excluding specs/): 0 occurrence(s)
PASS: 0 unexempted task-reference occurrences
$ echo $?
0
```

```
$ bash .claude/scripts/check-task-references.sh --quiet Boneyard
  Boneyard: 0 occurrence(s)
PASS: 0 unexempted task-reference occurrences
$ echo $?
0
```

```
$ bash .claude/scripts/check-task-references.sh --quiet Tests/BimodalTest
  Tests/BimodalTest: 0 occurrence(s)
PASS: 0 unexempted task-reference occurrences
$ echo $?
0
```

A direct re-scan of 771's own `file_scope` directories, sourcing the shared library and matching
its exact patterns (`TASK_PATTERN`/`PHASE_PATTERN` after `strip_exempt_regions`), independently
confirms zero matches under `Boneyard/` and `Tests/BimodalTest/` — this is not solely reliance
on the wrapper script's own exit code.

### The 198-citation debt was task 766's, and it is closed

The "198 pre-existing unexempted task-number citations... 109 of them [in Tests/BimodalTest]"
figure in this task's own description is a carried figure, sourced from the task description and
from task 766's completed summary — not independently re-derivable now because the debt no
longer exists to re-count. 766's summary (`specs/766_clear_task_reference_citation_debt/
summaries/01_clear-task-citation-debt-summary.md`) states: "All 198 occurrences across 53 files
(`Boneyard/**` tombstone READMEs and retired `.lean` module comments, `Tests/BimodalTest/**` and
`Tests/BimodalToolsTest/` property-suite and quarantine comments, and one illustrative-string
occurrence in `scripts/check-module-invariants.sh`) were resolved via durable-anchor rewrites."
That artifact also records: `lake build` (BimodalLogic, BimodalTest, BimodalToolsTest) all
succeeded after the rewrites, and `check-task-references.sh` was confirmed exiting 0 at 766's own
close. This research pass's independent re-run above corroborates that the gate still exits 0
now, after whatever else has landed on `main` since 766 closed.

### 766's disposition choice: clean, not exempt — and why that still satisfies 771

This task's description states a preference order: "Exempt them under the task-reference-
exemptions taxonomy (preferred where the citations are archival) or clean them". Task 766, read
on its own terms, did not follow that preference — it chose cleaning exclusively and explicitly
confirmed zero `task-ref-ok` markers were added anywhere (`git diff main -- . | grep -c
'task-ref-ok'` returned 0, per 766's Decisions section). This is a real deviation from 771's
stated preference, but it does not leave 771's goal unmet: the description's actual acceptance
test is "`check-task-references.sh --quiet` exits 0 and can serve as a gate again," not "the
exemption taxonomy was extended." Cleaning satisfies that test as fully as exemption would have,
and arguably more durably — a future reviewer skimming the rewritten `Boneyard/**` READMEs or
`Tests/BimodalTest/**` quarantine comments sees content with no task-identifier dependency at
all, rather than content that is correct only because a marker suppresses the lint over it.

### No open taxonomy gap blocks future archival content

Task 764's description (the parent record) separately asked whether the exemption taxonomy
should be extended to cover `Boneyard/**` as a legitimately-exempt path class, "argue it, do not
assume it." Nothing in this research found a reason that argument is still live for 771
specifically: the write-time guard hook (`hooks/validate-no-task-references.sh`, same shared
library) already blocks a *new* task-number citation landing in `Boneyard/**` or anywhere else
outside `specs/**` going forward, regardless of whether a path-level exemption category for
`Boneyard/**` is ever added to the taxonomy. A taxonomy extension would be a convenience for
future archival authors (letting them write "Task N" literally inside a new tombstone README
without triggering the hook), not a requirement for 771's stated goal. This question properly
belongs to 764, which already names it explicitly and is not blocked by anything this research
found in 771's scope.

## Decisions

- This research pass treats 771's acceptance criterion as **already met** by task 766's
  completed work, confirmed by an independent re-run of the lint (repo-wide and scoped to both
  of 771's `file_scope` directories) in this session, not by trusting 766's or 771's own prose
  alone.
- The "exempt vs. clean" disposition question 771's description poses is treated as **answered
  by precedent**: 766 already chose and fully executed "clean" for every one of the 198
  occurrences in 771's scope, and that choice satisfies 771's actual exit-code acceptance test.
  This research does not recommend reopening that choice (e.g., retroactively converting any of
  766's rewrites to `task-ref-ok` markers) absent a concrete reason to prefer exemption over an
  already-landed, build-verified rewrite.
- The taxonomy-extension question (should `Boneyard/**` become a named exempt path class) is
  **out of scope for 771** and is already correctly homed at task 764, which names it explicitly
  as part of the parent record's second finding.

## Recommendations

1. **Plan phase for 771 should be verification-only.** The plan should name the three
   verification commands above (repo-wide, `Boneyard` scope, `Tests/BimodalTest` scope) as its
   acceptance check, with no file edits implied by 771's own description beyond what 766 already
   made. Do not re-derive or duplicate 766's file-by-file rewrite work. If the orchestrator or a
   human reviewer prefers a lighter-weight path, consider whether 771 can close directly from
   this research finding without a separate plan/implement pair, since there is no remaining
   code change — this is a judgment call for the orchestrating process, not one this research
   report resolves unilaterally.
2. **Do not touch `Boneyard/**` or `Tests/BimodalTest/**` content again for this task.** 766's
   rewrites are the record of how the disposition was made; re-editing those files under 771
   would create unrelated diff noise against a build-verified, already-closed change.
3. **Leave the exemption-taxonomy extension question to task 764.** If a future dispatch on 764
   decides to add a `Boneyard/**` path-level exemption category, that is 764's decision to make
   and record in `.claude/context/standards/task-reference-exemptions.md`; 771 should not
   preempt it.
4. **At 771's close, record in its summary that the fix was supplied by task 766**, so a future
   reader of 771's artifacts is not misled into thinking 771 performed its own cleanup pass.

## Risks & Mitigations

- **Risk**: a planner or implementer unaware of 766's completion re-does the same 53-file
  rewrite pass under 771, producing duplicate or conflicting edits against already-closed,
  build-verified content.
  **Mitigation**: this report states explicitly, with fresh verification evidence, that no
  further edits are needed; the plan phase should cite this report rather than re-deriving the
  file list from the task description's `198`/`109` figures (which are now historical, not
  current).
- **Risk**: between this research pass and a later plan/implement dispatch, a new task-number
  citation could land in `Boneyard/**` or `Tests/BimodalTest/**` (e.g., from an unrelated task
  touching those trees) and flip the gate back to non-zero.
  **Mitigation**: the write-time guard hook (`validate-no-task-references.sh`) already blocks
  new citations outside `specs/**` at write time, independent of this task; the recommended
  verification-only plan phase should simply re-run the gate immediately before closing 771 to
  catch any such regression rather than assuming this report's snapshot still holds.

## Context Extension Recommendations

- None specific to 771. The taxonomy-extension question already has a home (task 764) and does
  not need a separate context-documentation gap recorded here.

## Appendix

- Commands run: `bash .claude/scripts/check-task-references.sh --quiet`; `bash
  .claude/scripts/check-task-references.sh --quiet Boneyard`; `bash
  .claude/scripts/check-task-references.sh --quiet Tests/BimodalTest`; a direct re-implementation
  of the scan (sourcing `task-reference-patterns.sh` and grepping `git ls-files` output per-file)
  as a cross-check against the wrapper script's own exit code.
- `specs/state.json` queried for `project_number` 764, 766, 771 (`status`, `dependencies`,
  `file_scope`).
- `git log --oneline` reviewed for the `766`-prefixed commit sequence and the
  dependency-edge commit `fe6021a30` ("766 -> 771 -> 764").
