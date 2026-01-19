# Implementation Plan: Task #605

- **Task**: 605 - Sync Plan Metadata Status with Task Status
- **Status**: [NOT STARTED]
- **Effort**: 2.5 hours
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: specs/605_sync_plan_metadata_status_with_task_status/reports/research-001.md
- **Artifacts**: plans/implementation-002.md (this file, supersedes v1)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Revision Notes

**v2 changes from v1**:
- Centralized approach: Single status update helper that updates all three locations (state.json, TODO.md, plan file) atomically
- Handles all status markers: IMPLEMENTING, COMPLETED, PARTIAL, BLOCKED, EXPANDED (not just the common ones)
- Reduces redundancy: Implementation skills call one helper instead of duplicating update logic
- Uniform workflow: /implement command uses the same pattern in both preflight and postflight

## Overview

Instead of adding plan file updates as additional lines in each skill, this revision creates a **unified status update pattern** that the /implement command follows. The key insight is that all three status locations (state.json, TODO.md, plan file) should be updated in the same code block to ensure atomicity and avoid redundancy.

### Research Integration

From research-001.md:
- Evidence: Tasks 604 and 568 are `[COMPLETED]` but their plan files show `[NOT STARTED]`
- Current skills update state.json and TODO.md separately - plan file is missed
- All status markers should map consistently across the three locations

### User Feedback

"There are other possible status markers that the plan could occupy such as [EXPANDED] or [BLOCKED], but what matters most is that the status of the task is updated everywhere at once (in TODO.md, state.json, and the most recent plan file if any exists). I want to avoid redundancy of operations, providing an efficient and uniform workflow in the /implement command."

## Goals & Non-Goals

**Goals**:
- Update all three status locations (state.json, TODO.md, plan file) in a single operation
- Support all status markers: IMPLEMENTING, COMPLETED, PARTIAL, BLOCKED, EXPANDED
- Reduce code duplication across implementation skills
- Create a uniform pattern that /implement uses consistently

