# Implementation Plan: Task #927

- **Task**: 927 - Final frame step: remeasure against the landed cover
- **Status**: [IMPLEMENTING]
- **Effort**: 2 hours
- **Dependencies**: None
- **Research Inputs**: `specs/927_final_frame_step_remeasure_against_landed_cover/reports/01_final-frame-step-remeasure.md`
- **Artifacts**: plans/01_final-frame-step-remeasure.md (this file)
- **Standards**:
  - `context/formats/plan-format.md`
  - `context/standards/status-markers.md`
  - `context/standards/artifact-management.md`
  - `context/formats/summary-format.md`
  - `context/standards/git-staging-scope.md`
  - `context/patterns/backlog-reconciliation.md`
  - `context/project/lean4/patterns/plan-authoring-gate-collisions.md`
  - `rules/state-management.md`, `rules/git-workflow.md`, `rules/pr-prohibition.md`
- **Type**: lean4
- **Lean Intent**: false

## Overview

The research dispatch already delivered all four of this task's stated findings: the landed
composition discharges the final-frame step as §15 states it (finding 1), the source-side
obligation is three constraints on the chronicle quotient of which none is doubtful (finding 2),
901's ingredient row and Risks paragraph are stale rather than wrong-at-the-time with amendment
text supplied (finding 3), and the step is conditionally discharged on a four-lemma API refactor
(finding 4). Nothing substantive remains to be *found*.

What remains is to hand the report's consequences forward intact, under guardrails that forbid
this task from acting on most of them itself: guardrail (b) bars writing or editing any Lean
file, guardrail (c) bars formalizing any part of §§7-15, and guardrail (e) bars editing the 901
or 879 reports in place. Accordingly this is a measure-attest-and-hand-off plan, not an
implementation plan in the usual sense. It re-validates the dispatch's own carried figures
against live source, attests that the research dispatch honored every guardrail, enumerates the
complete set of stale anchors in the 901 report (including two the research report's Finding (3)
did not reach), files the two successor tasks this repository can own, and writes a close-out
record that states explicitly what is deliberately not done and why. No `.lean` file, no build
file, and no report under `specs/archive/` is touched by any phase.

### Research Integration

The report is the sole substantive input; every phase consumes a named part of it rather than
re-deriving anything.

- **Finding (3)** supplies *verbatim* amendment text for 901's ingredient-table row (line 110 at
  plan time), its adjacent citation row (line 109), its "weakest link" Risks paragraph (line
  1001), and a one-clause correction to the companion Risks paragraph (line 1002). Phase 1
  re-locates each anchor live and enumerates the two further drifted-citation sites the report's
  Finding (3) did not enumerate; Phase 2 hands the whole list to a successor. **No phase applies
  any of it** — guardrail (e).
- **Finding (2) and the Recommendations** supply the four `ofStepRel` constraint lemmas
  (`ofStepRel_reflective`, `ofStepRel_compositional`, `ofStepRel_serial`, `ofStepRel_limit`), the
  `ofStepPlain` constructor and its `TaskRel` equation, each with a compiled, sorry-free proof
  body transcribed verbatim in the report's Appendix (probe A). Phase 2 files that refactor as a
  `lean4` successor task carrying those proofs by reference. **No phase writes them here** —
  guardrail (b).
- **Finding (1) and (4)** are the task's verdict and need no further action beyond being stated
  accurately in the close-out record: conditionally discharged, condition named, and explicitly
  not a completeness claim. Phase 3 carries that framing.
- **The report's Context Extension Recommendation** (a `frame-presentation.md` context file) is
  recorded as deliberately not filed, with the report's own reason: it is redundant if the API
  refactor lands, and the refactor is what Phase 2 files.

### Prior Plan Reference

No prior plan for this task. The structural precedent followed here is
`specs/archive/902_reassess_lplus_ztime_nogo_cslib_omega_automata/plans/01_cslib-omega-automata-nogo-reassessment.md`
(`[COMPLETED]`), which solved the same shape of problem — a report-only research task whose
implementation phases are record work, task filings and a close-out summary. Four calibrations
are carried from it as *lessons*, not as copied phases:

1. Its Phase 2 measured that `state-write.sh --audit-verdict` is subject to a 128 KB per-argv
   ceiling and that a multi-proposal audit file must then be sliced per proposal. Phase 2 below
   names the slice remedy up front.
2. Its Phase 2 measured that `--allocate-into` derives its number from membership rather than
   from the `next_project_number` cache, so each allocated number must be read from the script's
   own output. Phase 2 below reads it that way.
3. Its Phase 1 recorded a verification criterion that was *unsatisfiable by its own task list* —
   "each anchor grep still matches once" after a step whose job was to replace that very text.
   Phase 1 below states anchor criteria as a before/after disposition table instead, never as an
   unchanged count.
4. Its Phase 1 recorded a process deviation: the `[IN PROGRESS]` marker was not set before the
   first edit. Every phase below sets its marker first.

Effort calibration: 902's four phases of this character came in at 2.75 hours. This plan has
three phases, one of them measurement-only with no amendment application, and is estimated at
2 hours.

### Roadmap Alignment

No `roadmap_path` and no `roadmap_flag` were supplied in this dispatch, so no roadmap-review or
roadmap-update phase is present. `specs/ROADMAP.md` exists and carries, at line 160 at plan time,
the sentence placing "the two-sided truth lemma and the final-frame assembly" under 901's
Recommendation 8 as a **paper** proof. That sentence is a statement of a standing *ruling* about
what may not be formalized, not a staleness claim about the two Lean pieces, so this task's
finding does not overturn it. No phase here amends it, for three reasons stated once and carried
into Non-Goals: the ruling's disposition belongs to task 926 (the completeness-line reopen
decision record, which depends on this task and on 928 and whose explicit remit is route R2);
task 928 is dispatched concurrently with an **undeclared** `file_scope` and could legitimately be
writing the same file; and a ROADMAP amendment is a judgement this measurement task has no
mandate to make.

## Goals & Non-Goals

**Goals**:

- Every carried figure in this task's own dispatch description is re-validated against live
  source, with the one stale figure named explicitly rather than silently corrected, and each
  declaration the dispatch names is confirmed present at a measured line number.
- Each of the six guardrails (a)-(f) is attested as honored, by a mechanical check where one
  exists — in particular that no file under `FormalSystem/` or `Tests/`, and neither
  `lakefile.toml` nor `lake-manifest.json`, was modified by any dispatch of this task, and that
  neither the 901 nor the 879 report was edited in place.
- The complete set of stale anchors in the 901 report is enumerated with live line numbers and a
  per-anchor disposition, extending the research report's Finding (3) by the drifted-citation
  sites it did not reach, so a successor applying the amendment has a finished work list and
  re-measures nothing.
- Two successor tasks exist as filed `not_started` entries with backlog-reconciliation evidence
  on each: one applying the 901 amendment, one landing the four named `ofStepRel` constraint
  lemmas plus the `ofStepPlain` constructor in `FormalSystem/Semantics/IntNormalForm.lean` with
  `ofStepSat` rewritten to cite them.
