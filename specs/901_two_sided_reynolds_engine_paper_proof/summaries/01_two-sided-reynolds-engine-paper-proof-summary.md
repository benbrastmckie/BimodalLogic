# Implementation Summary: Two-Sided Reynolds Engine Paper Proof, L-plus at ZTime

- **Task**: 901 - Paper proof of the two-sided Reynolds engine for L-plus at ZTime: ban preservation, fair scheduling, universal non-acceptance, truth lemma
- **Status**: [COMPLETED]
- **Started**: 2026-11-09T19:49:00Z
- **Completed**: 2026-11-09T20:20:00Z
- **Effort**: 3.0 hours
- **Dependencies**: None
- **Artifacts**: reports/01_two-sided-reynolds-engine-paper-proof.md, plans/01_two-sided-reynolds-engine-paper-proof.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

The task's deliverable is the research report (`reports/01_two-sided-reynolds-engine-paper-proof.md`,
written in an earlier dispatch and never touched here): the two-sided transposition of Reynolds
2001's CTL* completeness engine closes for L-plus over ZTime, and in a shape the prior architecture
did not predict — two one-sided engines hinged at the clock cut, each verbatim Reynolds (one under
`reflectTime`), interacting only at the anchor ≡-class, with the level split as the design of record
and the interleaved form reported as failing at a named step. This plan is a **record-and-handoff
plan**: its four phases land that write-up's consequences in the records other tasks read, file the
two questions this repository can own, and close out, taking none of the actions the write-up
explicitly declines.

The deliverable is a **paper proof** at the source's level of rigour, not a machine-checked theorem.
One step — the final frame, through the universal cover — rests on two unlanded pieces (the universal
cover construction and a base-frame truth-transfer theorem). No completeness claim is made for T1,
T2, or T3 anywhere in this task's artifacts.

## What Changed

- `specs/879_lplus_ztime_completeness_tm_plus_lc_programme/reports/01_lplus-ztime-completeness-programme.md`
  — amended in two phases, 14 hunks total, two new dated amendment notes:
  - **Phase 1** (9 hunks): ingredient row 2 (`LCU` and mirror, declared and ZTime-valid) and its
    seven dependent assertions move from **missing** to **landed**, citing `lcU`
    (`PlusLanguage/PlusLCSchema.lean:248`), `lcU_plusValidInt` (`:409`), `lcU_plusValidZTime`
    (`:464`), `lcU_reflectTime_plusValidZTime` (`:486`), and task 893. Touched: the declaration-
    inventory row, the `ExtSound` sentence, Finding 2.3's consequence (i), the stage-D and stage-I
    rows, ingredient row 2, the P1 backlog-audit note, and the executive summary's deliverable-3
    bullet (missing count 9 → 8).
  - **Phase 2** (5 hunks): Finding 2.4's automaton-initialisation reading is marked correct but
    avoidable in favour of the first-transition formulation (Finding 5.4); its consumption-point
    sentence splits into (S1) the state-level cut index and (S2) PS/US pasting's conditional-
    badness tautology (Finding 4.3), with neither substituting for the other; ingredient rows 8 and
    9 gain second consumers (the alphabet collapse of Findings 1.3/4.4, and derivable separation of
    Lemma 7.2, respectively) with their `**missing**` Status cells left byte-identical; the
    Cross-Domain Synthesis sentence is restated across three registers (order-theoretic, logical,
    combinatorial) instead of "pays for itself exactly once."
- `specs/901_two_sided_reynolds_engine_paper_proof/task-proposals.json` — new; the two filed
  proposals in `audit-task-proposals.sh`'s four-key shape.
- `specs/901_two_sided_reynolds_engine_paper_proof/task-proposals-audit.ndjson` — new; the full,
  committed backlog-reconciliation evidence (465 verdicts for (Q3), 490 for (Q1)).
- `specs/state.json`, `specs/TODO.md` — two new `not_started` entries: **905**
  (`eliminate_cross_certification_two_sided_reynolds_automata`, (Q3)) and **906**
  (`lcu_derivability_from_lcn_non_ztime_separating_model`, (Q1)), each with its `audit_verdict`
  evidence and declared `file_scope: []`.
- No file under `FormalSystem/` or `Tests/`, and neither `lakefile.toml` nor `lake-manifest.json`,
  was touched by any of this task's own commits (verified per-commit, not merely by a window-wide
  diff — see Verification).

