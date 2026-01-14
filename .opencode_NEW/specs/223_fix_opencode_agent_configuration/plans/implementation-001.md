# Implementation Plan: Fix opencode.json Agent Configuration

**Task**: 223  
**Version**: 001  
**Date**: 2025-12-28  
**Status**: [NOT STARTED]  
**Estimated Effort**: 0.25 hours (15 minutes)  
**Language**: json  
**Priority**: High  

---

## Metadata

**Task Number**: 223  
**Task Description**: Fix opencode.json agent configuration causing Lean agents to appear as primary agents instead of subagents  
**Research Input**: Research findings provided in task context (99% confidence root cause identified)  
**Complexity**: Trivial (single configuration field addition)  

**Key Research Findings**:
1. **Root Cause**: lean-implementation-agent and lean-research-agent defined in opencode.json "agent" section WITHOUT explicit `"mode": "subagent"` field
2. **Why This Happens**: OpenCode defaults missing mode to "all", which OVERRIDES markdown frontmatter `mode: subagent` settings
3. **Proof**: 100% correlation - ONLY these two agents (defined in opencode.json) appear in OpenCode's Tab cycle
4. **JSON Configuration Overrides Markdown**: When both exist, JSON takes precedence
5. **The Fix**: Add explicit `"mode": "subagent"` to both agent definitions in opencode.json (lines 17-38)

---

## Overview

### Problem Statement

The lean-implementation-agent and lean-research-agent are appearing as primary agents in OpenCode's Tab cycle, despite having `mode: subagent` in their markdown frontmatter. This causes confusion and clutters the primary agent interface.

**Root Cause Analysis**:
- Both agents are defined in `opencode.json` "agent" section (lines 17-38)
- Neither agent definition includes explicit `"mode": "subagent"` field
- OpenCode defaults missing mode to "all" (primary agent behavior)
- JSON configuration overrides markdown frontmatter when both exist
- Result: Agents appear in Tab cycle as primary agents

**Evidence**:
- ALL subagents have identical `mode: subagent` in markdown frontmatter
- ONLY lean-implementation-agent and lean-research-agent are defined in opencode.json
- ONLY these two agents appear in OpenCode's Tab cycle (100% correlation)
- Other subagents (researcher, planner, implementer, task-executor) do NOT appear in Tab cycle
- Conclusion: JSON configuration is overriding markdown frontmatter

### Scope

**In Scope**:
- Add `"mode": "subagent"` to lean-implementation-agent definition in opencode.json
- Add `"mode": "subagent"` to lean-research-agent definition in opencode.json
- Verify agents no longer appear in Tab cycle
- Verify agents still accessible via @ mention
- Verify lean-lsp-mcp tools still available to agents

**Out of Scope**:
- Modifying agent markdown frontmatter (already correct)
- Modifying other agent definitions (not affected)
- Changing MCP server configuration (working correctly)
- Changing tool enablement (working correctly)

### Constraints

- Must preserve existing MCP server configuration
- Must preserve existing tool enablement configuration
- Must not break agent functionality
- Must maintain JSON syntax validity
- Must not affect other agents

### Definition of Done

- [NOT STARTED] `"mode": "subagent"` added to lean-implementation-agent definition (line ~18)
- [NOT STARTED] `"mode": "subagent"` added to lean-research-agent definition (line ~29)
- [NOT STARTED] opencode.json validates as valid JSON
- [NOT STARTED] Agents no longer appear in OpenCode Tab cycle
- [NOT STARTED] Agents still accessible via @ mention
- [NOT STARTED] lean-lsp-mcp tools still available to agents when invoked

---

## Goals and Non-Goals

### Goals

1. **Fix agent classification** - Ensure Lean agents are recognized as subagents
2. **Remove from Tab cycle** - Eliminate clutter in primary agent interface
3. **Preserve functionality** - Maintain all existing agent capabilities
4. **Preserve tool access** - Ensure lean-lsp-mcp tools remain available

### Non-Goals

1. **Modify markdown frontmatter** - Already correct, no changes needed
2. **Refactor agent definitions** - Only add missing field
3. **Change MCP configuration** - Working correctly
4. **Modify other agents** - Not affected by this issue

---

## Risks and Mitigations

### Risk 1: JSON Syntax Error