- A close-out record states the verdict in the report's own words — conditionally discharged, the
  condition named — and states explicitly, so that none reads as an oversight, that no Lean file
  was written, no part of §§7-15 was formalized, no report was amended in place, no ROADMAP
  sentence was touched and no completeness claim is made.

**Non-Goals**:

- No `.lean` file is created or modified anywhere, and no probe file is landed. This plan
  declares `Lean Intent: false`. The report's three probes stay where guardrail (b) put them: in
  the report's Appendix, as text.
- No part of §§7-15 of the Reynolds engine is formalized, attempted or filed. 901's
  Recommendation 8 stands untouched; the refactor filed in Phase 2 is frame-presentation API in
  `IntNormalForm.lean` that formalizes no chronicle, hue, ban, lull or truth-lemma content, and
  its filed description says so.
- No in-place edit of `specs/archive/901_two_sided_reynolds_engine_paper_proof/reports/01_*.md`
  or of the 879 completeness-programme report — guardrail (e). The amendment is handed forward,
  not applied.
- No amendment to `specs/ROADMAP.md`, for the three reasons given under Roadmap Alignment.
- No completeness claim, and no statement that T3 is complete or closer to complete. Rows 17-21
  remain paper; (O1), (O3) and (O4) are untouched.
- No ruling, reopening, or narrowing of 901's Recommendation 8. That is task 926's deliverable,
  and this task is one of its two inputs.
- No redeploy of the stale `.claude/` tree. The dispatch reports core as stale; the remedy is a
  whole-tree regeneration that is not this task's work, and no phase here declares the
  whole-tree sentinel because no phase regenerates the tree.
- No PR, no push, no `gh`/`glab` write operation (`rules/pr-prohibition.md`).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| The close-out record is read as a completeness claim, or finding (4) is read as flatly "discharged" | H | M | The condition is named in Phase 3's summary tasks, in the Goals above, and in the filed refactor task's own description. The summary states the verdict in the report's words ("conditionally discharged"), names the condition in the same sentence, and carries a paragraph stating what is NOT claimed. |
| Filing the `ofStepRel` refactor is read as a Recommendation 8 violation | H | L | The refactor touches only `FormalSystem/Semantics/IntNormalForm.lean`'s frame-presentation API, whose proofs already exist inline in `ofStepSat`'s body; it formalizes no part of §§7-15. The filed description states this explicitly, and Phase 2's decision gate drops or narrows the proposal if inspection of task 926's remit shows otherwise. |
| A filed task duplicates or is subsumed by an open one — 926 (decision record) and 928 (cost assessment) are both open and both name the final-frame step | M | M | `audit-task-proposals.sh` runs over both proposals before any write, and `state-write.sh`'s audit-evidence gate refuses the write unless a verdict object covers each. Phase 2 names 926 and 928 for inspection by number and narrows or drops on a surviving `duplicate-of-open`/`subset-of-open` rather than filing unchanged. |
| Task 928 is dispatched on the same working tree with `scope_declared: false` and may write `specs/state.json`, `specs/TODO.md` or `specs/ROADMAP.md` concurrently | M | H | `state-write.sh` serializes under its own mutex and Phase 2 appends with `+=` only, never a wholesale `.active_projects = [...]`. Every file is re-read immediately before editing; staging is by explicit path with no directory or glob pathspec; `git-snapshot.sh` is never run in its reverting default mode. A foreign commit or foreign uncommitted hunk is reported and the phase stops, per the dispatch's territory note. |
| The 901 anchor enumeration drifts between Phase 1's measurement and the successor's application | M | M | The enumeration is recorded as a text-anchor table (the matched string plus its disposition), not as line numbers alone, and the filed task's description instructs the successor to re-locate by content. Line numbers are recorded as plan-time measurements, explicitly labelled as such. |
| The successor refactor task trips the two coupled generated surfaces a Lean line-count change moves | M | H | Per `context/project/lean4/patterns/plan-authoring-gate-collisions.md` Condition 1, the filed task's `file_scope` names `typst/generated/status.typ` (pre-commit-blocking, must be regenerated in the same phase as the line-count change) alongside `README.md` and `FormalSystem/Metalogic/README.md` (deferrable to a reconciliation phase), so the obligation is inherited at filing time rather than discovered at that task's first commit. |
| `verify-deploy.sh` reports a red gate that is pre-existing and unrelated to this task | M | M | Per Condition 2's corollary, Phase 3's criterion is phrased to distinguish findings naming this task's own touched files from the tree's standing baseline, never as a bare "the gate passes". A gate whose only findings are pre-existing and outside this task's file scope is a recorded PASS with those findings enumerated. |
| The dispatch's deploy-freshness warning (core stale) tempts a redeploy mid-plan | L | L | Declared a non-goal. A redeploy is a whole-tree-regeneration claim belonging to its own task; no phase lists the reserved whole-tree sentinel because no phase regenerates the tree. |
| The full gate set is unavailable in this dispatch | L | M | Phase 3 follows a `## Batch Gate Deferral` directive if the dispatch carries one, recording the deferral in the summary's Verification section rather than claiming a gate run that did not happen. |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |

Phases within the same wave can execute in parallel; this plan is a strict chain. Phase 2's filed
descriptions cite Phase 1's anchor enumeration and its guardrail attestation, and Phase 3's
close-out record cites Phase 2's allocated task numbers, so no two phases here are genuinely
independent and none is presented as such.

### Phase 1: Premise Re-Validation, Guardrail Attestation, and the Full 901 Anchor Enumeration [COMPLETED]

**Goal**: This plan's Phase 1 Notes carry (i) each of the dispatch's carried figures re-measured
against live source with its verdict, (ii) a mechanical attestation that guardrails (a)-(f) were
honored, and (iii) the complete stale-anchor table for the 901 report, so that the successor
filed in Phase 2 re-measures nothing.

**Tasks**:
- [ ] Set this phase's heading marker to `[IN PROGRESS]` before the first edit.
- [ ] Re-measure the dispatch's one numeric carried figure: `wc -l FormalSystem/Semantics/UniversalCover.lean`.
  The dispatch description asserts 519 lines, carried from task 897's landing; the plan-time
  measurement is **626**. Record the measured value and the verdict (stale, grew after 897 when
  898 added the `_of_constraints` forms), explicitly rather than silently — the figure's staleness
  does not touch the substance, and saying so is part of the record.
