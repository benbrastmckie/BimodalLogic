# Implementation Plan: Task #700

- **Task**: 700 - lplus_completeness_programme_survey
- **Status**: [IMPLEMENTING]
- **Effort**: 3.5 hours
- **Dependencies**: None (this task blocks 696, whose `dependencies` array is `[700]`)
- **Research Inputs**: `specs/700_lplus_completeness_programme_survey/reports/01_lplus-completeness-programme-survey.md`
- **Artifacts**: plans/01_completeness-programme-sequencing.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: formal:logic
- **Lean Intent**: false

## Overview

The survey round is done: the report carries the dependency graph, the wave order, the
reachability verdict, the cross-repository hand-off list and exactly two justified task
proposals. This plan executes only what remains — re-check the three edges the report itself
flagged as provisional against the sibling reports that have since landed, create the two
proposed task entries and nothing else, and record the cross-repository coordination point
durably. **No Lean source, no other task's declared territory, and no file under
`/home/benjamin/Projects/ModelChecker` is touched.** Done means: two new entries exist with
justified dependencies, the graph's provisional edges are resolved in writing, the hand-off
names every declaration by fully-qualified name, and `validate-state.sh` is green.

### Research Integration

Four conclusions from the report drive this plan directly:

1. **Exactly two task entries, in a fixed order**: `lplus_compression_and_completeness`
   (the target theorem, the single largest gap, no owner today) and
   `certificate_non_vacuity_and_shape_gates` (both structural preventions as one task, last
   because a gate landed before the substrate repair goes red on the very refactor it exists
   to protect). Everything else in the survey scope is already owned — items (1), (2), (3) by
   tasks 696, 695 and 699 respectively, and item (4), the general finite-premise consequence
   form, is parallel to the critical path and gets no task at all.
