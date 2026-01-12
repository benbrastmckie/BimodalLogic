# Implementation Plan: lean-lsp-mcp Integration for Claude Code System

**Task**: 218
**Version**: 005
**Date**: 2026-01-10
**Status**: [IN PROGRESS]
**Estimated Effort**: 1.5 hours
**Language**: meta
**Priority**: High

---

## Metadata

**Task Number**: 218
**Task Description**: Fix lean-lsp-mcp integration and ensure correct usage within Claude Code agent system
**Research Input**:
- Previous plans: implementation-004.md (OpenCode-focused, now outdated)
- Current skill files: .claude/skills/skill-lean-implementation/SKILL.md, skill-lean-research/SKILL.md
- Current MCP config: .mcp.json

**Previous Plan**: implementation-004.md
**Revision Reason**: Migrated from OpenCode (.opencode/) to Claude Code (.claude/) agent system. Need to ensure lean-lsp-mcp tools are correctly integrated and documented for systematic, efficient Lean implementation.

**Key Changes from v004**:
1. **Platform Change**: OpenCode → Claude Code
2. **Configuration**: opencode.json → .mcp.json (already correct)
3. **Skill System**: .opencode/agent/subagents/*.md → .claude/skills/*/SKILL.md (already migrated)
4. **Tool Naming**: Natural language instructions → Direct MCP tool calls (mcp__lean-lsp__*)
5. **Focus Shift**: Configuration setup → Verification and documentation of correct tool usage

### Previous Plan Status (v004 for OpenCode)
- Phase 1: [COMPLETED] - Created opencode.json (obsolete - not used by Claude Code)
- Phase 2: [COMPLETED] - Updated lean-implementation-agent.md (obsolete location)
- Phase 3: [COMPLETED] - Updated lean-research-agent.md (obsolete location)
- Phase 4: [COMPLETED] - Created MCP integration documentation (needs update)
- Phase 5: [COMPLETED] - Testing (needs re-verification in Claude Code)

**Current State Analysis**:
- `.mcp.json` is correctly configured for lean-lsp server
- `.claude/skills/skill-lean-implementation/SKILL.md` uses correct `mcp__lean-lsp__*` tool names
- `.claude/skills/skill-lean-research/SKILL.md` uses correct `mcp__lean-lsp__*` tool names
- `.claude/context/project/lean4/tools/mcp-tools-guide.md` still references old Python client approach

---

## Overview

### Problem Statement

Task 218's previous implementation (v004) was for OpenCode, which uses a different agent/skill architecture. The project has now migrated to Claude Code which:

1. **Uses direct MCP tool calls**: Tools are called as `mcp__lean-lsp__lean_goal`, not via Python wrappers
2. **Different skill format**: YAML frontmatter with `allowed-tools` field
3. **Different config location**: `.mcp.json` instead of `opencode.json`
4. **Claude-native integration**: MCP tools appear directly in Claude's tool list

The skills are already updated, but documentation needs alignment and verification is needed.

### Scope

**In Scope**:
- Verify current skill definitions correctly reference MCP tools
- Update MCP tools guide to remove obsolete Python client references
- Add Claude Code-specific MCP usage documentation
- Test lean-lsp-mcp tools work correctly in current setup
- Document correct tool usage patterns for systematic Lean implementation

**Out of Scope**:
- OpenCode configuration (deprecated)
- Python MCP client (not used by Claude Code)
- Adding new MCP servers

### Constraints

- Must work with Claude Code's native MCP support
- Must use `mcp__lean-lsp__*` tool naming convention
- Skills must declare MCP tools in `allowed-tools` field
- Documentation must reflect actual tool behavior

### Definition of Done

- [ ] Verify `.mcp.json` configuration is correct for Claude Code
- [ ] Verify `skill-lean-implementation/SKILL.md` has correct MCP tool references
- [ ] Verify `skill-lean-research/SKILL.md` has correct MCP tool references
- [ ] Update `mcp-tools-guide.md` to remove Python client references
- [ ] Add Claude Code-specific usage patterns to documentation
- [ ] Test MCP tools work correctly with a sample Lean file
- [ ] Document rate limits and best practices
- [ ] Remove or update obsolete OpenCode references