- [ ] Confirm each declaration the dispatch and the report name is present, recording the live
  line number for each by `grep -n` against source, never against a report's description of it
  (guardrail (a)). Plan-time measurements, to be re-confirmed not trusted:
  `exists_orientedForest_cover_of_constraints` (`UniversalCover.lean:591`),
  `exists_orientedForest_cover` (`:617`), `coverFrameOfSerial` (`:475`), `coverFrame` (`:500`),
  `endpt_surjective` (`:409`), `endpt_twoWayBounded` (`:550`),
  `endpt_twoWayBounded_of_constraints` (`:523`),
  `plus_invariance_of_isZTime_of_constraints` (`HistoryMorphism.lean:681`),
  `plus_invariance_of_isZTime` (`:707`), `saturation_of_orientedForest`
  (`OrientedForest.lean:880`), `FrameOver.ofStepSat` (`IntNormalForm.lean:563`). Note that the
  dispatch names `endpt_twoWayBounded` while the constraint-form the cover headline actually
  consumes is `endpt_twoWayBounded_of_constraints`; both exist, and the record says which is which.
- [ ] Attest guardrail (b) and the dispatch's `FILE SCOPE: none` mechanically:
  `git status --short -- FormalSystem/ Tests/ lakefile.toml lake-manifest.json` is empty, and
  `git diff --stat <this task's first commit>^..HEAD -- FormalSystem/ Tests/ lakefile.toml lake-manifest.json`
  is empty. Record both outputs.
- [ ] Attest guardrail (e): `git diff --stat <this task's first commit>^..HEAD -- specs/archive/901_two_sided_reynolds_engine_paper_proof/ specs/archive/879_lplus_ztime_completeness_tm_plus_lc_programme/`
  is empty. Record the output.
- [ ] Attest guardrails (c), (d) and (f) by reading the research report rather than by a grep:
  (c) no §§7-15 formalization exists anywhere in this task's output — the probes live in the
  report's Appendix as text and no `.lean` file was added; (d) the report's finding (4) states
  "conditionally discharged" and its own "What is NOT claimed" paragraph preserves rows 17-21 as
  paper; (f) the report records that §15.1 and §13.1 state the quotient precisely enough and that
  no blocker was raised. Record one sentence per guardrail.
- [ ] Enumerate the stale anchors in
  `specs/archive/901_two_sided_reynolds_engine_paper_proof/reports/01_two-sided-reynolds-engine-paper-proof.md`
  (1084 lines at plan time), recording for each the matched text, its live line number and its
  disposition. The anchors confirmed present at plan time, with the first four being the ones the
  research report's Finding (3) enumerates and the last two being sites it did **not** reach:
  - `the two Lean pieces the final-frame step needs` (line 110) — the `**missing**` ingredient
    row; replacement text supplied verbatim by Finding (3).
  - `` `OrientedForest.lean:134`, `HistoryMorphism.lean:589` `` (line 109) — the adjacent row's
    drifted citations; Finding (3) supplies the corrected pair (`:880`, `:707`).
  - `Risk: the final-frame step is the weakest link` (line 1001) — the Risks paragraph; Finding
    (3) supplies a full dated replacement.
  - `one step (the final frame) resting on two unlanded pieces` (line 1002) — the companion Risks
    paragraph, which Finding (3) rules **still accurate** apart from this one clause.
  - `OrientedForest.lean:134`, `HistoryMorphism.lean:589` at line 1047 — the same drifted citation
    pair inside the evidence/status table. **Not enumerated by Finding (3).**
  - `Semantics/OrientedForest.lean:134` and `Semantics/HistoryMorphism.lean:306,589` at line 1075
    — the same drift in the reads list. **Not enumerated by Finding (3).**
  Also record, as a deliberate non-anchor, that line 910's "**The two missing pieces, named.**"
  paragraph is stale and that Finding (3) directs its replacement to be the Risks amendment text,
  and that line 904's §15.2 assessment of why the quotient's own *Saturation* is doubtful is
  **correct and load-bearing** and must not be touched.
- [ ] Record an issue-log entry for this phase (`win` or `issue`) via
  `bash .claude/scripts/issue-record.sh --task-dir "$TASK_DIR" --kind ... --phase implement --dispatch-seq <seq>`,
  or attest in the Phase 1 Notes that nothing arose.
- [ ] After `git status --short` confirms no sibling's uncommitted hunks are mixed in, commit this
  plan by explicit path (`git-commit-phase.sh`, or `git-commit-scoped.sh ... -- <path>`); never a
  directory or glob pathspec.

**Timing**: 0.5 hours

**Depends on**: none

**Verification Tier**: prose

**Tier Justification**: the only file this phase changes is this plan under `specs/**`, with zero
compile or elaboration surface, so no Lean suite covers it; the covering check is
`bash .claude/scripts/validate-artifact.sh specs/927_final_frame_step_remeasure_against_landed_cover/plans/01_final-frame-step-remeasure.md plan`
exiting 0, together with the `prose` tier's diff read-through confirming every hunk lies inside
the new Phase 1 Notes section.

**Scope Hypothesis**: exactly one file changes in this phase (this plan), gaining exactly one new
`#### Phase 1 Notes` section plus the phase heading's marker transition. The figures asserted
above are plan-time measurements carried from two records and must be re-derived, not trusted:
`UniversalCover.lean` at 626 lines against the dispatch description's asserted 519 (the carried
figure under test); the eleven declaration line numbers above, carried from this task's own
research report and re-measured at plan time by `grep -n`; and the 901 report at 1084 lines with
six anchors at lines 110, 109, 1001, 1002, 1047 and 1075, four of them carried from the research
report's Finding (3) and two measured fresh at plan time. Confirm by re-running each `grep -n`
and `wc -l` at implementation time; if an anchor's line has moved or its text is absent, record
the live value and the discrepancy rather than editing blind.

**Files to modify**:
- `specs/927_final_frame_step_remeasure_against_landed_cover/plans/01_final-frame-step-remeasure.md` - new `#### Phase 1 Notes` section: the carried-figure table, the guardrail attestation, the six-anchor enumeration

**Verification**:
- `bash .claude/scripts/validate-artifact.sh specs/927_final_frame_step_remeasure_against_landed_cover/plans/01_final-frame-step-remeasure.md plan` exits 0.
- `git status --short -- FormalSystem/ Tests/ lakefile.toml lake-manifest.json` is empty, and the `git diff --stat` over this task's own commits for the same paths is empty.
- `git diff --stat` over this task's own commits for `specs/archive/901_.../` and `specs/archive/879_.../` is empty.
- The Phase 1 Notes name the measured `UniversalCover.lean` line count and state the 519-line dispatch figure's verdict in words.
- The Phase 1 Notes carry one row per declaration with a live line number, and one row per 901 anchor with its matched text and disposition, including the two sites Finding (3) did not enumerate.
- `git diff --staged --name-only` names only this plan file.

#### Phase 1 Notes

All measurements below were taken live at implementation time against working-tree source, never
against a report's description of them (guardrail (a)).

**Carried-figure re-validation.**

| Carried figure | Source of the claim | Measured live | Verdict |
|---|---|---|---|
| `FormalSystem/Semantics/UniversalCover.lean` is 519 lines | dispatch description line 6, carried from task 897's landing | **626** (`wc -l`) | **STALE.** The file grew by 107 lines after 897 closed, when task 898 added the `_of_constraints` forms. The staleness does not touch the substance of either task 897's or the dispatch's claim — the headline `exists_orientedForest_cover` is present and the `_of_constraints` form the remeasurement actually depends on is one of the additions that moved the count. Recorded explicitly rather than silently corrected. |
| Guardrails (a)-(f), dispatch description line 21 | dispatch description | attested below | **ACCURATE**, all six honored. |