## Decisions

- The two located paper questions are filed as separate tasks rather than one, since each has a
  distinct deliverable shape (an elimination-or-load-bearing argument for (Q3); a derivation-or-
  separating-model for (Q1)) and a distinct settling route.
- (Q2) — whether the three naming rules are admissible in the rule-free system — is **recorded,
  not filed**: Recommendation 7 asks only that it stay framed as admissibility rather than
  soundness, and names no settling route an agent could be dispatched against; the landed
  `clock_irr_sound`/`irr_sound` bear on soundness, not admissibility, so filing it as partial
  progress would overstate the position.
- Every `duplicate-of-open`/`subset-of-open` verdict surfaced by the backlog audit was dismissed
  rather than acted on (see Phase 3's plan notes for the per-verdict reasoning): all five
  non-trivial candidates (901 self-reference, and 430/543/869/875 against (Q1)) scored
  0.41-0.51, below the sibling task 902's calibrated ~0.62 credible-match threshold, and none
  named cross-certification or the LCU/`LC_n` derivability question on inspection.
- The full `audit-task-proposals.sh` NDJSON (145-159 KB) could not be passed to
  `state-write.sh --audit-verdict` directly (shell argument-length limit via `jq --argjson`); a
  trimmed verdict object (proposal plus non-`scope-blind` verdicts only) was passed instead, since
  the audit-evidence gate only requires a matching `.proposal.id`. The full, unabridged NDJSON is
  committed separately as the evidence record.
- Recommendations 4 and 8 are standing no-ops, executed as such: the level split is not filed as a
  Lean item (a chronicle-*definition* change, behind (O1)/(O3), with no reachable target), and the
  CSLib `require` question is not re-opened.

## Plan Deviations

- None (implementation followed plan). The only departures from the plan's literal text were
  cosmetic: the amendment note was placed below the existing 903 note rather than the 902 note
  named in Phase 1's task text (903's note is itself already directly below 902's, so the new note
  still lands at the top of the chronological stack), and Phase 2's hunk count came in at 5 rather
  than the hypothesized "at most 7" because two of the six named anchors turned out to share a
  single line and a seventh anchor's text was byte-identical to prose already amended elsewhere —
  both are recorded in the Phase 1/2 plan notes as measured outcomes, not scope changes.

## Impacts

- The architecture report (`specs/879_.../reports/01_lplus-ztime-completeness-programme.md`) now
  states the true landed/missing split: 8 missing ingredient rows instead of 9, with `LCU`'s
  declaration and ZTime validity no longer misreported as absent. The Lean NO-GO's ground — the
  (O1)/(O3)/(O4) determinization obstruction — is unmoved: `grep -c 'NO-GO on a Lean proof'`
  returns 2 before and after, unchanged across both phases, and ingredient row 16 (the
  determinization gap) is byte-identical throughout.
- Two new research tasks (905, 906) are available for future dispatch, each with backlog
  evidence already attached and a declared `file_scope: []` signalling report-only, no-Lean work.
- No downstream consumer of the architecture report's stale `LCU`-missing claim is left pointing
  at a wrong fact; any future reader of ingredient row 2, the P1 backlog-audit note, or the
  executive summary's "Missing:" list sees the current, landed status.

## Follow-ups

- Task 905: settle whether the forward/backward Rabin automata's clause-(a) cross-certification
  is eliminable (cheap; chronicle-clauses-only).
- Task 906: settle `LCU`'s derivability from TM-plus + `LC_n` at ZTime via a non-ZTime separating
  model (first target: `.Base`, since no ZTime countermodel can separate the two schemata).
- (Q2) — the three naming rules' admissibility in the rule-free system — remains recorded but
  unfiled, per Recommendation 7; no settling route is currently known.
