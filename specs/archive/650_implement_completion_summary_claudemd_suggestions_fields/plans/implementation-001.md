# Implementation Plan: Task #650

- **Task**: 650 - Implement completion_summary and claudemd_suggestions fields in /implement workflow
- **Status**: [NOT STARTED]
- **Effort**: 3 hours
- **Priority**: High
- **Dependencies**: None
- **Research Inputs**: specs/650_implement_completion_summary_claudemd_suggestions_fields/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

This task modifies the /implement command-skill-agent workflow to populate `completion_summary` and `claudemd_suggestions` fields when tasks are completed. The research identified that these fields should be populated at the skill postflight level (Stage 7) since skills have access to the implementation result and know the task language. The implementation follows a producer/consumer pattern where /implement produces these fields and /todo consumes them.

### Research Integration

Key findings from research-001.md:
- Field schemas are well-defined in state-management.md (lines 102-196)
- Status transitions to "completed" happen in skill postflight (Stage 7)
- Agents should generate `completion_data` in metadata file; skills propagate to state.json
- Meta tasks need `claudemd_suggestions`; non-meta tasks get `roadmap_items` (optional)
- `completion_summary` is mandatory for all completed tasks

## Goals & Non-Goals

**Goals**:
- Extend return-metadata-file.md schema to include `completion_data` field
- Update general-implementation-agent to generate completion_data (including claudemd_suggestions for meta tasks)
- Update lean-implementation-agent and latex-implementation-agent to generate completion_data
- Update all three implementation skills to propagate completion fields in postflight
- Ensure completion_summary is always populated when status becomes "completed"

**Non-Goals**:
- Modifying the /todo command (it already consumes these fields per state-management.md)
- Adding automatic CLAUDE.md updates (these are suggestions for user review)
- Changing the /implement command itself (skills handle postflight internally)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| jq escaping issues with complex suggestion content | M | M | Use two-step jq pattern per jq-escaping-workarounds.md |
| Agents forget to generate completion_summary | M | L | Add explicit instructions in Stage 7 of each agent |
| claudemd_suggestions action type is inappropriate | L | M | Document clear criteria for each action type in agent instructions |
| Metadata file schema change breaks existing agents | M | L | completion_data field is additive; existing agents work without it |

## Implementation Phases

### Phase 1: Extend Return Metadata Schema [NOT STARTED]

**Goal**: Update the return-metadata-file.md schema to document the new `completion_data` field that agents should include.

**Tasks**:
- [ ] Read current return-metadata-file.md schema
- [ ] Add `completion_data` field specification with:
  - `completion_summary` (required for implemented status)
  - `roadmap_items` (optional array, non-meta only)
  - `claudemd_suggestions` (optional object, meta only)
- [ ] Add examples showing completion_data for meta and non-meta tasks
- [ ] Document that completion_data is extracted by skill postflight

**Timing**: 20 minutes

**Files to modify**:
- `.claude/context/core/formats/return-metadata-file.md` - Add completion_data field specification

**Verification**:
- Schema includes completion_data field with clear type definitions
- Examples demonstrate both meta and non-meta patterns

---

### Phase 2: Update General Implementation Agent [NOT STARTED]

**Goal**: Modify general-implementation-agent to generate completion_data in its metadata file, with special handling for meta tasks to include claudemd_suggestions.

**Tasks**:
- [ ] Read current general-implementation-agent.md
- [ ] Add Stage 6a: Generate Completion Data (after summary creation, before metadata writing)
- [ ] For meta tasks: Analyze what was implemented to determine appropriate claudemd_suggestions
- [ ] For non-meta tasks: Generate completion_summary only (roadmap_items when explicitly relevant)
- [ ] Update Stage 7 (Write Metadata) to include completion_data in the JSON
- [ ] Add examples of completion_data generation for different task types

**Timing**: 45 minutes

**Files to modify**:
- `.claude/agents/general-implementation-agent.md` - Add completion_data generation logic

**Verification**:
- Agent instructions include explicit completion_data generation steps
- Meta task handling includes claudemd_suggestions decision logic
- Examples show both meta and non-meta patterns

---

### Phase 3: Update Lean and LaTeX Implementation Agents [NOT STARTED]

