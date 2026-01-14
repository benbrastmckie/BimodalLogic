# Plan: Fix /task status syncing to TODO and linked plan (Task 160)

- **Status**: [COMPLETED]
- **Started**: 2025-12-23T00:00:00Z
- **Completed**: 2025-12-24T00:30:00Z
- **lean**: false
- **Language**: markdown
- **Effort**: 2 hours
- **Priority**: Medium
- **Task ID**: 160

## Research Inputs
- none linked

## context
- /task command sometimes fails to write status updates to `.opencode/specs/TODO.md` and to linked plan phase markers.
- Needs atomic, parity-preserving updates without breaking lazy directory creation or numbering/state sync.
- Relevant files: `.opencode/command/task.md`, `.opencode/agent/subagents/task-executor.md`, standards in `context/core/standards/tasks.md`, `status-markers.md`, artifact management guidance, and shared state files.

## role
Planner coordinating fixes to /task status synchronization across TODO, state, and linked plans while honoring status-marker and lazy-creation standards.

## task
Deliver a fix plan that:
- Reproduces and patches the status sync failure so /task updates TODO and any linked plan phases atomically.
- Adds/updates tests or dry-run checks (if retained) to cover TODO/plan status-marker synchronization and prevent regressions.
- Preserves lazy directory creation and numbering/state consistency.
- Updates command/agent docs to reflect corrected sync behavior.

## workflow_execution
1) Reproduce & trace failure [COMPLETED]
(Started: 2025-12-23T00:00:00Z)
(Completed: 2025-12-24T00:10:00Z)
- Identify failing invocation patterns and confirm when TODO/plan diverge.
- Trace current /task flow (command + task-executor) for status writes, lock/atomic behavior, and marker formatting.
- Output: documented failure path and root-cause notes.

2) Implement atomic status sync fixes [COMPLETED]
(Started: 2025-12-24T00:10:00Z)
(Completed: 2025-12-24T00:20:00Z)
- Adjust /task command and task-executor to ensure ordered, atomic writes to TODO, state, and linked plan (phases) with consistent status markers.
- Harden lazy directory checks so no new roots/subdirs are created when only syncing status.
- Output: code changes plus updated status-marker handling for plan phases; ensure numbering/state remain consistent.

3) Tests and documentation updates [COMPLETED]
(Started: 2025-12-24T00:20:00Z)
(Completed: 2025-12-24T00:30:00Z)
- Add/adjust tests (or routing checks if tests unavailable) covering TODO/plan parity, atomic writes, and lazy-creation guardrails.
- Update `.opencode/command/task.md` and related agent docs to describe corrected behavior and guardrails.
- Output: test updates, doc updates, and brief changelog entry.

## routing_intelligence
- Lean intent: false (Language=markdown); no Lean routing required.
- Primary surfaces: `.opencode/command/task.md`, `.opencode/agent/subagents/task-executor.md`, standards (`tasks.md`, `status-markers.md`, `artifact-management.md`).
- Ensure plan/phase marker usage matches status-markers standard; keep TODO/state sync consistent.

## artifact_management
- Plan path: `.opencode/specs/160_fix_task_status_syncing_to_todo_and_linked_plan/plans/implementation-001.md`.
- Lazy creation: no additional dirs besides project root and plans/ (created by this plan write).
- Status markers: keep plan header [IN PROGRESS]; phases begin [NOT STARTED]; update when executing.
- When implementing, only create artifacts (tests/docs) where required; avoid unrelated directories.

## quality_standards
- Use status markers per `status-markers.md`; ensure atomic, parity-preserving updates across TODO/state/plan.
- Preserve numbering and Language metadata; no emojis.
- Tests/guards must cover lazy-creation behavior and status sync regression.

## usage_examples
- `/task 160` — executes with fixed status-sync behavior ensuring TODO and linked plan phases update atomically.

## validation
- Acceptance criteria for task 160 are addressed in phases 1–3 deliverables.
- Verify TODO/state/plan markers remain aligned after fix and tests pass.