2. **Three edges were explicitly marked provisional** (E2, E5, E8 — "when those two reports
   land, re-check"). Task 695's, 698's and 699's research reports have all landed since the
   survey was written, so the re-check is now cheap and owed. A first read already shows it is
   not a formality: 699's Part A concludes that task 696's recommended redesign *relocates*
   rather than repairs the collapse (`trans_refl` is the culprit) and proposes its own
   follow-on task for it, which bears on E2's strength and on how the new compression task's
   dependency text must be phrased.
3. **One declaration name in the hand-off list was marked "confirm on landing"**, and it is
   wrong as written: the survey named `FormalSystem.Semantics.plusValidZTime_iff_plusValidInt`
   from task 695's description, but 695's landed probe proves it inside
   `namespace FormalSystem.PlusLanguage`, with a new-module siting recommendation of
   `FormalSystem/PlusLanguage/PlusIntTransfer.lean`. The hand-off exists precisely so the
   cross-repository reference survives renumbering; a wrong namespace defeats that.
4. **The F7 nine-file table needs a named consumer.** The survey assigned widening 696's
   `file_scope` to task 698, but 698's landed report declines to widen any task's `file_scope`
   by inference and recommends the task's own research/plan phase do it. The mechanism that
   makes that automatic already exists — `scripts/plan-file-scope-harvest.sh` harvests
   `file_scope` from a plan's `Files to modify` lines at plan postflight — so the hand-off
   states the obligation against 696's *plan* phase rather than against 698.

### Prior Plan Reference

No prior plan. This is round 1 for task 700.

### Roadmap Alignment

Not consulted. The dispatch context (`.dispatch/10.md`) supplies no `roadmap_path` and no
roadmap flag, so per this agent's contract the roadmap stage is skipped. `specs/ROADMAP.md`
exists; this plan neither reads it as an input nor writes to it.

## Goals & Non-Goals

**Goals**:
- Resolve the report's three provisional edges (E2, E5, E8) in writing, against the sibling
  reports that have since landed, and record whether any edge strength changes.
- Correct the one unconfirmed fully-qualified declaration name in the cross-repository
  hand-off list, and confirm the other four against the live tree.
- Create exactly two new task entries with justified dependencies and narrow `file_scope`
  declarations, ordered so the preventions land last.
- Leave a durable, self-contained cross-repository hand-off note naming every result by
  fully-qualified declaration name, including which three paired-repository tasks are
  unblocked *now* and should not wait.
- Carry the "soundness is not in question" sentence into every artifact this plan writes, so
  no reader mistakes a completeness gap for unsoundness.

**Non-Goals**:
- Any Lean edit. This task writes no `.lean` file and requires no `lake build`.
- Editing task 695's, 696's, 698's, 699's or 701's entries, descriptions, `file_scope` arrays
  or artifacts. The F7 table and the extension-point suggestion are handed off by note, never
  applied across a territory boundary.
- Editing anything under `/home/benjamin/Projects/ModelChecker`, including its `specs/`.
- Proposing a third task. In particular: no task for the general finite-premise consequence
  form (parallel, and the Formula side is the cheaper place to open it), and no task for
  dropping `trans_refl` — task 699 already proposes that one and owns it.
- Re-stating task 696's reports or `PlusWitnessFamily/Incompleteness.lean`. Citation by
  fully-qualified declaration name only.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `specs/state.json` is task 698's declared territory and several siblings are in flight on the same tree; a read-modify-write `jq` rewrite loses a concurrent writer's change | H | M | Bracket every state write with `task-lock.sh scope-acquire`/`scope-release`; re-read the file immediately before the write inside the mutex; additive `+=` append only, never a wholesale `.active_projects = [...]` assignment; stage and commit `specs/state.json` and `specs/TODO.md` as an explicit two-path list |
| `next_project_number` (703 at plan time) is consumed by another session first, so the created entries collide or renumber | H | L | Read `next_project_number` inside the mutex at write time and use whatever it gives; never hard-code 703/704. Every cross-reference in the notes is written *after* the numbers are allocated |
| Component 7 of the multi-task-creation standard requires interactive confirmation, which cannot surface from a background dispatch | M | H | Documented decision: the task description itself pre-authorizes creation ("Spawn at most what the survey concludes is needed, in the order it concludes"), `/orchestrate` runs without confirmation gates, and `/errors` is the standing precedent for non-interactive creation. The confirmation *content* (summary table, auto-derived-edge annotation) is still produced, in the notes artifact and the final report, so the user can audit and override |
| The edge re-check turns up a finding that invalidates a proposal | M | L | Phase 1 runs *before* creation and is allowed to change the proposals' dependencies or descriptions. If it ever concluded a proposal should not exist, the correct outcome is to create fewer than two and say so — not to create two and note a caveat |
| 699's `trans_refl` follow-on task does not exist yet, so the new compression task cannot depend on it by number | M | H | Phrase the dependency in the compression task's description against the substrate *as finally corrected*, and record in the hand-off note that the edge should be added by number once 699's follow-on is filed. No placeholder or invented task number |
| A reader mistakes a completeness gap for unsoundness | M | M | The standing sentence goes into both new task descriptions and both notes files, as the report's own mitigation requires |
| Over-declaring `file_scope` for the new compression task manufactures false collisions | L | M | Declare the new `Compression/` subtree (genuinely created wholesale by that task, so a directory entry is warranted) plus the four concrete files the report names, and nothing broader |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 1, 2 |
| 4 | 4 | 1, 2, 3 |

Phases within the same wave can execute in parallel; here the chain is strictly serial because
Phase 2 may be adjusted by Phase 1's findings and Phase 3 cites the numbers Phase 2 allocates.

---

### Phase 1: Resolve the provisional edges and confirm declaration names [COMPLETED]

**Goal**: Turn the report's three provisional edges and its one unconfirmed declaration name
into resolved, written facts, and confirm that exactly two task entries are still the right
number, before anything is created.

**Tasks**:
- [x] Read the Decisions and Findings sections of
      `specs/699_invariance_clause_audit_and_ockhamist_grounding/reports/01_invariance-clause-audit-ockhamist-grounding.md`
      and record, for E2 (699 Part A → 696): whether Part A's verdict makes the gate HARD
      rather than SOFT, and whether its own proposed follow-on task (drop `trans_refl`,
      re-base the constant thread) subsumes anything the survey assigned elsewhere.
      *(completed: E2 strengthens SOFT -> HARD; follow-on proposal subsumes nothing else)*
- [x] From the same report, record for E8 (699 Part B → the new compression task): Part B's
      verdict on obligation O4, and its `Liftable` ↔ Emerson–Halpern R-generability
      identification plus the Reynolds 2003 / Thomason 1984 finite-axiomatizability bound.
      State explicitly whether any of it predicts unreachability (the survey's judgement was
      "reachable, not provably blocked"); if it does, say so plainly rather than sequencing
      toward an unreachable target.
      *(completed: 699 Part B does not address O4 as posed (no GKWZ/product-logic content);
      O4 stays open for entry A's own research round; nothing predicts unreachability)*
- [x] Read `specs/695_plus_carrier_normalization_int_transfer/reports/01_plus-carrier-normalization-transfer.md`
      and record for E1/E5: that `plusValidZTime_iff_plusValidInt` is proved in
      `specs/695_plus_carrier_normalization_int_transfer/probes/01_plus_int_transfer_probe.lean`
      under `namespace FormalSystem.PlusLanguage`, and that its recommended siting is a new
      module `FormalSystem/PlusLanguage/PlusIntTransfer.lean`. Correct the hand-off list's
      item 1 to `FormalSystem.PlusLanguage.plusValidZTime_iff_plusValidInt`.
      *(completed: 695 has landed; declaration confirmed live in
      FormalSystem/PlusLanguage/PlusIntTransfer.lean; hand-off item 1 corrected)*
- [x] Confirm the other four hand-off declaration names against the live tree with `grep`
      (`SharingSkeleton.total_eq_thread`, `PlusSharingWitnessFamily.PlusLocalCoherentShare`,
      `...StabFaithful`, `...plusTruth_iff_mem`, `...plusRefutes_of_certifies`). Record any
      that do not resolve.
      *(completed: all four resolve live)*
- [x] Read `specs/698_file_scope_declaration_hygiene/reports/01_file-scope-hygiene-audit.md`
      far enough to confirm it does not widen 696's `file_scope`, and record that the F7
      nine-file table's consumer is therefore 696's plan phase via
      `scripts/plan-file-scope-harvest.sh`, not task 698.
      *(completed: 698 confirmed it declines to widen 696's file_scope)*
- [x] Sweep `specs/state.json` for any non-terminal task already covering either proposal
      (`jq` over `project_name` and `description` for `Compression`, `non_vacuity`,
      `shape_gate`, `check-module-invariants`), so the "propose nothing where covered"
      constraint is checked against the live tree and not only against the survey.
      *(completed: no existing task covers either proposal; 412 and 559 confirmed unrelated)*
- [x] Write the findings to `specs/700_lplus_completeness_programme_survey/notes/01_sequence-addendum.md`:
      a dated addendum, one short section per edge, the corrected declaration name, the F7
      consumer correction, the duplicate-check result, and the "soundness is not in question"
      sentence. Cite by declaration name and report path; do not restate 696's reports or
      `Incompleteness.lean`.

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: prose

**Scope Hypothesis**: The hypothesis is that exactly three edges (E2, E5, E8) and exactly one
declaration name need correction, that the duplicate sweep finds nothing, and that two task
entries remain the right number. Confirm by the reads above before creating anything; if the
sweep finds an existing owner for either proposal, drop that proposal and say so in the
addendum rather than creating it.

**Files to modify**:
- `specs/700_lplus_completeness_programme_survey/notes/01_sequence-addendum.md` - new; the
  dated edge re-check, corrected declaration name, F7 consumer correction, duplicate-check
  result

**Verification**:
- The addendum exists, is non-empty, and has one explicit verdict line per provisional edge
  (E2, E5, E8) stating whether its strength changed.
- `grep -c 'FormalSystem.Semantics.plusValidZTime_iff_plusValidInt'` over the addendum is 0
  except where it is explicitly marked as the superseded name.
- `grep` confirms the four other hand-off declaration names resolve in
  `FormalSystem/**/*.lean`, and the addendum records any that do not.
- The addendum carries the soundness sentence.

---

### Phase 2: Create the two task entries [NOT STARTED]

**Goal**: Add exactly the two justified task entries to `specs/state.json` under the scope
mutex, in topological order, with narrow `file_scope` declarations and the serializing
dependency the shared-gate overlap requires, and regenerate `specs/TODO.md`.

**Tasks**:
- [ ] Acquire the global state mutex:
      `token=$(bash .claude/scripts/task-lock.sh scope-acquire "$session_id")`. Hold it across
      the whole write, and release it in all exit paths.
- [ ] Inside the mutex, re-read `specs/state.json` and take `next_project_number` as the first
      new number; never a value cached from plan time.
- [ ] Compose entry A, `lplus_compression_and_completeness`, `task_type: lean4`,
      `topic: decidability`, `dependencies: [695, 696]`. Description must state: the target as
      the L⁺ twin of `FormalSystem.Metalogic.Decidability.exists_witnessFamily_of_not_validZTime`;
      that `FormalSystem.Metalogic.Decidability.PlusSharingWitnessFamily.plusTruth_iff_mem` and
      `...plusRefutes_of_certifies` are untouched and soundness is not in question; zero
      sorries, no new axioms, a `docs/theorem-index.md` row and a C2 axiom pin as acceptance;
      RESEARCH-FIRST with O1 (is `Liftable` decidable, and by what argument), O2 (constructing
      a liftable arrival-pruned `trans` from an arbitrary countermodel — the general case, not
      the constant-thread case) and O3 ((C5)'s time-indexed witness demand and the resulting
      lasso-count bound, which may not be `|closure| + 1`) as named research questions; that
      `WitnessFamily/Compression/Family.lean:165` (`rw [validZTime_iff_validInt]`) is why the
      carrier normalization is a hard prerequisite; that it must read 699 Part B's verdict on
      O4 before its plan is written; and that its substrate dependency is on the substrate *as
      finally corrected*, including 699's `trans_refl` follow-on once that task is filed.
- [ ] Declare entry A's `file_scope`:
      `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Compression/` (a subtree this
      task creates wholesale, so a directory entry is warranted rather than a hedge),
      `FormalSystem/Metalogic/Decidability/PlusWitnessFamily.lean`, `FormalSystem.lean`,
      `docs/theorem-index.md`, `scripts/check-module-invariants.sh`.
- [ ] Compose entry B, `certificate_non_vacuity_and_shape_gates`, `task_type: general`,
      `topic: verification`, `dependencies: [696, <entry A's number>]`. The edge onto entry A
      is auto-derived from file-footprint overlap (both write
      `scripts/check-module-invariants.sh` and the C2 `AXIOM_BASELINE` block) and must be
      annotated as such in the summary table, per the multi-task-creation standard's
      Component 4a/7. Description must state both preventions as one task — (a) a standing
      obligation that every certificate-shaped condition set exhibit a NON-TRIVIAL inhabitant
      as a checked artifact, with 696's `famA_tCertifies`/`famB_tCertifies` as the first
      instances, and (b) a mechanical check against the collapsing clause shape, whose
      specification is 699 Part A's audit table and its `clause_shape_collapse` abstract lemma
      — and must state why it is sequenced last (a gate landed earlier goes red on the very
      refactor it protects, and a shape check written against pre-repair clauses encodes the
      defect as its baseline). `file_scope`: `scripts/check-module-invariants.sh`.
- [ ] Append both entries additively (`jq '.active_projects += [...]'` into a temp file, then
      atomic `mv`), set `next_project_number` past both, and set `created`/`last_updated` to
      the current UTC timestamp. Never assign `.active_projects` wholesale.
- [ ] Run `bash .claude/scripts/generate-todo.sh`, then release the mutex.
- [ ] Commit `specs/state.json` and `specs/TODO.md` as an explicit two-path list via
      `.claude/scripts/git-commit-scoped.sh` (no `git add -A`, no directory pathspec).

**Timing**: 1 hour

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: The hypothesis is exactly two new entries taking the next two numbers
(703 and 704 as of plan time, with `next_project_number` = 703). Confirm inside the mutex by
re-reading `next_project_number`; if a sibling session has advanced it, use the live values and
update every cross-reference in Phase 3 accordingly.

**Files to modify**:
- `specs/state.json` - append exactly two `active_projects` entries; advance
  `next_project_number`
- `specs/TODO.md` - regenerated by `generate-todo.sh`, never hand-edited

**Verification**:
- `bash .claude/scripts/validate-state.sh` exits 0 (WARN lines on pre-existing coarse
  declarations elsewhere are acceptable; a WARN naming either new entry is not).
- `jq '.active_projects | length'` increased by exactly 2, and
  `jq '[.active_projects[] | select(.project_number >= <first new number>)] | length'` is 2.
- Both entries' `dependencies` resolve to existing `project_number` values; no self-reference;
  no cycle (entry B → entry A → {695, 696} is acyclic by construction).
- `git diff --staged` shows changes confined to `specs/state.json` and `specs/TODO.md`, with no
  modification to any other task's entry fields.
- `specs/TODO.md` renders both new entries with `[NOT STARTED]` and correct dependency lines.

---

### Phase 3: Write the cross-repository hand-off note [NOT STARTED]

**Goal**: Leave one self-contained note that a reader in either repository can act on, naming
every must-land result by fully-qualified declaration name, so the hand-off survives task
renumbering on either side.

**Tasks**:
- [ ] Create `specs/700_lplus_completeness_programme_survey/notes/02_cross-repo-handoff.md`
      opening with the soundness sentence: every gap named is a completeness-side gap, the
      certificate class is empty on a fragment and never unsound on it.
- [ ] Record the five must-land results by fully-qualified declaration name, with the
      Phase 1 correction applied:
      `FormalSystem.PlusLanguage.plusValidZTime_iff_plusValidInt` (task 695);
      `FormalSystem.Metalogic.Decidability.SharingSkeleton.total_eq_thread` (landed; to be
      re-proved in its `trans`-relative form by 696);
      the redesigned
      `FormalSystem.Metalogic.Decidability.PlusSharingWitnessFamily.PlusLocalCoherentShare`
      and `...StabFaithful` (696);
      `...plusTruth_iff_mem` and `...plusRefutes_of_certifies` (landed; must survive 696 with
      statements unchanged);
      and the L⁺ compression theorem plus its bound (the new compression task) — mapped onto
      the paired repository's four stated needs for `extend_bimodal_to_stability_modal`.
- [ ] State plainly that `apply_upstream_adequacy_chain_rows`,
      `rescope_blocked_adequacy_consumers` and `bimodal_theory_limits_example_group` in the
      paired repository need nothing further from here and should not wait, and that
      `a3_compute_bounds_from_closure` is orthogonal (it needs a minimal-period result the
      landed theorem does not supply).
- [ ] Carry the O3 warning forward explicitly: the L⁺ lasso-count bound may not be
      `|closure| + 1`, so the paired repository's search-bound expectations must not be set
      from the Formula side's figure.
- [ ] Record the two hand-offs that are notes rather than edits, each with its mechanism:
      (a) the F7 nine-file table belongs in task 696's plan's `Files to modify` lines, where
      `scripts/plan-file-scope-harvest.sh` harvests it into `file_scope` at plan postflight;
      (b) task 695's plan should name the consequence-form (`Γ ≠ []`) analogue as an extension
      point, since `WitnessFamily/Compression/Assembly.lean:66` identifies it as one of three
      `Γ = []`-specific residue items. State that neither is applied here, and why.
- [ ] Record the serialization rule as a standing operational note: never dispatch two of
      {695, 696, the new compression task, the new gates task} implementing in the same cycle,
      because `scripts/check-module-invariants.sh` (C2 `AXIOM_BASELINE`) and
      `docs/theorem-index.md` are shared, block-rewritten artifacts.
- [ ] Include the Component 7 confirmation summary table for the two created entries — number,
      title, task type, dependencies, with the entry-B→entry-A edge annotated
      `(auto: file overlap)` — so the non-interactive creation remains auditable.
- [ ] Commit the two notes files scoped to this task's directory.

**Timing**: 1 hour

**Depends on**: 1, 2

**Verification Tier**: prose

**Scope Hypothesis**: The hypothesis is a five-item must-land list and a three-item
already-satisfied list, exactly as the report's cross-repository section states, with one
declaration name corrected. Confirm against Phase 1's addendum before writing; if Phase 1
found a name that does not resolve, the list changes and the note says so.

**Files to modify**:
- `specs/700_lplus_completeness_programme_survey/notes/02_cross-repo-handoff.md` - new; the
  hand-off by fully-qualified declaration name, the three unblocked paired tasks, the O3
  warning, the two note-only hand-offs, the serialization rule, the confirmation table

**Verification**:
- Every must-land item in the note is a fully-qualified declaration name, not a task number
  alone; `grep -c '^\s*[0-9]\.' ` over that section yields five items.
- No path under `/home/benjamin/Projects/ModelChecker` was written:
  `git -C /home/benjamin/Projects/ModelChecker status --porcelain` shows nothing this task
  introduced.
- The note carries the soundness sentence and the `(auto: file overlap)` annotation.

---

### Phase 4: Final gates and territory audit [NOT STARTED]

**Goal**: Confirm the task's constraints held — nothing outside its own territory changed, no
Lean was touched, no third task appeared — and leave the state consistent.

**Tasks**:
- [ ] `bash .claude/scripts/validate-state.sh` — green, with no WARN naming either new entry.
- [ ] `bash .claude/scripts/check-task-references.sh` — confirm no task-number reference leaked
      outside `specs/**` (all of this task's writes are under `specs/**`, so this should be a
      no-op, and a hit means something landed in the wrong place).
- [ ] `git status --short` and `git log --oneline -5`: confirm this task's commits touch only
      `specs/state.json`, `specs/TODO.md` and
      `specs/700_lplus_completeness_programme_survey/**`. Confirm no `.lean` file and no file
      under `FormalSystem/`, `docs/` or `scripts/` was modified by this task.
- [ ] Confirm the created-entry count is exactly two and that no entry of any other task was
      modified: `git diff <pre-phase-2 sha> -- specs/state.json` touches only the two appended
      entries, `next_project_number`, and this task's own status/artifact bookkeeping.
- [ ] If a foreign uncommitted modification or a foreign commit is observed on
      `specs/state.json` (task 698 is a concurrent sibling declaring exactly that file), STOP
      and report it after checking `git log` to confirm the work is not this task's own, per
      the dispatch's concurrency note — do not proceed and do not dismiss it as noise.

**Timing**: 0.5 hours

**Depends on**: 1, 2, 3

**Verification Tier**: local

**Scope Hypothesis**: The hypothesis is that this task's entire footprint is four files
(`specs/state.json`, `specs/TODO.md`, and the two notes files) plus postflight's own artifact
bookkeeping, and that no `lake build` is owed because zero Lean files are touched. Confirm from
`git diff --stat` across this task's commits rather than by assertion.

**Files to modify**:
- none planned; this phase is verification only

**Verification**:
- `validate-state.sh` exits 0; `check-task-references.sh` reports no violation.
- `git diff --stat` across this task's commits lists only the four files named above.
- `git -C /home/benjamin/Projects/ModelChecker status --porcelain` shows no change from here.
- No `.lean` file appears in this task's diff, and the task's summary states that no build
  gate was owed and why.

## Testing & Validation

- [ ] `bash .claude/scripts/validate-state.sh` exits 0 after Phase 2 and again after Phase 4.
- [ ] `jq -e '.active_projects | map(.project_number) | (. | unique | length) == length'
      specs/state.json` — no duplicate task numbers.
- [ ] `jq -e '[.active_projects[] | select(.dependencies != null) | .dependencies[]] - [.active_projects[].project_number] | length == 0'`
      or equivalent — every dependency of a new entry resolves (archived numbers, if any,
      must be checked against `specs/archive/` before being called dangling).
- [ ] `specs/TODO.md` is generated, not hand-edited: re-running `generate-todo.sh` produces no
      further diff.
- [ ] Both notes files exist, are non-empty, and each carries the soundness sentence.
- [ ] No `.lean` file, and no file under `FormalSystem/`, `docs/`, `scripts/` or
      `/home/benjamin/Projects/ModelChecker`, appears in this task's diff.
- [ ] Exactly two new task entries — not one, not three.

## Artifacts & Outputs

- `specs/700_lplus_completeness_programme_survey/notes/01_sequence-addendum.md` — the resolved
  edge re-check (E2, E5, E8), the corrected declaration name, the F7 consumer correction, the
  duplicate-check result.
- `specs/700_lplus_completeness_programme_survey/notes/02_cross-repo-handoff.md` — the
  cross-repository coordination point by fully-qualified declaration name, the three
  paired-repository tasks that are unblocked now, the O3 bound warning, the two note-only
  hand-offs, the serialization rule, and the creation confirmation table.
- `specs/state.json` — two appended `active_projects` entries
  (`lplus_compression_and_completeness`, `certificate_non_vacuity_and_shape_gates`) and an
  advanced `next_project_number`.
- `specs/TODO.md` — regenerated.
- `specs/700_lplus_completeness_programme_survey/summaries/01_*-summary.md` — written at
  implementation postflight; must restate the two created numbers, the resolved edges, and the
  hand-off's location.

## Rollback/Contingency

Every write is confined to `specs/**` and every phase commits separately, so rollback is a
per-commit revert rather than a working-tree discard:

- **Phase 2 (state entries) went wrong**: `git revert` that single scoped commit, then re-run
  `bash .claude/scripts/generate-todo.sh` to bring `specs/TODO.md` back in step. Do not
  hand-edit `specs/TODO.md`.
- **Phase 1 or 3 (notes files) went wrong**: the files are additive and new; delete or rewrite
  them and re-commit. Nothing else depends on their content within this task.
- **A concurrent writer clobbered `specs/state.json`**: STOP rather than reconstructing by
  hand. Report the observation with the `git log` evidence; the mutex exists to prevent this
  and a loss means the mutex was not held.
- **A genuine working-tree rollback is needed** (not expected here, since no Lean is touched):
  take a durable, non-reverting checkpoint first with
  `bash .claude/scripts/git-snapshot.sh 700 --no-revert`; only an actual rollback scenario uses
  the reverting default mode, and then per `context/contracts/recovery.md`'s rollback rung,
  including its out-of-scope override flag for the deliberate whole-tree case.