**Declaration confirmation.** Every declaration the dispatch and the research report name is
present in source at the line recorded. All eleven plan-time line numbers re-confirmed unchanged.

| Declaration | File | Live line | Note |
|---|---|---|---|
| `exists_orientedForest_cover_of_constraints` | `FormalSystem/Semantics/UniversalCover.lean` | 591 | the constraint-form headline the remeasurement composes |
| `exists_orientedForest_cover` | `FormalSystem/Semantics/UniversalCover.lean` | 617 | the `[F.IsRegular]` specialisation |
| `coverFrameOfSerial` | `FormalSystem/Semantics/UniversalCover.lean` | 475 | takes `TaskFrame.Serial F.TaskRel`, no base class binder |
| `coverFrame` | `FormalSystem/Semantics/UniversalCover.lean` | 500 | `[F.IsRegular]` specialisation |
| `endpt_surjective` | `FormalSystem/Semantics/UniversalCover.lean` | 409 | |
| `endpt_twoWayBounded` | `FormalSystem/Semantics/UniversalCover.lean` | 550 | `[F.IsRegular]` form; **this is the one the dispatch names** |
| `endpt_twoWayBounded_of_constraints` | `FormalSystem/Semantics/UniversalCover.lean` | 523 | constraint form; **this is the one the cover headline actually consumes** |
| `plus_invariance_of_isZTime_of_constraints` | `FormalSystem/Semantics/HistoryMorphism.lean` | 681 | no base `def:frame` binder |
| `plus_invariance_of_isZTime` | `FormalSystem/Semantics/HistoryMorphism.lean` | 707 | retains `[F.IsRegular]` on the base, unread |
| `saturation_of_orientedForest` | `FormalSystem/Semantics/OrientedForest.lean` | 880 | a primed variant `saturation_of_orientedForest'` sits at 837; the unprimed form is the one cited |
| `FrameOver.ofStepSat` | `FormalSystem/Semantics/IntNormalForm.lean` | 563 | the presentation whose *Saturation* demand is finding (4)'s condition |

Two incidental corrections to the dispatch's own prose, recorded under guardrail (a) and not
affecting any finding:

- The dispatch names `endpt_twoWayBounded` among the pieces task 897 landed. Both forms exist; the
  constraint-form headline consumes `endpt_twoWayBounded_of_constraints` (`:523`), not the
  `[F.IsRegular]` form (`:550`). The record says which is which.
- The dispatch's piece-2 paragraph attributes `taskRel_eq_iter_of_constraints` to "the
  `HistoryMorphism.lean` lifting chain" by adjacency. It is in fact declared in
  `FormalSystem/Semantics/IntNormalForm.lean:259`. The declaration exists as claimed; only its
  file attribution was loose.

