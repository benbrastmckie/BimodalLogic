# Implementation Plan: Task #755

- **Task**: 755 - Plan files to modify unenforced
- **Status**: [IMPLEMENTING]
- **Effort**: 5.75 hours
- **Dependencies**: None
- **Research Inputs**: specs/755_plan_files_to_modify_unenforced/reports/01_files-to-modify-unenforced.md
- **Artifacts**: plans/01_files-to-modify-enforcement.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

`plan-format.md` marks the per-phase `Files to modify` field REQUIRED, but
`scripts/validate-artifact.sh` has no check for it, so a plan that omits it everywhere validates
clean while `plan-file-scope-harvest.sh` correctly harvests `[]` and the task's `file_scope` stays
`null` — invisible to the orchestrator's admission overlap gate. This plan closes that gap with a
**two-tier** presence check inside the validator's existing per-phase loop (per-phase omission
warns; a plan where *no* phase declares the field errors), repairs the one live whole-plan
offender as the regression fixture, and documents the enforcement level and its promotion
criterion in `plan-format.md`. The harvester's `[]`-is-normal contract is deliberately left
untouched.

### Research Integration

The research report settles three of the dispatch's four SCOPE items and supplies the measurement
the fourth needed:

- **SCOPE 1 (where)**: the validator's plan-mode per-phase loop (the `**Verification Tier**` check)
  already computes `phase_line_nums`, `phase_num` and `phase_block` in a single pass. The new check
  is one more `grep` against `phase_block` in that same loop — no new library, no second file scan,
  and explicitly *not* a whole-document `grep -qF` (the `PLAN_METADATA` header comment already
  warns that whole-document existence under-enforces a per-phase field).
