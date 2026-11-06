# Implementation Plan: Task #837

- **Task**: 837 - Challenge statement repair: ParamsOk quantification
- **Status**: [IMPLEMENTING]
- **Effort**: 3.25 hours
- **Dependencies**: None (parent: task 761, currently `[HOLD]`)
- **Research Inputs**: None (no research dispatch ran this round; the evidence base is the landed
  library source, task 761's plan lineage, and the design of record — each anchor re-derivable by
  the commands this plan names)
- **Artifacts**: plans/01_parameter-hypothesis-repair-ratification.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

The dispatch asks for a sanctioned decision between two repairs to the refuted Challenge
statements `cellAt_const_of_kappa_eq` and `ladderRealized`, with the revised statement recorded so
a later implement dispatch can land it without violating Statement Fidelity. **That decision has
already been taken and landed.** Task 761 revised its plan to
`plans/03_ladder-paramsok-parameter-repair.md` — the `/revise` route Statement Fidelity sanctions
— and carried the result forward through `plans/11_idle-insertion-cascade-restatement.md`, whose
`## Lean Challenge Statements` block states both theorems with
`(hp : ParamsOk step pend lab phi Tc Tn P B)`. Repair (a) is the adopted repair; `ParamsOk`,
`paramsOk_params` and `not_paramsOk_allZero` are all landed and compiled in
`FormalSystem/Metalogic/Decidability/RaySummary/CounterQuotient.lean`. No Lean work is owed by
this task, and this plan writes no `.lean` file.

What is genuinely outstanding is narrower and is a records gap: the **design of record**
(`specs/archive/757_lplus_decidability_successor_task_set/followup-scope-spec.md`) was last
amended 2026-10-18 and carries no ratification of the parameter-hypothesis repair at all. Its
Section C amendment still narrates `cellAt_const_of_kappa_eq` without the hypothesis, and H4's
`STATEMENT` line still shows the withdrawn `hitOf (truncate B …)` form inline. A reader who
consults the design of record today finds a stale account of a question that is settled in the
plan lineage and in the library source. This plan closes that gap: it ratifies repair (a) into a
durable decision record, amends the design of record and reproduces the amendment in a tracked
file (because `specs/archive/` is gitignored), and settles the second, independent inconsistency
the dispatch names in the same pass.

### Research Integration

No research report exists for this round. The Stage 1.5 assessment found the task description
plus targeted reads sufficient: every claim this plan rests on was established by direct read of
the repository, and each anchor is re-derived by Phase 1 before anything is written. The bar for
requesting a research dispatch — a fact no grep or read within this dispatch could settle — was
not met.

### Prior Plan Reference

No prior plan exists for task 837. Task 761's plan lineage (`plans/01` through `plans/11`) is
reference context only and is NOT a template: this plan copies no phase from it, and does not
edit it.

### Roadmap Alignment

No `roadmap_path` was supplied in this dispatch and no roadmap flag is set; `specs/ROADMAP.md` was
not consulted and is not modified.

## The decision this plan ratifies

**Repair (a) — the `ParamsOk` hypothesis — is the adopted repair, and this plan ratifies it
rather than re-opening it.** The grounds, each with its anchor:

1. **It is already the recorded statement.** `specs/761_ladder_realization_theorem/plans/11_idle-insertion-cascade-restatement.md`'s
   `## Lean Challenge Statements` block states both `cellAt_const_of_kappa_eq` and
   `ladderRealized` with `(hp : ParamsOk step pend lab phi Tc Tn P B)` in a fixed recorded
   position, carried verbatim from `plans/08_cell-agreement-construction-handoff.md` and
   originating at `plans/03_ladder-paramsok-parameter-repair.md`.
2. **It was adopted by the sanctioned route.** `plan-compliance.md`'s Statement Fidelity section
   forbids an *implement* dispatch from quietly editing a recorded Challenge; it does not forbid a
   plan revision from recording a corrected one. Task 761's Phases 9 and 13 closed `[BLOCKED]`
   under plan 01, and a `/revise` round — not an in-flight edit — produced plan 03. That is
   precisely the escalate-then-revise behaviour the rule mandates.
