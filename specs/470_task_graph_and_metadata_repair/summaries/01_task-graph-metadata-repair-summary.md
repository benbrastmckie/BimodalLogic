# Implementation Summary: Task #470

- **Task**: 470 - TASK-GRAPH AND TASK-METADATA REPAIR
- **Status**: [COMPLETED]
- **Started**: 2026-08-24T21:00:00Z
- **Completed**: 2026-08-24T21:37:00Z
- **Effort**: ~2.5 hours
- **Dependencies**: None
- **Artifacts**: plans/01_task-graph-metadata-repair.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Nine mechanical defects from the 2026-08-24 programme review against the task graph and task
metadata in `specs/state.json`. All nine are now closed: five required a write ((A) 421's
acceptance criterion, (B)'s description half for 433/434, (F) 257/282 descriptions, (G) 177's
`file_scope`, (H) the counter reconciliation, (I) the seven-task archival); three were
verify-only and confirmed already applied ((C) 426's dependency, (D) 95's dependency, (E) the
`repo-hygiene` topic). No task's mathematical/technical substance changed and no task was
transitioned to a terminal status by hand — the only terminal transitions were the seven
already-`completed` tasks that `/todo` archived in Phase 6, the sanctioned exception.

## What Changed

- `specs/state.json` — task 421: acceptance-criterion final clause rewritten from "unchanged at 2
  (verify with: inline grep)" to "unchanged at 1 (verify with `scripts/check-module-invariants.sh`
  check C3, ... `countermodel_discrete` ...)"
- `specs/state.json` — tasks 433, 434: appended a pointer sentence (after the existing "Done
  means..." text) naming the downstream owners (463/465 for 433; 462/464 for 434) of the
  residuals that moved off these tasks
- `specs/state.json` — tasks 257, 282: `description` set from `null` to the research report's
  reconstructed text (257: HF Hub migration, blocked on user auth; 282: exhaustive-enumeration
  flip, next step the deferred c9 feasibility probe). Neither task's `status` changed.
- `specs/state.json` — task 177: `file_scope` corrected from
  `["README.md","ROADMAP.md","FormalSystem/","FormalSystem/","docs/"]` to
  `["README.md","specs/ROADMAP.md","FormalSystem/","docs/"]` (root `ROADMAP.md` → `specs/ROADMAP.md`,
  duplicate `FormalSystem/` removed)
- `specs/state.json`, `specs/archive/state.json`, `specs/TODO.md`, `specs/CHANGE_LOG.md` — seven
  completed tasks (432, 436, 457, 458, 459, 460, 467) archived via the `/todo` process; their
  `specs/` directories moved to `specs/archive/`
- `specs/state.json` — `metadata.total_tasks`/`generated_at`/`last_sync` and the entire
  `task_counts` object recomputed live from the post-archival `active_projects` array (42 tasks)
- No writes for (C) 426's `dependencies`, (D) 95's `dependencies`, or (E) the `repo-hygiene`
  topic/451's topic assignment — all three were confirmed already correctly applied

## Decisions

- Phase ordering: `/todo` (archival) ran before the counter recomputation, because the counters
  are a pure derived function of the post-archival `active_projects` array; computing them
  before `/todo` would have made them stale the instant the seven tasks left the array.
- `/task --sync`'s counter-fix claim in the original task description was verified false (no
  script anywhere reads or writes `metadata.total_tasks`/`last_sync`/`generated_at`/`task_counts.*`)
  and a dedicated `state-write.sh` filter was used instead, run after `/task --sync` for its
  other legitimate side effects.
