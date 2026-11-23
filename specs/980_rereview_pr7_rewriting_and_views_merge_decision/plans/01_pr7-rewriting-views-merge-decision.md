# Implementation Plan: Task #980

- **Task**: 980 - rereview_pr7_rewriting_and_views_merge_decision
- **Status**: [COMPLETED]
- **Effort**: 1.25 hours
- **Dependencies**: None
- **Research Inputs**: specs/980_rereview_pr7_rewriting_and_views_merge_decision/reports/01_pr7-rewriting-views-merge-decision.md
- **Artifacts**: plans/01_pr7-rewriting-views-merge-decision.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

The task's stated aim — reach a merge decision on PR #7 — is already discharged by events that
postdate the research report. The pull request is **MERGED** (merge commit
`3c7197f84297d9ebab2472a89adba19effb72ef6`, merged 2026-11-22T22:58:00Z, head `6313e693f`), the
three conditions the report recommended were applied by the contributor, the filing by family
was delivered as well, and the M17 "Current client" paragraph has already been restated on
`main`. What remains is not a second review but a close-out: bring this task's own durable
record into agreement with what actually happened, retire the superseded draft that sits in this
task's declared file scope, and confirm every residual follow-up already has a named owner so
nothing is dropped on the floor. No Lean source is edited and nothing is posted, pushed or
merged.

### Research Integration

The research report (`reports/01_...md`) is the task's evidence base and it is sound as of the
head it reviewed (`5f5ad32bf`), but its headline recommendation — REQUEST CHANGES on three
items — is now historical rather than live. Its three findings that matter going forward are
carried into this plan unchanged: the measured views-tier gap (four view names against ~17
operators, two tables rather than one), the measured residual swallowed errors, and the
45-declaration filing inventory. The plan's job is to attach an outcome to that report, not to
re-derive it.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was supplied in this dispatch, so no roadmap consultation was performed. The
sequencing facts the plan relies on come from `specs/state.json` task descriptions (982, 981,
969, 960) rather than from `specs/ROADMAP.md`.

## Premise Re-Validation (Carried-Figure Discipline)

The dispatch's `## Description` was checked against live state before this plan was written.
Result, stated explicitly as the discipline requires:

| Carried claim in the description | Live state | Verdict |
|---|---|---|
| "head 5f5ad32bf when filed" | `gh pr view 7` reports head `6313e693f41e5dd761da83cd8e88b696196d2b8b` | **superseded** |
| "the aim is to reach a merge decision" | `state: MERGED`, `mergedAt: 2026-11-22T22:58:00Z`, merge commit `3c7197f84297d9ebab2472a89adba19effb72ef6`, already an ancestor of local `HEAD` | **discharged** |
| "CI is red on one linter warning ... `import Lean` at FormalSystem/Tactic/FormulaSyntax.lean:8" | line 8 now reads `import Lean.Meta.AppBuilder` | **fixed** |
| "not done: filing by family (Congruence.lean is one file, tests remain in the shared ProofModeExtensionsTest.lean)" | `FormalSystem/Theorems/ProofMode/Congruence/` exists beside `ModalBoolean.lean` and `ModalTemporalBoolean.lean`; `ProofModeExtensionsTest.lean` is gone, replaced by `ProofModeBooleanTest.lean`, `ProofModeModalBooleanTest.lean`, `ProofModeModalTemporalBooleanTest.lean`, `ProofModeTemporalBooleanTest.lean` | **delivered** |
| report's condition 2, the two missing docstrings | `FormulaViews.lean` carries `/-- Persistent registrations for named formula views ... -/` on the `views` extension; the `lSimpOption` production is documented | **fixed** |
| report's condition 3, the M17 "Current client" numbers | `records/proof-mode.md:493` now reads "The saving is in the proof script and not in the proof term, which is larger for the rewrite variant", names `Tests/BimodalTest/Automation/ProofModeModalBooleanTest.lean`, and carries no unreproducible node counts or timing | **corrected on `main`** |
| the three rulings carried on `.return-meta.json` from the research round | all three resolved by events: conditions settled and exceeded, squash merge taken, M17 paragraph restated | **closed** |

The response actually posted was `specs/reviews/pr-reviews-2026-11-21/pr7-approval.md`, not the
drafted `pr7-review.md` that this task's `file_scope` names. That divergence is the thing
Phase 3 repairs.

