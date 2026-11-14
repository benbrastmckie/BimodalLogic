# Implementation Summary: Task #927

- **Task**: 927 - Final frame step: remeasure against the landed cover
- **Status**: [COMPLETED]
- **Started**: 2026-11-13T18:00:00Z
- **Completed**: 2026-11-13T19:05:00Z
- **Effort**: ~1.1 hours
- **Dependencies**: None
- **Artifacts**: plans/01_final-frame-step-remeasure.md, reports/01_final-frame-step-remeasure.md, task-proposals.json, task-proposals-audit.ndjson
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

This is a measurement and record-correction task, report only, answering whether the completeness
paper proof's final-frame step is still open now that both Lean pieces it was said to need have
landed. The research dispatch delivered all four stated findings; this implementation dispatch
re-validated its carried figures against live source, attested each of the six guardrails
mechanically, extended the stale-anchor enumeration for the 901 report from four sites to seven,
and filed the two successor tasks this repository can own. No Lean file was written or edited, no
part of §§7-15 was formalized, and no report was amended in place.

## What Changed

No Lean source, no build file, no archived report and no `specs/ROADMAP.md` change — by design.
Every write is under `specs/**`.

- `specs/927_.../plans/01_final-frame-step-remeasure.md` — three new Notes sections: the
  carried-figure table, the eleven-declaration confirmation table, the guardrail attestation, the
  seven-anchor 901 enumeration, the decision-gate dispositions and the filing confirmation table.
- `specs/927_.../task-proposals.json` — the two successor proposals.
- `specs/927_.../task-proposals-audit.ndjson` — backlog-reconciliation evidence consumed by
  `state-write.sh --audit-verdict`.
- `specs/state.json` / `specs/TODO.md` — two new `not_started` entries appended via
  `state-write.sh` under its mutex (`+=` only, never a wholesale array assignment), TODO
  regenerated.
- `specs/927_.../summaries/01_final-frame-step-remeasure-summary.md` — this record.

### The four findings

1. **The landed trio discharges §15.3's step as 901 Finding 15 states it.**
   `exists_orientedForest_cover_of_constraints` (`UniversalCover.lean:591`),
   `saturation_of_orientedForest` (`OrientedForest.lean:880`) and
   `plus_invariance_of_isZTime_of_constraints` (`HistoryMorphism.lean:681`) compose sorry-free at
   axiom profile `[propext, Classical.choice, Quot.sound]`, verified against the landed
   declarations' actual signatures in source rather than against either report's prose.
2. **The source-side obligation is Compositionality, Seriality and Limit on the chronicle
   quotient, and none of the three is doubtful.** Two are free for any `ofStepRel`-generated
   relation over the integers; the third reduces exactly to the double seriality §13.1 already
   establishes from chronicle clause L1.
3. **901's ingredient row and "weakest link" Risks paragraph are stale, not wrong-at-the-time.**
   The 901 report was committed 2026-11-09 11:40 -0800; the universal cover landed 15:48 and the
   Saturation-free lift chain 17:32-17:56 the same day. The row was accurate when written and has
   been stale since that evening.
4. **The final-frame step is CONDITIONALLY DISCHARGED.** The condition is a named, compiled,
   four-lemma API refactor — presenting the chronicle quotient as a `FrameOver intOrder` without
   the *Saturation* that `ofStepSat` demands or the `[Finite W]` that `ofStep` demands — not an
   open mathematical question.

### Carried-figure re-validation (Phase 1)

The dispatch description's one numeric carried figure, `UniversalCover.lean` at 519 lines, is
**STALE**: the live measurement is **626**. The file grew after task 897 closed, when task 898
added the `_of_constraints` forms — including the very form this remeasurement depends on. Named
explicitly rather than silently corrected; the staleness does not touch the substance.

All eleven declarations the dispatch and report name were confirmed present at their recorded
line numbers by `grep -n` against source. Two incidental corrections to the dispatch's own prose:
the cover headline consumes `endpt_twoWayBounded_of_constraints` (`:523`), not the
`[F.IsRegular]` form `endpt_twoWayBounded` (`:550`) the dispatch names; and
`taskRel_eq_iter_of_constraints` is declared in `IntNormalForm.lean:259`, not in
`HistoryMorphism.lean` as the dispatch's piece-2 paragraph implies by adjacency.

### Guardrail attestation (Phase 1)

This task's first commit is `e30f23b81` (2026-11-13). All checks clean:
`git status --short -- FormalSystem/ Tests/ lakefile.toml lake-manifest.json` empty; the same
`git diff --stat` over this task's own commits empty; zero `.lean` files in
`git diff --name-only`; the archived 901 and 879 report diffs empty; `specs/ROADMAP.md` diff
empty. Guardrails (c), (d) and (f) attested by reading the report: the three probes live in its
Appendix as text and were never landed; Finding (4) is headed "CONDITIONALLY DISCHARGED" and
carries its own "What is NOT claimed" bullet; no blocker on quotient precision was raised.

