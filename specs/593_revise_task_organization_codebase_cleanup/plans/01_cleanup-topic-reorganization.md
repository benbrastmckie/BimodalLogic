# Implementation Plan: Task #593

- **Task**: 593 - Revise task organization codebase cleanup
- **Status**: [COMPLETED]
- **Effort**: 3 hours
- **Dependencies**: None
- **Research Inputs**: specs/593_revise_task_organization_codebase_cleanup/reports/01_cleanup-topic-reorganization.md
- **Artifacts**: plans/01_cleanup-topic-reorganization.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

This task edits task metadata only, not Lean sources. It gathers the 15 surviving
non-proof codebase-improvement tasks under a new `codebase-cleanup` topic, abandons 542 into
588, rescopes 583 and widens 586/590, creates four new tasks (N1-N4 in the research report),
applies the report's stale-graph fixes (its N5) directly, and rewires dependencies into the
report's six-wave DAG. Every `specs/state.json` write goes through
`.claude/scripts/state-write.sh`, the mutex-guarded writer. Other implement agents (579, 580)
are running at the same time, so no phase may hand-roll a `jq > tmp && mv` write. The task is
done when the topic holds 19 members, the DAG is acyclic and matches the table in Phase 5,
`TODO.md` has been regenerated, and `validate-state.sh` passes.

### Research Integration

The report covers all 60 active tasks, checks the key claims against the source tree, and
compares against cslib. This plan uses its membership table (Recommendation 1), its specs for
the new tasks (Recommendation 2), the rescope of 583 (Recommendation 3), and its dependency DAG
(Recommendation 4) unchanged, with two corrections found while planning:

- **481 and 428 are not stale-blocked.** Both carry substantive `blockers` text: 481 is
  blocked by a Phase 6 obstruction (`UniverseClosedAt` cannot be stated), and 428 is waiting on
  a human scope decision about its four residual hypotheses. Their completed dependency numbers
  should be pruned, but their `blocked` status must NOT change.
- **The 481 pointer.** `UnorderedSuccessorLabelClosed` is now defined in
  `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound/ClosureResidual.lean`,
  not `MintBound/SigmaFixed.lean` as the report says. The monolithic `MintBound.lean` still
  exists next to the `MintBound/` directory, so the implementer re-confirms the location before
  editing.

### Prior Decisions

- 569 (semantics retarget) joins `codebase-cleanup`, ordered after 584 and before
  588/540/589. This was settled in cycle 1 (`.decisions.json`), so do not ask again.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md consulted (no `roadmap_path` in the dispatch).

## Goals & Non-Goals

**Goals**:
- One topic `codebase-cleanup` with 19 members: 506, 540, 569, 578, 581, 582, 583, 584, 585,
  586, 587, 588, 589, 590, 591 and new N1-N4
- Abandon 542, carrying its attribute/simp-set reachability step into 588's description
- Rewrite the descriptions of 583 (narrowed to wiring the checks that pass today), 586 and 590
  (widened), and add final phases to 581, 582 and 584 in which each task wires its own check
  script into CI
- Create N1 (relocate in-library smoke tests), N2 (durable-records home), N3 (nest Semantics
  language-family files and add a ForMathlib README), and N4 (Mathlib standard linter set)
- Apply the report's N5 edits directly: remove completed task numbers from dependency lists
  and refresh 481's stale file pointer and `file_scope`
- Build an acyclic dependency DAG across the topic that matches the report's waves

**Non-Goals**:
- No Lean, docs, typst, or CI file is modified. All implementation belongs to the tasks this
  plan creates or rescopes.
- No status change for 428 or 481 (see Research Integration)
- No new N5 task (its edits are applied here instead)
- No edit to `.claude/**` (the topic-taxonomy context note the report recommends belongs in
  the source store and is out of scope)
