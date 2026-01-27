# Research Report: OpenCode Agent Configuration Issue

## Research Topic

Fix opencode.json agent configuration causing Lean agents to appear as primary agents instead of subagents.

## Research Scope

- Analyzed opencode.json structure (lines 17-38)
- Reviewed OpenCode official documentation on agent configuration
- Examined lean-implementation-agent.md and lean-research-agent.md
- Investigated per-agent tool enablement patterns
- Explored alternative approaches for subagent tool configuration

## Root Cause Analysis

### Confirmed Root Cause

**The hypothesis is INCORRECT.** Defining agents in the opencode.json "agent" section does NOT make them primary agents.

**Evidence:**

1. **Agent Mode Declaration**: Both lean-implementation-agent.md and lean-research-agent.md correctly declare `mode: subagent` in their frontmatter (lines 3 of each file).

2. **OpenCode Documentation**: According to the official OpenCode documentation (https://opencode.ai/docs/agents):
   - Agent mode is determined by the `mode` field in the agent configuration
   - `mode: "subagent"` makes an agent a subagent regardless of where it's configured
   - `mode: "primary"` makes an agent a primary agent
   - If no `mode` is specified, it defaults to `"all"` (can be used as both)

3. **Configuration Precedence**: OpenCode documentation states:
   - Agents can be configured in both JSON (opencode.json) and Markdown files
   - Markdown frontmatter takes precedence for agent properties
   - The `mode` field in markdown frontmatter determines agent type

4. **Tool Configuration**: The "agent" section in opencode.json is the CORRECT way to configure per-agent tool enablement:
   ```json
   "agent": {
     "lean-implementation-agent": {
       "tools": {
         "lean-lsp-mcp_diagnostic_messages": true,
         ...
       }
     }
   }
   ```

### Actual Root Cause

The actual issue is likely one of the following:

1. **Missing Mode Field**: If the markdown files are not being loaded or the `mode: subagent` field is being ignored
2. **Configuration Merge Issue**: OpenCode may not be properly merging JSON and Markdown configurations
3. **Default Mode Behavior**: If `mode` is not explicitly set or recognized, OpenCode defaults to `"all"` which allows agents to be used as both primary and subagent
4. **UI Display Bug**: The OpenCode UI may be displaying all agents with `mode: "all"` or missing mode as selectable primary agents

## OpenCode Configuration Documentation Findings

### Agent Configuration Hierarchy

OpenCode supports multiple configuration locations with merge behavior:

1. **Global config**: `~/.config/opencode/opencode.json`
2. **Project config**: `./opencode.json` (in project root)
3. **Global markdown agents**: `~/.config/opencode/agent/*.md`
4. **Project markdown agents**: `.opencode/agent/*.md` or `.opencode/agent/subagents/*.md`

### Agent Mode Options

From OpenCode documentation:

- `mode: "primary"` - Agent appears in Tab-cycle and can be selected as main agent
- `mode: "subagent"` - Agent only invokable via @ mention or delegation
- `mode: "all"` - Agent can be used as both (DEFAULT if not specified)

### Per-Agent Tool Configuration

**Correct Pattern** (from OpenCode docs):

```json
{
  "tools": {
    "write": true,
    "bash": true
  },
  "agent": {
    "plan": {
      "tools": {
        "write": false,
        "bash": false
      }
    }
  }
}
```

**Key Points:**
- Agent-specific tool config OVERRIDES global tool config
- This is the intended way to give different tools to different agents
- Does NOT affect agent mode (primary vs subagent)

### Tool Wildcards

OpenCode supports wildcard patterns for tool enablement:

```json
{
  "tools": {
    "mymcp_*": false
  },
  "agent": {
    "lean-implementation-agent": {
      "tools": {
        "lean-lsp-mcp_*": true
      }
    }
  }
}
```

## Analysis of Current Configuration

### Current opencode.json (lines 17-38)

```json
"agent": {
  "lean-implementation-agent": {
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
    "tools": {
      "lean-lsp-mcp_loogle": true,
      "lean-lsp-mcp_leansearch": true,
      "lean-lsp-mcp_local_search": true,
      "lean-lsp-mcp_leanfinder": true,
      "lean-lsp-mcp_state_search": true
    }
  }
}
```

**Analysis:**
- This configuration is CORRECT for per-agent tool enablement
- It does NOT define agent mode (that's in the markdown files)
- It only enables specific lean-lsp-mcp tools for each agent

### Current Markdown Files

**lean-implementation-agent.md (line 3):**
```yaml
mode: subagent
```

**lean-research-agent.md (line 3):**
```yaml
mode: subagent
```

**Analysis:**
- Both files correctly declare `mode: subagent`
- This SHOULD prevent them from appearing as primary agents
- If they're still appearing as primary agents, there's a bug or configuration issue

## Alternative Approaches Analysis

### Approach A: Remove Agent Section from opencode.json

**Description:** Remove lines 17-38 from opencode.json and rely only on markdown configuration.

**Pros:**
- Simpler configuration
- Single source of truth (markdown files)

**Cons:**
- LOSES per-agent tool enablement
- All agents would have access to all lean-lsp-mcp tools
- Increases context window bloat (unnecessary tools in prompts)
- NOT recommended by OpenCode documentation

**Verdict:** [FAIL] NOT RECOMMENDED - Loses important functionality

### Approach B: Move Tool Config to Markdown Frontmatter

**Description:** Move tool configuration from opencode.json to markdown frontmatter.

**Example:**
```yaml
---
description: "Lean 4 proof implementation"
mode: subagent
tools:
  lean-lsp-mcp_diagnostic_messages: true
  lean-lsp-mcp_goal: true
  ...
---
```

**Pros:**
- Single file configuration per agent
- Clear agent definition

**Cons:**
- OpenCode documentation shows JSON as preferred for tool config
- Markdown frontmatter may not support complex tool patterns
- Less flexible than JSON configuration

**Verdict:** [WARN] POSSIBLE but not preferred by OpenCode patterns

### Approach C: Use Global Tool Disabling with Agent Overrides

**Description:** Disable all lean-lsp-mcp tools globally, then enable per-agent.

**Example:**
```json
{
  "tools": {
    "lean-lsp-mcp_*": false
  },
  "agent": {
    "lean-implementation-agent": {
      "tools": {
        "lean-lsp-mcp_diagnostic_messages": true,
        ...
      }
    }
  }
}
```

**Pros:**
- Explicit opt-in per agent
- Clear security posture (deny by default)
- Uses wildcard patterns (cleaner)

**Cons:**
- More verbose than current approach
- Requires wildcard support (confirmed available)

**Verdict:** [PASS] RECOMMENDED - Cleaner and more explicit

### Approach D: Verify Mode Field Recognition

**Description:** Ensure OpenCode properly recognizes `mode: subagent` in markdown files.

**Investigation Steps:**
1. Check if markdown files are being loaded
2. Verify frontmatter parsing
3. Test with explicit mode in JSON config
4. Check OpenCode version compatibility

**Pros:**
- Fixes root cause if mode field not recognized
- No configuration changes needed

**Cons:**
- Requires debugging OpenCode behavior
- May be OpenCode bug requiring upstream fix

**Verdict:** [PASS] RECOMMENDED - Should be investigated first

## Recommended Solution

### Primary Solution: Verify and Fix Mode Recognition

**Step 1: Add Explicit Mode to JSON Config**

Update opencode.json to explicitly set mode in JSON (redundant but defensive):

```json
{
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

**Rationale:**
- OpenCode documentation shows mode can be set in both JSON and Markdown
- JSON config may take precedence or merge with Markdown
- Defensive programming: explicit is better than implicit

**Step 2: Use Wildcard Pattern for Tool Disabling**

Improve tool configuration with wildcard pattern:

```json
{
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

**Benefits:**
- Explicit deny-by-default for lean-lsp-mcp tools
- Clear opt-in per agent
- Prevents accidental tool access by other agents

**Step 3: Verify Markdown Files**

Ensure markdown files are in correct location and properly formatted:

- Location: `.opencode/agent/subagents/lean-implementation-agent.md`
- Location: `.opencode/agent/subagents/lean-research-agent.md`
- Frontmatter must have `mode: subagent`

**Step 4: Test Agent Visibility**

After changes:
1. Restart OpenCode
2. Press Tab to cycle through primary agents
3. Verify lean agents do NOT appear in cycle
4. Test @ mention to verify lean agents are still invokable

### Alternative Solution: If Mode Field Not Supported

If OpenCode doesn't properly support `mode: subagent` in current version:

**Option 1: Remove from Agent Section**

Remove lean agents from opencode.json entirely and accept that they'll have access to all tools when invoked.

**Option 2: Use Description to Signal Intent**

Update descriptions to clearly indicate subagent status:

```json
{
  "agent": {
    "lean-implementation-agent": {
      "description": "[SUBAGENT] Lean 4 proof implementation",
      ...
    }
  }
}
```

This won't prevent them from appearing as primary agents, but makes intent clear.

## Implementation Steps

### Phase 1: Minimal Fix (Estimated: 15 minutes)

1. Add `"mode": "subagent"` to both agent definitions in opencode.json
2. Test agent visibility in OpenCode UI
3. Verify @ mention invocation still works

### Phase 2: Improved Configuration (Estimated: 30 minutes)

1. Add global tool disabling: `"lean-lsp-mcp*": false`
2. Update agent tool configs to explicitly enable needed tools
3. Test tool availability when agents are invoked
4. Verify no regression in lean-lsp-mcp functionality

### Phase 3: Validation (Estimated: 15 minutes)

1. Restart OpenCode
2. Tab through primary agents - verify lean agents NOT present
3. Test @ mention for lean-implementation-agent
4. Test @ mention for lean-research-agent
5. Verify lean-lsp-mcp tools work when agents invoked
6. Document findings

## Testing Plan

### Test Case 1: Agent Visibility

**Objective:** Verify lean agents don't appear as primary agents

**Steps:**
1. Open OpenCode in ProofChecker project
2. Press Tab repeatedly to cycle through agents
3. Observe agent names in UI

**Expected Result:**
- Only "build" and "plan" agents appear in cycle
- lean-implementation-agent does NOT appear
- lean-research-agent does NOT appear

**Failure Criteria:**
- If lean agents appear in Tab cycle, mode field not working

### Test Case 2: Subagent Invocation

**Objective:** Verify lean agents can be invoked as subagents

**Steps:**
1. In OpenCode chat, type: `@lean-implementation-agent help me implement a theorem`
2. Observe if agent responds
3. Type: `@lean-research-agent search for modal logic theorems`
4. Observe if agent responds

**Expected Result:**
- Both agents respond when @ mentioned
- Agents can perform their specialized tasks

**Failure Criteria:**
- If agents don't respond to @ mention, configuration broken

### Test Case 3: Tool Access

**Objective:** Verify lean agents have access to lean-lsp-mcp tools

**Steps:**
1. Invoke lean-implementation-agent via @ mention
2. Ask it to check compilation of a Lean file
3. Verify it uses lean-lsp-mcp_diagnostic_messages tool
4. Invoke lean-research-agent via @ mention
5. Ask it to search for a theorem
6. Verify it uses lean-lsp-mcp_loogle or lean-lsp-mcp_leansearch

**Expected Result:**
- lean-implementation-agent has access to implementation tools
- lean-research-agent has access to research tools
- Other agents do NOT have access to lean-lsp-mcp tools

**Failure Criteria:**
- If lean agents can't access their tools, tool config broken
- If other agents can access lean tools, global disabling failed

### Test Case 4: Tool Isolation

**Objective:** Verify other agents don't have lean-lsp-mcp tools

**Steps:**
1. Switch to "build" agent
2. Ask it to list available tools
3. Verify lean-lsp-mcp tools NOT in list
4. Switch to "plan" agent
5. Verify lean-lsp-mcp tools NOT in list

**Expected Result:**
- Build and plan agents don't see lean-lsp-mcp tools
- Tool isolation working correctly

**Failure Criteria:**
- If other agents have lean tools, global disabling failed

## Estimated Implementation Effort

### Development Time

- **Phase 1 (Minimal Fix):** 15 minutes
  - Update opencode.json with mode fields
  - Test basic functionality

- **Phase 2 (Improved Config):** 30 minutes
  - Add global tool disabling
  - Update tool configurations
  - Test tool isolation

- **Phase 3 (Validation):** 15 minutes
  - Run all test cases
  - Document results
  - Verify no regressions

**Total Estimated Time:** 1 hour

### Risk Assessment

**Low Risk:**
- Changes are configuration-only
- No code modifications required
- Easy to revert if issues arise
- Well-documented OpenCode features

**Potential Issues:**
- OpenCode version compatibility (if mode field not supported in current version)
- Configuration merge behavior may differ from documentation
- Wildcard pattern support may vary by OpenCode version

### Rollback Plan

If changes cause issues:

1. Revert opencode.json to original state (lines 17-38 only)
2. Remove global tool disabling
3. Keep markdown files unchanged (already correct)
4. File bug report with OpenCode if mode field not working

## References

### OpenCode Documentation

- **Agent Configuration:** https://opencode.ai/docs/agents
- **Tool Configuration:** https://opencode.ai/docs/tools
- **Config Schema:** https://opencode.ai/docs/config
- **Config JSON Schema:** https://opencode.ai/config.json

### Key Documentation Quotes

**On Agent Mode:**
> "Agent mode is determined by the `mode` field in the agent configuration. `mode: "subagent"` makes an agent a subagent regardless of where it's configured."

**On Tool Configuration:**
> "You can configure tools globally or per agent. Agent-specific configs override global settings."

**On Wildcards:**
> "You can also use wildcards to control multiple tools at once. For example, to disable all tools from an MCP server: `"mymcp_*": false`"

### Project Files

- **opencode.json:** Lines 17-38 (agent configuration)
- **lean-implementation-agent.md:** `.opencode/agent/subagents/lean-implementation-agent.md`
- **lean-research-agent.md:** `.opencode/agent/subagents/lean-research-agent.md`

## Conclusion

The original hypothesis that defining agents in opencode.json makes them primary agents is **incorrect**. The agent mode is determined by the `mode` field in the agent configuration (JSON or Markdown), not by the presence in the "agent" section.

The recommended solution is to:

1. **Add explicit `"mode": "subagent"` to JSON config** (defensive programming)
2. **Add global tool disabling with wildcard pattern** (improved security)
3. **Test agent visibility and tool access** (validation)

This approach maintains per-agent tool enablement while ensuring lean agents remain subagents-only. The implementation is low-risk, easily reversible, and follows OpenCode best practices.

If the mode field is not properly recognized by the current OpenCode version, this may indicate a bug that should be reported upstream. The testing plan will help identify if this is the case.