---

## Goals and Non-Goals

### Goals

1. **Verify correct tool integration**: Ensure MCP tools work as expected
2. **Update documentation**: Remove obsolete references, add Claude Code patterns
3. **Document best practices**: Rate limits, tool selection, error handling
4. **Validate workflow**: Test the full implementation cycle with MCP tools

### Non-Goals

1. **OpenCode support**: No longer maintaining OpenCode configuration
2. **Additional MCP servers**: Future enhancement
3. **Custom tool wrappers**: Using Claude Code's native MCP support

---

## Risks and Mitigations

### Risk 1: MCP Server Connection Issues

**Likelihood**: Low (already working)
**Impact**: High
**Mitigation**: Document troubleshooting steps, verify LEAN_PROJECT_PATH
**Contingency**: Fall back to `lake build` for compilation verification

### Risk 2: Rate Limiting Issues

**Likelihood**: Medium
**Impact**: Medium (search tools limited)
**Mitigation**: Document rate limits, recommend lean_local_search first
**Contingency**: Use web search as backup for Mathlib queries

### Risk 3: Documentation Staleness

**Likelihood**: Medium
**Impact**: Low
**Mitigation**: Single source of truth in SKILL.md files, minimal external docs
**Contingency**: Regular documentation reviews

---

## Implementation Phases

### Phase 1: Verify Current Configuration [COMPLETED]

**Estimated Effort**: 0.25 hours

**Objectives**:
- Verify `.mcp.json` is correctly configured
- Verify MCP server is accessible
- Test basic tool invocation

**Tasks**:
1. Check `.mcp.json` structure:
   - Verify `lean-lsp` server definition
   - Verify `command` is `uvx lean-lsp-mcp` or similar
   - Verify `LEAN_PROJECT_PATH` environment variable
2. Test MCP tool availability:
   - Try `mcp__lean-lsp__lean_local_search` with a simple query
   - Try `mcp__lean-lsp__lean_diagnostic_messages` on a Lean file
3. Document any issues found

**Acceptance Criteria**:
- MCP server starts successfully
- At least one tool call succeeds
- Configuration documented if changes needed

**Files to Review**:
- `.mcp.json`

---

### Phase 2: Verify Skill Definitions [COMPLETED]

**Estimated Effort**: 0.25 hours

**Objectives**:
- Ensure skill files have correct `allowed-tools` declarations
- Ensure tool names match MCP convention

**Tasks**:
1. Review `skill-lean-implementation/SKILL.md`:
   - Check `allowed-tools` includes all needed MCP tools
   - Verify tool names use `mcp__lean-lsp__*` prefix
   - Verify documentation matches tool behavior
2. Review `skill-lean-research/SKILL.md`:
   - Check search tools are declared
   - Verify rate limit documentation
3. Cross-reference with MCP server capabilities:
   - `lean_goal`, `lean_diagnostic_messages`, `lean_hover_info`, `lean_completions`
   - `lean_multi_attempt`, `lean_local_search`
   - `lean_leansearch`, `lean_loogle`, `lean_leanfinder`
   - `lean_build`, `lean_run_code`, `lean_file_outline`, `lean_term_goal`

**Acceptance Criteria**:
- All needed tools declared in skills
- Tool names are correct
- Documentation is accurate

**Files to Review**:
- `.claude/skills/skill-lean-implementation/SKILL.md`
- `.claude/skills/skill-lean-research/SKILL.md`

---

### Phase 3: Update MCP Tools Guide [COMPLETED]

**Estimated Effort**: 0.5 hours

**Objectives**:
- Remove obsolete Python client references
- Add Claude Code-specific usage patterns
- Document all available tools and their use cases

**Tasks**:
1. Update `.claude/context/project/lean4/tools/mcp-tools-guide.md`:
   - Remove Python import examples
   - Remove `invoke_mcp_tool()` references
   - Add Claude Code tool invocation patterns
   - Update tool naming to `mcp__lean-lsp__*`
   - Document rate limits for search tools
   - Add decision tree for tool selection
