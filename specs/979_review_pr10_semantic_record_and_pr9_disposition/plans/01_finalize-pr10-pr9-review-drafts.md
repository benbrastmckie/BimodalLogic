# Implementation Plan: Task #979

- **Task**: 979 - Review PR #10 (semantic proof mode record) and settle the disposition of PR #9
- **Status**: [IMPLEMENTING]
- **Effort**: 2.5 hours
- **Dependencies**: None (sibling tasks 978 and 980 run concurrently on disjoint files)
- **Research Inputs**: `specs/reviews/pr-reviews-2026-11-21/pr10-review.md`,
  `specs/reviews/pr-reviews-2026-11-21/pr9-disposition.md`
- **Artifacts**: plans/01_finalize-pr10-pr9-review-drafts.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

The research round already produced both deliverables this task owes
(`pr10-review.md`, `pr9-disposition.md`) and a later working session produced the two drafts that
are actually posted (`pr10-comment.md`, `pr9-comment.md`) plus a posting checklist
(`FOLLOWUP.md`). Since those reports were written, PR #7 merged (`3c7197f84`), the records were
rewritten (`b63de1dd9`: D4 added, D1 extended, C3 reworded, join 7 rewritten), the PR #11 review
reported with the lemmas-only control result the PR #10 report could not read, and every open
ruling the report posed was decided. The reports are therefore stale in specific, enumerable
places — including three citations to "Open decision 4 of `records/milestones.md`" that now
resolve to a different decision. The work remaining is to reconcile the two reports with the
state the records and the pull requests are actually in, give the two posting drafts a final read
with every citation re-resolved, re-check both PR heads, and hand the result to the user to post.
Done when the four files agree with each other and with the records, every record citation in
them resolves, and the heads are confirmed. Nothing is posted, pushed, merged or closed by an
agent.

### Research Integration

- `pr10-review.md` (research round, dispatch 2) carries the three ruling items, the COMMENT
  recommendation, and the evidence for all seven dispatch checks. Its preamble (lines 9-12)
  explicitly records that the PR #11 review had not reported and that its lemmas-only control
  could not be read; that report now exists at
  `specs/reviews/pr-reviews-2026-11-21/pr11-review.md`, and the control result (13 tactic lines
  for the reference proof of `refute_allFuture_stab`, 13 for the tightest version using PR #11's
  lemmas) is already carried in `pr10-comment.md`.
- `pr9-disposition.md` carries the inventory, the close recommendation, and a draft closing
  comment. Its draft comment says `ProofModeSoundness.lean` carries forward unchanged; the
  decided position in `pr9-comment.md` is that its *content* becomes one soundness statement over
  `TruthEnv` (milestone D4) and the file itself need not come back. The report has to be brought
  onto the decided position so the two do not disagree.
- The decisions recorded in `FOLLOWUP.md` ("Decided") are the rulings on this report's three
  ruling items and on the five open points; the report should record them as settled rather than
  continue to present them as open.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was provided in the delegation context and no `roadmap_flag` is set, so no
roadmap phases are added. `state.json` carries a `roadmap_annotation` for this task — "#10 still
owes an open-decisions section, an adoption threshold and scope sentences" — which is exactly the
content of `pr10-comment.md`'s three numbered asks; this plan does not change that annotation.

## Goals & Non-Goals

