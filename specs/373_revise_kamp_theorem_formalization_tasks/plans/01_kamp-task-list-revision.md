# Implementation Plan: Task #373

- **Task**: 373 - revise_kamp_theorem_formalization_tasks
- **Status**: [IN PROGRESS]
- **Effort**: 2 hours
- **Dependencies**: None (all inputs landed: task 370 completed, research report 01 written)
- **Research Inputs**: specs/373_revise_kamp_theorem_formalization_tasks/reports/01_kamp-task-decomposition.md
- **Artifacts**: plans/01_kamp-task-list-revision.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Execute the task-management operations that implement research report 01's verdicts on the
blocked Kamp theorem formalization work: supersede task 358 (whose `blocked` status is stale —
task 370 already landed the M2 de-folded carrier that resolves its root cause), create two
successor tasks under topic `kamp_theorem_formalization` targeting the two remaining
`KampPrior.lean` sorries (`:519`, `:522`) and the final assembly/axiom audit, redirect the one
active dependent (task 362), and confirm tasks 341, 303, and 359 are dispatch-ready as-is. All
operations are `specs/state.json` edits plus `generate-todo.sh` regeneration and scoped commits.
**No `.lean` file is edited by this task** — the successor tasks do that work later.

### Research Integration

Report 01's conclusions are adopted wholesale:

- **358 superseded, not revised a 9th time** (Decision 2): its 8-version plan chain targets the
  pre-M2 folded-carrier interface. Mechanism chosen here: mark `[ABANDONED]` with a
  `completion_summary` documenting the stale blocker and the handoff (the same convention used by
  the existing abandoned entry for task 162), rather than a short bridging revision — a 9th plan
  version, however brief, keeps the churn artifact chain alive, which is exactly the pattern the
  parent task exists to break. Findings are preserved by reference from the successor task's
  description (`358/reports/11_render-cluster-divergence-audit.md`, phase-5-crux-a handoff).
- **Successor Task B folded into Task A** (report's own sequencing note: "do not over-fragment a
  small residual arm"). One successor task covers both `:519` (primary) and `:522` (secondary,
  adjudicate-then-resolve), with an explicit escape hatch to `/spawn` the `:522` residue if
  `:519` consumes the full dispatch budget. Task A will be dispatched `--hard`, whose per-phase
  dispatch model accommodates the two-stage scope naturally.
- **Tasks 341, 303, 359 need no revision** (Decisions 3-4): verdicts are recorded, not edited.
- **No refactor of `InteriorGateGeneralK.lean` or the carrier trio before the sorries land**
  (Decision 5): encoded as an explicit constraint in the successor task's description.

### Prior Plan Reference

No prior plan (this is plan round 01 for task 373).

### Roadmap Alignment

`roadmap_path` was not provided; ROADMAP.md was consulted read-only by the research phase only.
Report F6 notes ROADMAP.md's "Current state" section is stale (pre-370) — its refresh is
deliberately assigned to successor task 375's scope, NOT performed by this task.

## Goals & Non-Goals

**Goals**:

- Correct task 358's stale `blocked` state by superseding it: status `abandoned`,
  `blocked_reason` cleared, `completion_summary` documenting the 369-adjudicated/370-landed
  resolution and the handoff to its successor.
- Create successor task **374** (`retire_kampprior_519_522_residual_arms`, lean4, deps `[370]`)
  covering both remaining sorries, and successor task **375**
  (`kamp_completeness_final_assembly_axiom_audit`, lean4, deps `[374]`), both under topic
  `kamp_theorem_formalization`, with `file_scope` set.
- Redirect task 362's dependency edge `358 -> 375` (362 needs the fully assembled sorry-free
  chain, which 375 certifies).
- Record dispatch verdicts for 341 (`/implement 341`, any time, fully parallel), 303
  (`/implement 303`, existing plan v19, no re-research), and 359 (after 303) — verifying their
  entries are dispatch-ready without edits.
- Leave `specs/state.json` valid, TODO.md regenerated, and every green sub-step committed.

**Non-Goals**:

