# Research Report: Harmonize /todo and /review Command Lifecycle

**Project**: #108  
**Date**: 2025-12-22  
**Research Type**: implementation strategy (workflow alignment)

## Research Question
How should /todo and /review be harmonized so that /todo owns cleanup/archival and /review owns ambition/gap analysis, while keeping TODO.md, state.json, archive/state.json, FEATURE_REGISTRY.md, and IMPLEMENTATION_STATUS.md in sync without creating project directories prematurely and complying with state-schema.md and tasks.md?

## Current State Snapshot
- **TODO.md**: Tasks 90–108 (none completed). Status markers vary between `[IN PROGRESS]`, `pending`, `[NOT STARTED]`; numbering already allocated. Some lifecycle work (task 104) overlaps cleanup scope.
- **state.json**: `_schema_version` 1.0.0, `next_project_number` 109. Active project: #7 (maintenance). Completed projects listed (1,2,3,4,5,6,59–62,90) remain in `completed_projects` but **archive/state.json is empty**, indicating archival migration is incomplete. `pending_tasks` includes 105, 107, 108 only; TODO.md shows many more tasks → mismatch.
- **archive/state.json**: Empty `archived_projects` array; `_last_updated` present. Archive directories exist (e.g., 007_research_and_define_repository_aims) but not indexed in archive/state.json.
- **Command specs**:
  - `/todo` spec already calls reviewer in todo-maintenance scope, mandates cleanup, state/archive updates, orphan resolution, status docs sync, and no new project dirs.
  - `/review` spec (current) is generic repo review; loads broad context, updates TODO via todo-manager, creates NNN_review_YYYYMMDD project dirs. No explicit ambition/gap analysis steps, cleanup, or status-doc sync.
- **Standards**: tasks.md enforces ID sourcing from state.json and status rules; state-schema.md defines separation of active vs completed vs archive and archive metadata; status-markers.md defines status tokens and transitions.

## Required Lifecycle Alignment
1. **Ownership split**
   - `/todo`: authoritative for cleanup and reconciliation (remove completed tasks from TODO.md; migrate corresponding state entries to archive/state.json; archive project dirs; clear orphaned specs dirs and stale state entries; refresh `_last_updated`).
   - `/review`: authoritative for ambition/gap analysis that proposes new tasks (likely via /add or todo-manager) without modifying numbering policy.
2. **Data stores to keep in lockstep**
   - `.opencode/specs/TODO.md` (authoritative task list)
   - `.opencode/specs/state.json` (active + completed projects, `pending_tasks`, health)
   - `.opencode/specs/archive/state.json` (archived_projects and metadata/search indices)
   - `Documentation/ProjectInfo/FEATURE_REGISTRY.md` and `IMPLEMENTATION_STATUS.md` (surfacing lifecycle changes and current status)
3. **Project numbering**
   - Do **not** mutate `next_project_number` during /todo or /review. Only /add (/plan, /research) create dirs and advance numbering.

