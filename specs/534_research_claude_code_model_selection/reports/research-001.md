# Research Report: Task #534

**Task**: 534 - research_claude_code_model_selection
**Started**: 2026-01-17T12:00:00Z
**Completed**: 2026-01-17T12:30:00Z
**Effort**: Small (< 1 hour)
**Priority**: High
**Dependencies**: None
**Sources/Inputs**:
- Claude Code official documentation (code.claude.com)
- GitHub issues (#2532, #12063, #14863)
- Codebase analysis (.claude/agents/)
- Community resources and examples
**Artifacts**: specs/534_research_claude_code_model_selection/reports/research-001.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **Model specification in agent YAML frontmatter is supported** via the `model` field with values: `sonnet`, `opus`, `haiku`, or `inherit`
- **Default behavior**: When model is omitted, subagents default to `sonnet`
- **Known bug**: Task tool's `model` parameter is reportedly ignored in some versions (GitHub #12063)
- **This project's agents**: None currently specify a model field, defaulting to Sonnet
- **Recommendation**: Add explicit `model` fields to agent frontmatter for cost/latency optimization

## Context & Scope

This research investigates how Claude Code handles model selection for subagents spawned via the Task tool. The goal is to understand:

1. Whether agent YAML frontmatter supports model specification
2. How the Task tool's model parameter works
3. Model inheritance and default behavior
4. Current state of this project's agents

## Findings

### 1. Agent YAML Frontmatter Model Field

**The `model` field IS supported in agent YAML frontmatter.**

#### Syntax

```yaml
---
name: agent-name
description: Agent description
model: sonnet  # Optional: sonnet | opus | haiku | inherit
tools: Read, Write, Edit
---
```

#### Supported Values

| Value | Description |
|-------|-------------|
| `sonnet` | Claude Sonnet 4.5 - balanced cost/capability |
| `opus` | Claude Opus - highest capability, highest cost |
| `haiku` | Claude Haiku - fast, low-latency, lowest cost |
| `inherit` | Uses the same model as the parent/main conversation |
| (omitted) | Defaults to `sonnet` |

#### Priority Hierarchy

1. Explicit `model` field in agent frontmatter (highest priority)
2. Default subagent model configuration (`sonnet`)
3. Parent conversation model (only when using `inherit`)

### 2. Task Tool Model Parameter

The Task tool accepts a `model` parameter when invoking subagents:

```python
Task(
    subagent_type='agent-name',
    model='haiku',
    description='...',
    prompt='...'
)
```

**Expected Values**: `sonnet`, `opus`, `haiku`

**Documented Guidance**: "Prefer haiku for quick, straightforward tasks to minimize cost and latency."

#### Known Issue (GitHub #12063)

There is a reported bug where the Task tool's `model` parameter is ignored, with all agent invocations defaulting to Opus regardless of explicit configuration. This affects users who have Opus rate limits but available Sonnet/Haiku capacity.

**Status**: Bug report open, multiple related issues (#8932, #7251, #5456)

**Workaround**: Specify model in agent frontmatter rather than Task tool invocation.

### 3. Model Inheritance Rules

| Scenario | Resulting Model |
|----------|----------------|
| Agent frontmatter specifies `model: opus` | Opus (explicit wins) |
| Agent frontmatter specifies `model: inherit` | Parent's model |
| Agent frontmatter has no model field | Sonnet (default) |
| Task tool specifies `model: haiku` | Haiku (if bug is fixed) / Opus (if bug present) |
| Both frontmatter and Task tool specify | Frontmatter wins |

### 4. Built-in Agent Default Models

| Built-in Agent | Default Model |
|----------------|---------------|
| `Explore` | `haiku` (fast, low-latency for exploration) |
| `Plan` | `inherit` (uses main conversation model) |
| `general-purpose` | `inherit` |
| `Bash` | `inherit` |

### 5. Current State of This Project's Agents

Analysis of `.claude/agents/` reveals **7 agents**, none specifying a model field:

| Agent | Model Field | Effective Model |
|-------|-------------|-----------------|
| `meta-builder-agent` | (none) | sonnet (default) |
| `planner-agent` | (none) | sonnet (default) |
| `general-research-agent` | (none) | sonnet (default) |
| `lean-research-agent` | (none) | sonnet (default) |
| `lean-implementation-agent` | (none) | sonnet (default) |
| `latex-implementation-agent` | (none) | sonnet (default) |
| `general-implementation-agent` | (none) | sonnet (default) |

**Observation**: All agents currently use Sonnet by default. This may not be optimal for:
- Complex implementation tasks (could benefit from Opus)
- Simple research tasks (could use Haiku for cost savings)

### 6. Known Haiku Limitation

GitHub issue #14863 documents that Haiku agents fail with "tool_reference blocks not supported" error. Claude Code sends advanced "tool search" features to Haiku which it doesn't support.

**Impact**: Haiku agents may fail when using complex tool setups. Use with caution for agents with many allowed tools.

## Recommendations

### For Model Tiering Refactoring

1. **Add explicit model fields** to all agent frontmatter to make model selection clear and intentional

2. **Suggested model assignments**:

   | Agent | Recommended Model | Rationale |
   |-------|-------------------|-----------|
   | `meta-builder-agent` | `sonnet` | Complex multi-turn interview |
   | `planner-agent` | `sonnet` | Requires structured thinking |
   | `general-research-agent` | `sonnet` | Web search + synthesis |
   | `lean-research-agent` | `opus` | Complex theorem discovery |
   | `lean-implementation-agent` | `opus` | Complex proof development |
   | `latex-implementation-agent` | `sonnet` | Template-based work |
   | `general-implementation-agent` | `sonnet` | General file operations |

3. **Consider Haiku for**:
   - Fast validation tasks
   - Simple file transformations
   - Status checking operations
   - **Caution**: Test thoroughly due to tool_reference bug

4. **Use `inherit` for**:
   - Agents that should match user's chosen model
   - When consistency with parent context matters

### Implementation Pattern

Update agent frontmatter:

```yaml
---
name: lean-implementation-agent
description: Implement Lean 4 proofs following implementation plans
model: opus  # Complex proof development requires highest capability
---
```

### Workaround for Task Tool Bug

Until the Task tool `model` parameter bug is fixed:
- **Rely on frontmatter model specification** (confirmed working)
- Do not depend on dynamic model selection via Task tool parameters
- Consider creating model-specific agent variants if dynamic selection is needed:
  - `research-agent-quick` (haiku)
  - `research-agent-standard` (sonnet)
  - `research-agent-complex` (opus)

## Decisions

1. **Model specification location**: Prefer agent frontmatter over Task tool parameter (more reliable)
2. **Default model**: Accept Sonnet as default (good balance)
3. **Opus usage**: Reserve for complex tasks (Lean proofs, complex planning)
4. **Haiku usage**: Proceed with caution due to tool_reference limitation

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Task tool model parameter ignored | Medium | High (bug exists) | Use frontmatter specification |
| Haiku agents fail with tool_reference error | High | Medium | Test thoroughly, limit tool count |
| Model costs increase with Opus agents | Low | Medium | Use Opus only where needed |
| Inconsistent model behavior across sessions | Medium | Low | Explicit frontmatter specification |

## Appendix

### Sources

- [Claude Code Subagents Documentation](https://code.claude.com/docs/en/sub-agents)
- [GitHub Issue #2532: Model Selection for Sub Agents](https://github.com/anthropics/claude-code/issues/2532)
- [GitHub Issue #12063: Task tool ignores model parameter](https://github.com/anthropics/claude-code/issues/12063)
- [GitHub Issue #14863: Haiku tool_reference bug](https://github.com/anthropics/claude-code/issues/14863)
- [Claude Code Skills Factory Examples](https://github.com/krzemienski/claude-code-skills-factory)
- [Claude Code Customization Guide](https://alexop.dev/posts/claude-code-customization-guide-claudemd-skills-subagents/)

### Search Queries Used

1. "Claude Code Task tool model parameter subagent model selection 2026"
2. "Claude Code agent frontmatter model field specification"
3. Direct documentation fetch from code.claude.com

### YAML Frontmatter Reference

Required fields:
- `name`: Agent identifier
- `description`: Agent purpose

Optional fields:
- `model`: `sonnet` | `opus` | `haiku` | `inherit`
- `tools`: Comma-separated list of allowed tools
- `skills`: List of skills the agent can use

### Example Agent with Model

```yaml
---
name: data-scientist
description: Data analysis expert for SQL queries and insights
tools: Bash, Read, Write
model: sonnet
---

# Agent instructions follow...
```