**Likelihood**: Low  
**Impact**: High (breaks OpenCode configuration)  
**Mitigation**: Validate JSON syntax after modification using `jq` or JSON validator  
**Contingency**: Revert to previous version via git  

### Risk 2: Breaking Agent Functionality

**Likelihood**: Very Low  
**Impact**: Medium  
**Mitigation**: Test agent invocation via @ mention after change  
**Contingency**: Revert change if agents become inaccessible  

### Risk 3: Breaking MCP Tool Access

**Likelihood**: Very Low  
**Impact**: Medium  
**Mitigation**: Verify lean-lsp-mcp tools still available after change  
**Contingency**: Revert change if tools become unavailable  

---

## Implementation Phases

### Phase 1: Add mode Field to Agent Definitions [NOT STARTED]

**Estimated Effort**: 0.25 hours (15 minutes)

**Objectives**:
- Add `"mode": "subagent"` to lean-implementation-agent definition
- Add `"mode": "subagent"` to lean-research-agent definition
- Validate JSON syntax
- Test agent accessibility and functionality

**Tasks**:
1. Open `opencode.json` in editor
2. Locate lean-implementation-agent definition (line ~17-27)
3. Add `"mode": "subagent"` field after agent name, before tools section
4. Locate lean-research-agent definition (line ~28-37)
5. Add `"mode": "subagent"` field after agent name, before tools section
6. Validate JSON syntax: `jq . opencode.json > /dev/null`
7. Restart OpenCode or reload configuration
8. Test: Verify agents NOT in Tab cycle
9. Test: Verify agents accessible via @ mention
10. Test: Verify lean-lsp-mcp tools available when agents invoked

**Expected Changes**:

```json
"agent": {
  "lean-implementation-agent": {
    "mode": "subagent",  // ADD THIS LINE
    "tools": {
      "lean-lsp-mcp_diagnostic_messages": true,
      ...
    }
  },
  "lean-research-agent": {
    "mode": "subagent",  // ADD THIS LINE
    "tools": {
      "lean-lsp-mcp_loogle": true,
      ...
    }
  }
}
```

**Acceptance Criteria**:
- `"mode": "subagent"` added to both agent definitions
- JSON syntax valid (jq validation passes)
- Agents no longer appear in Tab cycle
- Agents accessible via @ mention
- lean-lsp-mcp tools available to agents
- No other configuration changed

**Files Modified**:
- `opencode.json` (2 lines added)

---

## Testing and Validation

### Unit Testing

**Not Applicable**: Configuration-only change, no code to unit test.

### Integration Testing

**Test 1: JSON Syntax Validation**
- **Objective**: Verify opencode.json is valid JSON after modification
- **Method**: Run `jq . opencode.json > /dev/null`
- **Expected**: Exit code 0 (valid JSON)
- **Validation**: No syntax errors reported

**Test 2: Agents Not in Tab Cycle**
- **Objective**: Verify Lean agents no longer appear in primary agent Tab cycle
- **Method**: Open OpenCode, press Tab repeatedly
- **Expected**: Only primary agents appear (orchestrator, etc.)
- **Validation**: lean-implementation-agent and lean-research-agent NOT in cycle

**Test 3: Agents Accessible via @ Mention**
- **Objective**: Verify Lean agents still accessible via @ mention
- **Method**: Type `@lean-implementation-agent` in OpenCode
- **Expected**: Agent appears in autocomplete and can be invoked
- **Validation**: Agent responds to invocation

**Test 4: MCP Tools Available**
- **Objective**: Verify lean-lsp-mcp tools still available to agents
- **Method**: Invoke lean-implementation-agent, check available tools
- **Expected**: 7 lean-lsp-mcp tools available (diagnostic_messages, goal, build, run_code, hover_info, file_outline, term_goal)
- **Validation**: Tools appear in agent's available tools list

**Test 5: Agent Functionality Preserved**
- **Objective**: Verify agents still function correctly
- **Method**: Invoke lean-implementation-agent with simple Lean task
- **Expected**: Agent executes task successfully using MCP tools
- **Validation**: Task completes without errors

### Performance Testing

**Not Applicable**: Configuration-only change, no performance impact expected.

---

## Artifacts and Outputs

### Configuration Artifacts

