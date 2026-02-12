# Research Report: Task #873

**Task**: 873 - Create teammate configuration system with model selection
**Started**: 2026-02-11T12:00:00Z
**Completed**: 2026-02-11T12:30:00Z
**Effort**: Medium (3-5 hours implementation)
**Dependencies**: Task 872 (language-aware routing) should be reviewed for coordination
**Sources/Inputs**: Codebase exploration, Claude Code official documentation
**Artifacts**: specs/873_teammate_configuration_model_selection/reports/research-001.md
**Standards**: report-format.md

## Executive Summary

- **Task 872 Status**: Phases 1-3 [COMPLETED], Phase 4 [IN PROGRESS], Phase 5 [NOT STARTED]. Language routing infrastructure is largely complete.
- **Model Parameter Discovery**: Claude Code supports model specification for teammates via natural language ("Use Sonnet for each teammate") and via direct configuration (`model: sonnet`, `model: opus`, `model: haiku`, `model: inherit`).
- **Integration Strategy**: Task 873 can extend 872's language routing pattern in `team-wave-helpers.md` to include a `model` field per language, allowing different models for different task types without requiring explicit specification on every invocation.
- **Recommended Configuration Schema**: Add `default_model` to the language routing config, e.g., `"lean": {"default_model": "opus"}` for complex theorem proving, `"general": {"default_model": "sonnet"}` for standard tasks.

## Context & Scope

### Problem Statement

Currently, team skills spawn teammates without model specification, defaulting to `inherit` (same model as the lead). This is suboptimal for:
- **Lean tasks**: Complex theorem proving benefits from more capable models (Opus 4.6)
- **General/meta tasks**: Sonnet is often sufficient and more cost-effective
- **Research vs Implementation**: Research might benefit from different model tradeoffs than implementation

Task 872 implemented language-aware routing for tool access and prompts. Task 873 extends this to include model routing.

### Scope

- Add model configuration to the language routing pattern in `team-wave-helpers.md`
- Modify team skills (skill-team-research, skill-team-plan, skill-team-implement) to include model specification when spawning teammates
- Optionally allow per-command model override (e.g., `--model opus`)

## Findings

### 1. Task 872 Implementation Status

**Reviewed**: `specs/872_language_aware_teammate_routing_team_skills/plans/implementation-001.md`

| Phase | Status | Description |
|-------|--------|-------------|
| Phase 1 | [COMPLETED] | Language routing helper pattern in `team-wave-helpers.md` |
| Phase 2 | [COMPLETED] | skill-team-research language routing |
| Phase 3 | [COMPLETED] | skill-team-implement language routing |
| Phase 4 | [IN PROGRESS] | skill-team-plan language routing |
| Phase 5 | [NOT STARTED] | Documentation updates |

**Key Finding**: The language routing infrastructure in `team-wave-helpers.md` is already implemented with a structured configuration:

```
language_config = {
  "lean": {
    "research_agent": "lean-research-agent",
    "implementation_agent": "lean-implementation-agent",
    "context_references": [...],
    "blocked_tools": [...],
    "research_tools": [...],
    "implementation_tools": [...],
    "verification": "lake build"
  },
  ...
}
```

**Task 873 can extend this by adding a `default_model` field to each language configuration.**

### 2. Claude Code Model Parameter API

