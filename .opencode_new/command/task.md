---
name: task
agent: orchestrator
description: "Execute TODO task(s) by number using plans/reports and keep specs in sync"
---

You are executing task(s) from `.opencode/specs/TODO.md` by number. Use existing research and plans, respect lazy directory creation, and keep TODO/state/artifacts synchronized.

**Task Input:** $ARGUMENTS (task number(s); ranges/lists allowed)

**Context Loaded:**
@.opencode/specs/TODO.md
@.opencode/specs/state.json
@.opencode/context/common/system/state-schema.md
@.opencode/context/common/system/artifact-management.md
@.opencode/context/common/system/status-markers.md
@.opencode/context/common/standards/tasks.md
@.opencode/context/common/standards/patterns.md
@.opencode/context/common/workflows/task-breakdown.md

## Execution Workflow

1. **Parse and validate input**
   - Support single numbers, comma-separated lists, and ranges (e.g., `105`, `105,106`, `105-107`).
   - Validate all numbers are positive integers; deduplicate expanded lists; fail clearly on invalid formats and return the bad inputs.

2. **Resolve each task in TODO.md**
   - Locate the task entry; if missing, fail that task gracefully with guidance to add it (via `/todo` or manual fix) and continue with other tasks.
   - Derive slug from TODO title (snake_case) and compute project root `.opencode/specs/NNN_slug/`; **do not create the root or subdirectories unless writing an artifact** (lazy creation per `artifact-management.md`).
   - Detect attached plan link; reuse exactly. If no plan link exists, execute directly (no failure), maintain lazy creation, and optionally recommend `/plan {task}` for complex work.

3. **Route execution**
   - Single task: route by work type (documentation → documenter; refactor → refactorer; research-only → researcher; general code → implementer).
   - Multiple tasks: route through `batch-task-orchestrator` with wave-based execution and `batch-status-manager` for atomic TODO/state updates; propagate per-task failures without partial updates.
   - When a plan exists, pass its path to the implementation orchestrator and keep plan phase status markers in sync during execution (align with `/implement`).

4. **Artifacts and lazy creation guardrails**
   - Create the project root only when writing the first artifact; create only the subdirectory needed at write time. Do not pre-create sibling subdirs or placeholder files.
   - Update the attached plan in place (if present) with status markers and timestamps per `status-markers.md` when phases progress.
   - When producing execution outputs, emit summaries under `summaries/implementation-summary-YYYYMMDD.md` (or update an existing summary) and reuse existing plan/research links.
   - Update project `state.json` alongside artifact writes with status, phase, timestamps, and artifact paths; do not write project state if no artifact was produced.

5. **TODO/state synchronization**
   - Update TODO entries with status markers (`[IN PROGRESS]` → `[COMPLETED]`), `**Started**`/`**Completed**` dates, and links to any updated plan and new/updated summary artifacts.
   - Keep numbering/metadata intact (Effort/Priority/Blocking/Dependencies) per `tasks.md` and align status values with `status-markers.md` and state schema.
   - Sync `.opencode/specs/state.json` task/project entries with TODO changes (status, timestamps, artifact links, phase markers) and reuse plan links already attached.

6. **Failure handling**
   - Invalid input: return error and do not mutate TODO/state/artifacts.
   - Missing TODO entry for a requested task: report explicitly, skip mutations for that task, and continue others.
   - Directory creation attempts without an artifact write: reject and remind of lazy creation rules.

7. **Return summary**
   - List tasks processed, routing decisions (including batch orchestration when applicable), artifacts created/updated (plans, summaries), TODO changes, and state updates.

## Usage Notes
- Always reuse the plan path attached in TODO.md when present; do not create project roots/subdirs unless writing an artifact (plan update or summary).
- For multi-task input (`count > 1` after expansion), use `batch-task-orchestrator` plus `batch-status-manager` to ensure atomic TODO/state updates and consistent wave routing.
- When any artifact is written, ensure a summary exists or is updated and linked in TODO/state alongside plan links; follow `artifact-management.md` and `tasks.md`.
- If no plan link exists, execute directly without failing while preserving lazy directory creation and numbering/state sync; advise `/plan {task}` only when additional planning is warranted.

## Usage Examples

```bash
/task 105                 # single task
/task 105,106             # multiple tasks (batch orchestrator)
/task 105-107             # range expansion (batch orchestrator)
/task 105, 107-109, 111   # mixed list + range (batch orchestrator)
```

Execute the task(s) now with artifact, TODO, and state synchronization.
