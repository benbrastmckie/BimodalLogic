---
task: 147 Ensure /task uses Lean subagents and MCP servers correctly
status: completed
phase: completed
type: implementation
effort: "2h"
priority: medium
lean: false
version: implementation-002
last_updated: 2025-12-23
started: 2025-12-23
completed: 2025-12-23
dependencies: []
research_inputs:
  - reports/research-001.md
artifacts:
  - plans/implementation-002.md
standards:
  - .opencode/context/common/standards/tasks.md
  - .opencode/context/common/system/artifact-management.md
  - .opencode/context/common/system/status-markers.md
---

# Implementation Plan (Revision): Route `/task` via Task `Language` metadata, not heuristics

## Delta from implementation-001
- Replace heuristic Lean intent detection with authoritative routing from the task's `Language` metadata in TODO.md (required by tasks.md).
- Keep MCP validation and lazy-creation guardrails unchanged; ensure routing respects `Language` even when heuristics disagree.
- Add fallbacks: if `Language` is missing, warn and default to non-Lean unless the user explicitly supplies `--lang lean`.

## Objectives
1) Use the TODO task `Language` field to select Lean research vs. Lean implementation subagents for `/task`.
2) Keep MCP validation (`lean-lsp` required; planned servers warn/halt) and lazy FS creation behavior intact.
3) Document the contract and dry-run expectations to align `/revise` with `/add` and `/plan` standards.

## Scope
- In-scope: `/task` routing logic, MCP validation gates, docs/standards alignment.
- Out-of-scope: Broader command refactors, non-Lean routing changes, new MCP servers.

## Deliverables
- Updated `/task` routing to use `Language` from TODO metadata (fallback to explicit flag if missing).
- Standards/docs updates describing the routing rule and fallback when `Language` is absent.
- Dry-run scenarios showing selected subagent + MCP check with no FS writes.

## Phases
### Phase 1: Routing rule update [NOT STARTED]
- Bind `/task` routing to the TODO task `Language` field: `lean` → Lean subagents; otherwise non-Lean.
- Keep mode split (research vs implementation) unchanged; only the language trigger changes.
- Add fallback: if `Language` missing/empty, emit warning and default to non-Lean unless user overrides.

### Phase 2: Validation & guardrails [NOT STARTED]
- Ensure MCP validation still runs before dispatch; no project dirs/state writes on validation failure/dry-run.
- Preserve lazy creation: no new roots/subdirs unless an artifact is emitted.
- Confirm planned servers (`lean-explore`, `loogle`, `lean-search`) warn/halt unless explicitly allowed.

### Phase 3: Docs & dry-run examples [NOT STARTED]
- Update standards/docs to state the Language-driven routing rule and fallback.
- Add dry-run examples: `/task <id> --mode research --dry-run --check-mcp` and `--mode implement` showing routing + MCP status, no FS writes.

## Risks & Mitigations
- Missing `Language` → Warn + default non-Lean; allow explicit `--lang lean` override.
- Divergent metadata vs user flag → Prefer explicit flag; log discrepancy and proceed with explicit flag.
- MCP outage → Fail fast with remediation; no FS writes.

## Validation
- Dry-run: `/task 147 --mode research --dry-run --check-mcp` → selects Lean research (because Language: markdown? ensure rule respects Language), validates `lean-lsp`, no FS writes.
- Dry-run: `/task 147 --mode implement --dry-run --check-mcp` with `--lang lean` override → selects Lean implementation, validates `lean-lsp`, no FS writes.
- Missing `Language` case: warning + non-Lean routing unless overridden; still no FS writes.
