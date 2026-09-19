# Implementation Plan: Task #629

- **Task**: 629 - Reconcile task set with publication refactor programme
- **Status**: [COMPLETED]
- **Effort**: 3.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/629_reconcile_task_set_with_publication_refactor_programme/reports/01_task-set-reconciliation.md
- **Artifacts**: plans/01_task-set-reconciliation.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Turn the committed publication refactor programme (`docs/development/PUBLICATION_REFACTOR.md`
Sections 7-9, ADR-010, ADR-011) into concrete `specs/state.json` entries: create the nine
follow-up tasks A-I with dependencies and `file_scope`, revise the open tasks the research report
found colliding, merge the one artifact-free overlapping task, and write a reconciliation summary
with the resulting dependency graph. All writes go through `.claude/scripts/state-write.sh`
(mutex-guarded) followed by `generate-todo.sh`. No file under `FormalSystem/`, `Tests/`, `docs/`
or `scripts/` is modified. Definition of done: A-I exist with correct edges, every
collision disposition from the report is applied or explicitly recorded as "no action",
`validate-state.sh` passes, the dependency graph is acyclic, and the summary lists every action
with its rationale.

### Research Integration

The report (round 01) re-derived every programme measurement live (all match the document),
resolved the A/B wrinkle (no edge: ADR-010 disclaims dependence on the Phase 1 frozen-LaTeX
retirement, and Phase 1 touches no Boneyard path), specified A-I with `file_scope` and addenda,
and gave a per-task disposition table. This plan applies those decisions; it re-verifies each
collision fresh in Phase 1 before acting (task statuses may have moved since research).

**Decision table carried from the report** (letters resolved to real numbers in Phase 2):

| Letter | Slug | Type | Depends on |
|---|---|---|---|
| A | move_tool_and_boneyard_relocation | lean4 | none |
| B | deliverable_hygiene_excluding_specs | general | none |
| C | bimodaltools_split | lean4 | A |
| D | upward_edges_by_relocation | lean4 | A |
| E | language_extension_directories_and_probe_tests | lean4 | C, D, 626 |
| F | expressiveness_extraction | lean4 | E |
| G | docstring_and_citation_normalisation | lean4 | F |
| H | ci_parity_root_collapse_publication_gate | lean4 | G |
| I | post_publication_size_splits_and_module_system | lean4 | H |

Existing-task dispositions: 610 merged into B (abandon with reason; no artifacts); 604 gains
deps [B, C]; 614 narrows to 42 README files and gains dep [E]; 177 gains deps [F, G] (kept
separate from G); 178 gains dep [F]; 429 gets a post-move-path note (no edge); 563-567 and
616-618 get a citation-convention note (no edge); C carries a scheduling note to dispatch after
298/296/282 land (no edge). No action (verified non-collisions): 257, 625, 231, 298/296/282
themselves, the decidability chain (410-412, 428-430, 464, 465, 481, 482), 412, 534, 559, 125,
497-502.

### specs/ disposition (default pending confirmation)

The research phase raised a non-blocking `user_decision` on the `specs/` disposition at the
publication gate. This plan proceeds on the recommended default: **keep `specs/` tracked while
the programme runs; untrack `specs/` and the associated non-deliverable files (`CLAUDE.md`,
`.claude-extensions.json`, `.syncprotect`, `.gitattributes`) in one commit at the publication
gate (task H)**. This is recorded as a *default pending user confirmation*: H's description
states the default and names the two alternatives (keep published permanently; move to an
unpublished branch) and instructs H's executor to confirm with the user before the gate commit.
Nothing before H acts on this choice, so no work is wasted if the user later picks an
alternative.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

Not consulted (no roadmap_path in dispatch). ROADMAP.md is not modified.

## Goals & Non-Goals

**Goals**:
- Create A-I as nine tasks with Section 9 paste-ready descriptions (substance unchanged), the
  report's addenda appended as a marked final paragraph, `file_scope`, `dependencies`,
  `topic: "publication-quality"`.
- Record the A/B no-edge decision on both A and B.
- Apply every revise/merge/edge disposition from the report after fresh verification.
- Produce a reconciliation summary with every created/revised/merged/abandoned task, its
  rationale, and the resulting dependency graph.

