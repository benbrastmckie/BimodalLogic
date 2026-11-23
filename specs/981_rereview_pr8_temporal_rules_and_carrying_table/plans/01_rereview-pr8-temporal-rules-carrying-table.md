# Implementation Plan: Task #981

- **Task**: 981 - Re-review PR #8 (temporal rules and the carrying table)
- **Status**: [IMPLEMENTING]
- **Effort**: 1.25 hours
- **Dependencies**: Task 980 (PR #7 re-review) — complete; PR #7 merged as `3c7197f84`
- **Research Inputs**: specs/981_rereview_pr8_temporal_rules_and_carrying_table/reports/01_rereview-pr8-temporal-rules-carrying-table.md
- **Artifacts**: plans/01_rereview-pr8-temporal-rules-carrying-table.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

The research round did both halves of this task's stated work: it established all ten items the
description asks for and it wrote the draft response to `specs/reviews/pr-reviews-2026-11-21/pr8-review.md`
(10,015 bytes, present on disk). What remains is not a second review but a close-out of the
review round for PR #8: re-validate the premise and the head against live state, audit every
claim in the draft against the report that is supposed to back it, produce the condensed body
the user actually posts (the convention every other pull request in this directory already
follows), hand the records half that is *ours* to the reconciliation task rather than to the
contributor, and dispose of the probe worktree and the follow-up ledger so nothing is dropped.
No Lean source is edited, no build is run on the main tree, and nothing is posted, pushed,
merged or approved.

### Research Integration

The report is the evidence base and every claim in the draft must trace to it. The findings this
plan carries forward unchanged are: the rebase route (`git rebase --onto origin/main fc85c61b9`,
seven conflicts, one real source break in `Automation/ProofMode/Temporal.lean`) and the four
green gates measured on the rebased tree; the carrying table's `(past, source)` key being the
thing that must change while its proof-to-proof value shape need not; the altered acceptance
example at `ProofModeTest.lean:128` passing on `main` too and so pinning nothing; and the
eighteen `*_expand` equalities all accepted by `register_lview`. The plan's job is to check the
draft against those findings, not to re-derive them.

The report also leaves one choice explicitly to the user — where the re-keyed carrying table
lives, a shared non-private module (a) or a `register_lcarry` registry mirroring the merged view
table (b). The draft already commits to (a). That is recorded as a non-blocking `user_decision`
rather than silently settled.

### Prior Plan Reference

No prior plan for this task.

### Roadmap Alignment

No `roadmap_path` was supplied in this dispatch and `roadmap_flag` is not set, so no roadmap
consultation was performed and no roadmap phases are added. The sequencing facts this plan
relies on come from `specs/state.json` (tasks 979, 982) and from
`specs/reviews/pr-reviews-2026-11-21/FOLLOWUP.md`.

## Premise Re-Validation (Carried-Figure Discipline)

The dispatch's `## Description` carries figures that the research round already found partly
stale. Checked against the report and against live state before this plan was written; stated
explicitly as the discipline requires, including where the description is confirmed unchanged.

| Carried claim in the description | Live state | Verdict |
|---|---|---|
| "head b020320fd when filed: two commits" | `gh pr view 8 --json headRefOid` returns `49a7efe231cf98a488ad107dd981881557b1fd96`; the PR carries **four** commits in its own layer, the fourth being "File temporal composition and tactics by rule family" (2026-11-22T18:44:07Z) | **superseded** — and the description's `updatedAt` is `2026-11-22T18:44:10Z`, unchanged since the research round |
| "not done: TemporalComposition.lean is not split by family" | the fourth commit lands review request 2 in full | **stale — must not be repeated in the response** |
| "the branch sits on the OLD PR #7 head (fc85c61b9) ... conflicts with main" | `mergeable: CONFLICTING`, `state: OPEN`; `fc85c61b9` still the branch point | **confirmed unchanged** |
| "has had NO CI RUN" | one run exists, `44476857626`, on `1f545ea0a` (three commits behind) and it **failed** on `readme-lint.sh` alone | **refined**: stale CI evidence exists, so "no CI run" is wrong as stated, "no CI run on the head" is right |
| "sixteen fail_if_success against three #guard_msgs" | measured on the rebased tree: **7 `#guard_msgs` against 17 `fail_if_success`** across the eight ProofMode acceptance files; the PR's own three new files contribute 3 and 4 | **superseded by measurement** |
| "prepare a draft response at specs/reviews/pr-reviews-2026-11-21/pr8-review.md" | the file exists, 10,015 bytes, written during the research round | **already produced** — Phase 2 audits it rather than writing it |
| "this task runs after the PR #7 re-review and reads that report first" | task 980 is `completed`; PR #7 merged `2026-11-22T22:58:00Z` as `3c7197f84`; `pr7-review.md` and `pr7-approval.md` were read in the research round | **satisfied** |
| ground rule (ii), "re-check the head with `gh pr view` before finishing" | re-checked at the close of the research round (unchanged) and again while writing this plan (unchanged) | **confirmed; Phase 1 re-checks once more and Phase 4 re-checks last** |

## Goals & Non-Goals

**Goals**:

- Leave `specs/reviews/pr-reviews-2026-11-21/pr8-review.md` with every claim traceable to a
  finding in the report, no stale first-read assertion surviving, and the register of the
  already-posted reviews in `specs/reviews/pr-reviews-2026-11-20/`.
- Give the user a postable body (`pr8-comment.md`), matching the two-file convention that
  `pr11-review.md`/`pr11-comment.md`, `pr10-*` and `pr9-*` already follow in this directory and
  that `FOLLOWUP.md`'s "To post, in order" list indexes.
- Make both halves of the records ask concrete: the contributor-facing half stated verbatim in
  the draft, the half that is ours handed to the records-reconciliation task as ready text
  rather than as prose to be re-derived.
- Record the disposition of the probe worktree and the exact rebase recipe, so the offer in the
  draft can be honoured without re-doing the work.
- Attach the outcome to the task's own durable artifacts (report disposition section, summary)
  and to the follow-up ledger, so the PR #8 response is not dropped between this cycle and the
  posting.

**Non-Goals**:

- **No record edits.** `records/milestones.md`, `records/proof-mode.md`,
  `records/proof-mode-architecture.md` and `records/README.md` are the declared `file_scope` of
  task 982 (`Reconcile the records, the roadmap rules and the open task descriptions with the
  outcome of the review round on collaborator PRs #7 to #11`). This task writes the text 982
  will apply; it applies none of it.
- **No Lean source edits and no main-tree build.** The rebase lives in a probe worktree and
  stays there. The gates quoted in the draft were measured in the research round and are not
  re-run on the main checkout.
- **Nothing posted, pushed, merged or approved** (`.claude/rules/pr-prohibition.md`). The
  deliverable is a draft the user posts and a recommendation the user acts on. The probe branch
  `pr8-rebase-probe` is never pushed.
- **No re-derivation of the M4 induction rule.** The description forbids it; the report
  established only that nothing in the PR bears on it.
- **No ruling on PRs #9, #10 or #11, and no edit to `FOLLOWUP.md`'s items 2 and 3.** Those
  belong to task 979, which is still pending this cycle.
- **No second review pass over the PR's Lean content.** The thirteen-request table is settled in
  the report; Phase 2 checks the draft against it, it does not re-open it.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| The PR head moves again before the response is posted — it moved once mid-task already | H | M | Phase 1 and Phase 4 both re-run `gh pr view 8 --json headRefOid,state,mergeable`; if it has moved, Phase 4 stops, records the new oid in the report disposition and the summary, and marks the draft NOT READY TO POST rather than quietly posting a stale review |
| `FOLLOWUP.md` is in task 979's declared `file_scope` and 979 is `planned` (not yet dispatched) — a concurrent edit could clobber or be clobbered | M | M | Phase 4 re-reads the file immediately before editing, uses anchored `Edit` calls only (never a block rewrite), touches only the `#8` bullet and adds one new numbered item, and on observing any foreign modification aborts the edit and records the intended entry verbatim in the summary instead |
| The draft commits to carrying-table option (a) before the user has ruled between (a) and (b) | M | H | Surfaced as a non-blocking `user_decision` with (a) recommended; the draft is not posted by an agent, so the user sees the commitment before it reaches the contributor; Phase 3 keeps option (b) named in one sentence of the draft so the choice is visible to the contributor too |
| The probe worktree shares `.lake/packages` with the main checkout by symlink | L | L | It was read-only in practice; Phase 4 records its path, branch and sha without removing it, so the green rebase remains available if the offer is taken up |
| `specs/reviews/**` is git-excluded (`.git/info/exclude:20`), so the review deliverables appear in no commit | L | H | Expected, not a gap — stated in the summary; the task's own `specs/981_*/` artifacts are committed normally |
| A verification step invokes a repo-wide gate whose baseline is already red in this tree | M | M | Per `context/project/lean4/patterns/plan-authoring-gate-collisions.md` Condition 4, every verification criterion below is scoped to this task's own touched paths or stated as a delta, never as an absolute repo-wide zero |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 1, 2, 3 |

Phases within the same wave can execute in parallel. This plan is a strict chain: each phase
reads the artifact the previous one left.

---

### Phase 1: Re-validate the Head and the Report's Live Premises [COMPLETED]

**Goal**: Establish, in this dispatch rather than by carrying the research round's word, that the
commit the draft reviews is still the head, and that the three artifacts the later phases edit
exist in the state those phases assume.

**Tasks**:
- [x] Re-run `gh pr view 8 --json headRefOid,state,mergeable,updatedAt` and record the four
      values. The research round and this plan both observed
      `49a7efe231cf98a488ad107dd981881557b1fd96` / `OPEN` / `CONFLICTING` /
      `2026-11-22T18:44:10Z`.
- [x] If the head has moved: stop the normal flow, run `git log --oneline 49a7efe23..<new>` to
      enumerate the new commits, and record them. *(deviation: altered -- the head HAD moved, to
      5ecc91d63, a merge of origin/main; enumerated via `git log --oneline origin/main..5ecc91d63`
      rather than the two-dot form, since the move was a merge rather than new linear commits)* The later phases then proceed only to the
      extent the new commits leave the draft's claims standing; anything they touch is marked
      explicitly as not re-reviewed.
- [x] Re-run `gh run list --branch feat/proof-mode-temporal --limit 5` and confirm the CI
      picture the draft states (one run, on `1f545ea0a`, failed) has not changed.
- [x] Confirm the three files the later phases edit exist and are the ones the report names:
      `specs/reviews/pr-reviews-2026-11-21/pr8-review.md`,
      `specs/981_rereview_pr8_temporal_rules_and_carrying_table/reports/01_rereview-pr8-temporal-rules-carrying-table.md`,
      and `specs/reviews/pr-reviews-2026-11-21/FOLLOWUP.md`. If `pr8-review.md` is absent or
      truncated, Phase 2 becomes an authoring phase rather than an audit phase and says so.
- [x] Confirm the probe worktree is still present and on the sha the report names:
      `git worktree list` should show `/home/benjamin/Projects/.worktrees/BimodalLogic-pr8` on
      branch `pr8-rebase-probe`. Record its current sha.
- [x] Append a dated `## Disposition` heading to the report with the re-checked head, state,
      mergeable value and CI picture. Purely additive — no existing finding, table row or
      measurement is deleted or reworded.
- [x] Record one `issue-record.sh` entry for this phase (a `win` if the head is unchanged and
      every premise holds, an `issue` of class `stale-premise` if the head has moved).

**Timing**: 20 minutes

**Depends on**: none

**Verification Tier**: prose

**Tier Justification**: The only edit is an additive markdown section in a `specs/**` report with
zero compile or elaboration surface; the covering check is a `git diff --stat` on that one file
showing `+N/-0`.

**Scope Hypothesis**: The head is still `49a7efe23` and the worktree is still on
`pr8-rebase-probe` — both observed while this plan was written, both to be re-confirmed by the
`gh pr view` and `git worktree list` calls above rather than assumed. If either differs, that is
a finding for the disposition section, not a failure of this phase.

**Files to modify**:
- `specs/981_rereview_pr8_temporal_rules_and_carrying_table/reports/01_rereview-pr8-temporal-rules-carrying-table.md` - append a dated `## Disposition` section recording the re-checked head, state, mergeable value, CI picture and worktree sha

**Verification**:
- `gh pr view 8 --json headRefOid` output is quoted verbatim in the disposition section, not
  paraphrased.
- `git diff --stat` on the report shows additions only (`+N/-0`).
- The disposition section names every one of: head oid, `state`, `mergeable`, CI run id and its
  conclusion, probe worktree path/branch/sha.

---

### Phase 2: Audit the Draft Against the Report, and Tighten It [COMPLETED]

**Goal**: Make every claim in `pr8-review.md` traceable to a finding in the report, remove any
surviving first-read assertion the research round superseded, and bring the register into line
with the reviews already posted in `specs/reviews/pr-reviews-2026-11-20/`.

**Tasks**:
- [x] Read `specs/reviews/pr-reviews-2026-11-21/pr8-review.md` in full and
      `specs/reviews/pr-reviews-2026-11-20/pr8-review.md` (the review being answered) alongside
      it.
- [x] Build a claim-to-evidence table, as working notes, mapping each factual assertion in the
      draft (file:line citations, measured gate results, counts, the behaviour-before/after
      claim, the eighteen view rows, the `register_lview` acceptance, the axiom check) to the
      report finding that backs it. Any claim with no backing finding is either cut or
      downgraded to an explicit "not verified".
- [x] Check specifically that no stale first-read assertion survives: the draft must not say
      `TemporalComposition.lean` is unsplit, must not say "no CI run" without the
      "on the head" qualifier, and must not repeat the "sixteen against three" counts in place
      of the measured 17-against-7.
- [x] Check each of the thirteen requests of the 2026-11-20 review is accounted for in the
      draft — done, partly done or not done — and that nothing is silently dropped. The report
      records nine done or substantially done; 1, 3, 4 and 13 not done; 8b, 10 and 12 partly.
- [x] Verify ground rule (iii) holds across the draft: add one short explicit paragraph naming
      what was **not** verified (the evidence probes, the `lean_exe` roots, the `typst` compile,
      the M4 derivation, any tactic-cost or term-size measurement), since the report states
      these and the draft currently does not.
- [x] Check ground rule (v): numbered conditions, credit where the work is right, conditions of
      merging clearly separated from follow-ups, and the direct register of the 2026-11-20
      reviews. Fix anything that drifts.
- [x] Apply the resulting edits with anchored `Edit` calls against the existing draft — never a
      whole-file rewrite — so the research round's wording survives wherever it is already
      right. *(deviation: altered — the PR head moved to `5ecc91d63` between planning and this
      dispatch, invalidating more than a quarter of the draft; the phase's own Scope Hypothesis
      names that escalation, so the draft was rewritten rather than anchored-edited, with the
      prior wording preserved in the scratchpad and every surviving paragraph carried over
      verbatim)*
- [x] Record an `issue-record.sh` entry for any claim found unbacked (class `evidence-gap`) or
      a `win` if the audit finds none.

**Timing**: 30 minutes

**Depends on**: 1

**Verification Tier**: prose

**Tier Justification**: Every hunk lands in a git-excluded markdown file under `specs/reviews/`
with no compile surface; the covering check is a read-through of the final draft against the
claim-to-evidence table produced in this same phase.

**Scope Hypothesis**: The draft is assumed to need tightening rather than rewriting — one added
"not verified" paragraph plus a small number of anchored corrections. If the audit finds more
than roughly a quarter of the draft unbacked or stale, the phase escalates to a rewrite and says
so in its commit message and in the summary rather than forcing the small-edit shape.

**Files to modify**:
- `specs/reviews/pr-reviews-2026-11-21/pr8-review.md` - anchored corrections; add an explicit "what was not verified" paragraph; align the register and the done/partly/not-done coverage of all thirteen requests

**Verification**:
- The claim-to-evidence table covers every factual assertion in the final draft, and every row
  names a report section or an explicitly-stated non-verification.
- `grep -n 'TemporalComposition' specs/reviews/pr-reviews-2026-11-21/pr8-review.md` shows no
  surviving "not split by family" claim.
- The draft contains a paragraph naming what was not verified.
- All thirteen requests of `specs/reviews/pr-reviews-2026-11-20/pr8-review.md` are accounted for
  in the draft, checked one by one against that file.

---

### Phase 3: The Postable Body and the Two Halves of the Records Ask [NOT STARTED]

**Goal**: Produce the condensed body the user actually posts, and make both halves of the records
ask concrete — the contributor's half verbatim in the draft, ours handed to the
records-reconciliation task as ready text.

**Tasks**:
- [ ] Write `specs/reviews/pr-reviews-2026-11-21/pr8-comment.md`: the postable condensation of
      the audited draft, in the register and at roughly the length of the comment files already
      in this directory (`pr11-comment.md`, `pr10-comment.md`, `pr9-comment.md`). It keeps the
      credit paragraph, the rebase recipe and the offer, the numbered conditions of merging, and
      the follow-ups as a short list; it drops the long evidence recitations, which stay in
      `pr8-review.md`.
- [ ] In `pr8-comment.md` and in the draft, state condition 4 (the records) in the form the
      contributor can act on directly: the exact sentence to state where the Until and Since
      tactics are described, and the exact open decision to strike, each with its file and
      heading. Keep "leave the induction milestone and Where the work sits to me" explicit.
- [ ] Write `specs/reviews/pr-reviews-2026-11-21/pr8-record-edits.md`: addressed to the records
      reconciliation task, carrying (i) verbatim replacement text for open decision 2 of
      `records/proof-mode-architecture.md:273-285` — fold and unfold name views only, the Until
      and Since derivation steps are `expand` and `contract`; (ii) verbatim text striking open
      decision 3 of `records/milestones.md` and amending the A2 "What to do next" item 1 that
      currently makes the merge contingent on that decision; (iii) a one-line note that these
      are *drafts for task 982 to apply*, not edits made here, and that the contributor is being
      asked for the `proof-mode-architecture.md` half so 982 must check before duplicating it.
- [ ] Keep carrying-table option (b) — a `register_lcarry` registry mirroring
      `FormalSystem/Tactic/FormulaViews.lean` — named in one sentence of the draft, with (a)
      stated as the ask, so the choice is visible rather than silently foreclosed.
- [ ] Record an `issue-record.sh` entry noting the duplication hazard between the contributor's
      records ask and task 982's declared `file_scope` (class `cross-task-overlap`, severity
      `minor`).

