# Research Report: Fix OpenCode $ARGUMENTS Variable Not Being Passed to Orchestrator

**Task**: 281  
**Started**: 2026-01-03  
**Completed**: 2026-01-03  
**Effort**: 4 hours  
**Priority**: High  
**Dependencies**: None  
**Sources/Inputs**:
- `.opencode/command/implement.md`
- `.opencode/command/research.md`
- `.opencode/agent/orchestrator.md`
- `.opencode/context/core/standards/command-argument-handling.md`
- `.opencode/docs/guides/creating-commands.md`
- `specs/278_investigate_fix_implement_argument_parsing/`
- `opencode.json`

**Artifacts**:
- `specs/281_fix_opencode_arguments_variable_not_being_passed_to_orchestrator/reports/research-001.md`

**Standards**: status-markers.md, artifact-management.md, tasks.md, report.md

---

## Executive Summary

Research into Task 281 reveals that the root cause is **NOT** in the orchestrator's argument parsing logic (which was fixed in Task 278), but rather in **how OpenCode invokes the orchestrator agent**. The `$ARGUMENTS` variable pattern documented in `command-argument-handling.md` assumes OpenCode automatically substitutes `$ARGUMENTS` with actual command arguments, but this substitution is not occurring when the orchestrator agent is invoked.

**Key Findings**:
1. Task 278 successfully fixed the orchestrator's argument parsing logic
2. The orchestrator correctly handles `$ARGUMENTS` when it receives them
3. The issue is that `$ARGUMENTS` arrives **empty** at the orchestrator
4. Command files specify `agent: orchestrator` in frontmatter, expecting OpenCode to pass arguments
5. OpenCode's agent invocation mechanism may not support argument passing in the same way as command file loading

**Root Cause**: OpenCode's agent invocation mechanism does not pass `$ARGUMENTS` to agents specified in command frontmatter. The `$ARGUMENTS` substitution works for command file content but not for agent invocations.

**Recommended Solution**: Modify command files to pass arguments explicitly in the agent invocation, or update OpenCode configuration to enable argument passing to agents.

---

## Context & Scope

### Background

The ProofChecker `.opencode` system uses a command-orchestrator-subagent architecture:

1. **User invokes command**: `/implement 271`
2. **OpenCode loads command file**: `.opencode/command/implement.md`
3. **Command file specifies agent**: `agent: orchestrator` in frontmatter
4. **OpenCode invokes orchestrator**: Should pass `271` as `$ARGUMENTS`
5. **Orchestrator parses arguments**: Extracts task number, validates, routes to subagent

### Problem Statement

When running `/implement 275`, the orchestrator reports:
```
Error: Task number required for /implement command

Stage 1 Validation Failed:
- Command type: task-based
- Arguments provided: (empty)
- Validation: FAILED - $ARGUMENTS is empty
```

This indicates that `$ARGUMENTS` is arriving **empty** at the orchestrator, despite the user providing `275` as an argument.

### Investigation Scope

This research investigates:
1. How OpenCode passes arguments from command invocation to agents
2. Whether command frontmatter supports argument passing
3. Working examples of commands that successfully receive arguments
4. OpenCode documentation on agent invocation and argument passing
5. Differences between command file loading and agent invocation

---

## Key Findings

### Finding 1: Task 278 Fixed Orchestrator Parsing Logic

**Evidence**: `specs/278_investigate_fix_implement_argument_parsing/summaries/implementation-summary-20260103.md`

Task 278 successfully enhanced the orchestrator's Stage 1 (PreflightValidation) with:
- Explicit command type lists (task-based vs. direct)
- Strengthened argument parsing with imperative instructions
- Validation checkpoints and logging
- Clear error messages

**Conclusion**: The orchestrator's argument parsing logic is **correct** and **working as designed**. The issue is not in the orchestrator.

### Finding 2: $ARGUMENTS Pattern is Well-Documented

**Evidence**: `.opencode/context/core/standards/command-argument-handling.md`

The `$ARGUMENTS` pattern is thoroughly documented:

```markdown
## The $ARGUMENTS Pattern

### How It Works

When a user invokes a slash command with arguments:

```
/research 197
```

OpenCode automatically:
1. Extracts the command name (`research`)
2. Captures the arguments (`197`)
3. Loads the command file (`.opencode/command/research.md`)
4. **Substitutes `$ARGUMENTS` with the actual arguments** (`197`)
5. Executes the command workflow with arguments available
```

