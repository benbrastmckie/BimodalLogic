# Research Report: Claude Code Skills vs Agents - Context Behavior

**Research Question**: Do Claude Code skills spawn new conversation contexts, or do they persist in the existing context?

**Started**: 2026-01-18
**Completed**: 2026-01-18
**Sources**: Claude Code official documentation, Anthropic engineering blog, codebase analysis

---

## Executive Summary

1. **Skills execute in the main conversation context by default** - they share the conversation history and context window
2. **Skills can spawn isolated contexts using `context: fork`** - this creates a subagent with its own context window
3. **Subagents (agents) always run in isolated contexts** - they have separate context windows and return only results to the parent
4. The user's current architecture correctly uses the forked subagent pattern for token efficiency

---

## Findings

### 1. Default Skill Execution Behavior

**Skills run in the main conversation context by default**:

From [Claude Code Skills Documentation](https://code.claude.com/docs/en/skills):
> "Skills add knowledge to the current conversation. Subagents run in a separate context with their own tools."

From [Claude Code Customization Guide](https://alexop.dev/posts/claude-code-customization-guide-claudemd-skills-subagents/):
> "Skills are auto-discovered and typically get applied when Claude decides they match the current task. They run in your main conversation, so you can iterate live."

**Key characteristics of default skill execution**:
- Shares conversation history with user
- Consumes tokens from the main context window
- Can reference previous messages and context
- Allows live iteration with user
- Instructions are injected into the conversation as new messages

### 2. The `context: fork` Option

Skills can spawn isolated contexts using the `context: fork` metadata field:

```yaml
---
name: code-analysis
description: Analyze code quality and generate detailed reports
context: fork
agent: general-research-agent  # Optional: specify which agent type
---
```

**What `context: fork` does**:
- Creates an **isolated sub-agent context** with its own conversation history
- Prevents multi-step operations from cluttering the main conversation
- The forked agent completes its task independently
- Only results are returned to the main conversation

**Supported agent types for forked execution**:
- `Explore` - Read-only codebase exploration
- `Plan` - Research agent for planning
- `general-purpose` - Full-capability agent (default)
- Custom agents from `.claude/agents/`

### 3. Subagent (Agent) Context Behavior

**Subagents always run in isolated contexts**. From [Claude Code Subagents Documentation](https://code.claude.com/docs/en/sub-agents):

> "Each subagent runs in its own context window with a custom system prompt, specific tool access, and independent permissions."

**Isolation details**:
- Separate context window from parent conversation
- Own conversation history stored at `~/.claude/projects/{project}/{sessionId}/subagents/agent-{agentId}.jsonl`
- Subagent transcripts persist independently of main conversation
- When main conversation compacts, subagent transcripts are unaffected
- Inherit permission context but can override permission mode
- Do NOT inherit skills from parent conversation by default

**Critical constraint**:
> "Subagents cannot spawn other subagents. If your workflow requires nested delegation, use Skills or chain subagents from the main conversation."

### 4. Skills vs Subagents Comparison

| Aspect | Skills (default) | Skills (`context: fork`) | Subagents |
|--------|-----------------|-------------------------|-----------|
| **Context** | Main conversation | Isolated fork | Isolated context |
| **Discovery** | Auto-triggered by description | Auto-triggered | Delegated via Task tool |
| **Iteration** | Live with user | Results returned | Results returned |
| **Skill Access** | Full access | Injected at startup | Must declare explicitly |
| **Tool Access** | Via `allowed-tools` | Via `allowed-tools` + agent type | Own tool config |
| **Nesting** | Can use nested skills | One level | Cannot nest |
| **Best For** | Guidance, standards | Complex multi-step workflows | Isolated task execution |

### 5. Analysis of User's Current Architecture

The user's `.claude/` system uses a **forked subagent pattern** that is architecturally sound:

**Pattern observed in codebase**:
```yaml
# From skill-researcher/SKILL.md
---
name: skill-researcher
description: Conduct general research...
allowed-tools: Task
context: fork
agent: general-research-agent
---
```

**Benefits of this pattern**:
1. **Token efficiency**: Context loaded only in subagent, not parent conversation
2. **Isolation**: Subagent context doesn't accumulate in parent
3. **Reusability**: Same agent callable from multiple entry points
4. **Maintainability**: Clear separation (skill = routing, agent = execution)
5. **Testability**: Subagents testable independently

**Current flow**:
```
Parent Context (~100 tokens)
├── Skill (thin wrapper)
│   └── Input validation
│   └── Delegation via Task tool
│
└─── [Fork] ────────────────────────┐
                                    ▼
                        Forked Context (Isolated)
                        ├── Subagent loads own context
                        ├── Executes full workflow
                        └── Returns structured JSON
```

### 6. Architectural Recommendations

**When to use direct skill execution (no fork)**:
- Simple guidance or standards injection
- Quick validations or checks
- Tasks requiring user iteration
- Short, context-light operations

**When to use `context: fork` with skills**:
- Complex multi-step workflows
- Operations that would consume significant context
- Tasks requiring specialized tool access
- Long-running operations

**When to delegate to custom agents**:
- Maximum isolation needed
- Complex return value requirements
- Reuse across multiple skills
- Domain-specific tooling (e.g., Lean MCP tools)

**The user's current pattern is optimal** for their use case because:
1. Workflow operations (research, plan, implement) are context-heavy
2. They require specialized tools per language
3. Structured JSON returns enable orchestrator validation
4. Token efficiency is important for long sessions

---

## Decisions

Based on this research:

1. **Skills DO share parent context by default** - but this can be changed with `context: fork`
2. **The user's forked subagent pattern is correct** for complex workflow operations
3. **Direct skill implementation makes sense for**:
   - Simple, stateless operations (like `skill-status-sync`)
   - Operations that need access to parent conversation context
   - Quick validations or checks
4. **Agent delegation makes sense for**:
   - Complex, multi-step workflows
   - Operations requiring isolated context
   - Tasks with specialized tool requirements

---

## Official Sources

1. [Claude Code Subagents Documentation](https://code.claude.com/docs/en/sub-agents) - Official Anthropic documentation on subagent behavior
2. [Claude Code Skills Documentation](https://code.claude.com/docs/en/skills) - Official documentation on skill execution
3. [Equipping agents for the real world with Agent Skills](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills) - Anthropic engineering blog
4. [Claude Code Customization Guide](https://alexop.dev/posts/claude-code-customization-guide-claudemd-skills-subagents/) - Third-party technical analysis

---

## Appendix: Key Quotes from Official Documentation

### On Skill Context (default)
> "Skills add knowledge to the current conversation, while subagents run in a separate context with their own tools. Use Skills for guidance and standards; use subagents when you need isolation or different tool access."

### On `context: fork`
> "You can use `context: fork` to run a Skill in an isolated sub-agent context with its own conversation history. This is useful for Skills that perform complex multi-step operations without cluttering the main conversation."

### On Subagent Isolation
> "Each subagent runs in its own context window with a custom system prompt, specific tool access, and independent permissions."

### On Subagent Nesting Limits
> "Subagents cannot spawn other subagents. If your workflow requires nested delegation, use Skills or chain subagents from the main conversation."

### On Progressive Disclosure
> "Progressive disclosure is the core design principle that makes Agent Skills flexible and scalable. Like a well-organized manual that starts with a table of contents, then specific chapters, and finally a detailed appendix, skills let Claude load information only as needed."