**Timing**: 25 minutes

**Depends on**: 2

**Verification Tier**: prose

**Tier Justification**: Two new markdown files and anchored edits to a third, all under
git-excluded `specs/reviews/`, with no compile surface; the covering check is a read-through
against the audited draft plus the line-range confirmation listed under Verification.

**Scope Hypothesis**: The two record edits are assumed to sit at
`records/proof-mode-architecture.md:273-285` (open decisions) and at the open-decision-3 and A2
"What to do next" blocks of `records/milestones.md`, per the report's §5. The implementer
confirms both line ranges by reading those files before quoting them — read-only; neither file is
edited here.

**Files to modify**:
- `specs/reviews/pr-reviews-2026-11-21/pr8-comment.md` - new; the postable condensation
- `specs/reviews/pr-reviews-2026-11-21/pr8-record-edits.md` - new; verbatim record-edit text for task 982
- `specs/reviews/pr-reviews-2026-11-21/pr8-review.md` - condition 4 made verbatim-actionable; option (b) kept named in one sentence

**Verification**:
- `pr8-comment.md` exists, is non-empty, carries the numbered conditions of merging and the
  rebase recipe, and is shorter than `pr8-review.md` (`wc -c` on both).
- `pr8-record-edits.md` quotes the two record locations with file and line, confirmed by reading
  `records/proof-mode-architecture.md` and `records/milestones.md` in this phase.
