# Research Report: Task #463 - Improve /meta Context Loading

- **Task**: 463 - Improve /meta Context Loading
- **Started**: 2026-01-12T18:00:00Z
- **Completed**: 2026-01-12T18:45:00Z
- **Effort**: 1 hour
- **Priority**: Medium
- **Dependencies**: None
- **Sources/Inputs**:
  - .claude/commands/meta.md
  - .claude/skills/skill-meta/SKILL.md
  - .claude/agents/meta-builder-agent.md
  - .claude/commands/research.md, plan.md, implement.md, revise.md
  - .claude/skills/skill-researcher/SKILL.md, skill-planner/SKILL.md, skill-implementer/SKILL.md
  - .claude/agents/planner-agent.md, general-implementation-agent.md
  - .claude/context/core/** (45 files analyzed)
  - .claude/docs/guides/** (4 guides analyzed)
- **Artifacts**: reports/research-001.md (this file)
- **Standards**: report-format.md, subagent-return.md

---

## Executive Summary

- The /meta command uses the same forked subagent pattern as /research, /plan, and /implement, but with key differences in context loading approach
- Working commands (/research, /plan, /implement) have agents that reference specific context files with clear "when to load" guidance in their Context References sections
- The meta-builder-agent references context files but lacks the structured "Always Load", "Load When X" categorization used by other agents
- The /meta workflow differs fundamentally: it creates tasks rather than operating on existing tasks, requiring different context loading patterns
- Three improvement opportunities identified: (1) explicit stage-based context loading table, (2) mode-specific context loading guidance, (3) on-demand loading for component guides during interview

---

## Context & Scope

### Research Objectives

1. Map the /meta command flow (all files involved)
2. Analyze context loading patterns in working commands
3. Identify relevant context files in .claude/context/core/
4. Compare context loading approaches
5. Identify improvement opportunities

### Scope Boundaries

- Focus on context loading patterns, not functional behavior
- Compare /meta against /research, /plan, /implement, /revise
- Analyze .claude/context/core/ files specifically

---

## Findings

### Finding 1: /meta Command Flow Architecture

The /meta command follows the three-layer architecture:

```
/meta command (.claude/commands/meta.md)
    |
    v
skill-meta (.claude/skills/skill-meta/SKILL.md)
    |
    v
meta-builder-agent (.claude/agents/meta-builder-agent.md)
```

**Files Involved**:
| Layer | File | Lines | Purpose |
|-------|------|-------|---------|
| Command | .claude/commands/meta.md | 190 | User entry point, mode detection, delegation |
| Skill | .claude/skills/skill-meta/SKILL.md | 199 | Thin wrapper, input validation, delegation |
| Agent | .claude/agents/meta-builder-agent.md | 590 | Full execution, 7-stage interview workflow |

This matches the pattern used by /research, /plan, /implement.

### Finding 2: Context Loading in Working Commands

**Pattern observed in planner-agent.md** (lines 35-47):

```markdown
## Context References

Load these on-demand using @-references:

**Always Load**:
- `@.claude/context/core/formats/subagent-return.md` - Return format schema

**Load When Creating Plan**:
- `@.claude/context/core/formats/plan-format.md` - Plan artifact structure
- `@.claude/context/core/workflows/task-breakdown.md` - Task decomposition guidelines

**Load for Context**:
- `@.claude/CLAUDE.md` - Project configuration
- `@.claude/context/index.md` - Full context discovery index (if needed)
```

**Pattern observed in general-implementation-agent.md** (lines 40-57):

```markdown
## Context References

Load these on-demand using @-references:

**Always Load**:
- `@.claude/context/core/formats/subagent-return.md` - Return format schema

**Load When Creating Summary**:
- `@.claude/context/core/formats/summary-format.md` - Summary structure (if exists)

**Load for Meta Tasks**:
- `@.claude/CLAUDE.md` - Project configuration
- `@.claude/context/index.md` - Full context discovery index
- Existing skill/agent files as templates

**Load for Code Tasks**:
- Project-specific style guides and patterns
- Existing similar implementations as reference
```

**Key Pattern Characteristics**:
1. **Categorized by timing**: "Always Load", "Load When X"
2. **Action-triggered**: Context loaded based on what the agent is doing
3. **Language/type-aware**: Different context for different task types
4. **Explicit @-references**: Clear syntax for lazy loading

### Finding 3: meta-builder-agent Context References (Current State)

**Current approach** (lines 52-66):

```markdown
## Context References

Load these on-demand using @-references:

**Always Load**:
- `@.claude/context/core/formats/subagent-return.md` - Return format schema

**Load for Component Creation Guidance**:
- `@.claude/docs/guides/component-selection.md` - Decision tree
- `@.claude/docs/guides/creating-commands.md` - When creating command tasks
- `@.claude/docs/guides/creating-skills.md` - When creating skill tasks
- `@.claude/docs/guides/creating-agents.md` - When creating agent tasks

**Load for System Analysis**:
- `@.claude/CLAUDE.md` - Project configuration
- `@.claude/context/index.md` - Full context discovery
```

**Gaps Identified**:
1. **Missing stage-based loading**: No guidance on which files to load at which interview stage
2. **Missing mode-based differentiation**: Same guidance for interactive, prompt, and analyze modes
3. **No progressive disclosure**: All component guides listed together, but they should be loaded only when relevant

### Finding 4: Comparison with Working Agent Context Loading

| Agent | Context Loading Pattern | Stage Integration |
|-------|------------------------|-------------------|
| planner-agent | "Load When Creating Plan" | Stage 5 (Create Plan File) |
| general-implementation-agent | "Load for Meta Tasks", "Load for Code Tasks" | Stage 4 (Execute File Operations) |
| general-research-agent | "Load When Creating Report" | Stage 5 (Create Research Report) |
| **meta-builder-agent** | "Load for Component Creation Guidance" | **No stage mapping** |

### Finding 5: Context Index /meta Guidance (Existing)

The index.md file (lines 389-407) already provides mode-based loading guidance:

```markdown
**Meta Workflow (meta-builder-agent)**:
Stage 2 loads (mode-based):
- Interactive mode: @.claude/docs/guides/component-selection.md (during interview)
- Prompt mode: @.claude/docs/guides/component-selection.md
- Analyze mode: @.claude/CLAUDE.md, @.claude/context/index.md

On-demand loading during interview:
- When discussing commands: @.claude/docs/guides/creating-commands.md
- When discussing skills: @.claude/docs/guides/creating-skills.md
- When discussing agents: @.claude/docs/guides/creating-agents.md

Stage 6 loads:
- @.claude/context/core/formats/subagent-return.md (for return format)

Stage 7 (Status Updates):
- @specs/TODO.md (for task entry creation)
- @specs/state.json (for state updates)
```

**Gap**: This guidance exists in index.md but is NOT reflected in meta-builder-agent.md itself.

### Finding 6: Relevant Context Files in .claude/context/core/

**Files directly relevant to /meta workflow**:

| Path | Purpose | When to Load |
|------|---------|--------------|
| core/formats/subagent-return.md | Return format schema | Always (Stage 6) |
| core/validation.md | Input/return validation | Stage 4 (validation) |
| core/routing.md | Language-based routing | N/A (/meta doesn't route by language) |
| core/orchestration/delegation.md | Delegation patterns | Stage 3 (if meta-builder delegates further) |

**Files relevant to component creation (for interview)**:

| Path | Purpose | When to Load |
|------|---------|--------------|
| core/templates/thin-wrapper-skill.md | Skill creation template | When creating skill tasks |
| core/templates/agent-template.md | Agent creation template | When creating agent tasks |
| core/templates/command-template.md | Command creation template | When creating command tasks |
| core/formats/plan-format.md | Plan structure | When planning meta changes |

### Finding 7: Key Differences Between /meta and Task-Based Commands

| Aspect | /research, /plan, /implement | /meta |
|--------|------------------------------|-------|
| **Input** | Existing task number | No task number OR prompt |
| **Output** | Artifacts for existing task | New tasks created |
| **Context needed** | Task-specific context | System-wide component knowledge |
| **Routing** | Language-based (lean/general) | Mode-based (interactive/prompt/analyze) |
| **Status updates** | Update existing task status | Create new task entries |

This fundamental difference means /meta cannot directly copy the context loading pattern from other commands.

---

## Decisions

1. **Adopt stage-based context loading**: meta-builder-agent should specify which context to load at each of its 8 stages
2. **Add mode-based differentiation**: Different context for interactive vs prompt vs analyze modes
3. **Progressive component guide loading**: Load creating-*.md guides only when discussing that component type
4. **Mirror index.md guidance in agent**: The agent file itself should contain the same loading guidance as index.md

---

## Recommendations

### Recommendation 1: Restructure Context References Section (High Priority)

Replace current Context References with stage-by-stage guidance:

```markdown
## Context References

Load these on-demand using @-references:

**Always Load (Stage 1)**:
- `@.claude/context/core/formats/subagent-return.md` - Return format schema

**Stage 2: Context Loading (mode-based)**:
| Mode | Files to Load |
|------|---------------|
| interactive | `@.claude/docs/guides/component-selection.md` (after Stage 0 inventory) |
| prompt | `@.claude/docs/guides/component-selection.md` |
| analyze | `@.claude/CLAUDE.md`, `@.claude/context/index.md` |

**Stage 2-5: Interview (on-demand, interactive mode only)**:
- When user mentions commands: `@.claude/docs/guides/creating-commands.md`
- When user mentions skills: `@.claude/docs/guides/creating-skills.md`
- When user mentions agents: `@.claude/docs/guides/creating-agents.md`
- When discussing templates: `@.claude/context/core/templates/thin-wrapper-skill.md`

**Stage 6: Return Generation**:
- Return format already loaded in Stage 1

**Stage 7: Status Updates**:
- Direct file access to `specs/TODO.md` and `specs/state.json`
- No additional context files needed
```

### Recommendation 2: Add Mode-Context Matrix (High Priority)

Add explicit matrix showing which context is needed for each mode:

```markdown
## Mode-Context Matrix

| Context File | Interactive | Prompt | Analyze |
|--------------|-------------|--------|---------|
| subagent-return.md | Always | Always | Always |
| component-selection.md | Stage 2 | Stage 2 | No |
| creating-commands.md | On-demand | On-demand | No |
| creating-skills.md | On-demand | On-demand | No |
| creating-agents.md | On-demand | On-demand | No |
| CLAUDE.md | No | No | Stage 1 |
| index.md | No | No | Stage 1 |
| TODO.md | Stage 7 | Stage 7 | Stage 1 |
| state.json | Stage 7 | Stage 7 | Stage 1 |
```

### Recommendation 3: Add Interview Stage Context Triggers (Medium Priority)

For interactive mode, add context loading triggers within interview stages:

```markdown
### Interview Stage 2: GatherDomainInfo

**Context Loading Trigger**:
- If user selects "Add a new command" -> Load `creating-commands.md`
- If user selects "Add a new skill or agent" -> Load `creating-skills.md` AND `creating-agents.md`
- If user selects "Fix or enhance existing" -> Load relevant existing component file

**Question 1** (via AskUserQuestion):
...
```

### Recommendation 4: Reduce Guide Duplication (Low Priority)

Currently, guidance exists in both index.md AND meta-builder-agent.md. Consider:
1. Making meta-builder-agent.md the authoritative source
2. Having index.md reference meta-builder-agent.md instead of duplicating

### Recommendation 5: Template Loading Strategy (Medium Priority)

Add template loading for specific component types:

```markdown
**Template Loading (when creating specific task types)**:
| Task Type | Templates to Reference |
|-----------|----------------------|
| Command | `core/templates/command-template.md` |
| Skill | `core/templates/thin-wrapper-skill.md` |
| Agent | `core/templates/agent-template.md` |
| Orchestrator | `core/templates/orchestrator-template.md` |
```

---

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Over-eager loading slows /meta | Medium | Medium | Strict on-demand loading with trigger conditions |
| Context duplication between index.md and agent | Low | High | Choose single source of truth |
| Interview stages become complex | Medium | Low | Keep context loading implicit, document separately |

---

## Appendix

### Files Analyzed

**Command Layer**:
- .claude/commands/meta.md (190 lines)
- .claude/commands/research.md (121 lines)
- .claude/commands/plan.md (123 lines)
- .claude/commands/implement.md (176 lines)
- .claude/commands/revise.md (193 lines)

**Skill Layer**:
- .claude/skills/skill-meta/SKILL.md (199 lines)
- .claude/skills/skill-researcher/SKILL.md (147 lines)
- .claude/skills/skill-planner/SKILL.md (154 lines)
- .claude/skills/skill-implementer/SKILL.md (170 lines)

**Agent Layer**:
- .claude/agents/meta-builder-agent.md (590 lines)
- .claude/agents/planner-agent.md (401 lines)
- .claude/agents/general-implementation-agent.md (447 lines)
- .claude/agents/general-research-agent.md (this agent - context referenced)

**Context Core** (45 files in .claude/context/core/):
- formats/: subagent-return.md, report-format.md, plan-format.md, summary-format.md
- orchestration/: delegation.md, state-management.md, routing.md
- templates/: thin-wrapper-skill.md, agent-template.md, command-template.md
- checkpoints/: checkpoint-gate-in.md, checkpoint-gate-out.md, checkpoint-commit.md
- validation.md, routing.md

**Guides**:
- .claude/docs/guides/component-selection.md (404 lines)
- .claude/docs/guides/creating-commands.md (330 lines)
- .claude/docs/guides/creating-skills.md (exists, referenced)
- .claude/docs/guides/creating-agents.md (690 lines)

### Search Queries Used

1. Glob patterns: `.claude/commands/**/*.md`, `.claude/skills/**/*.md`, `.claude/agents/**/*.md`, `.claude/context/core/**/*.md`
2. Content analysis: Read command, skill, and agent files
3. Context index review: `.claude/context/index.md`

### References

- CLAUDE.md: Project configuration and system overview
- index.md: Context loading index with meta workflow guidance
- thin-wrapper-skill.md: Template for forked subagent skills
- subagent-return.md: Return format standard for all agents