- Every count carried by the plan, the research report, or the original review was re-confirmed
  live before being acted on (per the task's Scope Hypothesis Discipline), rather than trusted
  from a stale snapshot. One count changed between snapshots: the roadmap structure is
  111 table rows / 0 checkboxes (not "12 checkboxes / 0 table rows" as CLAUDE.md's own stale
  prose states) — recorded here as a documentation-drift finding, not acted on.

## Plan Deviations

- **Phase 8**, item "`bash .claude/scripts/validate-state.sh` passes": closed via
  `[COMPLETED WITH EXCLUSIONS]` with a `#### Reasoned Exclusions` record on the phase heading.
  The script reports the identical 13 `FAIL` lines against both the pre-task baseline commit
  (`71ee76cf9`) and the final post-task state — none of the 13 involve a field this task wrote.
  This task's edits strictly *improved* the script's `WARN` count (12 → 10) by removing 177's
  duplicate `file_scope` entry in Phase 4. Fixing the pre-existing schema drift is explicitly out
  of scope per this plan's own Non-Goals.
- **Phase 2**'s `UnorderedSuccessorLabelClosed` out-of-scope gate: confirmed 468 is still
  `not_started` and took no action — no owner assigned, symbol not named in any description.
  This is a deliberate non-write, not a deviation from the plan's own instruction.
- No other deviations. Every remaining phase followed the plan as written.

## Verification

- Build: N/A (no Lean/code changes; this task edits `specs/state.json` and task descriptions only)
- Tests: N/A
- Files verified: Yes — every phase's own verification block was run and its output recorded in
  the plan file's per-task `*(completed: ...)*` annotations
- `jq empty specs/state.json` / `jq empty specs/archive/state.json`: valid throughout
- `generate-todo.sh`: 0 bytes stderr, no undeclared-topic warnings
- Union dangling-edge scan (`active_projects` ∪ archive `archived_projects` ∪ `completed_projects`):
  0 dangling edges. The archive-only set (edges that resolve only in the archive — expected, not
  defects) grew from the pre-task 21 to a live 22: 408 and 437 dropped out (their only referencing
  tasks were among the 7 archived), and 432/436/460 joined (still referenced by live tasks, now
  archived themselves)
- 421's acceptance criterion: confirmed names both `C3` and `unchanged at 1` in the final file
- Wave ordering relation (not literal wave numbers, per the plan's own stale-prediction note):
  470 = wave 1, 426 = wave 2 (426 strictly after 470, holds); 169 = wave 4, 95 = wave 5 (95
  strictly after 169, holds)
- Terminal-transition audit: diffed the full pre-task `active_projects[].project_number` set
  against the final set — exactly the 7 expected numbers were removed, 0 added, 0 unexpected
  removals
- Counters: `metadata.total_tasks == task_counts.total == task_counts.active == (active_projects
  | length) == 42`, confirmed after Phase 7 and re-confirmed in Phase 8
- `validate-state.sh`: does NOT pass (13 pre-existing FAILs, unrelated to this task — see Plan
  Deviations above and the phase's `#### Reasoned Exclusions` record for full evidence)

## Impacts

- 421 is no longer gated behind an unsatisfiable acceptance criterion, unblocking the
  completeness critical path (421 → 422 → 169).
- 433 and 434 now self-document where their residual work moved, reducing the risk of a future
  dispatch re-attempting work now owned by 462-465.
- 257 and 282 now carry enough recoverable intent in `description` for a first dispatch to act on
  without re-deriving context from scratch.
- 177's `file_scope` now resolves entirely on disk, and task 468 (which independently names this
  same repair in its own Stage 3) will find it already done.
- `active_projects` no longer carries the seven long-completed tasks, so active-set counts and
  wave computation are no longer inflated by them.
- The top-level `metadata`/`task_counts` counters agree with the live tree for the first time in
  this task's audit trail — though, per the finding below, they have no ongoing maintainer and
  will drift again.

## Follow-ups

- **Vestigial counter fields have no maintainer.** A repo-wide grep confirmed no script or
  command reads or writes `metadata.total_tasks`/`last_sync`/`generated_at` or any `task_counts.*`
  field in normal operation — this task's Phase 7 write is a one-time correction, not a durable
  fix. A follow-up `meta` task should either wire a maintainer (e.g. into `/todo` or
  `/task --sync`) or deprecate these schema fields outright. Not created here, per this task's
  own Non-Goals.
- **`validate-state.sh` reports 13 pre-existing schema-drift FAILs**, unrelated to this task,
  covering unknown top-level fields (`active_goal`, `artifacts`, `last_updated`, `metadata`,
  `task_counts`) and unknown per-entry fields (`blockers`, `language`, `parent_task`,
  `previous_status`, `priority`, `related_tasks`, `researched`, `resume_phase`). A dedicated
  schema-reconciliation task (extend `state-schema.json` to recognize these fields, or remove
  them) would let `validate-state.sh` return to a clean PASS.
- **CLAUDE.md's Literature Extension section documentation is stale**: it describes this repo's
  `specs/ROADMAP.md` as "checkbox-based with zero table rows (checkboxes: 12, table_rows: 0)".
  A live `roadmap-integration.sh --print` run in Phase 6 measured `phases=0 checkboxes=0
  table_rows=111` instead. Not corrected here (out of this task's scope; flagged for visibility).
- `UnorderedSuccessorLabelClosed`'s residual remains unassigned, by design — task 468's amendment
  10e is the sanctioned place to assign it once 468 runs.
- `git-snapshot.sh --no-revert` (and, by the same code path, default mode) has a latent
  SIGPIPE/pipefail bug at its `STASH_REF=$(git stash list | head -1 | cut -d: -f1)` line: under
  `set -euo pipefail`, `head -1` closing the pipe early can make `git stash list` exit 141
  (SIGPIPE), which `pipefail` propagates as the whole pipeline's exit status, aborting the script
  with `exit 1` before it writes its completion marker — even though the underlying
  `git stash create`/`git stash store` already succeeded and the snapshot itself is durable. Not
  fixed here (`.claude/scripts/git-snapshot.sh` is a deployed artifact of
  `agent-system/extensions/core/scripts/git-snapshot.sh`, out of this task's scope); worked
  around in Phase 6 by taking the underlying `git stash create`/`git stash store` calls directly.
  Recommend a follow-up `meta` task to fix the script (e.g. `head -1 || true` or reading via
  `git rev-parse --short` instead of piping `git stash list` through `head`).

## References

- `specs/470_task_graph_and_metadata_repair/plans/01_task-graph-metadata-repair.md`
- `specs/470_task_graph_and_metadata_repair/reports/01_task-graph-metadata-repair.md`
- `specs/reviews/review-2026-08-24.md`
- `specs/CHANGE_LOG.md` (2026-08-24 entry, "Archive 7 completed tasks")