## Goals & Non-Goals

**Goals**:

- Record, in this task's own durable artifact, the outcome the task was created to reach, with
  the merge commit and the evidence that each condition landed.
- Leave `specs/reviews/pr-reviews-2026-11-21/pr7-review.md` — this task's entire declared
  `file_scope` — stating plainly that it is the superseded draft and naming what was posted
  instead, so a future reader of that directory is not misled into thinking PR #7 is open.
- Confirm that every residual follow-up the review identified has a named owner, and name any
  that does not, so the close-out drops nothing.

**Non-Goals**:

- **No record edits.** `records/milestones.md`, `records/proof-mode.md`,
  `records/proof-mode-architecture.md` and `records/README.md` are the declared `file_scope` of
  `reconcile_records_and_tasks_after_pr_review_round`, whose description already covers M17,
  M16, the contributions table and open decision 1 by name. This task touches none of them.
- **No task-description edits.** The same reconciliation task owns every description change,
  explicitly "edited through state-write.sh and never by hand".
- **No re-review and no new PR #8–#11 work.** `rereview_pr8_temporal_rules_and_carrying_table`
  owns #8; siblings 978 and 979 own #11, #10 and #9 this same cycle.
- **No Lean source edits, no build-green campaign.** The merged tree's gates are CI's and the
  reconciliation task's business, not a close-out's.