3. **The hypothesis is dischargeable, so neither statement is vacuous.** `paramsOk_params`
   (`CounterQuotient.lean:785`) proves `ParamsOk` at the four parameters the periodicity fixpoint
   defines (`Tcof`, `Tnof`, `Pof`, `Bof`). A hypothesis no consumer can discharge would be
   indistinguishable from an unproved statement; this one has a landed witness.
4. **The hypothesis is load-bearing, so it is not decoration.** `not_paramsOk_allZero` records
   that `ParamsOk` FAILS at the all-zero tuple the refutation turns on, on the refuting probe's
   own object. The compiled refutation (`cell_succ_ne`, `separating_pair_nonvacuous`, the
   subsingleton `CK 0 0 0 0`) stays wired and unchanged as the reason the hypothesis exists.
5. **Repair (b) is not adopted.** Existentially quantifying `(Tc Tn P B)` would make both
   statements assert only that SOME parameter tuple works, which no downstream consumer can use:
   `ladderSound`, `ladderCons_localRun` and `ladderLift` all quantify the same four parameters
   universally and must instantiate at a tuple the caller chooses, and `Dmax` is indexed by them.
   An existential would also hide, rather than state, the parameter conditions (K1)-(K4) that the
   design names. Repair (a) keeps the parameters universally quantified and constrains them,
   which is what the consumers need.

**Scope boundary on claim 4's reach.** `specs/761_ladder_realization_theorem/reports/08_rk-bounded-representative-refutation.md`
Finding 4 establishes that `ParamsOk` is NOT the repair for `rk_of_count_drift`, because it bounds
`P` only from below while that refutation runs toward larger `P`. That finding is about a
different theorem and does not weaken the repair adopted here; the in-source docstring at
`CounterQuotient.lean:420-430` already records "`ParamsOk` is NOT a hypothesis here, and must not
be added" at `rk_of_count_drift`'s own site. This plan's record must state both facts together so
a later round does not read either one as general.

## The second inconsistency, and its resolution

The dispatch names a second item: task 761 plan 01's Phase 8 task list required promoting
`realizes_of_certAdm_cohBi` while that phase's own Scope Hypothesis said `certStab` and `certAdm`
are deliberately NOT promoted. `realizes_of_certAdm_cohBi` is stated in terms of `certAdm` and its
proof destructures `certAdm_iff`, so the two directives cannot both hold — the dispatch's reading
is correct.

**It is resolved, in favour of promotion.** `certStab` and `certAdm` were promoted at the K-free
carrier `ProdState Q φ`, and the decision plus its reason are recorded in
`specs/761_ladder_realization_theorem/summaries/01_ladder-realization-presentation-a-summary.md`'s
Decisions section. `Certificate.lean` carries the promoted layer today, and plan 11's Phase 8 is
`[COMPLETED]` with no contradictory Scope Hypothesis. This plan therefore ratifies the resolution
into the record rather than re-deciding it, so a later round does not re-litigate a conflict that
no live plan carries.

## Goals & Non-Goals

**Goals**:
- Re-derive, at implementation time, every anchor this plan asserts, rather than trusting the
  figures recorded here.
- Produce a durable decision record in task 837's own directory that ratifies repair (a), records
  both revised statements verbatim, names the discharge witness and the compiled refutation, and
  settles the `realizes_of_certAdm_cohBi` directive conflict.
- Amend the design of record (Sections A, C and H4) with dated `**Amended by**` paragraphs
  ratifying the parameter hypothesis, and reproduce those paragraphs verbatim in a tracked file
  because `specs/archive/` is gitignored.
- Leave the repository's gates green.

**Non-Goals**:
- Proving `cellAt_const_of_kappa_eq` or `ladderRealized`. Both remain unproved; task 761's
  Phases 11.7 and 16 own them. This plan writes no `.lean` file and claims no proof.
