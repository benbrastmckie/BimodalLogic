# Implementation Plan: Task #959

- **Task**: 959 - Review proof mode tasks and prepare roadmap planning document
- **Status**: [COMPLETED]
- **Effort**: 3.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/959_review_proof_mode_tasks_and_prepare_roadmap_planning_document/reports/01_proof-mode-roadmap-review.md
- **Artifacts**: plans/01_proof-mode-goals-document.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Write `records/proof-mode.md`, a long-horizon goals document for the derivation proof mode. The
file exists and is empty (0 bytes). The document states the aim, what is merged, the dimensions
still to develop, a set of milestones with their hard and sequencing-only dependencies, the two
adequacy gates, lanes for division of labour, open decisions, and a list of milestones that have
no filed record yet. Done means the file is complete, self-contained, internally consistent,
free of task numbers and draft-history language, and usable as the named input of a later
`/roadmap` instruction. No Lean is written and no task record or dependency edge is changed.

### Research Integration

From `reports/01_proof-mode-roadmap-review.md`:

- The merged state (21 tactics, 5 elaborator modules, 8 pure-rule modules, 31 acceptance
  examples, 2 negative tests, no client outside the tests). The report's figures are used as
  starting values and re-measured in Phase 1.
- Fourteen filed follow-on records form one total chain. The report reads at least five edges as
  sequencing edges that exist because every record edits the same test file, user guide and two
  READMEs. Three readings are marked doubtful and are re-examined in Phase 2.
- Eight dimensions plus two cross-cutting ones (trust and cost; dual verification).
- A 19-row milestone table (M0 to M15, with M6 and M9 split), a hard-dependency graph, and five
  lanes.
- `/roadmap` reads tasks from `specs/state.json`, not documents. The document reaches it through
  tasks filed from the "not yet filed" list and through a quoted instruction naming the file.
- `research/NEW_DIRECTIONS.md` is gitignored and says 22 tactics where two searches give 21. The
  document cites tracked files only and uses the measured count.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was given in this dispatch and `roadmap_flag` is not set, so `specs/ROADMAP.md`
is not edited and no roadmap phases are added. The document is written to feed a later `/roadmap`
run; it does not restate batch order or batch rationale.

## Goals & Non-Goals

**Goals**:
- A complete `records/proof-mode.md` with the nine sections listed in Phase 1 to Phase 3.
- Every milestone has: aim, done-when, hard dependencies, sequencing-only dependencies, lane, and
  either the slug of its filed record or "not filed".
- Every figure about the merged code is re-measured at writing time.
- The "not yet filed" list is written so each item can be passed to `/task` unchanged.
- A short section giving the exact `/roadmap` instruction that consumes the document.