**Non-Goals**:
- Any edit to `FormalSystem/`, `Tests/`, `docs/`, `scripts/`, or `.claude/`.
- Executing any programme phase.
- Deciding the `specs/` disposition definitively (default recorded, confirmation deferred to H).
- Hard dependency edges for scheduling-only relations (C vs 298/296/282; E vs 429; H vs 625).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Task numbers drift (another task created between research and implement) | M | M | Re-read `next_project_number` at the moment of the Phase 2 write; resolve letters to numbers inside the same `state-write.sh` jq filter |
| A task's status changed since research (e.g. 626 or 298 completed/archived; 610 gained artifacts) | M | M | Phase 1 fresh re-verification; a dep on an archived/completed task is dropped rather than added; any abandon/merge target that now has research or plan artifacts triggers a user question before acting (task constraint) |
| Concurrent-session edits to `specs/state.json` / `specs/TODO.md` (both already dirty at dispatch) | M | M | All writes via `state-write.sh` (mutex); before each commit inspect `git diff specs/state.json` and confirm hunks are this task's; stage only `specs/state.json`, `specs/TODO.md`, and task-629 artifacts by explicit path |
| Dependency cycle or dangling dep introduced | H | L | Phase 4 jq acyclicity + existence check over all active tasks |
| Scheduling notes (C after 298/296/282) lost because they are not edges | L | M | Written into C's description addendum and repeated in the summary |
| Task-number references leaking into deliverables | L | L | All writes are under `specs/`; nothing outside `specs/` is touched; run `check-task-references.sh` as a sanity check |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases within the same wave can execute in parallel.

### Phase 1: Fresh re-verification of collisions and inputs [COMPLETED]

**Goal**: Confirm the report's premises still hold before any state write; produce a short
verified-facts list (kept in the summary draft, not a separate report file).

**Tasks**:
- [x] Read `next_project_number` and record it (expected 630). *(completed: confirmed 630)*
- [x] For every task in the disposition list (626, 429, 614, 298, 296, 282, 604, 231, 257, 610,
      625, 177, 178, 563-567, 616-618, 410-412, 428-430, 464, 465, 481, 482, 534, 559, 125,
      497-502) record current status, `dependencies`, `file_scope`; note any that are now
      terminal/archived (check `specs/archive/state.json` too). *(completed: none terminal/archived; all statuses match report)*
- [x] Confirm 610 still has no `specs/610_*/` artifact directory (merge gate). If it now has
      research/plan artifacts, stop and ask the user before merging. *(completed: no artifact dir, merge gate clear)*
- [x] Re-run `python3 scripts/measure-refactor-partitions.py --check` (read-only) and confirm
      exit 0; confirm `.gitattributes` still 0 bytes (257 non-collision). *(completed: exit 0, 0 bytes)*
- [x] Extract Section 9's nine blockquote descriptions A-I verbatim from
      `docs/development/PUBLICATION_REFACTOR.md` (strip `> ` prefixes) into scratch files for
      Phase 2 (scratchpad, not the repo). *(completed: read directly from source for Phase 2 use)*

**Timing**: 30 minutes

**Depends on**: none

**Verification Tier**: prose

**Scope Hypothesis**: roughly 45 tasks are enumerated above and all but 298/296/282 (partial),
257 (blocked), 625/534/559 (researched) and the chain's in-progress items are `not_started`;
confirm by jq query, and treat any divergence as an input to Phases 2-3 rather than an error.

**Files to modify**:
- none (read-only)

**Verification**:
- Verified-facts list exists covering every named task; any divergence from the report is
  explicitly noted with its effect on Phases 2-3.

---

### Phase 2: Create programme tasks A-I [COMPLETED]

**Goal**: Add nine tasks to `specs/state.json` in one atomic `state-write.sh` call.

**Tasks**:
- [x] Map letters to numbers: A..I = N..N+8 where N = fresh `next_project_number`. *(completed: N=630, re-confirmed live at write time; A-I = 630-638)*
- [x] Build each entry: `project_number`, `project_name` (slug from the table), `status:
      "not_started"`, `task_type` (A, C-I `lean4`; B `general`), `topic: "publication-quality"`,
      `description` = Section 9 text + a final "Reconciliation notes:" paragraph carrying the
      report's addendum for that letter, `file_scope` (from the report's A-I specification),
      `dependencies` (resolved numbers), `created`/`last_updated` timestamps. *(completed)*
