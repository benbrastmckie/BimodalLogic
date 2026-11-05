# Implementation Plan: Task #865

- **Task**: 865 - tm_plus_lc_axiomatization_and_automaton_obstruction
- **Status**: [IMPLEMENTING]
- **Effort**: 2.5 hours
- **Dependencies**: 864 (`[COMPLETED]`), 866 (`[COMPLETED]`)
- **Research Inputs**: `specs/865_tm_plus_lc_axiomatization_and_automaton_obstruction/reports/01_lc-axiomatization-automaton-obstruction.md`
- **Artifacts**: plans/01_lc-axiomatization-automaton-obstruction.md (this file)
- **Standards**:
  - `.claude/context/formats/plan-format.md`
  - `.claude/context/standards/status-markers.md`
  - `.claude/rules/artifact-formats.md`
  - `.claude/rules/state-management.md`
  - `.claude/docs/reference/standards/multi-task-creation-standard.md`
  - `.claude/context/patterns/backlog-reconciliation.md`
- **Type**: formal
- **Lean Intent**: false

## Overview

The task's deliverable — the research report — is already written and is the whole of its
substantive output. What remains is the close-out the dispatch itself mandates: "No library
change and no completeness claim lands from this task; if a route survives scrutiny, file the
implementation as its own task." Three routes survived scrutiny, so this plan discharges the one
documentation amendment the report owns (R5), files the two follow-on tasks the report recommends
(R1, R2) with Component 4b backlog-reconciliation evidence, declines the two it refuses (R3
gated, R4 not to be filed), and closes with a summary. Definition of done: report 03 §1.3's
consequence sentence no longer reads as settled; two new `not_started` tasks exist with audited,
non-duplicate scope; nothing under `FormalSystem/` or `Tests/` has changed.

### Research Integration

The report is integrated as a set of dispositions, not re-derived:

- **Verdict (findings 3 and 5)**: a doubled, clock-anchored pair of one-sided automata is
  sufficient in shape (no bi-infinite ℤ-automaton), conditional on `SeparationOver
  TaskFrame.IsZTime`; but the binding obstruction is the AA carrier, proved intrinsic, so
  `coneR`'s two-layer shape and its *Saturation* obligation are forced. Nothing in this plan
  reopens either half — the verdict is the deliverable and it is already recorded.
- **R1 (finding 4)**: oriented-forest *Saturation* is the single uncompiled ingredient under both
  the AA carrier route and the MSO cover step. Filed in Phase 3 as a `lean4` task — the highest-
  value item the report found, and the one that unblocks two fronts.
- **R2 (finding 2)**: the two defects of record — `PlusLCSchema.lean`'s docstring claim that
  `LCU` is `lcN` at `n = 1`, and the landed `omega_chain`'s dropped segment-property parameter
  `P`. Both re-confirmed against the live tree during planning (docstring lines 50 and 173;
  `omega_chain` at `PlusOmegaChain.lean:310-319` carries `A` but no `P`/`hP`). These are library
  edits and so are explicitly outside this task's scope; they are filed, not performed.
- **R5 (finding 6)**: report 03 §1.3's closing sentence ("the open question is only a *natural*
  system") is the sentence at fault. Discharged in Phase 1 as an in-place amendment, because it
  touches only a `specs/**` artifact and the report labels it "documentation, cheap".
- **Not filed**: R3 (the doubled AA⊡ rule) is gated on R1 and informed by 867 — filing it now
  would reproduce the blocker `NamingRules.lean` already records. R4 (MSO formalization) is
  refused for the reason 866's R2 gives: Mathlib has no ω-automata, MSO, or Rabin tree theorem,
  and G1 needs a paper repair first.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was supplied in this dispatch and no `roadmap_flag` is set, so `specs/ROADMAP.md`
was not loaded as planning input and is not modified by any phase. For the record: the ROADMAP
lists this task under "Stage 0.5 — pre-archival rescue", and its pre-archival concern (the
candidate axiomatization sitting outside the live tree with no task pointing at it) is exactly what
Phase 3's filings address — but the ROADMAP is hand-maintained and its own sync is `/todo`'s job,
not this task's.

## Goals & Non-Goals

