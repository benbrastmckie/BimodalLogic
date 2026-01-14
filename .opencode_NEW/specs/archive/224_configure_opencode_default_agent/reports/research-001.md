# Research Report: Configure OpenCode Default Agent Mode

**Task**: 224
**Date**: 2025-12-29
**Status**: Completed

## Executive Summary

This research investigated how to configure OpenCode to start in Orchestrator mode or automatically switch agent modes for workflow commands. After analyzing OpenCode's agent system, command routing, and the project's custom orchestrator implementation, I identified four potential solutions with varying levels of disruption and effectiveness.

The recommended solution is to use OpenCode's `default_agent` configuration option to set Orchestrator as the default primary agent on startup. This is the most elegant, minimally disruptive approach that follows OpenCode conventions and requires no breaking changes.

## Research Findings

### 1. OpenCode Agent System Architecture

OpenCode uses a two-tier agent system:

**Primary Agents**:
- Main assistants users interact with directly
- Switchable via Tab key or configured keybind
- Built-in agents: Build (default), Plan
- Can be configured via `opencode.json` or markdown files

**Subagents**:
- Specialized assistants invoked by primary agents or via @ mentions
- Built-in subagents: General, Explore
- Cannot be set as default agents (validation enforced)

**Agent Mode Configuration**:
- Agents have a `mode` property: "primary", "subagent", or "all"
- Only primary agents can be set as the default agent
- Default agent determined by `default_agent` config option

### 2. Default Agent Configuration

