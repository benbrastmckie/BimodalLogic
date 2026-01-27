# Implementation Plan: Task #691

- **Task**: 691 - improve_lean_lsp_mcp_agent_integration
- **Status**: [NOT STARTED]
- **Effort**: 2.5 hours
- **Priority**: High
- **Dependencies**: None
- **Research Inputs**: specs/691_improve_lean_lsp_mcp_agent_integration/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

The issue where Lean agents cannot access MCP tools is caused by known Claude Code platform bugs (#13898, #14496, #13605), not by project configuration. Custom subagents spawned via the Task tool cannot access project-scoped MCP servers (.mcp.json) but can access user-scoped servers (~/.claude.json). The solution is to migrate the lean-lsp MCP server to user scope while keeping project-level configuration for documentation purposes.

### Research Integration

Key findings from research-001.md:
- Custom subagents hallucinate results instead of making real MCP calls when using project-scoped servers
- User-scope MCP configuration is reliably inherited by subagents
- Current agent architecture is correct; the issue is a platform bug

## Goals & Non-Goals

**Goals**:
- Enable Lean agents (lean-research-agent, lean-implementation-agent) to reliably access lean-lsp MCP tools
- Document the workaround and its rationale for future maintainers
- Create a setup script for easy configuration on new machines
- Keep changes minimal and avoid unnecessary complexity

**Non-Goals**:
- Fixing the Claude Code platform bug (tracked upstream)
- Changing the agent architecture (already correct)
- Adding complex verification or monitoring systems

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| User-scope config not portable across machines | Medium | Medium | Create setup script; keep .mcp.json for documentation |
| Hardcoded project path in user config | Medium | High | Use setup script with path detection |
| Future Claude Code updates may change behavior | Low | Medium | Monitor release notes; test after updates |

## Implementation Phases

### Phase 1: Create Setup Script [NOT STARTED]

**Goal**: Create a script that configures lean-lsp in user scope with proper environment variables

**Tasks**:
- [ ] Create `.claude/scripts/setup-lean-mcp.sh` script
- [ ] Script should detect project path automatically
- [ ] Script should add lean-lsp to ~/.claude.json if not present
- [ ] Script should preserve existing ~/.claude.json content
- [ ] Add usage instructions in script header

**Timing**: 45 minutes

**Files to modify**:
- `.claude/scripts/setup-lean-mcp.sh` - Create new setup script

**Verification**:
- Script runs without error
- Running script adds lean-lsp to ~/.claude.json
- Existing ~/.claude.json content is preserved
- Script is idempotent (running twice produces same result)

---

### Phase 2: Update Documentation [NOT STARTED]

**Goal**: Document the workaround, rationale, and setup instructions

**Tasks**:
- [ ] Add "Known Issues" or "Troubleshooting" section to CLAUDE.md under Lean 4 Integration
- [ ] Document the Claude Code platform bugs by number
- [ ] Document the user-scope workaround with setup instructions
- [ ] Add note to .mcp.json explaining it's kept for documentation only
- [ ] Update lean-research-agent with brief note about MCP scope requirements
- [ ] Update lean-implementation-agent with same note

**Timing**: 45 minutes

**Files to modify**:
- `.claude/CLAUDE.md` - Add troubleshooting section
- `.mcp.json` - Add comment header explaining documentation purpose
- `.claude/agents/lean-research-agent.md` - Add MCP scope note
- `.claude/agents/lean-implementation-agent.md` - Add MCP scope note

**Verification**:
- CLAUDE.md contains clear troubleshooting instructions
- Setup script path is documented
- Agent files reference the known limitation

---

### Phase 3: Add Verification Command [NOT STARTED]

**Goal**: Create a simple command to verify MCP configuration is correct

**Tasks**:
- [ ] Create `.claude/scripts/verify-lean-mcp.sh` script
- [ ] Script should check if lean-lsp exists in user scope
- [ ] Script should verify project path matches current project
- [ ] Script should report clear pass/fail status

**Timing**: 30 minutes

**Files to modify**:
- `.claude/scripts/verify-lean-mcp.sh` - Create verification script

**Verification**:
- Script correctly detects configured lean-lsp
- Script correctly detects missing lean-lsp
- Script correctly detects path mismatch

---

### Phase 4: Test and Validate [NOT STARTED]

**Goal**: Verify the complete solution works end-to-end

**Tasks**:
- [ ] Run setup script to configure lean-lsp in user scope
- [ ] Verify with /mcp command that lean-lsp is available
- [ ] Test lean-research-agent with a simple research query
- [ ] Test lean-implementation-agent with a simple goal check
- [ ] Document test results

**Timing**: 30 minutes

**Files to modify**:
- None (testing only)

**Verification**:
- Agents can access MCP tools without hallucination
- lean_goal, lean_leansearch, and lean_loogle all return valid results
- No errors in Claude Code debug output

## Testing & Validation

- [ ] setup-lean-mcp.sh runs without error on clean ~/.claude.json
- [ ] setup-lean-mcp.sh preserves existing ~/.claude.json content
- [ ] verify-lean-mcp.sh correctly reports configuration status
- [ ] Lean agents can access MCP tools after setup
- [ ] Documentation is clear and actionable

## Artifacts & Outputs

- `.claude/scripts/setup-lean-mcp.sh` - Setup script for lean-lsp user scope configuration
- `.claude/scripts/verify-lean-mcp.sh` - Verification script for MCP configuration
- Updated `.claude/CLAUDE.md` with troubleshooting section
- Updated agent documentation with MCP scope notes

## Rollback/Contingency

If the workaround causes issues:
1. Remove lean-lsp from ~/.claude.json: `jq 'del(.mcpServers."lean-lsp")' ~/.claude.json > tmp && mv tmp ~/.claude.json`
2. Continue using .mcp.json (with the known subagent limitation)
3. Fall back to running MCP-dependent tasks in main conversation instead of subagents

When Claude Code fixes the platform bug:
1. Remove lean-lsp from user scope
2. Confirm project-scoped .mcp.json works with subagents
3. Update documentation to remove workaround notes