**Goals**:
- Amend report 03 §1.3's consequence sentence so it cannot be read as settling ZTime
  axiomatizability, with a dated amendment note in the file's existing amendment style.
- Produce machine-checkable backlog-reconciliation evidence for the two proposed follow-ons
  before either is created.
- File exactly two follow-on tasks (R1 oriented-forest *Saturation*; R2 the corrective LCU/
  `omega_chain` record repair), each with a declared `file_scope` and audited scope.
- Record, in the summary, why R3 and R4 are deliberately not filed, so neither reads as an
  oversight.
- Leave `FormalSystem/` and `Tests/` byte-identical.

**Non-Goals**:
- Any library change. `PlusLCSchema.lean`, `PlusOmegaChain.lean`, `NamingRules.lean` and every
  other file under `FormalSystem/` are untouched; the two confirmed defects are filed, not fixed.
- Any completeness, decidability, or finite-model-property claim.
- `docs/theorem-index.md`. The report states explicitly that it records the position correctly
  today and needs no change — and it is inside a concurrent sibling's declared `file_scope`.
- `specs/ROADMAP.md` and `specs/CHANGE_LOG.md`.
- Declaring the until-form `LCU` itself, or any work on `SeparationOver` (task 867).
- Re-deriving or re-litigating the report's verdict.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Report 03 has moved to `specs/archive/` under a concurrent `/todo` | M | L | Phase 1's first step resolves the path by glob over both `specs/559_*` and `specs/archive/559_*` and fails loudly rather than creating a file; the directory was present at plan time |
| Autonomous task creation bypasses the Multi-Task Creation Standard's Component 7 user confirmation, which is mandatory and foreground-only | M | H | Stated assumption, not a silent one: the task description's own "file the implementation as its own task" is the user's pre-authorization for these specific filings. Phase 2 still produces the full Component 4b audit evidence and Phase 3 renders the Component 7 confirmation table into the summary as a record. If Phase 2 returns any verdict other than `genuinely-new`/`scope-blind`/`overlaps-open` for a proposal, Phase 3's decision gate drops that proposal and the summary says so rather than auto-applying a fold |
| `specs/state.json` / `specs/TODO.md` are written concurrently by sibling tasks 852 and 856 this same cycle | H | M | All state mutation goes through `state-write.sh` (flock-guarded, `--allocate-into` allocates under the same mutex) with `--regen-todo`; no hand-edit of either file, and no directory or glob `git add` |
| A filed task's number collides or `next_project_number` is stale | M | L | `--allocate-into` derives a membership-based free number under the mutex and refuses fail-closed on a stale or in-use cache; `validate-state.sh` is Phase 3's covering check |
| The amendment is read as a completeness or decidability claim | M | L | The amendment states only that the *consequence* sentence is unavailable and that the ZTime question is about existence; it adds no positive claim and cites the two reports that located the gap |
| R1's scope is drawn too wide and collides with the live decidability front | M | L | R1's `file_scope` is the single `saturation_of_*` home (`FormalSystem/Semantics/TaskFrame.lean`) plus its README row; it is independent of separation, of Rabin, and of the ladder/RaySummary files held by task 852 |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 2 |
| 3 | 4 | 1, 3 |

Phases within the same wave can execute in parallel.

### Phase 1: Amend Report 03 §1.3's Consequence Sentence [COMPLETED]

**Goal**: The sentence "So at ZTime the validities are decidable, hence recursively
axiomatizable; the open question is only a *natural* system" no longer reads as settled, and a
reader is pointed at the two reports that located the gap.