OpenCode provides a `default_agent` configuration option in `opencode.json`:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "default_agent": "orchestrator"
}
```

**Key Properties**:
- Must reference a primary agent (mode: "primary" or "all")
- Falls back to "build" if specified agent doesn't exist or is a subagent
- Applies across all interfaces: TUI, CLI, desktop app, GitHub Action
- Can be set globally (`~/.config/opencode/opencode.json`) or per-project

**Validation**:
- OpenCode validates that the specified agent exists
- OpenCode validates that the agent is a primary agent
- Warning issued if validation fails, fallback to "build"

### 3. Current Project Configuration

The ProofChecker project has:

**Orchestrator Agent** (`.opencode/agent/orchestrator.md`):
- Currently configured as mode: "all" (can be both primary and subagent)
- Comprehensive 13-stage workflow for delegation management
- Handles all workflow commands: /research, /implement, /plan, /review, etc.
- Language-based routing to specialized subagents

**Custom Commands** (`.opencode/command/*.md`):
- All commands specify `agent: orchestrator` in frontmatter
- Commands include: research, implement, plan, review, revise, task, todo, errors
- Commands use $ARGUMENTS for parameter passing

**Current Issue**:
- OpenCode defaults to "build" agent on startup
- Users must manually switch to orchestrator before running workflow commands
- Forgetting to switch can cause commands to execute in wrong agent context

### 4. Command Routing Mechanism

OpenCode's command system:

**Command Execution Flow**:
1. User types command (e.g., `/research 197`)
2. OpenCode loads command file from `.opencode/command/research.md`
3. OpenCode substitutes $ARGUMENTS with user input ("197")
4. Command specifies target agent in frontmatter (`agent: orchestrator`)
5. OpenCode routes to specified agent for execution

**Agent Specification in Commands**:
- Commands can specify `agent` property in frontmatter
- If agent is a subagent, command triggers subagent invocation
- If agent is primary, command switches to that agent
- `subtask: true` forces subagent invocation even for primary agents

**Current Behavior**:
- Commands specify `agent: orchestrator`
- If user is in "build" agent, command should route to orchestrator
- However, this routing may not be automatic if orchestrator is not a primary agent

### 5. Rules and Custom Instructions

OpenCode's rules system (`AGENTS.md` and `instructions` config):

**AGENTS.md Files**:
- Project-specific: `.opencode/AGENTS.md` or project root
- Global: `~/.config/opencode/AGENTS.md`
- Combined together when OpenCode starts
- Cannot enforce agent mode switching (informational only)

**Instructions Config**:
```json
{
  "instructions": ["CONTRIBUTING.md", "docs/guidelines.md"]
}
```
- Loads additional instruction files
- Combined with AGENTS.md
- Cannot enforce agent mode switching

**Limitations**:
- Rules are informational, not executable
- Cannot trigger automatic agent mode switches
- Cannot validate or enforce agent mode requirements

## Solution Analysis

### Solution 1: Configure Default Agent to Orchestrator

**Implementation**:
Add to `opencode.json`:
```json
{
  "$schema": "https://opencode.ai/config.json",
  "default_agent": "orchestrator"
}
```

Ensure orchestrator agent has `mode: "primary"` or `mode: "all"` in `.opencode/agent/orchestrator.md`:
```markdown
---
description: Central coordination and delegation management
mode: primary
---
```

**Pros**:
- Minimal configuration change (1 line in opencode.json)
- Uses official OpenCode feature designed for this purpose
- No breaking changes to existing workflows
- Works across all interfaces (TUI, CLI, desktop, GitHub Action)
- Follows OpenCode conventions and best practices
- Persistent across sessions
- Can be set globally or per-project

**Cons**:
- Requires orchestrator to be a primary agent (currently "all", which works)
- Users can still manually switch away from orchestrator
- Doesn't prevent execution in wrong agent if user switches

**Recommendation**: RECOMMENDED - This is the most elegant solution.

### Solution 2: Command-Level Agent Switching

**Implementation**:
Commands already specify `agent: orchestrator` in frontmatter. This should route to orchestrator when command is executed.

**Current Status**:
- All workflow commands already have `agent: orchestrator`
- OpenCode should automatically route to specified agent
- May already be working as intended

**Pros**:
- Already implemented in command files
- No additional configuration needed
- Commands always execute in correct agent context
- Works regardless of user's current agent

**Cons**:
- Relies on OpenCode's command routing behavior
- May not switch user's active agent (just executes in that context)
- User may not realize they're in wrong agent for manual interactions
- Unclear if this is fully automatic or requires user confirmation

**Recommendation**: VERIFY - Test if this already solves the problem.

### Solution 3: Subagent Invocation Mode

**Implementation**:
Add `subtask: true` to command frontmatter to force subagent invocation:
```markdown
---
name: research
agent: orchestrator
subtask: true
---
```

**Pros**:
- Forces command to invoke orchestrator as subagent
- Guaranteed execution in correct context
- No user interaction required
- Works even if orchestrator is not primary agent

**Cons**:
- Creates separate subagent session for each command
- May clutter session history with child sessions
- Doesn't change user's active agent
- More complex session navigation (parent/child cycles)
- Orchestrator would need mode: "subagent" or "all"

**Recommendation**: NOT RECOMMENDED - Adds unnecessary complexity.

### Solution 4: Custom Rules and Validation

**Implementation**:
Add validation rules to AGENTS.md:
```markdown
# Agent Mode Requirements

CRITICAL: Workflow commands (/research, /implement, /plan, /review) must be
executed in Orchestrator agent mode.

Before executing workflow commands:
1. Check current agent mode
2. If not Orchestrator, switch to Orchestrator
3. Then execute command
```

**Pros**:
- Documents expected behavior
- Provides guidance to users
- Can be shared across team

**Cons**:
- Rules are informational only, not enforced
- Cannot trigger automatic agent switches
- Relies on LLM interpreting and following rules
- No guarantee of compliance
- Not a technical solution

**Recommendation**: NOT RECOMMENDED - Insufficient enforcement.

## Recommended Solution

**Primary Recommendation**: Solution 1 - Configure Default Agent to Orchestrator

**Implementation Steps**:

1. Verify orchestrator agent mode in `.opencode/agent/orchestrator.md`:
   ```markdown
   ---
   description: Central coordination and delegation management
   mode: primary
   ---
   ```
   Current mode is "all" which works (can be both primary and subagent).

2. Add `default_agent` to `opencode.json`:
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

3. Test the configuration:
   - Restart OpenCode
   - Verify default agent is "orchestrator" (check indicator in lower right)
   - Run workflow commands: `/research`, `/implement`, `/plan`
   - Verify commands execute correctly

4. Optional: Document in AGENTS.md for team awareness:
   ```markdown
   # Default Agent Configuration

   This project uses Orchestrator as the default agent mode. OpenCode will start
   in Orchestrator mode automatically. All workflow commands (/research, /implement,
   /plan, /review) are designed to run in Orchestrator mode.

   To switch agents manually, use the Tab key.
   ```

**Secondary Recommendation**: Verify Solution 2 is Already Working

Before implementing Solution 1, test if command-level agent routing already solves the problem:

1. Start OpenCode in default "build" agent
2. Run a workflow command: `/research 197`
3. Observe if command automatically routes to orchestrator
4. Check if execution succeeds

If this works, Solution 1 may be unnecessary (though still recommended for better UX).

## Configuration Examples

### Example 1: Project-Specific Default Agent

`opencode.json` (project root):
```json
{
  "$schema": "https://opencode.ai/config.json",
  "default_agent": "orchestrator"
}
```

### Example 2: Global Default Agent

`~/.config/opencode/opencode.json`:
```json
{
  "$schema": "https://opencode.ai/config.json",
  "default_agent": "orchestrator"
}
```

### Example 3: Orchestrator as Primary Agent

`.opencode/agent/orchestrator.md`:
```markdown
---
description: Central coordination and delegation management
mode: primary
temperature: 0.3
model: anthropic/claude-sonnet-4-5
---

# Orchestrator Agent

Central coordinator routing user requests to appropriate subagents...
```

### Example 4: Command with Agent Specification

`.opencode/command/research.md`:
```markdown
---
name: research
agent: orchestrator
description: "Conduct research and create reports with [RESEARCHED] status"
---

**Task Input (required):** $ARGUMENTS
```

## Best Practices

1. **Use default_agent for startup behavior**: This is the official OpenCode mechanism for controlling default agent on startup.

2. **Keep orchestrator as mode: "all"**: This allows it to be both a primary agent (for default) and a subagent (for delegation).

3. **Specify agent in command frontmatter**: All workflow commands should specify `agent: orchestrator` for explicit routing.

4. **Document in AGENTS.md**: Inform team members about the default agent configuration and workflow expectations.

5. **Test across interfaces**: Verify default agent works in TUI, CLI, and other interfaces.

6. **Avoid subtask: true unless necessary**: Only use subagent invocation mode if you need separate session isolation.

## Potential Issues and Mitigations

### Issue 1: User Manually Switches Away from Orchestrator

**Problem**: User presses Tab and switches to "build" agent, then runs workflow command.

**Mitigation**: 
- Command-level agent routing should still work (commands specify `agent: orchestrator`)
- Document expected behavior in AGENTS.md
- Consider adding validation in orchestrator to detect wrong agent context

### Issue 2: Orchestrator Not Recognized as Primary Agent

**Problem**: OpenCode doesn't recognize orchestrator as valid primary agent.

**Mitigation**:
- Verify orchestrator.md has `mode: "primary"` or `mode: "all"`
- Check OpenCode logs for validation errors
- Ensure orchestrator.md is in correct location (`.opencode/agent/`)

### Issue 3: Global vs Project Config Conflict

**Problem**: Global config sets different default agent than project config.

**Mitigation**:
- Project config overrides global config (later configs override earlier)
- Set `default_agent` in project `opencode.json` for project-specific behavior
- Document in project README if different from global default

## Testing Plan

1. **Test Default Agent on Startup**:
   - Close OpenCode
   - Restart OpenCode in project directory
   - Verify agent indicator shows "orchestrator"
   - Verify Tab key cycles through primary agents including orchestrator

2. **Test Workflow Commands**:
   - Run `/research 197` from orchestrator agent
   - Verify command executes correctly
   - Run `/implement 196` from orchestrator agent
   - Verify command executes correctly

3. **Test Agent Switching**:
   - Switch to "build" agent via Tab key
   - Run `/research 197`
   - Verify command still routes to orchestrator (if command-level routing works)
   - Or verify error/warning if routing doesn't work

4. **Test Across Sessions**:
   - Close and restart OpenCode multiple times
   - Verify default agent persists as orchestrator
   - Verify no regression in existing workflows

## References

### OpenCode Documentation

1. **Agents**: https://opencode.ai/docs/agents/
   - Agent types (primary vs subagent)
   - Agent configuration options
   - Mode property and validation

2. **Config**: https://opencode.ai/docs/config/
   - default_agent configuration option
   - Agent-specific settings
   - Config file locations and precedence

3. **Commands**: https://opencode.ai/docs/commands/
   - Command frontmatter options
   - Agent specification in commands
   - Subtask mode for subagent invocation

4. **Rules**: https://opencode.ai/docs/rules/
   - AGENTS.md file format
   - Instructions configuration
   - Limitations of rules system

### Project Files

1. `.opencode/agent/orchestrator.md`: Orchestrator agent definition
2. `.opencode/command/research.md`: Research command with agent routing
3. `.opencode/command/implement.md`: Implementation command with agent routing
4. `opencode.json`: Project OpenCode configuration

## Conclusion

The recommended solution is to add `"default_agent": "orchestrator"` to the project's `opencode.json` configuration file. This is the most elegant, minimally disruptive approach that:

- Uses OpenCode's official default agent configuration mechanism
- Requires only a single line of configuration
- Works across all OpenCode interfaces
- Follows OpenCode conventions and best practices
- Provides persistent default agent behavior
- Allows users to still manually switch agents if needed

The orchestrator agent is already configured with `mode: "all"` which allows it to function as both a primary agent (for default startup) and a subagent (for delegation). All workflow commands already specify `agent: orchestrator` in their frontmatter, providing an additional layer of routing safety.

This solution addresses the core issue of users forgetting to switch to orchestrator mode while maintaining flexibility and following OpenCode's design patterns.