2. Add practical examples:
   - Example of using `lean_goal` to check proof state
   - Example of using `lean_diagnostic_messages` for verification
   - Example search workflow with `lean_local_search` → `lean_loogle`

**Acceptance Criteria**:
- No Python client references
- Claude Code tool patterns documented
- All tools described with use cases
- Rate limits clearly documented

**Files Modified**:
- `.claude/context/project/lean4/tools/mcp-tools-guide.md`

---

### Phase 4: Practical Verification [COMPLETED]

**Estimated Effort**: 0.25 hours

**Objectives**:
- Test MCP tools with real Lean code
- Verify the workflow described in documentation

**Tasks**:
1. Test with existing Lean file:
   - Use `lean_diagnostic_messages` to check a .lean file
   - Use `lean_goal` to check proof state at a specific line
   - Use `lean_hover_info` to get type information
2. Test search tools:
   - Use `lean_local_search` to find a local definition
   - Use `lean_loogle` with a type pattern (note rate limit)
3. Document actual behavior vs expected behavior
4. Note any discrepancies or issues

**Acceptance Criteria**:
- Core tools (goal, diagnostics, hover) work correctly
- Search tools work within rate limits
- Documentation matches actual behavior

**Files Used for Testing**:
- Any existing `.lean` file in Logos/

---

### Phase 5: Cleanup Obsolete References [COMPLETED]

**Estimated Effort**: 0.25 hours

**Objectives**:
- Remove or update obsolete OpenCode references
- Ensure consistency across documentation

**Tasks**:
1. Search for OpenCode references:
   - `grep -r "opencode" .claude/`
   - `grep -r "opencode.json" .`
2. Update or remove obsolete files:
   - If `.opencode/` directory exists, consider removal or archival
   - Update any cross-references in documentation
3. Update `mcp-tools-guide.md` implementation status:
   - Mark Phase 1 (Foundation) as complete for Claude Code
   - Update status of additional tools

**Acceptance Criteria**:
- No misleading OpenCode references in active docs
- Documentation reflects current system state

**Files to Check**:
- `.claude/context/` (all files)
- `.claude/rules/` (all files)

---

## Testing and Validation

### Tool Verification Matrix

| Tool | Test Command | Expected Result |
|------|--------------|-----------------|
| `lean_diagnostic_messages` | Check Logos/Shared/Formula.lean | Return diagnostics (errors, warnings, or empty) |
| `lean_goal` | Position in a proof | Return goal state or "no goals" |
| `lean_hover_info` | On a declaration | Return type signature and docstring |
| `lean_local_search` | Query "Frame" | Return local declarations matching |
| `lean_loogle` | Query "?a + ?b = ?b + ?a" | Return Mathlib theorems (rate limited) |
| `lean_leansearch` | Natural language query | Return relevant theorems (rate limited) |

### Integration Test

1. Open a task requiring Lean implementation
2. Use skill-lean-implementation to implement a simple theorem
3. Verify MCP tools are used correctly:
   - `lean_goal` checked proof state
   - `lean_diagnostic_messages` verified compilation
   - No `sorry` remaining

---

## Artifacts and Outputs

### Updated Documentation

1. **mcp-tools-guide.md**
   - **Location**: `.claude/context/project/lean4/tools/mcp-tools-guide.md`
   - **Changes**: Remove Python client, add Claude Code patterns
   - **Impact**: Accurate tool usage documentation

### Configuration Verification

1. **.mcp.json**
   - **Location**: Project root
   - **Status**: Verify correct, update if needed
   - **Content**: lean-lsp server definition

---

## Rollback/Contingency

### If MCP Tools Fail

1. **Immediate workaround**: Use `lake build` for compilation verification
2. **Investigation**: Check MCP server logs, LEAN_PROJECT_PATH
3. **Documentation**: Note issues in errors.json

### If Rate Limits Block Research

1. **Use lean_local_search**: No rate limit, fast
2. **Web search fallback**: Use WebSearch for Mathlib queries
3. **Cache results**: Note found theorems in research reports