- No Boneyard relocation task (ADR-005/009 settled this)
- Proof, research, dataset, literature, and agent-system tasks keep their current topics

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Concurrent state.json writers (impl-579, impl-580, meta-builder) clobber edits | H | M | Every write goes through `state-write.sh` (fail-closed mutex); read `next_project_number` inside the same write that creates each task; never touch the 579/580 entries |
| Research facts have drifted since research ran (a task completed, a new one appeared) | M | M | Phase 1 re-checks every member's status and dependencies and records any differences before editing |
| The new DAG contains a cycle or references a missing task | M | L | Phase 5 runs a jq topological check over the topic and fails before regenerating TODO.md |
| Pruning a dependency that is still live | M | L | Prune only numbers absent from `active_projects` at write time (in `completed_projects` or the archive); leave live ones |
| Abandon flow loses 542's content | L | L | Merge 542's step (1) into 588's description before abandoning; follow `/task --abandon` mode's archive write |
| Widened 586/590 descriptions grow past one agent run | M | M | Descriptions list the grep-bounded file sets and tell the future planner to split phases rather than truncate |
| No lean challenge block triggers snapshot tooling | L | L | `## Lean Challenge Statements` is deliberately omitted: Goals name no theorem identifiers, and a present section with zero ```` ```lean ```` blocks is a hard error for `lean-challenge-snapshot.sh` |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 4 | 1 |
| 3 | 3 | 2, 4 |
| 4 | 5 | 3 |

Phases in the same wave touch disjoint task entries and may run in parallel. Every write still
goes through the mutex.

### Phase 1: Re-verify the task graph snapshot [COMPLETED]

**Goal**: Confirm that the research's picture of the task graph still holds before anything
is written.

**Tasks**:
- [x] Save a pre-edit copy: `cp specs/state.json specs/593_revise_task_organization_codebase_cleanup/state.pre-593.json`
- [x] For each of 506, 540, 542, 569, 578, 581-591: record status, topic, dependencies. Stop
      and report if any is no longer `not_started`/active
- [x] Record the current `next_project_number` (594 at planning time; may have moved)
- [x] List every dependency number across `active_projects` that is not itself in
      `active_projects` (the report counts 36). This is the prune list for Phase 4 *(deviation: altered — 56 stale references across 27 tasks found at write time, all pointing at archived completed tasks; all pruned)*
- [x] Re-confirm the `UnorderedSuccessorLabelClosed` definition site (`grep -rn "def UnorderedSuccessorLabelClosed " FormalSystem/`)
- [x] Confirm `codebase-cleanup` is not already in `active_topics`

**Timing**: 0.25 hours

**Depends on**: none

**Verification Tier**: prose

**Scope Hypothesis**: 36 stale dependency references across active tasks, and 15 member tasks
all still `not_started`. Confirm with jq over `specs/state.json`. Any difference is recorded in
the summary and changes the counts used later.

**Files to modify**:
- `specs/593_revise_task_organization_codebase_cleanup/state.pre-593.json` - backup (new)

**Verification**:
- Backup exists. Membership, status, and prune list are recorded for the summary

---

### Phase 2: Create the topic, re-topic members, abandon 542 [COMPLETED]

**Goal**: Put all existing members under `codebase-cleanup` and merge 542 into 588.

**Tasks**:
- [x] `bash .claude/scripts/manage-topics.sh add codebase-cleanup --session-id $SID`
- [x] `manage-topics.sh set N codebase-cleanup` for 506, 540, 569, 578, 581, 582, 583, 584,
      585, 586, 587, 588, 589, 590, 591
- [x] Append to 588's description: a paragraph saying it absorbs the former dead-declaration
      triage task (989-count measurement). Carry over that task's step (1), which quantifies
      how many zero-occurrence declarations are reachable through attributes or simp sets.
      Note that the `release_unfold` reading is disputed: it is registered with
      `@[formula_unfold]`, but the only consumers of that simp set are the `#check`/`example`
      block in `Normalization.lean` and
      `Tests/BimodalTest/Automation/NormalizationTest.lean`. 588 must resolve this, not assume
      either reading
- [x] Abandon 542 following `.claude/commands/task.md`'s Abandon Mode (archive write through
      `state-write.sh --state-file`, removal from `active_projects`), with the reason "merged
      into 588" *(no `specs/542_*` directory existed, so no directory move was needed)*
- [x] Remove 542 from any other task's dependency list

**Timing**: 0.5 hours

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: 15 re-topics and 1 abandon. Confirm with
`jq '[.active_projects[]|select(.topic=="codebase-cleanup")]|length'` = 15 and 542 absent from
`active_projects`.

**Files to modify**:
- `specs/state.json` - topic fields, 588 description, 542 removal
- `specs/archive/state.json` - 542 archived as abandoned

**Verification**:
- Topic count is 15. 542 is archived with status `abandoned`. No active task depends on 542.
  `validate-state.sh` passes

---

### Phase 3: Rescope and widen existing descriptions [COMPLETED]

**Goal**: Change member task descriptions so each task's scope matches the report's
recommendations.

**Tasks**:
- [x] **583**: rewrite the scope to wire only the checks that pass today:
      `check-module-invariants.sh` (full, or `--no-build` after the lean-action build),
      `check-copyright-headers.sh --strict --exclude '*/Boneyard/*' FormalSystem`, and
      `readme-lint.sh`. Record the per-script wiring pattern: step naming, the skip-neutral
      convention for external inputs, and the runtime budget. State that repair tasks wire
      their own scripts and that 585's gate extends this workflow
