# Skills vs Agents: Context Behavior and Architectural Guidance

**Last Updated**: 2026-01-18
**Research Source**: specs/research_skill_agent_contexts/reports/research-001.md

## Executive Summary

This document clarifies how Claude Code skills and agents handle context, and provides architectural guidance for when to use each pattern in the ProofChecker development system.

**Key Findings**:
1. Skills execute in the main conversation context by default (shared history, shared token budget)
2. Skills can spawn isolated contexts using `context: fork` (separate conversation, separate tokens)
3. Subagents (via Task tool) always run in isolated contexts
4. The current forked subagent pattern is architecturally correct for workflow operations

---

## Context Behavior Deep Dive

### 1. Default Skill Execution

**Skills run in the main conversation context by default**:

```yaml
---
name: example-skill
description: Simple guidance skill
allowed-tools: Read, Grep
---

# Example Skill

This skill's instructions are injected directly into the main conversation.
```

**Characteristics**:
- ✅ Shares conversation history with user
- ✅ Can reference previous messages and context
- ✅ Allows live iteration with user
- ❌ Consumes tokens from main context window
- ❌ Context accumulates in parent conversation
- ❌ All instructions visible in transcript

**Best for**:
- Quick validations or checks
- Guidance and standards injection
- Operations requiring user interaction
- Short, stateless operations (< 100 tokens output)

### 2. Forked Skill Execution

**Skills with `context: fork` spawn isolated subprocess**:

```yaml
---
name: example-research-skill
description: Research a complex topic
allowed-tools: Task
context: fork
agent: general-research-agent
---

# Example Research Skill

This skill spawns an isolated agent context.
```

**Characteristics**:
- ✅ Isolated conversation history (separate window)
- ✅ Only results return to parent
- ✅ Prevents context accumulation in main conversation
- ✅ Can specify target agent type
- ❌ No live iteration with user
- ❌ Cannot access parent conversation details

**Best for**:
- Complex multi-step workflows
- Operations consuming significant context (> 1000 tokens)
- Tasks requiring specialized tool access
- Long-running operations with structured outputs

### 3. Subagent Execution (Task Tool)

**Subagents always run in isolated contexts**:

```python
# Invoked via Task tool from skill or main conversation
Task(
    subagent_type="general-research-agent",
    prompt="Research X and return findings",
    description="Research task"
)
```

**Characteristics**:
- ✅ Fully isolated context window
- ✅ Custom system prompt and tool access
- ✅ Independent permission scope
- ✅ Transcripts persist at `~/.claude/projects/{project}/{sessionId}/subagents/`
- ✅ Unaffected by main conversation compaction
- ❌ Cannot spawn nested subagents (one level only)
- ❌ Must explicitly declare skill dependencies

**Best for**:
- Maximum isolation required
- Domain-specific tooling (Lean MCP, LaTeX, etc.)
- Reusable across multiple entry points
- Complex return value requirements

---

## Context Comparison Table

| Aspect | Skills (default) | Skills (`context: fork`) | Subagents (Task tool) |
|--------|-----------------|-------------------------|-----------|
| **Context Window** | Main conversation | Isolated subprocess | Isolated subprocess |
| **Token Budget** | Shared with parent | Separate | Separate |
| **Discovery** | Auto-triggered | Auto-triggered | Explicit delegation |
| **User Iteration** | Live, interactive | Results only | Results only |
| **Tool Access** | Via `allowed-tools` | Via agent type + `allowed-tools` | Via agent definition |
| **Skill Inheritance** | Full access | Injected at startup | Must declare explicitly |
| **Nesting** | Can use nested skills | One level (skill→agent) | Cannot nest (agent→agent) |
| **Transcript** | Main conversation | Separate file | Separate file |
| **Compaction** | Affects skill context | Independent | Independent |

---

## ProofChecker Architecture Analysis

### Current Pattern: Forked Subagent Delegation

The ProofChecker system uses this pattern for workflow operations:

```yaml
# skill-researcher/SKILL.md
---
name: skill-researcher
description: Conduct general research using web search and codebase exploration
allowed-tools: Task
context: fork
agent: general-research-agent
---

# Researcher Skill

## Execution
Delegates to general-research-agent in isolated context.
```

