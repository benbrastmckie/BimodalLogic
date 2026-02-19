# Implementation Plan: Enforce Model Selection in Team Skills

- **Task**: 904 - enforce_model_selection_team_skills
- **Status**: [COMPLETED]
- **Effort**: 1.5 hours
- **Dependencies**: None
- **Research Inputs**: None (issue identified via direct investigation)
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

The three team skills (skill-team-research, skill-team-plan, skill-team-implement) correctly determine `default_model` based on task language (opus for lean, sonnet for all others) and include it as advisory text in teammate prompts via `model_preference_line`. However, this is not enforced at the tool level since TeammateTool supports an explicit `model` parameter that is not being used. This plan adds `model: $default_model` when spawning teammates to ensure Opus 4.6 is always used for Lean tasks and Sonnet 4.6 for all others.

## Goals & Non-Goals

**Goals**:
- Add explicit `model` parameter to all teammate spawning in team skills
- Update documentation to reflect enforced model selection (not advisory)
- Remove or clarify now-redundant `model_preference_line` advisory text
- Ensure consistent model usage: Opus 4.6 for lean, Sonnet 4.6 for all others

**Non-Goals**:
- Changing the model selection logic (already correct)
- Adding user-configurable model override (out of scope)
- Modifying non-team skills

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| TeammateTool model parameter not working as expected | High | Low | Test with actual team invocation after changes |
| Breaking existing team skill functionality | Medium | Low | Make minimal targeted changes; preserve existing structure |
| Inconsistent documentation | Low | Medium | Update all three skills and both helper files together |

## Implementation Phases

### Phase 1: Update Team Research Skill [COMPLETED]

- **Dependencies:** None
- **Goal:** Add model parameter to teammate spawning in skill-team-research

**Tasks**:
- [ ] Edit `.claude/skills/skill-team-research/SKILL.md`
- [ ] In Stage 5 (Spawn Research Wave), add `model: $default_model` to TeammateTool invocation
- [ ] Update or remove `model_preference_line` references (keep in prompts as secondary guidance but note model is enforced)
- [ ] Add explicit comment noting model parameter enforces the model selection

**Timing**: 20 minutes

**Files to modify**:
- `.claude/skills/skill-team-research/SKILL.md` - Add model parameter to spawn section

**Verification**:
- Grep for "TeammateTool" or spawn sections to ensure model parameter is documented
- Verify model_preference_line context is clarified

---

### Phase 2: Update Team Plan Skill [COMPLETED]

- **Dependencies:** None
- **Goal:** Add model parameter to teammate spawning in skill-team-plan

**Tasks**:
- [ ] Edit `.claude/skills/skill-team-plan/SKILL.md`
- [ ] In Stage 6 (Spawn Planning Wave), add `model: $default_model` to TeammateTool invocation
- [ ] Update or remove `model_preference_line` references
- [ ] Add explicit comment noting model parameter enforces the model selection

**Timing**: 20 minutes

**Files to modify**:
- `.claude/skills/skill-team-plan/SKILL.md` - Add model parameter to spawn section

**Verification**:
- Grep for "TeammateTool" or spawn sections to ensure model parameter is documented
- Verify model_preference_line context is clarified

---

### Phase 3: Update Team Implement Skill [COMPLETED]

- **Dependencies:** None
- **Goal:** Add model parameter to teammate spawning in skill-team-implement (both phase implementers and debuggers)

**Tasks**:
- [ ] Edit `.claude/skills/skill-team-implement/SKILL.md`
- [ ] In Stage 6 (Execute Implementation Waves), add `model: $default_model` to phase implementer spawning
- [ ] In Stage 7 (Handle Implementation Errors), add `model: $default_model` to debugger spawning
- [ ] Update or remove `model_preference_line` references
- [ ] Add explicit comment noting model parameter enforces the model selection

**Timing**: 25 minutes

**Files to modify**:
- `.claude/skills/skill-team-implement/SKILL.md` - Add model parameter to spawn sections

**Verification**:
- Grep for "TeammateTool" or spawn sections to ensure model parameter is documented
- Verify both implementer and debugger spawning include model parameter

---

### Phase 4: Update Helper Documentation [COMPLETED]

- **Dependencies:** Phase 1, Phase 2, Phase 3
- **Goal:** Update team-wave-helpers.md and team-orchestration.md to document enforced model selection

**Tasks**:
- [ ] Edit `.claude/utils/team-wave-helpers.md`
  - Update Language Routing Pattern section to show `model` parameter in spawn examples
  - Add note that model is enforced via parameter, not just advisory text
  - Update spawn pattern examples to include model parameter
- [ ] Edit `.claude/context/core/patterns/team-orchestration.md`
  - Update TeammateTool Integration section (around line 89) to document model parameter usage
  - Add example showing model parameter in spawn
- [ ] Update CLAUDE.md if needed to clarify model enforcement (currently says "advisory, not enforced")

**Timing**: 25 minutes

**Files to modify**:
- `.claude/utils/team-wave-helpers.md` - Update spawn examples and model selection docs
- `.claude/context/core/patterns/team-orchestration.md` - Document model parameter
- `.claude/CLAUDE.md` - Update Team Skill Model Defaults table footnote

**Verification**:
- All documentation references enforced model selection
- Spawn examples include model parameter
- CLAUDE.md reflects the change from "advisory" to "enforced"

**Progress:**

**Session: 2026-02-19, sess_1771522464_0ad6b1**
- Completed: All 4 phases executed successfully
- Added: Model parameter enforcement to skill-team-research Stage 5
- Added: Model parameter enforcement to skill-team-plan Stage 6
- Added: Model parameter enforcement to skill-team-implement Stage 6 and Stage 7
- Added: Model enforcement documentation to team-wave-helpers.md
- Added: Model Selection section to team-orchestration.md
- Fixed: CLAUDE.md footnote changed from "advisory" to "enforced"

---

## Testing & Validation

- [ ] Grep all three skill files for "model:" to verify parameter is present
- [ ] Grep team-wave-helpers.md for spawn examples to verify model parameter
- [ ] Review CLAUDE.md Team Skill Model Defaults section for updated language
- [ ] Verify no orphaned `model_preference_line` references without clarification

## Artifacts & Outputs

- `plans/implementation-001.md` (this file)
- Modified skill files (3)
- Modified helper/documentation files (3)
- `summaries/implementation-summary-YYYYMMDD.md` (on completion)

## Rollback/Contingency

If model enforcement causes issues:
1. Revert the `model` parameter additions from skill files
2. Keep `model_preference_line` as advisory-only approach
3. Investigate TeammateTool model parameter behavior
