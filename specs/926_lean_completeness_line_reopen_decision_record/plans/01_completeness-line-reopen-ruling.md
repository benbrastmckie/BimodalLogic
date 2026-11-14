# Implementation Plan: Task #926

- **Task**: 926 - Lean completeness line reopen decision record
- **Status**: [IMPLEMENTING]
- **Effort**: 2 hours
- **Dependencies**: 927 (completed), 928 (completed)
- **Research Inputs**: specs/926_lean_completeness_line_reopen_decision_record/reports/01_completeness-line-reopen-ruling.md
- **Artifacts**: plans/01_completeness-line-reopen-ruling.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

The research dispatch already delivered the ruling in full: Recommendation 8 stays in force for
all four routes, three of which (R2, R3-as-paper-research, R4's converse and guarded-until-form
sub-questions) were never actually blocked by it, R1 is held by the separate CSLib `require`
clause, and R4-Q2 is held by a literature-acquisition gap. This plan does not re-decide any of
that. It does the three things the dispatch asks for that the report does not yet fully carry:
discharge the Premise Re-Validation obligation against live state (one carried premise has gone
stale since the description was written), consolidate the per-route terms into a single
file-against-able section so a successor need not re-read four Findings sections or re-ask, and
close the task with a summary and the full gate set. No Lean, no task filing, no completeness
claim.

### Research Integration

The report's four route rulings are taken as given and are not re-argued. Two of its findings
drive concrete work here. First, its Context Extension Recommendation asks that a future record
state *which clause* of Recommendation 8 a route trips (engine-content vs. CSLib `require`)
rather than citing it as one undifferentiated bar — Phase 2 builds that discrimination into the
terms sheet, using the report's own R1/R2 contrast as the worked example. Second, its
Recommendation 5 names the report itself as the durable record and states that no amendment to
`specs/ROADMAP.md` is needed; both report-side phases therefore write into the report, and
ROADMAP.md is an explicit non-goal.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was supplied in this dispatch, so no roadmap consultation was performed and no
roadmap phases are added. `specs/ROADMAP.md` was read only to confirm a citation the report
makes (its "needs a fresh user ruling reversing that" sentence); it is not modified by this plan.

## Goals & Non-Goals

**Goals**:
- Discharge the dispatch's Premise Re-Validation obligation explicitly, stating the result for
  each carried claim including the ones that only confirm unchanged.
- Correct the one carried premise found stale at plan time, inside the report (the durable
  record), rather than leaving the correction only in a summary.
- Give the report a single consolidated reopening-terms section stating, per route and
  sub-route: the disposition, what may be filed, what stays barred, and the condition that would
  change the disposition.
- Close the task with a completion summary and the complete gate set, with the Issue Log
  obligation discharged or explicitly attested.

**Non-Goals**:
- **No Lean file is written or edited**, and no part of the Reynolds engine's §§7-15 is
  formalized, attempted, or filed. The guardrail is unchanged by anything in this plan.
- **No completeness claim.** Every reopening the report records leaves rows 17-21 of 879's
  ingredient table, and §§7-14, exactly as they were.