- Neither `records/proof-mode-architecture.md` nor `records/milestones.md` appears in
  `git status --short` — this phase is read-only on `records/`.
- The draft names carrying-table option (b) at least once.

---

### Phase 4: Ledger, Worktree Disposition, Summary and Close-Out [NOT STARTED]

**Goal**: Attach the outcome to the follow-up ledger and to the task's own durable artifacts, and
leave the probe worktree recorded rather than orphaned.

**Tasks**:
- [ ] Re-run `gh pr view 8 --json headRefOid,state,mergeable` one final time (ground rule ii).
      If the head has moved since Phase 1, mark the draft NOT READY TO POST in its own first
      line and in the summary, naming the new oid and the unreviewed commits.
- [ ] Re-read `specs/reviews/pr-reviews-2026-11-21/FOLLOWUP.md` **immediately before editing it**
      and compare against the copy read in Phase 1. If it has changed in any way other than by
      this task's own hand, abort the edit, record the intended entry verbatim in the summary,
      and record an `issue-record.sh` entry of class `cross-task-overlap`.
- [ ] If clear: two anchored `Edit` calls only — add one numbered item to "To post, in order"
      for `pr8-comment.md` (request changes; the three conditions), and replace the stale "#8
      temporal: Tanner's move ... Re-review after the rebase: `/orchestrate 981 --research`"
      bullet under "Related, not in the three" with the re-review's outcome. Items 2 and 3 of
      the post list, and every "Decided"/"Still open" bullet about #9, #10 and #11, are task
      979's and are not touched.
