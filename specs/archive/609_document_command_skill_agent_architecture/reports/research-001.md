# Research Report: Task #609

**Task**: 609 - Document command-skill-agent architecture
**Date**: 2026-01-19
**Focus**: Document command-skill-agent architecture for .claude/ system

## Executive Summary

- The ProofChecker system uses a **three-layer architecture**: Commands (user entry points) -> Skills (routing/validation) -> Agents (execution)
- Skills follow a **thin wrapper pattern**: minimal logic, delegate to agents via Task tool, handle pre/postflight operations
- Agents are **full execution engines**: load context on-demand, create artifacts, write metadata files for skill postflight
- The **orchestrator** provides centralized routing with language-based dispatch (lean vs general tasks)
- Comprehensive documentation already exists in `.claude/docs/guides/` but needs consolidation and context file creation for agent consumption

## Context & Scope

This research examines the existing command-skill-agent architecture to:
1. Understand current patterns and conventions
2. Identify documentation gaps
3. Recommend improvements for agent context files

**Constraints**: Focus on architecture documentation, not implementation changes.

## Findings

### 1. Three-Layer Architecture Overview

The system follows a clear separation of concerns:

```
Layer 1: Commands         User-facing entry points (/research, /plan, /implement)
    |
    v
Layer 2: Skills           Specialized execution logic with input validation
    |
    v
Layer 3: Agents           Full execution agents that do the actual work
```

| Component | Location | Purpose | User-Facing? |
|-----------|----------|---------|--------------|
| Command | `.claude/commands/` | User invocation point | Yes |
| Skill | `.claude/skills/skill-*/SKILL.md` | Routing and validation | No |
| Agent | `.claude/agents/*.md` | Execution and artifact creation | No |

### 2. Command Layer Details

**Location**: `.claude/commands/{command-name}.md`

**Current Commands** (10):
- `/task` - Create, manage, sync tasks
- `/research` - Conduct task research
- `/plan` - Create implementation plans
- `/implement` - Execute implementation
- `/revise` - Create new plan versions
- `/review` - Review code
- `/errors` - Analyze error patterns
- `/todo` - Archive completed tasks
- `/meta` - Interactive system builder
- `/convert` - Document conversion

**Command Structure**:
```yaml
---
description: {brief description}
allowed-tools: Skill, Bash(jq:*), Read, Edit
argument-hint: TASK_NUMBER [FOCUS]
model: claude-opus-4-5-20251101  # optional
---

# /{command} Command

{Documentation with checkpoint-based execution flow}
```

**Checkpoint Pattern**: Commands follow a 3-checkpoint execution model:
1. **CHECKPOINT 1: GATE IN** - Validate task, generate session_id
2. **STAGE 2: DELEGATE** - Invoke skill via Skill tool
3. **CHECKPOINT 2: GATE OUT** - Validate return, verify artifacts
4. **CHECKPOINT 3: COMMIT** - Git commit (non-blocking)

### 3. Skill Layer Details

**Location**: `.claude/skills/skill-{name}/SKILL.md`

**Current Skills** (11):
- `skill-orchestrator` - Central routing
- `skill-status-sync` - Atomic status updates (direct execution)
- `skill-git-workflow` - Git commits (direct execution)
- `skill-researcher` - General research delegation
- `skill-lean-research` - Lean 4 research delegation
- `skill-planner` - Planning delegation
- `skill-implementer` - General implementation delegation
- `skill-lean-implementation` - Lean implementation delegation
- `skill-latex-implementation` - LaTeX implementation delegation
- `skill-meta` - System building delegation
- `skill-document-converter` - Document conversion

**Thin Wrapper Pattern**:
```yaml
---
name: skill-{name}
description: {description}. Invoke for {use case}.
allowed-tools: Task
---
```

Key characteristics:
- Skills validate inputs before delegation
- Prepare delegation context (session_id, task info)
- Invoke agent via Task tool (NOT Skill tool)
- Handle preflight/postflight status updates internally
- Validate agent returns and propagate results

**Direct Execution Skills**: Some skills execute inline without spawning subagents:
- `skill-status-sync` - Atomic TODO.md/state.json updates
- `skill-git-workflow` - Git commit operations

### 4. Agent Layer Details

**Location**: `.claude/agents/{name}-agent.md`

**Current Agents** (8):
- `general-research-agent` - Web/codebase research
- `lean-research-agent` - Lean 4/Mathlib research
- `planner-agent` - Implementation planning
- `general-implementation-agent` - General file implementation
- `lean-implementation-agent` - Lean proof implementation
- `latex-implementation-agent` - LaTeX document implementation
- `meta-builder-agent` - System building and task creation
- `document-converter-agent` - Document format conversion

