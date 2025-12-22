# Implementation Plan: TODO 105 - Research command-to-context mapping for .opencode agents

**Project**: #105  
**Version**: 001  
**Date**: 2025-12-22  
**Complexity**: Moderate

## Overview
Produce a non-code implementation plan that inventories all .opencode commands/agents with their current context load lists, recommends explicit `.opencode/context/` loads (with rationale), identifies gaps/redundancies, and delivers a prioritized loader improvement sequence (including context gating and coverage fixes). Follow the provided template, keep tasks time-boxed (1–2h each), and anchor all work to existing research.

## Research Inputs
- .opencode/specs/105_research_command_to_context_mapping_for_opencode_agents/reports/research-001.md (complete; no missing inputs)

## Prerequisites
- Source materials: `.opencode/command/*.md`, `.opencode/agent/**/*.md`, `.opencode/context/**/*`, `.opencode/specs/TODO.md`, `.opencode/specs/state.json`.
- Standards/workflows to reference: `.opencode/context/common/system/{state-schema.md,artifact-management.md,status-markers.md,context-guide.md}`, `.opencode/context/common/standards/{tasks.md,patterns.md,analysis.md,plan.md,report.md,documentation.md,summary.md,tests.md}`, `.opencode/context/common/workflows/{task-breakdown.md,delegation.md,review.md,sessions.md}`.
- Constraints: no code changes; use explicit `.opencode/context/...` paths (avoid `@context` shorthand); ensure lazy directory handling; reuse research-001 (no new research planned).

## Tasks by Phase (1–2h each, with dependencies, verification, priority)
- **Phase 0: Scope lock & checklist (1h, P0)**  
  **Action**: Re-read research-001; draft acceptance checklist mapping four criteria; confirm target paths and template sections.  
  **Depends on**: Research input.  
  **Verification**: Checklist exists and maps to inventory, recommendations, gap/redundancy fixes, and prioritized sequencing.

- **Phase 1: Current-state inventory refresh (commands/agents) (1–2h, P0)**  
  **Action**: Extract/confirm current context loads from `.opencode/command/*.md` and `.opencode/agent/**/*.md` (incl. specialists); capture ordering and path forms.  
  **Depends on**: Phase 0.  
  **Verification**: Inventory tables list every command/agent with current loads and source line refs; spot-check 3 entries against files.

- **Phase 2: Target mappings with rationale (commands first) (1–2h, P0)**  
  **Action**: For each command, propose recommended load set (explicit paths) with rationale tied to responsibilities (artifact writes, status/state updates); include context gating and coverage fixes.  
  **Depends on**: Phase 1.  
  **Verification**: Table rows show current vs recommended, rationale, and priority tag (P0/P1/P2); includes lifecycle additions (status-markers, plan/report standards, tasks/state-schema for implement) and review narrowing.

- **Phase 3: Target mappings with rationale (agents/subagents) (1–2h, P1)**  
  **Action**: For each agent/subagent (implementation-orchestrator, reviewer, implementer, refactorer, planner, meta, specialists), define recommended loads and dedupe guidance; ensure state-mutating roles load state-schema/artifact-management/status-markers/tasks.  
  **Depends on**: Phase 1.  
  **Verification**: Table rows for all agents with rationale and priority tags; includes deduping patterns for implementer and explicit loads for orchestrators.

- **Phase 4: Gap/redundancy analysis (1h, P0)**  
  **Action**: Summarize gaps (missing standards, schema/status coverage, shorthand path risks) and redundancies/over-broad includes (e.g., review standards dir, duplicate patterns).  
  **Depends on**: Phases 2–3.  
  **Verification**: Issue list cites file/line, classification (gap/redundancy), proposed fix, and priority.

- **Phase 5: Prioritized loader improvement sequencing (1h, P0)**  
  **Action**: Build ordered roadmap: P0 lifecycle commands + orchestrators, P1 implementer/refactorer adjustments, P2 specialist defaults. Include dependencies (e.g., add standards before narrowing loads) and context gating steps.  
  **Depends on**: Phase 4.  
  **Verification**: Sequenced list with dependency notes and expected outcomes; explicitly states "no code changes yet".

- **Phase 6: Validation & packaging (1h, P0)**  
  **Action**: Cross-check acceptance checklist; ensure artifacts reference `.opencode/context/`, `.opencode/command/`, `.opencode/agent/`, `.opencode/specs/state.json`; add verification steps to final tables; prepare delivery set.  
  **Depends on**: Phases 2–5.  
  **Verification**: Checklist fully satisfied; tables include verification columns; plan saved at required path.

## Testing/Validation Strategy
- **Completeness**: Validate every command/agent from research-001 appears in inventory and recommendation tables with priorities and rationale.
- **Coverage**: Ensure status-markers, artifact-management, tasks, and state-schema are included where state or artifacts are touched; remove/replace over-broad directory loads with targeted files.
- **Path accuracy**: Confirm explicit `.opencode/context/...` paths for all recommendations; note any shorthand to replace.
- **Acceptance alignment**: Use Phase 0 checklist to confirm four acceptance bullets are addressed and that sequencing is prioritized.

## Risks/Assumptions
- **Risks**: Repository drift since research-001; mis-prioritization leading to missed compliance; overlooking specialists lacking explicit loads.  
- **Mitigations**: Refresh inventory (Phase 1); tie priorities to impact/risk; include specialists in tables; keep "no code changes" guard noted.  
- **Assumptions**: Research-001 remains authoritative; repository layout unchanged; future implementation will update state.json/feature registries only after loader changes are approved.

## Deliverables
- Updated inventory tables (commands and agents) with current vs recommended context loads, priorities, and rationales.
- Gap/redundancy issue list with proposed fixes and priority.
- Prioritized loader improvement roadmap with sequencing steps (context gating and coverage fixes), no code changes executed.
- Validation checklist demonstrating acceptance criteria coverage and path accuracy.

## Estimates
- Phase 0: 1.0h  
- Phase 1: 1.5h  
- Phase 2: 1.5h  
- Phase 3: 1.5h  
- Phase 4: 1.0h  
- Phase 5: 1.0h  
- Phase 6: 1.0h  
**Total**: ~8.5h (moderate)

---
Plan Summary: Reuse research-001 to refresh inventories, craft recommended context load sets (with rationale and P0/P1/P2 tags), and document gaps/redundancies for all commands and agents. Deliver a prioritized, dependency-aware roadmap emphasizing lifecycle commands and orchestrators first, then implementer/refactorer, then specialists, with verification checklists and explicit path guidance. No new research or code changes are needed; focus on accurate mapping, context gating, and coverage fixes.