- [ ] Record the probe worktree's disposition: path, branch, head sha, what it contains (the
      rebase plus one extra commit of this review's own restoring the test imports), and the
      instruction that if the rebase offer is taken up it is redone cleanly on a fresh branch
      rather than pushed from the probe. Do not remove the worktree — the green tree is the
      evidence behind the offer. Record it in the summary and in the report disposition section.
- [ ] Write `specs/981_rereview_pr8_temporal_rules_and_carrying_table/summaries/01_rereview-pr8-temporal-rules-carrying-table-summary.md`
      per `summary-format.md`: what changed, the live PR state measured in this dispatch, the
      recommendation (REQUEST CHANGES with three conditions), the follow-ups and their owners,
      the open ruling on the carrying table's siting, and a plain statement that
      `specs/reviews/**` is git-excluded so those files appear in no commit.
- [ ] Commit this task's own `specs/981_*/` artifacts with `git-commit-scoped.sh`, staging an
      explicit file list only — never a directory or glob add. Sibling tasks are live on this
      same tree.
- [ ] Record a closing `issue-record.sh` entry for the phase; if nothing noteworthy arose,
      attest that explicitly in the summary prose rather than recording nothing silently.

**Timing**: 25 minutes

**Depends on**: 1, 2, 3

**Verification Tier**: full