- A Lean formalization of any part of this write-up's §§7-15 remains blocked on the located
  (O1)/(O3) obstruction (specs/902's report) and is not to be filed until that obstruction is
  resolved.

## Verification

- `bash .claude/scripts/validate-artifact.sh specs/879_lplus_ztime_completeness_tm_plus_lc_programme/reports/01_lplus-ztime-completeness-programme.md report` exits 0 after both amendment phases.
- `bash .claude/scripts/validate-artifact.sh specs/901_two_sided_reynolds_engine_paper_proof/plans/01_two-sided-reynolds-engine-paper-proof.md plan` — run and PASS.
- `bash .claude/scripts/audit-task-proposals.sh` exited 0 over the proposals file; its NDJSON is committed.
- `bash .claude/scripts/validate-state.sh` exits 0 (19 pre-existing warnings, unrelated to this task's two new entries; 0 failures).
- `git status --short -- FormalSystem/ Tests/ lakefile.toml lake-manifest.json` is empty at this task's HEAD.
- Per-commit confirmation (not merely a window-wide diff, which would include concurrent sibling
  tasks sharing this working tree): `git show --stat <commit> -- FormalSystem/ Tests/
  lakefile.toml lake-manifest.json` is empty for all three of this task's own phase commits
  (`d06366364`, `8c486968c`, `ccff8ca7f`). No `.lean` file was created or modified, and no `lake`
  invocation was made, by any phase of this task.
- The amended architecture report still asserts the Lean NO-GO (`grep -c 'NO-GO on a Lean proof'`
  returns 2, unchanged) and nowhere claims T1, T2, or T3.
- **Batch Gate Deferral**: this dispatch is one of several `implement`-phase dispatches inside one
  multi-task `/orchestrate` batch invocation, and the dispatch file (`.dispatch/6.md`) carries a
  `## Batch Gate Deferral` directive for this plan's final (`full`-tier) phase. Per that directive,
  the complete `verify-deploy.sh` gate set was **not** independently run here; instead, the scoped
  narrowing invocation `bash .claude/scripts/tests/run-all.sh --only
  test-audit-task-proposals.sh,test-validate-artifact.sh,test-validate-state.sh,test-update-plan-status.sh,test-plan-file-scope-harvest.sh`
  — covering every script this task's phases actually exercised — was run and passed (5 passed, 0
  failed, 0 skipped). The full gate set is deferred to the once-per-invocation batch stage, not
  forgiven, per `context/formats/plan-format.md`'s "Batch-aware deferral" subsection.

## Deliberately Not Done

- **No Lean formalization of any part of the write-up's §§7-15.** The located obstruction
  (O1)/(O3) — determinization to a deterministic Rabin automaton, and the existential-over-`Type`
  shape of every determinization result — is unresolved, and nothing in this write-up moves it.
- **No level-split Lean item filed.** Recommendation 4: the level split is a change to the
  chronicle *definition*, and every chronicle stage is `paper` and behind (O1)/(O3) — filing it
  would create a Lean task with no reachable target.
- **No CSLib `require` added, and the question not re-opened.** Recommendation 8 is a standing
  no-op; `lakefile.toml` and `lake-manifest.json` are untouched by this task's own commits.
- **No edit under `FormalSystem/` or `Tests/` by any phase of this plan** (`Lean Intent: false`,
  honoured; see Verification for the per-commit confirmation).
- **(Q2) recorded rather than filed**, per Recommendation 7: no settling route is named, and the
  landed soundness results do not bear on the admissibility question it actually asks.
- **No redeploy of the stale `.claude/` tree.** The dispatch reports six extensions as stale
  relative to the source store; a redeploy is a whole-tree-regeneration claim belonging to its own
  task, not this one, and no phase of this plan lists the reserved whole-tree sentinel.

## References

- `specs/901_two_sided_reynolds_engine_paper_proof/reports/01_two-sided-reynolds-engine-paper-proof.md` — the task's deliverable (unchanged by this plan).
- `specs/879_lplus_ztime_completeness_tm_plus_lc_programme/reports/01_lplus-ztime-completeness-programme.md` — amended across Phases 1-2.
- `specs/901_two_sided_reynolds_engine_paper_proof/plans/01_two-sided-reynolds-engine-paper-proof.md` — this task's implementation plan, with per-phase notes.
- `specs/901_two_sided_reynolds_engine_paper_proof/task-proposals.json`, `…/task-proposals-audit.ndjson` — the two filed proposals and their backlog evidence.
- `specs/902_reassess_lplus_ztime_nogo_cslib_omega_automata/reports/01_cslib-omega-automata-nogo-reassessment.md` — the (O1)/(O3)/(O4) Lean-obstruction report this task's write-up inherits as settled.
