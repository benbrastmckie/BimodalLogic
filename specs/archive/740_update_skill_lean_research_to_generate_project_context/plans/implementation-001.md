# Implementation Plan: Task #740

- **Task**: 740 - Update skill-lean-research to generate Project Context section
- **Status**: [NOT STARTED]
- **Effort**: 1 hour
- **Priority**: Medium
- **Dependencies**: 739 (completed - report-format.md already updated)
- **Research Inputs**: specs/740_update_skill_lean_research_to_generate_project_context/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Update skill-lean-research to include the Project Context section in Lean research reports. This requires adding a context reference to project-overview.md, modifying Stage 7 report template in SKILL.md to include the new section, and updating the corresponding Stage 5 documentation in lean-research-flow.md for consistency.

### Research Integration

Key findings from research-001.md:
- Task 739 added the Project Context section specification to report-format.md with four fields: Upstream Dependencies, Downstream Dependents, Alternative Paths, and Potential Extensions
- SKILL.md Stage 7 (lines 201-258) currently generates reports without the Project Context section
- lean-research-flow.md Stage 5 (lines 86-138) mirrors SKILL.md and also lacks the section
- The project-overview.md provides module dependency relationships useful for context generation

## Goals & Non-Goals

**Goals**:
- Add project-overview.md to SKILL.md context references
- Update Stage 7 report template in SKILL.md to include Project Context section
- Update Stage 5 report template in lean-research-flow.md to match
- Add generation guidance explaining how to derive the four context fields

**Non-Goals**:
- Changing the report-format.md specification (already done in task 739)
- Modifying non-Lean research skills
- Automating context field population (fields are manually determined based on task analysis)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Incorrect dependency analysis in reports | Medium | Medium | Provide clear examples and guidance for determining upstream/downstream dependencies |
| Inconsistency between SKILL.md and lean-research-flow.md | Low | Low | Update both files in same phase, verify templates match |
| Over-complicated context guidance | Low | Low | Keep guidance brief, allow "None identified" where appropriate |

## Implementation Phases

### Phase 1: Update SKILL.md Context References and Stage 7 Template [COMPLETED]

**Goal**: Add project-overview.md reference and update the Stage 7 report template to include Project Context section

**Tasks**:
- [ ] Add project-overview.md to Context References section under "Load When Creating Report"
- [ ] Insert Project Context section template between Standards metadata and Executive Summary in Stage 7
- [ ] Add brief generation guidance explaining how to determine each field

**Timing**: 30 minutes

**Files to modify**:
- `.claude/skills/skill-lean-research/SKILL.md` - Add context reference (lines 23-24), modify Stage 7 template (lines 213-226)

**Verification**:
- Context References section includes project-overview.md with appropriate description
- Stage 7 template includes all four Project Context fields
- Template placement matches report-format.md example (between metadata and Executive Summary)

---

### Phase 2: Update lean-research-flow.md Stage 5 Template [COMPLETED]

**Goal**: Update the Stage 5 report template to match SKILL.md changes

**Tasks**:
- [ ] Insert Project Context section template between Standards metadata and Executive Summary in Stage 5
- [ ] Ensure template matches exactly with SKILL.md Stage 7

**Timing**: 15 minutes

**Files to modify**:
- `.claude/context/project/lean4/agents/lean-research-flow.md` - Modify Stage 5 template (lines 93-106)

**Verification**:
- Stage 5 template includes all four Project Context fields
- Template matches SKILL.md Stage 7 exactly
- Placement is consistent with report-format.md specification

---

### Phase 3: Verification and Testing [COMPLETED]

**Goal**: Verify the changes are complete and consistent

**Tasks**:
- [ ] Compare SKILL.md Stage 7 template with lean-research-flow.md Stage 5 template
- [ ] Verify both templates match report-format.md Project Context specification
- [ ] Check that context reference is properly documented

**Timing**: 15 minutes

**Files to review**:
- `.claude/skills/skill-lean-research/SKILL.md`
- `.claude/context/project/lean4/agents/lean-research-flow.md`
- `.claude/context/core/formats/report-format.md`

**Verification**:
- All four Project Context fields present in both templates
- Field descriptions match report-format.md specification
- Context reference properly added to SKILL.md

## Testing & Validation

- [ ] SKILL.md Context References includes project-overview.md
- [ ] SKILL.md Stage 7 template includes Project Context section
- [ ] lean-research-flow.md Stage 5 template includes Project Context section
- [ ] Both templates match report-format.md example skeleton
- [ ] Templates are consistent between the two files

## Artifacts & Outputs

- Modified `.claude/skills/skill-lean-research/SKILL.md`
- Modified `.claude/context/project/lean4/agents/lean-research-flow.md`
- Implementation summary at `specs/740_update_skill_lean_research_to_generate_project_context/summaries/`

## Rollback/Contingency

If implementation causes issues:
1. Revert changes to SKILL.md using git
2. Revert changes to lean-research-flow.md using git
3. The report-format.md specification remains unchanged (it's the source of truth)

Both files are under version control, so rollback is straightforward via `git checkout` of the specific files.