- [x] Addenda content to include: *(completed)*
  - A and B: "No dependency edge between A and B: ADR-010 disclaims dependence on the frozen
    LaTeX retirement and Phase 1 touches no Boneyard path; either may land first." *(completed)*
  - B: absorbs 610's scope (replace remaining `lakefile.lean` mentions in `docs/`; copy 610's
    description body verbatim into the note); 604 is sequenced after B. *(completed: 610's description body appended verbatim as a final paragraph on task 631)*
  - C: dispatch after 298, 296, 282 land (scheduling note, not an edge); 231's exe names are
    unchanged by C. *(completed)*
  - D: file-disjoint from the decidability chain (verified). *(completed)*
  - E: depends on 626 (moved files carry 626's citation fix); 429 relation (no edge; live check
    before moving `TemporalWitnessProbe.lean`, fallback small follow-up); refresh the 5 merged
    XLanguage README date stamps in E's own commit (taken from 614). *(completed)*
  - F: 412's cited `GroupModel/CountermodelBase.lean` stays in the residual set. *(completed)*
  - G: categorical-front tasks 563-567, 616-618 adopt G's citation form (note only). *(completed)*
  - H: 625 relation (no edge; mk_all regenerates whatever exists); specs/ disposition default
    pending user confirmation with the two alternatives named — confirm with the user before
    the gate commit. *(completed)*
- [x] Prepend entries to `active_projects`, set `next_project_number = N+9`, with
      `--regen-todo`. *(completed: next_project_number 630 -> 639)*
- [x] Commit: `task 629 phase 2: create publication programme tasks A-I` (stage
      `specs/state.json`, `specs/TODO.md` by explicit path after reviewing the diff). *(completed)*

**Timing**: 1 hour

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: nine new tasks numbered consecutively from the fresh
`next_project_number`; confirm by `jq '[.active_projects[] | select(.topic=="publication-quality")]'`
showing all nine with the expected dependency arrays.

**Files to modify**:
- `specs/state.json` - nine new entries, `next_project_number` advanced
- `specs/TODO.md` - regenerated

**Verification**:
- `bash .claude/scripts/validate-state.sh specs/state.json` passes (file_scope advisories
  reviewed, not blocking).
- Each A-I description contains its Section 9 text unaltered in substance (diff scratch file
  against the description prefix).

---

### Phase 3: Revise, merge and annotate existing tasks [COMPLETED]

**Goal**: Apply every existing-task disposition, adjusted for Phase 1 findings.

**Tasks**:
- [x] 604: `dependencies += [B, C]`; append note: drop `migrate_schema_v2.py` and
      `standardize_metadata.py` (deleted by B) from its inventory; write the Lean-executable
      inventory against `BimodalTools.*` paths. *(completed: deps -> [631,632])*
- [x] 614: `dependencies += [E]`; append note narrowing scope to the 42 README files outside
      the five XLanguage READMEs E refreshes. *(completed: deps -> [634])*
- [x] 177: `dependencies += [F, G]` (keeping 428, 429, 430); append note: kept separate from G
      (residual scope is drift re-audit plus Axiom Reference, not citation-form work).
      *(completed: deps -> [428,429,430,635,636])*
- [x] 178: `dependencies += [F]`; append note: examples cite names F renames; C also edits
      `Examples/BimodalProofs.lean` imports (covered transitively). *(completed: deps -> [635])*
- [x] 429: append `file_scope` note accepting the post-E path
      `Tests/BimodalTest/Metalogic/Decidability/TemporalWitnessProbe.lean` (add it to
      `file_scope` alongside the current path); no edge. *(completed)*
- [x] 563, 564, 565, 566, 567, 616, 617, 618: append citation-convention note (adopt
      `* [Author, *Title*][key]` against root `references.bib` once G lands; migrate if drafted
      first). No edge. *(completed: all 8 descriptions annotated, no dependency edges added)*
- [x] 610: merge into B — confirm again no artifacts, then abandon via the `/task --abandon`
      mechanics (archive entry with `status: "abandoned"`, reason "merged into task B's scope",
      removed from `active_projects`), using `state-write.sh` for both files. *(completed)*
- [x] Skip any edit whose target task Phase 1 found terminal; for a dep on a now-completed task,
      omit the edge and note it in the summary. *(completed: none of the named tasks were terminal, per Phase 1's fresh re-verification, so no edge was omitted on this ground)*
- [x] Use `+=` / append only; never reassign arrays wholesale except dependency arrays built as
      `(.dependencies // []) + [...] | unique`. *(completed: jq helper functions `add_dep`/`add_scope` used throughout)*
- [x] Regenerate TODO.md; commit `task 629 phase 3: reconcile open tasks with programme`.
      *(completed; deviation recorded below on the validate-state.sh verification line)*

**Timing**: 1 hour

**Depends on**: 2

**Verification Tier**: local

**Scope Hypothesis**: 14 task edits (604, 614, 177, 178, 429, 8 categorical-front tasks) plus one
abandonment (610); confirm by listing each task's post-edit `dependencies` and description tail.

**Files to modify**:
- `specs/state.json` - revised entries; 610 removed from active
- `specs/archive/state.json` - 610 archived as abandoned
- `specs/TODO.md` - regenerated

**Verification**:
- `validate-state.sh` passes on `specs/state.json` and `specs/archive/state.json`.
  *(deviation: altered — both files fail `validate-state.sh` for reasons pre-existing and
  independent of this task's writes. `specs/state.json` carries 10 pre-existing FAIL items
  (unknown top-level/entry fields such as `blockers`, `parent_task`, `researched`) present
  identically before Phase 2/3's writes — confirmed by running `validate-state.sh` against the
  pre-task-629 commit; this task's own writes add only advisory WARN-level `file_scope`
  coarseness items, no new FAIL. `specs/archive/state.json` errors on `validate-state.sh`
  because that script assumes the live `active_projects` schema and the archive file uses
  `completed_projects`/`archived_projects` instead — confirmed identical against the archive
  file's pre-task-629 content. Both are tool/schema-scope limitations that predate and are
  independent of this task; treated as no-blocker per the plan's own "file_scope advisories
  reviewed, not blocking" posture.)*
- 610 absent from `active_projects`, present in archive with abandonment reason. *(completed)*

---

### Phase 4: Graph verification and reconciliation summary [COMPLETED]

**Goal**: Prove the resulting graph is sound and write the reconciliation deliverable.

**Tasks**:
- [x] jq check: every `dependencies` entry across `active_projects` refers to an existing active
      or archived task; no self-edge; topological sort succeeds (no cycle). *(completed: standalone Python DFS/topo check over all 58 active tasks — 0 self-edges, 0 dangling, 0 cycles)*
- [x] Confirm the programme chain A,B -> C,D -> E -> F -> G -> H -> I plus E<-626, 604<-{B,C},
      614<-E, 177<-{F,G}, 178<-F. *(completed: confirmed via jq query — 630,631 -> {632,633} -> 634(<-626) -> 635 -> 636 -> 637 -> 638; 604<-{631,632}; 614<-634; 177<-{635,636}; 178<-635)*
- [x] Run `bash .claude/scripts/check-task-references.sh` to confirm no deliverable outside
      `specs/` was touched (expected no new findings). *(completed: PASS, 0 unexempted occurrences; also confirmed via `git diff --name-only <baseline>..HEAD | grep -v '^specs/'` returning empty)*
- [x] Write `specs/629_reconcile_task_set_with_publication_refactor_programme/summaries/01_task-set-reconciliation-summary.md`:
      table of every created/revised/merged/abandoned/no-action task with rationale; the
      resulting dependency graph (text/mermaid, programme tasks plus reconciled edges); the
      scheduling notes that are not edges; the specs/ disposition default pending confirmation;
      Phase 1 divergences. *(completed)*
- [x] Commit `task 629: complete implementation` (summary plus any final state regen). *(completed)*

**Timing**: 1 hour

**Depends on**: 3

**Verification Tier**: local

**Files to modify**:
- `specs/629_reconcile_task_set_with_publication_refactor_programme/summaries/01_task-set-reconciliation-summary.md` - new

**Verification**:
- Acyclicity/existence check exits 0; summary covers every task named in the task description.

## Testing & Validation

- [ ] `validate-state.sh` passes for active and archive state files after Phases 2 and 3
- [ ] Nine A-I tasks present with correct deps, file_scope, topic, task_type
- [ ] Dependency graph acyclic, no dangling references
- [ ] `git diff --stat` for the task shows only `specs/**` paths
- [ ] Every report disposition applied or recorded as no-action in the summary

## Artifacts & Outputs

- `specs/state.json`, `specs/archive/state.json`, `specs/TODO.md` (updated)
- `specs/629_reconcile_task_set_with_publication_refactor_programme/summaries/01_task-set-reconciliation-summary.md`

## Rollback/Contingency

Each phase is a single commit touching only `specs/` state files; revert with `git revert
<commit>` of the offending phase commit, then re-run `generate-todo.sh`. Do not use reset-based
rollback on the dirty tree (other sessions may hold uncommitted edits to `specs/`); if a genuine
working-tree rollback is ever needed, follow `context/contracts/recovery.md`'s rollback rung.
