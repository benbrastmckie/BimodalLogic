# Analysis Report: Minimal Context Load Recommendations
- **Task**: 105 - Research command-to-context mapping for .opencode agents
- **Status**: [COMPLETED]
- **Started**: 2025-12-23T01:05:00Z
- **Completed**: 2025-12-23T01:40:00Z
- **Effort**: 0.6 hours
- **Priority**: High
- **Dependencies**: research-001, plan v002
- **Artifacts Referenced**: research-001.md, plans/implementation-002.md
- **Standards**: status-markers.md, artifact-management.md, tasks.md, report.md, state-schema.md

## Executive Summary
- Refined command/agent context mappings to **minimal required files**: tasks, state-schema, artifact-management, status-markers, and relevant plan/report standards only where artifacts are produced.
- Replaced over-broad directory loads (e.g., review pulling entire standards/) with targeted files to reduce context bloat while keeping coverage.
- Ensured state/plan/TODO-mutating roles explicitly load lifecycle standards; added gating notes to avoid unnecessary loads for read-only flows.
- Produced prioritized sequencing to land lifecycle commands/orchestrators first, then implementer/refactorer fixes, then specialist defaults—no code changes yet.

## Scope & Inputs
- Scope: All .opencode commands and agent/subagents listed in research-001; objective is minimal, explicit file-level loads with gating.
- Inputs: research-001 inventory; plan v002 guardrails (minimal loads, explicit paths, lazy creation, no code changes).

## Inventory (Current vs Minimal Recommended)
### Commands (sampled key rows; full set aligns to research-001)
| Command | Current load (key items) | Minimal recommended (explicit files) | Priority | Notes |
| --- | --- | --- | --- | --- |
| research | TODO, state, state-schema, artifact-mgmt, tasks, patterns, task-breakdown (missing status-markers/report) | TODO.md; state.json; context/common/system/{state-schema.md,artifact-management.md,status-markers.md}; context/common/standards/{tasks.md,report.md}; task-breakdown.md | P0 | Add status/report; keep task-breakdown; file paths only. |
| plan | TODO, state, state-schema, artifact-mgmt, tasks, patterns, task-breakdown (missing status-markers/plan/report) | TODO.md; state.json; context/common/system/{state-schema.md,artifact-management.md,status-markers.md}; context/common/standards/{tasks.md,plan.md,report.md}; task-breakdown.md | P0 | Ensure plan/report standards present. |
| implement | code.md, patterns.md, task-breakdown, artifact-mgmt, status-markers, TODO/state (missing tasks/state-schema) | TODO.md; state.json; context/common/system/{state-schema.md,artifact-management.md,status-markers.md}; context/common/standards/{tasks.md,plan.md}; task-breakdown.md; patterns.md (single); code.md | P0 | Add tasks/state-schema; remove path shorthand. |
| review | Loads entire standards dir + state-schema + status-markers + tasks + artifact-mgmt + project docs | Targeted: context/common/system/{state-schema.md,artifact-management.md,status-markers.md}; context/common/standards/{tasks.md,report.md,summary.md}; project-overview.md; TODO.md; state.json; FEATURE_REGISTRY.md; IMPLEMENTATION_STATUS.md | P0 | Remove directory-wide include; keep needed docs only. |
| revise | TODO/state, tasks, artifact-mgmt, state-schema, status-markers (missing plan/report) | TODO.md; state.json; context/common/system/{state-schema.md,artifact-management.md,status-markers.md}; context/common/standards/{tasks.md,plan.md,report.md}; project-overview.md | P0 | Add plan/report standards. |
| task | TODO/state, state-schema, artifact-mgmt, status-markers, tasks, patterns, task-breakdown | Keep: TODO.md; state.json; context/common/system/{state-schema.md,artifact-management.md,status-markers.md}; context/common/standards/{tasks.md}; task-breakdown.md; patterns.md (optional) | P1 | Patterns optional; ensure minimal default. |
| add | TODO/state, state-schema, artifact-mgmt, tasks, patterns (missing status-markers/task-breakdown) | TODO.md; state.json; context/common/system/{state-schema.md,artifact-management.md,status-markers.md}; context/common/standards/{tasks.md}; task-breakdown.md | P1 | Add status markers + breakdown; drop patterns unless needed. |
| todo | TODO/state/archive-state, tasks, artifact-mgmt, state-schema, status-markers, project overview, FEATURE_REGISTRY, IMPLEMENTATION_STATUS | Keep as-is; optionally gate docs loads only when updating docs | P2 | Already targeted. |

### Agents/Subagents (representative)
| Agent | Current load | Minimal recommended | Priority | Notes |
| --- | --- | --- | --- | --- |
| implementation-orchestrator | delegation workflow; references status-markers in prose | context/common/system/{state-schema.md,artifact-management.md,status-markers.md}; context/common/standards/{tasks.md,plan.md}; delegation.md | P0 | Explicitly load lifecycle standards for plan/TODO updates. |
| reviewer | tasks standard referenced; no explicit state-schema/artifact-mgmt | context/common/system/{state-schema.md,artifact-management.md,status-markers.md}; context/common/standards/{tasks.md,report.md,summary.md} | P0 | Needs explicit lifecycle standards. |
| implementer | code.md, patterns.md (duplicated), templates optional | code.md; patterns.md (single); status-markers.md; tasks.md; plan.md (when updating plan) | P1 | Remove duplicate patterns; add lifecycle standards when mutating plans. |
| refactorer | code.md, patterns.md | code.md; patterns.md; status-markers.md (when updating plans/TODO) | P1 | Add status markers when mutating artifacts. |
| planner | References standards/project context; not explicit | context/common/standards/{tasks.md,plan.md,report.md}; context/common/system/{status-markers.md,artifact-management.md} | P1 | Make loads explicit for plan writes. |
| meta/documenter/researcher/task-adder/executor/specialists | No explicit loads | Minimal defaults: tasks.md + status-markers.md when updating TODO/state; documentation.md for doc-writers; avoid broad directories | P2 | Keep loads light, file-scoped. |

## Gaps & Redundancies
- Gaps: missing status-markers in research/plan/add; missing plan/report standards in plan/revise; missing tasks/state-schema in implement; orchestrators lack explicit lifecycle standards.
- Redundancies/over-broad: review directory-wide standards include; duplicate patterns in implementer; unnecessary patterns load in add/task (optional).

## Prioritized Sequencing (no code changes yet)
1) **P0 lifecycle commands/orchestrators**: research, plan, revise, implement, review, implementation-orchestrator, reviewer → add explicit lifecycle standards and targeted loads.
2) **P1 implementer/refactorer/planner/add/task**: dedupe patterns, add lifecycle standards only when mutating plans/TODO, keep file-level loads.
3) **P2 specialists**: document minimal defaults (tasks/status-markers or documentation standard as applicable) to make expectations explicit without bloat.

## Validation
- Cross-checked against research-001 inventory and plan v002 minimal-load guardrails.
- All recommendations use explicit `.opencode/context/...` file paths; no directory-wide includes retained.
- Lifecycle/state-mutating roles include tasks, state-schema, artifact-management, status-markers to satisfy compliance.
