# Research Report: Task #619

**Task**: 619 - agent_system_architecture_upgrade
**Started**: 2026-01-19T20:38:00Z
**Completed**: 2026-01-19T20:55:00Z
**Effort**: Medium (research phase)
**Priority**: Medium
**Dependencies**: None
**Sources/Inputs**: Codebase analysis, WebSearch (Claude Code 2026 best practices), Anthropic documentation
**Artifacts**: This report
**Standards**: report-format.md, subagent-return.md

---

## Executive Summary

- Current ProofChecker agent system already follows most 2026 best practices (three-layer architecture, lazy context loading, file-based metadata exchange)
- Key improvement areas: reduce CLAUDE.md from 385 to ~100 lines, adopt Claude Code native subagent features, enhance metadata passing via specs/state.json
- Context forking is NOT a Claude Code feature in the traditional sense; instead, use native subagent delegation with `context: fork` frontmatter pattern for proper context isolation
- Recommended approach: incremental migration preserving working patterns while adopting native subagent capabilities

---

## Context & Scope

### Research Questions

1. What are Claude Code best practices in 2026 for agent systems?
2. How can progressive disclosure be improved in the current system?
3. What context engineering techniques reduce primary agent context pollution?
4. Does Claude Code support "context forking" in skills, and how should it be used?
5. How can metadata passing via specs/state.json be enhanced?

### Constraints

- System is currently working well; focus on incremental improvements
- Must maintain backward compatibility with existing workflows
- Token efficiency is paramount given context window limitations

---

## Findings

### Finding 1: CLAUDE.md is Over-Bloated

**Current State**: The main `.claude/CLAUDE.md` file is 385 lines, significantly exceeding the recommended <300 lines (ideally <50-60 lines for always-loaded content).

**Best Practice** (from Anthropic and alexop.dev):
- Keep CLAUDE.md under 50-60 lines for universal context
- Use progressive disclosure: point to specialized documentation
- Each token competes with conversation history
- "Context engineering is the discipline of optimizing token utility"

**Evidence**: Current CLAUDE.md includes:
- Full skill-to-agent mapping tables (could be loaded on-demand)
- Detailed session maintenance instructions
- Complete routing tables
- Git commit conventions (could reference rules file)

**Recommendation**: Create a minimal CLAUDE.md (~50-100 lines) with:
- Project overview (5-10 lines)
- Quick reference pointers
- Essential commands
- References to specialized docs for everything else

### Finding 2: Native Claude Code Subagent Support

**Discovery**: Claude Code now has native subagent support with file-based configuration in `.claude/agents/`.

**Key Features** (from Claude Code official docs):
- YAML frontmatter with `name`, `description`, `tools`, `model`, `permissionMode`, `skills`
- Automatic delegation based on task description matching
- Session isolation: each subagent operates in its own context window
- Session persistence: subagent transcripts persist independently
- Auto-compaction: subagents auto-compact at ~95% capacity
- Background execution: subagents can run concurrently

**Current System vs. Native**:
| Aspect | Current System | Native Claude Code |
|--------|----------------|-------------------|
| Agent definition | Custom YAML + markdown | Standard frontmatter |
| Delegation | Via Task tool | Automatic based on description |
| Context isolation | Implicit via Task | Explicit via isolated context |
| Session tracking | Manual session_id | Built-in session persistence |
| Parallel execution | Not supported | Native background subagents |

**Recommendation**: Consider migrating to native subagent patterns for:
- Built-in session persistence
- Automatic context isolation
- Parallel execution capability
- Reduced custom infrastructure

### Finding 3: Context Forking Clarification

**Important Clarification**: The phrase "context forking" has been used in the current system documentation, but Claude Code's actual mechanism is different.

**Claude Code Pattern** (from official docs):
- Subagents do NOT inherit skills from parent conversation
- Skills must be loaded explicitly via `skills:` frontmatter
- Each subagent starts with fresh context
- There is no literal "fork" of parent context

**Current System Usage**:
- The thin-wrapper-skill.md mentions `context: fork` and `agent:` frontmatter fields
- However, actual skills (e.g., skill-researcher) note "Skills do NOT use `context: fork` or `agent:` frontmatter fields"

