# Implementation Plan: Task #811

- **Task**: 811 - Re-cut the dependency edges on the ladder/periodicity line
- **Status**: [NOT STARTED]
- **Effort**: 0.75 hours
- **Dependencies**: None
- **Research Inputs**: specs/811_ladder_periodicity_dependency_edge_recut/reports/01_dependency-edge-recut-verdict.md
- **Artifacts**: plans/01_dependency-edge-recut.md (this file)
- **Standards**:
  - .claude/context/formats/plan-format.md
  - .claude/context/standards/status-markers.md
  - .claude/context/standards/artifact-management.md
  - .claude/context/standards/tasks.md
  - .claude/rules/state-management.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

The audit is already settled: the research report returns a per-edge verdict against landed
artifacts (drop `809 -> 734`, keep `807 -> 809` as the file-territory serialization edge, leave
`809 -> 805` alone). What remains is the mechanical half of the deliverable — apply the one edge
deletion to `specs/state.json`, regenerate `specs/TODO.md` from it, and verify that the surviving
edge set still keeps tasks 809 and 807 out of the same orchestrate wave. No Lean is written, no
Lean probe is run, and nothing under `FormalSystem/` or `Tests/` is touched. Definition of done:
`809.dependencies == [805]`, `807.dependencies == [809]`, `734` untouched and still `hold`, and
`specs/TODO.md` rendering exactly those sets.

### Research Integration

The report's Recommendations 1-3 are this plan's phases verbatim, and its findings fix the
acceptance bar:

- **F1/F2/F4/E1** are the four independent mechanical grounds for the `809 -> 734` drop (no
  cross-reference in either direction; disjoint `FormalSystem` import subtrees; 734's landed
  `StabSaturated` predicate is identically true by its own probe header; the unobtainable Handbook
  sections 5.10/5.11 are R2's, and 809 is on R1's ladder/`RaySummary` line). The implementation
  does not re-derive any of this — it applies the verdict.
- **D2/F7** fix the `807 -> 809` treatment: the *semantic* rationale is refuted (807's test bed
  is `Probe719Backward`/`Probe733Mirror`, not 809's adequacy relation), but the edge is the sole
  expression of an unordered `file_scope` overlap (`scripts/check-evidence-probes.sh` plus
  `specs/evidence/seam-gluing-ray-product/`, measured identical on both tasks), so it stays.
- **Recommendation 1** supplies the exact `jq` form, including the `select((. == 734) | not)`
  spelling required by `CLAUDE.md`'s jq-safety section (a bare `!=` is escaped to `\!=` through
  the harness and fails to parse).
- **D1** is why no state write happened in the research dispatch: `specs/state.json` is live
  orchestrator state with other agents active, so the write is deliberately deferred to this
  implementation round.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was provided in this dispatch, and no roadmap phases are required. The recut's
roadmap-visible effect is indirect: it unblocks the two never-dispatched successors on the
ladder/periodicity line without touching task 734's hold.

## Goals & Non-Goals

**Goals**:
- `specs/state.json`: task 809's `dependencies` becomes `[805]` — the `734` entry removed, no other
  field of any task touched.
- `specs/TODO.md` regenerated from `state.json` so the two records agree on the resulting edge set.
- The `check-evidence-probes.sh` serialization between 809 and 807 verified to survive as an
  explicit edge (`807 -> 809`), and verified to keep the two out of one orchestrate wave.
- The per-edge verdict report already exists at
  `specs/811_ladder_periodicity_dependency_edge_recut/reports/01_dependency-edge-recut-verdict.md`
  and satisfies the first ACCEPTANCE clause; this plan does not rewrite it.

**Non-Goals**:
- Lifting or weakening task 734's `[HOLD]`, or editing its `held_at`, its probe
  (`specs/evidence/seam-gluing-ray-product/mosaic-stab-saturated.lean`), or its report.
