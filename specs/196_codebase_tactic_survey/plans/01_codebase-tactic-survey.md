# Implementation Plan: Task #196

- **Task**: 196 - Codebase-wide tactic opportunity survey and survivor re-scoping
- **Status**: [COMPLETED]
- **Effort**: 10 hours
- **Dependencies**: None
- **Research Inputs**:
  - specs/196_codebase_tactic_survey/reports/01_team-research.md
  - specs/196_codebase_tactic_survey/reports/01_teammate-a-findings.md
  - specs/196_codebase_tactic_survey/reports/01_teammate-b-findings.md
  - specs/196_codebase_tactic_survey/reports/01_teammate-c-findings.md
  - specs/196_codebase_tactic_survey/reports/01_teammate-d-findings.md
- **Artifacts**: plans/01_codebase-tactic-survey.md (this file)
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md
- **Type**: lean4

## Overview

This is a **survey**, not an implementation: no Lean source file may be modified. The task
produces one analysis report plus a set of task-management decisions. The single most valuable
output is a concrete recommendation — re-scoped charter, merge, or abandon — for each of the three
undescribed survivor tasks 186, 192 and 193, which currently sit mid-chain with empty descriptions
and cannot be orchestrated.

The plan is dominated by one fact discovered while planning: **the May 2026 research report is
substantially stale at the file level and materially stale at the conclusion level.** The report
surveyed 149 files / 92K lines; the tree now holds 278 live `.lean` files / 185,531 lines. Every
monolithic file the report names by path (`SoundnessLemmas.lean`, `Hierarchy.lean`, `EFGames.lean`,
`ExpressivenessGeneral.lean`, `Automation/Tactics.lean`, `Automation/ProofSearch.lean`) has been
split into a directory and no longer exists at the cited path. More importantly, the report's two
headline strategic findings have both moved: `modal_search` went from 3 occurrences to 126, and
executable `sorry` calls went from ~41 to 1. Phase 1 therefore re-establishes the measured
baseline before any inventory or re-scoping reasoning is allowed to proceed.

### Research Integration

The four teammate reports and the synthesis are treated as a **hypothesis list, not a fact base**.
Pattern-level findings largely survive re-measurement (`theorem_in_mcs` 313 -> 321, `imp_trans`
180 -> 223, `deduction_theorem` 143 -> 155) and are carried forward. File-level findings and both
strategic headlines must be re-derived. The synthesis' "Existing Tasks: Keep/Modify/Defer" table
is superseded: it reasons about tasks 185, 187, 189, 190, 191, 194 and 195, all of which have
since completed and been archived — only 186, 192, 193 (and the partial 199) remain open.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No roadmap path was supplied in the delegation context and no roadmap phases are scheduled.

## Goals & Non-Goals

**Goals**:
- Re-derive the automation inventory against the current tree (278 live `.lean` files, excluding
  `Boneyard/`), with measured occurrence counts, estimated line savings, complexity, and
  dependency relationships, each traceable to a reproducible shell command.
- Produce a decision for each of tasks 186, 192 and 193: a paste-ready re-scoped charter, a merge
  target, or an abandonment rationale — grounded in the re-derived inventory, not in the stale
  report.
- Diagnose the current adoption state of `Theories/Bimodal/Automation/` (35 files, 21,576 lines)
  and extract the cost-of-bespoke-tactics evidence from task 199's blocker analysis.
- Identify genuinely uncovered pattern groups and produce ready-to-run task charters for them,
  without duplicating whatever 186/192/193 become.
- Flag every recommendation that rewrites proof bodies as requiring a dependency on the systematic
  Mathlib naming upgrade (task 402).

**Non-Goals**:
- Modifying any `.lean` file. This is a hard constraint, verified mechanically in every phase.
- Implementing, prototyping, or benchmarking any tactic.
- Re-litigating the fate of tasks 185/187/189/190/191/194/195 — all completed and archived.
- Running `lake build`. The survey reads source; it does not need a build, and a build changes no
  conclusion here.
