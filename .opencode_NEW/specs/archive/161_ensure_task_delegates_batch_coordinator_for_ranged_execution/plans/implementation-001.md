# Plan: Ensure /task delegates batch coordinator for ranged execution (Task 161)

- **Status**: [COMPLETED]
- **Started**: 2025-12-24
- **Completed**: 2025-12-24
- **lean**: false
- **Language**: markdown
- **Effort**: 2 hours
- **Priority**: Medium
- **Task ID**: 161

## Research Inputs
- [specs/161_ensure_task_delegates_batch_coordinator_for_ranged_execution/reports/research-001.md](../reports/research-001.md)

## context
- /task must detect ranges/lists and delegate to batch-task-orchestrator for dependency-aware, wave-based execution while keeping status markers in sync across TODO/state/plan.
- Lazy creation: no project roots/subdirs beyond reports/ (existing) and plans/ (this write) unless emitting artifacts; routing checks must not create dirs.
- Key files: `.opencode/command/task.md`, `.opencode/agent/subagents/task-executor.md`, `.opencode/agent/subagents/specialists/batch-task-orchestrator.md`, standards (`tasks.md`, `commands.md`, `status-markers.md`, `artifact-management.md`, `patterns.md`).

## role
Planner defining implementation steps to add robust range parsing, batch delegation, dependency-aware wave execution, and atomic status synchronization for /task ranged invocations.

## task
Implement range/list handling and batch delegation for /task, ensuring dependency-aware scheduling, atomic TODO/state/plan status sync, lazy-creation guardrails, and documentation/testing coverage.

## workflow_execution
1) Parser and routing enhancements [COMPLETED]
(Started: 2025-12-24T00:45:00Z)
(Completed: 2025-12-24T00:55:00Z)
- Add range/list detection and normalization (ordered, de-duped) before single-task handling; enforce numeric-only tokens with clear errors.
- Ensure Language metadata travels per task; preserve existing single-task path behavior.
- Output: updated `/command/task.md` routing path and parser helpers.

2) Batch delegation and wave scheduler [COMPLETED]
(Started: 2025-12-24T00:55:00Z)
(Completed: 2025-12-24T01:05:00Z)
- In `task-executor`, add branch to call `batch-task-orchestrator` with normalized tasks, dependency hints, and language metadata.
- In `batch-task-orchestrator`, build dependency graph, perform topo + wave grouping, execute waves in parallel where allowed; stop dependents on failures and emit structured failure summaries.
- Output: updated executor + orchestrator with dependency-aware wave scheduling.

3) Status synchronization and lazy-creation guards [COMPLETED]
(Started: 2025-12-24T01:05:00Z)
(Completed: 2025-12-24T01:10:00Z)
- Reuse standard status update utilities to atomically sync TODO/state/plan for each task transition during batch execution.
- Ensure routing-check/tests do not create project directories; artifact writes only when producing outputs.
- Output: status-sync hooks and lazy-creation guards validated.

4) Tests and documentation [COMPLETED]
(Started: 2025-12-24T01:10:00Z)
(Completed: 2025-12-24T01:15:00Z)
- Add tests or routing-check coverage for range parsing, dependency-aware waves, status-marker parity, and lazy-creation guardrails.
- Update docs: `task.md`, `task-executor.md`, `batch-task-orchestrator.md` to describe flow, inputs/outputs, guardrails, and failure reporting per standards.
- Output: tests/docs updated; guidance aligned with standards.

## routing_intelligence
- Lean intent: false (Language=markdown in TODO); no Lean contexts needed.
- Delegation: planner -> implementation agents will touch command, executor, and batch-task-orchestrator per standards.
- Preserve numbering/state consistency; maintain Language metadata in all updates.

## artifact_management
- Plan path: `specs/161_ensure_task_delegates_batch_coordinator_for_ranged_execution/plans/implementation-001.md`.
- Lazy creation: only project root and plans/ (this write); no summaries/reports created here.
- Status markers: plan header [IN PROGRESS]; phases start [NOT STARTED]; update when executing phases.

## quality_standards
- Follow `status-markers.md`, `artifact-management.md`, and command/task standards; no emojis.
- Ensure atomic status sync and lazy-creation adherence across flows and tests.

## usage_examples
- `/task 101-105` — parsed to range, delegated to batch-task-orchestrator with dependency-aware waves and status-sync.
- `/task 101,103,105 --lang markdown` — list parsed, normalized, and delegated with language metadata.

## validation
- Acceptance criteria for task 161 mapped to phases 1–4: parsing/routing, batch delegation and waves, status sync + lazy-creation guards, tests/docs.
- Verify TODO/state/plan parity after execution; ensure routing-check/tests do not create dirs when not emitting artifacts.