**Source**: [Claude Code Official Documentation - Sub-agents](https://code.claude.com/docs/en/sub-agents) and [Agent Teams](https://code.claude.com/docs/en/agent-teams)

#### Subagent Configuration (Direct Model Specification)

From the subagent documentation:
```yaml
---
name: data-scientist
model: sonnet
---
```

**Available Model Values**:
| Value | Description |
|-------|-------------|
| `sonnet` | Claude Sonnet (balanced capability/speed) |
| `opus` | Claude Opus (most capable) |
| `haiku` | Claude Haiku (fastest, lowest cost) |
| `inherit` | Same model as parent conversation (default) |

#### Team Specification (Natural Language)

From the agent teams documentation:
> "Claude decides the number of teammates to spawn based on your task, or you can specify exactly what you want:
> ```
> Create a team with 4 teammates to refactor these modules in parallel.
> Use Sonnet for each teammate.
> ```"

**Key Finding**: Model specification in team prompts is done via natural language, not a structured parameter. The TeammateTool does not have a direct `model` parameter in its API; instead, the model is communicated via the teammate's prompt.

### 3. How Team Skills Currently Spawn Teammates

Team skills use the TeammateTool (when `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`) to spawn teammates. The current pattern in the skill files:

```
Teammate A - Primary Angle:
"Research task {task_number}: {description}
Focus on implementation approaches and patterns.
..."
```

There is no explicit model specification in current teammate prompts. Teammates inherit the lead's model by default.

### 4. Model Specification Integration Points

Based on the documentation and codebase analysis, there are two ways to specify models for teammates:

**Option A: Natural Language in Prompt (Soft)**
Include model preference in the teammate spawn prompt:
```
Research task {task_number}: {description}

Use Claude Opus for this analysis.

You are a Lean 4/Mathlib research specialist...
```

This relies on Claude interpreting the model preference.

**Option B: CLI-Defined Subagent Pattern (Structured)**
When launching Claude Code with `--agents`, you can specify model:
```bash
claude --agents '{
  "lean-researcher": {
    "model": "opus",
    ...
  }
}'
```

However, team skills don't launch new CLI instances; they use TeammateTool.

**Option C: Configuration-Based Default (Recommended)**
Extend the language routing configuration to include default models, then include model preference in teammate prompts:

```
language_config = {
  "lean": {
    "research_agent": "lean-research-agent",
    "default_model": "opus",  // NEW
    ...
  },
  "general": {
    "research_agent": "general-research-agent",
    "default_model": "sonnet",  // NEW
    ...
  }
}
```

When spawning teammates, include model preference in prompt:
```
Research task {task_number}: {description}

Model preference: Use Claude Opus for this analysis.

You are a Lean 4/Mathlib research specialist...
```

### 5. Existing Model Configuration in Codebase

The project already uses model configuration in some places:

**`.claude/settings.json`**: Line 128 shows `"model": "sonnet"` as the default model.

**`.claude/commands/learn.md`**: Line 5 shows `model: claude-opus-4-5-20251101` for the /learn command, demonstrating that commands can override the default model.

This confirms the pattern: configurations can specify model preferences that override the default.

### 6. Recommended Configuration Schema

**Extend `team-wave-helpers.md#language-routing-pattern`**:

```
language_config = {
  "lean": {
    "research_agent": "lean-research-agent",
    "implementation_agent": "lean-implementation-agent",
    "default_model": "opus",
    "context_references": [...],
    ...
  },
  "latex": {
    "research_agent": "general-research-agent",
    "implementation_agent": "latex-implementation-agent",
    "default_model": "sonnet",
    ...
  },
  "general": {
    "research_agent": "general-research-agent",
    "implementation_agent": "general-implementation-agent",
    "default_model": "inherit",
    ...
  }
}
```

**Model Selection Rationale**:
| Language | Default Model | Rationale |
|----------|---------------|-----------|
| `lean` | `opus` | Complex theorem proving benefits from most capable model |
| `latex` | `sonnet` | Document generation is well-handled by Sonnet |
| `typst` | `sonnet` | Similar to LaTeX |
| `general` | `inherit` | Use whatever the lead is using |
| `meta` | `sonnet` | System/meta tasks are well-handled by Sonnet |

### 7. Optional: Per-Command Model Override

For flexibility, team commands could accept an optional `--model` flag:
```
/research 873 --team --model opus
```

This would override the language-based default for that specific invocation.

**Implementation**: Modify team skill input parameters to include optional `model` parameter, which takes precedence over the language-based default.

## Coordination with Task 872

Task 872 is currently implementing Phase 4 (skill-team-plan) and has Phase 5 (documentation) remaining.

**Recommended Coordination**:
1. **Wait for 872 to complete Phase 4** - Ensures all three team skills have consistent language routing
2. **Extend 872's work in Phase 5** - Task 873 can be implemented alongside or immediately after 872's documentation updates
3. **Shared modification target**: Both tasks modify `team-wave-helpers.md`, so changes should be coordinated

**Integration Points**:
- `team-wave-helpers.md#language-routing-pattern` - Add `default_model` field
- All three team skill SKILL.md files - Add model extraction and prompt inclusion
- Optionally: skill input parameters for model override

## Risks & Mitigations

### Risk 1: Model Specification Not Respected

**Risk**: Natural language model specification in teammate prompts may not be consistently respected by the TeammateTool.

**Mitigation**:
- Test with explicit prompts like "Use Claude Opus for this task"
- Document that model preference is advisory, not guaranteed
- Consider filing feature request for structured `model` parameter in TeammateTool

### Risk 2: Cost Implications

**Risk**: Defaulting Lean tasks to Opus significantly increases token costs.

**Mitigation**:
- Document cost implications in team skill headers
- Provide `--model` override for cost-conscious users
- Consider using Sonnet for research and Opus only for implementation

### Risk 3: Coordination with 872 Incomplete

**Risk**: Task 872's Phase 4 or 5 changes might conflict with 873's modifications.

**Mitigation**:
- Review 872's final state before implementing 873
- Coordinate modifications to shared files (`team-wave-helpers.md`)
- Consider implementing 873 after 872 is fully complete

## Implementation Recommendations

### Phase 1: Extend Language Routing Configuration
- Add `default_model` field to `team-wave-helpers.md#language-routing-pattern`
- Document model selection rationale

### Phase 2: Modify skill-team-research
- Extract `default_model` from language config
- Include model preference in teammate prompts for Lean tasks

### Phase 3: Modify skill-team-implement
- Same pattern as Phase 2
- Include model preference for phase implementers and debuggers

### Phase 4: Modify skill-team-plan
- Same pattern as Phase 2
- Lower priority since planners are mostly language-agnostic

### Phase 5: Add Optional --model Override (Optional)
- Add `model` parameter to team skill input parameters
- Override language default when specified

### Phase 6: Documentation and Testing
- Update CLAUDE.md with model routing notes
- Test model specification with Lean tasks

### Estimated Effort

- Phase 1: 30 minutes
- Phase 2-4: 45 minutes each (total 2.25 hours)
- Phase 5: 1 hour (optional)
- Phase 6: 30 minutes
- **Total**: 3-5 hours

## Appendix

### Key Files Examined

1. `specs/872_language_aware_teammate_routing_team_skills/reports/research-001.md` - Task 872 research
2. `specs/872_language_aware_teammate_routing_team_skills/plans/implementation-001.md` - Task 872 plan
3. `.claude/skills/skill-team-research/SKILL.md` - Team research skill
4. `.claude/skills/skill-team-implement/SKILL.md` - Team implementation skill
5. `.claude/skills/skill-team-plan/SKILL.md` - Team planning skill
6. `.claude/utils/team-wave-helpers.md` - Language routing configuration
7. `.claude/agents/lean-implementation-agent.md` - Lean agent definition
8. `.claude/settings.json` - Project settings (model configuration)
9. `.claude/commands/learn.md` - Example of command with model override

### Web Sources

1. [Claude Code Agent Teams Documentation](https://code.claude.com/docs/en/agent-teams) - Official agent teams documentation
2. [Claude Code Sub-agents Documentation](https://code.claude.com/docs/en/sub-agents) - Subagent configuration including model parameter
3. [Claude Code Swarm Orchestration Guide](https://gist.github.com/kieranklaassen/4f2aba89594a4aea4ad64d753984b2ea) - Community guide to multi-agent coordination

### Search Queries Used

1. Web: "Claude Code Task tool model parameter TeammateTool agent teams specification 2026"
2. Codebase: `model` in `.claude/` directory
3. Codebase: Team skill files for teammate spawning patterns