- [x] **581**: add a final phase "wire `check-evidence-probes.sh` into CI following 583's pattern"
- [x] **582**: add a final phase "wire `check-metalogic-cycles.sh` into CI"
- [x] **584**: absorb the open naming-audit note at `MinusLanguage/Axioms.lean:76`. Add a final
      phase that wires `check-paper-definitions.sh` into CI, skip-neutral when the paper is
      absent, and point to N2 for where the definitions record lives
- [x] **586**: widen to all retired-tactic prose outside `docs/`:
      `FormalSystem/Automation/README.md` (:61, :114),
      `FormalSystem/Automation/ProofSearch/README.md:19`, and
      `typst/chapters/p4-dual-verification.typ:36`. Add a final phase that wires
      `typst-sync-check.sh`
- [x] **590**: widen to a staleness audit of `docs/`: retired-tactic mentions in the nine
      `docs/` files the report lists, the four `docs/research/leansearch-*.md` files,
      `docs/project-info/{implementation-status,performance-targets,test-coverage}.md`, the
      root `CLAUDE.md` title ("ProofChecker"), and flipping `ENFORCE_C9_DOCS=1`. Add a note
      telling the future planner to split rather than truncate
- [x] **589**: absorb the 3 broken `specs/` citations (`Syntax/BigConj.lean:30`,
      `.../NfMultiAnchorBridge/CarrierK1V.lean:42`, `Syntax/MinusLanguage/Axioms.lean:76`)
- [x] **578**: add the package-name decision (`Logos` vs `FormalSystem`/`BimodalLogic`) to the
      toml migration, citing cslib's `lakefile.toml` and `docs.yml` as precedent
- [x] **585**: add a note that the gate phase should weigh `--wfail --iofail` (cslib's
      approach) against a warning-count baseline
- [x] **506**: note that its layout work follows the rewritten automation chapter
- [x] Wherever a description relies on a new task, cite the actual number allocated in Phase 4

**Timing**: 1 hour

**Depends on**: 2, 4

**Verification Tier**: local

**Scope Hypothesis**: 10 description edits (583, 581, 582, 584, 586, 590, 589, 578, 585, 506).
Line references are from the research snapshot. Spot-check each cited line with `sed -n` before
writing it into a description.

**Files to modify**:
- `specs/state.json` - description fields and `last_updated` for the tasks above

**Verification**:
- Each edited description contains its new scope text (check with `jq -r .description | grep`
  for a key phrase per task). `validate-state.sh` passes

---

### Phase 4: Create new tasks N1-N4 and apply stale-graph fixes [COMPLETED]

**Goal**: Add the four new tasks and clean up stale dependency metadata across the backlog.

**Tasks**:
- [x] Create each task using `.claude/commands/task.md`'s Create Task mode. Read
      `next_project_number` inside the same `state-write.sh` filter that increments it. Set
      `topic: codebase-cleanup` and priority, effort, and description from the report's
      Recommendation 2:
  - N1 `relocate_in_library_smoke_tests` (lean4, medium): classify 404
    `#check`/`#eval`/`#print` lines and 389 top-level `example`s outside `Examples/`, move the
    test-shaped ones to `Tests/BimodalTest/`, keep `MainResults.lean`, and add a debug-artifact
    invariant check with an allowlist. Note that C17 counts `#check @foo` as an occurrence
  - N2 `establish_durable_records_home` (markdown, small): decide whether
    `specs/paper-definitions-of-record.md` and `specs/decisions/*` should live under `docs/`,
    then move them and repoint the 43 Lean citations plus `check-paper-definitions.sh`
  - N3 `nest_semantics_language_family_files` (lean4, medium): move `Semantics/{Minus,Plus,Star}*.lean`
    into subdirectories to mirror the `Syntax/*Language/` layout, update the C8 parent tuple,
    and write `FormalSystem/ForMathlib/README.md`
  - N4 `adopt_mathlib_standard_linter_set` (lean4, large): enable
    `weak.linter.mathlibStandardSet` with documented opt-outs, measure the new warnings
    (`longLine` 692, `longFile` 37), baseline them under 585's gate, scope the 4 blanket linter
    suppressions and 7 unscoped `maxHeartbeats` with `in`, and add a blanket-suppression ratchet
- [x] Prune the Phase 1 stale dependency numbers from every active task's `dependencies`
      (e.g. 177 goes from 20 entries to 428/429/430; 569 drops 562; 540 drops 529; 481 drops
      434/483; 428 drops 432/433/434). Recompute absence at write time