**Files to modify**:
- `specs/981_rereview_pr8_temporal_rules_and_carrying_table/summaries/01_rereview-pr8-temporal-rules-carrying-table-summary.md` - new; the close-out summary
- `specs/981_rereview_pr8_temporal_rules_and_carrying_table/reports/01_rereview-pr8-temporal-rules-carrying-table.md` - extend the disposition section with the worktree disposition and the final head re-check
- `specs/reviews/pr-reviews-2026-11-21/FOLLOWUP.md` - two anchored edits (one new post-list item, one replaced `#8` bullet), guarded by an immediate re-read; aborted and recorded in the summary instead if a concurrent modification is observed
- `specs/reviews/pr-reviews-2026-11-21/pr8-review.md` - a NOT READY TO POST marker, only if the final head re-check shows the head has moved

**Verification**:
- `gh pr view 8 --json headRefOid` run in this phase, its output quoted in the summary, and the
  draft's readiness stated accordingly.
- `FOLLOWUP.md` shows exactly two changed hunks attributable to this task
  (`git diff` is unavailable — the path is git-excluded — so the check is a before/after read of
  the two anchored regions plus confirmation that items 2 and 3 and every #9/#10/#11 bullet are
  byte-unchanged), or the summary records the abort and the intended entry verbatim.
