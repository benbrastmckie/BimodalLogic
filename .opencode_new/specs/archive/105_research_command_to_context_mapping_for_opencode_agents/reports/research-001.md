# Research Report: Command-to-Context Mapping for .opencode Agents
- **Task**: 105 - Research command-to-context mapping for .opencode agents
- **Status**: [COMPLETED]
- **Started**: 2025-12-22T10:00:00Z
- **Completed**: 2025-12-22T10:45:00Z
- **Effort**: 1.5 hours
- **Priority**: High
- **Dependencies**: None
- **Sources/Inputs**:
  - .opencode/command/*.md (research, plan, implement, review, revise, task, todo, add, context, document, refactor, meta)
  - .opencode/agent/subagents/*.md (implementation-orchestrator, implementer, refactorer, reviewer, planner, researcher, meta, task-adder, task-executor, documenter, context-refactor, context-references, batch-task-orchestrator, atomic-task-numberer)
  - .opencode/agent/subagents/specialists/*.md (scan for context references)
- **Artifacts**: .opencode/specs/105_research_command_to_context_mapping_for_opencode_agents/reports/research-001.md
- **Standards**: status-markers.md, artifact-management.md, tasks.md, report.md

## Executive Summary
- Cataloged all .opencode commands and agents; only commands declare explicit context loads, while most agents lack formal load lists.
- Found missing standards across lifecycle commands (e.g., status-markers, report/plan templates) and broad, potentially bloating loads (e.g., review pulls entire standards directory).
- Implement/plan/research commands omit key compliance files despite owning artifact writes; add/plan/research also lack status markers.
- Subagents that sync state (implementation-orchestrator, reviewer) reference standards indirectly but do not load them explicitly, creating risk of drift.
- Recommend a standardized, role-based context set and narrowing over-broad includes to reduce context size while enforcing required guardrails.

## Context & Scope
- Goal: map current command/agent context loading, identify gaps/redundancies, and propose improved context sets for each role.
- Scope: .opencode/command/* and .opencode/agent*/* entrypoints; focus on .opencode/context references and load ordering.
- Constraints: no code changes; lazy directory creation adhered to for this report; standards from report/status/tasks/artifact-management followed.

## Findings
- **Command context inventory** (ordered as loaded):
  - `research` loads TODO.md → state.json → state-schema → artifact-management → tasks → patterns → task-breakdown (`.opencode/command/research.md:11`). Missing status-markers, report standard.
  - `plan` loads TODO.md → state.json → state-schema → artifact-management → tasks → patterns → task-breakdown (`.opencode/command/plan.md:12`). Missing status-markers, plan/report templates.
  - `implement` loads code.md → patterns.md → task-breakdown → artifact-management → status-markers → TODO.md → state.json via `@context/...` shorthand (`.opencode/command/implement.md:12`). Missing tasks/state-schema; path shorthand may skip .opencode prefix.
  - `review` loads entire `@context/common/standards/` dir, state-schema, status-markers, tasks, artifact-management, project context, TODO/state, FEATURE_REGISTRY, IMPLEMENTATION_STATUS (`.opencode/command/review.md:12`). Broad include likely oversized.
  - `revise` loads TODO/state, tasks, artifact-management, state-schema, status-markers, project overview (`.opencode/command/revise.md:12`). Missing plan/report standards.
  - `task` loads TODO/state, state-schema, artifact-management, status-markers, tasks, patterns, task-breakdown (`.opencode/command/task.md:12`). Complete but could add project overview when syncing.
  - `todo` loads TODO/state/archive-state, tasks, artifact-management, state-schema, status-markers, project overview, FEATURE_REGISTRY, IMPLEMENTATION_STATUS (`.opencode/command/todo.md:12`). Coverage good; consider narrowing docs to relevant sections.
  - `add` loads TODO/state, state-schema, artifact-management, tasks, patterns (`.opencode/command/add.md:12`). Missing status-markers/task-breakdown for formatting enforcement.
  - `context` loads only context-guide.md (`.opencode/command/context.md:10`).
  - `document` loads documentation standard and project context (`.opencode/command/document.md:12`).
  - `refactor` loads code.md, patterns.md, project context (`.opencode/command/refactor.md:12`).
  - `meta` loads templates/, context-guide.md, patterns.md (`.opencode/command/meta.md:5`).