**Non-Goals**:
- Creating tasks, changing `dependencies[]`, or editing `roadmap_batches` / `roadmap_notes`.
- Editing `ORGANISATION.md`, `README.md`, or any file other than `records/proof-mode.md` (the
  task's `file_scope` is that one file).
- Any Lean change, `lake build`, or measurement of derivation term sizes.
- Deciding the open questions the document lists. It records them for the user.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Task numbers leak into the document; the write-time hook `hooks/validate-no-task-references.sh` rejects the write | M | M | Milestones use document-local IDs and record slugs only. The number-to-slug map stays in the research report. Phase 3 runs the task-reference lint |
| Draft-history wording ("no longer", "previously", version labels) | M | M | State the current design only. Phase 3 greps for the forbidden phrasings |
| The edge readings are taken as settled | M | M | The document labels them a proposed reading and lists the three doubtful ones under open decisions |
| The document repeats `specs/ROADMAP.md` | L | M | Goals and joints only; no batch order, no batch rationale |
| A carried figure is stale or wrong (the 22-versus-21 case) | M | L | Phase 1 re-runs each measurement; nothing is copied from the gitignored source |
| A cited path does not exist, or a gitignored file is cited as an anchor | M | L | Phase 3 checks every backticked repository path with `test -e` and `git check-ignore` |
| `records/` has no row in `ORGANISATION.md`; a repository lint may object to a new top-level directory | L | L | Out of `file_scope`. The document lists it as an open decision; Phase 3 records what `scripts/check-module-invariants.sh` reports, without editing other files |
| Lanes are read as safe to run in parallel today | H | M | The document says plainly that without M0 the shared test file forces the present total order |

## Decisions

- **Local IDs and slugs, never task numbers.** `records/` is outside `specs/`, so
  `.claude/rules/no-task-references-in-deliverables.md` applies. Slugs
  (`proof_mode_s5_aware_box_scopes`) survive renumbering.
- **The existing cut at the adequacy gate is kept as the spine.** The document proposes side
  branches, not a reordering. The Perpetuity gate is described exactly as filed.
- **Tactic count is 21**, subject to the Phase 1 re-measurement.
- **`ORGANISATION.md` is not edited.** Whether `records/` gets a row there is the user's call and
  lies outside this task's declared scope. It is recorded as an open decision, not raised as a
  blocking `user_decision`: the task description names the path explicitly.
- **Milestones keep the report's M0 to M15 numbering** with M6a/M6b/M6c and M9a/M9b, so the
  report's task-number mapping stays usable as a private key.
- **No edge is relaxed by this task.** The roadmap agent's contract describes adding edges, not
  removing them; the document says that relaxing a sequencing edge is a separate user step.

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |

Phases within the same wave can execute in parallel. All three phases edit one file, so the
order is strict.

### Phase 1: Aim, Current State and Dimensions [COMPLETED WITH EXCLUSIONS]

**Goal**: Write the framing half of the document on re-measured facts.

**Tasks**:
- [x] Re-measure the merged state and record the commands' outputs in working notes: tactic
  names (`grep '^syntax (name :='` over `FormalSystem/Automation/ProofMode/*.lean`), line counts
  of the elaborator and pure-rule modules (`wc -l`), `Plus*.lean` total, `throwError` count,
  `^example` count and negative-test count in
  `Tests/BimodalTest/Automation/ProofModeTest.lean`, absence of `sorry` / `axiom` /
  `native_decide`, clients (`grep -rln ProofMode --include=*.lean FormalSystem Tests BimodalTools`),
  absence of `#print axioms` in the test file, absence of coverage under `typst/`. *(completed)*
- [x] Check the import invariant the report carried unverified: that `FormalSystem/Theorems/`
  does not import `FormalSystem/Automation/`. Read `scripts/module-invariants-manifest.txt` and
  `scripts/check-module-invariants.sh` for the rule, and confirm with
  `grep -rn '^import FormalSystem.Automation' FormalSystem/Theorems`. If the invariant is not
  enforced or does not hold, say so in the document instead of asserting it. *(completed)*
- [x] Write the title and a two-line statement of what the document is and is not (a goals
  document; batch order lives in the roadmap). *(completed)*
- [x] Write **Aim**: one paragraph. From a tested frontend to the ordinary way TM derivations are
  written, then to specification reasoning; nothing semantic stands in for a derivation. *(completed)*
- [x] Write **Where it stands**: the measured table without a method column; what the merged
  work established (scope safety by typing, integer-time invariance derived in the calculus, the
  TM-plus deduction theorem and generalized K); the gap list (no client, no axiom audit in
  tests, no reference-manual coverage, two negative tests against 65 error sites). Cite
  `docs/user-guide/derivation-proof-mode.md` and the two ProofMode READMEs as anchors. *(completed)*
- [x] Write **Dimensions**: the eight dimensions and the two cross-cutting ones, each with a
  done-state, what filed records cover it (by slug), and the gap. *(completed)*

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: prose

**Tier Justification**: The edit is one markdown file with no compile surface; `suite_selection_select records/proof-mode.md` returns only `__FULL_SWEEP__` (no suite covers it), so the covering check is the diff read-through plus `bash .claude/scripts/verify-touched.sh records/proof-mode.md`.

**Scope Hypothesis**: The report's figures (21 tactics; 5 elaborator files, 1,013 lines; 8
pure-rule files, 1,157 lines; 624 lines of TM-plus copies; 65 `throwError` sites; 31 examples; 2
negative tests) are hypotheses. The implementer confirms each by re-running the command above
and writes the value observed, noting any difference in the summary. The count of dimensions
(eight plus two) is likewise a starting point; merge or split if the writing shows it is wrong.

