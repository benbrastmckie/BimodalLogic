# Implementation Plan: Task #832

- **Task**: 832 - Reclaim opencode_OLD and data partials
- **Status**: [NOT STARTED]
- **Effort**: 0.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/832_reclaim_opencode_old_and_data_partials/reports/01_reclaim-opencode-old-data-partials.md
- **Artifacts**: plans/01_reclaim-opencode-old-data-partials.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

Only one of the task's two reclamation items remains open. Item 1 (`.opencode_OLD/`, 62 MB) was
re-verified as a strict subset of the live `.opencode/` tree and deleted during the research
dispatch; the directory is confirmed absent from disk at plan time. Item 2's user decision has
been answered and recorded: both abandoned `bmlogic-c8-clean` partial-checkpoint files in `data/`
are approved for deletion. This plan therefore covers exactly that deletion plus the acceptance
sweep that closes the task. `data/proof_steps.jsonl` is untouched throughout.

### Premise Re-Validation (Carried-Figure Discipline)

Every figure the dispatch description carries was re-checked against live disk state at plan
time, not taken on the description's word:

| Carried claim | Live check | Result |
|---|---|---|
| `.opencode_OLD/` exists, 62 MB, safe to delete | `ls -d .opencode_OLD` | **CHANGED** — no longer exists; deleted during the research dispatch after a confirming `diff -rq` showed zero "Only in `.opencode_OLD`" entries. Item 1 is already discharged. |
| `.gitignore:105` ignores `.opencode_OLD`, `:107` ignores `data` | `sed -n '103,110p' .gitignore` | CONFIRMED unchanged — line 105 is `/.opencode_OLD`, line 107 is `/data`. |
| `data/` has zero tracked files | `git ls-files data` | CONFIRMED unchanged — zero entries. |
| `bmlogic-c8-clean.jsonl.partial` is 375 MB | `stat -c %s` | CONFIRMED — 392,670,566 bytes, mtime 2026-06-03 22:17:08. |
| `bmlogic-c8-clean.checkpoint.partial` is 15 MB | `stat -c %s` | CONFIRMED — 15,343,086 bytes, mtime 2026-06-03 22:17:08. |
| The two `.partial` files total 390 MB | sum of the two byte counts | CONFIRMED — 408,013,652 bytes combined (389.1 MiB). |
| `data/` totals 2.3 GB | `du -sh data` | CONFIRMED unchanged — 2.3 GB. |
| `proof_steps.jsonl` is 1.6 GB | `stat -c %s` | CONFIRMED — 1,650,583,836 bytes, mtime 2026-10-15 21:18. This is the untouched-throughout baseline. |

One correction to the description's framing follows from the first row: the plan's work list does
**not** include deleting `.opencode_OLD/`, because there is nothing left to delete. Phase 2
verifies its absence rather than acting on it.

### Research Integration

The research report mechanically confirmed the strict-subset relation for `.opencode_OLD/` (38
differing entries, **zero** of the form "Only in `.opencode_OLD`") before deleting it, and
established the shared run lineage of the two `.partial` files: both carry the same
2026-06-03 22:17 abandonment timestamp as `bmlogic-c8-clean_metadata.json`, and no completed
`bmlogic-c8-clean.jsonl` exists in `data/` — the run never finished. It also confirmed no script,
config, or deploy path references `.opencode_OLD/` as a live dependency.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was provided for this dispatch; no roadmap consultation performed.

### Recorded User Decision

`specs/832_reclaim_opencode_old_and_data_partials/.decisions.json` records the answer to this
task's one blocking question, given in cycle 1 at 2026-11-12T17:50:47Z: **delete both `.partial`
files now**, as confirmed abandoned-run artifacts of an interrupted generation run with no
completed output file in `data/`. The recorded obligation attached to that answer was to
discharge Item 2's acceptance criterion ("a recorded decision on the two `data/*.partial` files")
without performing an automatic, user-unconfirmed deletion. That route does discharge its named
obligation: the decision is now recorded *and* authorizes the deletion, so Phase 1 executes it as
authorized work rather than as a unilateral act, and no further user question is owed.

## Goals & Non-Goals

**Goals**:
- Delete `data/bmlogic-c8-clean.jsonl.partial` and `data/bmlogic-c8-clean.checkpoint.partial`
  (408,013,652 bytes combined), reclaiming ~389 MiB of local disk.
