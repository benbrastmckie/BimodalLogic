# Implementation Plan: Task #978

- **Task**: 978 - Review collaborator PR #11 (feat/pointed-semantic-lemmas) and prepare a merge recommendation and draft review
- **Status**: [IMPLEMENTING]
- **Effort**: 1.25 hours
- **Dependencies**: None
- **Research Inputs**: `specs/978_review_pr11_pointed_semantic_lemmas/reports/01_review-pr11-pointed-semantic-lemmas.md`
- **Artifacts**: plans/01_review-pr11-pointed-semantic-lemmas.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

The review this task was created to produce has already been produced *and acted on*. The
research round wrote the draft at `specs/reviews/pr-reviews-2026-11-21/pr11-review.md`; a later
session condensed it into `pr11-comment.md`; and the user posted that text verbatim to GitHub as
a `CHANGES_REQUESTED` review at `2026-11-23T01:57:16Z`. What remains is not review work but
record work: the two durable artifacts were written while #7 was still open and while the four
rulings were still open, and both are now stale in ways that the downstream reconciliation task
(982) will read directly. This plan reconciles them against live state, closes each ruling with
the disposition the user actually chose, gives every named follow-up a home or an explicit gap,
and closes the task. **No Lean file is touched and no build is run** — the gate evidence the
research measured is correctly scoped to commit `c6cd983b7` and does not need re-running, and the
rebase the posted review asks for is the contributor's move, not ours.

### Carried-Figure Check (dispatch description vs. prior artifact vs. live state)

Required by the dispatch's Premise Re-Validation block. Each trigger-class claim in the
description, checked at plan time (2026-11-22, local):

| Claim in the description | Status | Evidence |
|---|---|---|
| head `c6cd983b7` when filed | **CONFIRMED, still current** | `gh pr view 11 --json headRefOid` → `c6cd983b79842368ae789488d38e488656f98992` |
| base `main`, +793 lines | **CONFIRMED** | `gh pr view 11` → `baseRefName: main`, `additions: 793`, `deletions: 12`, `changedFiles: 14` |
| "CI was green" | **CONFIRMED at research time, NOT re-checked now** | research report finding 1 (`gh pr checks 11`, "Build and Test" pass, 25m50s); the base has since moved, so a green check at that commit no longer predicts a green check after rebase |
| "no sorry"; lemmas over the clause classes; `assert_not_exists` present | **CONFIRMED by research** | report findings 1, 2, 5 (C3 PASS, 58/58 invariants, three `assert_not_exists` spellings) |
| deliverable "a draft review at `specs/reviews/pr-reviews-2026-11-21/pr11-review.md`" | **EXISTS, and is superseded in use** | file present (10993 bytes); the posted text is the derived `pr11-comment.md` |
| **CHANGED since the description was written** | | |
| PR #7 was open | **now MERGED** | `gh pr list --state all` → `7 MERGED feat/proof-mode-rewriting 2026-11-22T22:58:00Z` |
| #11 `mergeable: MERGEABLE` (research risk section) | **now `CONFLICTING`** | `gh pr view 11 --json mergeable`; this is exactly the collision the report's finding 8 predicted |
| the review was unposted | **now POSTED** | `gh pr view 11 --json reviews` → author `benbrastmckie`, state `CHANGES_REQUESTED`, `submittedAt 2026-11-23T01:57:16Z`; body differs from `pr11-comment.md` by one blank line only |

### Research Integration

The research report is complete and its findings are not re-derived here. Three of its results
drive this plan directly: (i) the four "Items Needing the User's Ruling" are all now answered by
the posted review, so they must stop reading as open; (ii) finding 8's merge-mechanics paragraph
was written with #7 open and is now the live cause of the `CONFLICTING` state; (iii) the report's
context-extension recommendation (a `review-worktree-setup.md`) names a `.claude/**` path, which
cannot be authored in this repository — see Non-Goals.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was provided in this dispatch and no `roadmap_flag` is set; Stages 2.5/2.6 are
skipped and no roadmap phases are added.

### Lean4 Plan-Authoring Gate Collisions

`context/project/lean4/patterns/plan-authoring-gate-collisions.md` was read before decomposition.
Disposition of each condition for this plan:

- **Conditions 1, 5, 6, 7, 8, 9 — do not apply.** No `.lean` path is touched, so the pre-commit
  hook on `typst/generated/status.typ` is a fast no-op, no inventory block goes stale, no upward
  import is added, no `def`/`abbrev` is named, no file crosses `longFile`, no `show` is written.