- The summary exists, is non-empty, and names: the reviewed commit, the recommendation, the
  three conditions, the follow-ups with owners, the worktree path/branch/sha, and the
  git-exclusion note.
- **Scoped touched-path check**, per
  `context/project/lean4/patterns/plan-authoring-gate-collisions.md` Condition 4: run the
  repository's verification on this task's own touched paths only
  (`specs/981_rereview_pr8_temporal_rules_and_carrying_table/**`), and report any finding that
  does **not** name one of those paths as the tree's standing baseline rather than as this
  task's regression. This tree has a known standing baseline (`test-roadmap-generation.sh` fails
  for want of an on-disk `agent-system/` source store; `verify-touched.sh` attributes sibling
  tasks' uncommitted `specs/TODO.md`, `specs/events.jsonl` and `specs/state.json` to the running
  dispatch). No Lean line count changes in this task, so neither generated surface of Condition
  1 is tripped — `scripts/check-module-invariants.sh` and `scripts/typst-sync-check.sh` have
  nothing to regenerate here, and that is stated rather than assumed.
- **Deferral to the orchestration close**: under `/orchestrate`, the complete gate set is owed
  once per orchestration invocation and is discharged at the orchestration close (Move 4), not
  re-run independently by this phase. This phase's own obligation is the scoped touched-path
  check above plus this explicit deferral.