---

## Dependencies

### External Dependencies

1. **lean-lsp-mcp**: MCP server for Lean LSP
   - **Installation**: `uvx lean-lsp-mcp` or `pipx run lean-lsp-mcp`
   - **Status**: Should be available

2. **Lean 4 + Lake**: For project compilation
   - **Status**: Already set up in project

### Internal Dependencies

1. **Skill definitions**: `.claude/skills/skill-lean-*/SKILL.md`
2. **MCP configuration**: `.mcp.json`

---

## Success Criteria

### Functional Success

- [ ] MCP server starts and responds to tool calls
- [ ] `lean_goal` returns proof state correctly
- [ ] `lean_diagnostic_messages` returns compilation errors
- [ ] `lean_hover_info` returns type information
- [ ] Search tools work within rate limits
- [ ] Skills can use MCP tools during implementation

### Documentation Success

- [ ] No Python client references in active documentation
- [ ] Claude Code tool patterns documented
- [ ] Rate limits clearly stated
- [ ] Decision tree for tool selection provided

### Integration Success

- [ ] A complete lean implementation can use MCP tools
- [ ] Errors are detected and reported correctly
- [ ] No fallback to lake build needed for simple checks

---

## Notes

### Claude Code vs OpenCode Architecture

| Aspect | OpenCode | Claude Code |
|--------|----------|-------------|
| Config file | `opencode.json` | `.mcp.json` |
| Skill location | `.opencode/agent/subagents/*.md` | `.claude/skills/*/SKILL.md` |
| Tool invocation | Natural language + config | Direct `mcp__server__tool` calls |
| Tool declaration | Per-agent in config | `allowed-tools` in SKILL.md |

### Available lean-lsp-mcp Tools

From the MCP server instructions at session start:

**Key Tools**:
- `lean_goal` - Proof state at position (use often!)
- `lean_diagnostic_messages` - Compiler errors/warnings
- `lean_hover_info` - Type signature + docs
- `lean_completions` - IDE autocomplete
- `lean_local_search` - Fast local declaration search
- `lean_multi_attempt` - Test tactics without editing
- `lean_file_outline` - Token-efficient file skeleton
- `lean_declaration_file` - Get declaration source
- `lean_run_code` - Run standalone snippet
- `lean_build` - Rebuild + restart LSP (slow)
- `lean_term_goal` - Expected type at position

**Search Tools (rate limited)**:
- `lean_leansearch` (3/30s) - Natural language → Mathlib
- `lean_loogle` (3/30s) - Type pattern → Mathlib
- `lean_leanfinder` (10/30s) - Semantic/conceptual search
- `lean_state_search` (3/30s) - Goal → closing lemmas
- `lean_hammer_premise` (3/30s) - Goal → premises for simp/aesop

### Search Decision Tree

1. "Does X exist locally?" → `lean_local_search`
2. "I need a lemma that says X" → `lean_leansearch`
3. "Find lemma with type pattern" → `lean_loogle`
4. "What's the Lean name for concept X?" → `lean_leanfinder`
5. "What closes this goal?" → `lean_state_search`
6. "What to feed simp?" → `lean_hammer_premise`

After finding a name: `lean_local_search` to verify, `lean_hover_info` for signature.

---

## References

### Current Configuration
- `.mcp.json` - MCP server configuration for Claude Code
- `.claude/skills/skill-lean-implementation/SKILL.md` - Lean implementation skill
- `.claude/skills/skill-lean-research/SKILL.md` - Lean research skill

### Documentation to Update
- `.claude/context/project/lean4/tools/mcp-tools-guide.md` - MCP tools guide

### Previous Plan
- `.claude/specs/218_fix_lean_lsp_mcp_integration/plans/implementation-004.md` - OpenCode plan (obsolete)

---

**Plan Version**: 005
**Created**: 2026-01-10
**Estimated Total Effort**: 1.5 hours
**Risk Level**: Low (verification and documentation)
**Complexity**: Low (mostly verification + doc updates)