**Tasks**:
- [x] Resolve report 03's live path: glob `specs/559_nondeterministic_canonical_model_tm_star_completeness/reports/03_axiomatizability-rules-engine.md` and, if absent, `specs/archive/559_*/reports/03_axiomatizability-rules-engine.md`. If neither resolves, stop and record a blocker — do not create the file. *(completed)*
- [x] Re-read the §1.3 region immediately before editing (sibling-concurrency rule), locating the consequence sentence and the existing `> **Amendment (derived; ...)` block that follows it. *(completed)*
- [x] Append a second amendment note in the file's existing blockquote style, immediately after the existing amendment block and before `#### 1.4`. Content, and nothing beyond it: (a) the consequence sentence is withdrawn as unavailable, so the ZTime question is about **existence**, not only naturalness; (b) three stated reasons — G1 is live inside step 1 of this very argument (located in `specs/866_mso_route_open_modals_ztime_decidability/reports/01_mso-route-open-modals.md`, finding 6), §1.3 is a paper argument resting on a recalled theorem (Rabin) and is self-labelled "paper, Medium-High", and the landed `Compression.decidableValidZTime` / `ZTimeProvability.decidableDerivableZTime` are at base `Formula`, which has no `stab`; (c) the amendment adds no positive claim, establishes no finite model property, and leaves §1.2, §1.4 and the unamended §1.3 argument otherwise untouched; (d) a dated header line and a pointer to `specs/865_tm_plus_lc_axiomatization_and_automaton_obstruction/reports/01_lc-axiomatization-automaton-obstruction.md` finding 6 as the deriving record. *(completed)*
- [x] Confirm the consequence sentence itself is left byte-identical (the amendment withdraws it in place; it is not rewritten or deleted), so the file remains a faithful record of what it originally said. *(completed)*
- [x] Commit, staging only this one file by explicit path. *(completed)*

**Timing**: 0.5 hours

**Depends on**: none

**Verification Tier**: prose

**Tier Justification**: `suite_selection_select` returns `__FULL_SWEEP__` for this path, and the path lies entirely under `specs/**` (sub-case (a)), so the covering check is `bash .claude/scripts/validate-artifact.sh <resolved-report-03-path> report` together with the `prose` row's diff read-through confirming every changed hunk is inside the appended blockquote.

**Scope Hypothesis**: exactly one file changes, by exactly one appended blockquote, and the target consequence sentence is the single sentence currently at `specs/559_nondeterministic_canonical_model_tm_star_completeness/reports/03_axiomatizability-rules-engine.md:192`, with exactly one pre-existing `> **Amendment` block in §1.3. Confirm at implementation time by `grep -n "only a \*natural\* system" <resolved-path>` and `grep -c "> \*\*Amendment" <resolved-path>` before editing; if either count differs, re-locate rather than editing blind.

**Files to modify**:
- `specs/559_nondeterministic_canonical_model_tm_star_completeness/reports/03_axiomatizability-rules-engine.md` - append one dated amendment blockquote to §1.3 withdrawing its consequence sentence; the sentence itself and every other section left byte-identical

**Verification**:
- `grep -n "only a \*natural\* system"` still matches exactly once (the original sentence survives verbatim).
- The appended blockquote appears after the existing amendment block and before the `#### 1.4` heading.
- `bash .claude/scripts/validate-artifact.sh <resolved-path> report` exits 0.
- `git diff --staged` shows exactly one file and only added lines.

---

### Phase 2: Build and Audit the Follow-On Proposal Set [COMPLETED]

**Goal**: A machine-readable, non-duplicate verdict for each of the two proposed follow-ons,
written to this task's directory as the evidence Phase 3's filings will cite.

**Tasks**:
- [x] Re-read the report's `### Recommendations` section and confirm the disposition split is still R1 and R2 filed, R3 gated, R4 refused, R5 discharged in Phase 1. *(completed)*
- [x] Write a proposals array to `specs/865_tm_plus_lc_axiomatization_and_automaton_obstruction/task-proposals.json` in `audit-task-proposals.sh`'s set-mode shape (`id`, `title`, `description`, `file_scope`; no `project_number`), with two elements: *(completed)*
  - R1 — `lean4`. Oriented-forest *Saturation*: every oriented forest (directed paths unique between any two nodes) satisfies the literal `TaskFrame.Saturation`, stated with the path-uniqueness hypothesis explicit rather than a forest structure, as a `Semantics/` lemma beside the existing `saturation_of_*` family. Description names its two consumers (the AA carrier layer-split route and the MSO cover step) and its five-step source (report 03 §1.2). `file_scope`: `FormalSystem/Semantics/TaskFrame.lean`, `FormalSystem/Semantics/README.md`.
  - R2 — `lean4`, corrective and small. Three parts: correct `PlusLCSchema.lean`'s docstring claim that `LCU` is the `n = 1` instance of `lcN` (it is the until-form with two parameters and `untl`; `lcN 1` is the F-form with one); restore `omega_chain`'s segment-property parameter `P` with its stability hypothesis (`specs/evidence/limit-closure-schema/lc-schema-omega-chain.lean` lines 659-684 carry both); and state backward `LC_n` as the one-line `plusValidIn_reflectTime` corollary of `lcN_plusValidZTime`. Description states explicitly that declaring the until-form `LCU` itself is NOT in scope and waits on R1 and 867. `file_scope`: `FormalSystem/PlusLanguage/PlusLCSchema.lean`, `FormalSystem/PlusLanguage/PlusOmegaChain.lean`, `FormalSystem/PlusLanguage/README.md`.
