---
task: 147 Ensure /task uses Lean subagents and MCP servers correctly
status: planning
phase: planning
type: implementation
effort: "2h"
priority: medium
lean: false
version: implementation-001
last_updated: 2025-12-22
research_inputs:
  - reports/research-001.md
artifacts:
  - plans/implementation-001.md
related_files:
  - .mcp.json
  - .opencode/context/core/standards/tasks.md
  - .opencode/context/core/system/artifact-management.md
---

# Implementation Plan: Ensure /task uses Lean subagents and MCP servers correctly

## Overview
System-level update so `/task` auto-detects Lean tasks (research vs implementation), routes to the correct Lean subagent, and validates required MCP servers (`lean-lsp`) with clear errors and lazy creation preserved (no FS writes on dry-runs/failed validation). Planned servers (`lean-explore`, `loogle`, `lean-search`) must warn/halt until configured. Documentation and standards must reflect routing, fallback, and dry-run expectations.

## Goals
- Auto-detect Lean intent and select the correct Lean research/implementation subagent without requiring `--lang lean` when Lean indicators are present.
- Validate Lean MCP servers against `.mcp.json` before dispatch; fail fast with actionable remediation for missing/unhealthy/planned servers.
- Preserve lazy artifact/directory creation; dry-run routing + MCP checks must not write to state, TODO, or create project directories.
- Update standards to document routing heuristics, MCP validation, fallback behaviors, and dry-run expectations.

## Deliverables
- Updated `.mcp.json` (if needed for validation metadata/flags) aligned with server validation rules.
- Updated `.opencode/context/core/standards/tasks.md` with Lean routing heuristics, subagent selection, and fallback guidance.
- Updated `.opencode/context/core/system/artifact-management.md` covering Lean MCP validation gating, dry-run behaviors, and lazy creation constraints.
- Dry-run playbook demonstrating correct routing/validation without creating project directories.

## Approach / Phases (1–2h scope)
1. **Routing heuristics & MCP validation design (0.5h)**
   - Extract Lean intent heuristics from TODO entries, file lists, research inputs, and plan metadata (`lean: true/false`).
   - Define binding rules: research -> Lean research subagent; implementation -> Lean implementation subagent; non-Lean unaffected.
   - Specify MCP health-check gating: handshake `lean-lsp` via `.mcp.json` before dispatch; planned servers warn/halt.
2. **Config + standards updates (1h)**
   - Add/adjust `.mcp.json` annotations if needed for server status (required vs planned) and validation expectations.
   - Update `tasks.md` with auto-detection heuristics, subagent selection matrix, MCP validation, and fallback behaviors.
   - Update `artifact-management.md` to require MCP health-check prior to creation, enforce lazy creation, and document dry-run expectations.
3. **Dry-run validation plan (0.5h)**
   - Define `/task` dry-run invocations (research + implementation) that report selected subagent and server health without FS writes.
   - Note expected outputs and remediation for missing/planned/unhealthy servers; ensure no state/TODO/project directory changes.

## Dependencies
- `.mcp.json` current server definitions (`lean-lsp` required; `lean-explore`/`loogle`/`lean-search` planned only).
- Task routing standards (`tasks.md`) and artifact/lazy-creation rules (`artifact-management.md`).
- Research report `reports/research-001.md` for MCP inventory, validation rules, and dry-run expectations.

## Risks & Mitigations
- **Dry-run writes state/dirs**: Explicitly gate FS writes until after MCP validation passes; document and test dry-run expectations.
- **Planned servers mistakenly used**: Mark planned servers as planned and warn/halt unless explicitly acknowledged; default to `lean-lsp` only.
- **Misclassification of Lean intent**: Use multiple heuristics (TODO keywords, affected files with `.lean`, plan metadata `lean:true`, user mode) with safe fallback to manual override.
- **Inconsistent standards**: Cross-reference tasks and artifact standards; keep examples aligned with routing matrix.

## Testing / Validation
- Dry-run routing checks (no FS writes):
  - `/task 147 --mode research --dry-run --check-mcp` → selects Lean research subagent, validates `lean-lsp`, reports status, no dirs/state/TODO changes.
  - `/task 147 --mode implement --dry-run --check-mcp --plan <existing-plan>` → selects Lean implementation subagent, validates `lean-lsp`, warns/halt for planned servers, no dirs/state/TODO changes.
- Negative cases: missing `lean-lsp` or non-zero handshake → clear error with remediation, no FS writes.
- Planned server requested → "planned/not configured" warning + halt unless user opts to proceed with available servers only.

## Acceptance Alignment
- Auto Lean subagent selection without manual flag using heuristics (TODO signals, file extensions, plan metadata).
- MCP server validation against `.mcp.json` with clear errors and planned-server warnings.
- Standards updated for routing/fallback and lazy creation/dry-run behaviors.
- Dry-run demonstrates correct routing/validation without creating project directories or touching state.

## Research Inputs
- `specs/147_ensure_task_uses_lean_subagents_and_mcp_servers_correctly/reports/research-001.md`

## Notes
- Preserve lazy creation: no project root/subdirs until an artifact write succeeds; dry-run must keep numbering/state untouched.
- Document plan reuse: if TODO links a plan, `/task` should reuse/update it in place; otherwise execute with lazy creation.
