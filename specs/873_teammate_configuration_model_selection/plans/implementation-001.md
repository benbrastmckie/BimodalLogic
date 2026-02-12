# Implementation Plan: Task #873

- **Task**: 873 - Create teammate configuration system with model selection
- **Status**: [NOT STARTED]
- **Effort**: 2.5 hours
- **Dependencies**: Task 872 (language-aware routing) should be complete or coordinated
- **Research Inputs**: specs/873_teammate_configuration_model_selection/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md
- **Type**: meta
- **Lean Intent**: false

## Overview

This plan extends the language routing infrastructure (from task 872) to include model selection for team teammates. Each language type will have a `default_model` field specifying the preferred Claude model (opus, sonnet, haiku, or inherit). Team skills will extract this preference and include it in teammate prompts via natural language, enabling cost-effective model allocation based on task complexity.

### Research Integration

Key findings from research-001.md:
- Task 872 language routing infrastructure is complete in `team-wave-helpers.md`
- Claude Code supports model specification via natural language in prompts
- TeammateTool does not have a direct model parameter; models are communicated via prompt content
- Recommended model defaults: `opus` for Lean, `sonnet` for LaTeX/Typst/meta, `inherit` for general

## Goals and Non-Goals

**Goals**:
- Add `default_model` field to language routing configuration
- Modify team skills to include model preference in teammate prompts
- Document the model routing pattern in CLAUDE.md

**Non-Goals**:
- Per-command `--model` override (optional future enhancement)
- Guaranteed model enforcement (natural language is advisory)
- Modifying non-team skills

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Model preference not respected by TeammateTool | M | M | Document as advisory; test with explicit phrasing |
| Cost increase from Opus defaults for Lean | M | L | Document cost implications; users can manually override |
| Conflicts with 872 in-progress changes | L | L | Coordinate with 872 status; apply changes additively |

## Implementation Phases

### Phase 1: Extend Language Routing Configuration [NOT STARTED]

**Goal**: Add `default_model` field to the language routing pattern in `team-wave-helpers.md`

**Estimated effort**: 30 minutes

**Files to modify**:
- `.claude/utils/team-wave-helpers.md` - Add `default_model` to each language config

**Steps**:
1. Read current `team-wave-helpers.md` language_config structure
2. Add `default_model` field to each language:
   - `lean`: `"opus"` - Complex theorem proving benefits from most capable model
   - `latex`: `"sonnet"` - Document generation well-handled by Sonnet
   - `typst`: `"sonnet"` - Similar to LaTeX
   - `general`: `"inherit"` - Use lead's model
   - `meta`: `"sonnet"` - System tasks well-handled by Sonnet
3. Add documentation section explaining model selection rationale

**Verification**:
- Language config contains `default_model` for all 5 language types
- Documentation explains rationale for each default

---

### Phase 2: Modify skill-team-research [NOT STARTED]

**Goal**: Include model preference in research teammate prompts

**Estimated effort**: 45 minutes

**Files to modify**:
- `.claude/skills/skill-team-research/SKILL.md` - Add model extraction and prompt inclusion

**Steps**:
1. Read current skill-team-research SKILL.md
2. Add step to extract `default_model` from language config lookup
3. Modify teammate prompt template to include model preference line
4. Format: `Model preference: Use Claude {Model} for this analysis.`
5. Ensure model line appears near top of teammate prompt

**Verification**:
- Skill extracts model from language config
- Teammate prompts include model preference line
- Lean tasks specify Opus, general tasks use inherit

---

### Phase 3: Modify skill-team-implement [NOT STARTED]

**Goal**: Include model preference in implementation and debugger teammate prompts

**Estimated effort**: 45 minutes

**Files to modify**:
- `.claude/skills/skill-team-implement/SKILL.md` - Add model extraction and prompt inclusion

**Steps**:
1. Read current skill-team-implement SKILL.md
2. Add step to extract `default_model` from language config lookup
3. Modify phase implementer prompt template to include model preference
4. Modify debugger prompt template to include model preference
5. Format: `Model preference: Use Claude {Model} for this task.`

**Verification**:
- Skill extracts model from language config
- Both implementer and debugger prompts include model preference
- Lean implementation tasks specify Opus

---

### Phase 4: Modify skill-team-plan [NOT STARTED]

**Goal**: Include model preference in planning teammate prompts

**Estimated effort**: 30 minutes

**Files to modify**:
- `.claude/skills/skill-team-plan/SKILL.md` - Add model extraction and prompt inclusion

**Steps**:
1. Read current skill-team-plan SKILL.md
2. Add step to extract `default_model` from language config lookup
3. Modify planner prompt templates to include model preference
4. Format: `Model preference: Use Claude {Model} for planning.`

**Verification**:
- Skill extracts model from language config
- Planner prompts include model preference

---

### Phase 5: Documentation Update [NOT STARTED]

**Goal**: Document model routing in CLAUDE.md and verify consistency

**Estimated effort**: 30 minutes

**Files to modify**:
- `.claude/CLAUDE.md` - Add model routing note to Team Skill section

**Steps**:
1. Read current CLAUDE.md Team Skill section
2. Add brief note about model routing (extend existing language routing note)
3. Add table showing default models per language
4. Verify all modified files are consistent

**Verification**:
- CLAUDE.md documents model routing
- Model defaults table matches team-wave-helpers.md configuration
- All three team skills use consistent pattern

---

## Testing and Validation

- [ ] Language config has `default_model` for all 5 languages
- [ ] skill-team-research includes model preference in prompts
- [ ] skill-team-implement includes model preference in prompts
- [ ] skill-team-plan includes model preference in prompts
- [ ] CLAUDE.md documents the model routing feature
- [ ] Model preference format is consistent across all skills

## Artifacts and Outputs

- Updated `.claude/utils/team-wave-helpers.md` with model configuration
- Updated `.claude/skills/skill-team-research/SKILL.md`
- Updated `.claude/skills/skill-team-implement/SKILL.md`
- Updated `.claude/skills/skill-team-plan/SKILL.md`
- Updated `.claude/CLAUDE.md` with documentation

## Rollback/Contingency

If model specification proves problematic:
1. Remove `default_model` fields from team-wave-helpers.md
2. Remove model preference lines from team skill prompts
3. Revert CLAUDE.md documentation changes

Changes are additive and non-breaking; rollback is straightforward.
