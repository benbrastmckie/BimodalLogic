# Research Report: Task #432 - Progressive Context Loading Best Practices

**Task**: Fix artifact linking in TODO.md and state.json
**Date**: 2026-01-12
**Focus**: Online research on Claude Code best practices for progressive context loading vs agent-only loading

## Executive Summary

This research evaluates the context loading strategy proposed in research-003.md ("Command -> [no context] -> Skill -> [no context] -> Agent -> [LOAD CONTEXT HERE]") against industry best practices from Anthropic's official documentation and the broader Claude Code community. The findings suggest that while agent-only loading is directionally correct for token efficiency, a **progressive loading approach with minimal context at each layer** may be more robust and aligns better with official recommendations.

## Key Sources

- [Claude Code: Best practices for agentic coding](https://www.anthropic.com/engineering/claude-code-best-practices) - Anthropic official guide
- [Effective context engineering for AI agents](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents) - Anthropic context engineering guide
- [How we built our multi-agent research system](https://www.anthropic.com/engineering/multi-agent-research-system) - Anthropic multi-agent patterns
- [How I Organized My CLAUDE.md in a Monorepo](https://dev.to/anvodev/how-i-organized-my-claudemd-in-a-monorepo-with-too-many-contexts-37k7) - Monorepo patterns
- [Claude's Context Engineering Playbook](https://01.me/en/2025/12/context-engineering-from-claude/) - Layered context strategies

## Findings

### 1. Official Anthropic Recommendations Support Layered Loading

Anthropic's documentation explicitly recommends a **hybrid model** rather than purely deferred loading:

> "Claude Code employs a hybrid model: CLAUDE.md files are naively dropped into context up front, while primitives like glob and grep allow it to navigate its environment and retrieve files just-in-time."

This suggests that **some context should be loaded early** (like CLAUDE.md) while more detailed context is retrieved on-demand. The pure "no context until agent" approach may be too extreme.

### 2. CLAUDE.md Hierarchy Pattern

Anthropic recommends a hierarchical CLAUDE.md structure with progressive specificity:

| Location | Content | Loading |
|----------|---------|---------|
| `~/.claude/CLAUDE.md` | Universal user preferences | Always (all sessions) |
| `/project/CLAUDE.md` | Project-wide standards | Always (project sessions) |
| `/project/service/CLAUDE.md` | Service-specific context | When working in directory |
| Referenced docs without @ | Detailed guides | On-demand by agent |

**Key insight**: This is a **three-tier progressive loading** system, not binary "load everything" or "load nothing until execution."

### 3. Context Budget by Stage (Industry Practice)

From the Claude Code community, a pattern emerges:

| Stage | Context Budget | Purpose |
|-------|----------------|---------|
| **Routing** | ~500 tokens | Determine destination (command parsing) |
| **Orchestration** | ~2,000 tokens | Coordinate work (skill validation) |
| **Execution** | ~20,000+ tokens | Detailed work (agent implementation) |

This matches a **progressive disclosure** model where each layer loads only what it needs for its specific responsibility.

### 4. The "Pointer vs Copy" Principle

A critical recommendation from multiple sources:

> "Prefer pointers to copies. Don't include code snippets in these files if possible - they will become out-of-date quickly. Instead, include file:line references to point Claude to the authoritative context."

**Application to our system**: Commands and skills should contain **pointers** (paths, references) rather than embedded context. Agents load the actual content via those pointers.

### 5. Subagent Context Isolation Benefits

Anthropic's multi-agent research system documentation highlights key benefits:

> "Subagents facilitate compression by operating in parallel with their own context windows... Each subagent also provides separation of concerns - distinct tools, prompts, and exploration trajectories - which reduces path dependency."

**Quantified benefit**: "Subagents process 67% fewer tokens overall due to context isolation."

However, the orchestrator still needs **enough context to make routing decisions**:

> "The lead agent maintains strategic planning information while subagents operate with task-specific context."

### 6. Trade-offs Table from Research

| Strategy | Best For | Trade-off |
|----------|----------|-----------|
| **Preloading** | Immediate access, fast routing | Token waste if unused |
| **Just-in-Time** | Efficient token use | Latency from retrieval calls |
| **Hybrid** (recommended) | Balance of speed and efficiency | More complex to manage |
| **Agent-Only** | Maximum isolation | May lose routing intelligence |

### 7. The "10k Word Rule"

Multiple sources cite that CLAUDE.md files should stay under 10k words (~13k tokens) for optimal performance. One developer reduced their monorepo root file from 47k to 9k words with significant improvement.

**Application**: Our root CLAUDE.md should be curated, with domain-specific context pushed to child files or referenced documents.

## Analysis: Progressive vs Agent-Only Loading

### Arguments for Agent-Only Loading (research-003 proposal)

1. **Token Efficiency**: Maximum context available for actual work
2. **Clean Isolation**: No context pollution between layers
3. **Simple Mental Model**: Clear loading point
4. **Subagent Benefits**: Documented 67% token reduction

### Arguments for Progressive Loading (Industry Practice)

1. **Routing Intelligence**: Commands need enough context to route correctly
2. **Validation Context**: Skills need schema knowledge for return validation
3. **Fail-Fast Behavior**: Earlier context enables earlier error detection
4. **Official Recommendation**: Anthropic's hybrid model is explicitly recommended

### Synthesis: Tiered Progressive Loading

The research suggests a middle ground - **minimal progressive loading**:

```
Layer        | Context Type              | Budget    | Purpose
-------------|---------------------------|-----------|---------------------------
Command      | Routing hints only        | ~200 tok  | Route to correct skill
Skill        | Validation schemas only   | ~300 tok  | Validate inputs/outputs
Agent        | Full execution context    | ~10k+ tok | Actually do the work
```

This differs from research-003's proposal in that:
- Commands get **routing hints** (not full context, but not zero)
- Skills get **validation schemas** (return format, input requirements)
- Agents still get the bulk of context (~95%)

## Recommendations

### Recommendation 1: Adopt Minimal Progressive Loading

Instead of "no context until agent," adopt a tiered approach:

**Command Level** (~200 tokens):
- Task type routing hints (language -> skill mapping)
- Status transition rules (valid state changes)
- Nothing about HOW to execute

**Skill Level** (~300 tokens):
- Return schema (subagent-return.md core section only)
- Input validation rules
- Delegation pointer (which agent to invoke)

**Agent Level** (~10k+ tokens):
- Full execution context
- Language-specific tools and patterns
- Domain knowledge

### Recommendation 2: Use Pointers, Not Copies

For command and skill files:
- Reference paths to context files ("See .claude/context/core/formats/subagent-return.md")
- Do NOT use @ syntax for non-essential context
- Use @ syntax only for context that must always be present

### Recommendation 3: Create a "Routing Context" File

Create a small (~200 token) file specifically for command-level routing:

```markdown
# Routing Context (.claude/context/routing.md)

## Language -> Skill Mapping
- lean: skill-lean-research, skill-lean-implementation
- general: skill-researcher, skill-implementer
- meta: skill-meta
- latex: skill-latex-implementation

## Valid Status Transitions
- not_started -> researching
- researched -> planning
- planned -> implementing
```

This gives commands just enough context to route correctly without bloating.

### Recommendation 4: Create a "Validation Context" File

Create a small (~300 token) file for skill-level validation:

```markdown
# Validation Context (.claude/context/validation.md)

## Return Schema (Required Fields)
- status: completed|partial|failed|blocked
- summary: <100 tokens
- artifacts: array with {type, path, summary}
- metadata: {session_id, agent_type}

## Input Requirements
- task_number: Must exist in state.json
- focus_prompt: Optional string
```

### Recommendation 5: Budget Allocation

Establish explicit token budgets:

| Layer | Max Budget | Consequence if Exceeded |
|-------|------------|------------------------|
| CLAUDE.md (root) | 3,000 tokens | Refactor to child files |
| Command context | 500 tokens | Too much routing logic |
| Skill context | 500 tokens | Too much in wrapper |
| Agent context | 15,000 tokens | Normal operating range |

### Recommendation 6: Hierarchical CLAUDE.md Structure

Align with Anthropic's recommendation:

```
.claude/CLAUDE.md           # Project-wide (~200 lines max)
.claude/agents/CLAUDE.md    # Agent-specific patterns
.claude/skills/CLAUDE.md    # Skill-specific patterns
Logos/CLAUDE.md            # Lean 4 specific context
```

## Revised Architecture Proposal

Based on research, here is a refined version of the context loading architecture:

```
STAGE 1: ROUTING (Command Layer)
├── Load: routing.md (~200 tokens)
├── Purpose: Determine which skill to invoke
└── Contains: Language mappings, status rules

STAGE 2: ORCHESTRATION (Skill Layer)
├── Load: validation.md (~300 tokens)
├── Purpose: Validate inputs, prepare delegation, validate returns
└── Contains: Return schema, input requirements

STAGE 3: EXECUTION (Agent Layer)
├── Load: Full context manifest (~10k+ tokens)
├── Purpose: Actually perform the work
└── Contains: Tool guides, domain knowledge, format templates
```

**Total overhead from progressive loading**: ~500 tokens (3% of typical agent budget)
**Benefit**: Fail-fast routing, validated returns, cleaner error messages

## Integration with Checkpoint Model

This progressive loading integrates with research-002's checkpoint model:

```
CHECKPOINT 1 (GATE IN):
├── Context: routing.md (~200 tokens)
└── Validation: Task exists, status allows operation

DELEGATION TO AGENT:
├── Context: Full agent manifest
└── Execution: Research/Plan/Implement

CHECKPOINT 2 (GATE OUT):
├── Context: validation.md (already loaded)
└── Validation: Return matches schema

CHECKPOINT 3 (COMMIT):
├── Context: git patterns (from CLAUDE.md)
└── Action: Stage, commit, verify
```

## Conclusion

The pure "no context until agent" approach in research-003 is directionally correct but **too extreme**. Industry best practices from Anthropic and the Claude Code community support a **minimal progressive loading** approach where:

1. Each layer gets exactly the context it needs for its specific responsibility
2. The bulk of context (~95%) is still loaded at the agent level
3. Small amounts of routing and validation context enable fail-fast behavior
4. Pointers are preferred over copies at routing/orchestration layers

This hybrid approach balances token efficiency with operational robustness.

## References

- [Claude Code: Best practices for agentic coding](https://www.anthropic.com/engineering/claude-code-best-practices)
- [Effective context engineering for AI agents](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)
- [How we built our multi-agent research system](https://www.anthropic.com/engineering/multi-agent-research-system)
- [How I Organized My CLAUDE.md in a Monorepo](https://dev.to/anvodev/how-i-organized-my-claudemd-in-a-monorepo-with-too-many-contexts-37k7)
- [Claude's Context Engineering Playbook](https://01.me/en/2025/12/context-engineering-from-claude/)
- [Claude Code - Context Management](https://claudecode.io/guides/context-management)

## Next Steps

1. Decide whether to adopt minimal progressive loading vs agent-only loading
2. If progressive: Create routing.md and validation.md context files
3. Update skill files to reference validation.md
4. Update command documentation to reference routing.md
5. Establish token budget monitoring
