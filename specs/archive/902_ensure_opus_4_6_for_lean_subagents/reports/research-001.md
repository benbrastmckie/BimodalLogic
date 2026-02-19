# Research Report: Task #902

**Task**: 902 - ensure_opus_4_6_for_lean_subagents
**Started**: 2026-02-18T12:00:00Z
**Completed**: 2026-02-18T12:15:00Z
**Effort**: Low
**Dependencies**: None
**Sources/Inputs**: Codebase analysis, Claude Code documentation
**Artifacts**: specs/902_ensure_opus_4_6_for_lean_subagents/reports/research-001.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- Claude Code subagents support explicit model specification via the `model` frontmatter field
- Valid values are: `sonnet`, `opus`, `haiku`, or `inherit` (default)
- The Lean agents (lean-research-agent.md and lean-implementation-agent.md) currently do NOT specify a model in their frontmatter
- Adding `model: opus` to the YAML frontmatter will ensure Opus 4.6 is used for these agents

## Context & Scope

This research investigates how to specify the Opus 4.6 model for Lean subagents to ensure the most capable model is always used for theorem proving tasks. The investigation covers:
- Current state of agent files
- Claude Code model specification mechanisms
- Project conventions for model selection

## Findings

### 1. Current State of Agent Files

Both Lean agent files currently have minimal frontmatter:

**lean-implementation-agent.md**:
```yaml
---
name: lean-implementation-agent
description: Implement Lean 4 proofs following implementation plans
---
```

**lean-research-agent.md**:
```yaml
---
name: lean-research-agent
description: Research Lean 4 and Mathlib for theorem proving tasks
---
```

Neither specifies a `model` field, meaning they use the default behavior (`inherit`).

### 2. Claude Code Model Specification

According to the official Claude Code documentation (https://code.claude.com/docs/en/sub-agents), subagents support the following model specification:

| Field | Values | Description |
|-------|--------|-------------|
| `model` | `sonnet`, `opus`, `haiku`, `inherit` | Which Claude model the subagent uses |

- **`inherit`** (default): Uses the same model as the main conversation
- **`opus`**: Routes to the most capable model (Claude Opus 4.6)
- **`sonnet`**: Routes to the balanced model (Claude Sonnet 4.6)
- **`haiku`**: Routes to the fast, lightweight model (Claude Haiku 4.5)

**Key insight**: The `model` field is a direct frontmatter property, not requiring any custom implementation. Claude Code handles the routing automatically.

### 3. Existing Project Conventions

The project already documents model preferences in CLAUDE.md:

```markdown
**Team Skill Model Defaults**:

| Language | Default Model | Rationale |
|----------|---------------|-----------|
| `lean` | Opus | Complex theorem proving benefits from most capable model |
```

And in `team-wave-helpers.md`:
```
"lean": {
    "default_model": "opus",
    ...
}
```

The team skills communicate model preference via natural language in prompts (advisory, not enforced). However, the agent frontmatter approach is more direct and guaranteed.

### 4. How Team Skills Handle Model Preference

The team skills (skill-team-research, skill-team-plan, skill-team-implement) use a pattern like:

```bash
model_preference_line="Model preference: Use Claude ${default_model^} 4.6 for this analysis."
```

This is included in teammate prompts as advisory text. However, this is NOT the same as specifying the model in frontmatter - it relies on the agent reading and respecting the text suggestion.

### 5. Direct Invocation vs Team Mode

- **Direct invocation** (via skill-lean-research, skill-lean-implementation): Uses Task tool which respects agent frontmatter
- **Team mode**: Uses parallel teammates with model preference in prompt text

For direct invocation, the frontmatter `model: opus` is the authoritative way to ensure Opus is used.

## Recommendations

### Primary Recommendation: Add `model: opus` to Agent Frontmatter

Update both Lean agent files to include explicit model specification:

**lean-implementation-agent.md**:
```yaml
---
name: lean-implementation-agent
description: Implement Lean 4 proofs following implementation plans
model: opus
---
```

**lean-research-agent.md**:
```yaml
---
name: lean-research-agent
description: Research Lean 4 and Mathlib for theorem proving tasks
model: opus
---
```

### Rationale

1. **Guaranteed enforcement**: The `model` field is read by Claude Code and routes to the specified model
2. **Simplicity**: Single line addition per file
3. **Consistency**: Aligns with documented project conventions for Lean tasks using Opus
4. **No code changes**: No skill modifications required

### Secondary Consideration

The team skill advisory text (`Model preference: Use Claude Opus 4.6`) remains useful as a fallback reminder, but is not necessary if frontmatter is used. The team skills can optionally be updated to note that the agent frontmatter handles model selection.

## Decisions

1. **Use frontmatter `model: opus`** instead of prompt-based advisory text for guaranteed model selection
2. **Update both Lean agents** to maintain consistency
3. **No skill changes required** - the Task tool already respects agent frontmatter

## Risks & Mitigations

| Risk | Likelihood | Mitigation |
|------|------------|------------|
| Higher API costs from Opus usage | Expected | This is the intended behavior - Opus is needed for complex theorem proving |
| Model alias changes in future | Low | Claude Code aliases are stable; can update if needed |

## Appendix

### Files Examined

- `.claude/agents/lean-implementation-agent.md` - 368 lines
- `.claude/agents/lean-research-agent.md` - 201 lines
- `.claude/skills/skill-lean-implementation/SKILL.md` - 535 lines
- `.claude/skills/skill-lean-research/SKILL.md` - 314 lines
- `.claude/CLAUDE.md` - model preference documentation
- `.claude/utils/team-wave-helpers.md` - language routing patterns

### References

- [Claude Code Subagents Documentation](https://code.claude.com/docs/en/sub-agents)
- Project CLAUDE.md Team Skill Model Defaults table
- `.claude/utils/team-wave-helpers.md#language-routing-pattern`