- [x] Run `bash .claude/scripts/audit-task-proposals.sh --proposals-file specs/865_.../task-proposals.json > specs/865_.../task-proposals-audit.ndjson` and read every verdict. *(completed)*
- [x] Classify each proposal: `genuinely-new` / `overlaps-open #N` (edge to add) / anything else (drop or narrow — do not auto-apply). Record `scope-blind` compactly as a count, per the standard's rendering note. *(completed: R1 narrowed to drop README.md after audit found overlap with task 869; both R1 and R2 genuinely-new)*
- [x] Record an issue-log entry if any verdict is other than `genuinely-new`, `scope-blind`, or `overlaps-open`. *(completed: issue-record.sh entry for the R1/869 duplicate-of-open finding)*

**Timing**: 0.5 hours

**Depends on**: none

**Verification Tier**: prose

**Tier Justification**: both written files are data/prose under `specs/**` with zero compile or elaboration surface and `suite_selection_select` returns `__FULL_SWEEP__` for them (sub-case (a), and neither is a report/plan/summary artifact), so the covering check is `jq -e . specs/865_.../task-proposals.json` plus `jq -e . < each line of the audit NDJSON` together with the `prose` row's diff read-through.

**Scope Hypothesis**: the proposal set has exactly two elements, and each of R1 and R2 is expected `genuinely-new` against the backlog — at plan time a grep of every non-`completed` `active_projects` description for `saturation|oriented|forest|LCU|omega_chain|segment|limit.closure|separation` matched only task 867 (Gabbay separation), which is a different subject. Confirm at implementation time by the audit script's own verdicts, not by that grep; a verdict naming an open or closed record is the signal to narrow or drop, not to proceed.

**Files to modify**:
- `specs/865_tm_plus_lc_axiomatization_and_automaton_obstruction/task-proposals.json` - new; the two-element proposal array in set-mode shape
- `specs/865_tm_plus_lc_axiomatization_and_automaton_obstruction/task-proposals-audit.ndjson` - new; the audit script's verdict output, one line per proposal, retained as the filing evidence

**Verification**:
- `audit-task-proposals.sh` exits 0 and the NDJSON has exactly two lines.
- Every line parses under `jq -e .` and carries a non-empty `.verdicts` array.
- Each proposal's disposition (proceed / narrow / drop) is written down before Phase 3 starts.

---

### Phase 3: File the Surviving Follow-Ons [COMPLETED]

**Goal**: The follow-ons that survived Phase 2's audit exist as `not_started` tasks in
`specs/state.json` with declared `file_scope`, and `TODO.md` renders them.

**Tasks**:
- [x] Decision gate: for each proposal, proceed only on a `genuinely-new` verdict (or `overlaps-open`, adding the dependency edge via `update-task-status.sh --depends-on-add` and annotating it `(auto: file overlap)`). On any other verdict, drop or narrow that proposal and record the decision — do not file it unchanged. *(completed: both R1 and R2 are genuinely-new)*
- [x] For each surviving proposal, create the entry with `bash .claude/scripts/state-write.sh '<filter>' --session-id "$session_id" --allocate-into N --audit-verdict specs/865_.../task-proposals-audit.ndjson --regen-todo`, appending to `active_projects` with `+=` (never a wholesale `.active_projects = [...]` assignment), each entry carrying `project_number`, `project_name`, `status: "not_started"`, `task_type: "lean4"`, `file_scope`, `created`, `last_updated`, `next_artifact_number: 1`. *(completed: filed as project 870 (R1) and 871 (R2); worked around state-write.sh's per-argv size ceiling on --audit-verdict with a condensed evidence file -- see progress/phase-3-progress.json)*
- [x] Verify each proposal's `id` matches the `project_name` written, so the audit evidence gate finds its covering entry. *(completed)*
- [x] Render the Component 7 confirmation table (number, title, task type, effort, dependencies, backlog check) into the Phase 3 notes for the summary to carry; no interactive prompt is issued (see Risks). *(completed: see Phase 3 notes below and the summary)*
- [x] Run `bash .claude/scripts/validate-state.sh` and read its output in full. *(completed: exit 0, PASSED WITH WARNINGS, 0 failures)*
- [x] Commit `specs/state.json` and `specs/TODO.md` by explicit path only, after `git status --short` confirms no sibling's uncommitted hunks are mixed in. *(completed)*

#### Phase 3 Notes: Component 7 Confirmation Table

The task description's own "file the implementation as its own task" instruction is this
task's pre-authorization for these two filings (see the Multi-Task Creation Standard risk row
above); the table below is the record of that confirmation, rendered here since no interactive
foreground prompt was issued.