**Non-Goals**:
- Creating a separate skill-status-sync tool (inline updates are sufficient)
- Retroactively fixing existing completed tasks
- Adding plan status sync to research/planning skills (those don't change implementation status)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Plan file doesn't exist | Low | Medium | Check file exists before sed; skip gracefully |
| Multiple plan versions | Medium | Low | Use `sort -V \| tail -1` to get latest version |
| Status marker format varies | Low | Low | Use robust regex that handles any status text |
| One location fails to update | Medium | Low | Update in sequence: state.json → TODO.md → plan file |

## Implementation Phases

### Phase 1: Define Unified Status Update Pattern [COMPLETED]

**Goal**: Create a reusable bash code block that updates all three locations atomically.

**Tasks**:
- [ ] Define the canonical status update pattern with three steps:
  1. Update state.json via jq
  2. Update TODO.md via sed (status marker line)
  3. Update plan file via sed (if exists)
- [ ] Handle all status markers with a mapping table
- [ ] Add error checking that doesn't block execution

**Pattern to implement**:
```bash
# Unified status update (use in both preflight and postflight)
# Arguments: $task_number, $project_name, $new_status (lowercase), $session_id

# Step 1: Update state.json
jq --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
   --arg status "$new_status" \
   --arg sid "$session_id" \
  '(.active_projects[] | select(.project_number == '$task_number')) |= . + {
    status: $status,
    last_updated: $ts,
    session_id: $sid
  }' specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json

# Step 2: Update TODO.md
# Convert status to uppercase marker format: implementing -> IMPLEMENTING
status_upper=$(echo "$new_status" | tr '[:lower:]' '[:upper:]')
# Use Edit tool to change status marker (Claude will handle this)

# Step 3: Update plan file (if exists)
plan_file=$(ls -1 "specs/${task_number}_${project_name}/plans/implementation-"*.md 2>/dev/null | sort -V | tail -1)
if [ -n "$plan_file" ] && [ -f "$plan_file" ]; then
    sed -i "s/^\- \*\*Status\*\*: \[.*\]$/- **Status**: [${status_upper}]/" "$plan_file"
fi
```

**Timing**: 30 minutes

**Files to modify**:
- None in this phase (pattern definition only)

**Verification**:
- Pattern handles all status values correctly
- Pattern is self-contained and can be copied into skills

---

### Phase 2: Update skill-implementer with Unified Pattern [IN PROGRESS]

**Goal**: Replace separate state.json/TODO.md updates with unified pattern in skill-implementer.

**Tasks**:
- [ ] Replace Stage 2 (Preflight) state.json + TODO.md updates with unified pattern
- [ ] Add plan file update as Step 3 of the unified update
- [ ] Replace Stage 7 (Postflight) state.json + TODO.md updates with unified pattern
- [ ] Ensure status values match: implementing (preflight), completed/partial (postflight)

**Timing**: 45 minutes

**Files to modify**:
- `.claude/skills/skill-implementer/SKILL.md` - Refactor Stages 2 and 7

**Verification**:
- Preflight updates all three locations to [IMPLEMENTING]
- Postflight updates all three locations to [COMPLETED] or [PARTIAL]
- Plan file update is conditional (only if file exists)

---

### Phase 3: Update skill-lean-implementation with Unified Pattern [NOT STARTED]

**Goal**: Apply the same unified pattern to the Lean implementation skill.

**Tasks**:
- [ ] Replace Stage 2 (Preflight) updates with unified pattern
- [ ] Replace Stage 7 (Postflight) updates with unified pattern
- [ ] Ensure consistency with skill-implementer

**Timing**: 45 minutes

**Files to modify**:
- `.claude/skills/skill-lean-implementation/SKILL.md` - Refactor Stages 2 and 7

**Verification**:
- Same unified pattern as skill-implementer
- Both skills have identical status update logic

---

### Phase 4: Update skill-latex-implementation with Unified Pattern [NOT STARTED]

**Goal**: Apply the same unified pattern to the LaTeX implementation skill.

**Tasks**:
- [ ] Identify correct stage numbers (skill-latex uses different numbering)
- [ ] Replace preflight updates with unified pattern
- [ ] Replace postflight updates with unified pattern
- [ ] Ensure consistency with other implementation skills

**Timing**: 30 minutes

**Files to modify**:
- `.claude/skills/skill-latex-implementation/SKILL.md` - Refactor status update stages

**Verification**:
- Same unified pattern as other implementation skills
- Correct stage numbers used

---

## Testing & Validation

- [ ] All three implementation skills have identical status update patterns
- [ ] Preflight updates all three locations to [IMPLEMENTING]
- [ ] Postflight updates all three locations to [COMPLETED] or [PARTIAL]
- [ ] Plan file update handles missing files gracefully
- [ ] Status mapping is correct for all statuses

## Status Mapping Reference

| state.json status | TODO.md marker | Plan file marker |
|-------------------|----------------|------------------|
| implementing | [IMPLEMENTING] | [IMPLEMENTING] |
| completed | [COMPLETED] | [COMPLETED] |
| partial | [PARTIAL] | [PARTIAL] |
| blocked | [BLOCKED] | [BLOCKED] |
| expanded | [EXPANDED] | [EXPANDED] |

## Artifacts & Outputs

- `.claude/skills/skill-implementer/SKILL.md` - Updated with unified pattern
- `.claude/skills/skill-lean-implementation/SKILL.md` - Updated with unified pattern
- `.claude/skills/skill-latex-implementation/SKILL.md` - Updated with unified pattern
- `specs/605_sync_plan_metadata_status_with_task_status/summaries/implementation-summary-{DATE}.md` - Completion summary

## Rollback/Contingency

If changes cause issues:
1. Revert skill files: `git checkout HEAD~1 -- .claude/skills/skill-*/SKILL.md`
2. The unified pattern is isolated - easy to identify and revert
3. No impact on core functionality - status sync is informational