**Guardrail attestation.** This task's first commit is `e30f23b81` (2026-11-13, `task 927:
complete research`). See the Phase 1 issue-log entry for why a bare
`git log --grep='^task 927'` cannot be used to derive it: three further commits dated 2026-02-25
carry the same `task 927:` prefix and belong to a prior vault generation's unrelated task.

| Guardrail | Check | Result |
|---|---|---|
| (b) no Lean file written or edited; `FILE SCOPE: none` | `git status --short -- FormalSystem/ Tests/ lakefile.toml lake-manifest.json` | **empty** |
| (b) same, across this task's own commits | `git diff --stat e30f23b81^..HEAD -- FormalSystem/ Tests/ lakefile.toml lake-manifest.json` | **empty** |
| (b) corollary | `git diff --name-only e30f23b81^..HEAD \| grep -c '\.lean$'` | **0** |
| (e) no in-place edit of the 901 or 879 report | `git diff --stat e30f23b81^..HEAD -- specs/archive/901_.../ specs/archive/879_.../` | **empty** |
| (non-goal) no ROADMAP amendment | `git diff --stat e30f23b81^..HEAD -- specs/ROADMAP.md` | **empty** |

The complete set of files this task's commits touch is `specs/927_.../` artifacts, `specs/TODO.md`
and `specs/state.json` — plus `specs/928_.../` artifacts, which belong to the concurrently
dispatched sibling and are not this task's writes.

Guardrails (c), (d) and (f), attested by reading the research report rather than by a grep:

- **(c) no formalization of any part of §§7-15.** None exists anywhere in this task's output. The
  three probes live in the report's Appendix (lines 414-529) as text; they were elaborated through
  `lean_run_code` and never landed, and the `.lean` count above is zero.
- **(d) no completeness claim.** The report's Finding (4) is headed "CONDITIONALLY DISCHARGED" and
  carries its own "**What is NOT claimed**" bullet preserving rows 17-21 as paper and leaving (O1),
  (O3) and (O4) untouched.
- **(f) no blocker on quotient precision.** The report did not need the chronicle quotient stated
  more precisely than §15 states it: Finding (2) resolves the source-side obligation from §13.1's
  double seriality and §15.1's statement, and raises no blocker.

**The 901 stale-anchor enumeration.** Target:
`specs/archive/901_two_sided_reynolds_engine_paper_proof/reports/01_two-sided-reynolds-engine-paper-proof.md`,
**1084 lines** live (matching the plan-time figure). All six anchors confirmed at their plan-time
line numbers, and one further site found that neither Finding (3) nor this plan's task list
reached. Line numbers are implementation-time measurements; a successor re-locates **by content**.

| # | Matched text (anchor) | Line | Disposition |
|---|---|---|---|
| 1 | `the two Lean pieces the final-frame step needs` (the `**missing**` ingredient row) | 110 | **Replace.** Verbatim replacement supplied by report Finding (3). |
| 2 | `` `OrientedForest.lean:134`, `HistoryMorphism.lean:589` `` (adjacent compiled row) | 109 | **Correct citations** to `` `OrientedForest.lean:880`, `HistoryMorphism.lean:707` ``. Supplied by Finding (3). |
| 3 | `Risk: the final-frame step is the weakest link` | 1001 | **Replace.** Full dated replacement paragraph supplied by Finding (3). |
| 4 | `one step (the final frame) resting on two unlanded pieces` | 1002 | **One-clause correction** to "one step (the final frame), now resting on landed pieces". Finding (3) rules the rest of this paragraph **still accurate**; its substantive claim (no machine checking of the whole) survives and is load-bearing. |
| 5 | `OrientedForest.lean:134`, `HistoryMorphism.lean:589` inside the evidence/status table | 1047 | **Correct citations** (`:880`, `:707`). **Not enumerated by Finding (3).** |
| 6 | `Semantics/OrientedForest.lean:134` … `Semantics/HistoryMorphism.lean:306,589` in the reads list | 1075 | **Correct citations**: `:134`→`:880`, `:306`→`:335` (`exists_preimage_step_neg`, measured live), `:589`→`:707`. **Not enumerated by Finding (3).** |
| 7 | `saturation_of_orientedForest` (compiled, `OrientedForest.lean:134`) inside §15.3's route prose | 908 | **Correct citation** (`:134`→`:880`). **Found at implementation time; reached by neither Finding (3) nor this plan's plan-time task list.** This extends the enumeration from six anchors to seven. |

Two deliberate non-anchors, recorded so a successor does not treat either as an oversight:

- **Line 910**, `**The two missing pieces, named.**` — stale by the same measure as anchors 1 and
  3. Finding (3) directs its replacement to be the Risks amendment text of anchor 3 rather than a
  separate rewrite. It also carries the drifted `HistoryMorphism.lean:589` citation, which the
  replacement text supersedes.
- **Line 904**, §15.2's assessment of why the quotient's *own* *Saturation* is doubtful (countably
  infinite slices; the quotient is not an oriented forest, so `saturation_of_orientedForest` does
  not apply directly). **Correct and load-bearing — must not be touched.** It is the reason the
  cover route exists at all, and the research report's Recommendations say so explicitly.

The amendment must also preserve the 901 report's own refusal to claim the step ("This write-up
does not claim the final-frame step; it claims the engine up to it"), which appears inside anchor
3's paragraph: the replacement reframes what is landed, it does not lift the refusal.

**Issue log.** One `issue` recorded for this phase (class `tooling/ambiguous-anchor`, severity
`minor`): the task-number collision across vault generations described under Guardrail attestation
above, which produced a false guardrail-(b) violation before being caught.

---

### Phase 2: File the Two Owned Successor Tasks, With Backlog Evidence [COMPLETED]

**Goal**: Two new `not_started` entries exist in `specs/state.json`, each carrying
backlog-reconciliation evidence in its own `audit_verdict` field and a declared `file_scope`: one
to apply the 901 amendment, one to land the named `ofStepRel` API. `TODO.md` renders both.

**Tasks**:
- [ ] Set this phase's heading marker to `[IN PROGRESS]` before the first write.
- [ ] Write `specs/927_final_frame_step_remeasure_against_landed_cover/task-proposals.json` as a
  two-element JSON array, each element carrying exactly the four keys
  `{id, title, description, file_scope}` that `audit-task-proposals.sh` consumes:
  - `id: "apply_901_final_frame_amendments"`, `task_type` `general`,
    `file_scope: ["specs/archive/901_two_sided_reynolds_engine_paper_proof/reports/01_two-sided-reynolds-engine-paper-proof.md"]`.
    The description must (i) point at this task's report Finding (3) as the source of the verbatim
    replacement text for the ingredient row, the adjacent citation row, and the Risks paragraph,
    and of the one-clause correction to the companion Risks paragraph; (ii) point at this plan's
    Phase 1 Notes for the complete six-anchor table including the two drifted-citation sites at
    lines 1047 and 1075 that Finding (3) does not enumerate; (iii) instruct re-location by content
    rather than by line number; (iv) state that line 904's §15.2 assessment is correct and must
    not be touched, and that the amendment preserves the report's own refusal to claim the step
    ("This write-up does not claim the final-frame step") rather than lifting it; and (v) state
    that the amendment is a record correction, not a completeness claim.
  - `id: "ofsteprel_named_constraint_lemmas_and_ofstepplain"`, `task_type` `lean4`,
    `file_scope: ["FormalSystem/Semantics/IntNormalForm.lean", "typst/generated/status.typ", "README.md", "FormalSystem/Metalogic/README.md"]`.
    The description must (i) name the five declarations to land — `ofStepRel_reflective`,
    `ofStepRel_compositional`, `ofStepRel_serial`, `ofStepRel_limit`, `ofStepPlain` — plus the
    `ofStepPlain_taskRel` equation, with their compiled bodies cited by reference to this task's
    report Appendix probe A rather than restated; (ii) state that `ofStepSat` is to be rewritten
    to cite them (`ofStepPlain` wrapped by `ofReflectiveRegular`) rather than to duplicate them,
    so the transcription cannot diverge, and that no existing signature changes; (iii) record the
    `▸`-transport idiom the report's Tactic Survey isolates (prove constraints as bare-relation
    lemmas and transport, never by rewriting a frame's `TaskRel` in place); (iv) state explicitly
    that this is frame-presentation API in `IntNormalForm.lean` and formalizes **no** part of
    §§7-15, so 901's Recommendation 8 is untouched; and (v) carry the Condition 1 obligation in
    words — a Lean line-count change trips `typst/generated/status.typ`'s
    `formalsystem-line-count` (pre-commit-**blocking**, regenerate via
    `scripts/typst-sync-check.sh --fix` in the SAME phase as the line-count change) and the
    module-inventory blocks in `README.md` and `FormalSystem/Metalogic/README.md` (checked later,
    regenerate via `scripts/check-module-invariants.sh --emit-inventory`), which is why all three
    are in its `file_scope`.
- [ ] Run `bash .claude/scripts/audit-task-proposals.sh --proposals-file specs/927_final_frame_step_remeasure_against_landed_cover/task-proposals.json`
  and write its output to
  `specs/927_final_frame_step_remeasure_against_landed_cover/task-proposals-audit.ndjson`. Read
  the verdicts in full.
- [ ] Decision gate: proceed on `genuinely-new` or an aggregator-only `overlaps-open`. The tasks
  to inspect by number on a surviving `duplicate-of-open` or `subset-of-open` are **926** (the
  completeness-line reopen decision record, which depends on this task and whose remit is the
  ruling, not the record correction or the API), **928** (the determinization cost assessment,
  dispatched concurrently) and **927 itself** (a self-match is expected, since both proposals are
  drawn from this task's own report, and does not survive inspection on its own). Narrow
  `file_scope`/scope and re-run the audit with the same `id`, or drop and record the reason in
  the Phase 2 Notes. Do not file unchanged.
- [ ] Record the pre-filing baseline: `jq '.active_projects | length' specs/state.json` and
  `jq '.next_project_number' specs/state.json`. `--allocate-into` derives its number from
  membership, not from this cache, so read each allocated number from the script's own output.
- [ ] Re-read `specs/state.json` immediately beforehand (task 928 is live on this tree), then file
  the two entries, one `state-write.sh` call each, appending with `+=` only — never a wholesale
  `.active_projects = [...]` — with `title`/`description`/`file_scope` verbatim from
  `task-proposals.json`, `dependencies: []` on both, `priority: "medium"`, `artifacts: []`,
  `next_artifact_number: 1`:
  `bash .claude/scripts/state-write.sh '.active_projects += [{project_number: $n, project_name: "<id>", status: "not_started", task_type: "<general|lean4>", title: "<title>", description: "<description>", file_scope: <file_scope>, dependencies: [], priority: "medium", created: $now, last_updated: $now, next_artifact_number: 1}]' --session-id "$session_id" --allocate-into n --arg now "$(date -u +%Y-%m-%dT%H:%M:%SZ)" --audit-verdict specs/927_final_frame_step_remeasure_against_landed_cover/task-proposals-audit.ndjson --regen-todo`.
  If the audit payload trips the 128 KB per-argv ceiling, pass a one-line per-proposal slice of
  the committed audit file to each call instead.
- [ ] Add **no** dependency edge in either direction by default: neither successor is consumed by
  926's ruling (926 consumes this task's *report*, which already exists) and neither blocks the
  other. If inspection at the decision gate shows 926 would read a successor's output rather than
  this report, append that edge via `state-write.sh` under the mutex with a `+=` on 926's
  `dependencies` — `update-task-status.sh --depends-on-add` has no no-status-change token for a
  `not_started` task — and confirm with
  `jq '.active_projects[] | select(.project_number==926) | .dependencies' specs/state.json`.
  Record either way in the Phase 2 Notes.
- [ ] Verify each new entry: `project_name` equals its proposal `id`; `audit_verdict` is present;
  `file_scope` matches the declared list; `dependencies` is `[]`.
- [ ] Run `bash .claude/scripts/validate-state.sh` and read its output in full; exit 0 required.
- [ ] Render a confirmation table (allocated number, title, task type, `file_scope`, dependencies,
  backlog check with `scope-blind` reported as a count) into this plan's Phase 2 Notes.
- [ ] Record an issue-log entry for this phase (`win` or `issue`), or attest in the Phase 2 Notes
  that nothing arose.
- [ ] After `git status --short` confirms no sibling's uncommitted hunks are mixed in, commit
  `specs/state.json`, `specs/TODO.md`, the two new evidence files and this plan by explicit path.

**Timing**: 0.75 hours

**Depends on**: 1

**Verification Tier**: local

**Tier Justification**: the edit is confined to `specs/state.json`, the `specs/TODO.md` view
generated from it, two new evidence files under this task's own directory and this plan's notes;
`bash .claude/scripts/validate-state.sh` is the whole-file consistency lint for exactly that pair,
including the Check 12 allocation invariant `--allocate-into` writes against and the
dependency-cycle check, so no broader suite is claimed and none is needed.

**Scope Hypothesis**: exactly two new `active_projects` entries are added, `next_project_number`
is regenerated past them, and no existing entry changes unless the decision gate adds the one
optional 926 edge. Two new files appear under this task's directory. Baseline carried from a
plan-time read of `specs/state.json`: `.active_projects | length` is 49 and
`next_project_number` is 931, with 926, 927 and 928 all present and non-terminal; re-read both
immediately before filing rather than trusting these, since task 928 is live on this same tree and
may have filed entries in between. Confirm by diffing `jq '.active_projects | length'` before and
after (+2) and by `validate-state.sh` exiting 0; if the decision gate drops or narrows a
proposal, the count is lower and the Phase 2 Notes say which and why.

**Files to modify**:
- `specs/927_final_frame_step_remeasure_against_landed_cover/task-proposals.json` - new; the two proposals, four keys each
- `specs/927_final_frame_step_remeasure_against_landed_cover/task-proposals-audit.ndjson` - new; the audit output consumed by `--audit-verdict`
- `specs/state.json` - append two `active_projects` entries via `state-write.sh` under the mutex; no wholesale array assignment
- `specs/TODO.md` - regenerated by `--regen-todo`; never hand-edited
- `specs/927_final_frame_step_remeasure_against_landed_cover/plans/01_final-frame-step-remeasure.md` - new `#### Phase 2 Notes` section: the confirmation table with allocated numbers

