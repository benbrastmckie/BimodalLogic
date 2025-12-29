# Implementation Plan: Configure OpenCode Default Agent to Orchestrator

## Metadata

- **Task**: 224 - Configure OpenCode to start in Orchestrator mode or auto-switch agent modes for workflow commands
- **Status**: [NOT STARTED]
- **Estimated Effort**: 2 hours
- **Language**: general
- **Priority**: Medium
- **Created**: 2025-12-29
- **Session**: sess_1735410000_cf8a2b
- **Research Integrated**: Yes (research-001.md)
- **Dependencies**: None
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**:
  - .opencode/context/common/standards/plan.md
  - .opencode/context/common/system/status-markers.md
  - .opencode/context/common/system/artifact-management.md
  - .opencode/context/common/standards/tasks.md
- **Lean Intent**: false

## Overview

### Problem Statement

OpenCode currently defaults to the "build" agent on startup. Users must manually switch to the "orchestrator" agent before running workflow commands (/research, /plan, /implement, /review), which can lead to commands being executed in the wrong agent context if users forget to switch. Research identified an official `default_agent` configuration option in opencode.json that sets the startup agent.

### Scope

This implementation will:
- Add `default_agent` configuration to opencode.json
- Verify orchestrator agent mode configuration
- Test default agent behavior across workflow commands
- Document the configuration for team awareness

### Constraints

- Must use official OpenCode configuration mechanisms
- Must not break existing workflows or commands
- Must work across all OpenCode interfaces (CLI, web, IDE)
- Must follow OpenCode conventions and best practices
- Must be minimally disruptive (no breaking changes)

### Definition of Done

- opencode.json contains `"default_agent": "orchestrator"` configuration
- Orchestrator agent configured with appropriate mode (primary or all)
- OpenCode starts in orchestrator mode by default
- All workflow commands execute correctly from orchestrator
- Configuration tested and verified working
- Team documentation updated

## Goals and Non-Goals

### Goals

- Configure OpenCode to start in orchestrator mode by default
- Use recommended Solution 1 from research (default_agent config)
- Verify orchestrator agent mode allows primary agent usage
- Test workflow commands execute correctly
- Document configuration for team

### Non-Goals

- Implementing command-level agent switching (already exists via frontmatter)
- Creating custom rules for agent validation (overkill for this use case)
- Preventing users from manually switching agents (flexibility preserved)
- Modifying subagent invocation patterns (workflow-specific, not needed)
- Adding automated agent mode enforcement (not required)

## Risks and Mitigations

### Risk 1: Orchestrator Not Recognized as Primary Agent
- **Likelihood**: Low (orchestrator already has mode: "all")
- **Impact**: High (default_agent config would fail)
- **Mitigation**: Verify orchestrator.md mode configuration before adding default_agent
- **Contingency**: Update orchestrator mode to "primary" if needed

### Risk 2: Breaking Existing Workflows
- **Likelihood**: Very Low (additive change only)
- **Impact**: High
- **Mitigation**: Test all workflow commands after configuration change
- **Contingency**: Remove default_agent config if issues arise

### Risk 3: Config Validation Failure
- **Likelihood**: Low
- **Impact**: Medium (falls back to "build" agent)
- **Mitigation**: Validate JSON syntax and agent name spelling
- **Contingency**: OpenCode automatically falls back to "build" if validation fails

### Risk 4: User Confusion from Changed Startup Behavior
- **Likelihood**: Medium
- **Impact**: Low
- **Mitigation**: Document change clearly in project documentation
- **Contingency**: Add note to AGENTS.md explaining default agent

## Implementation Phases

### Phase 1: Verify Orchestrator Agent Configuration [NOT STARTED]
**Estimated Effort**: 0.5 hours

**Objectives**:
- Verify orchestrator agent mode allows primary agent usage
- Confirm orchestrator.md configuration is correct
- Document current configuration

**Tasks**:
1. Read `.opencode/agent/orchestrator.md` to check mode configuration
2. Verify mode is set to "all" or "primary" (required for default_agent)
3. Verify orchestrator description and other metadata are correct
4. Document current mode setting
5. If mode is "subagent", update to "all" to allow both primary and subagent usage

**Acceptance Criteria**:
- Orchestrator mode is "all" or "primary"
- Orchestrator.md syntax is valid
- Mode allows orchestrator to be set as default agent
- Current configuration documented

**Dependencies**: None

