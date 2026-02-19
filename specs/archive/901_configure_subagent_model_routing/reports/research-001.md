# Research Report: Task #901

**Task**: 901 - configure_subagent_model_routing
**Started**: 2026-02-18T12:00:00Z
**Completed**: 2026-02-18T12:30:00Z
**Effort**: 30 minutes
**Dependencies**: None
**Sources/Inputs**: Codebase analysis (.claude/ directory)
**Artifacts**: This research report
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- Model routing is documented in CLAUDE.md (Team Skill Model Defaults table) and implemented in team skill files
- Current configuration: Lean -> "opus", all others -> "sonnet" or "inherit"
- Model preference is **advisory only** - communicated via natural language in teammate prompts
- Single-agent skills (skill-lean-research, skill-lean-implementation) do NOT have explicit model routing
- To achieve the goal, update CLAUDE.md documentation AND team skill/helper routing tables

## Context & Scope

The goal is to configure:
1. Lean subagents to use Opus 4.6
2. All other agents to use Sonnet 4.6

This research identifies where model routing is configured and what changes are needed.

## Findings

### 1. Documentation Location (CLAUDE.md)

The primary documentation is in `.claude/CLAUDE.md` lines 169-179:

```markdown
**Team Skill Model Defaults**:

| Language | Default Model | Rationale |
|----------|---------------|-----------|
| `lean` | Opus | Complex theorem proving benefits from most capable model |
| `latex` | Sonnet | Document generation well-handled by Sonnet |
| `typst` | Sonnet | Similar to LaTeX |
| `meta` | Sonnet | System tasks well-handled by Sonnet |
| `general` | Inherit | Uses lead agent's model |

Model preference is communicated via natural language in teammate prompts (advisory, not enforced).
```

**Key Finding**: The documentation already specifies Opus for Lean and Sonnet for others, with "general" inheriting the lead's model.

### 2. Team Skill Implementation Locations

Model routing is implemented via `default_model` variable in three team skills:

#### a) skill-team-research/SKILL.md (lines 166-203)

```bash
case "$language" in
  "lean")
    default_model="opus"
    ;;
  "latex"|"typst"|"meta")
    default_model="sonnet"
    ;;
  *)
    default_model="inherit"
    ;;
esac

if [ "$default_model" = "inherit" ]; then
  model_preference_line=""
else
  model_preference_line="Model preference: Use Claude ${default_model^} for this analysis."
fi
```

#### b) skill-team-plan/SKILL.md (lines 150-198)

Same pattern - Lean uses "opus", latex/typst/meta use "sonnet", general uses "inherit".

#### c) skill-team-implement/SKILL.md (lines 214-259)

Same pattern - Lean uses "opus", latex/typst/meta use "sonnet", general uses "inherit".

### 3. Team Wave Helpers Reference (team-wave-helpers.md)

The canonical language routing configuration is documented in `.claude/utils/team-wave-helpers.md` lines 276-370 under "Language Routing Pattern":

```
language_config = {
  "lean": {
    "default_model": "opus",
    ...
  },
  "latex": {
    "default_model": "sonnet",
    ...
  },
  ...
}
```

This file contains the rationale for model selection:
- "opus": Most capable model, recommended for complex theorem proving (Lean)
- "sonnet": Balanced model, good for document generation and system tasks
- "inherit": Use the lead agent's model (no override)

### 4. Single-Agent Skills (NO explicit model routing)

The single-agent skills do NOT have explicit model configuration:

- `skill-lean-research/SKILL.md` - Uses Task tool to spawn `lean-research-agent`, no model param
- `skill-lean-implementation/SKILL.md` - Uses Task tool to spawn `lean-implementation-agent`, no model param
- `skill-researcher/SKILL.md` - Uses Task tool to spawn `general-research-agent`, no model param

**Key Finding**: Single-agent subagents inherit their model from the caller context. The Task tool does not support a `model` parameter for explicit model selection.