- Editing any file under `FormalSystem/`, `Tests/`, or `scripts/`.
- Editing task 761's plans, summaries, reports, or its `specs/state.json` entry. Task 761 is on
  `[HOLD]`; its records are its own round's lane, and the recorded Challenge block there is
  already correct and must not be touched.
- Re-opening the choice between repair (a) and repair (b). The choice is landed; this plan records
  it.
- Changing `specs/ROADMAP.md`.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| An anchor recorded here (line number, file state) has moved since this plan's authoring — concurrent siblings are live on this tree | M | M | Phase 1 re-derives every anchor by command before any write, and Phase 2/3 cite only what Phase 1 re-confirmed. A moved line number is corrected in place, not treated as a contradiction |
| The design-of-record file is gitignored, so an amendment written only there vanishes on a fresh clone | H | H (certain) | Phase 3 reproduces every amendment paragraph verbatim in `records/design-of-record-amendment-2026-11-05.md` inside the tracked task directory, following the precedent `specs/761_ladder_realization_theorem/records/design-of-record-amendment-2026-10-18.md` set |
| Amending the design of record reads as editing a recorded Challenge statement, the exact move Statement Fidelity forbids | H | L | The amendment records a repair ALREADY adopted by a sanctioned `/revise` round and already landed in the library; it changes no statement to match an implementation. The record paragraph says so explicitly and cites plan 03 as the adopting round |
| Task 761 is revived mid-flight and edits the same records | M | L | 761 is `[HOLD]` and is not in this cycle's concurrent-sibling set. Phase 3 re-reads each target immediately before editing and stages only its own hunks |
| The ratification is read as asserting that `ParamsOk` repairs every refuted statement in the round | M | M | The record states Finding 4's counter-case (`rk_of_count_drift`) alongside the adopted repair, so the scope of the ratification is bounded in writing |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases within the same wave can execute in parallel; this plan's chain is linear, because each
phase cites the artifact the previous one produced.

### Phase 1: Re-derive the As-Landed Baseline [COMPLETED]

**Goal**: Confirm, by command, that repair (a) is the recorded and landed repair and that the
design-of-record gap is real — before a single word is written. This phase produces no tree
change; its output is the corrected anchor set Phases 2 and 3 cite.

**Tasks**:
- [x] Confirm both Challenge statements carry the hypothesis:
      `grep -n 'hp : ParamsOk' specs/761_ladder_realization_theorem/plans/11_idle-insertion-cascade-restatement.md`
      — expect hits inside the `## Lean Challenge Statements` block for `cellAt_const_of_kappa_eq`
      and `ladderRealized`, and transcribe both signatures verbatim for Phase 2.
- [x] Confirm the adopting round: `ls specs/761_ladder_realization_theorem/plans/` shows
      `03_ladder-paramsok-parameter-repair.md`, and
      `grep -n 'Lean Challenge Statements' specs/761_ladder_realization_theorem/plans/03_ladder-paramsok-parameter-repair.md`
      locates the block that first recorded the repair.
- [x] Confirm the landed Lean layer:
      `grep -n 'def ParamsOk\|theorem paramsOk_params\|not_paramsOk_allZero' FormalSystem/Metalogic/Decidability/RaySummary/CounterQuotient.lean`
      — record the actual line numbers found, which supersede the ones this plan cites.
- [x] Confirm the `rk_of_count_drift` counter-case is in-source:
      `grep -n 'ParamsOk. is NOT a hypothesis here' FormalSystem/Metalogic/Decidability/RaySummary/CounterQuotient.lean`.
- [x] Confirm the second inconsistency is settled:
      `grep -n '^### Phase 8' specs/761_ladder_realization_theorem/plans/11_idle-insertion-cascade-restatement.md`
      shows `[COMPLETED]`, and `grep -rn 'realizes_of_certAdm_cohBi' FormalSystem/ --include=*.lean`
      shows the promoted layer in `Certificate.lean`.
