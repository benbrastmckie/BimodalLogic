# Implementation Plan: Task #729

- **Task**: 729 - prevent_blocked_mcp_tool_calls_in_agents
- **Status**: [NOT STARTED]
- **Effort**: 2.5 hours
- **Priority**: High
- **Dependencies**: None
- **Research Inputs**: specs/729_prevent_blocked_mcp_tool_calls_in_agents/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Agents are still calling blocked MCP tools (`lean_diagnostic_messages`, `lean_file_outline`) despite multiple warning locations because (1) deprecated agent files still list them as available tools, (2) documentation is scattered and inconsistent, and (3) the mcp-tools-guide.md documents them in detail after stating they are blocked. This plan addresses all five prioritized recommendations from research, making the blocking documentation prominent, consistent, and centralized.

### Research Integration

Key findings from research-001.md:
- Root cause: Deprecated agent files list blocked tools as "Available Tools"
- The mcp-tools-guide.md creates confusion by documenting blocked tools in detail
- Documentation-only blocking is inherently weak but is the only option without Claude Code features
- Bug references: lean-lsp-mcp #118 (diagnostic_messages), #115 (file_outline)

## Goals & Non-Goals

**Goals**:
- Remove blocked tools from deprecated agent files
- Create a single, authoritative blocked-tools reference
- Make blocked tool warnings prominent in CLAUDE.md
- Remove detailed documentation for blocked tools from mcp-tools-guide.md
- Ensure all context files referencing these tools have appropriate warnings

**Non-Goals**:
- Implementing runtime tool blocking (requires Claude Code feature)
- Modifying MCP server configuration
- Deleting deprecated agent files entirely (preserve for reference)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Documentation-only blocking remains weak | Medium | High | Make warnings as prominent as possible; add bug references for tracking when issues are fixed |
| Deprecated files still loaded as context | Medium | Medium | Add prominent warnings at top of deprecated files in addition to removing blocked tools |
| Missing some file with positive tool reference | Low | Low | Phase 5 audit catches any missed files |

## Implementation Phases

### Phase 1: Fix Deprecated Agent Files [NOT STARTED]

**Goal**: Remove blocked tools from deprecated agent files that create conflicting signals.

**Tasks**:
- [ ] Edit `.claude/agents/lean-research-agent.md` to remove `lean_diagnostic_messages` and `lean_file_outline` from the Allowed Tools section
- [ ] Edit `.claude/agents/lean-implementation-agent.md` to remove `lean_diagnostic_messages` and `lean_file_outline` from the Allowed Tools section
- [ ] Add prominent note in both files that these tools are blocked

**Timing**: 30 minutes

**Files to modify**:
- `.claude/agents/lean-research-agent.md` - Remove lines 44-45 and 49 (blocked tools)
- `.claude/agents/lean-implementation-agent.md` - Remove lines 44-45 and 49 (blocked tools)

**Verification**:
- Grep for `lean_diagnostic_messages` in `.claude/agents/` returns no results in "Allowed Tools" sections
- Grep for `lean_file_outline` in `.claude/agents/` returns no results in "Allowed Tools" sections

---

### Phase 2: Create Blocked-Tools Reference [NOT STARTED]

**Goal**: Establish single authoritative reference for blocked MCP tools.

**Tasks**:
- [ ] Create `.claude/context/core/patterns/blocked-mcp-tools.md`
- [ ] Document both blocked tools with status, alternatives, and bug references
- [ ] Include clear explanation of why tools are blocked and what to use instead
- [ ] Add upstream bug tracking numbers for future cleanup

**Timing**: 30 minutes

**Files to modify**:
- `.claude/context/core/patterns/blocked-mcp-tools.md` - New file

**Verification**:
- File exists and contains both tool entries
- Bug references included for tracking when issues are resolved

---

### Phase 3: Update mcp-tools-guide.md [NOT STARTED]

**Goal**: Remove detailed documentation for blocked tools and strengthen warnings.