- **Nothing posted, pushed, merged or approved** (`.claude/rules/pr-prohibition.md`). The merge
  already happened; this task does not touch GitHub beyond read-only `gh pr view`.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| A commit of `specs/980_.../reports/01_...md` is refused by `git-commit-scoped.sh`'s containment guard, because this task's `file_scope` in `specs/state.json` lists only `specs/reviews/pr-reviews-2026-11-21/pr7-review.md` | M | M | Expected path is that task-directory artifacts are handled by postflight staging. If a commit is refused, widen `file_scope` in `specs/state.json` first (via `state-write.sh`, or a scoped direct edit re-serialized with `json.dump(..., ensure_ascii=False)` so the file's existing non-ASCII is not corrupted) rather than forcing the commit |
| `specs/reviews/` is excluded from git locally (`.git/info/exclude:20:/specs/reviews/`), so the Phase 3 edit will never produce a commit | L | H (certain) | Expect and record a `git-commit-scoped.sh` exit 8/9 non-failure skip for that path; do not read it as a failure and do not attempt to force the file into the index |
| A sibling task (978, 979) edits `specs/reviews/pr-reviews-2026-11-21/` concurrently this same cycle | M | M | The siblings' declared scopes are `pr11-review.md`, `pr10-review.md` and `pr9-disposition.md` — disjoint from `pr7-review.md`. Re-read `pr7-review.md` immediately before editing. **Do not touch `FOLLOWUP.md`**: it is the shared coordination file of that thread and is in no one's declared scope |
| The close-out silently duplicates work the reconciliation task is contracted to do | M | M | Phase 4 states the handover as prose in this task's report only, naming the owning slug for each residual, and writes nothing into any record or any other task's description |
| `verify-touched.sh` attributes sibling tasks' uncommitted `specs/` edits to this dispatch and pulls in the agent-system battery, whose ~11-of-95 failures are a standing baseline in this deploy-only tree | L | H | Phase 4's criterion is scoped to the paths this task touched and is stated as a baseline delta, never as an absolute exit 0 — see `plan-authoring-gate-collisions.md` Condition 4 |

**Gate-collision pre-check** (`context/project/lean4/patterns/plan-authoring-gate-collisions.md`,
run before the phases below were written): this plan edits **no `.lean` file**, so Condition 1
does not fire on either surface — `.githooks/pre-commit`'s `typst/generated/status.typ`
line-count check is a no-op on a staged set with no `.lean` path, and the module-inventory
blocks cannot go stale. No new upward import, so Condition 5 is inert. No new `def`/`abbrev`,
so Conditions 6 and 9 are inert. No file added or removed under `FormalSystem/`, so C33 and
`FAIL INV` are inert. Condition 4 is the only live one and is honored in Phase 4's criterion.
No generated artifact derives any quantity this plan moves, so no coupled generated surface is
owed a declaration.

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2, 3 |

Phases within the same wave can execute in parallel.

### Phase 1: Confirm the Merged Outcome and Map the Residuals [COMPLETED]

**Goal**: Hold, as first-hand evidence rather than as inherited claim, the facts the close-out
will assert: that PR #7 merged, at which commit, with which conditions landed; and, for each
residual follow-up the review named, which open task or record already owns it.

**Tasks**:

- [x] Re-check the pull request read-only: `gh pr view 7 --json number,state,headRefOid,mergedAt,mergeCommit,title`. Record `state`, `mergedAt`, `headRefOid` and the merge commit oid verbatim. If `state` is anything other than `MERGED`, STOP and report — the whole premise of this plan is then wrong.
- [x] Confirm the merge commit is an ancestor of local `HEAD` (`git merge-base --is-ancestor <merge-oid> HEAD`), so the facts below are read off a tree that actually contains the merged work.
- [x] Confirm each of the three conditions landed, by file and line, not by inference: the import at `FormalSystem/Tactic/FormulaSyntax.lean` line 8; a docstring on the `lSimpOption` production in `FormalSystem/Automation/ProofMode/Simplification.lean`; a docstring on the `views` environment extension in `FormalSystem/Tactic/FormulaViews.lean`.
- [x] Confirm the filing by family landed: list `FormalSystem/Theorems/ProofMode/` and `Tests/BimodalTest/Automation/`, and record which per-family modules and per-family test files now exist and that `ProofModeExtensionsTest.lean` is gone.
- [x] Read the current M17 "Current client" paragraph in `records/proof-mode.md` and record whether the unreproducible node counts and the `0.14 ms` timing are still present. (At authoring time they are not; confirm rather than assume.)
- [x] For each of the five follow-ups listed in `specs/reviews/pr-reviews-2026-11-21/pr7-approval.md` and `pr7-review.md` — the missing occurrence argument on `lunfold`/`lfold`; `applyView` discarding its error; the per-attempt `catch` in `lsimp`; the eleven remaining `fail_if_success` and the untested stopped-wrapper message; the four-name view table against the operator-matching table — identify the owning slug by reading the relevant task descriptions in `specs/state.json` (`proof_mode_views_tier`, `reconcile_records_and_tasks_after_pr_review_round`, `proof_mode_split_shared_test_and_guide_files`) and the relevant record sections. Write the five-row owner map to the scratchpad.
- [x] Record any residual with **no** owner as an explicit gap; do not invent one.
- [x] Record one `issue-record.sh` entry for the premise supersession found at plan time (class: stale premise / superseded input), non-fatally.

**Timing**: 0.4 hours

**Depends on**: none

**Verification Tier**: local

**Tier Justification**: The phase reads files and runs one read-only `gh` query and one
`git merge-base` check; the covering check is that each asserted fact is restated with the
command or the file-and-line that produced it, and no file is modified, so no suite can regress.

**Scope Hypothesis**: This phase asserts that all three review conditions and the filing by
family landed, and that each of the five residual follow-ups has an owner among
`proof_mode_views_tier`, `reconcile_records_and_tasks_after_pr_review_round` and
`proof_mode_split_shared_test_and_guide_files`. The conditions and the filing were confirmed at
plan-authoring time and should reproduce; the five-row owner map was **not** confirmed and is a
genuine hypothesis — the implementer confirms it by reading each named task description in
`specs/state.json` in full, and reports any residual that turns out to be unowned rather than
forcing it into the nearest slug.

**Files to modify**:

- none planned — this phase reads only; its output is evidence held for Phases 2 and 3

**Verification**:

- `gh pr view 7` output recorded verbatim, showing `state: MERGED` with a merge commit oid
- Each of the three conditions and the filing by family restated with the file and line (or the
  directory listing) that shows it
- A five-row owner map exists, each row naming either an owning slug with the sentence in its
  description that carries the obligation, or an explicit "no owner found"

---

### Phase 2: Record the Outcome in the Task's Report [COMPLETED]

**Goal**: Attach the outcome to this task's own durable artifact, so the report no longer stands
as a live REQUEST CHANGES recommendation against a head that no longer exists.

**Tasks**:

- [x] Re-read `specs/980_rereview_pr7_rewriting_and_views_merge_decision/reports/01_pr7-rewriting-views-merge-decision.md` immediately before editing (a sibling could not have touched it, but the re-read also confirms no Outcome section already exists).
- [x] Append a single new `## Outcome` section at the end of the report. Do **not** rewrite, renumber or contradict the existing findings: they are correct for the head they reviewed and are the evidence this section's conclusion rests on.
- [x] In that section state, each with the evidence from Phase 1: that PR #7 merged, at which commit and when; that the head moved from `5f5ad32bf` to `6313e693f`; that all three recommended conditions landed; that the filing by family was delivered as well, which the report had recommended be deferred to the layout record; that the M17 "Current client" paragraph has been restated on `main`; and that the response actually posted was `pr7-approval.md`.
- [x] State plainly which of the report's claims are now **historical** rather than live: the REQUEST CHANGES recommendation and the three-condition list at the top, and the "Items Needing Your Ruling" table whose three rulings are all closed.
- [x] State plainly which of the report's claims remain **live and unsuperseded**: the measured views-tier gap against the M16 deliverables, the measured `lunfold`/`lfold` and `applyView` behaviour, the residual swallowed-error examples, and the 45-declaration filing inventory (now partly consumed by the contributor's own filing, which the section says so).
- [x] State what was **not** re-verified in this close-out — in particular that no build, test or lint gate was re-run against the merged tree, and that the per-family filing was confirmed by directory listing rather than by checking every declaration reached its intended family module.
- [x] Commit the report edit as its own green sub-step.