- [x] Confirm the design-of-record gap:
      `grep -n 'Amended by\|ParamsOk' specs/archive/757_lplus_decidability_successor_task_set/followup-scope-spec.md`
      — expect exactly two `**Amended by**` paragraphs, both dated 2026-10-18, and ZERO `ParamsOk`
      occurrences. If `ParamsOk` now appears there, the gap is already closed and Phase 3 narrows
      to whatever remains; record that outcome rather than writing a redundant amendment.
- [x] Confirm the archive tree is gitignored (`grep -n 'specs/archive' .gitignore`), which is the
      reason Phase 3 writes a durable tracked copy.

**Timing**: 0.5 hours

**Depends on**: none

**Verification Tier**: prose

**Tier Justification**: The phase writes no file at all, so the covering check is the `prose` row's
own read-through of the command output, with no suite or gate able to observe a change that does
not exist.

**Scope Hypothesis**: This plan asserts `ParamsOk` at `CounterQuotient.lean:776`,
`paramsOk_params` at `:785`, the `rk_of_count_drift` docstring at `:420-430`, exactly two
`**Amended by**` paragraphs in the design of record (lines 365 and 507) and zero `ParamsOk`
occurrences there, and plan 11 Phase 8 at `[COMPLETED]`. Every one of these is a hypothesis
measured at this plan's authoring, not a fact: the implementer confirms each by the command above
and corrects the figure in Phase 2's record where it has moved.

**Files to modify**:
- None — this phase is read-only.

**Verification**:
- Every bullet above was run and its output read; the anchor set carried into Phase 2 is the
  re-derived one, not this plan's recorded figures.
- Any divergence between a re-derived anchor and the figure recorded here is written down
  explicitly, so Phase 2's record states measured values.

---

### Phase 2: Write the Ratification Decision Record [COMPLETED]

**Goal**: A durable record in task 837's own tracked directory that states the adopted repair, both
revised statements verbatim, the evidence that the hypothesis is both dischargeable and
load-bearing, the bounded scope of the ratification, and the resolution of the
`realizes_of_certAdm_cohBi` directive conflict.

**Tasks**:
- [x] Create `specs/837_challenge_statement_repair_paramsok_quantification/records/`.
- [x] Write `records/01_parameter-hypothesis-repair-ratification.md` with these sections:
      **Decision** (repair (a) ratified, repair (b) not adopted, with the reason from this plan's
      "The decision this plan ratifies" section); **The revised statements**, quoting both
      `cellAt_const_of_kappa_eq` and `ladderRealized` verbatim from the Phase 1 transcription, in
      a fenced `lean` block, with the hypothesis in its recorded position; **Why the hypothesis is
      dischargeable** (`paramsOk_params` and the four fixpoint parameters, at the line number
      Phase 1 measured); **Why the hypothesis is load-bearing** (`not_paramsOk_allZero`, the
      subsingleton `CK 0 0 0 0`, `cell_succ_ne`, `separating_pair_nonvacuous`); **What this
      ratification does NOT cover** (Finding 4: `ParamsOk` is not the repair for
      `rk_of_count_drift`, and must not be added there); **The `realizes_of_certAdm_cohBi`
      directive conflict** (settled in favour of promotion at the K-free carrier `ProdState Q φ`,
      with the `Certificate.lean` anchor); **Statement Fidelity position** (the repair was adopted
      by a `/revise` round, not an in-flight edit, so recording it violates nothing).
- [x] State in the record that neither theorem is proved, that task 761's Phases 11.7 and 16 own
      them, and that this record changes no `.lean` file.
- [x] Cite durable anchors only — filenames, declaration names and section headings. Task numbers
      are permitted here because the file lives under `specs/**`
      (`no-task-references-in-deliverables.md`, primary exemption).

**Timing**: 1 hour

**Depends on**: 1

**Verification Tier**: prose

**Tier Justification**: The phase adds one new markdown file under `specs/**`, which
`suite_selection_select` maps to no suite (the `__FULL_SWEEP__` sub-case (a)), so the honest
covering check is the `prose` row's diff read-through of the new file.