- **No edit to `specs/ROADMAP.md`.** The report's Recommendation 5 finds no amendment needed
  (the ruling does not change that sentence's truth), and ROADMAP.md is generated from
  `state.json`'s roadmap entries rather than hand-edited.
- **No filing of the R3 or R4 follow-on tasks.** The report's Recommendations 3 and 4 are
  conditional ("if R3 is wanted", "if R4 is wanted") on a preference this task does not own; the
  dispatch's deliverable is "a ruling with its argument, nothing else."
- **No backfill of the missing `topic: completeness` tag on tasks 931 and 932.** That is a
  `state.json` mutation outside this task's `file_scope: []` / report-only scope; Phase 1 records
  the observation, it does not act on it.
- **No re-derivation or condensation of the four founding reports** (879, 901, 902, 903). They
  are cited, per the dispatch's guardrail (d).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| The consolidated terms sheet introduces a disposition or condition not actually argued in the report's Findings, creating a second, divergent ruling | H | M | Phase 2's verification requires every row to cite the Findings subsection that carries its argument; a row that cannot cite one is a new claim and must be dropped, not written |
| A successor reads a REOPEN row as license to touch §§7-15 | H | M | The terms sheet's preamble states once, and each REOPEN row's "what stays barred" column states again, that Recommendation 8 remains in force for every route not explicitly reopened |
| Another carried figure beyond the one found at plan time has also gone stale, and the implementer trusts the plan's count instead of re-measuring | M | M | Phase 1 carries a Scope Hypothesis directing the implementer to re-run the lookups rather than adopt the plan-time count, and to record any additional stale figure found |
| Editing the report after its research dispatch closed makes the artifact inconsistent with its own stated completion timestamp | L | M | Both report-side phases append or amend clearly-labelled sections rather than rewriting Findings prose; `validate-artifact.sh` is run after each |
| Whether to file the R3/R4 follow-on tasks is left unresolved and reads as an omission | L | H | The summary states it explicitly as a deferred user preference, consistent with the report's own decision not to raise `user_decision`; it is not a blocker on this task's completion |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |

Phases within the same wave can execute in parallel.

### Phase 1: Premise Re-Validation and Record Correction [COMPLETED]

**Goal**: Discharge the dispatch's Premise Re-Validation obligation against live state and
correct, inside the report, the carried premise found stale.

**Tasks**:
- [x] Re-check the description's carried claim that "the completeness front currently has zero
      tasks of any kind: no active record carries topic `completeness`" against live
      `specs/state.json`. At plan time this measured as STALE: three active records carry
      `topic: completeness` (926 itself, 927, 928), and two further records on R2's route (931,
      932) are filed with no topic tag at all. Re-measure rather than adopting this figure.
      *(completed: re-measured against live state.json at implementation time; confirmed the
      same three-plus-two figure, no drift since plan time)*
- [x] Re-check each carried figure the report itself asserts, and record a confirmed/stale
      verdict for each: 901's Recommendation 8 two-clause wording; `specs/ROADMAP.md`'s "needs a
      fresh user ruling reversing that" sentence; 927's three landed declarations and their
      `[propext, Classical.choice, Quot.sound]` axiom profile; 928's ~1,000-line costing and fork
      siting; 906's Recommendation 4 wording on Q1's cost and the converse direction.
      *(completed: all six confirmed verbatim at their cited lines; no additional stale figure
      found)*
- [x] Add a clearly-labelled `## Premise Re-Validation` section to the report recording the
      result for every claim checked, including those that only confirm unchanged — per
      report-format.md's Carried-Figure Discipline, a confirmation is stated explicitly, not
      omitted as uninteresting. *(completed)*
- [x] For the stale "zero tasks" premise specifically, state what changed and why it does not
      disturb the ruling: the front gained tasks *because of* this task's own companions (927,
      928) and the two tasks 927 filed (931, 932), all on R2's never-barred route, so the premise
      that motivated the task is stale while every disposition it reached is unaffected.
      *(completed)*
- [x] Record the missing `topic: completeness` tag on 931 and 932 as an observation only; do not
      edit `state.json`. *(completed: recorded in the new section's closing paragraph, no
      state.json edit made)*
- [x] Record issues and wins as they arise via `bash .claude/scripts/issue-record.sh
      --task-dir "$TASK_DIR" --kind issue|win --class "..." --severity ... --what-happened "..."
      --phase implement --dispatch-seq <seq>`, non-fatally. *(completed: one `win` entry recorded
      — clean confirmation pass, no additional stale figure)*

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: prose