**Flow**:
```
┌─────────────────────────────────────────────────────────┐
│ Main Conversation (~100 tokens)                         │
│                                                          │
│  User: /research 345                                    │
│    ↓                                                     │
│  Orchestrator validates task                            │
│    ↓                                                     │
│  Skill invoked (context: fork)                          │
│    ↓                                                     │
│  ┌────────────────────────────────────────────┐        │
│  │ FORK → Isolated Context (5000+ tokens)     │        │
│  │                                             │        │
│  │  Agent loads research context               │        │
│  │  Agent searches web, reads files            │        │
│  │  Agent writes report                        │        │
│  │  Agent returns JSON result                  │        │
│  └────────────────────────────────────────────┘        │
│    ↓                                                     │
│  Orchestrator receives: {status, artifacts, next_steps} │
│    ↓                                                     │
│  Update TODO.md, state.json                             │
│    ↓                                                     │
│  Git commit with session_id                             │
└─────────────────────────────────────────────────────────┘
```

### Why This Pattern is Optimal

**For ProofChecker workflow operations**:

1. **Token Efficiency**
   - Research/planning/implementation consume 5,000-20,000 tokens
   - Forked context prevents accumulation in main conversation
   - Main conversation stays lean for orchestration

2. **Context Isolation**
   - Multi-step operations don't clutter user-facing conversation
   - Agent failures don't pollute main context
   - Clear separation: orchestrator = routing, agent = execution

3. **Structured Returns**
   - JSON format enables validation at orchestrator level
   - Standard `subagent-return.md` schema
   - Enables checkpoint-based execution model

4. **Reusability**
   - Same agent callable from multiple skills
   - Same agent callable directly via Task tool
   - Agent testable independently

5. **Specialization**
   - Lean agents use lean-lsp MCP tools
   - LaTeX agents use pdflatex tooling
   - General agents use web search
   - Language-based routing via state.json

---

## Architectural Decision Guide

### When to Use Direct Skills (No Fork)

**Pattern**:
```yaml
---
name: skill-validator
description: Validate task state
allowed-tools: Read
---
```

**Use when**:
- ✅ Operation is stateless and simple
- ✅ Output is < 100 tokens
- ✅ No specialized tool requirements
- ✅ User iteration is beneficial
- ✅ Context loading is minimal

**Examples in ProofChecker**:
- `skill-status-sync` - Atomic state updates
- Future: `skill-task-validator` - Quick checks
- Future: `skill-git-message-generator` - Template rendering

### When to Use Forked Skills

**Pattern**:
```yaml
---
name: skill-researcher
description: Research complex topics
allowed-tools: Task
context: fork
agent: general-research-agent
---
```

**Use when**:
- ✅ Operation is multi-step and complex
- ✅ Output is > 1000 tokens
- ✅ Requires specialized tools or context
- ✅ Results-only return is sufficient
- ✅ Context isolation is valuable

**Examples in ProofChecker**:
- `skill-researcher` - Web search, file reading
- `skill-planner` - Multi-file analysis, phased planning
- `skill-implementer` - File modifications, testing
- `skill-lean-research` - Lean MCP tool usage
- `skill-lean-implementation` - Proof construction

### When to Use Subagents Directly

**Pattern**:
```python
# From main conversation or another skill
Task(subagent_type="lean-research-agent", ...)
```

**Use when**:
- ✅ Maximum isolation required
- ✅ Not triggered by description (manual delegation)
- ✅ Callable from multiple contexts
- ✅ Domain-specific system prompt needed
- ✅ Complex tool orchestration

**Examples in ProofChecker**:
- Direct invocation for ad-hoc research
- Debugging agent behavior
- Testing new agent implementations

---

## Critical Constraint: No Nested Subagents

**Rule**: Subagents cannot spawn other subagents.

From official documentation:
> "Subagents cannot spawn other subagents. If your workflow requires nested delegation, use Skills or chain subagents from the main conversation."

### Implications for ProofChecker

**Current architecture is compliant**:
```
Main Conversation
  ↓
Skill (context: fork)
  ↓
Agent (executes work)
  ✗ Cannot spawn another agent
```

**If nested delegation is needed**:

