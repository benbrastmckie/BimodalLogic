# Implementation Plan: Task #990

- **Task**: 990 - Rereview pr11 at rewriteable pointed truth head
- **Status**: [COMPLETED]
- **Effort**: 2 hours
- **Dependencies**: None
- **Research Inputs**: `specs/990_rereview_pr11_at_rewriteable_pointed_truth_head/reports/01_rereview-pr11-at-usability-and-tests.md`
- **Artifacts**: plans/01_approve-pr11-and-update-followup.md (this file)
- **Standards**:
  - .claude/context/formats/plan-format.md
  - .claude/context/standards/status-markers.md
  - .claude/context/standards/artifact-management.md
  - .claude/context/formats/tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

The re-review of PR #11 at head `b2eb3ac0b` is already measured and settled: all three posted
conditions are met, the gates are green in a from-scratch review worktree, and the verdict is
approve. What remains is to turn that verdict into the two prose deliverables the task names — a
draft approval body in `specs/reviews/pr-reviews-2026-11-21/` and an updated entry in that
directory's `FOLLOWUP.md` — after re-confirming the head has not moved again. No Lean source, no
generated surface and no repository code is touched; nothing is posted, pushed, merged or
approved by the agent. Done means: the head is re-confirmed at the pinned sha, a concise
approval body exists that states what `At` usability now measurably means, and `FOLLOWUP.md`'s
#11 facts are current and name the new file as the thing to post.

### Research Integration

