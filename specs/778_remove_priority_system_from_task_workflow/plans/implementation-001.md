# Implementation Plan: Task #778

- **Task**: 778 - Remove priority system from task workflow
- **Status**: [IMPLEMENTING]
- **Effort**: 5 hours
- **Dependencies**: None
- **Research Inputs**: specs/778_remove_priority_system_from_task_workflow/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Remove the High/Medium/Low priority system from task management workflow, replacing it with a simpler flat `## Tasks` section where new tasks are prepended at the top. This implements recency-based prioritization (newer tasks appear first). Research identified 8 critical files and 10+ documentation files requiring updates. Changes are forward-only - existing tasks retain their priority field but it will be ignored.

### Research Integration

The research report (research-001.md) identified:
- 8 critical files requiring changes (task.md, state-management.md, skill-lake-repair, skill-learn, CLAUDE.md, state-template.json, task-management.md, todo.md)
- 10+ documentation/format files with priority references in examples
- 3 files to preserve unchanged (review.md, errors.md, roadmap-format.md) as they use priority for issue severity, not task priority
- Clear TODO.md structure change from 3 priority sections to single `## Tasks` section

## Goals & Non-Goals

**Goals**:
- Remove priority sections from TODO.md structure (## High Priority, ## Medium Priority, ## Low Priority -> ## Tasks)
- Remove priority field from state.json schema for new tasks
- Update task creation to prepend tasks at top of ## Tasks section
- Update skills that create tasks (skill-lake-repair, skill-learn) to target ## Tasks
- Remove priority_distribution from TODO.md frontmatter
- Update documentation to reflect new structure

**Non-Goals**:
- Migrate existing tasks (forward-only change)
- Remove issue severity priority from /review and /errors commands
- Remove phase priority from roadmap-format.md
- Bulk update state.json to remove existing priority fields

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| TODO.md parsing breaks after structure change | Medium | Medium | Test skill-lake-repair and skill-learn immediately after TODO.md changes |
| Skills fail to prepend correctly | Medium | Low | Clear pattern: insert after `## Tasks\n\n` |
| Existing priority fields cause validation errors | Low | Low | Leave existing fields; they are read but ignored |
| Review command confusion with issue severity | Low | Low | Issue severity is preserved; document distinction if asked |

## Implementation Phases

### Phase 1: Update Core Task Command [COMPLETED]

**Goal**: Remove priority from /task command - the primary entry point for task creation

**Tasks**:
- [ ] Remove `--priority` flag parsing from task.md
- [ ] Remove `"priority": "medium"` from jq command adding to state.json
- [ ] Change task entry insertion from priority sections to `## Tasks` with prepend logic
- [ ] Remove `- **Priority**: {priority}` from task entry template
- [ ] Update `--recover` and `--expand` operations to prepend to `## Tasks`
- [ ] Remove priority-related output formatting

**Timing**: 1 hour

**Files to modify**:
- `.claude/commands/task.md` - Lines 50-51, 128, 145-150, 213, 304, 362, 400, 451

**Verification**:
- Read task.md and confirm no priority references remain (except in comments about preserved commands)
- Confirm task entry template uses `## Tasks` insertion

---

### Phase 2: Update State Management Rules [COMPLETED]

**Goal**: Remove priority from state.json schema definition and TODO.md format specification

**Tasks**:
- [ ] Remove `priority` from active_projects field list description
- [ ] Remove "Grouped by priority (High/Medium/Low)" from TODO.md description
- [ ] Remove `- **Priority**: {High|Medium|Low}` from TODO.md Entry format
- [ ] Remove `"priority": "high"` from state.json Entry example
- [ ] Update synchronization guidance to reflect new structure

**Timing**: 30 minutes

**Files to modify**:
- `.claude/rules/state-management.md` - Lines 14, 20, 69, 86

**Verification**:
- Read state-management.md and confirm no priority references in schema definitions
- Confirm TODO.md format shows single `## Tasks` section

---

### Phase 3: Update Skills That Create Tasks [COMPLETED]

**Goal**: Update skill-lake-repair and skill-learn to prepend tasks to ## Tasks section

**Tasks**:
- [ ] **skill-lake-repair**: Remove `"priority": "high"` from jq command (line 660)
- [ ] **skill-lake-repair**: Change task insertion from "## High Priority" to "## Tasks" with prepend (lines 675-696)
- [ ] **skill-lake-repair**: Remove `- **Priority**: High` from task entry template (line 685)
- [ ] **skill-learn**: Remove `"priority": "..."` from all task JSON templates (lines 390, 408, 420, 442, 462, 498, 519, 560)
- [ ] **skill-learn**: Change insertion from priority sections to `## Tasks` prepend (line 569)
- [ ] **skill-learn**: Remove `- **Priority**: {priority}` from task entry templates (lines 576, 590)
- [ ] **skill-learn**: Remove `Priority` column from summary table (line 611)

**Timing**: 1.5 hours

**Files to modify**:
- `.claude/skills/skill-lake-repair/SKILL.md`
- `.claude/skills/skill-learn/SKILL.md`

**Verification**:
- Grep both skill files for "priority" - should find none related to task priority
- Confirm prepend logic targets `## Tasks` section

---

### Phase 4: Update Documentation and Templates [COMPLETED]

**Goal**: Remove priority references from documentation, format files, and agent definitions

**Tasks**:
- [ ] **CLAUDE.md**: Remove `"priority": "high"` from state.json structure example (line 85)
- [ ] **state-template.json**: Remove priority from required fields comment (line 19)
- [ ] **state-template.json**: Remove high/medium/low priority count fields (lines 30-32)
- [ ] **state-template.json**: Remove priority from pending_tasks comment (line 49)
- [ ] **task-management.md**: Remove priority from Core Principles (line 11)
- [ ] **task-management.md**: Remove priority from Required Fields (line 39)
- [ ] **task-management.md**: Remove "Override Priority when" section (lines 52-54)
- [ ] **task-management.md**: Change insertion guidance to prepend to `## Tasks` (line 86)
- [ ] **task-management.md**: Remove `--priority` flag references and examples (lines 95, 117-118, 130)
- [ ] **task-management.md**: Remove priority from metadata checklist (lines 240, 246)
- [ ] **todo.md** (command): Remove priority breakdown from output summary (lines 991-993)

**Timing**: 1 hour

**Files to modify**:
- `.claude/CLAUDE.md`
- `.claude/context/core/templates/state-template.json`
- `.claude/context/core/standards/task-management.md`
- `.claude/commands/todo.md`

**Verification**:
- Grep all modified files for "priority" - should find no task-priority references
- state.json example should show entry without priority field

---

### Phase 5: Update Format Files and Agents [IN PROGRESS]

**Goal**: Remove priority references from format specifications and agent definitions

**Tasks**:
- [ ] **report-format.md**: Remove `- **Priority**: High | Medium | Low` from metadata (lines 10, 59)
- [ ] **plan-format.md**: Remove `Priority` from required fields list (line 8)
- [ ] **plan-format.md**: Remove `- **Priority**: Medium` from example (line 18)
- [ ] **plan-format.md**: Remove `- **Priority**: High` from skeleton (line 103)
- [ ] **summary-format.md**: Remove `- **Priority**: High | Medium | Low` from metadata (line 11)
- [ ] **planner-agent.md**: Remove `- **Priority**: {priority}` from task entry format (lines 182, 260)
- [ ] **meta-builder-agent.md**: Remove priority-related questions, table columns, and section headers (lines 278, 294, 339, 356, 360, 559)
- [ ] **general-research-agent.md**: Remove `**Priority**: {priority}` from report metadata (line 197)
- [ ] **lean-research-flow.md**: Remove `**Priority**: {priority}` from task format (line 100)
- [ ] **orchestration/state-management.md**: Remove `"priority": "high"` from example (line 76)

**Timing**: 1 hour

**Files to modify**:
- `.claude/context/core/formats/report-format.md`
- `.claude/context/core/formats/plan-format.md`
- `.claude/context/core/formats/summary-format.md`
- `.claude/agents/planner-agent.md`
- `.claude/agents/meta-builder-agent.md`
- `.claude/agents/general-research-agent.md`
- `.claude/context/project/lean4/agents/lean-research-flow.md`
- `.claude/context/core/orchestration/state-management.md`

**Verification**:
- Grep all format files for task-priority references - should find none
- Agent definitions should not mention priority in task creation sections

---

### Phase 6: Update TODO.md Structure [NOT STARTED]

**Goal**: Convert TODO.md from priority sections to single ## Tasks section

**Tasks**:
- [ ] Remove `priority_distribution:` block from frontmatter
- [ ] Replace `## High Priority`, `## Medium Priority`, `## Low Priority` sections with single `## Tasks` section
- [ ] Move all existing tasks under `## Tasks` (preserve order: high -> medium -> low for continuity)
- [ ] Verify task separators (`---`) are intact

**Timing**: 30 minutes

**Files to modify**:
- `specs/TODO.md`

**Verification**:
- TODO.md has single `## Tasks` section after `# TODO` header
- No priority_distribution in frontmatter
- All existing tasks preserved with their content intact

## Testing & Validation

- [ ] Run `/task "Test priority removal"` and verify task is prepended to `## Tasks` section
- [ ] Verify state.json entry has no priority field
- [ ] Verify TODO.md entry has no `- **Priority**:` line
- [ ] Grep `.claude/` for "priority" and verify remaining matches are only for issue severity (review.md, errors.md) or phase priority (roadmap-format.md)
- [ ] Verify skill-lake-repair task insertion targets `## Tasks` (code inspection)
- [ ] Verify skill-learn task insertion targets `## Tasks` (code inspection)

## Artifacts & Outputs

- plans/implementation-001.md (this file)
- summaries/implementation-summary-{DATE}.md (on completion)

## Rollback/Contingency

If issues arise after implementation:
1. Git revert can restore all file changes
2. Existing tasks with priority fields continue to work (fields are ignored, not validated)
3. Can re-add priority sections to TODO.md if absolutely needed

Critical checkpoint: After Phase 1 (task.md), test task creation before proceeding. If task creation fails, rollback Phase 1 before continuing.