**Option A: Chain from main conversation**
```
Main Conversation
  ├─→ Agent A (research)
  │    ↓ returns results
  ├─→ Agent B (plan, uses A's results)
  │    ↓ returns results
  └─→ Agent C (implement, uses B's results)
```

**Option B: Use skills within agent context**
```
Main Conversation
  ↓
Skill (context: fork)
  ↓
Agent (can invoke skills, but not other agents)
  ↓
Nested Skill (runs in agent's context)
```

**Current ProofChecker pattern (orchestration in main)**:
```bash
/research 345  # spawns lean-research-agent
/plan 345      # spawns planner-agent (uses research artifacts)
/implement 345 # spawns lean-implementation-agent (uses plan)
```

This is correct - each agent is independent, orchestration happens in main conversation.

---

## Performance Considerations

### Token Budget Analysis

**Main conversation tokens** (per command cycle):
- Orchestrator logic: ~200 tokens
- Skill invocation: ~100 tokens
- Return validation: ~50 tokens
- State updates: ~100 tokens
- **Total per cycle**: ~450 tokens

**Forked agent tokens** (isolated, doesn't accumulate):
- Research agent: 5,000-15,000 tokens
- Planner agent: 3,000-10,000 tokens
- Implementation agent: 10,000-30,000 tokens per phase

**Token savings from forking**:
- Without fork: 450 + 15,000 = 15,450 tokens accumulate in main
- With fork: 450 tokens in main, 15,000 tokens isolated (discarded after return)
- **Savings per command**: ~15,000 tokens
- **Savings over 10 tasks**: ~150,000 tokens

### Context Window Impact

**Main conversation compaction**:
- Forked skills don't count toward main conversation compaction threshold
- Agent transcripts persist independently at `~/.claude/projects/{project}/{sessionId}/subagents/`
- Main conversation can stay under compaction limit for entire session

**Subagent transcript persistence**:
- Transcripts saved as `agent-{agentId}.jsonl`
- Useful for debugging agent behavior
- Can be inspected with `tail -f ~/.claude/projects/*/subagents/*.jsonl`

---

## Refactoring Recommendations

### Current Skills: Keep As-Is (Forked Pattern)

These benefit from context isolation and should remain forked:

| Skill | Agent | Reason |
|-------|-------|--------|
| skill-researcher | general-research-agent | Web search, multi-file reads (high token) |
| skill-lean-research | lean-research-agent | Lean MCP tools, proof search (specialized) |
| skill-planner | planner-agent | Multi-file analysis, phased planning (high token) |
| skill-implementer | general-implementation-agent | File modifications, testing (high token) |
| skill-lean-implementation | lean-implementation-agent | Proof construction, tactic search (specialized) |
| skill-latex-implementation | latex-implementation-agent | LaTeX compilation, PDF generation (specialized) |
| skill-meta | meta-builder-agent | System analysis, task creation (high token) |
| skill-document-converter | document-converter-agent | Format conversion (specialized) |

### Current Skills: Already Direct (Correct)

| Skill | Reason |
|-------|--------|
| skill-status-sync | Atomic state updates (< 50 tokens) |
| skill-git-workflow | Template-based commit messages (< 100 tokens) |
| skill-orchestrator | Routing logic only (< 200 tokens) |

### Potential New Direct Skills

Consider adding these as direct (non-forked) skills:

1. **skill-task-validator**: Quick task existence checks
2. **skill-artifact-linker**: Update TODO.md with artifact paths
3. **skill-language-detector**: Determine task language from description
4. **skill-phase-tracker**: Mark phases complete in plan files

All are < 100 token operations with no specialized tools.

---

## Migration Guide (If Needed)

### Converting Forked Skill to Direct

**Before**:
```yaml
---
name: skill-example
description: Example skill
allowed-tools: Task
context: fork
agent: example-agent
---
```

**After**:
```yaml
---
name: skill-example
description: Example skill
allowed-tools: Read, Write, Edit
---

# Example Skill

{Direct implementation instructions}
```

**When to do this**:
- Agent execution is consistently < 100 tokens
- No specialized tools required
- User iteration would be beneficial

### Converting Direct Skill to Forked

**Before**:
```yaml
---
name: skill-example
description: Example skill
allowed-tools: Read, Write, Edit
---
```

**After**:
```yaml
---
name: skill-example
description: Example skill
allowed-tools: Task
context: fork
agent: example-agent
---

# Example Skill

Delegates to example-agent in isolated context.
```

**When to do this**:
- Token usage exceeds 500 tokens per invocation
- Multiple tool orchestration required
- Context isolation would improve debuggability

---

## Best Practices Summary

### ✅ DO

1. **Use forked skills for workflow operations** (research, plan, implement)
2. **Use direct skills for simple validations** (< 100 tokens)
3. **Return structured JSON from agents** (enables validation)
4. **Keep orchestration in main conversation** (don't nest agents)
5. **Persist agent transcripts for debugging** (~/.claude/projects/)
6. **Document context budget in skill frontmatter**

### ❌ DON'T

1. **Don't nest subagents** (agent→agent not allowed)
2. **Don't fork simple operations** (wastes subprocess overhead)
3. **Don't load context eagerly in forked skills** (defeats purpose)
4. **Don't accumulate agent output in main** (use structured returns)
5. **Don't use forking for user-interactive tasks** (breaks iteration)

---

## Reference Architecture

### Current ProofChecker Thin Wrapper Pattern

```yaml
# skill-researcher/SKILL.md
---
name: skill-researcher
description: Research general tasks using web search and codebase exploration
allowed-tools: Task
context: fork
agent: general-research-agent
---

# Researcher Skill

## Trigger Conditions
Invoked when task language is "general" and status is "not_started"

## Execution
1. Validate task exists and status allows research
2. Prepare delegation context with session_id
3. Invoke general-research-agent via Task tool
4. Validate return matches subagent-return.md schema
5. Return structured result to orchestrator

## Return Format
```json
{
  "status": "researched",
  "summary": "...",
  "artifacts": [{"type": "report", "path": "..."}],
  "metadata": {"session_id": "..."},
  "next_steps": "..."
}
```
```

**Benefits**:
- 🎯 Skill = routing (100 tokens in main)
- 🎯 Agent = execution (10,000 tokens isolated)
- 🎯 Clear separation of concerns
- 🎯 Reusable agent across contexts
- 🎯 Testable in isolation

---

## Debugging Tools

### Inspecting Agent Transcripts

```bash
# Find agent transcripts
find ~/.claude/projects -name "*.jsonl" -type f

# Watch agent execution live
tail -f ~/.claude/projects/*/subagents/agent-*.jsonl

# Search for specific session
grep "sess_1736700000" ~/.claude/projects/*/subagents/*.jsonl
```

### Comparing Main vs Agent Context

```bash
# Main conversation tokens (approximate)
wc -w ~/.claude/projects/ProofChecker/*/conversation.jsonl

# Agent conversation tokens (isolated)
wc -w ~/.claude/projects/ProofChecker/*/subagents/agent-*.jsonl
```

---

## Official Documentation References

1. [Claude Code Subagents Documentation](https://code.claude.com/docs/en/sub-agents)
   - Official Anthropic docs on subagent behavior

2. [Claude Code Skills Documentation](https://code.claude.com/docs/en/skills)
   - Official docs on skill execution and `context: fork`

3. [Equipping agents for the real world with Agent Skills](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills)
   - Anthropic engineering blog on progressive disclosure

4. [Claude Code Customization Guide](https://alexop.dev/posts/claude-code-customization-guide-claudemd-skills-subagents/)
   - Third-party technical analysis of skills vs subagents

---

## Conclusion

**Your current architecture is sound.** The forked subagent pattern is the correct choice for ProofChecker's workflow operations because:

1. Token efficiency (150K+ tokens saved per session)
2. Context isolation (clean orchestration layer)
3. Specialization (language-specific tooling)
4. Reusability (agents callable from multiple contexts)
5. Maintainability (clear skill→agent boundary)

**No refactoring needed** for existing workflow skills. Consider adding direct skills only for simple, stateless operations (< 100 tokens) where user iteration is beneficial.

**Key takeaway**: Skills execute in main context by default, but `context: fork` creates isolated subprocesses. Your use of forked skills for complex workflows is exactly the pattern recommended by Anthropic's official documentation.