- Editing `specs/ROADMAP.md`.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Implementer treats the May research report as current fact and reports dead file paths | H | H | Phase 1 is a dedicated stale-reference audit and gates all later phases; every path in the final report must be verified to exist by `test -f` before it is cited |
| Survey drifts into editing Lean sources to "just try" a tactic | H | M | Explicit non-goal; every phase's verification includes `git status --porcelain -- 'Theories/**/*.lean'` returning empty |
| Re-scoping 193 breaks downstream tasks 177 and 178, which both depend on it | M | M | Phase 4 must explicitly resolve the downstream impact on 177/178 for any recommendation that abandons or merges 193 |
| Declaration names cited become invalid after the naming upgrade (task 402) | M | H | Charter mandates reporting names as they exist now; every proof-body-rewriting proposal must declare a dependency on 402 |
| Orchestrator mode cannot show an `AskUserQuestion`, so the multi-task creation standard's user-confirmation component cannot be satisfied | M | H | Phase 6 branches: autonomous runs write ready-to-run `/task` invocations into the report instead of creating tasks, and say so plainly |
| State edits to 186/192/193 corrupt neighbouring entries in state.json | H | L | Phase 6 uses targeted `jq` updates keyed on `project_number`, writes to a temp file, diffs before replacing, and regenerates TODO.md via `generate-todo.sh` |
| Inventory becomes an unranked list of everything, repeating the report's failure mode | M | M | Phase 2 requires an explicit, written weighting formula and a hard cap of the top 10 ranked groups |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2, 3 |
| 4 | 5 | 4 |
| 5 | 6 | 5 |

Phases within the same wave can execute in parallel.

All phases write to the single deliverable report
`specs/196_codebase_tactic_survey/reports/02_automation-survey.md`. Each phase **appends** its own
top-level `##` section and must not rewrite sections written by earlier phases.

---

### Phase 1: Measured Baseline and Stale-Reference Audit [COMPLETED]

**Goal**: Replace the May 2026 research report's factual claims with measurements taken against
the current tree, and record exactly which of its claims no longer hold.

**Tasks**:
- [ ] Create `reports/02_automation-survey.md` with a header stating the survey date, the tree
      state it measures, and an explicit note that `reports/01_team-research.md` is historical.
- [ ] Measure and record: live `.lean` file count and total line count excluding `Boneyard/`;
      per-directory file and line counts for each `Theories/Bimodal/*/` subdirectory.
- [ ] Build a **stale-reference table** mapping every file path named in
      `reports/01_team-research.md` and the four teammate reports to its current location, or to
      "split into `<dir>/`", or to "removed". Verify each surviving path with `test -f`.
- [ ] Re-run the report's headline greps against the current tree and record old-vs-new counts.
      At minimum: `theorem_in_mcs`, `intro F M Omega`, `simp only [truth_at`,
      `DerivationTree.modus_ponens`, `imp_trans`, `deduction_theorem`, `modal_search`, `tauto`,
      `by_contra`, and executable `sorry` (`grep -rn '^\s*sorry\s*$'`).
- [ ] Write a short "Superseded Conclusions" subsection naming each research-report conclusion the
      measurements invalidate, with the number that invalidates it.
- [ ] Record the exact command used for every number in the report, so any figure is reproducible.

**Timing**: 1.5 hours

**Depends on**: none

**Files to modify**:
- `specs/196_codebase_tactic_survey/reports/02_automation-survey.md` - create; add sections
  "1. Measured Baseline", "2. Stale-Reference Audit", "3. Superseded Conclusions"

**Verification**:
- Report exists and contains all three sections.
- Every file path cited in the stale-reference table as surviving passes `test -f`.
- Every count in the baseline is accompanied by the command that produced it.
- `git status --porcelain -- 'Theories/**/*.lean'` is empty.

---

### Phase 2: Ranked Automation Inventory [COMPLETED]

**Goal**: Produce the ranked list of tactic/automation groups the charter's output (1) calls for,
measured against the current tree.

**Tasks**:
- [ ] State the ranking formula in writing before applying it, including how sorry-impact is
      weighted now that the executable sorry count is near zero.
- [ ] For each candidate pattern group, record: measured occurrence count, the directories and
      files where it concentrates, estimated line savings with the arithmetic shown, implementation
      complexity, and whether the group requires rewriting proof bodies.