| # | Title | Task Type | Effort | Dependencies | Backlog Check |
|---|-------|-----------|--------|---------------|----------------|
| 870 | Oriented-forest Saturation lemma for TaskFrame | lean4 | ~1 hour | None | `genuinely-new` after narrowing `file_scope` to drop `FormalSystem/Semantics/README.md` (initial audit hit a `duplicate-of-open` against task 869 on that one shared, low-specificity file; 869's actual content — open-future/open-past modal invariance — is unrelated) |
| 871 | Correct LCU docstring and restore omega_chain segment-property parameter | lean4 | ~0.5 hours | None | `genuinely-new`; no open-side overlap at any audit pass |

**Timing**: 0.75 hours

**Depends on**: 2

**Verification Tier**: local

**Tier Justification**: the edit is confined to `specs/state.json` plus the `TODO.md` view generated from it, and `bash .claude/scripts/validate-state.sh` is the whole-file consistency lint for exactly that pair (including the Check 12 allocation invariant `--allocate-into` writes against).

**Scope Hypothesis**: exactly two new `active_projects` entries are added and `next_project_number` advances accordingly (870 was the cached value at plan time, but `--allocate-into` derives the number from membership, so the actual numbers may differ and must be read from the script's output rather than assumed). Confirm by diffing `jq '.active_projects | length'` before and after, and by `validate-state.sh` exiting 0.

**Files to modify**:
- `specs/state.json` - append one `active_projects` entry per surviving proposal, via `state-write.sh` under the mutex
- `specs/TODO.md` - regenerated by `--regen-todo`; never hand-edited

**Verification**:
- `validate-state.sh` exits 0.
- `jq '.active_projects | map(select(.status == "not_started")) | length'` increased by the number of surviving proposals, and each new entry has a non-empty `file_scope`.
- `TODO.md` renders each new task with bracket-only artifact-link format and no `[name](path)` links.
- `git diff --staged` names only `specs/state.json` and `specs/TODO.md`.

---

### Phase 4: Summary and Final Gate [COMPLETED]

**Goal**: The task's close-out record exists, states what was filed and what was deliberately
not, and the repository passes its full gate set with `FormalSystem/` and `Tests/` untouched.

**Tasks**:
- [x] Write `specs/865_tm_plus_lc_axiomatization_and_automaton_obstruction/summaries/01_lc-axiomatization-automaton-obstruction-summary.md` per `summary-format.md`, covering: the report's verdict in two sentences (doubled one-sided automaton sufficient in shape conditional on separation; the AA carrier is the binding obstruction and is intrinsic); the ZTime correction and the amendment that discharged R5; the Component 7 confirmation table for the filed tasks with their allocated numbers; and an explicit paragraph recording that R3 is gated on R1 and 867 and R4 is refused, with the reasons, so neither reads as an oversight. *(completed)*
- [x] Confirm no library change: `git status --short -- FormalSystem/ Tests/` is empty and `git diff --stat HEAD -- FormalSystem/ Tests/` is empty. *(completed: both empty)*
- [x] Run the complete gate set: `bash .claude/scripts/verify-deploy.sh`. Read the output; do not infer a pass. *(deviation: scoped to this dispatch's Batch Gate Deferral directive -- ran run-all.sh --only test-audit-task-proposals.sh,test-validate-artifact.sh,test-validate-state.sh,test-validate-task-creation-audit.sh (4 passed, 0 failed) covering this phase's own scripts; the complete gate set runs once for the whole /orchestrate batch at the end of the invocation, per dispatch 7)*
- [x] Write `.orchestrator-handoff.json` and `.return-meta.json`, and commit the summary by explicit path. *(completed)*

**Timing**: 0.75 hours

**Depends on**: 1, 3

**Verification Tier**: full

**Scope Hypothesis**: one new summary file is written and no file under `FormalSystem/` or `Tests/` is modified by any phase of this plan. Confirm by the two `git status`/`git diff` checks above, read before the gate run.

**Files to modify**:
- `specs/865_tm_plus_lc_axiomatization_and_automaton_obstruction/summaries/01_lc-axiomatization-automaton-obstruction-summary.md` - new; the close-out record

**Verification**:
- `bash .claude/scripts/validate-artifact.sh specs/865_.../summaries/01_lc-axiomatization-automaton-obstruction-summary.md summary` exits 0.
- `bash .claude/scripts/verify-deploy.sh` runs to completion and is observed green (the complete gate set, not a `--only-gate` subset and not `--skip-slow`).
- `git status --short -- FormalSystem/ Tests/` is empty.
- `.orchestrator-handoff.json` validates (the write-time `validate-handoff-location.sh` gate accepts it) and `.return-meta.json` carries `status: "implemented"` with `dispatch_seq` echoed.

---

## Testing & Validation

- [ ] `bash .claude/scripts/validate-artifact.sh <report-03-path> report` exits 0 after the amendment.
- [ ] `bash .claude/scripts/audit-task-proposals.sh --proposals-file ...` exits 0; its NDJSON parses and carries a verdict list per proposal.
- [ ] `bash .claude/scripts/validate-state.sh` exits 0 after the filings.
- [ ] `bash .claude/scripts/validate-artifact.sh <summary-path> summary` exits 0.
- [ ] `bash .claude/scripts/verify-deploy.sh` observed green in the dispatch that closes Phase 4.
- [ ] `git status --short -- FormalSystem/ Tests/` empty at every phase boundary.
- [ ] No commit stages a directory or glob pathspec; every commit names files explicitly.

## Artifacts & Outputs

- `specs/865_tm_plus_lc_axiomatization_and_automaton_obstruction/plans/01_lc-axiomatization-automaton-obstruction.md` (this plan)
- `specs/865_tm_plus_lc_axiomatization_and_automaton_obstruction/task-proposals.json`
- `specs/865_tm_plus_lc_axiomatization_and_automaton_obstruction/task-proposals-audit.ndjson`
- `specs/865_tm_plus_lc_axiomatization_and_automaton_obstruction/summaries/01_lc-axiomatization-automaton-obstruction-summary.md`
- Amended `specs/559_nondeterministic_canonical_model_tm_star_completeness/reports/03_axiomatizability-rules-engine.md`
- Two new `not_started` entries in `specs/state.json`, rendered into `specs/TODO.md`

## Rollback/Contingency

Every phase is a single-file or single-script change with its own commit, so reverting is a
targeted `git revert` of that commit — no working-tree discard is needed and none is planned.

- **Phase 1**: revert the amendment commit. The consequence sentence was never rewritten, so the
  file returns to its prior state exactly.
- **Phase 2**: the two written files are evidence only, consumed by nothing else; delete them or
  revert the commit.
- **Phase 3**: the hazard is a wrongly-filed task, not a corrupted file. Remedy forward rather
  than by reverting a shared file that siblings also write this cycle: mark the entry
  `abandoned` via `bash .claude/scripts/update-task-status.sh`, which keeps `state.json`'s
  append-only discipline intact. Do **not** hand-edit `state.json` or `TODO.md` to remove an
  entry, and do not `git revert` a `state.json` commit that a sibling task has since extended.
- **Phase 4**: revert the summary commit.

If a rollback that would discard uncommitted work ever becomes genuinely necessary, follow
`.claude/context/contracts/recovery.md`'s rollback rung for the exact `git-snapshot.sh`
invocation shape; this plan emits no precautionary snapshot step, and no phase needs one.