- `git status --short` before the commit, and `git diff --staged` after staging, both reviewed;
  no file outside this task's own `specs/981_*/` tree is staged.

---

## Testing & Validation

- [ ] The reviewed commit named in the draft equals the live `headRefOid` at the moment the
      draft is declared ready, or the draft says plainly that it does not.
- [ ] Every factual claim in `pr8-review.md` traces to the research report or is explicitly
      flagged as unverified.
- [ ] All thirteen requests of `specs/reviews/pr-reviews-2026-11-20/pr8-review.md` are accounted
      for in the response.
- [ ] `pr8-comment.md` is postable as written: no placeholder, no internal task reference, no
      agent-facing language.
- [ ] `records/` is untouched by this task (`git status --short` shows no `records/` path).
- [ ] Nothing was posted, pushed, merged or approved; the probe branch was not pushed.
- [ ] The task's own `specs/981_*/` artifacts are committed; `specs/reviews/**` is not, and the
      summary says why.

## Artifacts & Outputs

- `specs/reviews/pr-reviews-2026-11-21/pr8-review.md` — the audited full draft response.
- `specs/reviews/pr-reviews-2026-11-21/pr8-comment.md` — the postable condensed body.
- `specs/reviews/pr-reviews-2026-11-21/pr8-record-edits.md` — verbatim record-edit text for task
  982.
- `specs/981_rereview_pr8_temporal_rules_and_carrying_table/reports/01_rereview-pr8-temporal-rules-carrying-table.md`
  — extended with a dated disposition section.
- `specs/981_rereview_pr8_temporal_rules_and_carrying_table/summaries/01_rereview-pr8-temporal-rules-carrying-table-summary.md`
  — the close-out summary.
- `specs/reviews/pr-reviews-2026-11-21/FOLLOWUP.md` — one new post-list item and one corrected
  `#8` bullet (guarded; may be recorded in the summary instead).

## Rollback/Contingency

Every edit in this plan is additive or anchored markdown in `specs/**`. Rollback is per-file and
needs no snapshot:

- `specs/981_*/` files are committed per phase, so any phase can be undone by reverting its own
  commit.
- `specs/reviews/**` is git-excluded and therefore not revertible by git. The contingency is
  that Phase 2 edits the existing draft with anchored `Edit` calls rather than rewriting it, and
  Phase 3's two new files are additive — so the worst case is deleting the two new files and
  re-reading the draft's prior wording from this plan's claim-to-evidence notes.
- `FOLLOWUP.md`'s guard is the rollback: on any observed foreign modification the edit is not
  attempted at all and the intended text goes into the summary.
- The probe worktree is left in place. If it must go,
  `git worktree remove /home/benjamin/Projects/.worktrees/BimodalLogic-pr8` plus deleting the
  `pr8-rebase-probe` branch reverses it, at the cost of having to redo the rebase to honour the
  offer.
- If Phase 1 finds the head has moved, the contingency is not a rollback but a scope statement:
  the draft is marked NOT READY TO POST, the new commits are enumerated, and a follow-up round
  is named rather than the draft being quietly posted against a stale commit.