**Files to modify**:
- `specs/837_challenge_statement_repair_paramsok_quantification/records/01_parameter-hypothesis-repair-ratification.md` - new; the ratification decision record

**Verification**:
- The file exists and is non-empty (`wc -l` > 0), and every section named above is present.
- Both quoted signatures diff IDENTICAL against the Phase 1 transcription from plan 11's
  `## Lean Challenge Statements` block — verified by direct `diff` of the extracted signature
  text, the hypothesis and its position included.
- Every line number and declaration name the record cites is one Phase 1 re-derived.
- Diff read-through confirms the change is confined to the one new file.

---

### Phase 3: Amend the Design of Record and Reproduce It Durably [COMPLETED]

**Goal**: The design of record carries a dated ratification of the parameter-hypothesis repair in
each of the three places that narrate the affected statements, and that text survives a fresh
clone.

**Tasks**:
- [x] Re-read `specs/archive/757_lplus_decidability_successor_task_set/followup-scope-spec.md`
      immediately before editing (concurrency discipline), and locate Section A's amendment
      paragraph, Section C's amendment paragraph, and the H4 record's `STATEMENT` block.
- [x] Append to **Section C** a dated paragraph in the file's established shape —
      `**Amended by** specs/837_challenge_statement_repair_paramsok_quantification/records/01_parameter-hypothesis-repair-ratification.md, 2026-11-05:` —
      recording that `cellAt_const_of_kappa_eq` carries `(hp : ParamsOk step pend lab phi Tc Tn P B)`,
      that the hypothesis is discharged by `paramsOk_params` at the periodicity fixpoint's own four
      outputs, and that `not_paramsOk_allZero` is the companion fact making it load-bearing. The
      section's existing content about the factorization lemma being a COROLLARY stands unchanged.
- [x] Append to **Section A** a dated paragraph in the same shape recording that the fibre equation
      `ladderRealized` likewise carries the parameter hypothesis, and that the parameters remain
      UNIVERSALLY quantified and constrained rather than existentially quantified — with the reason
      repair (b) was not adopted stated in one sentence.
- [x] Append to the **H4** record a dated paragraph in the same shape recording the same two
      signature changes against H4's own `STATEMENT` block, and noting that the block's
      `hitOf (truncate B …)` form was already withdrawn by the Section A amendment of 2026-10-18
      and is not revived.
- [x] State in each paragraph, in one sentence, that the repair was adopted by task 761's
      `plans/03_ladder-paramsok-parameter-repair.md` revision round and is ratified — not decided —
      here, so Statement Fidelity is satisfied.