**Files to modify**:
- `records/proof-mode.md` - title, Aim, Where it stands, Dimensions

**Verification**:
- Every number in "Where it stands" matches a command output from this phase.
- No task number, no `research/` path, no draft-history wording in the sections written.
- `bash .claude/scripts/verify-touched.sh records/proof-mode.md` reports no failure.

#### Reasoned Exclusions

| Item | Reason | Evidence |
|------|--------|----------|
| Verification criterion: `bash .claude/scripts/verify-touched.sh records/proof-mode.md` reports no failure | Not applicable to this deliverable. No suite maps to the path, so the script runs its 95-suite fallback, and the suites that fail are agent-system fixture tests that need the source store `agent-system/extensions/`, which this repository does not contain. None reads the markdown file. The covering check for this prose phase is the diff read-through. | Phase 1 run: `84 passed, 11 failed`; final-file run in Phase 3: `83 passed, 12 failed`, the same 11 plus `test-lint-state-writer-boundary.sh`, which passes when run alone (no `[FAIL]` line on rerun; intermittent). `test-generate-task-order.sh` prints `generate-task-order.sh not found (mode=source-store): .../agent-system/extensions/core/scripts/generate-task-order.sh`; `test-manifest-scripts-sync.sh` prints `agent-system/extensions does not exist`. Resolution summary of the run: `SELECT: (none)`, `OWED: records/proof-mode.md`, recorded in `records/full-sweep-owed.jsonl` in the task directory. |

---

### Phase 2: Milestones, Dependency Picture, Gates and Lanes [COMPLETED WITH EXCLUSIONS]

**Goal**: Write the core of the document: the milestone blocks and how they connect.

**Tasks**:
- [x] Re-examine the three edge readings the report marks doubtful, by reading the filed
  descriptions in `specs/state.json` (select by slug) and the relevant Lean sources:
  (a) linearity case split before Until/Since introduction, unfolding and induction
  (`proof_mode_linearity_case_tactic` to `proof_mode_until_since_intro_unfold_induction`);
  (b) other-language instances before the leads-to library
  (`proof_mode_instances_other_languages` to `proof_mode_leads_to_invariance_library`);
  (c) Until/Since rules and the usability record before Dense and real-time rules
  (into `proof_mode_dense_and_real_time_rules`; check that `density` and `coDerived` take the
  frame-class parameters the report names). For each, write down logical, sequencing, or
  undetermined, with the ground. Undetermined stays undetermined. *(completed)*
- [x] Write **Milestones**: one block per milestone, M0 to M15 with M6a/M6b/M6c and M9a/M9b. Each
  block has the same six fields in the same order: Aim, Done when, Hard dependencies,
  Sequencing-only dependencies, Lane, Filed record (slug, or "not filed"). "Done when" is a
  checkable condition, not a description of activity. *(deviation: altered — M14 split into M14a/M14b; 20 blocks)*
- [x] State at the top of the section that the hard / sequencing split is a proposed reading of
  the records' descriptions, and that sequencing edges bind until M0 lands. *(completed)*
- [x] Write **Dependency picture**: the hard-dependency graph as a fenced text diagram, followed
  by one sentence per milestone with no hard predecessor. *(completed)*
- [x] Write **Gates**: the Perpetuity adequacy gate and the temporal-slice gate; what GO and
  RE-PLAN each mean; which milestones wait on each verdict; that nothing here weakens the first
  gate. *(completed)*
- [x] Write **Lanes**: rule theory, elaborators, evaluation, metatheory, research and writing;
  which milestones fall in each; the rule / tactic seam inside a milestone (a pure rule can land
  ahead of its tactic, if Phase 1 confirmed the import invariant); the plain statement that M0
  is what buys parallel lanes. *(completed)*

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: prose

**Tier Justification**: Same single markdown file with no compile surface and no mapped suite (selector output `__FULL_SWEEP__` only); the covering check is the diff read-through plus `bash .claude/scripts/verify-touched.sh records/proof-mode.md`.