**Recommendation**: Remove references to `context: fork` from documentation since:
1. It's not an actual Claude Code feature
2. Current skills already don't use it
3. Subagent context isolation is achieved through Task tool delegation

### Finding 4: Progressive Disclosure Architecture

**Best Practice** (from Anthropic docs):
```
Layer 1 (Metadata): Name + description only (at startup)
Layer 2 (SKILL.md): Loaded when skill triggers
Layer 3 (References): Additional files loaded on-demand
```

**Current Implementation**: The ProofChecker system already follows this pattern:
- Skills have YAML frontmatter with name/description
- Skills reference context files via `@.claude/context/...`
- Agents load context on-demand via @-references

**Improvement Opportunities**:
1. **Skill descriptions need improvement**: Descriptions should be more specific about when to trigger
2. **Reference depth**: Some references are nested 2+ levels deep (violates best practice)
3. **Table of contents**: Longer reference files should have TOC at top

### Finding 5: Metadata Passing via state.json

**Current Pattern**: specs/state.json stores:
- Task metadata (number, name, status, language, priority)
- Session ID for correlation
- Artifact references with summaries
- Timestamps for tracking

**Enhancement Opportunities** (from research on LLM agent state patterns):

1. **Working Memory Pattern** (from OpenSearch agentic memory):
   - Store active conversation data and execution traces
   - Could add: `current_operation`, `last_checkpoint`, `resume_point`

2. **Delegation Context Pattern**:
   - Currently skills pass context via Task tool prompt
   - Could persist delegation_context in state.json for recovery

3. **Scoped Memory** (from Mem0 patterns):
   - User memory (persists across sessions)
   - Session memory (current conversation)
   - Agent memory (agent-specific knowledge)

**Recommended state.json Enhancements**:
```json
{
  "project_number": 619,
  "delegation_context": {
    "session_id": "sess_...",
    "delegation_depth": 1,
    "checkpoint": "GATE_OUT",
    "resume_point": "postflight"
  },
  "execution_trace": [
    {"stage": "preflight", "status": "completed", "ts": "..."},
    {"stage": "delegate", "status": "in_progress", "agent": "general-research-agent"}
  ]
}
```

### Finding 6: Context Window Management

**Key Insight** (from Claude Code docs):
- MCP tools consume context just by being available (8-30% each)
- Watch token percentage in status bar; exit at 80% for complex work
- Compaction is now instant via continuous session memory

**Current System Overhead**:
- 121 context files totaling 1.5MB
- This is fine since files are loaded on-demand
- Main concern is CLAUDE.md size and skill descriptions

### Finding 7: Skill Authoring Best Practices

**From Anthropic's Official Skill Authoring Guide**:

1. **Concise is key**: "Only add context Claude doesn't already have"
2. **Set appropriate degrees of freedom**: Match specificity to task fragility
3. **Naming convention**: Use gerund form (e.g., `processing-pdfs`)
4. **Third-person descriptions**: Always write in third person
5. **Keep SKILL.md under 500 lines**: Split if larger
6. **Avoid nested references**: Keep references one level deep from SKILL.md
7. **Use feedback loops**: Validate outputs before proceeding

**Current System Alignment**:
| Practice | Current Status | Gap |
|----------|----------------|-----|
| Concise skills | Mixed (some verbose) | Review and trim |
| Naming convention | Uses skill-{name} | Already good |
| Third-person | Not consistently | Update descriptions |
| Under 500 lines | Most comply | Monitor |
| Reference depth | Some violations | Flatten structure |
| Feedback loops | Well-implemented | Continue |

---

## Recommendations

### Priority 1: Reduce CLAUDE.md Size (High Impact, Low Effort)

Create a minimal CLAUDE.md (~50-100 lines) with:
```markdown
# ProofChecker Agent System

## Quick Reference
- Task List: specs/TODO.md
- Machine State: specs/state.json
- Full Architecture: @.claude/context/core/architecture/system-overview.md

## Essential Commands
/task, /research, /plan, /implement, /revise, /todo

## Project Structure
Logos/ - Lean 4 source | specs/ - Task artifacts | .claude/ - Agent system

## Key Rules
- Update status BEFORE starting work (preflight)
- Update status AFTER completing work (postflight)
- state.json is machine truth, TODO.md is user truth
```

