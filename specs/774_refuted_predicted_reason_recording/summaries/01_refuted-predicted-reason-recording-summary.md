# Implementation Summary: Task #774

- **Task**: 774 - EVALUATE (AND BE WILLING TO DECLINE): should plan guidance require a refuted
  predicted REASON to be recorded distinctly from a refuted predicted OUTCOME?
- **Status**: [COMPLETED]
- **Started**: 2026-11-07T00:00:00Z
- **Completed**: 2026-11-07T00:30:00Z
- **Effort**: 0.75 hours
- **Dependencies**: None
- **Artifacts**: plans/01_refuted-predicted-reason-recording.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md,
  source-store-deploy-boundary.md, no-task-references-in-deliverables.md,
  no-record-versioning-in-deliverables.md

## Overview

This record closes with a **decline**: no plan-format field, no new issue-log class, no new
`.return-meta.json` field, and no source-store or deployed-tree edit. The originating observation
— a predicted *reason* refuted while the predicted *outcome* held, captured by an implementer's
own-initiative issue-log entry rather than by any documented requirement — is already fully
covered by the existing tools once their boundaries are understood. Zero files outside this
task's own directory were touched.

## What Changed

- `specs/774_refuted_predicted_reason_recording/summaries/01_refuted-predicted-reason-recording-summary.md` — created (this file).

No other file in the repository, the deployed `.claude/` tree, or the source store
(`agent-system/extensions/core`) was modified.

## Decisions

**The decline, and why, re-confirmed against the live source store at implement time** (the
source store is under concurrent edit by sibling tasks this same cycle, so the research
snapshot was re-verified rather than trusted):

1. **The originating entry, read verbatim.** `entry_id: iss_1791780659461_iJw5zy`,
   `class: plan-accuracy`, `severity: minor`, `phase: implement`, `dispatch_seq: 3`,
   `resolution: null`, `evidence_path: null`, `suggested_channel: null`. The owning task has
   since been archived; the entry now lives at
   `specs/archive/773_ladder_cell_index_factorization/issues.jsonl` (line 6) rather than at the
   active path the original dispatch cited. Its `what_happened` text matches the dispatch's
   summary word for word: Phase 2 attempt (iii-a) confirmed the plan's predicted outcome but
   refuted its predicted reason — the measured mechanism (`Count false false` holds the
   countdown at `0` through an idle interval of any length while `Drift` moves the next deadline
   freely, so every second-region length is reachable from every pending state) was stronger and
   simpler than the plan's achievable-window argument positioned by residue coordinates.

2. **Grounding finding 1 (no predicted-outcome field in plan-format.md) re-confirmed.** The
   per-phase required-field list in `context/formats/plan-format.md` is still exactly Goal,
   Tasks, Timing, Depends on, Verification Tier (plus optional Commit Mode and conditional Scope
   Hypothesis / Goal Polarity / Files to modify). No predicted-outcome or predicted-reason field
   exists anywhere in the document; a grep for `predict`, `expected outcome`, `both-outcome`,
   `falsify` returns no hits of that kind. Task 773's falsify-first, both-outcomes plan style was
   authored locally by that task, not instantiated from a documented standard. Consequently, the
   change this record was asked to evaluate would mean **introducing** a new plan-authoring
   convention, not tightening an existing one — a materially larger and weaker-motivated proposal
   than the dispatch's own framing implied, which raises rather than lowers the bar for making it.

3. **Grounding finding 2 (phase-closure.md has no predicted-outcome machinery) re-confirmed.**
   Every occurrence of "outcome" in `context/contracts/phase-closure.md` refers to terminal
   dispatch outcomes or phase-heading status markers (`[COMPLETED]`, `[PARTIAL]`, etc.), never to
   a plan's own predictions. It is not a plausible home for this requirement.

4. **Grounding finding 3 (`claim_invalidations` is a type mismatch, not an awkward fit)
   re-confirmed, with the decisive nuance held.** `context/formats/return-metadata-file.md`'s
   `claim_invalidations` structure still carries exactly `declaration_names`, `kind`
   (`"refutation"` or `"supersession"`), `claim`, and `evidence_path`, and its consumer
   `scripts/sweep-invalidated-claims.sh` still matches `declaration_names` literally
   (word-boundary) against *other tasks'* `title`/`description` text, producing a triage list for
   a human — never acting on a same-task divergence between what a plan predicted and what that
   same implementation measured. There is no second task whose claim needs invalidating in the
   task 773 case. This is a structural type mismatch (cross-task forward pointer vs. same-task
   retrospective note), not merely an imperfect fit modulated by the mechanism's documented
   paraphrase-precision caveat — stronger grounds for declining than the dispatch's grounding
   finding 3 originally stated.

