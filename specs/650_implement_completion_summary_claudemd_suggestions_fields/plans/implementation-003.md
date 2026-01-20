# Implementation Plan: Task #650

- **Task**: 650 - Implement completion_summary and claudemd_suggestions fields in /implement workflow
- **Version**: 003
- **Status**: [COMPLETED]
- **Effort**: 3 hours
- **Priority**: High
- **Dependencies**: None
- **Research Inputs**: specs/650_implement_completion_summary_claudemd_suggestions_fields/reports/research-001.md
- **Artifacts**: plans/implementation-003.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Revision Notes (v003)

**Change from v002**: Simplified the responsibility split between `/implement` and `/todo`:

- **`/implement` responsibility**: Always populate `claudemd_suggestions` for meta tasks, describing what .claude/ changes were made. Value is `"none"` if no .claude/ files were modified. No decision criteria needed - just factual reporting.

- **`/todo` responsibility**: Evaluate `claudemd_suggestions` content and decide whether the changes warrant CLAUDE.md updates. This is where criteria for inclusion belong.

**Key insight**: CLAUDE.md is loaded context for agents, not primarily user documentation. The field exists to track .claude/ modifications, not to pre-filter what gets documented.

## Overview

This task modifies the /implement command-skill-agent workflow to populate `completion_summary` and `claudemd_suggestions` fields when tasks are completed. The implementation follows a producer/consumer pattern:
- **Producer** (`/implement`): Reports what was changed
- **Consumer** (`/todo`): Decides what warrants CLAUDE.md updates

### Design Principle: Factual Reporting

**For meta tasks, `claudemd_suggestions` is mandatory and describes .claude/ changes:**

| Scenario | claudemd_suggestions value |
|----------|---------------------------|
| Modified .claude/ files | Brief description of changes (e.g., "Added completion_data field to return-metadata-file.md") |
| No .claude/ files modified | `"none"` |

**The field is always populated** - there's no concept of "should I include this?" at the `/implement` level. That decision belongs to `/todo`.

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
- Update general-implementation-agent to always generate `claudemd_suggestions` for meta tasks
- The field describes .claude/ changes factually; `"none"` when no changes
- Update lean-implementation-agent and latex-implementation-agent to generate completion_data
- Update all three implementation skills to propagate completion fields in postflight
- Ensure completion_summary is always populated when status becomes "completed"

**Non-Goals**:
- Making `/implement` decide what merits CLAUDE.md documentation (that's `/todo`'s job)
- Adding criteria/filtering logic to agents (keep it simple: report what changed)
- Modifying the /todo command (separate concern)
- Changing the /implement command itself (skills handle postflight internally)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| jq escaping issues with complex suggestion content | M | M | Use two-step jq pattern per jq-escaping-workarounds.md |
| Agents forget to generate completion_summary | M | L | Add explicit instructions in Stage 7 of each agent |
| claudemd_suggestions format inconsistent | L | M | Provide clear template in agent instructions |
| Metadata file schema change breaks existing agents | M | L | completion_data field is additive; existing agents work without it |

## Implementation Phases

### Phase 1: Extend Return Metadata Schema [COMPLETED]

**Goal**: Update the return-metadata-file.md schema to document the new `completion_data` field that agents should include.

**Tasks**:
- [ ] Read current return-metadata-file.md schema
- [ ] Add `completion_data` field specification with:
  - `completion_summary` (required for implemented status)
  - `roadmap_items` (optional array, non-meta only)
  - `claudemd_suggestions` (required string for meta tasks, `"none"` if no .claude/ changes)
- [ ] Add examples showing:
  - Meta task with .claude/ changes: `"claudemd_suggestions": "Added X to Y, updated Z"`
  - Meta task without .claude/ changes: `"claudemd_suggestions": "none"`
  - Non-meta task: no claudemd_suggestions field
- [ ] Document that completion_data is extracted by skill postflight

**Timing**: 20 minutes

**Files to modify**:
- `.claude/context/core/formats/return-metadata-file.md` - Add completion_data field specification