- [ ] Carry forward the hypothesis groups from the research report that survive re-measurement,
      and add any group the re-derived counts surface that the report missed.
- [ ] Explicitly mark each group as naming-upgrade-sensitive or naming-upgrade-independent. Any
      group that rewrites proof bodies is sensitive and must carry a dependency on task 402.
- [ ] Rank the groups and cap the ranked table at the top 10; list anything below the cap in a
      short "considered and not ranked" paragraph with a one-line reason each.
- [ ] Record dependency relationships between groups (which group's tactic must exist before
      another group's refactor is possible).

**Timing**: 2 hours

**Depends on**: 1

**Files to modify**:
- `specs/196_codebase_tactic_survey/reports/02_automation-survey.md` - append section
  "4. Ranked Automation Inventory"

**Verification**:
- Ranked table has at most 10 rows and every row carries occurrence count, savings estimate,
  complexity, and the naming-upgrade sensitivity flag.
- The ranking formula appears in the report before the table.
- Every file path in the table was confirmed to exist in Phase 1's audit or is verified here.
- `git status --porcelain -- 'Theories/**/*.lean'` is empty.

---

### Phase 3: Adoption Evidence and Bespoke-Tactic Cost [COMPLETED]

**Goal**: Answer the question the research report raised but could not settle — is there an
adoption problem in `Automation/`, and what does a bespoke tactic actually cost — using current
evidence rather than the May snapshot.

**Tasks**:
- [ ] Measure current `Automation/` adoption: for each of the tactics exposed by
      `Theories/Bimodal/Automation/Tactics/` and `Theories/Bimodal/Automation/ProofSearch/`, count
      call sites and separate definition/test/example sites from real proof sites in
      `Metalogic/`, `Theorems/`, `Semantics/` and `ProofSystem/`.
- [ ] Determine whether the `modal_search` occurrence growth (3 -> 126) represents genuine proof-site
      adoption or growth of the automation subtree itself, and state which.
- [ ] Read `specs/199_grid_order_tactic/reports/02_blocker-analysis.md`,
      `specs/199_grid_order_tactic/summaries/01_grid-order-tactic-summary.md`, and
      `specs/199_grid_order_tactic/handoffs/phase-3-handoff-20260526.md`. Extract what the
      `grid_order_tac` attempt cost and why it stalled ("b_resp vs p_n ordering unprovable from
      current hypotheses").
- [ ] Read `specs/179_research_lean4_tactics_infrastructure/reports/01_team-research.md` for prior
      art on tactics infrastructure and note anything that changes a Phase 2 ranking.
- [ ] Write an explicit verdict on whether more bespoke tactics are warranted, and under what
      preconditions — this verdict feeds the Phase 4 decisions directly.

**Timing**: 1.5 hours

**Depends on**: 1

**Files to modify**:
- `specs/196_codebase_tactic_survey/reports/02_automation-survey.md` - append section
  "5. Adoption Evidence and Bespoke-Tactic Cost"

**Verification**:
- Adoption counts distinguish definition/test/example sites from real proof sites.
- The section states a one-paragraph verdict on further bespoke-tactic investment.
- Task 199's stall is characterised with a specific cause, not a generic "it was hard".
- `git status --porcelain -- 'Theories/**/*.lean'` is empty.

---

### Phase 4: Survivor Re-Scoping — Tasks 186, 192, 193 [COMPLETED]

**Goal**: Deliver the charter's highest-value output — one decision per survivor task, each
grounded in the re-derived inventory and the adoption verdict.

**Tasks**:
- [ ] For each of 186, 192, 193, read its seed report
      (`specs/186_unify_search_systems/reports/01_unify-search-seed.md`,
      `specs/192_master_tactic_dispatch/reports/01_master-dispatch-seed.md`,
      `specs/193_codebase_tactic_refactor/reports/01_codebase-refactor-seed.md`) and record its
      current `dependencies` and `file_scope` from `specs/state.json`.
- [ ] Audit each survivor's dependency list against live state. Record that 186 depends on
      `[185, 199]` where 185 is completed/archived and 199 is `[partial]`; that 192 depends on
      `[185, 187, 190, 191, 194]`, all five of which are completed and archived; and that 193
      depends on `[189, 192, 196, 402]` where 189 is completed/archived.
- [ ] Recommend exactly one outcome per survivor: **re-scope** (with a complete, paste-ready
      charter), **merge** (naming the absorbing task and what carries over), or **abandon** (with
      the rationale and what, if anything, is lost).
- [ ] For any re-scope, the charter must specify: scope statement, `file_scope`, corrected
      `dependencies`, effort estimate, and the inventory group(s) from Phase 2 it draws on.
- [ ] Resolve downstream impact: tasks 177 (`update_readme_and_module_docstrings`) and 178
      (`publication_examples_and_demo`) both declare a dependency on 193. Any recommendation that
      abandons or merges 193 must state what happens to those two dependency edges.
- [ ] State plainly, per survivor, which measured number drove the decision.

**Timing**: 2 hours

**Depends on**: 2, 3

**Files to modify**:
- `specs/196_codebase_tactic_survey/reports/02_automation-survey.md` - append section
  "6. Survivor Re-Scoping: Tasks 186, 192, 193"

**Verification**:
- Exactly three decisions are present, one per survivor, each being one of re-scope / merge /
  abandon.
- Every re-scope decision includes a paste-ready charter with scope, `file_scope`, `dependencies`
  and effort.
- The 177/178 downstream edges on 193 are explicitly addressed.
- Each decision cites at least one measured number from Phase 1 or Phase 2.
- `git status --porcelain -- 'Theories/**/*.lean'` is empty.

---

### Phase 5: New Task Proposals for Uncovered Groups [COMPLETED]

**Goal**: Propose new tasks only where a ranked inventory group is not covered by whatever
186/192/193 became.

**Tasks**:
- [ ] Build a coverage matrix: ranked inventory group (Phase 2) against the three re-scoped
      survivors (Phase 4). Every group is either covered, uncovered, or deliberately dropped.
- [ ] For each uncovered group worth pursuing, write a full task charter: title, snake_case slug,
      description, `task_type`, `file_scope`, `dependencies`, effort estimate.
- [ ] Add a dependency on task 402 (systematic Mathlib naming upgrade) to every proposed task that
      rewrites proof bodies. State the reason inline in the charter so it survives copy-paste.
- [ ] Write a "deliberately not spawned" subsection listing every ranked group that gets no task,
      each with a one-line reason.
- [ ] Emit, for each proposed task, the exact `/task "..."` invocation that would create it.

**Timing**: 1 hour

**Depends on**: 4

**Files to modify**:
- `specs/196_codebase_tactic_survey/reports/02_automation-survey.md` - append section
  "7. New Task Proposals"

**Verification**:
- The coverage matrix accounts for every group in the Phase 2 ranked table.
- No proposed task duplicates the scope of a re-scoped survivor.
- Every proof-body-rewriting proposal declares a dependency on 402.
- Every proposal has a ready-to-run `/task` invocation.
- `git status --porcelain -- 'Theories/**/*.lean'` is empty.

---

### Phase 6: Apply State Changes and Write Summary [COMPLETED]

**Goal**: Land the Phase 4 decisions in `specs/state.json`, handle new-task creation according to
what the run mode permits, and write the implementation summary.

**Tasks**:
- [ ] Apply each Phase 4 decision to the matching `active_projects` entry in `specs/state.json`
      using a targeted `jq` update keyed on `project_number`: write the new `description`, corrected
      `dependencies`, and `file_scope` for re-scoped survivors; set status to `abandoned` with a
      `completion_summary` for abandoned ones; for merges, update the absorbing task and mark the
      absorbed one. Write to a temp file, `diff` it against the original, and confirm only the
      intended entries changed before replacing.
- [ ] If 193 is abandoned or merged, update the `dependencies` arrays of tasks 177 and 178 as
      decided in Phase 4.
- [ ] **New-task creation branches on run mode.** If an interactive prompt is available, follow the
      multi-task creation standard — grouped presentation, `AskUserQuestion` multi-select, explicit
      user confirmation — then create the approved tasks. If the run is autonomous
      (`orchestrator_mode: true`, where no user confirmation can be obtained), create no new tasks:
      leave the ready-to-run `/task` invocations from Phase 5 in the report and record in both the
      report and the summary that creation was deferred for lack of user confirmation.
- [ ] Bump `next_artifact_number` for task 196 to 3 and register `reports/02_automation-survey.md`
      in its `artifacts` array.
- [ ] Run `bash .claude/scripts/generate-todo.sh` to regenerate TODO.md from state.json. Do not
      edit TODO.md by hand.
- [ ] Write `specs/196_codebase_tactic_survey/summaries/02_tactic-survey-summary.md`, leading with
      the three survivor decisions, then the ranked inventory headline, then what was deferred.

**Timing**: 1.5 hours

**Depends on**: 5

**Files to modify**:
- `specs/state.json` - re-scoped/abandoned entries for 186, 192, 193; dependency edges on 177/178
  if 193's fate requires it; task 196 `artifacts` and `next_artifact_number`
- `specs/TODO.md` - regenerated, never hand-edited
- `specs/196_codebase_tactic_survey/summaries/02_tactic-survey-summary.md` - create

**Verification**:
- `jq empty specs/state.json` succeeds.
- `jq '.active_projects[] | select(.project_number==186 or .project_number==192 or
  .project_number==193) | {project_number, status, description}'` shows a non-null description for
  every survivor that was re-scoped.
- The state.json diff touches only the intended entries.
- TODO.md regenerated by script; `git diff --stat specs/TODO.md` shows changes consistent with the
  state edits.
- Summary exists and leads with the three survivor decisions.
- `git status --porcelain -- 'Theories/**/*.lean'` is empty.

---

## Testing & Validation

- [ ] No `.lean` file under `Theories/` is modified at any point:
      `git status --porcelain -- 'Theories/**/*.lean'` returns empty at the end of every phase.
- [ ] Every file path cited in `reports/02_automation-survey.md` exists — verified by a final pass
      that `test -f` each one.
- [ ] Every numeric claim in the report is accompanied by the command that produced it.
- [ ] Exactly three survivor decisions are present, one each for 186, 192 and 193.
- [ ] `jq empty specs/state.json` succeeds after Phase 6.
- [ ] No proposed new task duplicates the scope of a re-scoped survivor.
- [ ] Every proof-body-rewriting recommendation declares a dependency on task 402.
- [ ] The report states its own staleness horizon: which findings survive the naming upgrade and
      which do not.

## Artifacts & Outputs

- `specs/196_codebase_tactic_survey/plans/01_codebase-tactic-survey.md` (this file)
- `specs/196_codebase_tactic_survey/reports/02_automation-survey.md` — the survey deliverable,
  sections 1-7 appended across phases 1-5
- `specs/196_codebase_tactic_survey/summaries/02_tactic-survey-summary.md`
- Updated `specs/state.json` entries for tasks 186, 192, 193 (and 177/178 if 193's fate requires)
- Regenerated `specs/TODO.md`
- New task entries, only when an interactive confirmation was obtainable

## Rollback/Contingency

No Lean source is touched, so rollback is confined to task-management artifacts.

- **Report/summary**: delete `reports/02_automation-survey.md` and
  `summaries/02_tactic-survey-summary.md`. Nothing else depends on them.
- **state.json**: the Phase 6 edits are the only destructive step. Before editing, capture
  `git stash`-free recovery by relying on the last commit — `git diff specs/state.json` shows the
  full change, and `git checkout HEAD -- specs/state.json` restores it, followed by
  `bash .claude/scripts/generate-todo.sh` to resync TODO.md. Do not run this while other
  uncommitted state.json changes from concurrent tasks are present; check `git diff --stat` first.
- **New tasks created in error**: use `/task --abandon N` rather than deleting entries by hand.
- **Partial completion**: phases 1-5 are append-only against a single report, so an interrupted run
  resumes at the first section not yet appended. Phase 6 is the only phase that must run to
  completion once started; if it fails mid-way, restore state.json as above and re-run it whole.