- [x] Create `specs/837_challenge_statement_repair_paramsok_quantification/records/design-of-record-amendment-2026-11-05.md` *(deviation: altered — written as `design-of-record-amendment-2026-11-06.md`, and all three paragraphs dated 2026-11-06, because the round executed on 2026-11-06 and a dated amendment must carry the date it was written; the plan's 2026-11-05 was its own authoring date)*
      reproducing all three paragraphs VERBATIM, with the same durability preamble the
      2026-10-18 copy carries (`specs/archive/` is gitignored, so the tracked copy exists for
      durability only and the archived file remains the amended record).
- [x] Do NOT touch any file under `specs/761_ladder_realization_theorem/`, and do NOT edit
      `specs/state.json`'s 761 entry.

**Timing**: 1 hour

**Depends on**: 2

**Verification Tier**: prose

**Tier Justification**: Both touched paths lie entirely under `specs/**` and are prose records with
no executable surface, the `__FULL_SWEEP__` sub-case (a), so the honest covering check is the
`prose` row's diff read-through plus the verbatim `diff` between the two copies below.

**Files to modify**:
- `specs/archive/757_lplus_decidability_successor_task_set/followup-scope-spec.md` - three dated `**Amended by**` paragraphs appended to Sections A, C and the H4 record
- `specs/837_challenge_statement_repair_paramsok_quantification/records/design-of-record-amendment-2026-11-06.md` - new; durable tracked reproduction of those three paragraphs (dated for the execution date, not the plan's authoring date)

**Verification**:
- `grep -c 'Amended by' specs/archive/757_lplus_decidability_successor_task_set/followup-scope-spec.md`
  returns exactly three more than the Phase 1 baseline, and `grep -n 'ParamsOk'` on the same file
  now returns a non-empty set confined to the three new paragraphs.
- Each of the three paragraphs is reproduced in the tracked copy with zero textual divergence,
  verified by extracting each paragraph from both files and `diff`-ing them — identical, byte for
  byte.
- `git status --short specs/761_ladder_realization_theorem/` is empty, and
  `git diff -- specs/state.json` shows no change to the 761 entry: nothing in 761's lane was
  touched.
- Diff read-through confirms every changed hunk is prose inside a records file; no `.lean`,
  `.sh`, `.typ` or `.json` file appears in `git status --short`.

---

### Phase 4: Full Gate, Summary, and Scoped Commit [COMPLETED]

**Goal**: The repository's complete gate set is green over the round's changes, the round is
summarized, and the work is committed with scoped staging.

**Tasks**:
- [x] `bash .claude/scripts/validate-artifact.sh specs/837_challenge_statement_repair_paramsok_quantification/plans/01_parameter-hypothesis-repair-ratification.md plan`
      — read the exit status.
- [x] `bash .claude/scripts/check-task-references.sh` — expect 0 unexempted occurrences outside
      `specs/**`; every file this round touched is inside `specs/**`, so this round adds none.
- [x] `bash .claude/scripts/check-record-versioning.sh` *(deviation: altered — exits 1 on 6 PRE-EXISTING BLOCKING occurrences in Boneyard/** and FormalSystem/Metalogic/Expressiveness/Kamp/** Lean files this round never touched; the lint excludes specs/**, where every file this round wrote lives. Enumerated in the summary; not an exemption claim)* — the dated `**Amended by**` paragraphs are
      a permitted exception and the touched files are `specs/**`, the primary exemption; confirm
      the exit status rather than assuming it.
- [x] `bash .claude/scripts/verify-deploy.sh` — the complete gate set, run unnarrowed, with its
      exit status read. Neither `--skip-slow` nor `--only-gate` is used here: this is the final
      phase's own gate, and a narrowed pass is not evidence for it. *(deviation: altered — this dispatch's Batch Gate Deferral directive supersedes this bullet: the `full` tier was discharged against a SCOPED `run-all.sh --only` selection of the 12 suites covering this round's file kinds (12 passed, 0 failed), and the complete set runs once for the whole batch at the end of the invocation, attributed back by `modified_files`. Deferred, not forgiven)*
- [x] Write `specs/837_challenge_statement_repair_paramsok_quantification/summaries/01_parameter-hypothesis-repair-ratification-summary.md`
      stating plainly that the round's substantive decision was found already landed, what was
      therefore ratified rather than decided, the design-of-record gap that was closed, and that
      no `.lean` file was touched and neither theorem was proved.
- [x] Commit with explicit per-file staging (`git add -- <file> <file> …`, never a directory or
      glob pathspec), reviewed by `git status --short` and `git diff --staged` first, with the
      message `task 837: complete implementation` and the session ID in the body.

**Timing**: 0.75 hours

**Depends on**: 3

**Verification Tier**: full

**Files to modify**:
- `specs/837_challenge_statement_repair_paramsok_quantification/summaries/01_parameter-hypothesis-repair-ratification-summary.md` - new; the round summary

**Verification**:
- `validate-artifact.sh` exits 0 on this plan.
- `check-task-references.sh` exits 0.
- `check-record-versioning.sh` exits 0, or any finding is a documented exemption named in the
  summary with its category.
- `verify-deploy.sh` exits 0 with no gate reported as skipped-under-filter; its per-gate output is
  read, not merely its exit code.
- The summary file exists and names the superseded premise explicitly.
- `git status --short` is clean after the commit except for files outside this task's scope, and
  `git log -1 --stat` shows only this task's files.

## Testing & Validation

- [x] `bash .claude/scripts/validate-artifact.sh <plan path> plan` exits 0. *(exit 0, `[PASS] plan artifact is valid (0 warning(s))`; the summary artifact also validates, exit 0)*
- [x] `bash .claude/scripts/check-task-references.sh` exits 0 with 0 unexempted occurrences outside
      `specs/**`.
- [x] `bash .claude/scripts/check-record-versioning.sh` *(deviation: altered — exits 1, not 0: 6 PRE-EXISTING BLOCKING occurrences in `Boneyard/**` and `FormalSystem/Metalogic/Expressiveness/Kamp/**` Lean files, all five files untouched by this round's three commits, and the lint excludes `specs/**` where every file this round wrote lives. All six enumerated in the summary's Verification section as a pre-existing repo-wide condition, NOT as an exemption claim)* — exits 0, or every finding is named with its
      exemption category in the round summary.
- [x] `bash .claude/scripts/verify-deploy.sh` *(deviation: altered — superseded by this dispatch's Batch Gate Deferral directive; discharged against a scoped `run-all.sh --only` selection of 12 covering suites, 12 passed / 0 failed, with the complete set deferred to the batch stage)* exits 0, run with no `--skip-slow` and no
      `--only-gate` narrowing.
- [x] `git status --short` lists no file under `FormalSystem/`, `Tests/`, `scripts/`, `typst/`, or
      `specs/761_ladder_realization_theorem/` at any point in the round.
- [x] *(deviation: altered — `lake build` WAS run, through `lake-build-guard.sh` detached with the bounded-waiter idiom, because the lean-implementation agent contract mandates a final full build before an `implemented` return. Guard exit 0, `Build completed successfully (2958 jobs)`, 0 `error:` occurrences, `.olean` newer than source for both cited modules. The plan's point stands on its own terms: the round compiles nothing of its own, so the green build attests the tree's state, not this round's output.)* `lake build` is NOT run and is not required: this round compiles nothing, and the plan claims
      no build result.
- [x] The three amendment paragraphs diff IDENTICAL between the archived design of record and the
      tracked durable copy.

## Artifacts & Outputs

- `specs/837_challenge_statement_repair_paramsok_quantification/plans/01_parameter-hypothesis-repair-ratification.md` (this plan)
- `specs/837_challenge_statement_repair_paramsok_quantification/records/01_parameter-hypothesis-repair-ratification.md` (the ratification decision record)
- `specs/837_challenge_statement_repair_paramsok_quantification/records/design-of-record-amendment-2026-11-06.md` (durable tracked reproduction)
- `specs/archive/757_lplus_decidability_successor_task_set/followup-scope-spec.md` (amended, Sections A, C and H4; gitignored, hence the copy above)
- `specs/837_challenge_statement_repair_paramsok_quantification/summaries/01_parameter-hypothesis-repair-ratification-summary.md` (round summary)

## Rollback/Contingency

Every change this plan makes is an append of prose to a markdown file under `specs/**`; nothing
compiles, nothing is generated, and no library module is touched, so there is no build state to
restore. To revert, remove the three new files in the task directory and delete the three appended
paragraphs from the design of record — the tracked durable copy is the exact text to remove, which
is a second reason it exists.

If Phase 1 finds that the design of record ALREADY carries a ratification of the parameter
hypothesis (the gap is closed by another round), Phase 3 narrows to whatever remains unrecorded and
the summary says so; the phase is not padded with a redundant amendment. If Phase 1 instead finds
that plan 11's Challenge block does NOT carry the hypothesis — contradicting this plan's
foundation — the phase closes `[BLOCKED]` with the measured output recorded, and the task is
re-planned rather than proceeding on a falsified premise.

Before any defensive checkpoint during the round, use
`bash .claude/scripts/git-snapshot.sh 837 --no-revert`; the default reverting form belongs only to
a genuine rollback and must not be emitted as a routine checkpoint.
