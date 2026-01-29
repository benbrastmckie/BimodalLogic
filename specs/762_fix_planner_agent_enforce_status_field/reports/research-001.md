# Research Report: Task #762

**Task**: 762 - fix_planner_agent_enforce_status_field
**Started**: 2026-01-29T12:00:00Z
**Completed**: 2026-01-29T12:15:00Z
**Effort**: 30 minutes
**Priority**: Medium
**Dependencies**: None
**Sources/Inputs**: Codebase exploration (planner-agent.md, plan-format.md, task plans)
**Artifacts**: specs/762_fix_planner_agent_enforce_status_field/reports/research-001.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- Task 750 v005 plan is **missing the Status field** in its metadata block, while older plans (758, 759, 741) all have it
- The planner-agent.md currently lists plan-format.md in "Load When Creating Plan" (line 43), but agents may skip this context
- There is **no explicit verification step** in Stage 5 or Stage 6 to ensure the Status field exists before writing success metadata
- Required changes: (1) move plan-format.md to "Always Load" section, (2) add verification step in Stage 6

## Context & Scope

The task description identifies that plan-format.md requires a Status field (`- **Status**: [NOT STARTED]`) in the metadata block, but task 750's v005 plan omitted this field. The investigation focuses on:

1. Understanding planner-agent.md structure and context loading sections
2. Identifying where verification should be added
3. Comparing plans with and without the Status field to confirm the evidence

## Findings

### 1. Task 750 v005 Plan Missing Status Field

**Evidence** (specs/750_refactor_forward_truth_lemma_remove_sorries/plans/implementation-005.md):

Lines 1-12 of the metadata block:
```markdown
# Implementation Plan: Task #750

**Task**: Refactor forward Truth Lemma - Remove sorries
**Version**: 005
**Created**: 2026-01-29
**Language**: lean
**Research Input**: research-011.md (Approach 1: MCS-Restricted Truth Lemma)
```

**MISSING**: `- **Status**: [NOT STARTED]`

This plan was created without the required Status line.

### 2. Comparison with Older Plans (Have Status Field)

**Task 758 plan (lines 1-12)**:
```markdown
# Implementation Plan: Audit and Reduce Metalogic Sorries

- **Task**: 758 - Audit and reduce sorry count in Theories/Bimodal/Metalogic/
- **Status**: [COMPLETED]
- **Effort**: 8 hours
```

**Task 759 plan (lines 1-12)**:
```markdown
# Implementation Plan: Task #759

- **Task**: 759 - update_todo_md_sorry_metrics
- **Status**: [COMPLETED]
- **Effort**: 2.5 hours
```

**Task 741 plan (lines 1-12)**:
```markdown
# Implementation Plan: Task #741

- **Task**: 741 - Witness extraction architecture for backward Truth Lemma
- **Status**: [PARTIAL]
- **Effort**: 10 hours
```

All three older plans have the Status field. Task 750's v005 is the outlier.

### 3. Current planner-agent.md Context References Section (Lines 35-48)

```markdown
## Context References

Load these on-demand using @-references:

**Always Load**:
- `@.claude/context/core/formats/return-metadata-file.md` - Metadata file schema

**Load When Creating Plan**:
- `@.claude/context/core/formats/plan-format.md` - Plan artifact structure and metadata
- `@.claude/context/core/workflows/task-breakdown.md` - Task decomposition guidelines
```

**Problem**: plan-format.md is in "Load When Creating Plan" but agents sometimes don't load optional context, leading to missing required fields.

### 4. plan-format.md Status Field Requirement (Lines 5-8)

```markdown
## Metadata (Markdown block, required)
- Use a single **Status** field with status markers (`[NOT STARTED]`, `[IN PROGRESS]`, `[BLOCKED]`, `[ABANDONED]`, `[COMPLETED]`) per status-markers.md.
- Do **not** use YAML front matter. Use a Markdown metadata block at the top of the plan.
- Required fields: Task, Status, Effort, Priority, Dependencies, Research Inputs, Artifacts, Standards, Type, Lean Intent.
```

**Note**: Status is explicitly listed as a required field.

### 5. Current Stage 5 (Create Plan File) - Lines 165-248

Stage 5 provides a plan template that DOES include Status:
```markdown
### Stage 5: Create Plan File

...

Write plan file following plan-format.md structure:

```markdown
# Implementation Plan: Task #{N}