**Scope Hypothesis**: this phase hypothesizes exactly ONE stale carried figure (the "zero tasks"
premise), with every other claim listed above confirming unchanged. Confirm by re-running the
`state.json` topic query and the four grep lookups named in the report's Appendix; if an
additional stale figure is found, record it in the same section and say so rather than
preserving the count asserted here.

**Tier Justification**: `suite_selection_select` returns `__FULL_SWEEP__` for this phase's
`specs/**` path, so plan-format.md's sub-case (a) applies and the covering check is `bash
.claude/scripts/validate-artifact.sh specs/926_lean_completeness_line_reopen_decision_record/reports/01_completeness-line-reopen-ruling.md report`.

**Files to modify**:
- `specs/926_lean_completeness_line_reopen_decision_record/reports/01_completeness-line-reopen-ruling.md` - add a `## Premise Re-Validation` section; correct the stale "zero tasks" premise where Context & Scope restates it

**Verification**:
- `bash .claude/scripts/validate-artifact.sh specs/926_lean_completeness_line_reopen_decision_record/reports/01_completeness-line-reopen-ruling.md report` exits 0
- Diff read-through confirms every changed hunk lies in prose and no Findings argument was
  rewritten
- The new section names every carried claim listed above with an explicit confirmed-or-stale
  verdict, none omitted

---

### Phase 2: Consolidated Reopening-Terms Sheet [COMPLETED]

**Goal**: Give the report one section a successor can file against without re-reading the four
Findings sections or re-asking what the terms are.

**Tasks**:
- [x] Append a `## Reopening Terms` section to the report with one row per route and sub-route:
      R1; R2; R3; R4-Q1-as-stated; R4-Q1-converse; R4-guarded-until-form; R4-Q2. Each row carries
      the disposition (REOPEN / KEEP CLOSED / BLOCKED), what may be filed (task type and file
      scope), what stays barred, and the condition that would change the disposition.
      *(completed: all seven rows present exactly once, verified by grep count)*
- [x] For each KEEP CLOSED row, name which clause of 901's Recommendation 8 it trips — the
      engine-content clause ("do not file a Lean formalization of any part of §§7-15") or the
      separate CSLib `require` clause — rather than citing Recommendation 8 undifferentiated.
      This is the discrimination the report's own Context Extension Recommendation asks a future
      record to make; its R1/R2 contrast is the worked example.
      *(completed: R1 names the require clause, R4-Q1-as-stated names the engine-content clause)*
