# [NOT STARTED] Implementation Plan (Revision 002): TODO 105 - Research command-to-context mapping for .opencode agents

**Project**: #105  
**Version**: 002  
**Date**: 2025-12-22  
**Revision Prompt**: "load just the context files that count to avoid context bloat"  
**Delta from v001**: Tighten recommendations to only essential context loads, add explicit gating to prevent over-broad directory pulls, and keep lazy creation/no-code change guardrails.

## Overview
Produce a refined, non-code plan to finalize command/agent context-load mappings with explicit minimal sets. Keep recommendations scoped to necessary standards (tasks, state-schema, artifact-management, status-markers, plan/report/summary standards) and avoid directory-wide includes. Maintain lazy directory creation and reuse research-001.

## Research Inputs
- .opencode/specs/105_research_command_to_context_mapping_for_opencode_agents/reports/research-001.md

## Prerequisites / Guardrails
- Source: `.opencode/command/*.md`, `.opencode/agent/**/*.md`, `.opencode/context/**/*`, `.opencode/specs/TODO.md`, `.opencode/specs/state.json`.
- Standards to load: `.opencode/context/common/system/{state-schema.md,artifact-management.md,status-markers.md}`, `.opencode/context/common/standards/{tasks.md,plan.md,report.md,summary.md}`, plus command-specific needs (patterns/tests/docs only where used).
- Constraints: No code changes; no new directories beyond existing project path; use explicit `.opencode/context/...` paths; favor file-level loads over directories.

## Tasks by Phase (1–2h each)
- **Phase 0: Scope lock & checklist (1h, P0)**
  - Action: Re-read research-001; draft acceptance checklist focused on minimal-load compliance, gating, and sequencing.
  - Verification: Checklist maps to inventory completeness, minimal recommended loads, gap/redundancy fixes, and prioritized sequencing.

- **Phase 1: Current-state inventory refresh (1–2h, P0)**
  - Action: Confirm current context loads for every command/agent (incl. specialists) with file/line refs; flag directory-wide loads.
  - Verification: Inventory table lists all entries with current loads and 3 spot checks.

- **Phase 2: Minimal target mappings for commands (1–2h, P0)**
  - Action: For each command, propose minimal recommended loads (only required standards/system files) with rationale and gating notes; remove over-broad directories.
  - Verification: Table shows current vs recommended, rationale, priority (P0/P1/P2), and gating flags.

- **Phase 3: Minimal target mappings for agents/subagents (1–2h, P1)**
  - Action: For orchestrators/implementer/reviewer/refactorer/planner/meta/specialists, define minimal loads and dedupe guidance; ensure state-mutating roles include tasks/state-schema/artifact-management/status-markers.
  - Verification: Table covers all agents with priorities and gating guidance.

- **Phase 4: Gap & redundancy analysis (1h, P0)**
  - Action: Summarize missing essentials (status-markers, plan/report standards, state-schema/tasks) and redundant/over-broad loads; propose fixes.
  - Verification: Issue list cites file/line, classification, fix, priority.

- **Phase 5: Prioritized sequencing (1h, P0)**
  - Action: Build ordered roadmap emphasizing lifecycle commands/orchestrators first, then implementer/refactorer, then specialists; include dependency/gating steps and "no code changes yet" note.
  - Verification: Sequenced list with dependencies and expected outcomes.

- **Phase 6: Validation & packaging (1h, P0)**
  - Action: Cross-check against acceptance checklist; ensure all recommendations use explicit file paths and minimal sets; package tables.
  - Verification: Checklist satisfied; tables show verification columns; plan saved here.

## Testing/Validation Strategy
- Completeness: Every command/agent from research-001 present with priorities and rationale.
- Coverage: State/artifact-touching roles include tasks, state-schema, artifact-management, status-markers; avoid directory-wide includes.
- Path accuracy: All recommendations use explicit `.opencode/context/...` file paths; note any shorthand to replace.
- Acceptance alignment: Checklist confirms minimal loads, gating, gap fixes, and sequencing are addressed.

## Risks/Assumptions
- Risks: Repository drift since research-001; over-pruning missing a required file.
- Mitigations: Spot-check current loads; require rationale for removals; keep P1/P2 tags for lower-risk pruning.
- Assumptions: No new research required; repository layout unchanged; implementation will update loaders separately.

## Deliverables
- Updated inventory tables (commands + agents) with current vs minimal recommended loads, rationale, priorities, and gating flags.
- Gap/redundancy issue list with fixes and priorities.
- Sequenced loader improvement roadmap (no code changes), emphasizing minimal necessary loads and context gating.
- Validation checklist demonstrating acceptance coverage and path accuracy.