**Timing**: 0.35 hours

**Depends on**: 1

**Verification Tier**: prose

**Tier Justification**: The edit is a markdown append under `specs/**`, which no build, test or
lint suite reads; the covering check is a re-read of the appended section confirming every
asserted fact names the Phase 1 evidence that produced it.

**Files to modify**:

- `specs/980_rereview_pr7_rewriting_and_views_merge_decision/reports/01_pr7-rewriting-views-merge-decision.md` - append one `## Outcome` section; no existing content rewritten

**Verification**:

- The report ends with exactly one new `## Outcome` section, and every pre-existing section is
  byte-unchanged (confirm with a diff of the edit, not by eye)
- Every fact in the new section is traceable to a command run or a file read in Phase 1
- The section names what was not re-verified, rather than leaving the omission implicit

---

### Phase 3: Retire the Superseded Draft in This Task's File Scope [COMPLETED]

**Goal**: Leave `specs/reviews/pr-reviews-2026-11-21/pr7-review.md` — the whole of this task's
declared `file_scope` — unable to mislead a future reader of that directory into thinking PR #7
is open and awaiting three changes.

**Tasks**:

- [x] Re-read `specs/reviews/pr-reviews-2026-11-21/pr7-review.md` immediately before editing (territory: siblings 978 and 979 are live in this same directory this cycle, on different files).
- [x] Prepend a short, clearly separated header block — four lines at most — stating: that this is the drafted request-changes response, superseded before it was posted; that the response actually posted was `pr7-approval.md` in the same directory; and that PR #7 merged as `<merge-oid>` on `<mergedAt>` with all three conditions and the filing by family landed. Supersession language is permitted here: `specs/**` is the primary exemption of `.claude/rules/no-record-versioning-in-deliverables.md`.
- [x] Leave the draft's body text unchanged. It is the record of what was asked for and why, and the approval that superseded it is a separate file; rewriting the body would destroy the comparison.
- [x] **Do not touch `FOLLOWUP.md`**, `pr7-approval.md`, or any `pr8`/`pr9`/`pr10`/`pr11` file in that directory.
- [x] Attempt the scoped commit. `specs/reviews/` is git-excluded locally, so expect a `git-commit-scoped.sh` non-failure skip (exit 8/9) rather than a commit; record that outcome and move on rather than treating it as a failure or forcing the file into the index.

**Timing**: 0.25 hours

**Depends on**: 1

**Verification Tier**: prose

**Tier Justification**: The edit is a markdown header prepended to a git-excluded file under
`specs/**` that no build, test or lint suite reads; the covering check is a re-read confirming
the header names the merge commit and `pr7-approval.md` and that the body below it is unchanged.

**Files to modify**:

- `specs/reviews/pr-reviews-2026-11-21/pr7-review.md` - prepend a short superseded-draft header; body unchanged

**Verification**:

- The file opens with the header block, which names `pr7-approval.md` and the merge commit oid
- The draft body below the header is unchanged
- `git status --short specs/reviews/` is empty (the directory is excluded), and the commit
  attempt's skip is recorded rather than worked around

---

### Phase 4: Close Out and Hand Over the Residuals [COMPLETED]

