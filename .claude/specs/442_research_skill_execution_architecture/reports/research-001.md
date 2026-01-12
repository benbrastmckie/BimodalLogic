# Research Report: Task #438

**Task**: Research skill/agent execution architecture
**Date**: 2026-01-12
**Session**: sess_1768247272_1eaab2

## Executive Summary

Investigation of the skill/agent execution architecture revealed **a critical root cause** for observed failures: custom agents in `.claude/agents/` lack YAML frontmatter, preventing their registration as valid `subagent_type` values for the Task tool.

Key findings:
1. The Skill tool is a **context injection mechanism**, not an executor - it loads skill markdown into context
2. Custom subagent types require **YAML frontmatter** with a `name` field to register
3. Current agents have NO frontmatter - they're plain markdown, so Claude Code ignores them
4. The "forked subagent pattern" documented in skills cannot work without proper agent registration

**Recommendation**: **Option D (Hybrid)** - Fix agent registration via frontmatter AND simplify the delegation chain. This addresses the root cause while reducing unnecessary complexity.

---

## Platform Constraints Discovered

### Claude Code Skill Tool Behavior

The Skill tool operates as a **multi-phase context injection process**:

1. **Discovery Phase**: At startup, loads only skill metadata (name + description) - ~100 tokens
2. **Activation Phase**: When request matches, Claude asks to use skill via Skill tool
3. **Execution Phase**: Full SKILL.md content injected into context

**Key facts**:
- Skills do NOT execute code automatically
- Skills ARE documentation that becomes instructions in context
- Claude then manually follows the instructions
- The `allowed-tools` frontmatter restricts available tools during skill execution

### Task Tool Subagent Registration

Valid `subagent_type` values come from three sources:

| Source | Location | Registration Mechanism |
|--------|----------|----------------------|
| Built-in | Hardcoded | Always available |
| Custom | `.claude/agents/*.md` | **Requires YAML frontmatter** |
| Plugins | Plugin `agents/` dir | Plugin installation |

**Built-in subagent types**:
- `Bash` - Command execution
- `general-purpose` - Full capability agent
- `Explore` - Read-only codebase exploration
- `Plan` - Research/planning agent
- `statusline-setup` - Configuration helper
- `claude-code-guide` - Documentation guidance

### Root Cause: Missing Frontmatter

Current agent files (e.g., `lean-research-agent.md`) have NO YAML frontmatter:

```markdown
# Lean Research Agent          <-- Starts with H1, no frontmatter!

## Overview
...
```

**Required format** for agent registration:

```yaml
---
name: lean-research-agent
description: Research Lean 4 and Mathlib for theorem proving tasks
model: claude-opus-4-5-20251101
tools:
  - Read
  - Write
  - mcp__lean-lsp__*
---

# Lean Research Agent
...
```

Without frontmatter, Claude Code **silently ignores** the agent files, explaining why `skill-lean-implementation` produced:
```
Error: Agent type 'skill-lean-implementation' not found. Available agents: Bash, general-purpose, ...
```

---

## Option Analysis

### Option A: Make Skills Executable (with automatic subagent delegation)

**Concept**: Skills with `context: fork` and `agent: xxx` frontmatter automatically spawn subagents.

**Current Status**: Partially implemented in SKILL.md files but broken because:
1. Agent files lack registration frontmatter
2. Skills don't actually execute - they're just context

**Effort to Fix**:
- Add YAML frontmatter to all 7 agent files
- Skills already have `context: fork` and `agent` fields
- Should "just work" once agents are registered

**Token Efficiency**: Good
- Skills load minimal context (~300 tokens)
- Agents load full context in isolated conversation
- No duplication between main conversation and subagent

**Reliability**: Medium-High (once fixed)
- Registration is automatic from frontmatter
- Delegation is explicit in skill frontmatter
- Subagent isolation prevents context bleed

**Maintainability**: Good
- Clear separation: Skills = routing, Agents = execution
- Changes to agent behavior in one place
- Skills remain thin wrappers

**Risks**:
- Relies on Claude Code's agent registration working correctly
- Subagent returns need to be structured (current agents document this)
- Need to test registration actually works

---

### Option B: Inline Critical Patterns in Commands

**Concept**: Remove skill indirection; commands directly contain all jq/Edit patterns.

**Effort**: High
- Rewrite all commands with embedded status update patterns
- Remove skill-status-sync as separate skill
- Duplicate patterns across commands (or use includes)

**Token Efficiency**: Poor
- Each command loads full patterns (~2000+ tokens)
- Patterns duplicated across commands
- No isolation - all in main conversation context

**Reliability**: Medium
- No indirection = fewer failure points
- But patterns can drift between commands
- No centralized validation

**Maintainability**: Poor
- Changes require updating multiple command files
- Easy to introduce inconsistencies
- Large command files harder to navigate

**Risks**:
- Pattern duplication leads to drift
- Commands become bloated
- Loses the abstraction benefits

---

### Option C: Task Tool with Explicit Prompts

**Concept**: Skip skill layer entirely; commands use Task(general-purpose) with full context in prompt.

**Effort**: Medium
- Rewrite commands to build comprehensive Task prompts
- Include all context inline in prompt argument
- Remove skill files (or keep as documentation)