### Phase 2: Add default_agent Configuration to opencode.json [NOT STARTED]
**Estimated Effort**: 0.5 hours

**Objectives**:
- Add default_agent configuration to opencode.json
- Maintain existing configuration (MCP, tools, agent settings)
- Validate JSON syntax

**Tasks**:
1. Read current opencode.json to understand existing configuration
2. Add `"default_agent": "orchestrator"` at root level of JSON
3. Preserve all existing configuration (mcp, tools, agent sections)
4. Validate JSON syntax with parser
5. Verify configuration follows OpenCode schema
6. Commit change with clear message

**Acceptance Criteria**:
- opencode.json contains `"default_agent": "orchestrator"` at root level
- All existing configuration preserved
- JSON syntax valid (verified with parser)
- Configuration follows OpenCode schema
- Commit created with descriptive message

**Dependencies**: Phase 1 (orchestrator mode verified)

### Phase 3: Test Default Agent Startup Behavior [NOT STARTED]
**Estimated Effort**: 0.5 hours

**Objectives**:
- Verify OpenCode starts in orchestrator mode
- Test agent switching still works
- Verify no regression in existing functionality

**Tasks**:
1. Restart OpenCode in project directory
2. Verify agent indicator shows "orchestrator" on startup
3. Test Tab key cycles through primary agents including orchestrator
4. Verify orchestrator is the default after restart
5. Test manual switching to "build" agent works
6. Test switching back to orchestrator works
7. Document startup behavior

**Acceptance Criteria**:
- OpenCode starts with orchestrator as active agent
- Agent indicator displays "orchestrator" on startup
- Tab key cycling works correctly
- Manual agent switching works in both directions
- No errors or warnings on startup
- Behavior consistent across restarts

**Dependencies**: Phase 2 (default_agent config added)

### Phase 4: Test Workflow Commands Execution [NOT STARTED]
**Estimated Effort**: 0.5 hours

**Objectives**:
- Verify all workflow commands execute correctly from orchestrator
- Test command routing works as expected
- Verify no regression in command functionality

**Tasks**:
1. Test `/research` command execution from orchestrator
2. Test `/plan` command execution from orchestrator
3. Test `/implement` command execution from orchestrator
4. Test `/review` command execution from orchestrator
5. Test `/task` command execution from orchestrator
6. Test `/todo` command execution from orchestrator
7. Verify all commands complete successfully
8. Verify command outputs are correct
9. Test command execution from "build" agent (verify routing still works)

**Acceptance Criteria**:
- All workflow commands execute successfully from orchestrator
- Command outputs are correct and complete
- No errors or warnings during command execution
- Commands still route correctly when executed from other agents
- No regression in command functionality
- Command-level agent routing (frontmatter) still works

**Dependencies**: Phase 3 (startup behavior verified)

## Testing and Validation

### Configuration Tests
- Verify opencode.json syntax is valid JSON
- Verify default_agent value matches orchestrator agent name exactly
- Verify orchestrator.md mode allows primary agent usage
- Verify no typos in agent name or configuration

### Startup Tests
- Restart OpenCode multiple times and verify orchestrator is default each time
- Verify agent indicator shows "orchestrator" on startup
- Verify Tab key cycling includes orchestrator
- Verify no errors or warnings in OpenCode logs

### Workflow Command Tests
- Execute `/research {task_number}` from orchestrator
- Execute `/plan {task_number}` from orchestrator
- Execute `/implement {task_number}` from orchestrator
- Execute `/review` from orchestrator
- Execute `/task` from orchestrator
- Execute `/todo` from orchestrator
- Verify all commands complete successfully

### Agent Switching Tests
- Switch from orchestrator to build agent manually
- Execute workflow command from build agent
- Verify command routes to orchestrator (frontmatter routing)
- Switch back to orchestrator manually
- Verify switching works in both directions

### Regression Tests
- Verify existing MCP configuration still works
- Verify lean-implementation-agent tools still accessible
- Verify lean-research-agent tools still accessible
- Verify no breaking changes to existing workflows

## Artifacts and Outputs

### Modified Files
- `opencode.json` (add default_agent configuration)
- `.opencode/agent/orchestrator.md` (potentially update mode if needed)

### Documentation Files
- `.opencode/AGENTS.md` (optional: document default agent behavior)
- Project README.md (optional: note about default agent)

### Implementation Artifacts
- `.opencode/specs/224_configure_opencode_default_agent/plans/implementation-001.md` (this file)
- `.opencode/specs/224_configure_opencode_default_agent/summaries/implementation-summary-20251229.md` (created on completion)

