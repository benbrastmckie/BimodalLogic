# Research Report: Task #729

**Task**: 729 - prevent_blocked_mcp_tool_calls_in_agents
**Started**: 2026-01-28T12:00:00Z
**Completed**: 2026-01-28T12:30:00Z
**Effort**: Low-Medium (documentation updates, no code changes)
**Priority**: High (blocking tool calls cause hangs)
**Dependencies**: None
**Sources/Inputs**: Codebase analysis (.claude/ directory)
**Artifacts**: specs/729_prevent_blocked_mcp_tool_calls_in_agents/reports/research-001.md
**Standards**: report-format.md

## Executive Summary

- The hanging tool call in `.claude/output/research.md` shows Claude calling `lean_diagnostic_messages` (labeled "Diagnostics (MCP)") **directly from the main conversation context**, NOT from within a skill or agent
- **Root Cause**: The main Claude conversation has access to ALL MCP tools including the blocked ones. The "MCP Safety" warnings in commands only tell Claude not to call them, but don't actually prevent access
- **Gap Analysis**: Blocking documentation exists in CLAUDE.md, commands, and skills, but the deprecated agent files still LIST the blocked tools as "Available Tools", creating conflicting signals
- **Recommended Fix**: Remove blocked tools from deprecated agent files, add stronger warnings to mcp-tools-guide.md, and ensure the "Blocked Tools" warning is at the TOP of any tool listing

## Context & Scope

### Problem Statement
Agents/skills are still calling blocked MCP tools (`lean_diagnostic_messages`, `lean_file_outline`) despite multiple attempts to prevent this, causing hanging operations.

### Evidence of Issue
From `.claude/output/research.md` (lines 56-59):
```
lean-lsp - Diagnostics (MCP)(file_path: "/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Representation/UniversalCanonicalModel.lean")
```

This shows Claude directly calling the blocked tool during a `/research` command, despite the command file stating "MCP Safety: Do not call `lean_diagnostic_messages`".

## Findings

### 1. Current Blocking Documentation Locations

| Location | Type | Content |
|----------|------|---------|
| `.claude/CLAUDE.md` (L112-113) | Warning | "Blocked MCP Tools (DO NOT call directly)" |
| `.claude/commands/research.md` (L19) | Warning | "MCP Safety: Do not call..." |
| `.claude/commands/implement.md` (L19) | Warning | "MCP Safety: Do not call..." |
| `.claude/commands/lake.md` (L40) | Warning | "MCP Safety: Do not call..." |
| `.claude/skills/skill-lean-research/SKILL.md` (L14) | Warning | "Temporary Workaround: removed..." |
| `.claude/skills/skill-lean-implementation/SKILL.md` (L14) | Warning | "Temporary Workaround: removed..." |
| `.claude/skills/skill-lake-repair/SKILL.md` (L13) | Warning | "Temporary Workaround: removed..." |
| `.claude/rules/lean4.md` (L18) | Note | "BLOCKED (hangs indefinitely)" |
| `.claude/context/project/lean4/tools/mcp-tools-guide.md` (L11-12) | Table | "BLOCKED" status |

### 2. Conflicting Documentation (The Problem)

**Critical Issue**: The deprecated agent files STILL LIST blocked tools as "Available Tools":

| Location | Lines | Content |
|----------|-------|---------|
| `.claude/agents/lean-research-agent.md` | L44 | `mcp__lean-lsp__lean_diagnostic_messages` - Compiler errors/warnings |
| `.claude/agents/lean-research-agent.md` | L49 | `mcp__lean-lsp__lean_file_outline` - Token-efficient file skeleton |
| `.claude/agents/lean-implementation-agent.md` | L44 | `mcp__lean-lsp__lean_diagnostic_messages` - Compiler errors/warnings |
| `.claude/agents/lean-implementation-agent.md` | L49 | `mcp__lean-lsp__lean_file_outline` - Token-efficient file skeleton |

**Even though** these files have a deprecation notice at the top, the tool listings create confusing signals. If these files are ever loaded as context (e.g., someone looking for examples), Claude may see them as authoritative tool lists.

### 3. Why the Blocking Fails

**Root Cause**: MCP tool availability is determined by Claude Code's runtime configuration, NOT by documentation. The `.mcp.json` file provides all lean-lsp tools to Claude. Documentation can only ADVISE Claude not to call certain tools.

**Failure Mode**: When Claude is solving a problem, it sees the full tool palette. If the task involves "checking diagnostics" or "understanding file structure", Claude may naturally reach for `lean_diagnostic_messages` or `lean_file_outline` because they seem like the right tool for the job.

### 4. Skill Frontmatter `allowed-tools` Field

The skills DO use an `allowed-tools` frontmatter field that is supposed to restrict tool access:

- `skill-lean-research/SKILL.md`: Does NOT list `lean_diagnostic_messages` or `lean_file_outline`
- `skill-lean-implementation/SKILL.md`: Does NOT list `lean_diagnostic_messages` or `lean_file_outline`

However, the skill system may not enforce this at runtime - it appears to be advisory only.

### 5. MCP Tools Guide Issues

The `mcp-tools-guide.md` file has a "Blocked Tools" table at the top (L9-12), but then STILL documents the blocked tools in detail later in the file (L54-68 for `lean_diagnostic_messages`, L126-136 for `lean_file_outline`). This creates confusion.

