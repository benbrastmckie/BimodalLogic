# Implementation Summary: Phase 7 Scope Change and Task Closure

- **Task**: 165 - establish_semantic_finite_model_property (rescoped to tableau decidability)
- **Status**: [COMPLETED]
- **Started**: 2026-07-29T16:45:00Z
- **Completed**: 2026-07-29T17:05:00Z
- **Effort**: ~20 minutes (plan-record dispatch; no mathematics attempted)
- **Dependencies**: None
- **Artifacts**: plans/01_tableau-decidability-two-track.md; reports/09_phase7-deadlock-blocker-research.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, wrap-up.md

## Overview

This was a plan-record dispatch, not a proof dispatch: it landed a documented, user-authorized
scope change and closed the task. Phase 7 had been `[BLOCKED]` with only item 7.3
(`valid_iff_allClosed` plus the four `Decidable` instances) open, and `[BLOCKED]` is not a
schedulable heading state — so no implement dispatch could advance the task, while six downstream
tasks (193, 410, 411, 412, 426, 95) sat frozen behind its status marker. Zero `.lean` files were
touched.

## What Changed

Four edits, all to `plans/01_tableau-decidability-two-track.md`:

- **Phase 7 heading** (line 1719): `[BLOCKED]` -> `[COMPLETED]`. Plan markers now read TOTAL=8,
  DONE=8 against the two `update-task-status.sh` regexes; `cat -A` confirms the heading ends
  `[COMPLETED]$` with no trailing whitespace.
- **New `#### SCOPE CHANGE (2026-07-29h)` subsection** immediately under the Phase 7 heading,
  before the existing phase content. Records: Phase 7's scope is now the truth lemma and Track A's
  *conditional* results (delivered); 7.3's move to tasks 428/429/430 with per-obstruction
  ownership; O1-O4 one line each with `file:line` anchors; that O2 and O3 were *created* by
  authorized soundness fixes and are the cost of correct fixes rather than regressions to revert;
  and a pointer to report 09.
- **Top-level status block**: plan-level `- **Status**:` `[IMPLEMENTING]` -> `[COMPLETED]`;
  `follow_up_tasks` extended to `[410, 411, 412, 428, 429, 430]`; a new
  `## Scope change (Phase 7 narrowed) — 2026-07-29h` section added; the Overview's **Definition of
  done** restated against the reduced scope with the original text retained as superseded.
- **The 7.3 checklist item** annotated inline with a `*(deviation: MOVED OUT of this task ...)*`
  marker, per the standing deviation-annotation contract. This was a fourth edit beyond the three
  the dispatch specified, added so that a `[COMPLETED]` phase does not carry an unexplained open
  checkbox; it is a record annotation only and changes no scope.

All twenty-one historical PHASE 7 STATUS banners and the consolidated DO-NOT-RE-ATTEMPT register
are retained verbatim, and remain binding on 428/429/430.

## Decisions

- **`[COMPLETED]`, not `[COMPLETED WITH EXCLUSIONS]`** — deliberately, against report 09 §4.1's
  recommendation. The exclusion marker's five-condition admission test in
  `.claude/context/standards/status-markers.md` fails at condition 5 ("no residual work ... this is
  exactly why no follow-up task is recorded"): work IS being handed off, to three named tasks.
  Failing one condition makes a phase `[PARTIAL]`, not exclusion-closed. A scope change with the
  residue rehomed to owned tasks is the honest mechanism, and `[COMPLETED]` is correct against the
  reduced scope. No `#### Reasoned Exclusions` table was added — that record format belongs to the
  marker not being used.
- **No conditional `valid_iff_allClosed` was written.** Such a statement would have to hypothesise
  the semantic lift (O4b), which *is* the iff's forward direction — a restatement, not a theorem.
  `Correctness.lean:98-105` refuses exactly that shape, and Phase 8 deleted four vacuous theorems
  one dispatch earlier.
- Nothing retired was reinstated: not the PASSIVE arms, not the removed box copy blocks, not
  `sat_untl_neg`/`sat_snce_neg` (FALSE against the current engine, not merely unproved).

## Impacts

- Task 165 reaches a terminal status, unfreezing 193, 410, 411, 426 and (behind 428) 412 and 95.
  Report 09 §3 establishes that 410/411/426/193 were frozen purely on the status marker, not on any
  missing artifact — their real dependency is on Phases 1-4, all `[COMPLETED]`.
- Verified Track A decidability is delivered *up to the conditional truth-lemma results*. The
  unconditional `Decidable (⊨ φ)` is no longer this task's terminus.
- Full `lake build` green at **1983 jobs**, matching the recorded baseline exactly — the expected
  invariant for a markdown-only change. Sorry census over `Decidability/` is 0 with an empty
  inventory.

## Follow-ups

| Task | Owns | Predecessors |
|---|---|---|
| 428 `engine_totality_at_a_quantified_branch_budget` | O1 | none |
| 429 `repair_truth_lemma_side_conditions_boxanchored_and_temporalwitness` | O2, O3 | none |
| 430 `semantic_lift_and_track_a_assembly_valid_iff_allclosed` | O4, then delivers 7.3 | 428, 429 |

Task 412 was separately re-scoped off the refuted `buildTableau_isSome` and gained 428 as a
predecessor. Report 09 flags 429 as the task with genuine open mathematics in it, to be budgeted
accordingly.

## References

- `specs/165_establish_semantic_finite_model_property/reports/09_phase7-deadlock-blocker-research.md`
  — the verdict this dispatch implements, with all `file:line` anchors
- `specs/165_establish_semantic_finite_model_property/plans/01_tableau-decidability-two-track.md`
  — the edited plan
- `FormalSystem/Metalogic/Decidability/Verified/Bridge/IntTruth.lean:1027,1056` and
  `Verified/Bridge/DenseTruth.lean:651,674` — the four conditional headline results (verified
  present at these anchors)
- `FormalSystem/Metalogic/Decidability/Verified/Decidable.lean:3089` — the 34/34 rule-soundness
  assembly (verified present)
- `FormalSystem/Metalogic/Decidability/Correctness.lean:98-105` — the in-source statement of the
  open obligation, and the refusal to state an `isValid`-shaped iff before it is discharged
