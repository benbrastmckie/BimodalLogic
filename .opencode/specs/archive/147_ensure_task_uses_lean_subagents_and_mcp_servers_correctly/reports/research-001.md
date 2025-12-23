# Research Report: /task Lean Subagents & MCP Servers

## Metadata
- **Task**: 147 — Ensure /task uses Lean subagents and MCP servers correctly
- **Date**: 2025-12-22
- **Researcher**: subagents/researcher
- **Scope**: Lean task routing, MCP server validation, artifact/dry-run behaviors
- **Sources Reviewed**: `.mcp.json`, `.opencode/specs/TODO.md`, `.opencode/specs/state.json`, `.opencode/context/common/system/state-schema.md`, `.opencode/context/common/system/artifact-management.md`, `.opencode/context/common/standards/tasks.md`, `.opencode/context/common/standards/patterns.md`, `.opencode/context/common/workflows/task-breakdown.md`

## MCP Server Inventory & Validation Rules
- **Configured**: `lean-lsp` (stdio via `uvx lean-lsp-mcp`, env `LEAN_LOG_LEVEL=WARNING`, `LEAN_PROJECT_PATH=/home/benjamin/Documents/Philosophy/Projects/ProofChecker`). Treat this as required for all Lean tasks.
- **Planned (not present)**: `lean-explore`, `loogle`, `lean-search` — marked `_status: planned` with placeholder configs and unresolved research items; should surface a "planned/not configured" warning, not silently route.
- **Validation expectations**:
  - Resolve the requested Lean MCP server against `.mcp.json`; if missing/unreachable or the command exits non-zero, fail fast with an actionable error (install `lean-lsp-mcp` via `uvx`, set `LEAN_PROJECT_PATH`, provide API keys where required).
  - For health checks, attempt a lightweight handshake (spawn command in dry-run mode or version ping) before any artifact or directory creation.
  - When a planned server is requested, emit a warning and halt unless the user opts to proceed with only `lean-lsp`.

## /task Routing for Lean Work
- **Subagent selection**: Lean research requests must dispatch to the Lean research subagent; Lean implementation requests must dispatch to the Lean implementation subagent. Do not mix roles.
- **MCP binding**: Bind Lean tasks to the validated Lean MCP server set (at minimum `lean-lsp`); reject routing if required servers are absent/unhealthy.
- **Plan reuse**: If TODO entry links a plan, `/task` must reuse and update it in place; otherwise execute directly while respecting lazy creation. Status markers sync between plan/TODO/state per standards.
- **Lazy creation**: No project root or subdirs until the first artifact write. Dry-run/routing checks must avoid touching the filesystem and keep numbering/state untouched.

## Fallbacks & Error Handling
- Missing server: clear failure stating which server is missing, expected command (`uvx lean-lsp-mcp`), and remediation; avoid directory/state writes.
- Unreachable server: fail with logged stdout/stderr snippet (sanitized) and remediation steps; do not proceed to subagent dispatch.
- Planned servers requested: return "planned/not configured" warning with next actions (research/install) and allow user to rerun with available servers only.

## Dry-Run / Test Invocation (no directories created)
- Run `/task 147 --mode research --lang lean --dry-run --check-mcp` to verify: (1) Lean research subagent is selected, (2) `lean-lsp` handshake succeeds, (3) no project directories or state/TODO changes occur.
- For implementation mode: `/task 147 --mode implement --lang lean --dry-run --check-mcp --plan <existing-plan>` should route to the Lean implementation subagent and validate servers without filesystem writes.
- Observability: dry-run should report selected subagent, validated servers, and any remediation without creating `.opencode/specs/147_...` until an artifact is actually written.

## Documentation Updates Made
- Added Lean routing and MCP validation requirements to `.opencode/context/common/standards/tasks.md` (subagent selection, server validation, dry-run routing check).
- Added Lean routing + dry-run best practice to `.opencode/context/common/system/artifact-management.md` (validate `.mcp.json`, avoid filesystem changes on validation failure, keep lazy creation).

## Recommendations / Next Steps
- Implement automatic `lean-lsp` health ping used by `/task --check-mcp` before dispatch.
- Track planned servers (`lean-explore`, `loogle`, `lean-search`) as optional capabilities with explicit warnings until configured.
- Consider adding a short summary of Lean MCP defaults to user-facing help for `/task --lang lean`.