- Verify all three of the task's acceptance criteria hold at close: `.opencode_OLD/` removed,
  a recorded decision on the two `data/*.partial` files, `proof_steps.jsonl` untouched.
- Leave the repository's tracked working tree unchanged — no source-code or config commit
  originates from this task's own work.

**Non-Goals**:
- Deleting, truncating, moving, or reading `data/proof_steps.jsonl`. It feeds the separate
  BimodalHarness training pipeline and is not regenerable from anything in this repository.
- Deleting any other file in `data/`, including `bmlogic-c8-clean_metadata.json` (1,800 bytes,
  same run lineage but not a `.partial` file and not in scope), `bmlogic-c8-stratified.checkpoint`,
  `bmlogic.checkpoint`, or any `.jsonl`/`.zst` dataset.
- Sweeping any other top-level directory. `Boneyard/` in particular holds 225 TRACKED files and
  is retained by design — DO NOT DELETE.
- Fixing the stale `CHANGELOG.md` or the stale `completeness_discrete` citation in
  `FormalSystem/Metalogic/README.md`. Both fold into the already-filed documentation-polish
  record, which is last in the programme.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| The deletion is unrecoverable — `data/` is gitignored with zero tracked files, so there is no git history and no stash to restore from | H | H (certain, by construction) | Accepted and explicitly authorized by the recorded user decision. Phase 1 re-confirms byte sizes and mtimes immediately before deleting, so the plan and summary preserve the only durable record of what was removed. |
| A glob or wildcard removal catches more than the two intended files (e.g. `rm data/*.partial` also matching a future file, or `rm -rf data/`) | H | L | Phase 1 removes the two files by **explicit full path only** — never a glob, never `-r`, never a directory argument. A post-delete `ls data/` confirms the rest of the directory is intact. |
| `proof_steps.jsonl` is accidentally touched | H | L | Its exact pre-state (1,650,583,836 bytes, mtime 2026-10-15 21:18:22) is recorded above and re-asserted in Phase 2's verification as a byte-for-byte, mtime-for-mtime match. |
| A concurrent sibling task's edits are mistaken for this task's own, or vice versa | M | M | Four sibling tasks are dispatched this same cycle (817, 818, 714 plan; 821 implement), none with any overlap with `data/**`. Phase 2's `git status --short` review attributes any tracked-file change to its owner before concluding anything; an unexplained foreign modification is reported, not swept. |
| The "no commit expected" acceptance line is misread as forbidding the orchestrator's own artifact commits | L | M | Clarified in Phase 2: that line governs the *repository working tree* (source, config, data). Lifecycle commits of this task's own `specs/**` artifacts are normal orchestration and are not a scope violation. |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |

Phases within the same wave can execute in parallel.

### Phase 1: Delete the Two Abandoned c8-clean Partial Checkpoints [NOT STARTED]

**Goal**: Remove `data/bmlogic-c8-clean.jsonl.partial` and
`data/bmlogic-c8-clean.checkpoint.partial` from local disk, as authorized by the recorded user
decision, after a final immediately-before-deletion re-verification.

**Tasks**:
- [ ] Re-read `specs/832_reclaim_opencode_old_and_data_partials/.decisions.json` and confirm the
      recorded answer is still "Delete both .partial files now". If it is not, STOP and report —
      do not delete.
- [ ] Re-verify both files are untracked: `git ls-files data` must return zero entries, and
      `sed -n '107p' .gitignore` must read `/data`.
- [ ] Re-verify identity and size immediately before deleting:
      `stat -c '%n %s %y' data/bmlogic-c8-clean.jsonl.partial data/bmlogic-c8-clean.checkpoint.partial`.
      Expect 392,670,566 and 15,343,086 bytes, both mtime 2026-06-03 22:17:08. If either byte
      count differs from the recorded figure, STOP and report — a changed size means the file is
      not the abandoned artifact the decision was given about.
- [ ] Confirm no completed `data/bmlogic-c8-clean.jsonl` (non-`.partial`) has appeared; its
      presence would change the interpretation of the `.partial` files.
- [ ] Record `du -sb data` as the pre-delete baseline.
- [ ] Delete exactly the two files, by explicit full path, with no glob, no `-r`, and no
      directory argument:
      `rm -- data/bmlogic-c8-clean.jsonl.partial data/bmlogic-c8-clean.checkpoint.partial`
