---
name: todo
agent: orchestrator
description: "Cleanup and archival lifecycle owner: remove completed tasks, migrate state to archive, clear orphan/stale entries, and sync status docs without creating new project directories"
---

You are executing the TODO maintenance workflow. Own **cleanup and archival** only; do **not** generate new tasks or create new project directories. Numbering must remain unchanged.

**Request:** $ARGUMENTS

**Context Loaded:**
@.opencode/specs/TODO.md
@.opencode/specs/state.json
@.opencode/specs/archive/state.json
@context/common/standards/tasks.md
@context/common/system/artifact-management.md
@context/common/system/state-schema.md
@context/common/system/status-markers.md
@context/project/repo/project-overview.md
@Documentation/ProjectInfo/FEATURE_REGISTRY.md
@Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md

**Task:**

Execute cleanup/archival in compliance with tasks.md, artifact-management.md, state-schema.md, and status-markers.md:

1) Route to @subagents/reviewer with **todo-maintenance** scope and loaded standards.
2) Reviewer must:
   - Normalize TODO.md formatting and statuses (only [NOT STARTED]/[IN PROGRESS]/[COMPLETED]/[BLOCKED]/[ABANDONED]); validate task IDs against `.opencode/specs/state.json` (increment_modulo_1000 rules).
   - Detect completed **and [ABANDONED]** tasks; if >5 combined, list and request user confirmation before removal; surface blockers separately for `[BLOCKED]` tasks (no removal).
   - Remove completed **and [ABANDONED]** tasks from TODO.md; migrate matching entries from `active_projects`/`pending_tasks` to `completed_projects` (use status `completed` or `abandoned`), then into `.opencode/specs/archive/state.json.archived_projects` with required metadata (project_number, project_name, type, timeline created/completed/archived or abandoned, summary, artifacts.base_path). Refresh `_last_updated` fields.
   - Move existing completed **or abandoned** project directories from `.opencode/specs/NNN_project_name/` to `.opencode/specs/archive/NNN_project_name/` per artifact-management.md; **never** create new project roots or subdirectories—only move what exists.
   - Detect and clear orphan specs directories (no TODO/state coverage) and stale state entries (no TODO or directory). Prefer archive/migrate; never delete contents. Emit warnings when directories or state entries are missing.
   - Keep `next_project_number` unchanged; /add, /plan, and /research own number allocation and project creation.
   - Update `Documentation/ProjectInfo/FEATURE_REGISTRY.md` and `Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md` to reflect cleanup outcomes and current lifecycle state.
   - Provide dry-run/report-only mode and validation: JSON syntax (jq), status-marker compliance, archive/state schema alignment; include abandonment-removal checks alongside completed-task cleanup to avoid regressions.
3) Present results with artifact references, state diffs, operations executed (and skipped), warnings, and next steps.

**File Structure:**
- Working TODO: `.opencode/specs/TODO.md`
- Active specs: `.opencode/specs/{project-name}/`
- Archive: `.opencode/specs/archive/{project-name}/`
- Status docs: `Documentation/ProjectInfo/`

**Expected Output:**
- Cleanup summary: tasks removed, state migrations, directories moved, orphan/stale issues resolved, warnings/errors.
- State updates: `.opencode/specs/state.json` pruned to active/pending; `.opencode/specs/archive/state.json` populated per state-schema; refreshed `_last_updated`.
- Status doc updates: FEATURE_REGISTRY.md and IMPLEMENTATION_STATUS.md reflect maintenance run and lifecycle state.
- Safety: No new project directories created; `next_project_number` untouched; operations are atomic with dry-run option.

**Safety and Error Handling:**
- Confirmation required when >5 completed tasks are detected before removal.
- Graceful degradation: if directories missing, note and continue; if archive move fails, continue and warn; never delete—only move or archive.
- Collect all warnings/errors with remediation guidance; ensure TODO.md and state writes are atomic.

Execute the TODO maintenance now.