**Verification**:
- `bash .claude/scripts/validate-state.sh` exits 0, cycle check included.
- Two new entries exist, each with `project_name` equal to its proposal `id`, an `audit_verdict` field, and the declared `file_scope`; the `lean4` entry's `file_scope` names all four paths including `typst/generated/status.typ`.
- `jq -e . specs/927_final_frame_step_remeasure_against_landed_cover/task-proposals.json` succeeds and the array has two elements; every line of the audit NDJSON is `jq -e .`-valid.
- `specs/TODO.md` renders both new tasks with bracket-only artifact-link format and no `[name](path)` links.
- `git diff --staged --name-only` names only the five files above, and `git status --short` shows no foreign uncommitted hunk mixed into the commit.
- `git status --short -- FormalSystem/ Tests/ lakefile.toml lake-manifest.json` is empty.

#### Phase 2 Notes

**Baseline, read immediately before filing.** `.active_projects | length` = **49**;
`next_project_number` = **931** — both matching the plan-time figures, so task 928 filed nothing
in between. After both filings: length **51** (+2, as hypothesized), `next_project_number`
**933**. Allocated numbers were read from `state-write.sh`'s own output, not from the
`next_project_number` cache.

**Decision gate.** `audit-task-proposals.sh` was run over both proposals before any write. Both
proposals drew 449 `scope-blind` verdicts each — reported as a count per the script's own
presentation guidance, not expanded. The open-side verdicts, and their disposition:

| Proposal | Verdict | Against | Mech. class | Score | Disposition |
|---|---|---|---|---|---|
| `apply_901_final_frame_amendments` | `duplicate-of-open` | **926** `lean_completeness_line_reopen_decision_record` | `scope-blind` (926 declares `file_scope: []`) | 0.40 | **Does not survive inspection.** 926's description reads "DECISION RECORD ONLY … The deliverable is a ruling with its argument, nothing else", with `FILE SCOPE: none. Report only.` Its deliverable is a reopen/keep-closed ruling on routes R1-R4; applying a record correction to an archived report is neither a ruling nor within its file scope. The match is Pass-2 vocabulary overlap (901, final-frame, Recommendation 8) — exactly the recall-biased over-inclusion the matcher documents. **Filed unchanged.** |
| `apply_901_final_frame_amendments` | `duplicate-of-open` | **927** (this task) | `none` | 0.50 | **Expected self-match**, the proposal being drawn from this task's own report. Does not survive on its own: guardrail (e) bars this task from applying the amendment, which is why it is filed. **Filed unchanged.** |
| `ofsteprel_named_constraint_lemmas_and_ofstepplain` | `overlaps-open` ×6 | 763, 761, 177, 410, 543, 869 | `overlap` | 0.17-0.32 | **Aggregator-only overlap — the gate's stated proceed condition.** Every shared path is one of the three generated/aggregator surfaces (`typst/generated/status.typ`, `README.md`, `FormalSystem/Metalogic/README.md`). **No open task shares `FormalSystem/Semantics/IntNormalForm.lean`**, the proposal's substantive target. Narrowing `file_scope` to remove the shared paths would defeat the Condition 1 obligation this proposal deliberately inherits, so it is **filed unchanged**. |

Task 928 was inspected and is unrelated to both proposals: it is report-only, costing
`Muller.toRabin_exists`, and the matcher flagged no verdict against it.

**Confirmation table.**