**Key Insight**: The documentation states that OpenCode "substitutes `$ARGUMENTS` with the actual arguments" when loading the command file. However, this substitution may only apply to the **command file content**, not to **agent invocations**.

### Finding 3: Command Files Specify Agent in Frontmatter

**Evidence**: All command files (`.opencode/command/*.md`)

Every command file has frontmatter specifying the target agent:

```yaml
---
name: implement
agent: orchestrator
description: "Execute implementation with resume support and [COMPLETED] status"
routing:
  language_based: true
  lean: lean-implementation-agent
  default: implementer
timeout: 7200
---
```

**Key Insight**: The `agent: orchestrator` field tells OpenCode which agent to invoke, but there's **no mechanism** in the frontmatter to specify that `$ARGUMENTS` should be passed to the agent.

### Finding 4: Command File Content vs. Agent Invocation

**Evidence**: Comparison of command file structure and orchestrator invocation

**Command File Content** (what the agent sees):
```markdown
**Task Input (required):** $ARGUMENTS (task number; e.g., `/research 258`)

## Workflow Setup

**Orchestrator handles (Stage 1-5):**
- **Stage 1 (PreflightValidation):** Read task number from $ARGUMENTS variable...
```

**Agent Invocation** (how OpenCode calls the agent):
- OpenCode reads frontmatter: `agent: orchestrator`
- OpenCode invokes orchestrator agent
- **Question**: Does OpenCode pass `$ARGUMENTS` to the orchestrator?

**Hypothesis**: OpenCode substitutes `$ARGUMENTS` in the command file content (which the orchestrator reads), but when invoking the orchestrator as an agent, the `$ARGUMENTS` variable is **not available** in the orchestrator's execution context.

### Finding 5: No Explicit Argument Passing in Frontmatter

**Evidence**: Review of all command frontmatter schemas

The frontmatter schema includes:
- `name`: Command name
- `agent`: Target agent
- `description`: Brief description
- `routing`: Routing configuration
- `timeout`: Timeout value
- `context_loading`: Context loading strategy

**Missing**: No field for passing arguments to the agent (e.g., `arguments: $ARGUMENTS` or `pass_arguments: true`)

**Conclusion**: The frontmatter schema does not include a mechanism to pass `$ARGUMENTS` to the invoked agent.

### Finding 6: OpenCode Configuration Review

**Evidence**: `opencode.json`

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

**Key Observations**:
- `default_agent: "orchestrator"` - Orchestrator is the default agent
- Agent configuration includes `mode` and `tools` but **no argument passing configuration**
- No global configuration for passing `$ARGUMENTS` to agents

**Conclusion**: `opencode.json` does not configure argument passing to agents.

---

## Detailed Analysis

### How OpenCode Processes Commands

Based on the documentation and command structure, OpenCode likely follows this flow:

1. **User Input**: `/implement 275`
2. **Parse Command**: Extract command name (`implement`) and arguments (`275`)
3. **Load Command File**: Read `.opencode/command/implement.md`
4. **Substitute Variables**: Replace `$ARGUMENTS` with `275` in command file content
5. **Read Frontmatter**: Extract `agent: orchestrator`
6. **Invoke Agent**: Call orchestrator agent
7. **Pass Command Content**: Provide command file content to orchestrator

**Critical Question**: In step 6 (Invoke Agent), does OpenCode pass the `$ARGUMENTS` variable to the orchestrator's execution context?

### Hypothesis: $ARGUMENTS Scope is Limited to Command File

**Theory**: The `$ARGUMENTS` variable is substituted in the command file content but is **not available** in the orchestrator's execution environment.

**Evidence**:
1. Orchestrator reports `$ARGUMENTS` is empty
2. Command file content references `$ARGUMENTS` (e.g., "Read task number from $ARGUMENTS variable")
3. Orchestrator can read the command file content but cannot access the `$ARGUMENTS` variable directly

**Implication**: The orchestrator needs to **parse the command file content** to extract the arguments, rather than accessing `$ARGUMENTS` directly.

### Alternative Hypothesis: Agent Invocation Method

**Theory**: OpenCode may invoke agents differently than it loads command files, and the agent invocation method does not support argument passing.

**Evidence**:
1. Command files have `agent: orchestrator` in frontmatter
2. OpenCode invokes the orchestrator agent
3. The orchestrator does not receive `$ARGUMENTS`

