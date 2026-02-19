# Implementation Plan: Configure Subagent Model Routing

- **Task**: 901 - configure_subagent_model_routing
- **Status**: [NOT STARTED]
- **Effort**: 1 hour
- **Dependencies**: None
- **Research Inputs**: specs/901_configure_subagent_model_routing/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Configure model routing so Lean subagents use Opus 4.6 while all other agents use Sonnet 4.6. The main change is updating "general" language from "inherit" to "sonnet" in the team skill model routing tables. Model preference is advisory (communicated via natural language in prompts), not enforced.

### Research Integration

Research report (research-001.md) identified:
- Model routing is implemented in three team skills with case statements
- Documentation in CLAUDE.md and team-wave-helpers.md needs updating
- Single-agent skills cannot specify model (Task tool limitation)
- Change is straightforward: update default_model for "general" from "inherit" to "sonnet"

## Goals & Non-Goals

**Goals**:
- Update "general" language to use Sonnet instead of inheriting lead's model
- Update documentation to reflect Opus 4.6 and Sonnet 4.6 naming
- Ensure consistency across all team skill files

**Non-Goals**:
- Modifying single-agent skill model behavior (not possible with Task tool)
- Enforcing model selection (remains advisory)
- Adding model version checking at runtime

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Model preference is advisory only | L | H | Document limitation; actual enforcement depends on Claude Code |
| Version references may become stale | L | M | Use generic Opus/Sonnet in code; add version note in docs |
| Missing file during edit | M | L | Verify file exists before editing |

## Implementation Phases

### Phase 1: Update Documentation [NOT STARTED]

- **Dependencies:** None
- **Goal:** Update CLAUDE.md Team Skill Model Defaults table

**Tasks**:
- [ ] Update CLAUDE.md model defaults table (change "general" row from "Inherit" to "Sonnet")
- [ ] Update rationale text to reference 4.6 versions where appropriate

**Timing**: 15 minutes

**Files to modify**:
- `.claude/CLAUDE.md` - Team Skill Model Defaults table (around lines 169-179)

**Verification**:
- Table shows "Sonnet" for all non-lean languages
- Model note references 4.6 versions

---

### Phase 2: Update Team Wave Helpers [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal:** Update reference configuration in team-wave-helpers.md

**Tasks**:
- [ ] Update language_config for "general" to use "sonnet" instead of "inherit"
- [ ] Update model comments to reference 4.6 versions

**Timing**: 10 minutes

**Files to modify**:
- `.claude/utils/team-wave-helpers.md` - Language Routing Pattern section (around lines 276-370)

**Verification**:
- All non-lean languages show default_model: "sonnet"
- Comments reference 4.6 models

---

### Phase 3: Update Team Research Skill [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal:** Update model routing in skill-team-research

**Tasks**:
- [ ] Change `*) default_model="inherit"` to `default_model="sonnet"` in case statement
- [ ] Update model_preference_line to reference 4.6 versions

**Timing**: 10 minutes

**Files to modify**:
- `.claude/skills/skill-team-research/SKILL.md` - Around lines 166-203

**Verification**:
- Case statement uses "sonnet" for default case
- No "inherit" value remains in model routing

---

### Phase 4: Update Team Plan Skill [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal:** Update model routing in skill-team-plan

**Tasks**:
- [ ] Change `*) default_model="inherit"` to `default_model="sonnet"` in case statement
- [ ] Update model_preference_line to reference 4.6 versions

**Timing**: 10 minutes

**Files to modify**:
- `.claude/skills/skill-team-plan/SKILL.md` - Around lines 150-198

**Verification**:
- Case statement uses "sonnet" for default case
- No "inherit" value remains in model routing

---

### Phase 5: Update Team Implement Skill [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal:** Update model routing in skill-team-implement

**Tasks**:
- [ ] Change `*) default_model="inherit"` to `default_model="sonnet"` in case statement
- [ ] Update model_preference_line to reference 4.6 versions

**Timing**: 10 minutes

**Files to modify**:
- `.claude/skills/skill-team-implement/SKILL.md` - Around lines 214-259

**Verification**:
- Case statement uses "sonnet" for default case
- No "inherit" value remains in model routing

---

## Testing & Validation

- [ ] All five files modified successfully
- [ ] No "inherit" references remain in model routing code
- [ ] Documentation is internally consistent (CLAUDE.md matches skill files)
- [ ] Grep for `default_model.*inherit` returns no matches in team skills

## Artifacts & Outputs

- plans/implementation-001.md (this file)
- summaries/implementation-summary-20260218.md (on completion)

## Rollback/Contingency

Changes are documentation/configuration only. Rollback via git:
```bash
git checkout HEAD~1 -- .claude/CLAUDE.md .claude/utils/team-wave-helpers.md .claude/skills/skill-team-*/SKILL.md
```