- [ ] Confirm removal and collateral safety: `ls -la data/` shows both `.partial` files absent and
      every other entry still present (including `bmlogic-c8-clean_metadata.json`,
      `bmlogic-c8-stratified.checkpoint`, and `proof_steps.jsonl`).
- [ ] Confirm the reclamation: `du -sb data` is lower than the pre-delete baseline by
      408,013,652 bytes (allow for filesystem block-accounting slack; the figure is the sum of
      the two file sizes, not necessarily the exact on-disk delta).
- [ ] Confirm `git status --porcelain` lists nothing for `data/` — the deletion must be invisible
      to git, since the path is gitignored with zero tracked files.

**Timing**: 0.25 hours

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: Exactly two files are deleted, totalling 408,013,652 bytes
(392,670,566 + 15,343,086), and `data/` loses no other entry. Confirm at implementation time via
the pre-delete `stat` on both paths and the post-delete `ls -la data/` collateral check listed
above; a differing byte count or a missing third entry falsifies the hypothesis and is a STOP
condition, not a figure to adjust silently.

**Tier Justification**: `suite_selection_select` over both `data/*.partial` paths returns
`__FULL_SWEEP__` (run at plan time — no test suite maps to either path), and both are
deploy-consumer-tree paths outside `specs/**`, so the honest covering checks are the `local`
row's single-target lint read as the post-delete `ls -la data/` / `du -sb data` / `git status
--porcelain` inspection above, together with sub-case (c)'s `bash
.claude/scripts/verify-deploy.sh --only-gate 4`.

**Files to modify**:
- `data/bmlogic-c8-clean.jsonl.partial` - deleted (392,670,566 bytes, abandoned run checkpoint output)
- `data/bmlogic-c8-clean.checkpoint.partial` - deleted (15,343,086 bytes, abandoned run checkpoint state)

**Verification**:
- Both paths absent from `ls -la data/`.
- `du -sb data` reduced by approximately 408,013,652 bytes against the pre-delete baseline.
- Every other `data/` entry still present, `bmlogic-c8-clean_metadata.json` and
  `proof_steps.jsonl` among them.
- `git status --porcelain` shows no entry for `data/`.
- `bash .claude/scripts/verify-deploy.sh --only-gate 4` passes (task-reference lint; the only
  gate with a real surface for a deploy-consumer-tree path with no mapped suite).

---

### Phase 2: Acceptance Verification and Task-Record Disposition [NOT STARTED]

**Goal**: Confirm all three of the task's acceptance criteria hold, confirm the two explicitly
out-of-scope protections were honoured, and close the task with the full gate set green.

**Tasks**:
- [ ] Acceptance criterion 1 — `.opencode_OLD/` removed: confirm `ls -d .opencode_OLD` reports no
      such file or directory. This was discharged during the research dispatch after a confirming
      `diff -rq .opencode .opencode_OLD` showed zero "Only in `.opencode_OLD`" entries; this phase
      verifies the end state rather than repeating the deletion.
- [ ] Acceptance criterion 2 — a recorded decision on the two `data/*.partial` files: confirm
      `specs/832_reclaim_opencode_old_and_data_partials/.decisions.json` holds the answered
      question, and that this plan's "Recorded User Decision" section and the task summary both
      state the decision and its disposition.
- [ ] Acceptance criterion 3 — `proof_steps.jsonl` untouched: confirm
      `stat -c '%n %s %y' data/proof_steps.jsonl` still reads 1,650,583,836 bytes with mtime
      2026-10-15 21:18:22. Any difference in either field is a failure, not a rounding artifact.
- [ ] Confirm the out-of-scope directories were not swept — at minimum that `Boneyard/` still
      exists and `git ls-files Boneyard | wc -l` still reports 225 tracked files.
- [ ] Review `git status --short` and `git diff --staged`. The task's own work must contribute
      **zero** tracked-file changes: `data/` and `.opencode_OLD/` are both gitignored with zero
      tracked files, so nothing from Phase 1 can appear. Note explicitly in the summary that this
      acceptance line governs the repository working tree — lifecycle commits of this task's own
      `specs/**` artifacts (report, plan, summary, state) are normal orchestration and are not a
      scope violation.
- [ ] If any tracked-file modification appears that this task did not make, check `git log` to
      confirm it is not this task's own work and then STOP and report it as a possible concurrent
      sibling's in-flight edit (tasks 817, 818, 714, 821 are dispatched this same cycle) rather
      than dismissing it or reverting it.
- [ ] Run the complete gate set: `bash .claude/scripts/verify-deploy.sh`. Record the result
      verbatim, green or not.
- [ ] Record total disk reclaimed across both items: 62 MB (`.opencode_OLD/`, research dispatch)
      plus ~389 MiB (the two `.partial` files, Phase 1) — approximately 451 MB.

**Timing**: 0.25 hours

**Depends on**: 1

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase writes exactly one file (the summary) and modifies no other
path; the figures it asserts are `Boneyard/` at 225 tracked files, `proof_steps.jsonl` at
1,650,583,836 bytes, and ~451 MB total reclaimed across both items. Confirm at implementation
time via `git ls-files Boneyard | wc -l`, `stat -c %s data/proof_steps.jsonl`, and the Phase 1
`du -sb data` delta respectively; a mismatch on any of the three is a reportable finding, not a
figure to quietly restate.

**Files to modify**:
- `specs/832_reclaim_opencode_old_and_data_partials/summaries/01_reclaim-opencode-old-data-partials-summary.md` - new execution summary recording the deletion, the byte counts removed, and the acceptance-criteria verdicts

**Verification**:
- `bash .claude/scripts/verify-deploy.sh` runs to completion and is observed green in this
  dispatch — the complete gate set this plan's final phase is responsible for, never trusted on
  sight.
- All three acceptance criteria verified as described in the task list above, each with its
  command output rather than an assertion.
- `data/proof_steps.jsonl` byte-for-byte and mtime-for-mtime unchanged.
- `git status --short` attributable in full; nothing from this task staged.

---

## Testing & Validation

- [ ] `data/bmlogic-c8-clean.jsonl.partial` and `data/bmlogic-c8-clean.checkpoint.partial` absent
      from `ls -la data/`.
- [ ] `du -sb data` reduced by approximately 408,013,652 bytes.
- [ ] `data/proof_steps.jsonl` still 1,650,583,836 bytes, mtime 2026-10-15 21:18:22.
- [ ] `data/bmlogic-c8-clean_metadata.json` and every other non-`.partial` entry in `data/` still
      present.
- [ ] `.opencode_OLD/` absent.
- [ ] `Boneyard/` present with 225 tracked files.
- [ ] `git status --porcelain` carries no entry attributable to this task's working-tree work.
- [ ] `bash .claude/scripts/verify-deploy.sh` green.

## Artifacts & Outputs

- `specs/832_reclaim_opencode_old_and_data_partials/plans/01_reclaim-opencode-old-data-partials.md`
  (this plan).
- `specs/832_reclaim_opencode_old_and_data_partials/summaries/01_reclaim-opencode-old-data-partials-summary.md`
  (execution summary, written in Phase 2), recording the exact byte counts removed, the
  acceptance-criteria verdicts, and the total disk reclaimed.
- Local disk: approximately 389 MiB reclaimed under `data/` (on top of the 62 MB already
  reclaimed by the research dispatch's `.opencode_OLD/` removal).
- No source-code, configuration, or tracked-data change; no working-tree commit originates from
  this task's own work.

## Rollback/Contingency

**There is no rollback for Phase 1.** `data/` is gitignored at `.gitignore:107` with zero tracked
files, so the deleted `.partial` files exist in no commit, no stash, and no snapshot. This is the
precise asymmetry that made Item 2 a user decision rather than an automatic action, and the
decision to accept it is recorded in `.decisions.json`. The contingency is therefore preventive,
not corrective, and lives entirely in Phase 1's pre-delete gates: the decisions-file re-read, the
untracked re-confirmation, the byte-count-and-mtime match, and the explicit-path-only `rm`. Any
one of those failing is a STOP-and-report condition, not a proceed-with-caution one.

Should the abandoned run ever need to be resumed, it must be re-run from the generator; the only
durable record of what was removed is the byte counts and mtimes preserved in this plan and in the
Phase 2 summary.

Phase 2 is read-only apart from writing the summary, and needs no rollback. No `git-snapshot.sh`
invocation is warranted anywhere in this plan: there is no uncommitted tracked work to protect and
no rollback scenario to prepare for.
