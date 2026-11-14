# Implementation Summary: Task #926

- **Task**: 926 - Lean completeness line reopen decision record
- **Status**: [COMPLETED]
- **Started**: 2026-11-14T07:10:31Z
- **Completed**: 2026-11-14T08:05:00Z
- **Effort**: ~1 hour
- **Dependencies**: 927 (completed), 928 (completed)
- **Artifacts**: plans/01_completeness-line-reopen-ruling.md, reports/01_completeness-line-reopen-ruling.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

This task closes out the decision record on whether the Lean completeness line reopens, for
each of the four routes (R1-R4) the research dispatch named. The research report already
delivered the ruling; this implementation discharged the three obligations the report did not
yet carry: a Premise Re-Validation section against live state, a consolidated Reopening Terms
sheet, and this completion summary. No Lean file was written or edited, no part of the Reynolds
engine's §§7-15 was formalized, attempted, or filed, and no completeness claim is made anywhere
in either artifact.

## The Ruling, One Line Per Route

- **R1** (`Muller.toRabin_exists`): KEEP CLOSED, in this repository — blocked by the separate
  CSLib `require` ruling, not by Recommendation 8's engine-content clause.
- **R2** (final-frame step): REOPEN — already executing under tasks 931/932, never actually
  blocked by Recommendation 8, nothing further owed.
- **R3** (determinization-free progress-measure design): REOPEN for paper research only; any
  resulting Lean filing still requires a separate Recommendation 8 reversal.
- **R4-Q1, as stated**: KEEP CLOSED — trips the engine-content clause (no cheaper than
  `LCRulesComplete` itself per 906).
- **R4-Q1, converse** and **R4-guarded-until-form**: REOPEN, confined to
  `PlusLCSchema.lean`/`LCExtension.lean`.
- **R4-Q2**: BLOCKED on literature acquisition (Di Maio-Zanardo 1998), not on any ruling.

Recommendation 8 stays in force for every route and sub-route this task does not explicitly
mark REOPEN, and no REOPEN row above is a reversal of it — each is a route the report's
Findings argue was never actually blocked by that ruling in the first place.

## What Changed

- `specs/926_lean_completeness_line_reopen_decision_record/reports/01_completeness-line-reopen-ruling.md` —
  added a `## Premise Re-Validation` section recording a confirmed/stale verdict for every
  carried claim (one found stale, six confirmed verbatim); corrected the stale "zero tasks"
  sentence in `## Context & Scope`; appended a `## Reopening Terms` section consolidating all
  seven routes/sub-routes into one file-against-able table, each row citing its Findings
  subsection and, for KEEP CLOSED rows, naming the specific Recommendation 8 clause it trips.
- `specs/926_lean_completeness_line_reopen_decision_record/plans/01_completeness-line-reopen-ruling.md` —
  all three phases checked off with completion annotations; phase headings advanced to
  `[COMPLETED]`.
- `specs/926_lean_completeness_line_reopen_decision_record/summaries/01_completeness-line-reopen-ruling-summary.md` —
  this file, new.

## Decisions

- The Premise Re-Validation pass re-ran every lookup rather than trusting the plan-time count;
  it found exactly the one stale figure the plan's Scope Hypothesis anticipated (the "zero
  tasks" premise) and no additional one. The ruling's substance is unaffected: the front gained
  tasks only on R2's never-barred route, which the ruling does not condition on the front being
  empty.
- The Reopening Terms table discriminates, for both KEEP CLOSED rows, which specific clause of
  Recommendation 8 is tripped (the engine-content clause for R4-Q1-as-stated, the separate CSLib
  `require` clause for R1), per the report's own Context Extension Recommendation.
- The missing `topic: completeness` tag on tasks 931 and 932 is recorded as an observation only
  in the report; no `state.json` edit was made, consistent with this task's report/summary-only
  `file_scope`.
- Whether to file the R3 paper-research follow-on, and the R4 converse/guarded-form follow-on,
  is a **deferred user preference, not a blocker**. The report's Recommendations 3-4 state the
  filing terms conditionally ("if R3 is wanted", "if R4 is wanted"); this task does not raise
  `user_decision` for it, consistent with the report's own Decisions section, which found no
  routine field warranted.

## Plan Deviations

- None (implementation followed plan).

## Impacts

- A successor who wants to file against R2's already-executing route (931/932), R3's paper
  research, or R4's converse/guarded-until-form schema questions can file directly from the
  Reopening Terms table without re-reading the four Findings sections or re-asking what the
  terms are.
- The completeness front's task inventory now has an explicit, re-verifiable account of why it
  is no longer empty, closing the gap between the task's motivating premise and live state.
- Recommendation 8 and the separate CSLib `require` ruling are both left exactly as they stood
  before this task for every route not explicitly reopened; no Reynolds-engine content (§§7-15)
  is touched.

## Follow-ups

- Whether to file the R3 paper-research task and/or the R4 converse/guarded-until-form task
  (deferred user preference, not a blocker — see Decisions above).
- Backfilling `topic: completeness` on tasks 931 and 932 (observation recorded in the report;
  out of this task's `file_scope`).
- R4-Q2 requires literature acquisition of Di Maio-Zanardo 1998 before any research or Lean
  task can be filed against it.

## Guardrails Held

- No `.lean` file was written or edited by this task (confirmed by `git status --short`, no
  path outside `specs/926_lean_completeness_line_reopen_decision_record/` touched by this
  task's own commits).
- No part of the Reynolds engine's §§7-15 was formalized, attempted, or filed.
- No completeness claim appears in either artifact.
- The four founding reports (879, 901, 902, 903) are cited throughout, never re-derived or
  condensed.

## Issue Log

One `win` entry was recorded during Phase 1 (clean confirmation pass: exactly one stale figure
found, matching the plan's Scope Hypothesis, with six other carried claims confirming verbatim).
Nothing further arose during Phase 2 or Phase 3.

## Verification

- `bash .claude/scripts/validate-artifact.sh specs/926_lean_completeness_line_reopen_decision_record/reports/01_completeness-line-reopen-ruling.md report` — PASS
- `bash .claude/scripts/validate-artifact.sh specs/926_lean_completeness_line_reopen_decision_record/summaries/01_completeness-line-reopen-ruling-summary.md summary` — run below
- `git status --short` — scoped review confirms no `.lean` file and no path outside this task's
  directory was touched by this task's own commits
- Full gate set (`verify-deploy.sh`): deferred to the batch-level stage per this dispatch's
  Batch Gate Deferral directive — see Verification section below for the scoped discharge
  actually run in its place

## References

- `specs/926_lean_completeness_line_reopen_decision_record/plans/01_completeness-line-reopen-ruling.md`
- `specs/926_lean_completeness_line_reopen_decision_record/reports/01_completeness-line-reopen-ruling.md`
- `specs/927_final_frame_step_remeasure_against_landed_cover/summaries/01_final-frame-step-remeasure-summary.md`
- `specs/928_muller_torabin_determinization_cost_assessment/summaries/01_muller-torabin-cost-assessment-summary.md`
- `specs/archive/901_two_sided_reynolds_engine_paper_proof/reports/01_two-sided-reynolds-engine-paper-proof.md`
- `specs/ROADMAP.md`