**Scope Hypothesis**: Nineteen milestone blocks, following the report's table. The implementer
confirms the count against the report and may merge or split blocks where a done-when cannot be
stated cleanly, recording the change in the summary. The report's dependency columns are
hypotheses for the three doubtful edges and are replaced by this phase's findings.

**Files to modify**:
- `records/proof-mode.md` - Milestones, Dependency picture, Gates, Lanes

**Verification**:
- Every milestone block has all six fields.
- Every ID named in a dependency field has its own block.
- The diagram shows exactly the hard dependencies stated in the blocks; no cycle.
- Each of the three re-examined edges carries a stated reading and ground.
- `bash .claude/scripts/verify-touched.sh records/proof-mode.md` reports no failure.

#### Reasoned Exclusions

| Item | Reason | Evidence |
|------|--------|----------|
| Verification criterion: `bash .claude/scripts/verify-touched.sh records/proof-mode.md` reports no failure | Not applicable to this deliverable. No suite maps to the path, so the script runs its 95-suite fallback, and the suites that fail are agent-system fixture tests that need the source store `agent-system/extensions/`, which this repository does not contain. None reads the markdown file. Not re-run in this phase; the Phase 3 run covers the file including this phase's sections. | Phase 1 run: `84 passed, 11 failed`; final-file run in Phase 3: `83 passed, 12 failed`, the same 11 plus `test-lint-state-writer-boundary.sh`, which passes when run alone (no `[FAIL]` line on rerun; intermittent). `test-generate-task-order.sh` prints `generate-task-order.sh not found (mode=source-store): .../agent-system/extensions/core/scripts/generate-task-order.sh`; `test-manifest-scripts-sync.sh` prints `agent-system/extensions does not exist`. Resolution summary of the run: `SELECT: (none)`, `OWED: records/proof-mode.md`, recorded in `records/full-sweep-owed.jsonl` in the task directory. |

---

### Phase 3: Open Decisions, Unfiled Work, Roadmap Use and Final Checks [COMPLETED WITH EXCLUSIONS]

**Goal**: Close the document and check the whole file.

**Tasks**:
- [x] Write **Open decisions**: the edges left undetermined in Phase 2; what "default" means for
  the adoption milestone given the import invariant; whether `records/` gets a row in
  `ORGANISATION.md`; whether sequencing edges are relaxed once M0 lands, and that doing so is a
  user step outside what `/roadmap` does. *(completed)*
- [x] Write **Not yet filed**: one entry per milestone marked "not filed" (M0, M9b, M12, M13,
  M14, M15, plus any Phase 2 added). Each entry is a self-contained description: what to build,
  the done-when, the files it is expected to touch, and its hard dependencies by slug or local
  ID. An entry must read correctly when pasted into `/task` without the rest of the document. *(completed)*
- [x] Write **Using this document with the roadmap**: the three channels (tasks filed from the
  list above; a quoted `/roadmap` instruction naming `records/proof-mode.md`; edge changes by
  the user), with one example instruction. *(completed)*
- [x] Read the whole file top to bottom once for consistency: milestone IDs, slugs, counts, and
  section cross-references agree across sections. *(completed)*
- [x] Task-reference check: `bash .claude/scripts/check-task-references.sh` shows no finding for
  `records/proof-mode.md`. *(completed)*
- [x] Draft-history check:
  `grep -nEi 'no longer|previously|formerly|used to|supersed|carried forward|withdrawn|\(v[0-9]+\)' records/proof-mode.md`
  returns nothing, or each hit is read and is not draft-history language. *(completed)*
- [x] Path check: extract every backticked repository path from the file; each passes `test -e`
  and none is reported by `git check-ignore`. *(deviation: altered — three hits read and accepted: the globs `FormalSystem/*Language/` and `Plus*.lean`, and `Tests/BimodalTest/Automation/ProofMode/`, named as a directory M0 creates)*
- [x] Slug check: every `proof_mode_*` slug in the file is a `project_name` in
  `specs/state.json`. *(completed: 14 slugs, all present; the bare prefix `proof_mode_` is prose)*