## Rollback/Contingency

### Rollback Plan
If default_agent configuration causes issues:
1. Remove `"default_agent": "orchestrator"` line from opencode.json
2. Restart OpenCode to revert to default "build" agent
3. Verify workflows still function correctly
4. Investigate root cause of failure
5. Revise configuration and retry

### Backup Strategy
- Git commit before making changes for easy rollback
- Keep backup copy of original opencode.json
- Document original configuration for reference
- Test in isolated session before committing

### Validation Gates
- Phase 1: Verify orchestrator mode before proceeding to Phase 2
- Phase 2: Validate JSON syntax before committing
- Phase 3: Verify startup behavior before proceeding to Phase 4
- Phase 4: Verify all commands work before marking complete

### Fallback Behavior
- OpenCode automatically falls back to "build" agent if default_agent validation fails
- Command-level agent routing (frontmatter) provides secondary routing mechanism
- Users can always manually switch agents if needed

## Notes

### Research Findings Integration

Research completed 2025-12-29 analyzing OpenCode agent system, command routing, and custom rules. Key findings:

**Solution Analysis**:
- Solution 1 (default_agent config): RECOMMENDED - 1 line change, official feature, minimal disruption
- Solution 2 (command-level routing): Already implemented via frontmatter `agent: orchestrator`
- Solution 3 (subagent invocation): Not recommended - adds unnecessary complexity
- Solution 4 (custom rules): Not recommended - informational only, no enforcement

**OpenCode Agent System**:
- Two-tier system: primary agents (user-facing) and subagents (specialized)
- Agents have mode property: "primary", "subagent", or "all"
- Only primary agents can be set as default_agent
- default_agent config validated on startup, falls back to "build" if invalid

**Current Project Configuration**:
- Orchestrator configured with mode: "all" (can be both primary and subagent)
- All workflow commands specify `agent: orchestrator` in frontmatter
- Commands use $ARGUMENTS for parameter passing
- Orchestrator handles 13-stage workflow for delegation management

**Recommended Solution**:
Add `"default_agent": "orchestrator"` to opencode.json root level. This is the most elegant, minimally disruptive solution that follows OpenCode conventions and works across CLI, web, and IDE interfaces.

### Configuration Example

```json
{
  "$schema": "https://opencode.ai/config.json",
  "default_agent": "orchestrator",
  "mcp": {
    "lean-lsp-mcp": {
      "type": "local",
      "command": ["npx", "-y", "lean-lsp-mcp"],
      "enabled": true,
      "environment": {
        "LEAN_PROJECT_ROOT": "{env:PWD}"
      },
      "timeout": 10000
    }
  },
  "tools": {
    "lean-lsp-mcp*": false
  },
  "agent": {
    "lean-implementation-agent": {
      "mode": "subagent",
      "tools": {
        "lean-lsp-mcp_diagnostic_messages": true,
        "lean-lsp-mcp_goal": true,
        "lean-lsp-mcp_build": true,
        "lean-lsp-mcp_run_code": true,
        "lean-lsp-mcp_hover_info": true,
        "lean-lsp-mcp_file_outline": true,
        "lean-lsp-mcp_term_goal": true
      }
    },
    "lean-research-agent": {
      "mode": "subagent",
      "tools": {
        "lean-lsp-mcp_loogle": true,
        "lean-lsp-mcp_leansearch": true,
        "lean-lsp-mcp_local_search": true,
        "lean-lsp-mcp_leanfinder": true,
        "lean-lsp-mcp_state_search": true
      }
    }
  }
}
```

### Best Practices

1. **Use default_agent for startup behavior**: Official OpenCode mechanism for controlling default agent
2. **Keep orchestrator as mode: "all"**: Allows both primary agent (for default) and subagent (for delegation)
3. **Specify agent in command frontmatter**: All workflow commands specify `agent: orchestrator` for explicit routing
4. **Document in AGENTS.md**: Inform team about default agent configuration
5. **Test across interfaces**: Verify default agent works in TUI, CLI, and other interfaces
6. **Avoid subtask: true unless necessary**: Only use subagent invocation mode for session isolation

### Future Enhancements

- Consider adding validation in orchestrator to detect wrong agent context
- Add note to AGENTS.md explaining default agent behavior
- Document agent switching workflow for team members
- Consider global config in ~/.config/opencode/opencode.json for user preference
