# Implementation Summary: Task #729

**Completed**: 2026-01-28
**Duration**: ~45 minutes

## Changes Made

Prevented blocked MCP tool calls (`lean_diagnostic_messages`, `lean_file_outline`) in the agent system by:
1. Updating deprecated agent files to explicitly list blocked tools with warnings
2. Creating a centralized blocked-tools reference document
3. Enhancing the mcp-tools-guide.md blocked tools section
4. Making CLAUDE.md blocked tools warning more prominent
5. Auditing and updating remaining files with positive references

## Files Modified

- `.claude/agents/lean-research-agent.md` - Added BLOCKED TOOLS section, removed from Core Tools
- `.claude/agents/lean-implementation-agent.md` - Added BLOCKED TOOLS section, removed from Core Tools
- `.claude/context/core/patterns/blocked-mcp-tools.md` - **NEW FILE** - Authoritative blocked tools reference
- `.claude/context/project/lean4/tools/mcp-tools-guide.md` - Enhanced blocked tools warning, updated date
- `.claude/CLAUDE.md` - Expanded blocked tools section with table and CRITICAL warning
- `.claude/docs/guides/user-installation.md` - Removed positive references to blocked tools
- `.claude/context/core/patterns/mcp-tool-recovery.md` - Clarified blocked tool status in fallback table
- `.claude/skills/skill-lake-repair/SKILL.md` - Added explicit BLOCKED note in error handling

## Verification

- Grep for `lean_diagnostic_messages` in `.claude/`: All results are in warning/blocked context
- Grep for `lean_file_outline` in `.claude/`: All results are in warning/blocked context
- blocked-mcp-tools.md exists with both tool entries and bug references
- mcp-tools-guide.md has enhanced blocked tools warning at top
- Deprecated agent files list blocked tools prominently with NEVER USE warning

## Notes

- Documentation-only blocking remains inherently weak (no runtime enforcement)
- Bug references (lean-lsp-mcp #118, #115) included for future tracking
- When bugs are fixed upstream, unblocking procedure documented in blocked-mcp-tools.md
- All alternatives consistently documented: lean_goal/lake build for diagnostics, Read/lean_hover_info for outlines