**Agent Frontmatter** (required for Claude Code recognition):
```yaml
---
name: {agent-name}
description: {one-line description}
---
```

**Agent Structure**:
1. Overview and metadata
2. Allowed tools section
3. Context references (lazy loading via @-references)
4. 6-8 stage execution flow
5. Return format (writes to metadata file)
6. Error handling patterns

**Metadata File Pattern**: Agents write results to a metadata file (`specs/{N}_{SLUG}/.return-meta.json`) rather than returning JSON to console. This enables reliable parsing by the invoking skill.

### 5. Orchestration Patterns

**Language-Based Routing**:
| Language | Research Skill | Implementation Skill |
|----------|---------------|---------------------|
| lean | skill-lean-research | skill-lean-implementation |
| latex | skill-researcher | skill-latex-implementation |
| general | skill-researcher | skill-implementer |
| meta | skill-researcher | skill-implementer |
| markdown | skill-researcher | skill-implementer |

**Delegation Context Schema**:
```json
{
  "session_id": "sess_{timestamp}_{random}",
  "delegation_depth": 1,
  "delegation_path": ["orchestrator", "command", "agent"],
  "timeout": 3600,
  "task_context": {
    "task_number": N,
    "task_name": "{project_name}",
    "description": "{description}",
    "language": "{language}"
  }
}
```

**Safety Mechanisms**:
- Max delegation depth: 3 levels
- Cycle detection via delegation_path tracking
- Timeout enforcement (1-4 hours depending on operation)
- Session ID tracking for debugging

### 6. Existing Documentation Analysis

**User-Facing Guides** (`.claude/docs/guides/`):
- `component-selection.md` - Decision tree for when to create each component type
- `creating-commands.md` - Command creation guide
- `creating-skills.md` - Skill creation guide
- `creating-agents.md` - Agent creation guide
- `context-loading-best-practices.md` - Context loading patterns

**Core Context Files** (`.claude/context/core/`):
- `orchestration/delegation.md` - Delegation patterns and return format
- `orchestration/routing.md` - Language-based routing logic
- `formats/return-metadata-file.md` - Metadata file schema
- `formats/report-format.md` - Research report structure
- `formats/plan-format.md` - Implementation plan structure
- `workflows/preflight-postflight.md` - Status update patterns
- `checkpoints/` - Checkpoint execution patterns

### 7. Documentation Gaps Identified

**For Users** (`.claude/docs/`):
1. No architecture overview document summarizing the three-layer system
2. No visual diagram of command → skill → agent flow
3. No troubleshooting guide for common issues

**For Agents** (`.claude/context/core/`):
1. No consolidated "architecture-overview.md" for agents to reference
2. Context files are scattered across multiple directories
3. `/meta` command agents need architecture context to reproduce patterns
4. No "patterns" directory documenting common implementation patterns

## Recommendations

### Phase 1: Create Architecture Overview for Agents

Create `.claude/context/core/architecture/system-overview.md`:
- Three-layer architecture diagram and explanation
- Component responsibilities matrix
- Delegation flow patterns
- When to create each component type (summarized from guides)

### Phase 2: Create Pattern Documentation

Create `.claude/context/core/patterns/` directory:
- `thin-wrapper-skill.md` - Skill delegation pattern
- `metadata-file-return.md` - Agent return pattern
- `checkpoint-execution.md` - Command checkpoint pattern
- `anti-stop-patterns.md` - Already exists, consolidate references

### Phase 3: Create User Architecture Guide

Create `.claude/docs/architecture/system-overview.md`:
- High-level architecture for users
- Visual diagram (ASCII or mermaid)
- Links to detailed component guides

### Phase 4: Update CLAUDE.md

Update `.claude/CLAUDE.md` to reference new architecture documentation under "Skill Architecture" section.

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Documentation drift | Medium | Establish review process for architecture changes |
| Redundant documentation | Low | Reference vs duplicate - prefer @-references |
| Over-documentation | Medium | Focus on patterns used by /meta agents |

## References

- `.claude/docs/guides/component-selection.md` - Component decision tree
- `.claude/docs/guides/creating-commands.md` - Command creation
- `.claude/docs/guides/creating-skills.md` - Skill creation
- `.claude/docs/guides/creating-agents.md` - Agent creation
- `.claude/context/core/orchestration/delegation.md` - Delegation standard
- `.claude/context/core/orchestration/routing.md` - Routing logic
- `.claude/CLAUDE.md` - Project configuration

## Next Steps

1. Run `/plan 609` to create implementation plan for documentation
2. Implementation should create context files in recommended locations
3. Update CLAUDE.md with references to new architecture documentation
