# Implementation Plan: Task #877

- **Task**: 877 - Update planner-agent to generate phase dependencies
- **Status**: [COMPLETED]
- **Effort**: 1.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/877_update_planner_agent_generate_phase_dependencies/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Update planner-agent.md to generate the Dependencies field for each phase in implementation plans. This requires adding explicit dependency analysis guidance to Stage 4 (task decomposition), updating the Stage 5 plan template to include the Dependencies field, and updating Stage 6 to verify the field exists before writing success metadata.

### Research Integration

Research report (research-001.md) identified:
- Stage 4 already has conceptual dependency questions but doesn't translate them to output format
- Stage 5 template lacks Dependencies field entirely
- Stage 6 verification checklist doesn't check for Dependencies field
- Task 876 established the Dependencies field format in plan-format.md (lines 76-116)

## Goals & Non-Goals

**Goals**:
- Add explicit dependency analysis guidance to Stage 4 that produces `Dependencies` field values
- Update Stage 5 plan template to include `- **Dependencies**: None | Phase N | Phase N, Phase M`
- Update Stage 6 verification to check Dependencies field exists for each phase
- Ensure generated plans match the format established by task 876

**Non-Goals**:
- Modifying plan-format.md (already updated by task 876)
- Changing the phase structure or other template fields
- Adding automated dependency inference (manual analysis is sufficient)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Template changes break existing plan generation | M | L | Carefully match existing format, test with /plan on a task |
| Dependency guidance too verbose | L | M | Keep additions minimal and actionable |
| Field placement inconsistent with plan-format.md | M | L | Reference task 876 implementation as source of truth |

## Implementation Phases

### Phase 1: Update Stage 4 Dependency Analysis [COMPLETED]

**Dependencies**: None
**Estimated effort**: 0.5 hours
**Status**: [COMPLETED]

**Objectives**:
1. Expand step 4 "Define Dependencies" to include explicit guidance for generating Dependencies field values
2. Add input/output mapping heuristic for determining phase dependencies
3. Add table showing dependency notation patterns

**Files to modify**:
- `.claude/agents/planner-agent.md` - Stage 4 (lines 155-158)

**Steps**:
1. Read current Stage 4 content around lines 155-158 (Define Dependencies step)
2. Add sub-bullets with explicit guidance:
   - Generate Dependencies field for each phase
   - Use `None` for phases with no blockers
   - Use `Phase N` for single-predecessor phases
   - Use `Phase N, Phase M` for multi-predecessor phases
3. Add input/output mapping heuristic table:
   - If Phase B modifies files created by Phase A -> B depends on A
   - If Phase B requires artifacts from Phase A -> B depends on A
   - If Phase B tests functionality from Phase A -> B depends on A
4. Add note about identifying parallel opportunities (phases with same predecessor)

**Verification**:
- Stage 4 contains explicit guidance for generating Dependencies field
- Guidance matches notation from plan-format.md
- Heuristics are clear and actionable

---

### Phase 2: Update Stage 5 Plan Template [COMPLETED]

**Dependencies**: Phase 1
**Estimated effort**: 0.5 hours
**Status**: [COMPLETED]

**Objectives**:
1. Add `- **Dependencies**: None` to Phase 1 template
2. Add `- **Dependencies**: Phase 1` to Phase 2 template
3. Ensure field placement matches plan-format.md (after heading, before Goal)

**Files to modify**:
- `.claude/agents/planner-agent.md` - Stage 5 (lines 214-233)

**Steps**:
1. Read current Stage 5 plan template (lines 214-233)
2. Update Phase 1 template:
   - Change from: `### Phase 1: {Name} [NOT STARTED]\n\n**Goal**: ...`
   - Change to: `### Phase 1: {Name} [NOT STARTED]\n\n- **Dependencies**: None\n- **Goal**: ...`
3. Update Phase 2 template similarly with `- **Dependencies**: Phase 1`
4. Ensure bullet format matches plan-format.md example (dash + bold + colon)

**Verification**:
- Both phase templates include Dependencies field
- Field placement is after heading, before Goal
- Format matches plan-format.md example skeleton

---

### Phase 3: Update Stage 6 Verification [COMPLETED]

**Dependencies**: Phase 2
**Estimated effort**: 0.25 hours
**Status**: [COMPLETED]

**Objectives**:
1. Add Dependencies field to the verification checklist in Stage 6a
2. Ensure the verification matches the new template format

**Files to modify**:
- `.claude/agents/planner-agent.md` - Stage 6a (lines 253-264)

**Steps**:
1. Read current Stage 6a verification list (lines 253-264)
2. Add Dependencies field to the required fields list after Status check:
   - `- \`- **Dependencies**: ...\` - **REQUIRED** for each phase (None, Phase N, or Phase N, Phase M)`
3. Update verification command comment to include Dependencies check if needed

**Verification**:
- Stage 6a includes Dependencies in required fields
- Verification instructions are clear about format expectations

---

### Phase 4: Verify and Test [COMPLETED]

**Dependencies**: Phase 3
**Estimated effort**: 0.25 hours
**Status**: [COMPLETED]

**Objectives**:
1. Review all changes for consistency
2. Verify changes align with plan-format.md and task 876 format

**Files to modify**:
- None (verification only)

**Steps**:
1. Re-read the modified planner-agent.md sections
2. Compare Stage 5 template against plan-format.md example (lines 252-262)
3. Verify Dependencies field format matches: `- **Dependencies**: {value}`
4. Verify the guidance in Stage 4 produces values compatible with Stage 5 template

**Verification**:
- All three stages (4, 5, 6) are consistent with each other
- Output format matches plan-format.md specification
- No syntax errors or formatting inconsistencies

## Testing & Validation

- [ ] Stage 4 contains explicit dependency generation guidance
- [ ] Stage 5 template includes Dependencies field in both Phase 1 and Phase 2 examples
- [ ] Stage 6 verification includes Dependencies field check
- [ ] Format matches plan-format.md specification (lines 76-116)
- [ ] Field placement: after phase heading, before Goal field

## Artifacts & Outputs

- Updated `.claude/agents/planner-agent.md` with:
  - Stage 4: Dependency analysis guidance (~10-15 lines added)
  - Stage 5: Dependencies field in phase templates (~2 lines per phase)
  - Stage 6: Verification checklist update (~2 lines added)

## Rollback/Contingency

If changes cause plan generation issues:
1. Revert planner-agent.md to previous git commit state
2. Review plan-format.md to ensure understanding of required format
3. Re-implement with smaller, incremental changes