### The 901 stale-anchor enumeration, extended (Phase 1)

The research report's Finding (3) enumerates four anchors. Phase 1's plan-time task list added
two more. Implementation-time measurement found a **seventh**: the `OrientedForest.lean:134`
citation inside §15.3's route prose (line 908), reached by neither. The successor therefore
receives a seven-row table with per-anchor disposition, plus two deliberate non-anchors — line
910's stale "two missing pieces" paragraph (whose replacement is the Risks amendment text) and
line 904's §15.2 assessment, which is **correct and load-bearing** and must not be touched.

### Successor tasks filed (Phase 2)

| # | Owns |
|---|---|
| **931** `apply_901_final_frame_amendments` (`general`) | Applies the record correction to the 901 report: Finding (3)'s verbatim replacement text plus the complete seven-anchor table from this plan's Phase 1 Notes. A record correction, not a completeness claim. |
| **932** `ofsteprel_named_constraint_lemmas_and_ofstepplain` (`lean4`) | Lands `ofStepRel_reflective`, `ofStepRel_compositional`, `ofStepRel_serial`, `ofStepRel_limit`, `ofStepPlain` and `ofStepPlain_taskRel` in `IntNormalForm.lean`, rewriting `ofStepSat` to cite them. This is finding (4)'s named condition; it is frame-presentation API and formalizes no part of §§7-15. |

Both carry `audit_verdict` evidence and a declared `file_scope`; both have `dependencies: []`. No
dependency edge was added in either direction: task 926 already declares `dependencies: [927,
928]` and consumes this task's *report*, which already exists.

## Decisions

- **The 901 amendment is filed, not applied** (guardrail (e)). Phase 1 nevertheless completed the
  work list, so filing hands forward a finished enumeration rather than a re-measurement.
- **Both proposals were filed unchanged after decision-gate inspection.** The
  `duplicate-of-open` against task 926 does not survive: 926's deliverable is a reopen/keep-closed
  *ruling* with `FILE SCOPE: none`, and a record correction to an archived report is neither. The
  six `overlaps-open` verdicts against proposal 2 are aggregator-only — every shared path is a
  generated surface (`typst/generated/status.typ`, `README.md`,
  `FormalSystem/Metalogic/README.md`) and no open task shares
  `FormalSystem/Semantics/IntNormalForm.lean`. Narrowing would have defeated the Condition 1
  obligation the proposal deliberately inherits.
- **Task 932's `file_scope` carries the two coupled generated surfaces by design**, so the
  obligation is inherited at filing time rather than discovered at that task's first commit:
  `typst/generated/status.typ`'s `formalsystem-line-count` is pre-commit-**blocking** and must be
  regenerated in the same phase as the line-count change.

## Plan Deviations

- None (implementation followed plan). Two in-scope extensions were made within the plan's own
  instructions rather than against them: a seventh 901 anchor was found at implementation time
  beyond the six the plan's task list named (the plan directs recording live discrepancies rather
  than editing blind), and the plan's 902-derived 128 KB argv lesson was measured as no longer
  binding rather than applied unexamined.

## Verification

- Build: **N/A** — no Lean file was written or edited by any phase, and
  `git diff --name-only e30f23b81^..HEAD | grep -c '\.lean$'` returns **0**. There is no compile
  or elaboration surface in this task's output to build.
- Sorry count: **0** (no Lean source touched)
- Vacuous count: **0** (no Lean source touched)
- Axiom count: **unchanged** (no Lean source touched)
- Tests: scoped suite run — see the batch-deferral note below
- Files verified: Yes

| Check | Result |
|---|---|
| `validate-artifact.sh … plans/01_final-frame-step-remeasure.md plan` | **exit 0**, 0 warnings |
| `validate-artifact.sh … summaries/01_final-frame-step-remeasure-summary.md summary` | **exit 0** |
| `validate-state.sh` | **exit 0** (10 passed, 25 warnings, 0 failed), cycle check included |
| `git status --short -- FormalSystem/ Tests/ lakefile.toml lake-manifest.json` | **empty** |
| Combined `git diff --stat` over this task's commits for Lean, build-file, archived-report and ROADMAP paths | **empty** |
| `grep -cE '\]\(' specs/TODO.md` | **0** — bracket-only artifact links |