### 5. How Model Routing Actually Works

The model preference is **advisory, not enforced**:

1. Team skills compute `model_preference_line` based on language
2. This line is included in teammate prompts: `"Model preference: Use Claude Opus for this task."`
3. The actual model used depends on Claude Code's internal routing and the user's settings

**Important**: This is a "soft" preference communicated via natural language. Claude Code's Task tool does not have an explicit `model` parameter to force model selection.

### 6. Current State vs Goal

| Language | Current Config | Goal Config | Status |
|----------|----------------|-------------|--------|
| lean | opus | Opus 4.6 | Update version reference |
| latex | sonnet | Sonnet 4.6 | Update version reference |
| typst | sonnet | Sonnet 4.6 | Update version reference |
| meta | sonnet | Sonnet 4.6 | Update version reference |
| general | inherit | Sonnet 4.6 | **Change from "inherit" to "sonnet"** |

The main change needed is for `general` language - currently it inherits the lead's model, but the goal is to use Sonnet 4.6 explicitly.

## Recommendations

### Changes Required

1. **Update CLAUDE.md Table** (lines 169-179):
   - Change `general` from "Inherit" to "Sonnet"
   - Update model names to include version (e.g., "Opus 4.6", "Sonnet 4.6")

2. **Update team-wave-helpers.md** (lines 276-370):
   - Change `"general": { "default_model": "inherit" }` to `"default_model": "sonnet"`
   - Update comments to reference 4.6 versions

3. **Update skill-team-research/SKILL.md** (lines 166-203):
   - Change `*) default_model="inherit"` to `default_model="sonnet"`

4. **Update skill-team-plan/SKILL.md** (lines 150-198):
   - Change `*) default_model="inherit"` to `default_model="sonnet"`

5. **Update skill-team-implement/SKILL.md** (lines 214-259):
   - Change `*) default_model="inherit"` to `default_model="sonnet"`

### Files to Modify

1. `.claude/CLAUDE.md` - Documentation table
2. `.claude/utils/team-wave-helpers.md` - Reference configuration
3. `.claude/skills/skill-team-research/SKILL.md` - Research team skill
4. `.claude/skills/skill-team-plan/SKILL.md` - Planning team skill
5. `.claude/skills/skill-team-implement/SKILL.md` - Implementation team skill

### What Cannot Be Changed

Single-agent skills (skill-lean-research, skill-lean-implementation, skill-researcher, etc.) use the Task tool without model selection. The Task tool in Claude Code does not expose a `model` parameter, so single-agent subagents will use whatever model the session is running.

To change model for single-agent invocations, the user would need to:
- Start Claude Code with a specific model flag (if available)
- Or Claude Code would need to add model selection to the Task tool

## Decisions

1. Focus changes on team skills where model routing is already implemented
2. Change "general" language from "inherit" to "sonnet" to align with goal
3. Update documentation to reference 4.6 versions
4. Accept that single-agent skills inherit model from caller (no explicit routing possible)

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Model preference is advisory | Document this limitation; actual enforcement depends on Claude Code |
| Single-agent skills can't specify model | Accept limitation; most complex work uses team mode anyway |
| Version references may become stale | Use generic "Opus"/"Sonnet" without version in code, add version note in docs |

## Appendix

### Search Queries Used

- Grep for `model|opus|sonnet` in .claude/
- Pattern matching on SKILL.md files
- Read of team skill implementations

### Key File Paths

- `.claude/CLAUDE.md:169-179` - Team Skill Model Defaults table
- `.claude/utils/team-wave-helpers.md:276-370` - Language Routing Pattern
- `.claude/skills/skill-team-research/SKILL.md:166-203` - Research routing
- `.claude/skills/skill-team-plan/SKILL.md:150-198` - Planning routing
- `.claude/skills/skill-team-implement/SKILL.md:214-259` - Implementation routing