- **Condition 2 — honored.** The final phase's gate language names a deploy-tree root and
  distinguishes findings on this task's own touched files from the tree's standing baseline.
- **Condition 3 — not applicable.** No "matches nothing" sweep is authored.
- **Condition 4 — honored.** Every verification criterion below is scoped to the files the phase
  modifies, never stated as a repo-wide absolute zero.

## Goals & Non-Goals

**Goals**:
- Record, with live evidence, the disposition of PR #11: head unchanged, review posted, base
  moved, mergeable now `CONFLICTING`.
- Make `pr11-review.md` and the research report agree with what was actually posted, so task 982
  can consume them without re-deriving the round.
- Give each of the six "after the merge" follow-ups in the posted review a named task or an
  explicit "no task yet" line.
- Record the review worktree and its warm-`.lake` setup so the post-rebase re-review can reuse it.
- Close the task with a summary.

**Non-Goals**:
- Posting, merging, pushing, approving, or commenting on any pull request. The review is already
  posted by the user; nothing further goes to GitHub from this task (`rules/pr-prohibition.md`).
- Re-running the Lean gate battery. The research ran the full `check-module-invariants.sh`,
  `--wfail` build, and 52 `#print axioms` at `c6cd983b7`; that evidence is correctly scoped to
  that commit and is not improved by repetition. Re-measuring after a rebase is the contributor's
  move under condition 1 of the posted review.
- Rebasing the PR, resolving its conflicts, or regenerating `FormalSystem.lean`, the READMEs or
  `typst/generated/status.typ`. Those are the contributor's.