- **SCOPE 3 (harvester)**: decided NO. The harvester's `[]` return is documented as normal for both
  "no block anywhere" and "block present, zero paths", and a live legitimate instance of the second
  case exists (task #750's plan carries a `- none planned` prose sentinel that correctly contributes
  no path while the plan's other phases still populate a non-empty aggregate). Changing the return
  shape would ripple into seven callers and two test suites, and the dispatch's NON-GOALS bar
  touching the union-merge. The validator becomes the sole surface that distinguishes the two.
- **SCOPE 4 (backfill)**: `backfill-file-scope.sh` cannot repair #410 as written — its skip logic
  treats a harvester `[]` identically to "no plan at all", and #410's plan carries a narrative
  `## Territory Contract` table instead of per-phase blocks. The regression fixture is therefore
  *repair the plan, then re-harvest*, exactly as the dispatch words it.
- **SCOPE 2 (tier)**: the report argued against reflexively copying the `Verification Tier`
  advisory-first posture and asked for a population measurement. That measurement was taken at
  plan time (see Phase 3's **Scope Hypothesis**) and is what drives the two-tier design below:
  per-phase omission at error level would newly fail two unrelated active plans; whole-plan
  omission at error level newly fails only #410, which this task repairs.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was passed in the delegation context, so Stage 2.5's roadmap consultation was
not dispatched; `specs/ROADMAP.md` was nonetheless read read-only for alignment. Two items this
plan advances:

- Stage 1's framing note that "a task with no declared `file_scope` is invisible to the overlap
  gate" — this plan removes the mechanism by which a planned task can arrive in that state.
- Stage 4's standing instruction that 410, 411 and 412 "declare an empty or absent `file_scope` —
  scope them at plan time before running any wave concurrently". Phase 2 discharges that for 410.

ROADMAP.md is not modified by this plan.

## Goals & Non-Goals

**Goals**:
- A plan whose phases omit `Files to modify` can no longer validate silently: each omitting phase
  draws a warning, and a plan where *every* phase omits it draws an error.
- `--strict` escalates the per-phase warning, mirroring the `Verification Tier` precedent.
- The legitimate "header present, zero paths" sentinel case (live in task #750's plan) is never
  flagged.
- Task #410's `file_scope` is non-null, derived by re-running the real harvester against a repaired
  plan rather than by a hand-written `state.json` edit.
- `plan-format.md` carries an explicit `Enforcement level` note for this field, with the measured
  residue and a promotion criterion a future task can execute mechanically.

**Non-Goals**:
- No change to the frozen `Files to modify` heading text or its entry grammar.
- No change to `plan-file-scope-harvest.sh`'s return contract or to `update-task-status.sh`'s
  union-merge semantics.
- No retroactive `file_scope` backfill beyond #410; the two plans with a *partial* per-phase gap
  (tasks 282 and 428) are recorded in the promotion criterion, not repaired here.
- No promotion of the existing `Verification Tier` advisory to an error — its own promotion
  criterion is unmet and the validator's comment already bars doing it as a side effect.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| The whole-plan error fires on #410 before its plan is repaired, newly failing an unrelated task's validation | M | M | Phase 2 (repair) is in Wave 1 and Phase 3 (the check) depends on it; the error only becomes live in the deployed tree at Phase 5's redeploy, by which point the repair has landed |
| The deployed `.claude/` core tree is stale (`source_git_head` f86b736 vs agent-system HEAD db6aeae), so a Phase 5 gate failure could originate outside this task | M | M | Phase 1 redeploys and records a gate **baseline** before any edit, so every Phase 5 failure is classifiable as NEW or EXPECTED against that baseline |
| `test-validate-artifact.sh` resolves the script under test as `$REPO_ROOT/.claude/scripts/validate-artifact.sh` *before* its source-store sibling; run from the source store, `git rev-parse --show-toplevel` yields the nvim config repo and the test silently exercises that repo's deployed copy, not the edit | H | H | Phase 3 verifies by invoking the edited source-store validator **directly** on hand-built fixtures; the suite run happens only from the BimodalLogic deployed tree after Phase 5's redeploy |
| The existing `make_plan_fixture` emits a Phase 1 with no `Files to modify`, so the new check adds a warning (and, being the only phase, triggers the whole-plan error) to every current plan fixture | H | H | Phase 3 updates `make_plan_fixture` to carry the field, before adding the three new cases; the `[PASS]`-asserting cases at lines ~183/189 would otherwise flip to `[FAIL]` |
| A future generator renders the field in a shape neither the harvester nor the new check recognizes | L | L | The new check's grep is specified to mirror `plan-file-scope-harvest.sh`'s `strip_marker()` grammar verbatim (both punctuation forms, optional single leading list marker) rather than inventing a third grammar |
| Repairing #410's plan reads as rewriting implementation history | L | L | Sanctioned by the dispatch as the regression fixture; `specs/**` is the primary exemption zone in `no-record-versioning-in-deliverables.md` |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 1, 2 |
| 3 | 4 | 3 |
| 4 | 5 | 1, 2, 3, 4 |

Phases within the same wave can execute in parallel.

### Phase 1: Redeploy the stale core tree and record the gate baseline [COMPLETED]

**Goal**: the deployed `.claude/` tree in this repo matches the source store before any of this
task's edits land, and the pre-change state of the gate set is recorded so a later failure is
classifiable as NEW rather than attributed to this task.

**Tasks**:
- [x] Re-read `.claude-extensions.json`'s `extensions.core.source_git_head` and compare against
      `git -C /home/benjamin/.config/nvim/agent-system rev-parse HEAD`. Record both values.
      *(completed: f86b736c... vs db6aeae... — confirmed stale)*
- [x] Run `bash .claude/scripts/deploy-headless.sh` and record its `RESULT=` line.
      *(completed: RESULT=landed_verify_clean)*
- [x] Run `bash .claude/scripts/tests/run-all.sh` and record the pass/fail roster verbatim as the
      baseline. Any failure here is EXPECTED for the remainder of this task.
      *(completed: 116 passed, 15 failed (0 expected, 15 NEW), 0 skipped, 131 total — recorded in
      progress/phase-1-progress.json)*
- [x] Run `bash .claude/scripts/verify-deploy.sh` and record its findings as part of the same
      baseline. *(completed: PASS -- 14 check(s), 0 failure(s))*
- [x] Confirm `grep -c 'files to modify' .claude/scripts/validate-artifact.sh` is still `0` in the
      freshly deployed copy — i.e. the defect is live in the tree the rest of this task edits
      against, not an artifact of staleness. *(completed: returned 0)*

**Timing**: 0.5 hours

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: the deployed core tree is stale by the agent-system commit range
`f86b736..db6aeae`, and that range is hypothesized to introduce no gate failure in this repo.
Confirm by the baseline run itself — do not assume a green baseline; whatever the run reports IS
the baseline, and a non-empty EXPECTED set is a legitimate outcome of this phase rather than a
blocker.

**Tier Justification**: this phase hand-edits nothing — `deploy-headless.sh`'s own inline
`verify-deploy.sh` plus the recorded `run-all.sh` roster are the covering checks for the only thing
that changes (the regenerated `.claude/` tree), so no broader sweep adds information.

**Files to modify**:
- `.claude/` - regenerated wholesale by `deploy-headless.sh`; no file in this tree is hand-edited
  by this phase or any later one. **Edit target** for every `.claude/**` path named in later
  phases: the source store under
  `/home/benjamin/.config/nvim/agent-system/extensions/core/`, resolved via
  `.claude-extensions.json`'s `source_dir` per `.claude/rules/source-store-deploy-boundary.md`.

**Verification**:
- `deploy-headless.sh` reports `RESULT=landed_verify_clean` (or its reported result is recorded
  verbatim with the reason it differs).
- The `run-all.sh` and `verify-deploy.sh` baselines are written into the issue log or the phase's
  commit message so Phase 5 can diff against them.
- `grep -c 'files to modify' .claude/scripts/validate-artifact.sh` returns `0`.

---

### Phase 2: Repair task #410's plan and backfill its `file_scope` [COMPLETED]

**Goal**: #410's plan carries per-phase `Files to modify` blocks sourced from its own
`## Territory Contract` table, the real harvester returns a non-empty array for it, and that array
is written into `state.json#active_projects[].file_scope` — the regression fixture the whole-plan
error in Phase 3 depends on not firing against.

**Tasks**:
- [x] Read `specs/410_internalize_tableau_branches_and_prove_routine_rule_admissibility/plans/01_internalize-routine-admissibility.md`'s
      `## Territory Contract` table (lines ~189-209) and its eight `### Phase N:` blocks.
      *(completed)*
- [x] Add one `**Files to modify**:` block to each of the eight phases, placed directly after that
      phase's `- **Scope Hypothesis:**` line to match the field order in `plan-format.md`, using the
      plan's existing list-item field rendering (`- **Files to modify:**` with entries indented one
      level). Derive each phase's entries from the Territory Contract's "Exclusive to this task
      (new)" row plus `FormalSystem/Metalogic/Decidability.lean` on whichever phases append an
      import line. The full path prefix is
      `FormalSystem/Metalogic/Decidability/` (the table's `Verified/...` entries are relative to it);
      `Verified/Refutation/` does not exist on disk yet, which is correct — `file_scope` is
      prospective and the harvester never filesystem-validates a path. *(completed: 8 blocks added,
      one per top-level phase)*
- [x] Decide the conditional `Verified/Internalize/*.lean` overflow path explicitly. Recommended:
      include `FormalSystem/Metalogic/Decidability/Verified/Internalize/Mono.lean` on the
      monotonicity phase with its conditionality stated in the entry's free text, since a declared
      prospective path that goes unused costs nothing while an undeclared one that *is* used is
      exactly the overlap-gate blindness this task exists to remove. *(completed: added to Phase 3
      of 410's plan with conditionality stated in the entry's free text)*
- [x] Do NOT add a block to the `#### Phase N.M` sub-headings: the validator's loop and the
      harvester both treat a `####` sub-heading as part of its enclosing `### Phase N` block, so one
      block per top-level phase is the correct and sufficient shape. *(completed: honored — no
      block added to any sub-heading)*
- [x] Run `bash .claude/scripts/plan-file-scope-harvest.sh specs/410_.../plans/01_internalize-routine-admissibility.md`
      and confirm non-empty output. Expect the harvester's generated-surface appendix to fire
      (every harvested path is `.lean`), so the array is larger than the hand-written entry set —
      that is its documented behavior, not a defect. *(completed: 11-path array, including the
      4-file generated-surface appendix)*
- [x] Cross-check with `bash .claude/scripts/backfill-file-scope.sh --dry-run` and confirm its
      proposed array for 410 agrees with the direct harvester run. *(completed: byte-identical)*
- [x] Write the harvested array into `state.json` for project 410 **only**, as a union-append
      (`.file_scope = ((.file_scope // []) + $add | unique)` scoped to the matching
      `active_projects[]` entry), never a wholesale array assignment. Do not run
      `backfill-file-scope.sh` without `--dry-run`: it is repo-wide and would backfill tasks the
      dispatch's NON-GOALS exclude. Do not route the write through
      `update-task-status.sh --file-scope-add` either: that flag is restricted to
      `operation=postflight` with `target_status` in `{research, plan}`, which would re-transition
      #410 as a side effect. *(completed: via `state-write.sh` directly with the scoped jq filter)*
- [x] Run `bash .claude/scripts/validate-state.sh` and `bash .claude/scripts/generate-todo.sh`.
      *(completed: validate-state.sh passed with pre-existing, unrelated warnings only;
      generate-todo.sh ran clean)*

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: the repaired plan is hypothesized to harvest at least the six Territory
Contract paths (five "Exclusive to this task (new)" files plus the shared append-only
`Decidability.lean`), plus the harvester's `.lean`-triggered generated-surface appendix. Confirm by
running the harvester and reading its output — do not assert a count before the run.

**Tier Justification**: `plan-file-scope-harvest.sh` on the repaired plan plus
`validate-state.sh` are the specific checks that cover both edited files exactly, and nothing in
`.claude/**` or the source store is touched by this phase.

**Files to modify**:
- `specs/410_internalize_tableau_branches_and_prove_routine_rule_admissibility/plans/01_internalize-routine-admissibility.md` -
  one per-phase `Files to modify` block added to each of the eight `### Phase N:` blocks.
- `specs/state.json` - project 410's `file_scope` union-appended from the harvester's output.
- `specs/TODO.md` - regenerated by `generate-todo.sh`, never hand-edited.

**Verification**:
- `bash .claude/scripts/plan-file-scope-harvest.sh <repaired plan>` emits a non-empty JSON array.
- `jq '.active_projects[] | select(.project_number==410) | .file_scope' specs/state.json` is
  non-null and non-empty.
- `bash .claude/scripts/validate-state.sh` is clean.
- Re-running the per-phase measurement sweep over `specs/[0-9]*/plans/*.md` reports zero
  whole-plan misses.

---

### Phase 3: Add the two-tier `Files to modify` presence check and its fixtures [COMPLETED]

**Goal**: `validate-artifact.sh`'s plan mode reports a per-phase omission as a warning and a
whole-plan omission as an error, distinguishes both from the legitimate "header present, zero
paths" sentinel, and is covered by three new fixture cases.

**Tasks**:
- [x] In the source-store `scripts/validate-artifact.sh`, extend the **existing** per-phase loop
      (the `**Verification Tier**` loop) with a header-presence test against the already-computed
      `phase_block`. Accept both punctuation forms and an optional single leading list marker,
      mirroring `plan-file-scope-harvest.sh`'s `strip_marker()` grammar verbatim rather than
      inventing a third grammar:
      `^[[:space:]]*(-[[:space:]]+)?\*\*Files to modify\*\*:` and
      `^[[:space:]]*(-[[:space:]]+)?\*\*Files to modify:\*\*`. *(completed)*
- [x] Collect the omitting phases' numbers into an array inside the loop and **emit after** it, so
      the two tiers never double-report: if every phase omits the field, emit a single `log_error`
      naming the consequence (`plan-file-scope-harvest.sh` harvests nothing, `file_scope` stays
      null, the task is invisible to the admission overlap gate); otherwise emit one `log_warn` per
      omitting phase (`Phase ${phase_num} missing **Files to modify** field`). *(completed)*
- [x] Add a header comment above the new block recording the tier rationale and the promotion
      criterion, in the same shape as the `Verification Tier` check's comment, and extend the
      `PLAN_METADATA` note to say that `Files to modify` is likewise deliberately not a member of
      that whole-document array and for the same reason. *(completed)*
- [x] Take no `--fix` participation (same posture as the plan-level Status-line grammar check): a
      missing file list cannot be synthesized. *(completed: no --fix branch added)*
- [x] In the source-store `scripts/tests/test-validate-artifact.sh`, first add a
      `**Files to modify**:` block with one backtick-path entry to `make_plan_fixture`'s Phase 1, so
      the existing `[PASS]`-asserting cases do not flip once the new check is live. *(completed)*
- [x] Add the three new cases: (a) a phase block with no header at all, asserting the new finding;
      (b) a phase block with the header and only a `- none planned ...` prose sentinel line,
      mirroring task #750's live shape, asserting NO finding; (c) a phase block with the header and
      at least one `` - `path` `` entry, asserting NO finding. Add a fourth case asserting the
      whole-plan `log_error` on a multi-phase fixture where every phase omits the field, and a fifth
      asserting that a mixed plan (one phase omits, another declares) draws the warning and NOT the
      error. *(completed: 5 cases added, one wrong assertion in case (b) caught and corrected during
      manual direct-invocation verification -- see progress/phase-3-progress.json)*
- [x] Verify by invoking the edited source-store script **directly** against hand-built fixtures
      (`bash /home/benjamin/.config/nvim/agent-system/extensions/core/scripts/validate-artifact.sh
      <fixture> plan`), in both default and `--strict` mode. Do NOT run
      `test-validate-artifact.sh` from the source store: it prefers
      `$REPO_ROOT/.claude/scripts/validate-artifact.sh`, and from there `REPO_ROOT` resolves to the
      nvim config repo, so the suite would silently exercise that repo's deployed copy instead of
      the edit. The suite runs in Phase 5, from this repo's deployed tree. *(completed: all 5 cases
      manually reconstructed and invoked directly against the edited source-store script; behavior
      matched expectations in both default and --strict mode)*

**Timing**: 2 hours

**Depends on**: 1, 2

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: the active-plan population measured at plan time is 16 plans / 116
`### Phase N:` blocks, with 13 phases across 3 plans omitting the field and exactly 1 whole-plan
miss (task #410, 8/8). The other two are task 282 (1/7) and task 428 (4/13). This is the evidence
for landing the per-phase tier at warn and the whole-plan tier at error: error-by-default on the
per-phase tier would newly fail two unrelated active plans, while error-by-default on the
whole-plan tier newly fails only #410, which Phase 2 repairs. **Confirm at implementation time** by
re-running the sweep after Phase 2 has landed; the expected post-repair residue is 5 omitting
phases across 2 plans and 0 whole-plan misses. If the re-run disagrees, re-derive the tier choice
from the new numbers rather than carrying these.

**Tier Justification**: `bash .claude/scripts/tests/run-all.sh --only test-validate-artifact` is
the suite that owns both edited files, and the change is confined to `validate-artifact.sh`'s
`artifact_type = plan` branch, which no other script sources.

**Files to modify**:
- `.claude/scripts/validate-artifact.sh` - the new per-phase header-presence test inside the
  existing loop, the deferred two-tier emission block after it, and the two header comments.
  **Edit target**:
  `/home/benjamin/.config/nvim/agent-system/extensions/core/scripts/validate-artifact.sh`.
- `.claude/scripts/tests/test-validate-artifact.sh` - `make_plan_fixture` gains the field; five new
  cases added. **Edit target**:
  `/home/benjamin/.config/nvim/agent-system/extensions/core/scripts/tests/test-validate-artifact.sh`.

**Verification**:
- `bash -n` on both edited source-store files parses clean.
- Direct invocation of the edited source-store validator on a fixture with no header anywhere exits
  non-zero and prints the whole-plan error; on a mixed fixture it exits 0 in default mode with the
  per-phase warning present, and non-zero under `--strict`.
- Direct invocation on a fixture carrying the header with only a `- none planned` sentinel prints
  no `Files to modify` finding.
- `bash .claude/scripts/plan-file-scope-harvest.sh` output for the sentinel fixture is unchanged
  from a pre-edit run (the harvester is untouched).

---

### Phase 4: Document the enforcement level and record the harvester decision [COMPLETED]

**Goal**: a future reader finds the tier rationale, the measured residue, and the promotion
criterion in `plan-format.md` without re-deriving them, and finds the SCOPE-3 decision recorded
where the harvester's own contract is defined.

**Tasks**:
- [x] Add an `Enforcement level` subsection for `Files to modify` to the source-store
      `context/formats/plan-format.md`, placed alongside the existing `### Enforcement level`
      subsection for `Verification Tier` and cross-referencing it explicitly as "the same pattern"
      rather than restating the rationale from scratch (the research report's Context Extension
      Recommendation). *(completed: added "### Enforcement level (Files to modify)" immediately
      after the Verification Tier one)*
- [x] State in that subsection: the per-phase tier (warn by default, error under `--strict`), the
      whole-plan tier (error by default), the reason the two differ, and the promotion criterion —
      promote the per-phase warning to an error once no non-terminal plan under `specs/` has any
      phase lacking the field, naming the residue measured at implementation time and the plans it
      sits in. *(completed: residue = 5 omitting phases across 2 plans)*
- [x] Extend the existing `**Consumers of this field**` subsection with a sentence stating that
      `validate-artifact.sh` is now a fourth consumer and the only surface that distinguishes "no
      header in this phase" from the legitimate "header present, zero paths" case. *(completed)*
- [x] Add a short cross-reference to the source-store `scripts/plan-file-scope-harvest.sh` header
      comment, under its existing `[]`-is-normal contract note, recording that the distinction is
      deliberately NOT made here and naming `validate-artifact.sh` as where it lives. Change no
      executable line in that script. *(completed: comment-only, confirmed via git diff -- 7
      insertions, all comment lines)*
- [x] Observe `.claude/rules/no-task-references-in-deliverables.md`: the source-store files are
      outside `specs/**`, so the residue must be described by plan slug or path, never by task
      number. *(completed: verified via grep sweep, zero task-number matches)*

**Timing**: 0.75 hours

**Depends on**: 3

**Verification Tier**: prose

**Commit Mode**: per-substep

**Scope Hypothesis**: two files, prose and comments only, no executable line changed. Confirm with
`git diff --stat` in the agent-system repo and by checking that the harvester diff touches only
comment lines.

**Tier Justification**: no suite covers a markdown-and-comment-only edit, so the specific covering
check is a consistency grep asserting that every tier word written into `plan-format.md` matches
the actual `log_warn`/`log_error` call site it describes in the validator landed in Phase 3.

**Files to modify**:
- `.claude/context/formats/plan-format.md` - a new `Enforcement level` subsection for this field
  and one sentence added to `**Consumers of this field**`. **Edit target**:
  `/home/benjamin/.config/nvim/agent-system/extensions/core/context/formats/plan-format.md`.
- `.claude/scripts/plan-file-scope-harvest.sh` - header-comment cross-reference only, no
  executable change. **Edit target**:
  `/home/benjamin/.config/nvim/agent-system/extensions/core/scripts/plan-file-scope-harvest.sh`.

**Verification**:
- The tier words in `plan-format.md` match the validator's call sites: a grep for `log_warn` and
  `log_error` in the new validator block agrees with the subsection's prose.
- `bash -n` on the edited harvester parses clean and `git diff` on it shows comment lines only.
- No task-number string appears in either source-store diff
  (`bash .claude/scripts/check-task-references.sh` on the deployed copies after Phase 5's redeploy).

---

### Phase 5: Redeploy, run the full gate set, and sweep every active plan [COMPLETED]

**Goal**: the edits are live in this repo's deployed tree, the complete gate set is green against
Phase 1's baseline, and the new check's behavior over the real active-plan corpus matches what
Phase 3's Scope Hypothesis predicted.

**Tasks**:
- [x] Run `bash .claude/scripts/deploy-headless.sh` and confirm `RESULT=landed_verify_clean`.
      *(completed)*
- [x] Run `bash .claude/scripts/tests/run-all.sh` (the complete suite set, no `--only`) and diff the
      roster against Phase 1's baseline. Every failure must be EXPECTED; a NEW failure blocks.
      *(completed, with a deviation: the first run surfaced 2 NEW failing suites not anticipated
      by this plan's Risk table -- test-gate-out-repair-reporting.sh and
      test-orchestrate-cycle-postflight.sh each build a single-phase plan fixture with no Files
      to modify field and assert zero errors/warnings from validate-artifact.sh. The plan's own
      Risk-table mitigation only updated test-validate-artifact.sh's OWN fixture; these two
      sibling suites' independently-defined fixtures needed the same one-entry Files-to-modify
      block added. Fixed both (in the source store), redeployed, re-ran: zero NEW failures
      against the Phase 1 baseline. See progress/phase-5-progress.json and the issue log.)*
- [x] Run `bash .claude/scripts/verify-deploy.sh` (the complete gate set, no `--only-gate`) and diff
      its findings against Phase 1's baseline. *(completed: PASS -- 14 check(s), 0 failure(s),
      matching baseline exactly)*
- [x] Run the deployed validator over every active plan
      (`for f in specs/[0-9]*/plans/*.md; do bash .claude/scripts/validate-artifact.sh "$f" plan; done`)
      and confirm: zero whole-plan `Files to modify` errors, and the per-phase warning count and
      plan distribution match the post-repair residue Phase 3 re-measured. *(completed: 0
      whole-plan errors, 5 per-phase warnings across 2 plans, exactly matching the predicted
      residue)*
- [x] Re-run `bash .claude/scripts/plan-file-scope-harvest.sh` against task #750's plan and confirm
      its output is byte-identical to the pre-change run — the legitimate sentinel case is
      untouched end to end. *(completed: byte-identical)*
- [x] Validate this task's own plan and report with the deployed validator
      (`validate-artifact.sh ... plan` and `... report`) and confirm `[PASS]`. *(completed: both
      [PASS], 0 warnings)*
- [x] Run `bash .claude/scripts/check-task-references.sh` and confirm no new finding from the
      source-store edits now present under `.claude/**`. *(completed: 198 pre-existing,
      unrelated occurrences repo-wide; zero of the 6 edited files appear in the findings)*

**Timing**: 1 hour

**Depends on**: 1, 2, 3, 4

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: the deployed validator over the 16 active plans is hypothesized to yield 0
whole-plan errors and a per-phase warning count equal to Phase 3's re-measured post-repair residue.
Confirm by the sweep itself and reconcile any disagreement before closing — an unexplained extra
warning means the new grep's grammar diverges from the harvester's.

**Files to modify**:
- `.claude/` - regenerated by `deploy-headless.sh`; no hand edit.
- `specs/755_plan_files_to_modify_unenforced/summaries/01_files-to-modify-enforcement-summary.md` -
  the completion summary, written at task close.

**Verification**:
- `deploy-headless.sh` reports `RESULT=landed_verify_clean`.
- `bash .claude/scripts/tests/run-all.sh` shows no NEW failure against the Phase 1 baseline.
- `bash .claude/scripts/verify-deploy.sh` shows no NEW finding against the Phase 1 baseline.
- The active-plan sweep reports 0 whole-plan errors.
- Task #750's harvester output is unchanged.
- This task's own plan and report both validate `[PASS]`.

---

## Testing & Validation

- [ ] `bash .claude/scripts/tests/run-all.sh --only test-validate-artifact` passes, including the
      five new cases.
- [ ] `bash .claude/scripts/tests/run-all.sh` (complete set) shows no NEW failure against the
      Phase 1 baseline.
- [ ] `bash .claude/scripts/verify-deploy.sh` (complete gate set) shows no NEW finding against the
      Phase 1 baseline.
- [ ] A plan with no `Files to modify` in any phase exits non-zero; a plan where one of several
      phases omits it exits 0 in default mode and non-zero under `--strict`.
- [ ] A phase carrying the header with only a prose sentinel draws no finding.
- [ ] `jq '.active_projects[] | select(.project_number==410) | .file_scope' specs/state.json` is
      non-empty and `bash .claude/scripts/validate-state.sh` is clean.
- [ ] `bash .claude/scripts/plan-file-scope-harvest.sh` output for task #750's plan is unchanged.
- [ ] `bash .claude/scripts/check-task-references.sh` reports no new finding.

## Artifacts & Outputs

- `specs/755_plan_files_to_modify_unenforced/plans/01_files-to-modify-enforcement.md` (this plan).
- A two-tier `Files to modify` presence check in `validate-artifact.sh`'s plan mode, with five new
  fixture cases in `test-validate-artifact.sh`.
- An `Enforcement level` subsection for the field in `plan-format.md`, carrying the measured
  residue and a mechanically executable promotion criterion.
- A comment-only cross-reference in `plan-file-scope-harvest.sh` recording that the no-block /
  empty-block distinction deliberately does not live there.
- Task #410's plan repaired with per-phase `Files to modify` blocks, and its `file_scope`
  non-null in `specs/state.json`.
- `specs/755_plan_files_to_modify_unenforced/summaries/01_files-to-modify-enforcement-summary.md`.

## Rollback/Contingency

Every edit is a small, isolated, per-substep commit, so recovery is forward rather than by revert
wherever a gate names the failing file (`context/contracts/recovery.md`).

- **Phase 3's check is too noisy or wrong-grammar**: the whole block is additive and confined to
  the validator's plan branch. Reverting that one commit restores pre-change behavior exactly; the
  harvester, `update-task-status.sh`, and all seven harvester callers were never touched, so there
  is nothing else to unwind.
- **Phase 5's gate set shows a NEW failure attributable to the stale-gap commit range rather than
  to this task**: Phase 1's baseline is what distinguishes the two. If the range is at fault, record
  it as a boundary note and raise it rather than absorbing the fix here.
- **Phase 2's repair of #410 proves wrong about a path**: `file_scope` is prospective and
  union-append, so a superfluous path costs an unnecessary serialization at most, never a lost
  edit; correct it with a second targeted union-append rather than a wholesale rewrite of the array.
- **Before any destructive rollback** (not expected for this task): take a durable checkpoint with
  `bash .claude/scripts/git-snapshot.sh 755 --no-revert` first, and use the default reverting form
  only in a genuine rollback.