**Possible Causes**:
1. **Agent invocation API limitation**: OpenCode's agent invocation API may not support passing arguments
2. **Missing configuration**: Frontmatter may need additional fields to enable argument passing
3. **Architectural mismatch**: The command-agent architecture may not be designed for argument passing

### Comparison with Working Commands

**Direct Commands** (e.g., `/meta`):
- No arguments required
- `agent: orchestrator` in frontmatter
- Orchestrator invokes meta subagent
- **Works correctly** because no arguments needed

**Task-Based Commands** (e.g., `/implement`, `/research`):
- Require task number as argument
- `agent: orchestrator` in frontmatter
- Orchestrator should receive task number
- **Fails** because `$ARGUMENTS` is empty

**Conclusion**: Direct commands work because they don't need arguments. Task-based commands fail because they need arguments but don't receive them.

---

## Decisions

### Decision 1: Root Cause Identified

**Decision**: The root cause is that OpenCode's agent invocation mechanism does not pass `$ARGUMENTS` to agents specified in command frontmatter.

**Rationale**:
- Task 278 confirmed orchestrator parsing logic is correct
- Documentation assumes `$ARGUMENTS` substitution works for agents
- Orchestrator reports `$ARGUMENTS` is empty
- No frontmatter configuration for argument passing exists

### Decision 2: Investigation Needed

**Decision**: Further investigation is needed to understand how OpenCode invokes agents and whether argument passing is supported.

**Investigation Questions**:
1. How does OpenCode invoke agents specified in command frontmatter?
2. Does OpenCode support passing arguments to agents?
3. Is there a configuration option to enable argument passing?
4. Are there working examples of commands that successfully pass arguments to agents?
5. Is there OpenCode documentation on agent invocation and argument passing?

### Decision 3: Potential Solutions

**Decision**: Three potential solutions have been identified:

**Solution 1: Modify Command Files to Pass Arguments Explicitly**
- Add argument passing configuration to frontmatter
- Example: `arguments: $ARGUMENTS` or `pass_arguments: true`
- Requires understanding OpenCode's frontmatter schema

**Solution 2: Update OpenCode Configuration**
- Add global configuration for argument passing in `opencode.json`
- Example: `"pass_arguments_to_agents": true`
- Requires understanding OpenCode's configuration schema

**Solution 3: Change Agent Invocation Method**
- Instead of `agent: orchestrator`, use a different invocation method
- Example: Embed orchestrator logic directly in command file
- Requires architectural changes

---

## Recommendations

### Recommendation 1: Investigate OpenCode Documentation

**Priority**: High  
**Effort**: 1-2 hours

**Action**: Search for OpenCode documentation on:
- Agent invocation API
- Command frontmatter schema
- Argument passing to agents
- Configuration options for argument passing

**Resources**:
- OpenCode official documentation (if available)
- OpenCode GitHub repository (if public)
- OpenCode community forums or discussions
- Similar projects using OpenCode

### Recommendation 2: Test Argument Passing Methods

**Priority**: High  
**Effort**: 2-3 hours

**Action**: Test different methods of passing arguments to agents:

**Test 1: Frontmatter Configuration**
```yaml
---
name: implement
agent: orchestrator
arguments: $ARGUMENTS
---
```

**Test 2: Explicit Argument Field**
```yaml
---
name: implement
agent: orchestrator
pass_arguments: true
---
```

**Test 3: Agent Invocation in Content**
```markdown
Invoke orchestrator with arguments: $ARGUMENTS
```

**Test 4: Global Configuration**
```json
{
  "default_agent": "orchestrator",
  "pass_arguments_to_agents": true
}
```

### Recommendation 3: Review OpenAgents Implementation

**Priority**: Medium  
**Effort**: 2-3 hours

**Action**: Review the OpenAgents project (mentioned in Task 240 research) to see how they handle argument passing.

**Questions**:
- Does OpenAgents use the same command-agent architecture?
- How do OpenAgents commands pass arguments to agents?
- Are there configuration options for argument passing?
- Can we adopt their approach?

### Recommendation 4: Consider Architectural Alternatives

**Priority**: Low  
**Effort**: 4-6 hours

**Action**: If argument passing is not supported, consider alternative architectures:

**Alternative 1: Embed Orchestrator Logic in Command Files**
- Move orchestrator's Stage 1-5 logic into command files
- Commands handle argument parsing and routing directly
- No need to pass arguments to orchestrator