Move all detailed content to:
- `.claude/context/core/architecture/system-overview.md` (already exists)
- `.claude/context/core/quick-reference.md` (new, for detailed command info)

### Priority 2: Enhance state.json Schema (Medium Impact, Medium Effort)

Add delegation context for improved recovery:

```json
{
  "project_number": 619,
  "session": {
    "id": "sess_...",
    "started": "...",
    "checkpoint": "GATE_OUT",
    "agent": "general-research-agent"
  },
  "recovery": {
    "resume_point": "postflight",
    "completed_stages": ["preflight", "delegate"],
    "pending_stages": ["postflight", "commit"]
  }
}
```

Benefits:
- Enables automatic recovery from interruptions
- Reduces need to pass context through prompts
- Provides audit trail for debugging

### Priority 3: Adopt Native Subagent Patterns (Medium Impact, High Effort)

Migrate to Claude Code native subagent configuration:

**Current** (custom Task tool invocation):
```markdown
Use Task tool with subagent_type: general-research-agent
```

**Native** (automatic delegation):
```yaml
---
name: general-research
description: Conduct general research using web search and codebase exploration. Use proactively for non-Lean research tasks.
tools: Read, Write, Glob, Grep, WebSearch, WebFetch
model: inherit
---
```

Benefits:
- Built-in session persistence
- Automatic delegation based on description
- Parallel execution capability
- Reduced custom infrastructure

**Migration Path**:
1. Keep current system working
2. Add native frontmatter to existing agents
3. Update skill descriptions for better trigger matching
4. Gradually remove custom Task tool invocations

### Priority 4: Improve Skill Descriptions (Low Impact, Low Effort)

Update skill descriptions to be more specific:

**Current**:
```yaml
description: Conduct general research using web search, documentation, and codebase exploration.
```

**Improved**:
```yaml
description: Conducts web searches, fetches documentation, and explores codebase for non-Lean tasks. Use when task language is general, meta, markdown, or latex. Triggers for research phases needing external information.
```

### Priority 5: Flatten Reference Depth (Low Impact, Medium Effort)

Audit context files for nested references exceeding one level. Create direct references from SKILL.md to all needed files.

---

## Decisions

1. **Keep three-layer architecture**: Current Command->Skill->Agent pattern aligns with best practices
2. **Use file-based metadata exchange**: Continue using .return-meta.json pattern (aligns with official guidance)
3. **Do not adopt context: fork**: It's not a real Claude Code feature; current Task tool delegation is correct
4. **Prefer incremental migration**: Don't break working system; adopt native features gradually

---

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Breaking working system | High | Incremental changes, maintain backward compatibility |
| Over-engineering metadata | Medium | Start with minimal schema additions |
| Native subagent incompatibility | Medium | Keep fallback to Task tool invocation |
| CLAUDE.md too minimal | Low | Monitor if Claude loses important context |

---

## Appendix

### Search Queries Used
1. "Claude Code best practices 2026 context engineering progressive disclosure"
2. "Claude Code context forking subagent delegation patterns 2026"
3. "LLM agent metadata passing persistent state patterns"
4. "Claude Code skills frontmatter context management memory optimization"

### Key Sources
- [alexop.dev - Stop Bloating Your CLAUDE.md](https://alexop.dev/posts/stop-bloating-your-claude-md-progressive-disclosure-ai-coding-tools/)
- [Claude Code Docs - Create custom subagents](https://code.claude.com/docs/en/sub-agents)
- [Anthropic - Skill authoring best practices](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices)
- [Anthropic - Claude Code Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices)
- [Letta - Stateful Agents](https://www.letta.com/blog/stateful-agents)
- [Mem0 Tutorial - Persistent Memory](https://www.datacamp.com/tutorial/mem0-tutorial)

### Current System Metrics
- CLAUDE.md: 385 lines (target: <100)
- Root CLAUDE.md: 55 lines (acceptable)
- Context files: 121 files, 1.5MB total
- Skills: 12 skill directories
- Agents: 8 agent files

---

## Next Steps

Run `/plan 619` to create an implementation plan with phased approach for:
1. CLAUDE.md minimization
2. state.json schema enhancement
3. Skill description improvements
4. Optional native subagent adoption