**Batch gate deferral, recorded rather than claimed.** This dispatch carries a
`## Batch Gate Deferral` directive, so the complete gate set was **not** independently run here;
it runs once for the whole batch at the end of the invocation, attributed back to this task by
its `modified_files`. The plan's Phase 3 criterion names `verify-deploy.sh`, which is an
**unmappable criterion** for this phase: that script compares the deployed `.claude/` tree
against the source store, and this task touched no file under `.claude/` or `agent-system/` — no
`--only-gate N` selection reaches `specs/**` artifact or state validity. Per the directive's
unmappable-criterion clause the named check was therefore run directly, scoped to this phase's
own touched surfaces, as the scoped discharge: `run-all.sh --only` over the three suites covering
the tools this task exercised (`test-validate-artifact.sh`, `test-validate-state.sh`,
`test-audit-task-proposals.sh`), plus the per-artifact validators above. The criterion was
neither waived nor treated as satisfied by a narrowing that does not reach it.

The only `validate-state.sh` warning naming either new task is the standing
`Unknown entry field: audit_verdict` warning, which already names thirteen other entries
including 926, 927 and 928 — pre-existing baseline, not introduced here. All other warnings are
legacy `file_scope`-missing and roadmap-batch findings outside this task's file scope.

## Impacts

The completeness paper proof's one acknowledged gap is now **conditionally discharged** rather
than open, with the condition filed as task 932. The 901 report's stale record has a finished,
seven-anchor correction work list filed as task 931. Task 926, the completeness-line reopen
decision record, already depends on this task and can now weigh its route R2 against a measured
verdict instead of a stale "missing" row.

**What is deliberately not done, each with its reason, so none reads as an oversight:**

- **No `.lean` file written or edited** — guardrail (b). The report's three probes stay in its
  Appendix as text; the composition was elaborated through `lean_run_code` and reported as a
  finding, not landed.
- **No part of §§7-15 formalized, attempted or filed** — guardrail (c). 901's Recommendation 8 is
  untouched. Task 932 is frame-presentation API in `IntNormalForm.lean` whose proofs already
  exist inline in `ofStepSat`'s body; it formalizes no chronicle, hue, ban, lull or truth-lemma
  content.
- **No in-place edit of the 901 or 879 report** — guardrail (e). The amendment is filed, not
  applied.
- **No `specs/ROADMAP.md` amendment.** Its final-frame sentence states a standing *ruling*, not a
  staleness claim about the two landed pieces; the ruling's disposition is task 926's deliverable,
  and task 928 was dispatched concurrently with an undeclared `file_scope` that could include
  that file.
- **No `frame-presentation.md` context file filed.** The research report's own Context Extension
  Recommendation makes it conditional — worth writing only if the API refactor is *not* done —
  and the refactor is filed as task 932.
- **No redeploy of the stale `.claude/` tree.** The dispatch reports extension `core` as stale;
  the remedy is a whole-tree regeneration belonging to its own task, and no phase here
  regenerates the tree.

**Finding (4) positive does NOT make T3 complete.** Rows 17-21 of the ingredient table remain
paper, §§7-14 remain paper, and (O1), (O3) and (O4) are untouched by anything here. The gap this
closes is the one §15 itself acknowledged, and no other. The 901 report's own refusal — "This
write-up does not claim the final-frame step; it claims the engine up to it" — is reframed by the
filed amendment, not lifted.

## Follow-ups

- Task **931** applies the 901 record correction (seven anchors, work list complete).
- Task **932** lands the four `ofStepRel` constraint lemmas plus `ofStepPlain`, discharging
  finding (4)'s named condition.
- The research report's second recommendation — recording `final_frame_step_ztime` (probe C's
  statement) as §15's obligation in its compiled form, in whatever record tracks §15's status —
  is **not** filed here: the record that tracks §15's status is the 901 report, whose amendment
  is task 931's, and whose ruling disposition is task 926's. Named so it is not lost.
- Two incidental dispatch-prose corrections (the `endpt_twoWayBounded` form and
  `taskRel_eq_iter_of_constraints`'s file) are recorded in this plan's Phase 1 Notes; neither
  needs its own task.

## References

- `specs/927_final_frame_step_remeasure_against_landed_cover/reports/01_final-frame-step-remeasure.md`
- `specs/927_final_frame_step_remeasure_against_landed_cover/plans/01_final-frame-step-remeasure.md`
- `specs/927_final_frame_step_remeasure_against_landed_cover/task-proposals.json`
- `specs/927_final_frame_step_remeasure_against_landed_cover/task-proposals-audit.ndjson`
- `specs/archive/901_two_sided_reynolds_engine_paper_proof/reports/01_two-sided-reynolds-engine-paper-proof.md`
- `specs/archive/897_universal_cover_oriented_forest_two_way_bounded/`
- `specs/archive/898_plus_invariance_base_without_saturation/`