| # | `project_name` | Type | Status | `file_scope` | Deps | Backlog check |
|---|---|---|---|---|---|---|
| **931** | `apply_901_final_frame_amendments` | `general` | `not_started` | the 901 report (1 path) | `[]` | 449 `scope-blind`; 2 `duplicate-of-open` (926, 927) inspected and not surviving |
| **932** | `ofsteprel_named_constraint_lemmas_and_ofstepplain` | `lean4` | `not_started` | `IntNormalForm.lean`, `typst/generated/status.typ`, `README.md`, `FormalSystem/Metalogic/README.md` | `[]` | 449 `scope-blind`; 6 `overlaps-open`, all aggregator-only |

Both entries carry an `audit_verdict` field (`state-write.sh`'s audit-evidence gate accepted
each), both `project_name`s equal their proposal `id`, and both `file_scope`s match the declared
lists verbatim.

**No dependency edge added, in either direction.** Task 926 already declares
`dependencies: [927, 928]` and consumes this task's **report**, which already exists; neither
successor is an input to 926's ruling, and neither blocks the other. Inspection of 926's remit at
the decision gate confirmed this rather than overturning it, so no `+=` on 926's `dependencies`
was issued.

**Validation.** `bash .claude/scripts/validate-state.sh` exits **0** (10 passed, 25 warnings, 0
failed), cycle check included. The only warning naming 931 or 932 is the standing
`Unknown entry field: audit_verdict` warning, which already names thirteen other entries
including 926, 927 and 928 — a pre-existing schema-modelling gap, not introduced here. Check 12's
allocation invariant passes at 933. `specs/TODO.md` renders both new tasks; `grep -cE '\]\('`
over it returns **0**, so no markdown-format artifact link is present.

**Issue log.** One `win` recorded for this phase (class `tooling/scaling-fix-held`, severity
`none`): the 902-derived lesson that a multi-proposal `--audit-verdict` file must be sliced
against a 128 KB per-argv ceiling is **no longer binding** — `state-write.sh` now normalizes the
file through a private temp file and re-passes it via `--argjson-file` specifically to survive a
large one, and the 349 KB audit file here was accepted. Per-proposal slicing was still used
(each filing is a separate call needing only its own verdict line) but was not forced by a
ceiling. Recorded so the lesson is discharged rather than carried forward unexamined.

---

### Phase 3: Close-Out Record and Final Gate [NOT STARTED]

**Goal**: The task's close-out record exists, states the verdict with its condition in the
report's own words, names the two filed successors, and states explicitly what was deliberately
not done; and the repository passes its gate set with no Lean source, build file or archived
report touched by any phase of this task.