- [x] Cite, for every row, the Findings subsection that carries its argument. A row that cannot
      cite one is a new claim, not a consolidation: drop it rather than writing it.
      *(completed: every row's rightmost column cites its Findings subsection)*
- [x] State in the section's preamble, once, that Recommendation 8 stays in force for every route
      the ruling does not explicitly reopen, and that no reopening recorded here is a reversal of
      it. *(completed)*
- [x] For R2, state that the route is already executing under tasks 931 and 932 and that nothing
      further is owed here. *(completed)*
- [x] For R4-Q2, state that the block is literature acquisition (Di Maio-Zanardo 1998), not a
      ruling, and name the acquisition route rather than a research or Lean task. *(completed)*
- [x] Continue recording issues and wins as they arise. *(completed: nothing new arose in this
      phase beyond Phase 1's win entry; attested explicitly here)*

**Timing**: 0.75 hours

**Depends on**: 1

**Verification Tier**: prose

**Tier Justification**: `suite_selection_select` returns `__FULL_SWEEP__` for this phase's
`specs/**` path, so plan-format.md's sub-case (a) applies and the covering check is `bash
.claude/scripts/validate-artifact.sh specs/926_lean_completeness_line_reopen_decision_record/reports/01_completeness-line-reopen-ruling.md report`.

**Files to modify**:
- `specs/926_lean_completeness_line_reopen_decision_record/reports/01_completeness-line-reopen-ruling.md` - append a `## Reopening Terms` section

**Verification**:
- `bash .claude/scripts/validate-artifact.sh specs/926_lean_completeness_line_reopen_decision_record/reports/01_completeness-line-reopen-ruling.md report` exits 0
- All seven routes/sub-routes appear exactly once, each with a disposition, a file-against scope,
  a barred scope, and a change-condition
- Every KEEP CLOSED row names the specific clause it trips
- No row asserts a disposition or condition absent from the Findings section it cites

---

### Phase 3: Completion Summary and Gates [NOT STARTED]

**Goal**: Close the task with its completion summary and the complete gate set.

**Tasks**:
- [ ] Write `summaries/01_completeness-line-reopen-ruling-summary.md` per summary-format.md:
      the ruling in brief (one line per route), what the task did and did not do, the Premise
      Re-Validation result, and the deferred user preference on whether to file the R3/R4
      follow-ons.
- [ ] State in the summary that whether to file the R3 paper-research task and the R4
      converse/guarded-form task is a deferred preference, not a blocker, consistent with the
      report's decision not to raise `user_decision`.
- [ ] Confirm the guardrails held: no `.lean` file written or edited, no part of §§7-15
      formalized or filed, no completeness claim made, the four founding reports cited rather
      than re-derived.
- [ ] Discharge the Issue Log obligation: ensure entries were recorded as they arose, or attest
      explicitly in the summary prose that nothing arose during this phase.
- [ ] Run the complete gate set.

**Timing**: 0.5 hours

**Depends on**: 1, 2

**Verification Tier**: full

**Files to modify**:
- `specs/926_lean_completeness_line_reopen_decision_record/summaries/01_completeness-line-reopen-ruling-summary.md` - new completion summary

**Verification**:
- `bash .claude/scripts/verify-deploy.sh` runs green (the complete gate set; nothing is deferred
  past this tier)
- `bash .claude/scripts/validate-artifact.sh specs/926_lean_completeness_line_reopen_decision_record/reports/01_completeness-line-reopen-ruling.md report` exits 0
- `bash .claude/scripts/validate-artifact.sh specs/926_lean_completeness_line_reopen_decision_record/summaries/01_completeness-line-reopen-ruling-summary.md summary` exits 0
- `git status --short` shows no `.lean` file modified and no path touched outside
  `specs/926_lean_completeness_line_reopen_decision_record/`

## Testing & Validation

- [ ] Premise Re-Validation section states a verdict for every carried claim, confirmations
      included
- [ ] Reopening Terms section covers all seven routes/sub-routes with no new, uncited claim
- [ ] Every KEEP CLOSED row names which standing clause it trips
- [ ] `validate-artifact.sh` passes on both the report and the summary
- [ ] `verify-deploy.sh` runs green
- [ ] No `.lean` file modified; no path touched outside the task directory
- [ ] No completeness claim appears in any artifact

## Artifacts & Outputs

- `specs/926_lean_completeness_line_reopen_decision_record/reports/01_completeness-line-reopen-ruling.md` (amended: Premise Re-Validation, Reopening Terms)
- `specs/926_lean_completeness_line_reopen_decision_record/summaries/01_completeness-line-reopen-ruling-summary.md` (new)
- `specs/926_lean_completeness_line_reopen_decision_record/issues.jsonl` (appended as issues/wins arise)

## Rollback/Contingency

All edits are confined to markdown under `specs/926_lean_completeness_line_reopen_decision_record/`
and are committed per phase, so reverting any phase is a single `git revert` of that phase's
commit; the report's research-dispatch content is reachable at its prior commit throughout.
If Phase 1 finds the ruling's *substance* (not merely its motivating premise) disturbed by a
stale figure — for instance if one of 927's or 928's load-bearing findings no longer holds — stop
rather than patching: that is a record-correction question for a successor task, and this plan's
Phase 2 consolidation would otherwise propagate a disposition the evidence no longer supports.
Record it, mark the phase `[BLOCKED]` with the finding named, and return `blocked` rather than
writing the terms sheet.