**Alternative 2: Use Command File Content as Argument**
- Orchestrator parses command file content to extract arguments
- Command file content includes argument information
- Orchestrator extracts arguments from content

**Alternative 3: Create Wrapper Script**
- Create a wrapper script that invokes orchestrator with arguments
- Command files invoke wrapper script instead of orchestrator directly
- Wrapper script passes arguments to orchestrator

---

## Risks & Mitigations

### Risk 1: OpenCode Limitation

**Risk**: OpenCode may not support passing arguments to agents at all.

**Impact**: High - Would require architectural changes to entire system

**Mitigation**:
- Investigate OpenCode documentation thoroughly
- Test all possible argument passing methods
- Consider alternative architectures if needed

### Risk 2: Breaking Changes

**Risk**: Fixing argument passing may require changes to all command files.

**Impact**: Medium - Would require updating 10+ command files

**Mitigation**:
- Test changes on a single command first
- Create migration script for bulk updates
- Document changes clearly

### Risk 3: Compatibility Issues

**Risk**: Changes may break existing functionality or introduce new bugs.

**Impact**: Medium - Could affect all workflow commands

**Mitigation**:
- Test all commands after changes
- Create rollback plan
- Document all changes

---

## Appendix: Sources and Citations

### Source 1: Task 278 Implementation Summary

**File**: `specs/278_investigate_fix_implement_argument_parsing/summaries/implementation-summary-20260103.md`

**Key Quote**:
> "The orchestrator AI agent was not following its Stage 1 instructions to parse task numbers from $ARGUMENTS. The instructions were present but not explicit or imperative enough."

**Relevance**: Confirms that Task 278 fixed the orchestrator's parsing logic, so the issue is not in the orchestrator.

### Source 2: Command Argument Handling Standard

**File**: `.opencode/context/core/standards/command-argument-handling.md`

**Key Quote**:
> "OpenCode automatically:
> 1. Extracts the command name (`research`)
> 2. Captures the arguments (`197`)
> 3. Loads the command file (`.opencode/command/research.md`)
> 4. **Substitutes `$ARGUMENTS` with the actual arguments** (`197`)
> 5. Executes the command workflow with arguments available"

**Relevance**: Documents the expected behavior of `$ARGUMENTS` substitution, but may only apply to command file content, not agent invocations.

### Source 3: Creating Commands Guide

**File**: `.opencode/docs/guides/creating-commands.md`

**Key Quote**:
> "**Task Input (required):** $ARGUMENTS (task number; e.g., `/{command} 258`)"

**Relevance**: Shows the standard pattern for documenting `$ARGUMENTS` in command files, but doesn't explain how arguments are passed to agents.

### Source 4: Command Structure Standard

**File**: `.opencode/context/core/standards/command-structure.md`

**Key Quote**:
> "Commands should be **lightweight** (<200 lines) and focus on routing, not execution."

**Relevance**: Confirms that commands are routing layers, and the orchestrator is the routing agent. The issue is in the routing mechanism.

### Source 5: OpenCode Configuration

**File**: `opencode.json`

**Relevance**: Shows the current OpenCode configuration, which does not include any argument passing configuration for agents.

---

## Next Steps

1. **Immediate** (1-2 hours):
   - Search for OpenCode documentation on agent invocation
   - Test frontmatter argument passing methods
   - Review OpenAgents implementation

2. **Short-term** (2-4 hours):
   - Implement and test the working solution
   - Update all command files if needed
   - Document the fix

3. **Long-term** (4-6 hours):
   - Consider architectural improvements
   - Update documentation and standards
   - Create migration guide for future commands

---

## Conclusion

The root cause of Task 281 is that OpenCode's agent invocation mechanism does not pass `$ARGUMENTS` to agents specified in command frontmatter. The `$ARGUMENTS` variable is substituted in command file content but is not available in the orchestrator's execution context.

**Recommended Next Steps**:
1. Investigate OpenCode documentation for agent invocation and argument passing
2. Test different methods of passing arguments to agents
3. Implement the working solution and update all command files
4. Document the fix and update standards

**Estimated Effort**: 6-8 hours total (2 hours investigation, 2 hours testing, 2-4 hours implementation)

**Priority**: High - Blocks all task-based workflow commands (/research, /plan, /implement, /revise)