**Verification**:
- Schema includes completion_data field with clear type definitions
- claudemd_suggestions is documented as required for meta tasks (string, not optional object)
- Examples show both "changes made" and "none" patterns

---

### Phase 2: Update General Implementation Agent [COMPLETED]

**Goal**: Modify general-implementation-agent to generate completion_data in its metadata file. For meta tasks, always include claudemd_suggestions describing .claude/ modifications.

**Tasks**:
- [ ] Read current general-implementation-agent.md
- [ ] Add Stage 6a: Generate Completion Data (after summary creation, before metadata writing)
- [ ] For meta tasks:
  - List .claude/ files that were modified during implementation
  - If any: set claudemd_suggestions to brief description (e.g., "Updated agent X to include Y")
  - If none: set claudemd_suggestions to `"none"`
- [ ] For non-meta tasks: Generate completion_summary only (roadmap_items when explicitly relevant)
- [ ] Update Stage 7 (Write Metadata) to include completion_data in the JSON
- [ ] Provide example template for claudemd_suggestions string

**Timing**: 40 minutes

**Files to modify**:
- `.claude/agents/general-implementation-agent.md` - Add completion_data generation with simple .claude/ change tracking

**Verification**:
- Agent instructions include explicit completion_data generation steps
- Meta task handling always populates claudemd_suggestions
- No decision criteria - just factual reporting of what changed

---

### Phase 3: Update Lean and LaTeX Implementation Agents [COMPLETED]

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

### Phase 4: Update Implementation Skills Postflight [COMPLETED]

**Goal**: Modify all three implementation skills to extract completion_data from the metadata file and propagate it to state.json during postflight.

**Tasks**:
- [ ] Read current skill-implementer/SKILL.md Stage 7
- [ ] Add completion_data extraction from metadata file
- [ ] Add language-conditional propagation to state.json:
  - Always: completion_summary
  - If meta: claudemd_suggestions (always present for meta tasks)
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

### Phase 5: Update Documentation [COMPLETED]

**Goal**: Update state-management.md to reflect the simplified schema and responsibility split.

**Tasks**:
- [ ] Update state-management.md claudemd_suggestions schema:
  - Change from optional object to required string for meta tasks
  - Document that value is description of .claude/ changes or "none"
  - Remove action/section/rationale object structure (simplify to string)
- [ ] Add note clarifying responsibility split:
  - `/implement` reports changes factually
  - `/todo` decides what warrants CLAUDE.md updates
- [ ] Remove "Design Principle" section about sparse suggestions (no longer applicable)

**Timing**: 30 minutes

**Files to modify**:
- `.claude/rules/state-management.md` - Simplify claudemd_suggestions schema to string

**Verification**:
- Schema shows claudemd_suggestions as string (not object)
- Responsibility split is clearly documented
- No filtering criteria in /implement documentation

---

## Testing & Validation

- [ ] Schema: return-metadata-file.md includes completion_data with string-based claudemd_suggestions
- [ ] Agents: general-implementation-agent always populates claudemd_suggestions for meta tasks
- [ ] Agents: Lean/LaTeX agents include completion_summary
- [ ] Skills: All three implementation skills propagate completion_data to state.json
- [ ] Documentation: state-management.md reflects simplified string schema

## Artifacts & Outputs

- plans/implementation-003.md (this file)
- summaries/implementation-summary-{DATE}.md (upon completion)
- Modified files:
  - .claude/context/core/formats/return-metadata-file.md
  - .claude/agents/general-implementation-agent.md
  - .claude/agents/lean-implementation-agent.md
  - .claude/agents/latex-implementation-agent.md
  - .claude/skills/skill-implementer/SKILL.md
  - .claude/skills/skill-lean-implementation/SKILL.md
  - .claude/skills/skill-latex-implementation/SKILL.md
  - .claude/rules/state-management.md (simplify schema)

## Rollback/Contingency

If the implementation causes issues:
1. The completion_data field is additive - agents without it continue to work
2. Skills check for field presence before propagation - missing fields are skipped
3. /todo already handles missing completion fields gracefully
4. Git history allows reverting individual file changes if needed

To rollback: Revert changes to agent and skill files. The schema documentation can remain as it's informational.
