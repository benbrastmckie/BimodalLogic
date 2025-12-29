# Feature Registry

**Last Updated**: 2025-12-28
**Total Features**: 2 (routing & task execution)
**Status**: All features active and documented

## Routing & Task Execution

### /revise plan versioning guardrails (Tasks 144, 152, 154)
- **Status**: Active guardrail (tasks 144, 152 completed; task 154 abandoned after Branch B execution)
- **Description**: `/revise` mirrors `/add` and `/plan` guardrails: reuse the existing project directory, increment plan version in-place (`implementation-NNN.md`), and update TODO/state without altering task numbering or creating new project entries. Task 152 reversal used these guardrails to move command/meta docs back to YAML front matter and @subagent/XML markup per `.opencode/command/meta.md` and `.opencode/command/context.md`. Task 154 plan v2 applies the same guardrails to execute Branch B in Lean while retiring tasks 129/130.
- **Guardrails**:
  - No new project roots or numbering changes; plans stay in the task’s project folder.
  - Status markers and timestamps must align across TODO/state; phases reset to `[NOT STARTED]` in the new plan version.
  - Lean intent follows the task/plan metadata; language metadata remains authoritative in TODO.
- **Artifacts**: .opencode/specs/127_context_refactor/plans/implementation-002.md (plan v3 for task 144); .opencode/specs/152_standardize_command_templates_and_migrate_command_docs/plans/implementation-002.md (plan v2 for task 152); .opencode/specs/154_research_temporal_swap_strategy_for_truth_lean_supports_tasks_129_130/plans/implementation-002.md (plan v2 for task 154)
- **Related Standards**: .opencode/context/common/standards/tasks.md; .opencode/context/common/system/artifact-management.md; .opencode/context/common/system/status-markers.md

### /task Language-driven Lean routing (Task 147)
- **Status**: Completed and archived (2025-12-23)
- **Description**: `/task` now uses the TODO task `Language` metadata as the authoritative signal for Lean intent. When `Language: lean`, it routes to Lean research/implementation subagents; otherwise non-Lean. If `Language` is missing, the command warns and defaults to non-Lean unless the user supplies `--lang lean`.
- **Guardrails**:
  - Validate required MCP servers (at minimum `lean-lsp`) before dispatch; planned servers (`lean-explore`, `loogle`, `lean-search`) warn/halt unless explicitly allowed.
  - Preserve lazy creation: no project roots/subdirs/state writes on validation failure or `--dry-run` checks.
  - Prefer explicit user flag when it conflicts with TODO metadata; log the discrepancy.
- **Artifacts**: .opencode/specs/147_ensure_task_uses_lean_subagents_and_mcp_servers_correctly/plans/implementation-002.md
- **Related Standards**: .opencode/context/common/standards/tasks.md; .opencode/context/common/system/artifact-management.md; .opencode/context/common/system/status-markers.md