## Decisions

1. The blocked tool documentation should be more prominent and consistent
2. Deprecated agent files should have their tool listings updated to remove blocked tools
3. The mcp-tools-guide.md should NOT document blocked tools in detail (moves them to an appendix or removes entirely)
4. Commands and skills should have a single source of truth for blocked tool list

## Recommendations

### Priority 1: Fix Deprecated Agent Files

Even though `lean-research-agent.md` and `lean-implementation-agent.md` are deprecated, they should be fixed to avoid confusion:

**Option A (Preferred)**: Remove the blocked tools from the "Allowed Tools" section entirely:
- Delete lines 44-45 and 49 from `lean-research-agent.md`
- Delete lines 44-45 and 49 from `lean-implementation-agent.md`

**Option B**: Move the deprecated files to an archive folder where they won't be loaded as context.

### Priority 2: Update mcp-tools-guide.md

Move or remove detailed documentation for blocked tools:
1. Keep the "Blocked Tools" table at the top
2. REMOVE the detailed sections for `lean_diagnostic_messages` (L54-68) and `lean_file_outline` (L126-136)
3. Add a note in the Quick Reference table: `Check for errors | lake build (lean_diagnostic_messages BLOCKED)`

### Priority 3: Add Explicit "DO NOT USE" Sections

In CLAUDE.md, make the blocked tools section more prominent:

```markdown
## CRITICAL: Blocked MCP Tools

**NEVER CALL THESE TOOLS** - they hang indefinitely:
- `mcp__lean-lsp__lean_diagnostic_messages` -> Use `lean_goal` or `lake build`
- `mcp__lean-lsp__lean_file_outline` -> Use `Read` + `lean_hover_info`

These tools are provided by the MCP server but are buggy. Do not call them under any circumstances.
```

### Priority 4: Create a Single Blocked-Tools Reference

Create `.claude/context/core/patterns/blocked-mcp-tools.md`:

```markdown
# Blocked MCP Tools

## Currently Blocked

| Tool | Status | Alternative | Bug Reference |
|------|--------|-------------|---------------|
| `lean_diagnostic_messages` | BLOCKED | `lean_goal` + `lake build` | lean-lsp-mcp #118 |
| `lean_file_outline` | BLOCKED | `Read` + `lean_hover_info` | lean-lsp-mcp #115 |

## Why These Are Blocked

These tools cause the lean-lsp MCP server to hang indefinitely. The bug is in the upstream lean-lsp-mcp package.

## What To Do Instead

### Instead of lean_diagnostic_messages
1. Use `lean_goal` at the relevant line to check proof state
2. Run `lake build` via Bash to get all compilation errors

### Instead of lean_file_outline
1. Use `Read` to get the full file content
2. Use `lean_hover_info` on specific symbols to understand structure
```

### Priority 5: Audit All Context Files

Search for any other files that might reference these tools positively:
- `.claude/context/project/lean4/agents/lean-implementation-flow.md` - Already checked, does not mention blocked tools
- `.claude/context/project/lean4/agents/lean-research-flow.md` - Already checked, does not mention blocked tools
- `.claude/docs/guides/user-installation.md` - Contains references at L121 and L224 (for installation testing)

## Risks & Mitigations

### Risk: Documentation-only blocking is inherently weak

**Mitigation**: Consider requesting a feature from Claude Code to support tool blocking in `.mcp.json` or project configuration. For now, make documentation as prominent and consistent as possible.

### Risk: Upstream lean-lsp-mcp bugs may be fixed

**Mitigation**: When bugs #118 and #115 are fixed, the blocking documentation can be removed. Add bug tracking numbers to all blocking documentation for easy cleanup.

### Risk: Skills frontmatter `allowed-tools` may not be enforced

**Mitigation**: Investigate whether Claude Code actually enforces the `allowed-tools` field or if it's purely advisory. If advisory, the documentation approach is the only option.

## Appendix

### Search Queries Used

- `lean_diagnostic_messages|lean_file_outline|diagnostic_messages|file_outline` in `.claude/`
- `lean_diagnostic|lean_file_outline|Diagnostics` in `.claude/`

### Files Containing References to Blocked Tools

1. `.claude/skills/skill-lean-research/SKILL.md` - Warning about blocked tools
2. `.claude/skills/skill-lean-implementation/SKILL.md` - Warning and fallback table
3. `.claude/skills/skill-lake-repair/SKILL.md` - Warning about blocked tools
4. `.claude/commands/implement.md` - MCP Safety warning
5. `.claude/commands/research.md` - MCP Safety warning
6. `.claude/commands/lake.md` - MCP Safety warning
7. `.claude/CLAUDE.md` - Blocked MCP Tools section
8. `.claude/agents/lean-research-agent.md` - **PROBLEM: Lists as available tool**
9. `.claude/agents/lean-implementation-agent.md` - **PROBLEM: Lists as available tool**
10. `.claude/rules/lean4.md` - Note about blocked status
11. `.claude/context/core/patterns/mcp-tool-recovery.md` - Fallback table
12. `.claude/context/project/lean4/agents/lean-implementation-flow.md` - Fallback table
13. `.claude/context/project/lean4/tools/mcp-tools-guide.md` - Blocked table and full documentation
14. `.claude/docs/guides/user-installation.md` - Installation testing instructions