- Re-measuring the `hodkinson_2006` paywall, or editing `specs/literature-index.json`.
- Any change under `FormalSystem/`, `Tests/`, or `scripts/check-evidence-probes.sh`.
- Writing or running a Lean probe, or running `lake build`.
- Adding any compensating or pre-emptive edge for task 734 (report Recommendation 4).
- Dropping the `809 -> 805` edge (real and already satisfied; 805 is `[COMPLETED]`).
- No `## Lean Challenge Statements` section is present in this plan and none is owed: this task
  commits no Lean declarations, so its Goals name no Lean identifiers. A present-but-empty section
  is an error condition for `lean-challenge-snapshot.sh` (it exits non-zero when the heading
  exists with no ```lean block), so omitting it is the correct shape, not an oversight.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Concurrent orchestrator write to `specs/state.json` clobbers the edit (other agents are live this session) | H | M | Re-read 809/807/734's objects immediately before and after the `jq` write; if the pre-read no longer matches the measured starting set, stop and report rather than overwrite. `file_scope` already declares the collision with tasks 751/784 and the dispatch requires a separate cycle. |
| The `jq` edit drops an unrelated field or rewrites an array wholesale | H | L | Recommendation 1's form applies `|=` to the single selected project's `dependencies` array only. Verify with a full `jq`-object diff of 809, 807 and 734 before/after; `.claude/rules/state-management.md` prohibits wholesale array assignment. |
| `specs/TODO.md` hand-edited instead of regenerated | M | L | Phase 2 runs `bash .claude/scripts/generate-todo.sh`; `state-management.md` forbids editing `TODO.md` directly for dependency changes. |
| Dropping `809 -> 734` is later read as "734's remaining half is unnecessary" | M | M | The report's Executive Summary and D4 already state the opposite; 734's hold and reactivation condition are untouched by every phase here. |
| The final `full` gate run surfaces pre-existing deploy staleness (dispatch records core/lean/typst stale) as a finding | M | H | Record it as a pre-existing, out-of-scope condition in the phase's verification notes; the remedy is `deploy-headless.sh`, never a hand-patch under `.claude/**` (`source-store-deploy-boundary.md`). |
| 809 is later dispatched and finds a dependency this audit missed | L | L | Re-add with `update-task-status.sh --depends-on-add='[734]'`; the report's Risks section records this as the cheap direction of the error. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |

Phases within the same wave can execute in parallel.

### Phase 1: Drop the 809-on-734 edge in state.json [NOT STARTED]

**Goal**: Task 809's `dependencies` array in `specs/state.json` reads `[805]`, with every other
field of 809 and every other task object byte-identical.

**Tasks**:
- [ ] Pre-read the three task objects and keep the output for comparison:
      `jq '.active_projects[] | select(.project_number==734 or .project_number==807 or .project_number==809)' specs/state.json > /tmp/811-pre.json`
- [ ] Confirm the pre-read matches the measured starting set (809 `[734,805]`, 807 `[809]`, 734
      `hold` with `[733,805]`). If it does not, STOP: a concurrent writer moved the state; report
      rather than overwrite.
- [ ] Apply the edge deletion with the report's exact form:
      `jq '(.active_projects[] | select(.project_number==809) | .dependencies) |= map(select((. == 734) | not))' specs/state.json > specs/state.json.811.tmp && mv specs/state.json.811.tmp specs/state.json`
- [ ] Post-read the same three objects to `/tmp/811-post.json` and `diff` against `/tmp/811-pre.json`;
      the only differing line must be 809's `dependencies`.
- [ ] Confirm `jq 'any(.active_projects[]; .project_number==809)'` is still `true` and the
      `active_projects` array length is unchanged (guards against a malformed filter emptying the file).

**Timing**: 0.25 hours

**Depends on**: none

**Verification Tier**: local

**Tier Justification**: The edit touches one file under `specs/**`, for which
`suite_selection_select` returns `__FULL_SWEEP__` (no mapped suite), so sub-case (a) applies: the
covering check is the diff read-through prescribed by the tier table plus
`jq -e '.' specs/state.json` confirming the file still parses and the `active_projects` length is
unchanged.

**Scope Hypothesis**: Exactly one edge is removed, from exactly one task object, and exactly two
files change across the whole plan (`specs/state.json`, `specs/TODO.md`) — the report's
dependency sweep found only `807 -> 809` and `809 -> [734,805]` referencing 734/807/809, so no
third task's edges need touching. Confirm at implementation time by re-running that sweep
(`jq -r '[.active_projects[] | select((.dependencies // []) | any(. == 809 or . == 807 or . == 734)) | "\(.project_number) -> \(.dependencies)"] | .[]' specs/state.json`)
before and after the write; if a third edge appears, the hypothesis is refuted and the phase
reports it instead of silently widening scope.

**Files to modify**:
- `specs/state.json` - task 809's `dependencies`: `[734, 805]` -> `[805]`. No other field, no other task.

**Verification**:
- `jq -r '.active_projects[] | select(.project_number==809) | .dependencies' specs/state.json` prints `[805]`.
- `jq -r '.active_projects[] | select(.project_number==807) | .dependencies' specs/state.json` prints `[809]` (unchanged).
- `jq -r '.active_projects[] | select(.project_number==734) | "\(.status) \(.dependencies)"' specs/state.json` prints `hold [733,805]` (unchanged).
- `diff /tmp/811-pre.json /tmp/811-post.json` shows only 809's `dependencies` line.
- `jq -e '.' specs/state.json >/dev/null` exits 0 (file still valid JSON).

---

### Phase 2: Regenerate TODO.md and verify the surviving edge set [NOT STARTED]

**Goal**: `specs/TODO.md` agrees with `specs/state.json` on the resulting edge set, and the
`check-evidence-probes.sh` serialization between 809 and 807 is confirmed still expressed as an
explicit edge that keeps the two out of one orchestrate wave.

**Tasks**:
- [ ] `bash .claude/scripts/generate-todo.sh`
- [ ] Verify task 809's rendered block reads `- **Dependencies**: Task 805` (was `Task 734, Task 805`)
      and task 807's reads `- **Dependencies**: Task 809` (unchanged) —
      `grep -n -A8 '^### \[.*\] 809\|809\.' specs/TODO.md` or the equivalent block read.
- [ ] Re-run the dependency sweep from Phase 1's Scope Hypothesis and record that the surviving
      edge set is exactly `807 -> 809` and `809 -> 805`.
- [ ] Wave check, against the surviving set: 807 depends on 809, so an unordered-overlap wave
      containing both is impossible — the two cannot co-schedule while that edge stands. Record
      this explicitly (it is the dispatch's PRESERVE THIS SERIALIZATION clause), noting that both
      tasks declare the identical `file_scope` (`scripts/check-evidence-probes.sh`,
      `specs/evidence/seam-gluing-ray-product/`) and that per
      `context/patterns/batch-orchestration-guardrails.md` an unordered overlap takes an edge, not
      a bare exclusion.
- [ ] Confirm the no-op surface: task 734's `[HOLD]` and `held_at` unchanged,
      `specs/literature-index.json` unmodified, and `git status --short` shows no path under
      `FormalSystem/`, `Tests/`, or `scripts/check-evidence-probes.sh`.
- [ ] Run the complete gate set and record its outcome, including any pre-existing deploy-staleness
      finding as out-of-scope.
- [ ] Commit with targeted staging (`specs/state.json`, `specs/TODO.md`, plus this task's own
      report and plan paths) per `context/standards/git-staging-scope.md` — explicit file list, never
      `git add -A`/`.`/a directory pathspec.

**Timing**: 0.5 hours

**Depends on**: 1

**Verification Tier**: full

**Scope Hypothesis**: `generate-todo.sh` changes exactly one rendered dependency line (task 809's)
and nothing else in `specs/TODO.md`. Confirm by diffing `specs/TODO.md` before and after the
regeneration; if the regeneration rewrites unrelated blocks (a drift the generator is catching up
on, not this task's edit), the hypothesis is refuted — report the extra diff rather than folding
it in silently.

**Files to modify**:
- `specs/TODO.md` - regenerated from `state.json`; 809's dependency line loses `Task 734`.

**Verification**:
- `bash .claude/scripts/verify-deploy.sh` — the complete gate set this plan's final phase owes,
  run and observed, not trusted on sight. A pre-existing failure attributable to the recorded
  core/lean/typst deploy staleness is reported as such, never hand-patched under `.claude/**`.
- `bash .claude/scripts/validate-artifact.sh specs/811_ladder_periodicity_dependency_edge_recut/plans/01_dependency-edge-recut.md plan`
  exits 0 (this plan validates against `plan-format.md`).
- `grep -c 'Task 734' specs/TODO.md` is lower by exactly one than its pre-regeneration value, and
  task 809's block no longer names Task 734.
- `specs/state.json` and `specs/TODO.md` agree: 809 `-> 805`, 807 `-> 809`.
- `git status --short` lists only `specs/state.json`, `specs/TODO.md`, and this task's own
  directory.

---

## Testing & Validation

- [ ] `jq -e '.' specs/state.json` exits 0 after the edit.
- [ ] 809 `dependencies == [805]`; 807 `dependencies == [809]`; 734 `status == hold`, `dependencies == [733,805]`.
- [ ] `specs/TODO.md` regenerated by `generate-todo.sh` (not hand-edited) and agreeing with `state.json`.
- [ ] Dependency sweep returns exactly two edges referencing 734/807/809: `807 -> 809`, `809 -> 805`.
- [ ] The `807 -> 809` edge is present, so 809 and 807 cannot land in the same orchestrate wave.
- [ ] No diff under `FormalSystem/`, `Tests/`, `scripts/check-evidence-probes.sh`, or `specs/literature-index.json`.
- [ ] `bash .claude/scripts/verify-deploy.sh` run and its outcome recorded.

## Artifacts & Outputs

- `specs/state.json` — task 809's `dependencies` reduced to `[805]`.
- `specs/TODO.md` — regenerated view of the resulting edge set.
- `specs/811_ladder_periodicity_dependency_edge_recut/reports/01_dependency-edge-recut-verdict.md`
  — the per-edge verdict report (already written; satisfies ACCEPTANCE clause 1, not re-authored here).
- `specs/811_ladder_periodicity_dependency_edge_recut/plans/01_dependency-edge-recut.md` — this plan.
- `specs/811_ladder_periodicity_dependency_edge_recut/summaries/01_dependency-edge-recut-summary.md`
  — implementation summary, written at completion.

## Rollback/Contingency

The whole change is one array element in `specs/state.json` plus a regenerated `specs/TODO.md`, so
the cheapest contingency is forward, not a tree rollback:

- **Wrong edge removed, or a concurrent writer interleaved**: restore 809's edge with
  `bash .claude/scripts/update-task-status.sh --depends-on-add='[734]' 809` (the script has an add
  flag but no removal counterpart, which is why the drop goes through `jq`), then re-run
  `generate-todo.sh`.
- **`state.json` left malformed by the `jq` write**: `git checkout` is not needed if the change is
  uncommitted and isolated — restore from `git show HEAD:specs/state.json`, re-apply the single
  edge deletion, and re-verify. If a genuine working-tree rollback becomes necessary, follow
  `context/contracts/recovery.md`'s rollback rung for the snapshot-then-rollback invocation shape
  (including its out-of-scope override flag); do not emit a bare reverting snapshot as a
  precautionary checkpoint.
- **`TODO.md` desynced**: re-run `bash .claude/scripts/generate-todo.sh`; it is idempotent and
  reads only `state.json`.
- **Verdict itself disputed later**: re-adding the edge is one `--depends-on-add` call, and the
  report records this as the cheap direction of the error.