The report fixes every factual claim the response is allowed to make, and the response adds none
of its own. Carried forward verbatim: the pinned head `b2eb3ac0b57d0f6082235aee0b861d8249bd7687`
with CI run `45112546558` green on it; Condition 1 met by the generators' own verdicts (`lake
exe mk_all --lib FormalSystem` reporting no update necessary, `check-module-invariants.sh
--emit-inventory` reporting no rewrite needed, C33 byte-for-byte with 791 import lines); Condition
2 met with the working idiom `simp only [at_def, TruthEnv.T, <language clause lemma>]`, measured
in goal and hypothesis position at L, L⁺ and L⋆, with `rw` to a clause lemma under `At` still
failing and the `at_def`-omitted control making no progress at all; Condition 3 met with eleven
named lemmas now carrying rows, two of them at L⋆ threading `regs : ℕ → F.Duration` explicitly,
and 7 of 13 transport factories exercised, one per relation family. Also carried: the gate table
(`lake build --wfail` 3010 jobs, `lake test` 3086 jobs, `lake lint`, full
`check-module-invariants.sh` ALL CHECKS PASSED, and all 69 declarations of the four PR modules
inside `[propext, Classical.choice, Quot.sound]`), and the two measured corrections to the task
description's diff figures (the test files are `65 7` and `34 1`, not `+72` and `+35`), neither
of which changes a verdict.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No roadmap context was supplied with this dispatch; none was consulted.

## Goals & Non-Goals

**Goals**:

- Re-confirm, before writing anything, that PR #11's head is still the sha the research measured,
  and stop rather than write an approval against code nobody has measured if it has moved.
- Produce a draft approval body for PR #11 that is concise and flat in register, matching the
  precedent set by the approval already in this directory for the rewriting contribution.
- State in that body what At usability now means in practice, rather than only that the condition
  is met: which tactic sequence works, where it works, and what still does not.
- Acknowledge, without reopening, the three small observations the re-review turned up: the four
  lemmas whose direct test rows were rewritten into their keeping forms, the degenerate rank
  progress row, and the three transport relation shapes still unexercised.
- Leave the posted after-the-merge list intact and unchanged, and say so.
- Bring the follow-up record's facts for this pull request up to date and name the new draft as
  an item to post, in its existing order.

**Non-Goals**:

- Posting, pushing, merging, approving or commenting on GitHub. Every deliverable is a local
  draft; the user posts.
- Re-deriving the research verdict, re-running the gate set, or rebuilding the review worktree.
  The evidence is already measured and the implementation phase consumes it.
- Re-reading the statements of the contributed lemmas for correctness. The earlier review's
  reading is carried forward unchanged and was not re-derived.
- Editing any Lean source, generated file, record under `records/`, or task state. The
  after-the-merge list stays where it is.
- Touching the other three pull requests' drafts in the same directory.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| The head moves again between the research dispatch and this one, making the approval an endorsement of unmeasured code | H | L | Phase 1 is a hard gate: re-probe `headRefOid` before any file is written, and stop with a recorded `user_decision` if it differs from the pinned sha |
| The approval reads as endorsing more than was measured — that the statements are the intended ones, not merely that they compile and lint | M | M | The body states explicitly what the gates certify; the earlier review's reading of the statements is cited as carried forward, not re-derived |
| The response overstates Condition 2 as "`At` now rewrites" | M | M | The body names the three-lemma `simp only` idiom literally and says `rw` to a clause lemma under `At` still fails; the `at_def`-omitted control is the evidence that `at_def` is load-bearing |
| A small observation (degenerate `rank_progress` row, stale test README row, unexercised relation shapes) is read as a new condition and reopens the review | M | M | Each is written as a note or an acknowledgement in its own sentence, explicitly not a condition, in a section the body marks as such |
| `FOLLOWUP.md`'s stale #11 preamble facts (head `c6cd983b7`, "draft, now conflicting") survive the edit and contradict the new entry | M | M | Phase 3 enumerates every #11 mention in the file — preamble, post list, Decided, Still open, Backing reports — and reconciles each, rather than appending a new entry only |
| The implementer treats the commit skip on `specs/reviews/**` as a failure | L | M | `specs/reviews/` is excluded locally via `.git/info/exclude`; a `git-commit-scoped.sh` exit 8/9 skip for those paths is the expected, documented non-failure, and the plan says so |
| The approval body cites a task number and so leaks ephemeral metadata into text destined for GitHub | L | L | The body cites durable anchors only (`records/milestones.md` D1, file paths, declaration names), exactly as the already-posted comment does; task numbers stay in `FOLLOWUP.md`, which is never posted |

## Decisions

- **The verdict is not re-litigated here.** The research dispatch measured all three conditions
  against the head and recommended approval; this plan's phases produce the response, not a
  second opinion. The one thing that can overturn it is the head having moved, which Phase 1
  checks first and treats as a stop condition rather than a prompt to re-measure.
- **The approval is a new file, not an edit of the posted comment.** `pr11-comment.md` is the
  body that was actually posted at 2026-11-23T01:57:16Z and is a record of what went out; the
  approval is a second, later message and takes its own file, following the naming precedent
  already in the directory for the approved rewriting contribution.
- **`## Lean Challenge Statements` declares zero goals.** This task's deliverables are two prose
  files under `specs/reviews/`; it commits to no theorem, no Lean declaration and no change to
  any Lean source, so the plan carries the section with the zero-goal marker rather than omitting
  it, and `- **Goals**:` names no identifiers.
- **No coupled generated surface is in scope.** No phase moves a Lean line count, adds or removes
  a file under `FormalSystem/`, or touches a `.lean` path at all, so neither the module-inventory
  blocks nor `typst/generated/status.typ`'s counts can drift, and the pre-commit hook's
  line-count check is a no-op for every commit this plan fires. Nothing is deferred to a
  reconciliation phase because nothing is triggered.

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases within the same wave can execute in parallel. Every wave here holds one phase: the
approval cannot be written before the head is re-confirmed, the follow-up entry names the
approval file, and the final pass reads both.

### Phase 1: Re-confirm the head before writing anything [COMPLETED]

**Goal**: establish that the measured verdict still applies to the code currently at the tip of
PR #11, or stop.

**Tasks**:

- [x] Run `gh pr view 11 --json number,state,isDraft,headRefOid,updatedAt,mergeable,mergeStateStatus,baseRefName`
      and record the output verbatim, with the wall-clock time of the probe.
- [x] Compare `headRefOid` against the pinned
      `b2eb3ac0b57d0f6082235aee0b861d8249bd7687`. Equality is the gate.
- [x] Confirm CI on that head is still green: `gh run list --branch feat/pointed-semantic-lemmas
      --limit 5 --json databaseId,headSha,conclusion,status,workflowName`, looking for run
      `45112546558` (or a later run on the same sha) with `conclusion: success`.
- [x] Check for any contributor prose that arrived after the research dispatch:
      `gh api repos/benbrastmckie/BimodalLogic/issues/11/comments` and
      `gh api repos/benbrastmckie/BimodalLogic/pulls/11/comments`. Both were empty; a non-empty
      result is content the response must answer, not a stop condition.
- [ ] If `headRefOid` differs from the pinned sha: write no response file at all. *(deviation: skipped — stop condition did not fire; the head matched the pinned sha)* Record the new
      sha with `issue-record.sh`, set `user_decision` on `.return-meta.json` (the approval would
      otherwise endorse code no gate run has seen), and return `blocked` without entering
      Phase 2.

**Timing**: 15 minutes

**Depends on**: none

**Verification Tier**: prose

**Tier Justification**: the phase writes no deliverable file and runs only read-only `gh`
probes, so its covering check is the `prose` row's read-through of the recorded probe output
against the pinned sha `b2eb3ac0b57d0f6082235aee0b861d8249bd7687`.

**Files to modify**:

- none planned — read-only GitHub probes; any `issue-record.sh` entry is bookkeeping written by
  that script rather than an edit this phase authors.

**Verification**:

- The probe output is recorded in the phase notes, with its timestamp, and `headRefOid` reads
  `b2eb3ac0b57d0f6082235aee0b861d8249bd7687`.
- `state` is `OPEN` and `mergeable` is `MERGEABLE`; a change in either is recorded in the notes
  and carried into the response rather than silently dropped.
- The CI query names a `success` run on that sha.

**Verification Notes** (Phase 1, probe at 2026-11-23T09:45:17Z):

```
{"baseRefName":"main","headRefOid":"b2eb3ac0b57d0f6082235aee0b861d8249bd7687","isDraft":false,
 "mergeStateStatus":"CLEAN","mergeable":"MERGEABLE","number":11,"state":"OPEN",
 "updatedAt":"2026-11-23T04:33:16Z"}
```

- `headRefOid` equals the pinned `b2eb3ac0b57d0f6082235aee0b861d8249bd7687`. The gate passes and
  Phase 2 is entered.
- `state` `OPEN`, `isDraft` `false`, `mergeable` `MERGEABLE`, `mergeStateStatus` `CLEAN` — all
  unchanged from the research measurement; nothing to carry into the response as a change.
- CI: run `45112546558`, workflow `CI`, `headSha` `b2eb3ac0b...`, `conclusion: success`,
  `status: completed`. No later run on that sha.
- Contributor prose since the research dispatch: none. `issues/11/comments` length 0,
  `pulls/11/comments` length 0. `pulls/11/reviews` still holds exactly one review,
  `CHANGES_REQUESTED` at 2026-11-23T01:57:16Z against `c6cd983b79842368ae789488d38e488656f98992`.
- Covering check for the declared `prose` tier: the read-through above. No `.lean` path, no
  generated surface and no deliverable file was touched by this phase, so no build or suite maps
  to it.

---

### Phase 2: Draft the approval body [COMPLETED]

**Goal**: a concise, flat approval message for PR #11 that says what was re-measured, what `At`
usability now means, and what is a note rather than a condition.

**Tasks**:

- [x] Create `specs/reviews/pr-reviews-2026-11-21/pr11-approval.md`. Do not edit or overwrite
      `pr11-comment.md`, which is the record of the body that was posted.
- [x] Open with the approval and the re-measurement in two or three sentences: approving at
      `b2eb3ac0b`; the gate set re-run locally in a from-scratch worktree at that head (build
      under `--wfail`, tests, lint, the full invariants run) and green; the axiom profile of all
      69 declarations of the four modules unchanged.
- [x] Condition 1, one short paragraph: the regeneration is the generators' own verdict, not an
      eyeball — `lake exe mk_all --lib FormalSystem` reports no update necessary and
      `check-module-invariants.sh --emit-inventory` reports no block needed a rewrite, with the
      tree clean through both. Note in one clause that the `status.typ` stamp naming `c6cd983`
      is the generator recording the HEAD it ran at, and that every count reproduces at the merge
      head, so it is generated output rather than a hand-resolved conflict.
- [x] Condition 2, the longest section and the one that has to be exact. State: the working
      idiom is `simp only [at_def, TruthEnv.T, <language clause lemma>]`; it works on goals and
      on hypotheses with `... at h`; it works at L, L⁺ and L⋆ including L⋆'s
      `ℕ → F.Duration` environment; `at_def` is load-bearing, since omitting it leaves `simp`
      with no progress to make; and `rw` to a clause lemma under `At` still does not work,
      because the per-language clause lemma is stated about the instance projection and that has
      to be reduced first. Add that on a generic clause former `simp` already sees through the
      reducible `At`, so `at_def` is needed only on the language-specific route.
- [x] Condition 3, one paragraph plus the acknowledgement: every named lemma now has a row, two
      of them at L⋆ with `regs` threaded explicitly, and 7 of the 13 transport factories are
      exercised, one per relation family. Acknowledge — as an acknowledgement, not an ask — that
      `IsoRel`, `AntiIsoRel` and the `Eq` relation of `plus_iffTransport_stateLocalStab` remain
      unexercised, since the bar asked for was one per family.
- [x] Notes, each explicitly not a condition and each at most a sentence or two: the
      `someFuture_bind`, `somePast_bind`, `allFuture_persist` and `allPast_persist` rows were
      rewritten into the `_keeping` forms and stay exercised transitively, since the `_keeping`
      lemmas are proved from them, so nothing is being reopened there; the `rank_progress` row
      takes `I = Q`, so its step premise is discharged vacuously and the descent is exercised by
      the pre-existing `rank_progress_strict` row rather than by it; and
      `Tests/BimodalTest/Semantics/README.md`'s row for `TemporalRulesTest.lean` no longer
      describes the file.
- [x] Credit the one thing that landed early at no cost: the `release_iff`, `trigger_iff` and
      `weakUntil_iff` rows state their goals with `Formula.release`, `Formula.trigger` and
      `Formula.weakUntil`, so they compile the definitional agreement between the generic inline
      formula and the existing `Syntax/Formula.lean` operator.
- [x] Close by confirming the after-the-merge list stands unchanged — nothing in this push
      touches the named interval operators, the `next_iff_covBy`/`prev_iff_covBy` promotion, the
      Release positive-reading note, the module docstring titles, or the L⁻/L⋆ gaps — and
      pointing at `records/milestones.md` D1 as the posted comment already does.
- [x] State plainly, in one sentence, what the gates certify and what they do not: compilation,
      linting, the invariants suite and the axiom profile, not that any statement is the intended
      one.
- [x] Re-read the whole file for register: flat, direct, no hedging, no exclamation, short
      paragraphs, bold lead-ins only where a note genuinely needs one. Use no task numbers
      anywhere in the body — the durable anchors are file paths, declaration names and
      `records/milestones.md` D1.

**Timing**: 50 minutes

**Depends on**: 1

**Verification Tier**: prose

**Scope Hypothesis**: the body is expected to land in roughly 35-55 lines, comparable to the
existing approval in this directory. Confirm at implementation time by `wc -l` on the finished
file; a materially longer body is a signal to cut, not a reason to amend this plan, and the
figure governs nothing else.

**Tier Justification**: the only touched path lies entirely under `specs/**` and is not a
report/plan/summary artifact, so plan-format's sub-case (a) applies and the covering check is the
`prose` row's diff read-through of the new file against the research report's Condition 1-3
tables.

**Files to modify**:

- `specs/reviews/pr-reviews-2026-11-21/pr11-approval.md` - new file; the draft approval body for
  PR #11 at `b2eb3ac0b`.

**Verification**:

- The file exists, is non-empty, and every factual claim in it traces to a row of the research
  report's Condition 1, Condition 2, Condition 3 or gate-evidence tables — checked claim by
  claim, with nothing asserted that the report does not carry.
- All three conditions are addressed by name and in order, and each is marked met.
- The Condition 2 section names the three-lemma `simp only` idiom literally, says `rw` under
  `At` still fails, and says `at_def` is load-bearing.
- `grep -nE '\b[Tt]asks? [0-9]+' specs/reviews/pr-reviews-2026-11-21/pr11-approval.md` returns
  nothing.
- `git status --short` does not list the file: `specs/reviews/` is excluded via
  `.git/info/exclude`, so its absence from the status output is the expected signal and a
  commit skip (`git-commit-scoped.sh` exit 8/9) for that path is a documented non-failure, not
  a gap.

**Verification Notes** (Phase 2):

- `specs/reviews/pr-reviews-2026-11-21/pr11-approval.md` exists and is non-empty (61 lines).
- Claim-by-claim read-through against the research report completed: every factual assertion in
  the body traces to a named row of the report's Condition 1, Condition 2, Condition 3 or
  gate-evidence tables. Nothing is asserted that the report does not carry; the one
  non-measurement sentence ("the case I was most worried about") restates the posted comment's
  own stated concern about a wrongly threaded L⋆ environment rather than adding a fact.
- All three conditions are addressed by name, in order, each with an explicit "— met".
- The Condition 2 paragraph names `simp only [at_def, TruthEnv.T, <language clause lemma>]`
  literally, states that `rw` to a clause lemma under `At` still does not work, and states that
  `at_def` is load-bearing via the omitted-`at_def` control.
- `grep -nE '\b[Tt]asks? [0-9]+'` over the file returns nothing (exit 1).
- `git status --short -- <the file>` is empty, as expected: `/specs/reviews/` is listed in
  `.git/info/exclude`, so this deliverable is never committed and a `git-commit-scoped.sh`
  exit 8/9 skip for that path is the documented non-failure.
- `pr11-comment.md` is untouched: still 45 lines, same first and last lines as read at planning
  time.
- **Scope Hypothesis outcome**: 61 lines against the hypothesised 35-55. Recorded as a knowing
  overshoot in `issues.jsonl` rather than cut further, since every remaining paragraph discharges
  a checklist item above and the only route to 55 was rewrapping at a wider column.
- Covering check for the declared `prose` tier: the read-through above. The sole touched path
  lies under `specs/**` and is not a report/plan/summary artifact, so no suite or build maps
  to it.

---

### Phase 3: Reconcile the follow-up record [COMPLETED]

**Goal**: `FOLLOWUP.md` states the current facts for PR #11 and names the approval draft as an
item to post.

**Tasks**:

- [x] Enumerate every mention of #11 in
      `specs/reviews/pr-reviews-2026-11-21/FOLLOWUP.md` before editing: the preamble state
      sentence, item 1 of the post list, the `## Decided` bullet, the `## Still open` entry, and
      the `## Backing reports` paragraph. Work the list, not only the first hit.
- [x] Correct the preamble: #11's head is no longer `c6cd983b7` and is no longer draft or
      conflicting. It is `b2eb3ac0b`, `OPEN`, `MERGEABLE`, `CLEAN`, with the merge of `main`
      done by the contributor.
- [x] Leave item 1's `**POSTED ...**` record intact — it is the record of what went out against
      `c6cd983b79842368ae789488d38e488656f98992` — and extend it with the outcome: the
      contributor answered in code with no prose, all three conditions are met at
      `b2eb3ac0b`, and the draft response is `pr11-approval.md`.
- [x] Add the approval to the post list as its own item, in the order the user should post it,
      carrying the same one-line shape the other items use: what it is, what it says, and the
      re-check result with its timestamp and the CI run id. *(deviation: altered — the approval
      was APPENDED as item 5 rather than inserted at position 2 with the list renumbered.
      Renumbering would have edited the #8 entry's own self-reference "now in the post list above
      as item 4", which the next checklist item forbids; appending is also this list's established
      convention. Posting order is conveyed inside item 5's own text instead.)*
- [x] Update the `## Decided` bullet for #11 so it records that the three conditions were met and
      the position is now approve, without rewriting the decisions that produced the original
      three conditions.
- [x] Reconcile the `## Still open` entry that names the re-read of `pr11-comment.md`'s changed
      follow-up section, and the `## Backing reports` paragraph, against the new backing report
      at `specs/990_rereview_pr11_at_rewriteable_pointed_truth_head/reports/01_rereview-pr11-at-usability-and-tests.md`.
- [x] Keep the standing pre-post instruction intact: re-check each head immediately before
      posting. The approval is subject to it exactly as the other items are.
- [x] Do not touch the #8, #9 or #10 entries except where a shared sentence (the preamble's
      heads line) names #11 alongside them.

**Timing**: 25 minutes

**Depends on**: 2

**Verification Tier**: prose

**Tier Justification**: the only touched path lies entirely under `specs/**` and is not a
report/plan/summary artifact, so plan-format's sub-case (a) applies and the covering check is the
`prose` row's diff read-through of the edited file against the enumerated list of #11 mentions.

**Files to modify**:

- `specs/reviews/pr-reviews-2026-11-21/FOLLOWUP.md` - preamble head facts, item 1's outcome, a
  new post-list item for the approval, the `## Decided` and `## Still open` entries, and the
  `## Backing reports` paragraph.

**Verification**:

- `grep -n '11' specs/reviews/pr-reviews-2026-11-21/FOLLOWUP.md` surfaces no surviving claim that
  #11 is draft, conflicting, or at `c6cd983b7` other than inside the preserved posted-record
  sentence, which correctly names that sha as what the posted review attached to.
- The file names `pr11-approval.md` as a thing to post and `b2eb3ac0b` as the head it was
  measured against.
- The #8, #9 and #10 entries are unchanged apart from the shared preamble sentence — confirmed by
  reading the diff hunk by hunk.
- `git status --short` does not list the file, for the same exclusion reason as Phase 2.

**Verification Notes** (Phase 3):

- All six enumerated #11 mentions were worked, confirmed by a hunk-by-hunk read of
  `diff -u <scratchpad backup> FOLLOWUP.md`: the preamble heads sentence, item 1's `**Outcome**`
  extension, the new item 5, the `## Decided` bullet, the `## Still open` entry, and the
  `## Backing reports` paragraph.
- `grep -n 'c6cd983'` returns two lines, both correct: item 1's preserved posted-record sentence
  (the sha the `CHANGES_REQUESTED` review attached to) and the `## Backing reports` statement that
  `pr11-review.md` and the other review's report are written against that sha. Neither asserts it
  as #11's current head.
- `grep -nE 'draft|conflict'` surfaces no surviving stale #11 claim: the preamble reads "not a
  draft" and "the conflict ... is gone", line 6's "(conflicting)" belongs to #9, and line 19's
  "the draft response" means a draft document.
- The file names `pr11-approval.md` (4 occurrences) and `b2eb3ac0b` (7).
- The #8, #9 and #10 entries are unchanged apart from the shared preamble sentence. In that
  sentence #10's head was reconciled from the stale `bdaa3b6d0` (draft, clean) to `ada7074dd`
  (no longer draft) — the value the file's own `## Still open` section already records — rather
  than preserved as a contradiction the rewrite would have knowingly carried forward.
- The standing "Before posting: ... re-check each head" instruction is intact, and item 5 is
  subject to it exactly as the other items are.
- `git status --short -- specs/reviews/` is empty, as expected under the `.git/info/exclude`
  entry.
- Covering check for the declared `prose` tier: the diff read-through above. The sole touched
  path lies under `specs/**` and is not a report/plan/summary artifact.

---

### Phase 4: Final consistency pass and completion [COMPLETED]

**Goal**: the two review files agree with each other and with the report, the head is confirmed
one last time, and the task closes with a summary.

**Tasks**:

- [x] Re-read `pr11-approval.md` and `FOLLOWUP.md` together and check that every fact common to
      both — the head sha, the verdict, the CI run, the condition outcomes — is stated the same
      way in each.
- [x] Re-probe `gh pr view 11 --json headRefOid,state,mergeable,updatedAt` one last time and
      record the result. If the head has moved since Phase 1, do not revise the drafts silently:
      record it, note in `FOLLOWUP.md` that the drafts were measured against `b2eb3ac0b` and the
      head has since moved, and surface it as a `user_decision`.
- [x] Write the completion summary to
      `specs/990_rereview_pr11_at_rewriteable_pointed_truth_head/summaries/01_approve-pr11-and-update-followup.md`
      per `context/formats/summary-format.md`.
- [x] Record in the summary that nothing was posted, pushed, merged or approved, and that the
      unblocking of the two downstream follow-up tasks is contingent on the user posting the
      approval and the merge actually landing.
- [x] Record the issue-log attestation for this phase, including an explicit attestation if
      nothing arose.

**Timing**: 25 minutes

**Depends on**: 3

**Verification Tier**: full

**Files to modify**:

- `specs/990_rereview_pr11_at_rewriteable_pointed_truth_head/summaries/01_approve-pr11-and-update-followup.md` - new completion summary.

**Verification**:

- Scoped touched-path check, since every path this task touched lies under `specs/**`:
  `bash .claude/scripts/validate-artifact.sh specs/990_rereview_pr11_at_rewriteable_pointed_truth_head/summaries/01_approve-pr11-and-update-followup.md summary`
  passes, and the two `specs/reviews/` files get the `prose` row's diff read-through, which is
  the covering check plan-format's sub-case (a) prescribes for a non-artifact `specs/**` file.
  No suite maps to any of these paths and no `.lean` path was touched, so the pre-commit
  line-count hook is a no-op for this task's commits.
- The complete gate set is explicitly DEFERRED to the orchestration close under `/orchestrate`
  rather than invoked independently here; this phase records that deferral in its own
  verification notes.
- `gh pr view 11 --json headRefOid` still reads `b2eb3ac0b57d0f6082235aee0b861d8249bd7687`, or
  the divergence is recorded in `FOLLOWUP.md` and surfaced as a `user_decision`.
- Both deliverable files exist and are non-empty; the summary names both of them.

**Verification Notes** (Phase 4):

- Final head re-probe at 2026-11-23T09:50:58Z:
  `{"headRefOid":"b2eb3ac0b57d0f6082235aee0b861d8249bd7687","mergeable":"MERGEABLE","state":"OPEN","updatedAt":"2026-11-23T04:33:16Z"}`
  — identical to the Phase 1 probe. No divergence to record, and no `user_decision` needed.
- Cross-read of `pr11-approval.md` against `FOLLOWUP.md`: the head sha (`b2eb3ac0b`) and the
  verdict (approve) are stated the same way in both. The CI run id `45112546558` appears only in
  `FOLLOWUP.md`, by design — it is the pre-post re-check record, while the approval body reports
  the local gate run rather than CI.
- `bash .claude/scripts/validate-artifact.sh <summary> summary` → `[PASS]`, 0 warnings.
- `pr11-comment.md` byte-unchanged: still 45 lines, same opening and closing lines as read at
  planning time.
- `git status --short` shows no `.lean`, `README.md`, `FormalSystem/**` or `typst/generated/**`
  entry, and no entry attributable to this task outside
  `specs/990_rereview_pr11_at_rewriteable_pointed_truth_head/`. The sibling `specs/978*`,
  `specs/979*`, `specs/980*` and `specs/981*` entries and the `specs/TODO.md`,
  `specs/events.jsonl`, `specs/state.json` entries belong to other dispatches in this batch and
  to the orchestrator.
- **Scoped discharge of the declared `full` tier**: `bash .claude/scripts/verify-touched.sh`, per
  the dispatch's Batch Gate Deferral directive, run detached with a bounded wait. Result: 84
  passed, 1 failed (NEW), 10 skipped, 95 total. The single failure is
  `tests/test-deploy-baseline-lib.sh`'s case "control: a genuinely matching warm-cache entry was
  expected to skip gate 1 but did not" — the standing `verify-deploy.sh` gate-cache warm-path
  defect, already reproduced twice in freshly created isolated scratch directories and so not a
  concurrency artifact. It is unattributable to this task, which touched no `.claude/**` and no
  `.lean` path; `verify-touched.sh` selected that suite only because it derives touched paths
  from the whole working tree plus the committed diff against its own determined base, which under
  this multi-task batch takes in sibling and prior-session changes. Recorded in `issues.jsonl`
  and named in the summary's Verification and Follow-ups sections rather than papered over.
- **The complete gate set is DEFERRED** to the orchestration close for the whole batch rather
  than independently run here, and no additional full sweep was run. No unmappable criterion
  arose: `verify-touched.sh` resolved every touched path, with the four this task owns landing in
  its OWED free-fallback set.

---

## Lean Challenge Statements

<!-- lean-challenge-statements:none -->

This task's deliverables are two prose files under `specs/reviews/` and a completion summary. It
commits to no theorem, no new Lean declaration, and no edit to any `.lean` file; the Lean
evidence it consumes was measured by the research dispatch in a separate review worktree and is
cited, not reproduced. See the `## Decisions` section above for the full rationale.

## Testing & Validation

- [x] `gh pr view 11 --json headRefOid` reads `b2eb3ac0b57d0f6082235aee0b861d8249bd7687` at
      Phase 1 and again at Phase 4.
- [x] `specs/reviews/pr-reviews-2026-11-21/pr11-approval.md` exists, is non-empty, and addresses
      all three posted conditions by name and in order.
- [x] Every factual claim in the approval body traces to a row of the research report; nothing is
      asserted that the report does not carry.
- [x] The approval body contains no task-number reference, checked with
      `grep -nE '\b[Tt]asks? [0-9]+'`.
- [x] `specs/reviews/pr-reviews-2026-11-21/FOLLOWUP.md` carries no surviving stale #11 fact
      outside the preserved posted-record sentence, and names `pr11-approval.md` and
      `b2eb3ac0b`.
- [x] `specs/reviews/pr-reviews-2026-11-21/pr11-comment.md` is byte-unchanged — confirmed by
      comparing its length and first and last lines against the values read at planning time (45
      lines, opening "Thank you. This is the contribution I asked for").
- [x] `bash .claude/scripts/validate-artifact.sh <summary path> summary` passes.
- [x] No `.lean`, `README.md`, `FormalSystem/**` or `typst/generated/**` path is modified —
      confirmed from `git status --short`, which must show no new entries attributable to this
      task outside `specs/990_rereview_pr11_at_rewriteable_pointed_truth_head/`.

## Artifacts & Outputs

- `specs/reviews/pr-reviews-2026-11-21/pr11-approval.md` — the draft approval body for PR #11 at
  `b2eb3ac0b` (new; locally excluded from git, so never committed).
- `specs/reviews/pr-reviews-2026-11-21/FOLLOWUP.md` — reconciled #11 facts and a post-list entry
  for the approval (modified; same exclusion).
- `specs/990_rereview_pr11_at_rewriteable_pointed_truth_head/summaries/01_approve-pr11-and-update-followup.md`
  — completion summary (new).
- `specs/990_rereview_pr11_at_rewriteable_pointed_truth_head/issues.jsonl` — issue and win
  entries recorded as they arise.

## Rollback/Contingency

Every edit this plan makes is a prose file; none is reachable from a build, a gate or the Lean
library, so a bad outcome costs nothing beyond the text itself.

- `pr11-approval.md` is new. Reverting it is deleting the file; the task then returns `partial`
  with the reason recorded.
- `FOLLOWUP.md` is the only pre-existing file edited. Before Phase 3's first edit, copy it to the
  scratchpad (`cp specs/reviews/pr-reviews-2026-11-21/FOLLOWUP.md <scratchpad>/FOLLOWUP.md.bak`)
  and restore from that copy if the reconciliation goes wrong. A plain file restore is the
  mechanism here, not a git operation: `specs/reviews/` is excluded via `.git/info/exclude`, so
  git holds no version of this file to restore from, and no snapshot-then-rollback recipe
  applies to it.
- If Phase 1's head check fails, nothing has been written yet and there is nothing to roll back:
  stop before Phase 2, record the new sha, and return `blocked` with a `user_decision`.
- If the head moves after the drafts exist, the drafts are kept and annotated rather than
  deleted — they remain a correct record of what `b2eb3ac0b` was measured to be, and the
  decision about re-measuring the newer head is the user's.
