# ProofChecker Development System

Task management and agent orchestration for Lean 4 theorem proving.

## Quick Reference

- **Task List**: @specs/TODO.md | **Machine State**: @specs/state.json | **Architecture**: @.claude/README.md

## Project Structure

Theories/ (Lean 4), docs/ (documentation), specs/ (task artifacts), .claude/ (configuration)

## Task Management

Status flow: `[NOT STARTED]` -> `[RESEARCHING]` -> `[RESEARCHED]` -> `[PLANNING]` -> `[PLANNED]` -> `[IMPLEMENTING]` -> `[COMPLETED]`
Terminal states: `[BLOCKED]`, `[ABANDONED]`, `[PARTIAL]`, `[EXPANDED]`

Artifacts: `specs/{N}_{SLUG}/reports/`, `plans/`, `summaries/`

## Commands

`/task`, `/research`, `/plan`, `/implement`, `/revise`, `/review`, `/todo`, `/errors`, `/meta`, `/learn`, `/lake`, `/lean`, `/refresh`

Full reference: @.claude/context/core/reference/command-reference.md

## State Synchronization

Update state.json first (machine state), then TODO.md (user-facing). See @.claude/context/core/reference/state-json-schema.md

## Git Commits

Format: `task {N}: {action}` with session ID in body, Co-Authored-By trailer.
See @.claude/rules/git-workflow.md

## Lean 4 Integration

### CRITICAL: Blocked MCP Tools

**DO NOT call**: `lean_diagnostic_messages` (hangs), `lean_file_outline` (unreliable)
Use `lean_goal` + `lake build` instead. See @.claude/context/core/patterns/blocked-mcp-tools.md

### MCP Tools

`lean_goal`, `lean_hover_info`, `lean_completions`, `lean_leansearch`, `lean_loogle`, `lean_leanfinder`, `lean_multi_attempt`, `lean_local_search`, `lean_state_search`, `lean_hammer_premise`

Configure: `.claude/scripts/setup-lean-mcp.sh`

## Skill-Agent Mapping

See @.claude/context/core/reference/skill-agent-mapping.md

## Rules (auto-applied by path)

- state-management.md (specs/**) | git-workflow.md | lean4.md (**/*.lean)
- error-handling.md (.claude/**) | artifact-formats.md (specs/**) | workflows.md (.claude/**)

## Context Discovery

**Machine-readable index**: `.claude/context/index.json` - Query with jq for dynamic context loading
**Human-readable index**: `.claude/context/index.md` - Browse available context files
**Query patterns**: `.claude/context/core/utils/index-query.md` - jq query examples

Common queries:
```bash
# Find context by agent
jq -r '.entries[] | select(.load_when.agents[]? == "AGENT") | .path' .claude/context/index.json

# Find context by language (lean, meta, latex, etc.)
jq -r '.entries[] | select(.load_when.languages[]? == "LANGUAGE") | .path' .claude/context/index.json
```

**Frequently used context** (load as needed):
- @.claude/context/project/lean4/tools/mcp-tools-guide.md
- @.claude/context/project/lean4/patterns/tactic-patterns.md
- @.claude/context/project/logic/domain/kripke-semantics-overview.md

## Error Handling

- **On failure**: Keep status, log to errors.json, preserve progress
- **On timeout**: Mark phase [PARTIAL], next /implement resumes
- **On MCP error**: Retry once, try alternative, continue with available info

## jq Command Safety

**Issue #1132**: `!=` operator gets escaped as `\!=`. Use `select(.type == "X" | not)` instead.

## Important Notes

- Update status BEFORE starting work (preflight) and AFTER completing (postflight)
- state.json = machine truth, TODO.md = user visibility
- Session ID format: `sess_{timestamp}_{random}`