**Tasks**:
- [ ] Set this phase's heading marker to `[IN PROGRESS]` before the first write.
- [ ] Write `specs/927_final_frame_step_remeasure_against_landed_cover/summaries/01_final-frame-step-remeasure-summary.md`
  per `summary-format.md` (all required headings verbatim), covering:
  - The four findings in four sentences: (1) the landed trio discharges §15.3's step as stated,
    on a compiled sorry-free composition at axiom profile `[propext, Classical.choice, Quot.sound]`;
    (2) the source-side obligation is *Compositionality*, *Seriality* and *Limit* on the chronicle
    quotient, of which two are free for any `ofStepRel`-generated relation over the integers and
    the third reduces exactly to the double seriality §13.1 establishes from chronicle clause L1,
    so none is doubtful; (3) 901's ingredient row and "weakest link" Risks paragraph are stale
    rather than wrong-at-the-time, the report having preceded both landings by four to six hours
    on the same day; (4) the step is **conditionally discharged**, the condition being a named,
    compiled, four-lemma API refactor rather than an open mathematical question.
  - The Phase 1 carried-figure verdict (the dispatch's 519-line figure for `UniversalCover.lean`
    is stale against a measured 626) and the guardrail attestation.
  - The Phase 2 confirmation table with the allocated numbers, and a one-line statement of what
    each successor owns.
  - An explicit paragraph recording what is deliberately **not** done, each with its reason, so
    none reads as an oversight: no `.lean` file written or edited (guardrail b); no part of
    §§7-15 formalized or filed (guardrail c, 901 Recommendation 8 untouched); no in-place edit of
    the 901 or 879 report (guardrail e — the amendment is filed, not applied); no `specs/ROADMAP.md`
    amendment (its final-frame sentence states a standing ruling, whose disposition is task 926's
    deliverable, and task 928 is concurrent with undeclared scope); no `frame-presentation.md`
    context file (the report's own reason: redundant if the filed refactor lands); and no
    redeploy of the stale `.claude/` tree.
  - A sentence stating plainly that finding (4) positive does **not** make T3 complete: rows
    17-21 remain paper and (O1), (O3) and (O4) are untouched (guardrail d).
  - Link this task's report and this plan under `## References`.
- [ ] Confirm no library, build-file or archived-report change across the whole task:
  `git status --short -- FormalSystem/ Tests/ lakefile.toml lake-manifest.json` is empty, and
  `git diff --stat <this task's first commit>^..HEAD -- FormalSystem/ Tests/ lakefile.toml lake-manifest.json specs/archive/901_two_sided_reynolds_engine_paper_proof/ specs/archive/879_lplus_ztime_completeness_tm_plus_lc_programme/ specs/ROADMAP.md`
  is empty.
- [ ] Run the complete gate set: `bash .claude/scripts/verify-deploy.sh` from the repository root
  (its target argument is a deploy-tree root, never an extension subdirectory). Read the output in
  full; do not infer a pass from the absence of visible errors. Classify every finding as either
  naming a file this task touched or pre-existing and outside this task's file scope, and record
  the classification — a gate whose only findings are pre-existing is a recorded PASS with those
  findings enumerated, not a blocker and not grounds to edit an out-of-scope file. If this
  dispatch carries a `## Batch Gate Deferral` directive, follow it and record the deferral in the
  summary's Verification section instead of claiming a gate run that did not happen.
- [ ] Record a closing issue-log entry (`win` or `issue`) for this phase, or attest in the summary
  that nothing arose.
- [ ] Write `.orchestrator-handoff.json` and `.return-meta.json` (`status: "implemented"`,
  `dispatch_seq` echoed verbatim, `phases_completed`/`phases_total` as top-level integers,
  `summary` and `blockers` both present), and commit the summary and this plan by explicit path.

**Timing**: 0.75 hours

**Depends on**: 2

**Verification Tier**: full

**Scope Hypothesis**: exactly one new summary file is written in this phase, and across all three
phases no file under `FormalSystem/` or `Tests/`, neither `lakefile.toml` nor `lake-manifest.json`,
neither archived report, and not `specs/ROADMAP.md`, is modified. Confirm by the two `git` checks
above, read before the gate run rather than after it; if any is non-empty, stop and report it
rather than reverting, since task 928 is live on this tree and the hunk may not be this task's.

**Files to modify**:
- `specs/927_final_frame_step_remeasure_against_landed_cover/summaries/01_final-frame-step-remeasure-summary.md` - new; the close-out record, including the deliberately-not-done paragraph
- `specs/927_final_frame_step_remeasure_against_landed_cover/plans/01_final-frame-step-remeasure.md` - new `#### Phase 3 Notes` section: the gate classification and the final attestation

**Verification**:
- `bash .claude/scripts/validate-artifact.sh specs/927_final_frame_step_remeasure_against_landed_cover/summaries/01_final-frame-step-remeasure-summary.md summary` exits 0.
- `bash .claude/scripts/verify-deploy.sh` runs to completion with every finding classified as touched-file or pre-existing baseline, or the batch deferral is recorded per the dispatch's directive.
- `bash .claude/scripts/validate-state.sh` exits 0.
- `git status --short -- FormalSystem/ Tests/ lakefile.toml lake-manifest.json` is empty, and the combined `git diff --stat` over this task's own commits for the Lean, build-file, archived-report and ROADMAP paths is empty.
- `.orchestrator-handoff.json` validates (the write-time `validate-handoff-location.sh` gate accepts it) and `.return-meta.json` carries `status: "implemented"` with `dispatch_seq` echoed verbatim.
- The summary's deliberately-not-done paragraph names all six omissions, each with a reason, and the summary states in one sentence that T3 is not thereby complete.

## Lean Challenge Statements

<!-- lean-challenge-statements:none -->

This is a `lean4` task with no theorem deliverable: guardrail (b) forbids writing or editing any
Lean file, and the composition the research dispatch verified was run through `lean_run_code` and
reported as a finding rather than landed. The four `ofStepRel` constraint lemmas and the
`ofStepPlain` constructor are named in the report and handed to the successor task filed in Phase
2; they are that task's challenge statements, not this one's. See `## Decisions` below.

## Decisions

1. **Zero Lean goals, declared explicitly.** This plan carries the
   `<!-- lean-challenge-statements:none -->` marker rather than omitting the section, because the
   section is never omitted on a `lean4` plan. The rationale is guardrail (b): no `.lean` file is
   written or edited by any phase, so there is no declaration for a Challenge module to pin. The
   `- **Goals**:` bullets above correspondingly name zero identifiers.
2. **The 901 amendment is filed, not applied.** Guardrail (e) is explicit, and the research
   report's Finding (3) was written as amendment text "for a successor to apply". Phase 1
   nevertheless completes the work list the successor needs — including two drifted-citation
   sites Finding (3) did not reach — so that filing hands forward a finished enumeration rather
   than a re-measurement.
3. **No `specs/ROADMAP.md` amendment.** Its final-frame sentence states a standing ruling
   (901's Recommendation 8), not a staleness claim about the two landed pieces, so this task's
   finding does not overturn it. Its disposition is task 926's deliverable, and task 928 is
   dispatched concurrently with an undeclared `file_scope` that may include that file.
4. **The `ofStepRel` refactor is filed as its own task rather than deferred behind 926.** It
   touches frame-presentation API in `IntNormalForm.lean` whose proofs already exist inline in
   `ofStepSat`'s body; it formalizes no part of §§7-15 and therefore sits outside Recommendation
   8 entirely. Phase 2's decision gate drops or narrows it if inspection of 926's remit shows
   otherwise.
5. **No `frame-presentation.md` context file is filed.** The report's own Context Extension
   Recommendation makes it conditional — "worth writing only if the API refactor is NOT done" —
   and Phase 2 files the refactor.
6. **No `user_decision` is raised.** The four findings are delivered; the one downstream choice
   (whether to land the refactor) is filed as an ordinary task with no external cost and no
   preference the artifacts cannot infer.

## Testing & Validation

- [ ] `bash .claude/scripts/validate-artifact.sh specs/927_final_frame_step_remeasure_against_landed_cover/plans/01_final-frame-step-remeasure.md plan` exits 0.
- [ ] `bash .claude/scripts/validate-artifact.sh specs/927_final_frame_step_remeasure_against_landed_cover/summaries/01_final-frame-step-remeasure-summary.md summary` exits 0.
- [ ] `bash .claude/scripts/validate-state.sh` exits 0 after the Phase 2 filings, cycle check included.
- [ ] `bash .claude/scripts/verify-deploy.sh` runs to completion in Phase 3, with every finding classified as naming a touched file or as pre-existing baseline.
- [ ] `git status --short -- FormalSystem/ Tests/ lakefile.toml lake-manifest.json` is empty at every phase boundary.
- [ ] `git diff --stat` over this task's own commits is empty for `specs/archive/901_.../`, `specs/archive/879_.../` and `specs/ROADMAP.md`.
- [ ] `specs/TODO.md` renders both filed tasks, with bracket-only artifact links.
- [ ] No file matching `*.lean` appears in `git diff --name-only` over this task's own commits.

## Artifacts & Outputs

- `specs/927_final_frame_step_remeasure_against_landed_cover/plans/01_final-frame-step-remeasure.md` — this plan, with Phase 1, 2 and 3 Notes appended as the phases close.
- `specs/927_final_frame_step_remeasure_against_landed_cover/task-proposals.json` — the two successor proposals.
- `specs/927_final_frame_step_remeasure_against_landed_cover/task-proposals-audit.ndjson` — the backlog-reconciliation evidence consumed by `state-write.sh --audit-verdict`.
- `specs/927_final_frame_step_remeasure_against_landed_cover/summaries/01_final-frame-step-remeasure-summary.md` — the close-out record.
- Two new `not_started` entries in `specs/state.json`, rendered into `specs/TODO.md`.
- No Lean source, no build file, no archived report and no ROADMAP change — by design.

## Rollback/Contingency

Every phase's output is additive and confined to `specs/**`, so rollback is per-phase and cheap.

- **Phase 1**: revert the single commit that added the Phase 1 Notes (`git revert <sha>`); nothing
  else depends on it until Phase 2 cites it.
- **Phase 2**: the two filed entries are removed by a further `state-write.sh` call under the
  mutex that filters them out of `.active_projects` by `project_number`, followed by
  `generate-todo.sh` and `validate-state.sh`. Do not hand-edit `specs/state.json` and do not
  hand-edit `specs/TODO.md`. Numbers already allocated are not reused.
- **Phase 3**: delete the summary and revert its commit; no other record cites it.
- **If a working-tree rollback is ever genuinely needed** (it should not be — no phase here edits
  an existing non-`specs/**` file), follow `context/contracts/recovery.md`'s rollback rung for the
  snapshot-then-rollback invocation shape, including its out-of-scope override flag. Do **not**
  run `git-snapshot.sh` in its reverting default mode as a precaution: task 928 is live on this
  same working tree and a revert would discard its in-flight work. An ordinary defensive
  checkpoint uses `--no-revert`.
- **If a foreign commit, foreign uncommitted modification, or a build this dispatch did not start
  is observed**: stop and report it after checking `git log` to confirm the work is not this
  task's own, rather than proceeding or reverting anything.