**Goals**:
- Bring `pr10-review.md` and `pr9-disposition.md` (this task's declared `file_scope`) onto the
  current state: PR #7 merged, the records as rewritten in `b63de1dd9`, the PR #11 review
  available, the rulings taken.
- Re-resolve every `records/*.md` citation in all four files against the records as they now
  stand, in particular the open-decision numbering.
- Give `pr10-comment.md` and `pr9-comment.md` their final read, in the register of
  `specs/reviews/pr-reviews-2026-11-20/`, so the user can post them unchanged.
- Re-check both PR heads immediately before handing off, and report any movement.

**Non-Goals**:
- Posting, commenting, closing, merging, approving or pushing anything on GitHub. The deliverable
  is a draft the user posts (`.claude/rules/pr-prohibition.md`).
- Editing `records/*.md`. The record changes this task's comments cite already landed in
  `b63de1dd9`; if a citation does not resolve, the fix is to the citing comment, not to the
  record.
- `pr11-comment.md` / `pr11-review.md` (task 978) and `pr7-review.md` / `pr7-approval.md`
  (task 980). Those are concurrent siblings' territory.
- Re-reviewing PR #10's or PR #9's diff from scratch. The reviews stand; this is reconciliation.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| A concurrent sibling (978, 980) edits `FOLLOWUP.md`, the one shared file, while this task does | M | M | Phase 4 re-reads `FOLLOWUP.md` immediately before editing, changes only the sentences naming #10/#9, never rewrites a block, and stages nothing by directory or glob. If a foreign modification is observed, stop and report rather than merging it silently. |
| `specs/reviews/` is excluded from git locally (`.git/info/exclude:20:/specs/reviews/`), so none of these edits can be committed | L | H (certain) | Expected, not a failure: `git-commit-scoped.sh` reports a non-failure skip (exit 8/9) for ignored members. Do not treat it as a commit failure and do not attempt to force-add. The task's own `specs/979_*/**` bookkeeping remains committable normally. |
| A PR head moved since `bdaa3b6d0` / `b3d8f646344c95ba28130b3dafda0d812d371600` | M | L | Phase 4 re-checks with `gh pr view`; if moved, say so in the report, review the new commits, and do not hand off a draft written against a superseded head. |
| Over-correcting the reports into a second copy of the comments | M | M | The reports are the backing evidence; the comments are what is posted. Reconcile the reports' *facts and citations*, record the rulings taken, and leave the argument structure (options, recommendations, evidence) intact. |
| Verification noise: `verify-touched.sh` derives touched paths from the whole working tree, so concurrent siblings' uncommitted `specs/TODO.md`, `specs/state.json` and `specs/events.jsonl` edits pull in the agent-system shell battery, which has a standing ~11-of-95 baseline failure in this deploy-only tree | L | H | Read such failures as the known baseline; check whether any failing suite reads a file this task edited before treating one as a regression. |

## Decisions

- **The reports are reconciled, not rewritten.** `pr10-review.md` and `pr9-disposition.md` are
  this task's declared `file_scope` and the durable record of what was checked; they keep their
  structure and get their stale facts, citations and now-settled rulings corrected in place.
- **The posting drafts are in scope even though they are not in the declared `file_scope`.**
  `pr10-comment.md` and `pr9-comment.md` are PR #10 / PR #9 territory, which is this task's, and
  are claimed by no sibling (978 declares `pr11-review.md`, 980 declares `pr7-review.md`). They
  are declared in the phases below.
- **Citation drift is fixed in the citing file, never in the record.** Where a report cites "Open
  decision 4 of `records/milestones.md`" for the evaluator-beside-the-lemmas question, the
  current milestones record puts that question at open decision 2 and gives decision 4 to the
  signature-layer timing question. The report is corrected.

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 1, 2 |
| 3 | 4 | 3 |

Phases within the same wave can execute in parallel.

### Phase 1: Reconcile `pr10-review.md` with the merged-#7 state, the PR #11 control, and the current records [COMPLETED]

**Goal**: `pr10-review.md` states facts that are true today, cites decisions that resolve, and
records the rulings that were taken on its three ruling items.

**Tasks**:
- [x] Re-read `specs/reviews/pr-reviews-2026-11-21/pr10-review.md` in full and
      `specs/reviews/pr-reviews-2026-11-21/pr11-review.md`, in case a sibling has changed either.
      *(completed: neither had been touched by a sibling)*
- [x] Replace the preamble caveat (the sentences at lines 9-12 saying the PR #11 review had not
      reported and its lemmas-only control could not be read) with the result now available: cite
      `pr11-review.md` and the control measurement for `refute_allFuture_stab` (reference proof 13
      tactic lines; tightest version over PR #11's lemmas also 13), and say what that does to
      ruling item 3's threshold argument — the saving has to come from the evaluator, not the
      lemmas. *(completed)*
- [x] Re-resolve the open-decision citations against `records/milestones.md` as it now stands
      (open decision 2 = "Evaluator with the lemmas or in a mode of its own?"; open decision 4 =
      whether the signature layer lands before or after the temporal contribution): the three
      occurrences of "Open decision 4" at lines 97, 153 and 246 all mean the evaluator question
      and must become decision 2. Check the surrounding claim at line 155 about an open decision
      2 that recorded "who writes the record first?" — that decision is no longer in the record's
      list; either re-ground the claim on something that is in the current record or drop it.
      *(completed: all three resolved to decision 2; the "who writes first" claim re-grounded on
      C2's own Channel column, "T drafts, B reviews", since no numbered open decision carries it
      any longer)*
- [x] Correct every description of PR #7 as in flight: it is merged (`3c7197f84`, "Add checked
      rewriting and bounded simplification (#7)"). Affects at least the sentences at lines 104 and
      253-255 about the syntax/positions/views move to `FormalSystem/Tactic/`. *(completed; also
      corrected the equivalent passage inside the Evidence §1 drafted block)*
- [x] Under each of the three "Items for your ruling", record the ruling taken (from
      `FOLLOWUP.md`'s "Decided" list: the `## Open decisions` section is asked for with drafted
      text; the Until/Since gap is named rather than filled; the threshold is by source tokens, at
      least three of the four clients, stated as revisable), as a short "Ruled:" line under the
      existing options — do not delete the options or the recommendation. *(completed)*
- [x] Re-read the drafted `## Open decisions` block inside Evidence §1 against the block actually
      drafted in `pr10-comment.md`, and make the report's copy match the one that will be posted.
      *(completed: replaced wholesale, now word-for-word identical to `pr10-comment.md`'s block;
      also corrected the §6 "Where the soundness adapter lives" bullet, which still recommended
      the now-superseded "carry ProofModeSoundness.lean forward unchanged" position)*

**Timing**: 45 minutes

**Depends on**: none

**Verification Tier**: prose

**Tier Justification**: `suite_selection_select` over this phase's `Files to modify` set returns
`__FULL_SWEEP__` only (no suite covers it) and the path lies entirely under `specs/**` and is not
a report/plan/summary artifact, so the covering check is the `prose` row's diff read-through
confirming every changed hunk is prose inside this one markdown file.

**Scope Hypothesis**: this phase asserts five specific stale passages (the lines 9-12 preamble;
"Open decision 4" at 97/153/246; the open-decision-2 claim at 155; the PR-#7-in-flight sentences
at 104 and 253-255; the Evidence §1 drafted block). Confirm each by re-reading the file before
editing — line numbers are from a read taken at plan time and shift as edits land; locate each by
its text, not by its line number, and if a passage is not there, say so rather than inventing a
substitute.

**Files to modify**:
- `specs/reviews/pr-reviews-2026-11-21/pr10-review.md` - stale facts, open-decision citations,
  rulings recorded, drafted open-decisions block aligned with the posting draft

**Verification**:
- Diff read-through: every changed hunk is prose in this file, no other file touched.
- `grep -n "Open decision 4\|open decision 4" specs/reviews/pr-reviews-2026-11-21/pr10-review.md`
  returns only occurrences that genuinely mean the signature-layer-timing decision (expected:
  none).
- No sentence remains that describes PR #7 as open or in flight.

---

### Phase 2: Reconcile `pr9-disposition.md` with the merged-#7 state and the decided adapter disposition [COMPLETED]

**Goal**: `pr9-disposition.md` and `pr9-comment.md` tell the same story about what carries
forward from PR #9, and the report's facts about PR #7 are true.

**Tasks**:
- [x] Re-read `specs/reviews/pr-reviews-2026-11-21/pr9-disposition.md` and
      `specs/reviews/pr-reviews-2026-11-21/pr9-comment.md` in full. *(completed: neither had been
      touched by a sibling; mtimes unchanged since this task's earlier read)*
- [x] Correct the PR #7 status in the inventory table (the row at line 42 saying "PR #7 is still
      open but has since evolved past what PR #9 was stacked on") and in option C's wording (line
      65, "once PR #7/#8 ... have moved further"): #7 is merged at `3c7197f84`; #8 is still open
      and conflicting (`49a7efe231cf98a488ad107dd981881557b1fd96`). *(completed; both re-confirmed
      live with `gh pr view 7`/`gh pr view 8`)*
- [x] Bring the `## Draft closing comment` block onto the decided position: the adapter is one
      soundness statement over `TruthEnv` with TM, TM⁺ and TM⋆ as instances (milestone D4 of
      `records/milestones.md`), so `FormalSystem/Metalogic/ProofModeSoundness.lean` contributes
      its *shape and content*, and the file itself need not come back — not "carried over
      unchanged" as the current draft says. The simplest correct move is to replace the block with
      the text of `pr9-comment.md` and mark it as the comment that will be posted; if the report's
      own draft is kept separate, it must not contradict `pr9-comment.md`. *(completed: block
      replaced with `pr9-comment.md`'s text verbatim, confirmed identical by diff)*
- [x] Update `## What was and was not verified`: the task 978 (PR #11) findings, listed there as
      unavailable, are now available at `specs/reviews/pr-reviews-2026-11-21/pr11-review.md`. Keep
      every other "not verified" item as it stands — the line-for-line diff against #7/#8 and the
      PR #9 build against current `main` were not run and are not run by this plan either.
      *(completed: moved into "Verified", citing pr11-review.md directly; the two remaining
      "Not verified" items left unchanged)*

**Timing**: 30 minutes

**Depends on**: none

**Verification Tier**: prose

**Tier Justification**: `suite_selection_select` over this phase's `Files to modify` set returns
`__FULL_SWEEP__` only (no suite covers it) and the path lies entirely under `specs/**` and is not
a report/plan/summary artifact, so the covering check is the `prose` row's diff read-through
confirming every changed hunk is prose inside this one markdown file.

**Scope Hypothesis**: this phase asserts three specific stale passages (the #7 status in the
inventory row and in option C; the draft closing comment's "carried over unchanged" treatment of
`ProofModeSoundness.lean`; the unavailable-978-findings line). Confirm each by re-reading the file
before editing, locating each by its text rather than by the plan-time line number, and report any
that is not there instead of substituting.

**Files to modify**:
- `specs/reviews/pr-reviews-2026-11-21/pr9-disposition.md` - PR #7 status, draft closing comment
  brought onto the D4 adapter position, verification list updated

**Verification**:
- Diff read-through: every changed hunk is prose in this file, no other file touched.
- The report's statement about what carries forward from `ProofModeSoundness.lean` and
  `pr9-comment.md`'s statement agree, read side by side.
- No sentence remains that describes PR #7 as open.

---

### Phase 3: Final read of the two posting drafts [COMPLETED]

**Goal**: `pr10-comment.md` and `pr9-comment.md` are ready for the user to post unchanged — every
citation resolves, every factual claim is backed by something read in this task, and the register
matches the reviews already posted.

**Tasks**:
- [x] Re-read `pr10-comment.md` and `pr9-comment.md` in full, and re-read
      `specs/reviews/pr-reviews-2026-11-20/pr7-followup.md` (and a second posted review in that
      directory) for the register: direct, numbered requests, credit where the work is right,
      conditions of merging separated from follow-ups. *(completed: both drafts already match the
      register — direct address, numbered items, credit given, merge conditions separated from
      optional items; mtimes unchanged since this task's earlier read, no sibling edits)*
- [x] Resolve each record citation in the two drafts against the files on disk: `D4` and the
      soundness-statement-over-`TruthEnv` wording (`records/milestones.md`, Goal D row D4); `D1`
      and its operator-recognition clause reaching L⋆; `B4` and `theorem_library_countermodels`
      (Goal B row B4); the evaluator-beside-the-lemmas assumption (now open decision 2, and the C3
      and C4 rows of Goal C); the adapter bullet in `records/proof-mode-architecture.md`. Where
      `pr10-comment.md` says "`milestones.md` assumes the evaluator sits under
      `FormalSystem/Semantics/` beside the lemmas with the mode a thin tactic layer over it",
      confirm that is what open decision 2 and the C3/C4 rows actually say. *(completed: every
      citation resolves and agrees; D4's row text, D1's "reaches L⋆" clause, B4's Countermodels
      table, open decision 2's exact wording, the C3/C4 rows, and the architecture record's
      adapter bullet were all re-read directly and match what the drafts attribute to them — no
      correction needed to either draft)*
- [x] Confirm the three file paths `pr10-comment.md` names as shared-syntax candidates exist on
      `main` — `FormalSystem/Tactic/FormulaSyntax.lean`, `FormulaViews.lean`,
      `FormulaPositions.lean` — and that `FormulaSyntax.lean`'s operator table does stop at TM⁺,
      which is the premise of its item 3. If it does not, correct the draft. *(completed: all
      three files exist; `FormulaSyntax.lean`'s `elabFormula`/match only handles
      `PlusFormula` constructors, no `StarFormula` case — confirms the TM⁺-only premise; no
      correction needed)*
- [x] Confirm the four client declarations named in the drafts exist and are spelled correctly:
      `refute_allFuture_stab` and `refute_stab_allFuture_past` in `PlusNonValidities.lean`,
      `refute_modal_future` and `refute_sentDet` in `StarNonValidities.lean`. *(completed: all
      four exist under those exact names in those exact files on current `main`)*
- [x] Check both drafts for anything meaningless to an outside collaborator: task numbers, agent
      or orchestration vocabulary, references to `specs/**` paths the collaborator cannot see, and
      draft-history phrasing. These are posted outside the repository even though PR metadata is
      exempt from `.claude/rules/no-task-references-in-deliverables.md`. *(completed: a case-
      insensitive sweep for task-number, specs/-path, agent/orchestration and draft-history
      patterns found nothing in either draft)*
- [x] Note in the drafts, or in the reports, anything asserted that was not independently verified
      in this task, rather than letting it pass as checked. *(completed: `pr10-comment.md`'s
      first-person "I ran the lemmas-only control" claim is a measurement this task read from
      `pr11-review.md`'s reported trial rather than re-running itself; that provenance is now
      recorded in `pr10-review.md`'s preamble, which this draft's claim rests on)*

**Timing**: 45 minutes

**Depends on**: 1, 2

**Verification Tier**: prose

**Tier Justification**: `suite_selection_select` over this phase's `Files to modify` set returns
`__FULL_SWEEP__` only (no suite covers either path) and both lie entirely under `specs/**` and are
not report/plan/summary artifacts, so the covering check is the `prose` row's diff read-through
over the two files.

**Scope Hypothesis**: this phase assumes the two drafts need citation and fact corrections only,
not restructuring. If a citation turns out not to resolve at all — for instance if the record no
longer states what a draft attributes to it — that is a substantive change to the ask, not a
wording fix: record it as an item for the user rather than silently rewriting the request.

**Files to modify**:
- `specs/reviews/pr-reviews-2026-11-21/pr10-comment.md` - citation and fact corrections found in
  the final read
- `specs/reviews/pr-reviews-2026-11-21/pr9-comment.md` - citation and fact corrections found in
  the final read

**Verification**:
- Diff read-through over both files; no file outside this phase's declared set touched.
- Every `records/*.md` reference and every milestone id in the two drafts has been opened and
  resolved, with the resolved location named in the phase's own notes.
- Every Lean declaration and file path named in the drafts was located on `main`.

---

### Phase 4: Citation sweep, PR head re-check, and posting hand-off [NOT STARTED]

**Goal**: the four files agree with each other and with the records, both heads are confirmed
unmoved (or the movement is reported), and the user has a current posting checklist.

**Tasks**:
- [ ] Sweep all four files for record citations and resolve each one against the records as they
      stand: `grep -nE 'records/[a-z-]+\.md|\b[A-F][0-9]+\b|PM-M[0-9]+|[Oo]pen decisions? [0-9]'`
      over `pr10-review.md`, `pr9-disposition.md`, `pr10-comment.md`, `pr9-comment.md`, then open
      each cited location. Report any that does not resolve rather than guessing at a correction.
- [ ] Cross-read the pairs: `pr10-review.md` against `pr10-comment.md`, and `pr9-disposition.md`
      against `pr9-comment.md`. The report is the evidence for the comment; neither pair may
      contradict the other on a fact or a recommendation.
- [ ] Re-check both heads: `gh pr view 10 --json number,state,isDraft,headRefOid,mergeable` and
      the same for 9. Expected `bdaa3b6d0307001794cc8c22fd3cf0a6f4ac1679` (OPEN, draft,
      MERGEABLE) and `b3d8f646344c95ba28130b3dafda0d812d371600` (OPEN, CONFLICTING). If either has
      moved, say so in the corresponding report, review the new commits, and flag the drafts as
      written against a superseded head.
- [ ] Re-read `specs/reviews/pr-reviews-2026-11-21/FOLLOWUP.md` immediately before editing it —
      concurrent sibling tasks 978 and 980 may have changed it this same cycle — then update only
      the sentences that name #10 and #9 (the "Still open" entry for the final read of
      `pr10-comment.md` and `pr9-comment.md`, and the "Backing reports (stale where they call #7
      open)" line, which no longer applies to this task's two reports). Do not rewrite a block, do
      not touch the `pr11-comment.md` entry, and if a foreign modification is observed, stop and
      report it after checking `git log` to confirm the work is not this task's own.
- [ ] Record issues and wins as they arose via `issue-record.sh` per the dispatch's Issue Log
      section; if nothing arose, attest that explicitly in the handoff summary.
- [ ] Commit this task's own `specs/979_*/**` bookkeeping with
      `bash .claude/scripts/git-commit-scoped.sh` and an explicit file list. Expect a non-failure
      skip (exit 8/9) for every `specs/reviews/**` path: that tree is excluded locally
      (`.git/info/exclude:20:/specs/reviews/`). Never `git add -A`, a directory, or a glob, and
      never force-add an excluded path.
- [ ] Hand off: the user posts `pr10-comment.md` (comment) and `pr9-comment.md` (close) in the
      order `FOLLOWUP.md` gives. No agent posts, closes, merges or pushes anything
      (`.claude/rules/pr-prohibition.md`).

**Timing**: 30 minutes

**Depends on**: 3

**Verification Tier**: full

**Scope Hypothesis**: this phase asserts that both PR heads are unmoved
(`bdaa3b6d0307001794cc8c22fd3cf0a6f4ac1679` for #10,
`b3d8f646344c95ba28130b3dafda0d812d371600` for #9, as observed at plan time) and that
`FOLLOWUP.md` needs only its #10/#9 sentences changed. Confirm both by running `gh pr view` and by
re-reading `FOLLOWUP.md` immediately before editing; a moved head or a sibling's intervening edit
changes this phase's outcome and is reported, not worked around.

**Files to modify**:
- `specs/reviews/pr-reviews-2026-11-21/FOLLOWUP.md` - the "Still open" and "Backing reports" lines
  for #10 and #9 only
- `specs/979_review_pr10_semantic_record_and_pr9_disposition/.return-meta.json` - implementation
  return metadata
- `specs/979_review_pr10_semantic_record_and_pr9_disposition/.orchestrator-handoff.json` - handoff

**Verification**:
- Under `/orchestrate`, this phase's own in-dispatch obligation is the scoped touched-path check
  `bash .claude/scripts/verify-touched.sh specs/reviews/pr-reviews-2026-11-21/pr10-review.md specs/reviews/pr-reviews-2026-11-21/pr9-disposition.md specs/reviews/pr-reviews-2026-11-21/pr10-comment.md specs/reviews/pr-reviews-2026-11-21/pr9-comment.md specs/reviews/pr-reviews-2026-11-21/FOLLOWUP.md`,
  plus an explicit deferral of the complete gate set to the orchestration close. Do not invoke an
  independent full battery as this phase's own criterion. A standalone, non-orchestrated run of
  this phase runs the complete gate set directly.
- Known baseline when reading that run: touched paths are derived from the whole working tree, so
  concurrent siblings' uncommitted `specs/` edits pull in the agent-system shell battery, which
  has a standing ~11-of-95 failure in this deploy-only tree. Check whether a failing suite reads a
  file this task edited before calling it a regression.
- `gh pr view` output for both PRs is recorded in the reports, with the exact head oid.
- Every citation found by the sweep has been resolved or reported.

---

## Testing & Validation

- [ ] Every `records/*.md` citation and milestone id in the four files resolves to a location that
      exists and says what the citing sentence claims.
- [ ] No sentence in any of the four files describes PR #7 as open or in flight.
- [ ] `pr10-review.md` and `pr10-comment.md` agree; `pr9-disposition.md` and `pr9-comment.md`
      agree.
- [ ] Both PR heads re-checked with `gh pr view` and recorded with their exact oids.
- [ ] No GitHub write of any kind was performed: no `gh pr comment`, `gh pr close`,
      `gh pr review`, `gh pr merge`, and no `git push`.
- [ ] Diff read-through over every changed file confirms the edits are prose only.
- [ ] Nothing outside this task's territory was edited: not `pr11-review.md` / `pr11-comment.md`
      (task 978), not `pr7-review.md` / `pr7-approval.md` (task 980), not `records/*.md`.

## Artifacts & Outputs

- `specs/reviews/pr-reviews-2026-11-21/pr10-review.md` (reconciled) — this task's declared
  deliverable, the backing review for PR #10.
- `specs/reviews/pr-reviews-2026-11-21/pr9-disposition.md` (reconciled) — this task's declared
  deliverable, the backing disposition for PR #9.
- `specs/reviews/pr-reviews-2026-11-21/pr10-comment.md` (final) — the comment the user posts on
  PR #10.
- `specs/reviews/pr-reviews-2026-11-21/pr9-comment.md` (final) — the closing comment the user
  posts on PR #9.
- `specs/reviews/pr-reviews-2026-11-21/FOLLOWUP.md` (#10/#9 lines updated) — the user's posting
  checklist.
- `specs/979_review_pr10_semantic_record_and_pr9_disposition/summaries/01_*-summary.md` — the
  implementation summary.

## Rollback/Contingency

All five edited files are markdown under `specs/reviews/`, which is excluded from git locally, so
ordinary git revert is not available for them and no snapshot-then-rollback is warranted for a
prose edit. Contingency is per-file and forward-only:

- If a reconciliation turns out to be wrong, correct the sentence in place; the reports' structure
  is never discarded.
- If a PR head has moved, stop short of hand-off, record the movement and the new commits in the
  corresponding report, and return the task as `partial` with the drafts marked as written against
  the superseded head.
- If a concurrent sibling is found to have edited `FOLLOWUP.md` mid-phase, leave that file
  untouched, report the collision, and let the user reconcile the checklist.
- If a record citation cannot be resolved because the record genuinely no longer supports the
  claim, do not invent a replacement: record it as an item needing the user's ruling and return
  `user_decision` rather than a silently rewritten ask.