**Token Efficiency**: Poor-Medium
- Full context loaded for each delegation (~10k+ tokens)
- Context must be passed explicitly each time
- No caching of common patterns

**Reliability**: Medium
- `general-purpose` always available
- But prompts can become very long
- Harder to ensure consistent behavior

**Maintainability**: Medium
- Context in commands, not separate files
- But commands become very large
- Changes require finding all places context is used

**Risks**:
- Very long prompts are harder to maintain
- No reuse of agent definitions
- Loses specialization benefits

---

### Option D: Hybrid - Fix Registration + Simplify Chain (RECOMMENDED)

**Concept**: Fix the root cause (agent registration) AND simplify where beneficial.

**Components**:

1. **Fix Agent Registration** (Critical)
   - Add YAML frontmatter to all `.claude/agents/*.md` files
   - Fields: name, description, model, tools (where appropriate)
   - Test that agents appear in available subagent_type list

2. **Verify Skill Delegation** (Test)
   - Confirm `context: fork` + `agent: xxx` works after registration
   - May need adjustments to skill frontmatter

3. **Simplify skill-status-sync** (Optimization)
   - Keep as skill but ensure it's truly thin
   - The jq patterns are proven; issue was invocation not patterns
   - Consider making operations more explicit in return

4. **Improve Session ID Generation** (Quick Fix)
   - Update checkpoint-gate-in.md with portable command
   - `od -An -N3 -tx1 /dev/urandom | tr -d ' '` works on NixOS

**Effort**: Low-Medium
- Phase 1: Add frontmatter (~1 hour)
- Phase 2: Test and verify (~1 hour)
- Phase 3: Minor adjustments (~1-2 hours)

**Token Efficiency**: Good (same as Option A)

**Reliability**: High
- Fixes root cause
- Maintains proven patterns
- Incremental, testable changes

**Maintainability**: Good
- Preserves separation of concerns
- Skills remain thin wrappers
- Agents encapsulate domain logic

---

## Comparison Matrix

| Criterion | Option A | Option B | Option C | Option D |
|-----------|----------|----------|----------|----------|
| **Fixes root cause** | Yes | No | Workaround | Yes |
| **Effort** | Low | High | Medium | Low-Medium |
| **Token efficiency** | Good | Poor | Poor-Med | Good |
| **Reliability** | Med-High | Medium | Medium | High |
| **Maintainability** | Good | Poor | Medium | Good |
| **Preserves architecture** | Yes | No | No | Yes |

---

## Recommended Migration Path

### Phase 1: Fix Agent Registration (Immediate)

Add YAML frontmatter to each agent file:

```yaml
---
name: {agent-name}
description: {from current ## Overview}
model: claude-opus-4-5-20251101
---
```

Files to update:
- `.claude/agents/lean-research-agent.md`
- `.claude/agents/lean-implementation-agent.md`
- `.claude/agents/general-research-agent.md`
- `.claude/agents/general-implementation-agent.md`
- `.claude/agents/latex-implementation-agent.md`
- `.claude/agents/planner-agent.md`
- `.claude/agents/meta-builder-agent.md`

### Phase 2: Test Agent Registration

After adding frontmatter:
1. Restart Claude Code session
2. Attempt Task tool call with custom subagent_type
3. Verify agent is recognized and executes

```
Task(subagent_type="lean-research-agent", prompt="Test: confirm you are lean-research-agent")
```

If test fails, investigate frontmatter format requirements.

### Phase 3: Fix Session ID Generation

Update `.claude/context/core/checkpoints/checkpoint-gate-in.md`:

```bash
# Portable session ID (works on NixOS, macOS, Linux)
session_id="sess_$(date +%s)_$(od -An -N3 -tx1 /dev/urandom | tr -d ' ')"
```

### Phase 4: Validate End-to-End

Test full workflow:
1. `/research 438` - Should use general-research-agent (meta task)
2. `/plan 438` - Should use planner-agent
3. Verify structured returns and artifact linking

### Phase 5: Document and Monitor

- Update CLAUDE.md with any learnings
- Monitor next few task executions for issues
- Log any remaining failures for iteration

---

## Implementation Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Frontmatter format wrong | Medium | High | Test immediately after Phase 1 |
| Agent context too large | Low | Medium | Current agents are ~12k tokens - acceptable |
| Skill-agent link broken | Low | High | Skills already have correct fields |
| Other platform constraints | Low | Medium | Can fall back to general-purpose |

---

## Success Criteria

After implementation:

- [ ] All 7 agent files have valid YAML frontmatter
- [ ] `lean-research-agent` recognized as valid subagent_type
- [ ] `planner-agent` recognized as valid subagent_type
- [ ] Session ID generation works without `xxd`
- [ ] `/research` successfully delegates to correct agent
- [ ] `/plan` successfully delegates to planner-agent
- [ ] `/implement` successfully delegates to language-appropriate agent
- [ ] Structured returns are captured at GATE OUT

---

## Appendix: Agent Frontmatter Template

```yaml
---
name: {agent-name-matching-filename}
description: {one-line description for Claude's routing}
model: claude-opus-4-5-20251101
tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Bash
  # Add domain-specific tools as needed
---
```

**Note**: The `tools` field may be optional if the agent should inherit all available tools. Test with and without to determine requirement.