- Updating `records/milestones.md`, `records/proof-mode-architecture.md`, or other task
  descriptions. **Task 982 explicitly owns that** ("Run this after the four review tasks have
  reported AND the user has acted on them"); duplicating it here would collide.
- Creating follow-up tasks. The gaps are reported for the user to act on with `/task`.
- Writing anything under `.claude/**`. The research's `review-worktree-setup.md` recommendation
  targets the lean extension, whose `source_dir` is
  `/home/benjamin/.config/nvim/agent-system/extensions/lean` — a different repository with no
  on-disk `agent-system/` here. Per `rules/source-store-deploy-boundary.md`'s Task Siting
  subsection, that task must be created in the repository that holds the source store; this plan
  only names it.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| The PR head moves between plan time and implementation | H | L | Phase 1's first step re-reads `headRefOid`; if it has moved, ground rule (ii) applies and the phase stops and reports rather than editing a record that would then misdescribe the review |
| A sibling task (979, 980) edits `FOLLOWUP.md` concurrently | M | M | `FOLLOWUP.md` is in no sibling's declared `file_scope`; Phase 3 re-reads it immediately before a single anchored edit and no-ops if a sibling already recorded the posting |
| Appending a disposition destroys the evidence the rulings rested on | M | L | Every edit is additive and annotates in place; the original findings, options, and measurements stay readable |
| `specs/reviews/**` is excluded in `.git/info/exclude`, so review-draft edits cannot be committed | L | H (certain) | Expected, not a gap: `git-commit-scoped.sh` reports a non-failure skip for excluded members; commits cover `specs/978_*/**` only |
| `verify-touched.sh` derives scope from the whole working tree and attributes siblings' uncommitted `specs/` edits to this dispatch | M | H | Phase 3 passes this task's paths explicitly rather than letting derivation run, and reads the standing agent-system suite failures in this deploy-only tree as baseline, per condition 4 |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |

Phases within the same wave can execute in parallel; this plan is strictly serial.

### Phase 1: Record the live disposition of PR #11 [COMPLETED]

**Goal**: Establish, from live commands rather than from the research report, what changed
between the research round and now, and append it to the report as a dated disposition section.

**Tasks**:
- [x] Re-read live PR state: `gh pr view 11 --json number,state,headRefOid,baseRefName,mergeable,additions,deletions,changedFiles,updatedAt,reviews`. Record `headRefOid`, `state`, `mergeable`, and the review's author / `state` / `submittedAt`.
- [x] **Escalation check**: if `headRefOid` is no longer `c6cd983b79842368ae789488d38e488656f98992`, STOP editing records. Ground rule (ii) requires the new commits be reviewed; report the mismatch in the handoff (`status: blocked`) with the new SHA and what moved, and do not append a disposition that would misdescribe the posted review.
- [x] Confirm the base moved: `gh pr view 7 --json state,mergedAt,mergeCommit` and `git fetch origin main --quiet && git log --oneline -3 origin/main`. Record #7's merge commit and time.
- [x] Diff the posted review body against the local draft: `gh pr view 11 --json reviews --jq '.reviews[0].body'` against `specs/reviews/pr-reviews-2026-11-21/pr11-comment.md`, whitespace-normalized. Record the result (at plan time: identical but for one blank line).
- [x] Append a `## Disposition (2026-11-22)` section to the research report recording: the posted review (author, `CHANGES_REQUESTED`, `submittedAt`, its three conditions in one line each); head unchanged at `c6cd983b7`; `mergeable` now `CONFLICTING` because #7 merged, which is finding 8's predicted collision arriving; and that the report's "The head could move before the user posts" risk is now closed by the posting.
- [x] In that same section, state the scope of the gate evidence explicitly: the `--wfail` build, the 58/58 `check-module-invariants.sh` pass and the 52 axiom sets were measured at `c6cd983b7` against the pre-#7 base, remain true *of that commit*, and are not evidence about the rebased tree condition 1 asks for.
- [x] Record one `issue-record.sh` entry for the premise shift found here (the task's deliverable was produced and acted on before this phase ran).

**Timing**: 20 minutes

**Depends on**: none

**Verification Tier**: prose

**Scope Hypothesis**: The PR #11 head is still `c6cd983b79842368ae789488d38e488656f98992` and
the `CHANGES_REQUESTED` review of `2026-11-23T01:57:16Z` is the only review on it — both measured
at plan time. Confirm with `gh pr view 11 --json headRefOid,reviews` as this phase's first step;
if either has moved, take the escalation task above instead of proceeding.

**Tier Justification**: Every touched path is a `specs/**` report artifact for which
`suite_selection_select` returns `__FULL_SWEEP__` (no mapped suite), so plan-format's `specs/**`
sub-case (a) applies and `bash .claude/scripts/validate-artifact.sh specs/978_review_pr11_pointed_semantic_lemmas/reports/01_review-pr11-pointed-semantic-lemmas.md report`
plus the `prose` row's diff read-through is the covering check.

**Files to modify**:
- `specs/978_review_pr11_pointed_semantic_lemmas/reports/01_review-pr11-pointed-semantic-lemmas.md` - append a dated `## Disposition` section; existing findings left intact

**Verification**:
- The appended section names a `headRefOid`, a review `submittedAt` and a `mergeable` value that each match the output of a command re-run in this phase, quoted in the phase's own notes.
- `bash .claude/scripts/validate-artifact.sh specs/978_review_pr11_pointed_semantic_lemmas/reports/01_review-pr11-pointed-semantic-lemmas.md report` exits 0.
- Diff read-through confirms every changed hunk is prose appended at the end of the file and that no existing finding, table row or measurement was deleted.

---

### Phase 2: Reconcile the draft and close the four rulings [COMPLETED]

**Goal**: Make `pr11-review.md` and the report's four open rulings agree with the disposition the
user actually chose, so task 982 reads a settled record rather than an open question list.

**Tasks**:
- [x] Append a `## Posted disposition` section to `specs/reviews/pr-reviews-2026-11-21/pr11-review.md` stating that the text posted was the condensed `pr11-comment.md` and mapping each of the draft's eight numbered requests onto its outcome:
  - requests 1 (`At` usability) and 2 (tests) kept, as conditions 2 and 3 of the posted review;
  - a condition the draft did not have — rebase onto `main` and regenerate rather than hand-resolve — added as posted condition 1, because #7 merged after the draft was written;
  - requests 3 (named interval operators) and 4 (`next`/`prev` coincidence rows) moved to follow-ups, assigned to the signature layer (milestone D1, task 977), with the posted instruction "please do not add per-language versions in this PR";
  - requests 5 (module docstring titles), 6 (one `assert_not_exists` spelling), 7 (positive reading for `release_iff`/`trigger_iff`) and 8 (`Point.history` field name) moved to the after-merge list. *(deviation: altered — requests 5, 6 and 7 are on the posted after-merge list as the plan expected, but request 8 is absent from the posted review entirely, in any form; the cross-check caught it and it is recorded under "Not posted at all", together with three other unposted draft pieces, rather than mapped to a follow-up it does not have)*
- [x] Annotate each of the four headings under `## Items Needing the User's Ruling` in the research report with its resolution, directly beneath the heading, leaving the options and measurements intact:
  - ruling 1 (`At`) → resolved as option (a): make it usable, with a test that rewrites a clause under `At`;
  - ruling 2 (interval operators) → resolved as option (a) in substance but **deferred to the signature layer (D1, task 977)**, not asked of this PR;
  - ruling 3 (`next_iff_covBy` promotion) → resolved as option (c), the user's own, now carried by task 984;
  - ruling 4 (merge vs. request changes) → resolved as REQUEST CHANGES, narrowed from four items to three conditions.
- [x] Cross-check that no annotation contradicts the posted text: each resolution line quotes or paraphrases a sentence that is actually in `pr11-comment.md`.

**Timing**: 30 minutes

**Depends on**: 1

**Verification Tier**: prose

**Scope Hypothesis**: The draft carries exactly eight numbered requests (four under "What I am
asking for", four under "Smaller requests") and the report exactly four `### ` ruling headings.
Confirm by counting both before editing (`grep -c` on the heading pattern) and reconcile the
mapping to whatever count is actually found rather than to this estimate.

**Tier Justification**: Both touched paths lie under `specs/**`, where `suite_selection_select`
returns `__FULL_SWEEP__`, so the covering check is plan-format sub-case (a)'s
`bash .claude/scripts/validate-artifact.sh ... report` on the report plus the `prose` row's diff
read-through on the review draft, which is not a report/plan/summary artifact type.

**Files to modify**:
- `specs/reviews/pr-reviews-2026-11-21/pr11-review.md` - append a `## Posted disposition` section mapping the eight requests onto the posted outcome
- `specs/978_review_pr11_pointed_semantic_lemmas/reports/01_review-pr11-pointed-semantic-lemmas.md` - annotate each of the four rulings with its resolution

**Verification**:
- Every numbered request in the draft has exactly one disposition line in the new section, and every `### ` heading under `## Items Needing the User's Ruling` is followed by a resolution line — both confirmed by counting the headings and the disposition lines and comparing the two counts.
- `bash .claude/scripts/validate-artifact.sh specs/978_review_pr11_pointed_semantic_lemmas/reports/01_review-pr11-pointed-semantic-lemmas.md report` exits 0.
- Diff read-through confirms the edits are additive: the draft's original eight requests and the report's four option lists are byte-unchanged.

---

### Phase 3: Follow-up ledger, worktree disposition, and summary [NOT STARTED]

**Goal**: Leave every follow-up the posted review names with a named home or an explicit gap,
record the review worktree for the post-rebase re-review, and close the task.

**Tasks**:
- [ ] For each bullet in the posted review's "After the merge, not conditions of it" list, search `specs/state.json` for a covering task and record the mapping. Known at plan time: named interval operators and the one `next`/`prev` encoding → task 977 (D1); `next_iff_covBy`/`prev_iff_covBy` promotion → task 984; records and task-description reconciliation → task 982. Report as gaps, without creating tasks, any bullet with no home — at plan time: the positive reading for `release_iff`/`trigger_iff`; the module docstring titles and the single `assert_not_exists` spelling; L⁻ `allFuture_persist`/`allPast_persist`; L⋆ time-shift and state-local transport factories.
- [ ] Record the review worktree in the summary: `/home/benjamin/Projects/.worktrees/BimodalLogic-pr11`, detached at `c6cd983b7`, `.lake/packages` symlinked to the main tree and `build/lib` + `build/ir` real-copied, `.lake/build-guard.*` deliberately not copied. **Keep it** — condition 1 of the posted review will produce a new head to re-review and the warm `.lake` is the expensive part. Confirm with `git worktree list`.
- [ ] Record that the research's `review-worktree-setup.md` context-extension recommendation cannot be authored here: `.claude/**` in this repository is a regenerated deploy artifact and the lean extension's `source_dir` resolves to `/home/benjamin/.config/nvim/agent-system/extensions/lean`, a different repository. Name it as a user follow-up to be created there per `rules/source-store-deploy-boundary.md`'s Task Siting subsection. Write no file under `.claude/**`.
- [ ] Re-read `specs/reviews/pr-reviews-2026-11-21/FOLLOWUP.md` immediately before editing (siblings 979 and 980 are live on this same working tree), then make one anchored edit recording that item 1, `pr11-comment.md`, was posted at `2026-11-23T01:57:16Z` as `CHANGES_REQUESTED`. If a sibling has already recorded it, leave the file unchanged and say so in the summary. Do not restructure the file; items 2 and 3 belong to task 979.
- [ ] Write `specs/978_review_pr11_pointed_semantic_lemmas/summaries/01_review-pr11-pointed-semantic-lemmas-summary.md`: what was reviewed and at which commit, the posted disposition, the follow-up ledger with its gaps, the worktree, and an explicit statement of what was *not* verified in this round (no rebase, no re-build, CI not re-checked after #7's merge).
- [ ] Commit this task's own artifacts only — `specs/978_review_pr11_pointed_semantic_lemmas/**` — with an explicit file list, never a directory or glob pathspec. `specs/reviews/**` is excluded in `.git/info/exclude`, so a non-failure skip for those members is expected rather than a gap.

**Timing**: 25 minutes

**Depends on**: 2

**Verification Tier**: full

**Files to modify**:
- `specs/978_review_pr11_pointed_semantic_lemmas/summaries/01_review-pr11-pointed-semantic-lemmas-summary.md` - new; the task summary, follow-up ledger and not-verified statement
- `specs/reviews/pr-reviews-2026-11-21/FOLLOWUP.md` - one anchored line recording that item 1 was posted; no-op if a sibling already did it

**Verification**:
- Every bullet of the posted review's after-merge list is followed in the summary by either a task number or an explicit "no task yet" line; counted against the list in `pr11-comment.md`.
- `git worktree list` shows `/home/benjamin/Projects/.worktrees/BimodalLogic-pr11` at `c6cd983b7`, and the summary's worktree paragraph matches that output.
- `bash .claude/scripts/validate-artifact.sh specs/978_review_pr11_pointed_semantic_lemmas/summaries/01_review-pr11-pointed-semantic-lemmas-summary.md summary` exits 0.
- No path under `.claude/**` and no `.lean` path appears in `git status --short` for this task's changes.
- Scoped touched-path check: `bash .claude/scripts/verify-touched.sh` invoked with this task's paths passed **explicitly** (not derived from the tree, which on this shared working tree would attribute siblings' uncommitted `specs/` edits to this dispatch). Read its verdict as a narrowed pass, never as a full-battery pass; findings that name no file this task touched are the tree's standing baseline in this deploy-only repository (notably the agent-system suites that report `mode=source-store` with no local source store) and are a recorded PASS for this phase, not a blocker.
- **Deferral**: the complete gate set is owed once per `/orchestrate` invocation and is discharged at the orchestration close (`context/contracts/batch-gate-stage.md`), not independently by this phase.

---

## Testing & Validation

- [ ] The live `headRefOid`, review `state`/`submittedAt`, and `mergeable` value recorded in the report match a command re-run during implementation, not the values copied from this plan.
- [ ] `validate-artifact.sh` exits 0 for the report (`report`) and the summary (`summary`).
- [ ] Every one of the draft's numbered requests and the report's rulings carries exactly one disposition line.
- [ ] Every after-merge follow-up bullet has a task number or an explicit gap line.
- [ ] No `.lean` file, no `.claude/**` file, and no file belonging to a sibling task's declared `file_scope` is modified.
- [ ] Nothing is posted, pushed, merged or approved on GitHub by this task.

## Artifacts & Outputs

- `specs/978_review_pr11_pointed_semantic_lemmas/reports/01_review-pr11-pointed-semantic-lemmas.md` (amended: disposition section + four ruling resolutions)
- `specs/reviews/pr-reviews-2026-11-21/pr11-review.md` (amended: posted-disposition mapping)
- `specs/reviews/pr-reviews-2026-11-21/FOLLOWUP.md` (one line, conditional)
- `specs/978_review_pr11_pointed_semantic_lemmas/summaries/01_review-pr11-pointed-semantic-lemmas-summary.md` (new)
- A reported list of follow-up gaps with no covering task, for the user to act on with `/task`
- A reported recommendation that `review-worktree-setup.md` be created in the source-store repository

## Rollback/Contingency

Every edit is an append or an in-place annotation to a markdown file under `specs/**`; nothing is
generated, compiled, or pushed, so there is no build state to restore. To revert, remove the
appended sections — `git checkout` the report and summary from the prior commit (the task
directory is tracked), and delete the appended section from `pr11-review.md` and the one line
from `FOLLOWUP.md` by hand, since `specs/reviews/` is excluded from git locally and has no
committed version to restore from. If the PR head has moved, Phase 1's escalation path applies
instead of any rollback: stop, report `blocked`, and let a fresh research round review the new
commits under ground rule (ii).