- [x] 481: update the description pointer and `file_scope` from `MintBound.lean:6199` to the
      re-confirmed `MintBound/ClosureResidual.lean` location. Leave `status: blocked` and
      `blockers` unchanged
- [x] 428: prune dependencies only. Leave `status: blocked` unchanged (its blocker is a human
      scope decision)

**Timing**: 0.75 hours

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: 4 new tasks and about 36 pruned dependency references. Counts in the new
task descriptions (404, 389, 43, 692, 37, 4, 7) are research-time measurements and must be
labelled that way in the descriptions, not stated as current facts. Confirm the prune count
against the Phase 1 list.

**Files to modify**:
- `specs/state.json` - 4 new entries, `next_project_number`, dependency lists, 481 pointer

**Verification**:
- Topic count is 19. No active task's `dependencies` contains a number absent from
  `active_projects`. 481 and 428 are still `blocked`. `validate-state.sh` passes

---

### Phase 5: Wire the DAG, validate, regenerate TODO.md [COMPLETED]

**Goal**: Set the topic's dependency edges to match the report's wave table and publish the
result.

**Tasks**:
- [x] Set `dependencies` for each member (N1-N4 = the numbers allocated in Phase 4). Keep any
      live non-topic dependency each task already has:

| Wave | Task | Dependencies |
|------|------|--------------|
| 1 | 583, 582, 591, N3, N2, 581, 587, 578, N1 | none (583 loses 581/582/586/590) |
| 2 | 584 | 582, 591, N3, N2 |
| 2 | 586 | 591 |
| 2 | 590 | N2 |
| 3 | 569 | 584 |
| 3 | 585 | 583, 584 |
| 3 | 506 | 586 |
| 4 | N4 | 585 |
| 4 | 588 | 585, 591, N1, 569 |
| 5 | 540 | 588, N4 |
| 6 | 589 | 588, 540, N4, 584, 591, N3 |

- [x] Run a jq check that every topic dependency is in `active_projects` and that
      Kahn-style layering over the topic subgraph reproduces 6 waves with no cycle. Stop on
      failure
- [x] `bash .claude/scripts/validate-state.sh` *(deviation: altered — exits 1 with the same 10 pre-existing schema-drift failures present in the pre-edit backup (unknown fields such as `blockers`, `parent_task`, `active_goal`); no new failure introduced)*
- [x] Regenerate `specs/TODO.md` (`state-write.sh --regen-todo` on the last write, or
      `generate-todo.sh`) and confirm `## Task Order` shows the new topic grouping
- [x] Commit `task 593: reorganize codebase-cleanup topic and dependencies`. Stage only
      `specs/state.json`, `specs/archive/state.json`, `specs/TODO.md`, and this task's
      directory, and leave out other agents' in-flight changes

**Timing**: 0.5 hours

**Depends on**: 3

**Verification Tier**: local

**Scope Hypothesis**: 19 members across 6 waves, 10 member entries with non-empty topic
dependencies. Confirm with the Phase 5 layering script output.

**Files to modify**:
- `specs/state.json` - dependency lists
- `specs/TODO.md` - regenerated

**Verification**:
- Layering output matches the table. `validate-state.sh` exits 0. TODO.md diff shows the new
  topic and N1-N4 entries

## Testing & Validation

- [x] `jq '[.active_projects[]|select(.topic=="codebase-cleanup")]|length' specs/state.json` = 19
- [x] 542 in `specs/archive/state.json` with status `abandoned`, absent from `active_projects`
- [x] Topic subgraph is acyclic and layers into the 6 waves above
- [x] No active dependency references a non-active task
- [x] 428 and 481 still `blocked`, with `blockers` unchanged
- [x] `bash .claude/scripts/validate-state.sh` exits 0 *(deviation: altered — failure set identical to the pre-edit baseline, 10 pre-existing schema failures)*
- [x] `git diff --stat` touches only `specs/` paths

## Artifacts & Outputs

- `specs/state.json`, `specs/archive/state.json`, `specs/TODO.md` (updated)
- `specs/593_revise_task_organization_codebase_cleanup/state.pre-593.json` (backup)
- `specs/593_revise_task_organization_codebase_cleanup/summaries/01_cleanup-topic-reorganization-summary.md`

## Rollback/Contingency

Restore `specs/state.json` from `state.pre-593.json` through `state-write.sh` (a whole-document
replacement filter). Undo 542's archival with `/task --recover 542`, then regenerate TODO.md.
If another agent has written to state.json since the backup, revert per task entry with jq
instead of restoring the whole file.