5. **Grounding finding 4 (seed-class promotion is recurrence-gated, and one occurrence doesn't
   meet the bar) re-confirmed.** `context/formats/issue-log.md`'s Seed Class Enum still lists
   exactly 15 classes; `plan-accuracy` is not among them. The Extensibility Rule still makes
   `class` deliberately open (`scripts/issue-record.sh` warns on an unrecognized value and
   proceeds; it never refuses). The Unknown-Class Tally section still assigns the
   recurrence-across-tasks tally to the conclusion stage as the named promotion criterion for a
   non-seed class. The existing seed class `design-record defect or ambiguity` — "the design
   record was wrong, self-contradictory, or silent on a case the implementer actually hit" —
   reads naturally over this observation: the plan was wrong about *which* mechanism would hold,
   even though it was right about whether the outcome would be refuted. One `minor`-severity,
   single-occurrence entry does not meet a recurrence bar.

**Why the proposed change is declined, stated as three independent reasons, any one of which is
sufficient on its own:**

- It would **introduce**, not tighten, a plan-authoring convention — the falsify-first,
  both-outcomes style that produced the originating observation is not a documented system
  standard, so legislating a predicted-reason field would be new standing guidance manufactured
  from a single occurrence, which the dispatch explicitly warned against.
- The one mechanism that already exists for recording a refuted claim (`claim_invalidations`) is
  the wrong shape for this case by construction — it is a cross-task forward pointer consumed by
  a literal-match sweep against other tasks' titles/descriptions, not a same-task
  plan-versus-measurement reconciliation log.
- The one taxonomy that already has room for this case (`issue-log.md`'s open `class` vocabulary,
  with `design-record defect or ambiguity` as a close-enough existing seed class and
  `plan-accuracy` available as an open-vocabulary alternative) is explicitly recurrence-gated by
  a mechanism the conclusion stage already runs across tasks. The correct action on one
  occurrence is to **wait**, not legislate.

## Forward Precedent

Recorded here so the next occurrence can be judged against stated reasoning rather than
re-litigated from scratch: when a plan's predicted *outcome* is confirmed but its predicted
*reason* is refuted, the implementer should record it via `issue-record.sh` under
`class: "design-record defect or ambiguity"` (or `class: "plan-accuracy"`, since the class
vocabulary is open — either is acceptable until one is promoted), never via
`claim_invalidations` (wrong shape: that mechanism is for a cross-task forward-pointing claim
match, not a same-task plan/measurement reconciliation). No plan-format field should be added for
this on the strength of a single occurrence. If and when a second genuine occurrence of this
specific phenomenon is observed, the conclusion stage's Unknown-Class Tally mechanism
(`context/formats/issue-log.md`) is the correct, already-documented place to weigh promoting
`plan-accuracy` into the 15-class seed enum — that is the trigger to re-open this question, not
any one further occurrence treated in isolation at implement time.

## Plan Deviations

- None (implementation followed plan).

## Verification

- Build: N/A (no code change)
- Tests: N/A (no code change)
- Files verified: Yes — the originating issue-log entry was read verbatim at its archive path
  (`specs/archive/773_ladder_cell_index_factorization/issues.jsonl`, line 6) and matches the
  dispatch's summary word for word; all four grounding findings were independently re-confirmed
  against the live source store (`/home/benjamin/.config/nvim/agent-system/extensions/core`)
  rather than trusted from the research snapshot, per the greps recorded under Decisions above.
- `git status --porcelain` at phase close shows no modification attributable to this task outside
  `specs/774_refuted_predicted_reason_recording/`; any other uncommitted paths visible are
  sibling tasks' own in-flight work for this same `/orchestrate` cycle, named in this dispatch's
  Territory block, not this task's.
- The complete gate set (`bash .claude/scripts/verify-deploy.sh`) is deferred to the batch-level
  stage per this dispatch's Batch Gate Deferral directive (this task touches nothing outside its
  own `specs/**` directory, so by construction a gate failure would be pre-existing deploy
  staleness — independently noted for six extensions including core — or sibling-caused, never a
  regression introduced here).

## Impacts

- None in-tree. The decision and its reasoning are now durably recorded for discovery by the
  conclusion stage's Unknown-Class Tally mechanism and by any future research dispatch that
  re-encounters this question, without introducing a standing requirement unsupported by
  recurrence.

## Follow-ups

- None required now. Per the Forward Precedent above: if a second genuine occurrence of a
  refuted-predicted-reason-with-confirmed-outcome arises, the conclusion stage's recurrence tally
  is where that should be weighed, not a fresh ad hoc decision.

## References

- `specs/774_refuted_predicted_reason_recording/reports/01_refuted-predicted-reason-recording.md`
  (research report; load-bearing source for the re-verified grounding)
- `specs/774_refuted_predicted_reason_recording/plans/01_refuted-predicted-reason-recording.md`
  (this task's plan)
- `specs/archive/773_ladder_cell_index_factorization/issues.jsonl` (line 6; originating entry)
- `context/formats/plan-format.md`, `context/contracts/phase-closure.md`,
  `context/formats/return-metadata-file.md`, `context/formats/issue-log.md` (all read at their
  live source-store location; none edited)
