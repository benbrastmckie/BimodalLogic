# Research Report: Task #529 (Part 2)

**Task**: 529 - Unify Workflow Commands into Single-Execution Pattern
**Focus**: Compare preflight/postflight locations and align with Claude Code 2026 best practices
**Started**: 2026-01-17T14:10:00Z
**Completed**: 2026-01-17T14:30:00Z
**Session ID**: sess_1768659082_0813e6
**Effort**: 4-6 hours (implementation estimate)
**Priority**: High
**Sources/Inputs**:
- [Claude Code: Best practices for agentic coding](https://www.anthropic.com/engineering/claude-code-best-practices)
- [Create custom subagents - Claude Code Docs](https://code.claude.com/docs/en/sub-agents)
- [Claude Code Agent Architecture - ZenML](https://www.zenml.io/llmops-database/claude-code-agent-architecture-single-threaded-master-loop-for-autonomous-coding)
- Current skill and agent files in `.claude/`
**Artifacts**: - specs/529_unify_workflow_commands_single_execution/reports/research-002.md

## Executive Summary

Comparing four locations for preflight/postflight status updates:

| Location | Skill Invocations | Halt Risk | Matches Best Practices |
|----------|------------------|-----------|------------------------|
| **In Command (inline)** | 1 | Low | ⚠️ Partial |
| **In Skill (thin wrapper)** | 1 | Medium | ✅ Yes |
| **In Agent (delegated)** | 1 | Medium | ⚠️ Partial |
| **Current (separate skill)** | 3 | High | ❌ No |

**Recommendation**: **Option B: In Skill** - Move preflight/postflight into the research/plan/implement skills themselves. This aligns with Claude Code 2026 patterns where skills are "self-contained workflows" and keeps commands as thin routers.

## Context: Claude Code 2026 Architecture Patterns

### Single-Threaded Master Loop

Claude Code uses a "simple while-loop pattern" where execution continues as long as responses include tool calls; plain text without tool invocations terminates the loop naturally. This means:

> "A simple, single-threaded master loop combined with disciplined tools and planning delivers controllable autonomy."
> — [ZenML Analysis](https://www.zenml.io/llmops-database/claude-code-agent-architecture-single-threaded-master-loop-for-autonomous-coding)

**Implication**: Fewer Skill invocations = less risk of loop termination.

### Skills vs Subagents in 2026

From the [official subagent documentation](https://code.claude.com/docs/en/sub-agents):

| Aspect | Skills | Subagents |
|--------|--------|-----------|
| **Context** | Run in main conversation | Run in isolated context |
| **State** | Main conversation context | Fresh per invocation |
| **Use when** | Reusable workflows in main context | Verbose output or tool restrictions |

Key guidance:
> "Use **Skills** when you want reusable prompts or workflows that run in the main conversation context rather than isolated subagent context."

**Implication**: Skills should be self-contained workflows, not thin pass-throughs that require additional skill invocations.

### Subagent State Management

> "Subagents do not maintain persistent state between invocations. Each subagent invocation creates a new instance with fresh context."

**Implication**: Subagents cannot own preflight/postflight because they start fresh each time. The skill or command must handle state transitions.

## Options Analysis

### Option A: Inline in Command

**Pattern**:
```
/research N
├── GATE IN: Bash/jq inline status update
├── DELEGATE: Skill(skill-researcher)
├── GATE OUT: Bash/jq inline status update
└── COMMIT: Bash git commit
```

**Pros**:
- Complete control in one place
- No additional skill invocations
- Demonstrated to work in research-001.md session

**Cons**:
- Commands become longer (~50 lines of jq/Edit)
- Duplication across research.md, plan.md, implement.md
- Commands should be thin routers, not workflow executors
- Violates "skills as self-contained workflows" principle

**Skill invocations**: 1

### Option B: In Skill (Recommended)

**Pattern**:
```
/research N
└── DELEGATE: Skill(skill-researcher)
    ├── Preflight: Inline status update
    ├── Agent: Task(general-research-agent)
    ├── Postflight: Inline status update
    └── Return with artifacts

(Command does COMMIT only)
```

**Pros**:
- Skills become truly self-contained workflows
- Commands stay thin (router + commit)
- Consistent with "skills as workflows" principle
- Single responsibility: skill owns the entire research/plan/implement lifecycle
- Reusable: same skill can be invoked from multiple entry points

**Cons**:
- Skills become longer (~100 lines with state management)
- Need to update all 6 implementation skills

**Skill invocations**: 1

**Alignment with Best Practices**:

From [Anthropic's best practices](https://www.anthropic.com/engineering/claude-code-best-practices):
> "A Skill is a folder that contains instructions and resources for specific tasks—think of it as a reference guide that Claude consults when working on something that matches the skill's domain."

A skill that handles research should handle the entire research lifecycle, including status transitions.

### Option C: In Agent

**Pattern**:
```
/research N
└── DELEGATE: Skill(skill-researcher)
    └── Agent: Task(general-research-agent)
        ├── Preflight: Bash/jq
        ├── Research work
        ├── Postflight: Bash/jq
        └── Return
```

**Pros**:
- Agents fully own their lifecycle
- Skill becomes even thinner

**Cons**:
- Agents start fresh each invocation - no persistent state
- Agent would need to load state.json context every time
- Violates subagent isolation principle
- If agent fails mid-execution, status may be inconsistent
- Agents are for "verbose output or tool restrictions", not state management

**Skill invocations**: 1

**Why Not Recommended**:
> "Subagents do not maintain persistent state between invocations."

Making agents responsible for state management goes against their design as isolated workers.

### Option D: Current Pattern (3 Skills)

**Pattern**:
```
/research N
├── GATE IN: Skill(skill-status-sync) preflight    ← HALT RISK
├── DELEGATE: Skill(skill-researcher)              ← HALT RISK
├── GATE OUT: Skill(skill-status-sync) postflight  ← HALT RISK
└── COMMIT: Bash
```

**Pros**:
- Separation of concerns (status-sync is reusable)
- Clear checkpoint boundaries

**Cons**:
- 3 skill invocations = 3 potential halt points
- Evidence shows halting occurs even with anti-stop patterns
- Over-engineered for the actual complexity

**Skill invocations**: 3

## Recommendation: Option B (In Skill)

### Rationale

1. **Matches Claude Code 2026 Architecture**
   - Skills as "self-contained workflows"
   - Commands as thin routers
   - Single skill invocation minimizes halt risk

2. **Clean Separation of Concerns**
   - Commands: Route and commit
   - Skills: Own the entire lifecycle (preflight → delegate → postflight)
   - Agents: Isolated work units

3. **Reduces Complexity**
   - skill-status-sync becomes optional (for debugging/manual use)
   - Commands shrink to ~20 lines
   - One place to understand each workflow

4. **Proven Pattern**
   - Claude Code's built-in `/commit` skill owns its entire workflow
   - Anthropic's example skills are self-contained

### Implementation Architecture

#### Command (thin router):
```markdown
## Execution

### Route and Delegate
Invoke skill-researcher with task context and session ID.
The skill handles preflight, agent delegation, and postflight internally.

### Commit (on success)
```bash
git add -A && git commit -m "task {N}: complete research"
```
```

#### Skill (self-contained workflow):
```markdown
## Execution

### 1. Preflight (inline)
```bash
# Update state.json to "researching"
jq '(.active_projects[] | select(.project_number == $N)) |= . + {status: "researching"}' ...

# Update TODO.md status marker
# (use Edit tool)
```

### 2. Delegate to Agent
```
Task(general-research-agent, prompt="{context}")
```

### 3. Postflight (inline)
```bash
# Update state.json to "researched"
jq '(.active_projects[] | select(.project_number == $N)) |= . + {status: "researched"}' ...

# Update TODO.md with artifact link
# (use Edit tool)
```

### 4. Return
Return standardized JSON with artifacts.
```

## Files to Modify

### Commands (simplify):
- `.claude/commands/research.md` - Remove GATE IN/OUT, keep route + commit
- `.claude/commands/plan.md` - Same
- `.claude/commands/implement.md` - Same

### Skills (add lifecycle):
- `.claude/skills/skill-researcher/SKILL.md` - Add preflight/postflight
- `.claude/skills/skill-lean-research/SKILL.md` - Add preflight/postflight
- `.claude/skills/skill-planner/SKILL.md` - Add preflight/postflight
- `.claude/skills/skill-implementer/SKILL.md` - Add preflight/postflight
- `.claude/skills/skill-lean-implementation/SKILL.md` - Add preflight/postflight
- `.claude/skills/skill-latex-implementation/SKILL.md` - Add preflight/postflight

### Documentation:
- `.claude/skills/skill-status-sync/SKILL.md` - Mark as deprecated for workflow use
- `.claude/context/core/patterns/skill-lifecycle.md` - NEW: Document pattern

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Skills become longer | Medium | Create reusable snippet patterns |
| Inconsistent implementations | Medium | Use single template for all skills |
| skill-status-sync orphaned | Low | Keep for debugging and direct invocation |
| Agent failures leave bad state | Medium | Wrap agent call in try/catch, postflight only on success |

## Success Criteria

After implementation:
- [ ] Commands are <30 lines each
- [ ] Each skill handles preflight/delegate/postflight internally
- [ ] Workflows complete without "continue" prompts
- [ ] Only 1 Skill invocation per command
- [ ] skill-status-sync works for standalone use

## Appendix: Source References

### Claude Code Official Documentation
- [Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices)
- [Subagents](https://code.claude.com/docs/en/sub-agents)

### Architecture Analysis
- [ZenML: Single-Threaded Master Loop](https://www.zenml.io/llmops-database/claude-code-agent-architecture-single-threaded-master-loop-for-autonomous-coding)

### Current Implementation
- `.claude/skills/skill-researcher/SKILL.md` - Current thin wrapper
- `.claude/skills/skill-status-sync/SKILL.md` - Current status management
- `.claude/commands/research.md` - Current 3-skill pattern