- **Task**: {N} - {title}
- **Status**: [NOT STARTED]
- **Effort**: {total_hours} hours
```

**Observation**: The template in Stage 5 includes Status, but there's no verification step to ensure the agent actually followed the template.

### 6. Current Stage 6 (Write Metadata File) - Lines 250-279

Stage 6 writes metadata but doesn't verify plan file contents:

```markdown
### Stage 6: Write Metadata File

**CRITICAL**: Write metadata to the specified file path, NOT to console.

Write to `specs/{N}_{SLUG}/.return-meta.json`:

```json
{
  "status": "planned",
  "artifacts": [
    {
      "type": "plan",
      "path": "specs/{N}_{SLUG}/plans/implementation-{NNN}.md",
      ...
```

**Gap**: No verification of plan content before writing success metadata.

### 7. Critical Requirements Section (Lines 365-389)

Item 7 says:
```markdown
7. Always follow plan-format.md structure exactly
```

But this is a passive requirement with no active enforcement mechanism.

## Recommendations

### Change 1: Move plan-format.md to Always Load Section

Update lines 39-44 in planner-agent.md:

**Before**:
```markdown
**Always Load**:
- `@.claude/context/core/formats/return-metadata-file.md` - Metadata file schema

**Load When Creating Plan**:
- `@.claude/context/core/formats/plan-format.md` - Plan artifact structure and metadata
- `@.claude/context/core/workflows/task-breakdown.md` - Task decomposition guidelines
```

**After**:
```markdown
**Always Load**:
- `@.claude/context/core/formats/return-metadata-file.md` - Metadata file schema
- `@.claude/context/core/formats/plan-format.md` - Plan artifact structure (REQUIRED fields)

**Load When Creating Plan**:
- `@.claude/context/core/workflows/task-breakdown.md` - Task decomposition guidelines
```

### Change 2: Add Verification Step in Stage 6

Insert a verification step at the beginning of Stage 6 (before writing success metadata), around line 250:

**Add after "### Stage 6: Write Metadata File"**:

```markdown
### Stage 6: Verify Plan and Write Metadata File

**CRITICAL PRE-CHECK**: Before writing success metadata, verify the plan file contains all required fields from plan-format.md:

**Required Metadata Fields (verify present)**:
1. `- **Task**:` line exists
2. `- **Status**:` line exists with valid marker (`[NOT STARTED]`)
3. `- **Effort**:` line exists
4. `- **Priority**:` line exists
5. `- **Dependencies**:` line exists
6. `- **Research Inputs**:` line exists
7. `- **Artifacts**:` line exists
8. `- **Standards**:` line exists
9. `- **Type**:` line exists
10. `- **Lean Intent**:` line exists

If any required field is missing:
1. Re-read plan-format.md via `@.claude/context/core/formats/plan-format.md`
2. Edit the plan file to add missing fields
3. Re-verify before proceeding

Only after verification passes, write metadata to...
```

### Change 3: Update Critical Requirements

Add to the "MUST DO" list (around line 374):

```markdown
10. **MUST** verify plan file contains Status field before writing success metadata
```

## Decisions

- **Chose**: Move plan-format.md to "Always Load" rather than duplicating content
- **Rationale**: Keeps single source of truth in plan-format.md while ensuring it's loaded
- **Chose**: Add verification in Stage 6 rather than creating new Stage 5.5
- **Rationale**: Verification is logically part of "write success metadata" - must verify before declaring success

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Agents may still skip context even with "Always Load" | Medium | Low | Explicit verification step catches this |
| Verification step adds complexity | Low | Medium | Keep verification simple (just check field presence) |
| Edit/re-verify loop could fail | Low | Low | Clear instructions for re-reading plan-format.md |

## Appendix

### Search Queries Used

1. `Read planner-agent.md` - Full agent definition
2. `Read plan-format.md` - Standard for plan artifacts
3. `Glob specs/*/plans/*.md` - Find example plans
4. `Read implementation-005.md` - Task 750 v005 (missing Status)
5. `Read implementation-001.md` - Tasks 758, 759, 741 (have Status)

### References

- `.claude/agents/planner-agent.md` - Agent definition being modified
- `.claude/context/core/formats/plan-format.md` - Plan format standard
- `specs/750_refactor_forward_truth_lemma_remove_sorries/plans/implementation-005.md` - Evidence of missing Status
- `specs/758_audit_and_reduce_metalogic_sorries/plans/implementation-001.md` - Correct format example
- `specs/759_update_todo_md_sorry_metrics/plans/implementation-001.md` - Correct format example
- `specs/741_witness_extraction_architecture_for_backward_truth_lemma/plans/implementation-001.md` - Correct format example