- No edits to any `.lean` file (read-only verification of the `:519`/`:522` sorry sites only).
- No edits to `specs/ROADMAP.md` (delegated to task 375).
- No new plan version for 358, no edits to 341's plan v02 or 303's plan v19.
- No archival/relocation of the 358 task directory (that is `/todo`'s job after abandonment).
- No dispatching of the successor tasks (the orchestrator/user does that after this task lands).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `next_project_number` drifts before Phase 2 runs (concurrent task creation), so 374/375 are taken | M | L | Phase 1 re-reads `next_project_number` at execution time; if it is not 374, shift both successor numbers up and substitute the actual numbers consistently in Phases 2-4 (descriptions, 362 redirect, commit messages) |
| Abandoning 358 looks like discarding its genuinely valuable findings (H5 audit, root-cause diagnosis) | M | M | Successor 374's description cites `358/reports/11` and the phase-5-crux-a handoff by path as authoritative grounding; 358's `completion_summary` names both; the 358 directory is left in place |
| 358's directory later moves to `specs/archive/` via `/todo`, breaking the citation paths in 374's description | L | M | 374's description notes the directory "may later move under specs/archive/" so the reference survives archival |
| Folding the `:522` arm into 374 overloads a single dispatch | L | L | 374's description mandates `:519` first and explicitly authorizes `/spawn` for the `:522` residue if the budget is consumed — never an indefinite `[PARTIAL]` |
| Hand-editing state.json corrupts JSON or loses fields | H | L | All edits via `jq` with `--arg`/`--argjson` (never string interpolation of descriptions); `jq empty specs/state.json` gate after every write; `generate-todo.sh` only after validation passes; commit only after green |
| 362's dependency redirect is wrong direction (374 vs 375) | L | L | Redirect to 375: 362 (strong completeness) needs the certified sorry-free chain, which 375's axiom audit delivers; 375 already depends on 374, so the edge is transitive-complete |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 2, 3 |

Phases within the same wave can execute in parallel. (All state.json-writing phases are
deliberately sequential — a single writer at a time.)

### Phase 1: Precondition verification and successor number allocation [COMPLETED]

**Goal**: Confirm the world still matches the research report's snapshot before any write, and
pin the successor task numbers.

**Tasks**:
- [x] *(completed: all six assertions confirmed)* Read `specs/state.json` and verify: task 358 has `status: "blocked"` with a
  `blocked_reason` naming task 369; task 341 `status: "planned"`; task 359
  `status: "not_started"` with `dependencies: [303]`; task 303 `status: "planned"`; task 370
  `status: "completed"`; task 362 `dependencies` contains 358.
- [x] *(completed: actual value 374, no shift needed)* Read `next_project_number` — expected `374`. Record the actual value; successor numbers are
  `N` (Task A) and `N+1` (Task C). If `N != 374`, substitute the actual numbers everywhere
  374/375 appear in Phases 2-4.
- [x] *(completed: exactly two sorry statements at :519 and :522, no drift)* Read-only sorry-site check: `grep -n "sorry" Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean`
  — confirm exactly two hits at (or near) lines 519 and 522. If line numbers drifted, record the
  actual lines and substitute them in Phase 2's description text. **No edit to the file.**
- [x] *(completed: no divergence)* If any check materially diverges (e.g., 358 no longer blocked, a sorry already discharged),
  STOP and surface the divergence in the handoff rather than proceeding on stale premises.

**Timing**: 15 minutes

**Depends on**: none

**Files to modify**:
- None (read-only phase; no commit)

**Verification**:
- All six state assertions confirmed (or divergences explicitly recorded with substitutions
  decided); sorry count in `KampPrior.lean` is exactly 2.

---

### Phase 2: Create successor tasks 374 and 375 [COMPLETED]

**Goal**: Add the two successor task entries to `specs/state.json` under topic
`kamp_theorem_formalization` and advance `next_project_number`.

**Tasks**:
- [x] *(completed)* Append entry **374** to `active_projects` (schema mirrors existing entries, e.g. 359):
  - `project_number`: 374
  - `project_name`: `retire_kampprior_519_522_residual_arms`
  - `status`: `"not_started"`
  - `task_type`: `"lean4"`
  - `topic`: `"kamp_theorem_formalization"`
  - `effort`: `"medium"`
  - `parent_task`: 373
  - `dependencies`: `[370]`
  - `created` / `last_updated`: current ISO8601 UTC timestamp
  - `artifacts`: `[]`
  - `file_scope`: `["Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean", "Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/"]`
  - `description` (pass via `jq --arg`, verbatim):

    > Retire the two remaining KampPrior.lean sorries against the landed M2 de-folded carrier,
    > superseding the abandoned realization-recursion task (358). PRIMARY (:519, the n=1, k>=2
    > residual arm): discharge the general-k Rabinovich Cor 5.4 F_i-chain converter inside
    > nf_nvar_exist_all_depths using the M2 assets landed by task 370 — kampPrior_hreal_supply
    > (InteriorHrealSupplyK.lean), the *Fib sibling carrier chain (bracketEndChar_kvFib and
    > siblings), and kampPrior_site_rungKFib_gate_match. Phase 1 of the implementation plan MUST
    > be a bounded feasibility adjudication (mirroring task 369's discipline) confirming the M2
    > assets suffice for the general-k arm BEFORE full proof construction; if refuted, stop and
    > spawn a narrowly-scoped follow-up rather than re-opening the carrier design. SECONDARY
    > (:522, the n>=2 arm, off the critical path — completeness_discrete only invokes n in
    > {0,1}): first adjudicate route (a) prove it as a corollary of the :519 machinery vs route
    > (b) restate nf_nvar_exist_all_depths so its call sites only require n in {0,1}; then
    > execute the chosen route. If :519 consumes the full dispatch budget, land :519 first and
    > /spawn the :522 residue — never leave this task [PARTIAL] indefinitely. GROUNDING: do NOT
    > resume task 358's plan v09 (crux-first-interior-realizer) — it targets the pre-M2
    > folded-carrier interface. The authoritative diagnosis is
    > specs/358_realization_recursion_nf_nvar_exist_all_depths/reports/11_render-cluster-divergence-audit.md
    > and the phase-5-crux-a handoff (directory may later move under specs/archive/).
    > CONSTRAINTS: no refactor of InteriorGateGeneralK.lean or the carrier trio
    > (Base/CarrierK1V/CarrierKv) before both sorries land; respect the frozen bracketEndChar_kv
    > defeq bridge (CarrierKv.lean:246-249, InteriorGateGeneralK.lean:339-351). Definition of
    > done: zero sorries in KampPrior.lean, full lake build green, no new axioms. Dispatch with
    > --hard --lit (Rabinovich 2014, doc_id rabinovich_2014, Lemma 5.3 / Cor 5.4(1)).

- [x] *(completed)* Append entry **375**:
  - `project_number`: 375
  - `project_name`: `kamp_completeness_final_assembly_axiom_audit`
  - `status`: `"not_started"`
  - `task_type`: `"lean4"`
  - `topic`: `"kamp_theorem_formalization"`
  - `effort`: `"small"`
  - `parent_task`: 373
  - `dependencies`: `[374]`
  - `created` / `last_updated`: current ISO8601 UTC timestamp
  - `artifacts`: `[]`
  - `file_scope`: `["Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean", "specs/ROADMAP.md"]`
  - `description` (verbatim):

    > Final assembly and axiom audit for the Kamp expressive-completeness chain, after the
    > KampPrior sorry-retirement task (374) lands. Confirm completeness_discrete
    > (Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean:276) is fully sorry-free; run
    > lean_verify across the full dependency chain nf_nvar_exist_all_depths ->
    > nf_characterizable_temporal_prior -> kamp_prior_expressive_completeness ->
    > US_expressively_complete_over_prior, confirming the axiom set is exactly {propext,
    > Classical.choice, Quot.sound}; run a fresh sorry/admit scan across
    > Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ excluding Boneyard/; refresh
    > specs/ROADMAP.md's Current state section (dated 2026-07-12, pre-M2) to reflect the landed
    > state. Verification and documentation only — no new proof content. Standard dispatch (no
    > --hard / --lit needed).

- [x] *(completed)* Set `next_project_number` to 376.
- [x] *(completed)* Validate: `jq empty specs/state.json`.
- [x] *(completed: both render [NOT STARTED])* Regenerate TODO.md: `bash .claude/scripts/generate-todo.sh`; confirm both new tasks render
  with `[NOT STARTED]`.
- [x] *(completed)* Commit (scoped to `specs/state.json` + `specs/TODO.md`):
  `task 373 phase 2: create successor tasks 374 and 375` with session ID in body.

**Timing**: 45 minutes

**Depends on**: 1

**Files to modify**:
- `specs/state.json` - two new entries + `next_project_number` bump
- `specs/TODO.md` - regenerated (never edited directly)

**Verification**:
- `jq empty` passes; `jq '.active_projects[] | select(.project_number == 374 or .project_number == 375)'`
  returns both entries with correct deps/topic/type; `next_project_number == 376`; TODO.md shows
  both tasks; commit created.

---

### Phase 3: Supersede task 358 and redirect task 362 [COMPLETED]

**Goal**: Close out the stale-blocked task in favor of its successor, and repoint the one active
dependent.

**Tasks**:
- [x] *(completed)* Update entry 358 via `jq`:
  - `status`: `"abandoned"`
  - `blocked_reason`: `null`
  - `last_updated`: current ISO8601 UTC timestamp
  - `completion_summary` (verbatim, via `--arg`):

    > Superseded by task 374 (retire_kampprior_519_522_residual_arms). The blocked status was
    > stale: task 369 adjudicated the M1 route (REFUTED, high confidence) and task 370 landed
    > the M2 de-folded arity-4 carrier — its completion summary states "Unblocks task 358" —
    > resolving the root-cause igFoldBit fold circularity this task was blocked on. Rather than
    > a 9th plan revision against a superseded interface (8 plan versions, 12 reports, 12
    > handoffs targeted the pre-M2 folded carrier), the remaining work (KampPrior.lean:519/:522)
    > moves to task 374 against the landed *Fib assets. This task's findings remain
    > authoritative by reference: reports/11_render-cluster-divergence-audit.md (root-cause
    > diagnosis) and the phase-5-crux-a handoff.

- [x] *(completed: result [361, 375, 169, 170])* Update entry 362: replace 358 with 375 in `dependencies` (result: `[361, 375, 169, 170]`,
  order immaterial); update its `last_updated`.
- [x] *(completed: directory untouched)* Leave the `specs/358_realization_recursion_nf_nvar_exist_all_depths/` directory untouched
  (archival is `/todo`'s job).
- [x] *(completed)* Validate: `jq empty specs/state.json`.
- [x] *(completed: renders [ABANDONED])* Regenerate TODO.md; confirm 358 renders `[ABANDONED]`.
- [x] *(completed)* Commit (scoped): `task 373 phase 3: supersede task 358 and redirect task 362` with session
  ID in body.

**Timing**: 30 minutes

**Depends on**: 2

**Files to modify**:
- `specs/state.json` - 358 status/summary, 362 dependency edge
- `specs/TODO.md` - regenerated

**Verification**:
- 358 shows `status: "abandoned"`, `blocked_reason: null`, non-empty `completion_summary`
  naming 374; 362's dependencies contain 375 and not 358; TODO.md consistent; commit created.

---

### Phase 4: Record dispatch verdicts and final validation [NOT STARTED]

**Goal**: Confirm the leave-as-is tasks are dispatch-ready, record the verdict table durably, and
close the task green.

**Tasks**:
- [ ] Re-verify (read-only) that no edits are needed for the leave-as-is tasks:
  - 341: `status: "planned"`, deps `[335, 337, 340, 346]` all completed, plan
    `341/plans/02_module-split-refresh.md` present on disk -> dispatchable via `/implement 341`
    any time, fully parallel to everything else.
  - 303: `status: "planned"`, plan `303/plans/19_subsumption-closure-plan.md` present on disk ->
    dispatchable via `/implement 303` (no `/research` or `/plan` round needed).
  - 359: `status: "not_started"`, deps `[303]` -> correctly gated; dispatch after 303 closes.
  - If any of these drifted from the expected state, fix ONLY what blocks dispatchability
    (status/dependency fields), log the drift, and re-run `generate-todo.sh`.
- [ ] Write the implementation summary
  `specs/373_revise_kamp_theorem_formalization_tasks/summaries/01_kamp-task-list-revision-summary.md`
  containing: the verdict table (358 superseded -> 374; 341 dispatch as-is; 303 dispatch plan
  v19; 359 after 303; 362 redirected -> 375), the successor-task ordering diagram from report
  01 ("Ordering summary"), and the recommended dispatch commands
  (`/implement 341`, `/implement 303`, then `/orchestrate 374 --hard --lit` or
  `/research 374 --hard --lit` -> `/plan 374 --hard` -> `/implement 374 --hard --lit`, then 375,
  then 359).
- [ ] Final validation gate: `jq empty specs/state.json`; re-run
  `bash .claude/scripts/generate-todo.sh` and confirm it is idempotent (no diff on second run);
  spot-check TODO.md renders 374, 375 `[NOT STARTED]`, 358 `[ABANDONED]`.
- [ ] Commit (scoped to the summary + any drift fixes):
  `task 373 phase 4: record dispatch verdicts and validate state` with session ID in body.

**Timing**: 30 minutes

**Depends on**: 2, 3

**Files to modify**:
- `specs/373_revise_kamp_theorem_formalization_tasks/summaries/01_kamp-task-list-revision-summary.md` - new
- `specs/state.json` / `specs/TODO.md` - only if drift-fixes are needed

**Verification**:
- Summary file exists and contains the verdict table; `jq empty` passes; `generate-todo.sh`
  idempotent; all three status renderings confirmed in TODO.md; commit created.

## Testing & Validation

- [ ] `jq empty specs/state.json` passes after every write phase (2, 3, 4).
- [ ] `jq '.next_project_number' specs/state.json` returns 376 (or shifted equivalent per Phase 1).
- [ ] `jq '.active_projects[] | select(.project_number == 374) | .dependencies'` returns `[370]`;
  same for 375 returning `[374]`.
- [ ] `jq '.active_projects[] | select(.project_number == 358) | .status'` returns `"abandoned"`.
- [ ] `jq '.active_projects[] | select(.project_number == 362) | .dependencies'` contains 375,
  not 358.
- [ ] `git diff --staged` before each commit shows only `specs/` paths (state.json, TODO.md, and
  the task-373 summary) — never a `.lean` file, never ROADMAP.md.
- [ ] `grep -c "sorry" Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean` is unchanged
  from Phase 1's reading (proof that this task touched no Lean source).

## Artifacts & Outputs

- `specs/373_revise_kamp_theorem_formalization_tasks/plans/01_kamp-task-list-revision.md` (this plan)
- `specs/state.json` — entries 374, 375 created; 358 abandoned; 362 redirected;
  `next_project_number` 376
- `specs/TODO.md` — regenerated
- `specs/373_revise_kamp_theorem_formalization_tasks/summaries/01_kamp-task-list-revision-summary.md`
  — verdict table + dispatch guidance
- Three scoped git commits (phases 2, 3, 4)

## Rollback/Contingency

All changes are additive-or-reversible JSON edits committed per-phase:

- **Before any commit**: restore `specs/state.json` from `git show HEAD:specs/state.json` and
  re-run `generate-todo.sh` (state-first pattern; TODO.md is derived, never hand-fixed).
- **After a phase commit**: `git revert` the specific phase commit (each commit is scoped to
  exactly the files that phase touched, so reverts are clean), then re-run `generate-todo.sh`.
- **If 358's abandonment proves premature** (e.g., a successor-task feasibility check fails in a
  way that revives 358's plan chain): abandonment is terminal per state-management.md, so do NOT
  flip 358 back; instead the successor task spawns follow-ups — the 358 artifact chain remains on
  disk (and later in `specs/archive/`) for reference.
- **If successor numbers collided** (Phase 1 guard missed a race): revert Phase 2's commit,
  re-read `next_project_number`, re-run Phase 2 with fresh numbers.