**Goal**: Modify lean-implementation-agent and latex-implementation-agent to generate completion_data in their metadata files.

**Tasks**:
- [ ] Read current lean-implementation-agent.md
- [ ] Add completion_data generation stage (completion_summary only, since these are non-meta)
- [ ] Update metadata writing stage to include completion_data
- [ ] Read current latex-implementation-agent.md
- [ ] Add completion_data generation stage
- [ ] Update metadata writing stage to include completion_data

**Timing**: 30 minutes

**Files to modify**:
- `.claude/agents/lean-implementation-agent.md` - Add completion_data generation
- `.claude/agents/latex-implementation-agent.md` - Add completion_data generation

**Verification**:
- Both agents include completion_data generation instructions
- Metadata examples show completion_summary field

---

### Phase 4: Update Implementation Skills Postflight [NOT STARTED]

**Goal**: Modify all three implementation skills to extract completion_data from the metadata file and propagate it to state.json during postflight.

**Tasks**:
- [ ] Read current skill-implementer/SKILL.md Stage 7
- [ ] Add completion_data extraction from metadata file
- [ ] Add language-conditional propagation to state.json:
  - Always: completion_summary
  - If meta: claudemd_suggestions (when present)
  - If non-meta: roadmap_items (when present)
- [ ] Update skill-lean-implementation/SKILL.md Stage 7 with same pattern
- [ ] Update skill-latex-implementation/SKILL.md with same pattern (Section 5)

**Timing**: 50 minutes

**Files to modify**:
- `.claude/skills/skill-implementer/SKILL.md` - Add completion_data propagation in Stage 7
- `.claude/skills/skill-lean-implementation/SKILL.md` - Add completion_data propagation in Stage 7
- `.claude/skills/skill-latex-implementation/SKILL.md` - Add completion_data propagation in Section 5

**Verification**:
- All skills extract completion_data from metadata file
- jq commands correctly populate state.json with completion fields
- Two-step jq pattern used for complex content (per jq-escaping-workarounds.md)

---

### Phase 5: Documentation and Verification [NOT STARTED]

**Goal**: Ensure documentation is consistent and verify the implementation works correctly.

**Tasks**:
- [ ] Review state-management.md to ensure schema documentation is consistent
- [ ] Add note to CLAUDE.md "Completion Summary Workflow" section confirming producer implementation
- [ ] Create brief test scenario documentation describing how to verify:
  - Meta task completion produces claudemd_suggestions
  - Non-meta task completion produces completion_summary
  - /todo correctly extracts and displays these fields

**Timing**: 35 minutes

**Files to modify**:
- `.claude/rules/state-management.md` - Verify producer documentation is accurate
- `.claude/CLAUDE.md` - Minor update to confirm producer implementation

**Verification**:
- Documentation accurately describes the implemented workflow
- Test scenarios are clear and actionable

---

## Testing & Validation

- [ ] Schema: return-metadata-file.md includes completion_data field with examples
- [ ] Agents: All three implementation agents have completion_data generation stages
- [ ] Skills: All three implementation skills have completion_data extraction and propagation
- [ ] Integration: Documentation in state-management.md and CLAUDE.md is consistent

## Artifacts & Outputs

- plans/implementation-001.md (this file)
- summaries/implementation-summary-{DATE}.md (upon completion)
- Modified files:
  - .claude/context/core/formats/return-metadata-file.md
  - .claude/agents/general-implementation-agent.md
  - .claude/agents/lean-implementation-agent.md
  - .claude/agents/latex-implementation-agent.md
  - .claude/skills/skill-implementer/SKILL.md
  - .claude/skills/skill-lean-implementation/SKILL.md
  - .claude/skills/skill-latex-implementation/SKILL.md
  - .claude/rules/state-management.md (verification only)
  - .claude/CLAUDE.md (minor update)

## Rollback/Contingency

If the implementation causes issues:
1. The completion_data field is additive - agents without it continue to work
2. Skills check for field presence before propagation - missing fields are skipped
3. /todo already handles missing completion fields gracefully
4. Git history allows reverting individual file changes if needed

To rollback: Revert changes to agent and skill files. The schema documentation can remain as it's informational.