**Goal**: Close the task with every residual explicitly assigned, and with the verification
evidence this orchestration round owes.

**Tasks**:

- [x] Append to the report's `## Outcome` section (or add one short `### Handover` subsection beneath it) the five-row residual owner map from Phase 1, each row naming the residual, the owning slug, and the sentence in that task's description that carries the obligation.
- [x] For any residual Phase 1 found **unowned**, state it as an open gap in the same subsection and surface it in the dispatch's `.return-meta.json` as a non-blocking `user_decision`, since creating a new task is the user's call and not this task's remit.
- [x] State in that subsection that `reconcile_records_and_tasks_after_pr_review_round` is the record owner and that this task edited no record, so the reconciliation task's inputs are unperturbed.
- [x] Run the scoped touched-path verification over the paths this task actually modified (the report and `pr7-review.md`), and record the result as a delta against the standing baseline, not as an absolute exit 0 — this tree's agent-system battery carries ~11-of-95 standing failures that are a property of a deploy-only tree with no on-disk source store, unrelated to any file this task touched.
- [x] Record the gate-set obligation as deferred to the orchestration close (Move 4) rather than invoking the full battery here: no `.lean` file was touched, so no Lean gate is implicated by this task's edits.
- [x] Record the close-out `issue-record.sh` entries — at minimum the premise-supersession issue and, as a `win`, that the contributor delivered beyond the three conditions (the filing by family) so the layout record's inventory shrank without a round-trip.
- [x] Commit the final report edit.

**Timing**: 0.25 hours

**Depends on**: 2, 3

**Verification Tier**: full

**Files to modify**:

- `specs/980_rereview_pr7_rewriting_and_views_merge_decision/reports/01_pr7-rewriting-views-merge-decision.md` - append the residual owner map and handover statement

**Verification**:

- Every residual named in Phase 1's map appears in the report with an owning slug, or is named
  as an open gap and carried into `.return-meta.json` as a non-blocking `user_decision`
- The scoped touched-path check is run over the two files this task modified and its result is
  recorded as a baseline delta, with any pre-existing failure enumerated and shown not to read
  any file this task touched
- The complete gate set is explicitly deferred to the orchestration close rather than invoked
  here, and the deferral is stated in the handoff; no `.lean` path was staged at any point, so
  the `.githooks/pre-commit` generated-surface check is a confirmed no-op
- `specs/state.json` and the records are unmodified by this task (`git status --short records/`
  is empty of this task's work)

---

## Testing & Validation

- [x] `gh pr view 7` confirms `state: MERGED` and the merge commit oid the report cites
- [x] The three conditions and the per-family filing are each restated in the report with the
      file, line or directory listing that shows them
- [x] The report's `## Outcome` section separates historical claims from live ones, and names
      what was not re-verified
- [x] `specs/reviews/pr-reviews-2026-11-21/pr7-review.md` opens with the superseded-draft header
      and its body is unchanged
- [x] `FOLLOWUP.md` and the `pr8`–`pr11` files in that directory are untouched
- [x] No file under `records/`, no `.lean` file, and no other task's description was modified
- [x] The scoped touched-path check is recorded as a baseline delta over the two modified files

## Artifacts & Outputs

- `specs/980_rereview_pr7_rewriting_and_views_merge_decision/reports/01_pr7-rewriting-views-merge-decision.md` — extended with an `## Outcome` section and a residual-handover subsection
- `specs/reviews/pr-reviews-2026-11-21/pr7-review.md` — annotated as the superseded draft
  (git-excluded locally; no commit expected)
- `.return-meta.json` — final status, with a non-blocking `user_decision` only if Phase 1 finds
  an unowned residual

## Rollback/Contingency

Both edits are additive markdown under `specs/**`. To revert, remove the appended `## Outcome`
section from the report and the prepended header from `pr7-review.md`; nothing else in the
repository is touched and no build artifact is affected. Do **not** use
`git checkout -- <path>` to revert: this is a shared working tree with concurrent sibling
dispatches, and `guard-destructive-git.sh` blocks the pathspec-discard form on a dirty tree.
Restore from a saved copy and confirm with `git status --short` instead.

**Contingency if Phase 1 finds `state` is not `MERGED`**: stop immediately and report. The
entire plan rests on the merge having happened; if it has not, the task reverts to a live
re-review and needs a fresh plan against the current head, not an adapted close-out.