- [x] Run `bash scripts/check-module-invariants.sh` only if it completes in bounded time on this
  host (hard timeout, per `context/patterns/bounded-build-waiter.md`); record whether any finding
  names `records/`. Do not edit other files to clear such a finding; report it in the summary. *(completed: ALL CHECKS PASSED in under 400s; no finding names records/)*
- [x] Run `bash .claude/scripts/verify-touched.sh records/proof-mode.md`. *(deviation: altered — run on the final file; fails on suites unrelated to the deliverable, see Reasoned Exclusions)*

**Timing**: 1 hour

**Depends on**: 2

**Verification Tier**: full

**Scope Hypothesis**: Six unfiled milestones (M0, M9b, M12, M13, M14, M15), taken from the
report's table. The implementer confirms the list against the Phase 2 blocks marked "not filed".
Expected document length is 250 to 400 lines; this is an estimate, not a bar.

**Files to modify**:
- `records/proof-mode.md` - Open decisions, Not yet filed, roadmap-use section, consistency fixes

**Verification**:
- The four mechanical checks above (task-reference, draft-history, path, slug) pass.
- `bash .claude/scripts/verify-touched.sh records/proof-mode.md` is the phase's own in-dispatch
  check. Under `/orchestrate` the complete gate set is deferred to the orchestration close and
  is not run here. In a standalone run, run `bash .claude/scripts/verify-deploy.sh` instead.
- The file has all nine sections and is non-empty.

#### Reasoned Exclusions

| Item | Reason | Evidence |
|------|--------|----------|
| Verification criterion: `bash .claude/scripts/verify-touched.sh records/proof-mode.md` reports no failure | Not applicable to this deliverable. No suite maps to the path, so the script runs its 95-suite fallback, and the suites that fail are agent-system fixture tests that need the source store `agent-system/extensions/`, which this repository does not contain. None reads the markdown file. The complete gate set is deferred to the batch stage under the dispatch's Batch Gate Deferral directive. | Phase 1 run: `84 passed, 11 failed`; final-file run in Phase 3: `83 passed, 12 failed`, the same 11 plus `test-lint-state-writer-boundary.sh`, which passes when run alone (no `[FAIL]` line on rerun; intermittent). `test-generate-task-order.sh` prints `generate-task-order.sh not found (mode=source-store): .../agent-system/extensions/core/scripts/generate-task-order.sh`; `test-manifest-scripts-sync.sh` prints `agent-system/extensions does not exist`. Resolution summary of the run: `SELECT: (none)`, `OWED: records/proof-mode.md`, recorded in `records/full-sweep-owed.jsonl` in the task directory. |

## Testing & Validation

- [x] `records/proof-mode.md` has the sections: Aim, Where it stands, Dimensions, Milestones,
  Dependency picture, Gates, Lanes, Open decisions, Not yet filed, and the roadmap-use section. *(completed)*
- [x] No task number anywhere in the file (`check-task-references.sh`). *(completed)*
- [x] No draft-history wording (grep in Phase 3). *(completed)*
- [x] Every cited path exists and is tracked or trackable (not gitignored). *(completed)*
- [x] Every dependency ID resolves to a block; the hard-dependency graph has no cycle. *(completed)*
- [x] Every figure about merged code was re-measured in Phase 1. *(completed)*
- [x] `git status --short` shows no change outside `records/proof-mode.md` and this task's
  `specs/` directory from this work. *(completed)*

## Artifacts & Outputs

- `records/proof-mode.md` - the goals document (the deliverable)
- `specs/959_review_proof_mode_tasks_and_prepare_roadmap_planning_document/summaries/01_proof-mode-goals-document-summary.md` -
  implementation summary, including re-measured figures that differ from the report, the three
  edge findings, and any lint finding about `records/`

## Rollback/Contingency

The deliverable is one new file with no dependents. To revert, empty or delete
`records/proof-mode.md`; nothing else changes. If a phase is interrupted, the sections already
written stay in place and the next dispatch resumes at the first phase not marked completed. If
the write-time hook rejects a write, fix the flagged text and write again; do not add an
exemption marker to get past it.