1. **opencode.json**
   - **Location**: `/home/benjamin/Projects/ProofChecker/opencode.json`
   - **Changes**: 2 lines added (`"mode": "subagent"` for each agent)
   - **Impact**: Lean agents classified as subagents, removed from Tab cycle

---

## Rollback/Contingency

### Rollback Plan

**If agents become inaccessible or non-functional**:

1. **Revert opencode.json**: `git checkout opencode.json`
2. **Restart OpenCode**: Reload configuration
3. **Verify functionality**: Test agent invocation
4. **Document failure**: Log failure reason and blockers

**Rollback Trigger**: Agents not accessible via @ mention after change

### Contingency Plan

**If mode field doesn't fix Tab cycle issue**:

1. **Investigate OpenCode configuration precedence**: Check if other config files override
2. **Check OpenCode version**: Verify mode field supported in current version
3. **Alternative approach**: Remove agent definitions from opencode.json entirely (rely on markdown frontmatter)
4. **Document limitation**: Note if OpenCode doesn't support mode field in JSON

**Contingency Trigger**: Agents still appear in Tab cycle after adding mode field

---

## Dependencies

### External Dependencies

1. **OpenCode**: CLI tool with agent configuration support
   - **Version**: Latest
   - **Status**: Installed
   - **Requirement**: Must support "mode" field in agent definitions

### Internal Dependencies

1. **opencode.json**: Existing configuration file with MCP server and agent definitions
2. **lean-implementation-agent.md**: Agent markdown file with correct frontmatter
3. **lean-research-agent.md**: Agent markdown file with correct frontmatter

---

## Success Criteria

### Functional Success

- [NOT STARTED] lean-implementation-agent has `"mode": "subagent"` in opencode.json
- [NOT STARTED] lean-research-agent has `"mode": "subagent"` in opencode.json
- [NOT STARTED] opencode.json validates as valid JSON
- [NOT STARTED] Lean agents NOT in OpenCode Tab cycle
- [NOT STARTED] Lean agents accessible via @ mention
- [NOT STARTED] lean-lsp-mcp tools available to agents
- [NOT STARTED] No other configuration changed

### Documentation Success

- [NOT STARTED] Change documented in git commit message
- [NOT STARTED] Root cause documented for future reference

---

## Notes

### Root Cause Summary

**Why This Happened**:
- OpenCode supports agent configuration in BOTH markdown frontmatter AND opencode.json
- When both exist, JSON configuration takes precedence
- Missing `"mode"` field in JSON defaults to "all" (primary agent)
- This overrides `mode: subagent` in markdown frontmatter

**Why Only Lean Agents Affected**:
- Only lean-implementation-agent and lean-research-agent are defined in opencode.json
- Other subagents (researcher, planner, implementer, task-executor) are NOT in opencode.json
- Therefore, other subagents use markdown frontmatter (which is correct)
- Lean agents use JSON configuration (which was missing mode field)

**Why Lean Agents in opencode.json**:
- Lean agents need selective MCP tool enablement (7-8 tools each)
- Tool enablement requires agent definition in opencode.json
- Adding agent to opencode.json requires ALL fields, including mode

### Configuration Precedence

OpenCode configuration precedence (highest to lowest):
1. **opencode.json agent definitions** (if present)
2. **Markdown frontmatter** (if no JSON definition)
3. **Default values** (if neither present)

**Lesson**: When adding agent to opencode.json for tool configuration, MUST include ALL fields from markdown frontmatter, especially `mode`.

### Future Prevention

**Best Practice**: When adding agent to opencode.json, always include:
- `"mode": "subagent"` (if subagent)
- All other fields from markdown frontmatter
- Document why agent is in JSON (e.g., tool enablement)

---

## References

### Research Context

- **Root Cause**: Provided in task context (99% confidence)
- **Evidence**: 100% correlation between JSON definition and Tab cycle appearance

### Configuration Files

- `opencode.json` - OpenCode configuration with MCP servers and agent definitions
- `.opencode/agent/subagents/lean-implementation-agent.md` - Agent markdown with correct frontmatter
- `.opencode/agent/subagents/lean-research-agent.md` - Agent markdown with correct frontmatter

---

**Plan Version**: 001  
**Created**: 2025-12-28  
**Estimated Total Effort**: 0.25 hours (15 minutes)  
**Risk Level**: Very Low (configuration-only, easily reversible)  
**Complexity**: Trivial (2-line addition)
