# Research Report: Fix /research and /plan task-number parser regression (range/number handling)

**Project**: #163  
**Date**: 2025-12-24  
**Research Type**: comprehensive

## Research Question

Why do `/research 161` and `/plan 161` prompt for a task number instead of accepting the provided numeric input (including ranges), and how should parsing, status-marker preflight, and lazy-creation guardrails be implemented to avoid regressions?

## Sources Consulted

- `.opencode/context/common/system/status-markers.md` (status marker semantics)  
- `.opencode/context/common/system/artifact-management.md` (lazy creation, numbering)  
- `.opencode/context/common/standards/commands.md` and `/tasks.md` (command argument handling)  
- Recent task fixes for related regressions: tasks 153, 160, 161, 162, 167 (doc notes and behavioral expectations)

## Key Findings

### Regression cause (parsing)
- The command wrappers for `/research` and `/plan` currently normalize argv, but the numeric-or-range argument is routed through an interactive prompt when the parsed list is empty. A regression introduced a branch that treats any non-string promptable input as missing, so numeric tokens like `"161"` are discarded when the preflight path expects a list object. This triggers the fallback prompt even though argv already contained a valid numeric task id.
- Range parsing is not guarded by a numeric-only check before attempting a prompt path; when a single number is provided but range parsing is invoked, the code falls through to interactive prompt on parse failure instead of short-circuiting with the provided number.
- The planner/researcher subagent wrappers depend on task-executor for TODO/state preflight; when the numeric argument is dropped, the preflight cannot locate the TODO entry and re-prompts.

### Expected parsing & validation
- Accept exactly one numeric id or a numeric range list (e.g., `163` or `161-163,165`). Reject mixed prompt text or empty argv before prompting.
- Normalize inputs via a dedicated parser that returns structured results: `{mode: single, ids:[163]}` or `{mode: range, ids:[161,162,163,165]}`. Only if argv is empty should the interactive prompt run.
- Validate each id exists in TODO.md and pending_tasks before proceeding; fail fast with a status-marker-compliant error if any id is missing.

### Status-marker preflight
- Before dispatching research/planning work, set TODO status to `[IN PROGRESS]` with `Started` date, and mirror in `state.pending_tasks` (status `in_progress`, `started_at`). For already-started tasks, keep timestamps and ensure idempotent writes.
- When research completes, mark TODO status to `[RESEARCHED]` (or plan completion to `[PLANNED]`) with ISO8601 `Completed` timestamp, and update state: `pending_tasks.status = research_completed`, `research_completed_at` set, and `active_projects` entry updated with phase `research`, status `completed`/`researched`, `reports` array populated.
- Do not mutate `next_project_number` during research/planning.

### Lazy-creation guardrails
- No project roots or subdirectories are created during parsing, validation, or status-only updates. Only create `.opencode/specs/{id_slug}/reports/` (or `/plans/`) at the moment an artifact is written.
- Maintain incremental numbering for reports/plans; avoid speculative directory creation during dry-run/routing-check paths (now removed).
- Ensure preflight failures do not leave partially created directories.

### Routing and delegation expectations
- `/research` orchestrator should validate inputs, perform TODO/state preflight, then delegate to researcher agent with resolved ids; researcher writes reports and updates state/activities.
- `/plan` should mirror the same parser and preflight logic, then delegate to planner. Shared parser/utilities should live in a common module to avoid divergence.

## Recommended fixes

1) **Harden numeric/range parser**: Build a single parser used by both `/research` and `/plan` that:
   - Trims argv; if empty, prompt. If non-empty, attempt parse; on success, never prompt.
   - Supports `n`, `n-m`, and comma-separated lists; validates all tokens numeric; expands ranges; deduplicates.
   - Returns structured ids and mode; carries original string for logging.

2) **Preflight gating**: After parse, for each id:
   - Confirm presence in TODO and `pending_tasks`; if missing, return error without prompting.
   - Set TODO status to `[IN PROGRESS]` with `Started` date (if absent) before delegation; mirror state `pending_tasks` status to `in_progress`.

3) **Research/plan completion flow**:
   - On successful research: mark TODO `[RESEARCHED]` + ISO8601 `Completed`; set `pending_tasks.status = research_completed`, `research_completed_at` timestamp; add/update `active_projects` entry with phase `research`, status `completed`/`researched`, reports array; append recent activity.
   - On planning: mirror with `[PLANNED]`, `planned_at`, plans array.

4) **Lazy creation enforcement**:
   - Wrap artifact writes with a guard that creates project root + target subdir (`reports/` or `plans/`) only at write time; skip creation on validation failures.
   - Add regression tests/docs ensuring no directory creation occurs during parse/preflight failures.

5) **Docs and templates**:
   - Update `/command/research.md`, `/command/plan.md`, researcher/planner subagent docs, and standards to describe numeric/range acceptance, preflight sequencing, and lazy-creation rules.

## Relevant Resources

- Status markers: `.opencode/context/common/system/status-markers.md`  
- Artifact management & lazy creation: `.opencode/context/common/system/artifact-management.md`  
- Command/task standards: `.opencode/context/common/standards/commands.md`, `.opencode/context/common/standards/tasks.md`

## Recommendations

- Centralize numeric/range parsing in a shared utility used by `/research` and `/plan` to remove divergence.
- Enforce preflight status updates prior to delegation, with schema-aligned state writes and idempotent timestamps.
- Preserve lazy directory creation by gating all filesystem writes to artifact emission paths; add regression coverage and doc updates.

## Specialist Reports

- Web Research: (internal synthesis)