## Recommended Data Flows
### /todo (cleanup/archival)
- **Inputs**: TODO.md, state.json, archive/state.json, specs/ directory listing, status docs.
- **Processing steps** (idempotent, no new project dirs):
  1) Parse TODO.md tasks → identify `[COMPLETED]` or status `completed` tasks; confirm removal policy (>5 asks confirmation per spec).
  2) For each completed task: remove from TODO.md; move matching project entry from `active_projects` or `pending_tasks` → `completed_projects`, then migrate to `archive/state.json.archived_projects` with required metadata (project_number, project_name, type, timeline {created/completed/archived}, summary, artifacts.base_path). Remove from `completed_projects` once archived; update `_last_updated`.
  3) **Orphan/stale detection**:
     - Orphan directories: specs/* directories with no matching TODO task or state entry → archive or mark for deletion? (spec: clear orphaned dirs; prefer move to archive or flag warning, never delete).
     - Stale state: entries in state.json without TODO coverage or missing directories → remove or migrate to archive; record warnings.
  4) Archive directory handling: move completed project dirs from `.opencode/specs/NNN_*` → `.opencode/specs/archive/NNN_*`; ensure archive/state.json records artifacts paths and `_last_updated`.
  5) Sync status docs: append/adjust FEATURE_REGISTRY.md and IMPLEMENTATION_STATUS.md to reflect maintenance run (what was cleaned, remaining active tasks/projects) without creating new features.
  6) Emit maintenance summary + errors/warnings; refresh maintenance/state.json if in scope (linked via state_references).
- **Outputs**: Updated TODO.md, state.json, archive/state.json, status docs; summary with IDs moved, orphan/stale fixes, warnings.

### /review (ambition/gap analysis)
- **Inputs**: Standards contexts, repository materials, existing TODO/state, status docs.
- **Processing steps**:
  1) Run structured ambition/gap analysis (coverage vs roadmap, architecture phases, docs completeness, command coverage).
  2) Produce findings → generate proposed tasks using `/add` (or todo-manager) so numbering comes from state.json and directory creation deferred to /add when artifacts required.
  3) Update TODO.md with new tasks (per tasks.md formatting, status `[NOT STARTED]`), **without** touching completed/archival flows.
  4) Update state.json `pending_tasks` (append new tasks, no changes to active/completed arrays unless review itself is a project) and refresh `_last_updated`; do **not** modify `next_project_number` beyond what /add already performed.
  5) Update FEATURE_REGISTRY.md and IMPLEMENTATION_STATUS.md to log new ambitions and open gaps.
  6) Produce review reports in its own project directory only if explicitly invoked via /add or existing review project; avoid auto-creating NNN_review_YYYYMMDD dirs when performing pure ambition updates unless spec requires new review project creation.
- **Outputs**: Findings summary, new tasks (with IDs), status-doc deltas, no cleanup actions.

## Edge Cases to Handle
- **Archive empty vs completed populated**: When completed_projects exist but archive/state.json empty (current case), /todo must migrate them with proper metadata and directories (if missing, log warning, do not fail).
- **Orphaned specs dirs**: specs directories without TODO/state coverage; move to archive or flag; never delete.
- **Stale state entries**: state entries without TODO or directory; remove/migrate with warning; ensure `_last_updated` refreshed.
- **Large removal (>5 completed tasks)**: enforce confirmation per /todo spec.
- **Status normalization**: Convert legacy `pending`/`in_progress`/`completed` in TODO/state to standard markers and lowercase state values per status-markers.md.
- **Numbering protection**: /todo and /review must not change `next_project_number`; /review task creation relies on /add or numbering helper.
- **Directory creation guard**: /todo and /review must not create new project dirs except when archiving existing ones; review reports should only be generated when a review project exists/created via /add.

## Recommendations / Next Steps
1. **Update command specs**
   - Expand `/review` spec to include ambition/gap analysis workflow, task creation via /add, and explicit non-cleanup stance; clarify when review projects are created and how artifacts are stored.
   - Tighten `/todo` spec to detail archive/state.json shape (timeline, artifacts, summary), orphan/stale handling rules, and status-doc sync steps.
2. **Implement orchestration logic**
   - Add detection utilities for completed tasks, orphan dirs, and stale state entries (shared helper used by /todo).
   - Add archival writer that populates archive/state.json per state-schema.md and moves directories safely.
   - Add TODO/state/status doc updaters with atomic write + validation (JSON validation).
3. **Validation and safeguards**
   - Enforce no `next_project_number` mutation in /todo and /review flows; ensure /review defers to /add for new task creation.
   - Add confirmation gate for >5 removals; collect warnings/errors section.
4. **Documentation updates**
   - Update FEATURE_REGISTRY.md entry for command lifecycle harmonization (Task 108) once implemented; add IMPLEMENTATION_STATUS.md notes for the maintenance/review split and latest run.
5. **Test plan**
   - Scenario tests: (a) completed tasks present with matching dirs; (b) completed tasks without dirs; (c) stale state entries; (d) orphan dirs; (e) review proposing tasks without altering numbering.

## Suggested Implementation Steps (for planning)
1) Design shared lifecycle helper module: load TODO/state/archive, detect completed/orphan/stale, compute migrations, normalize statuses.  
2) /todo flow: apply migrations, move dirs to archive, write state.json + archive/state.json + TODO.md + status docs, refresh `_last_updated`, emit summary.  
3) /review flow: run gap analysis checklist, propose tasks via /add, update TODO/state/status docs, keep archival untouched, no new dirs unless /add triggers.  
4) Add validation hooks (JSON schema lint, status marker checks) and dry-run/reporting mode for safety.

## Further Research Needed
- Confirm desired ambition/gap analysis rubric (e.g., per architecture layers, docs, commands, coverage metrics) and whether reviews always instantiate a review project directory.
- Define archive/state.json minimal required fields for backward compatibility given current empty structure.
- Decide policy for orphan directories with partial artifacts (archive vs warn only).

## Specialist Reports
- Source documents: `.opencode/command/todo.md`, `.opencode/command/review.md`, `.opencode/specs/TODO.md`, `.opencode/specs/state.json`, `.opencode/specs/archive/state.json`, `Documentation/ProjectInfo/FEATURE_REGISTRY.md`, `Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md`, `.opencode/context/common/system/state-schema.md`, `.opencode/context/common/standards/tasks.md`, `.opencode/context/common/system/status-markers.md`, `.opencode/context/common/system/artifact-management.md`.
