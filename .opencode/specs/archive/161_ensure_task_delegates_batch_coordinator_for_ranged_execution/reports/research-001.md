# Research: Ensure /task delegates batch coordinator for ranged execution (Task 161)

- **Status**: [COMPLETED]
- **Started**: 2025-12-24
- **Completed**: 2025-12-24
- **lean**: false
- **Language**: markdown
- **Task ID**: 161

## Research Inputs
- none linked

## context
- /task must detect ranged invocations (e.g., `101-105`, `101,103,105`) and delegate to the batch-task-orchestrator specialist for dependency analysis and wave-based execution.
- Must preserve status synchronization across TODO/state/plan links and respect lazy directory creation (no roots/subdirs unless writing artifacts).
- Dry-run/routing-check path should validate coordinator selection without creating artifacts or altering numbering/state.
- Key surfaces: `.opencode/command/task.md`, `.opencode/agent/subagents/task-executor.md`, `.opencode/agent/subagents/specialists/batch-task-orchestrator.md`, and standards (`tasks.md`, `commands.md`, `status-markers.md`, `artifact-management.md`, `patterns.md`).

## role
Researcher identifying required routing, dependency analysis, and status-sync behaviors for ranged /task execution with batch coordination.

## findings
1) **Range detection and parsing**: Implement explicit detection for numeric ranges and comma-separated lists before single-ID handling; normalize to an ordered, de-duped task list. Reject mixed-language or non-numeric tokens early with clear errors.
2) **Coordinator handoff contract**: /task command should delegate to batch-task-orchestrator with payload: normalized task list, dependency map (if present in TODO/state), and language metadata per task. Command should set TODO/state to `[IN PROGRESS]` before delegation but avoid creating project roots unless artifacts are emitted.
3) **Wave-based execution**: Batch coordinator must topologically sort tasks by dependencies, group independent tasks into waves, and execute in parallel where allowed. Failed tasks halt downstream dependents and surface a structured failure summary.
4) **Status synchronization**: For each task, enforce atomic updates to TODO/state and any linked plan phases during coordinator-driven transitions. Use status-markers standard; ensure parity between task-level status and plan phases (if plans exist).
5) **Lazy creation guardrails**: Routing checks/dry-runs must not create project directories. Artifact creation (reports/plans/summaries) is only permitted when execution writes outputs; ensure guards in both /task command and batch-task-orchestrator.
6) **Documentation and metadata**: Update command and subagent docs to declare batch delegation behavior, inputs/outputs, dependency handling, lazy-creation guarantees, and status-sync expectations. Align with patterns/commands/task standards.

## recommendations
- Add pre-routing parser in `/command/task.md` to classify invocation as single vs range/list; enforce numeric-only inputs with helpful errors.
- In `task-executor`, add a batch branch that calls `batch-task-orchestrator` with normalized tasks, dependency hints, and language metadata; keep single-task path unchanged.
- In `batch-task-orchestrator`, implement dependency graph construction, topo+wave scheduling, and per-task status-sync hooks that reuse the standard status update utilities to keep TODO/state/plan in lockstep.
- Add routing-check (or tests, depending on dry-run policy) that validates delegation without creating dirs/artifacts; ensure lazy-creation guards remain intact.
- Extend docs in `task.md`, `task-executor.md`, and `batch-task-orchestrator.md` to describe flow, guardrails, and failure reporting.

## next_steps
- Update parser/routing in /task command to detect ranges/lists and delegate to batch-task-orchestrator.
- Implement batch-task-orchestrator wave scheduler with dependency-aware ordering and per-task status-sync calls.
- Add tests/routing-checks covering range parsing, dependency-aware waves, lazy-creation guards, and status-marker parity.
- Refresh command/agent docs per standards (commands, tasks, patterns, artifact-management, status-markers).