- **Agent context inventory**:
  - `implementation-orchestrator` explicitly loads delegation workflow (`@context/common/workflows/delegation.md`) and references status-markers for phase updates (`.opencode/agent/subagents/implementation-orchestrator.md:35,159`).
  - `implementer` loads code.md, patterns.md (listed twice), templates/ optionally (`.opencode/agent/subagents/implementer.md:54`).
  - `refactorer` loads code.md and patterns.md (`.opencode/agent/subagents/refactorer.md:55`).
  - `reviewer` lists tasks standard in context and passes it to todo-manager (`.opencode/agent/subagents/reviewer.md:33,145`).
  - `planner` references domain context from `@context/common/standards/`, task-breakdown.md, and project context for subagent routing, but not declared as loaded (`.opencode/agent/subagents/planner.md:80`).
  - `meta` subagent loads meta/orchestrator/subagent templates plus context-guide.md (`.opencode/agent/subagents/meta.md:48`).
  - Other subagents and specialists (researcher, documenter, task-adder, task-executor, batch-task-orchestrator, atomic-task-numberer, context-refactor, context-references, specialists/*) contain no explicit .opencode/context load lists; some mention guides in prose but do not formalize loads.
- **Gaps**:
  - Lifecycle commands (research, plan, add) omit status-markers; research/plan/revise omit report/plan standards; implement omits tasks/state-schema and uses shorthand pathing.
  - Agent orchestrators that mutate state (implementation-orchestrator, reviewer) do not explicitly load state-schema/status-markers/artifact-management, risking drift.
  - Over-broad loads (review pulls entire standards directory) increase context size; add/task lack task-breakdown for sizing consistency.
- **Redundancies**:
  - Implementer lists patterns twice (`.opencode/agent/subagents/implementer.md:54-56`).
  - Review command’s directory-wide include likely duplicates specific standards already listed later.

## Decisions
- Maintain current files unchanged; provide recommendations only.

## Recommendations
- **High**: Normalize lifecycle command contexts.
  - Add `status-markers.md` to research/plan/add; add `report.md` to research, `plan/report standards` to plan/revise; add `state-schema.md` and `tasks.md` to implement to align TODO/state updates.
  - Use explicit `.opencode/context/...` paths (avoid `@context/...` shorthand) for consistency.
- **High**: Right-size review context.
  - Replace directory-wide `@context/common/standards/` with targeted `tasks.md`, `status-markers.md`, `artifact-management.md`, `state-schema.md`, and keep project docs as needed to cut context bloat.
- **Medium**: Strengthen agent orchestrator loads.
  - Implementation-orchestrator and reviewer should explicitly load `state-schema.md`, `artifact-management.md`, `status-markers.md`, and `tasks.md` since they mutate plans/TODO/state.
  - Implementer/refactorer should dedupe patterns entry and ensure code/patterns/status markers when updating plans/TODO.
- **Low**: Clarify specialist defaults.
  - Documenter, researcher, task-adder/executor can declare minimal standards (tasks/status-markers for TODO edits; documentation.md for doc changes) to make expectations explicit without heavy loads.

## Risks & Mitigations
- **Context bloat** from broad includes (review): mitigate by narrowing to specific standards and project docs.
- **Non-compliant status handling** if status-markers absent: add to lifecycle commands and orchestrators to enforce markers/timestamps.
- **Schema drift** when state updates occur without state-schema/artifact-management loaded: ensure orchestrators load those standards.

## Appendix
- **Command load details**: research (`.opencode/command/research.md:11`), plan (`plan.md:12`), implement (`implement.md:12`), review (`review.md:12`), revise (`revise.md:12`), task (`task.md:12`), todo (`todo.md:12`), add (`add.md:12`), context (`context.md:10`), document (`document.md:12`), refactor (`refactor.md:12`), meta (`meta.md:5`).
- **Agent load details**: implementation-orchestrator (`implementation-orchestrator.md:35,159`), implementer (`implementer.md:54`), refactorer (`refactorer.md:55`), reviewer (`reviewer.md:33,145`), planner (`planner.md:80`), meta subagent (`meta.md:48`), others explicit load not present.
- **Observed redundancies**: duplicate patterns in implementer (`implementer.md:54-56`); review directory include (`review.md:12`).