**Tasks**:
- [ ] Keep the "Blocked Tools" table at the top of the file
- [ ] Remove the detailed section for `lean_diagnostic_messages` (current lines ~54-68)
- [ ] Remove the detailed section for `lean_file_outline` (current lines ~126-136)
- [ ] Add reference to blocked-mcp-tools.md for blocked tool documentation
- [ ] Update Quick Reference table to note alternatives: `Check for errors | lake build (lean_diagnostic_messages BLOCKED)`

**Timing**: 30 minutes

**Files to modify**:
- `.claude/context/project/lean4/tools/mcp-tools-guide.md` - Remove blocked tool sections, add reference

**Verification**:
- File no longer contains detailed documentation for blocked tools
- Blocked tools table still present at top
- Reference to blocked-mcp-tools.md added

---

### Phase 4: Update CLAUDE.md Blocking Section [NOT STARTED]

**Goal**: Make blocked tool warning more prominent in the main configuration file.

**Tasks**:
- [ ] Expand "Blocked MCP Tools" section with stronger warning language
- [ ] Add "CRITICAL" or "NEVER CALL" prefix to make it stand out
- [ ] Add reference to blocked-mcp-tools.md for full details
- [ ] Ensure alternatives are clearly documented

**Timing**: 20 minutes

**Files to modify**:
- `.claude/CLAUDE.md` - Expand blocked tools section (lines ~112-113)

**Verification**:
- Blocked tools section uses prominent warning language
- Reference to detailed blocked-tools documentation included

---

### Phase 5: Audit and Update Remaining Files [NOT STARTED]

**Goal**: Ensure all other files referencing blocked tools have appropriate warnings.

**Tasks**:
- [ ] Check `.claude/docs/guides/user-installation.md` (lines 121, 224) - update installation testing to note blocked status
- [ ] Check `.claude/context/core/patterns/mcp-tool-recovery.md` - verify it documents blocked tools appropriately
- [ ] Check `.claude/context/project/lean4/agents/lean-implementation-flow.md` - verify fallback table is accurate
- [ ] Search for any other positive references to blocked tools and add warnings

**Timing**: 30 minutes

**Files to modify**:
- `.claude/docs/guides/user-installation.md` - Update blocked tool references
- Any other files found with positive references

**Verification**:
- Grep for `lean_diagnostic_messages` and `lean_file_outline` shows only warnings/blocked references
- No files suggest using these tools positively

---

### Phase 6: Documentation Cleanup [NOT STARTED]

**Goal**: Ensure consistency and add upstream tracking for future cleanup.

**Tasks**:
- [ ] Review all changes for consistency in warning language
- [ ] Ensure all blocked tool references include bug tracking numbers
- [ ] Update any cross-references between documentation files
- [ ] Verify all alternatives are documented consistently

**Timing**: 30 minutes

**Files to modify**:
- Review and minor edits to files from previous phases

**Verification**:
- All blocked tool warnings use consistent language
- Bug references (#118, #115) appear in relevant documentation
- Alternatives documented consistently across all files

---

## Testing & Validation

- [ ] Grep entire `.claude/` for `lean_diagnostic_messages` - all results should be in warning/blocked context
- [ ] Grep entire `.claude/` for `lean_file_outline` - all results should be in warning/blocked context
- [ ] Verify `.claude/context/core/patterns/blocked-mcp-tools.md` exists and is complete
- [ ] Verify mcp-tools-guide.md no longer has detailed blocked tool sections
- [ ] Verify deprecated agent files no longer list blocked tools as available

## Artifacts & Outputs

- `specs/729_prevent_blocked_mcp_tool_calls_in_agents/plans/implementation-001.md` (this file)
- `specs/729_prevent_blocked_mcp_tool_calls_in_agents/summaries/implementation-summary-YYYYMMDD.md` (on completion)
- `.claude/context/core/patterns/blocked-mcp-tools.md` (new file)

## Rollback/Contingency

All changes are documentation-only. If issues arise:
1. Revert via `git checkout HEAD~1 -- .claude/` to restore previous documentation state
2. Individual file reverts possible since changes are isolated to specific files
3. No runtime changes to undo
