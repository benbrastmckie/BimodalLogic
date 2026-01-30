# Research Report: Task #778

**Task**: 778 - Remove priority system from task workflow
**Started**: 2026-01-30T12:00:00Z
**Completed**: 2026-01-30T12:30:00Z
**Effort**: 4-6 hours (estimated implementation)
**Dependencies**: None
**Sources/Inputs**:
- Codebase search via Grep (`.claude/`, `specs/`)
- File analysis via Read
**Artifacts**:
- specs/778_remove_priority_system_from_task_workflow/reports/research-001.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- Found **31 files** in `.claude/` directory that reference priority
- **Primary changes required** in 8 files: task.md, state-management.md, skill-lake-repair, skill-learn, CLAUDE.md, state-template.json, task-management.md, and todo.md
- **Secondary changes** in 15+ format/context files that reference priority in examples or schemas
- New TODO.md structure uses single `## Tasks` section with tasks prepended at top
- Existing tasks retain their priority field during migration (forward-only change)

## Context & Scope

This research identifies all files requiring modification to remove the High/Medium/Low priority system from task management. The goal is to simplify task management by using a flat `## Tasks` section where new tasks are added at the top, naturally implementing recency-based prioritization.

**Scope**:
- Remove priority sections from TODO.md structure
- Remove priority field from state.json schema
- Update task creation to prepend to `## Tasks` section
- Update skills that create tasks
- Remove priority_distribution from frontmatter
- Forward-only: existing tasks keep their priority field (read but not enforced)

## Findings

### Category 1: Critical Files (Must Change)

#### 1.1 `.claude/commands/task.md`
**Lines affected**: 50-51, 128, 145-150, 213, 304, 362, 400, 451

**Required changes**:
- Line 50-51: Remove `--priority` flag parsing
- Line 128: Remove `"priority": "medium"` from jq command for state.json
- Line 145-150: Change "**Part B - Add task entry** under appropriate priority section" to prepend under `## Tasks`
- Line 150: Remove `- **Priority**: {priority}` from task entry template
- Line 213: Change "Add recovered task entry under appropriate priority section" to "Prepend under ## Tasks"
- Line 304: Remove `priority=$(echo "$task_data" | jq -r '.priority // "medium"')`
- Line 362: Remove `**Priority**: {priority}` from review output
- Line 400: Remove `Priority: {inherited from parent}`
- Line 451: Remove `"priority": "'{priority}'"` from jq command

#### 1.2 `.claude/rules/state-management.md`
**Lines affected**: 14, 20, 69, 86

**Required changes**:
- Line 14: Remove `priority` from "active_projects array with status, language, priority"
- Line 20: Remove "Grouped by priority (High/Medium/Low)"
- Line 69: Remove `- **Priority**: {High|Medium|Low}` from TODO.md Entry format
- Line 86: Remove `"priority": "high"` from state.json Entry example

#### 1.3 `.claude/skills/skill-lake-repair/SKILL.md`
**Lines affected**: 660, 675-696

**Required changes**:
- Line 660: Remove `"priority": "high"` from jq command
- Lines 675-696: Change task insertion from "## High Priority" to "## Tasks" with prepend logic
  - Current: `old_string: "## High Priority\n"`
  - New: Target `## Tasks` section, prepend new task after header
- Line 685: Remove `- **Priority**: High` from task entry template

#### 1.4 `.claude/skills/skill-learn/SKILL.md`
**Lines affected**: 390, 408, 420, 442, 462, 498, 519, 560, 569, 576, 590, 611

**Required changes**:
- Lines 390, 408, 420, 442, 462, 498, 519, 560: Remove `"priority": "..."` from task JSON templates
- Line 569: Change "Append new task entry in appropriate priority section" to "Prepend to ## Tasks"
- Lines 576, 590: Remove `- **Priority**: {priority}` from task entry templates
- Line 611: Remove `Priority` column from summary table

#### 1.5 `.claude/CLAUDE.md`
**Lines affected**: 85

**Required changes**:
- Line 85: Remove `"priority": "high"` from state.json structure example

#### 1.6 `.claude/context/core/templates/state-template.json`
**Lines affected**: 19, 30-32, 49

**Required changes**:
- Line 19: Remove `priority` from comment listing required fields
- Lines 30-32: Remove `high_priority_tasks`, `medium_priority_tasks`, `low_priority_tasks` fields
- Line 49: Remove `priority` from pending_tasks comment

#### 1.7 `.claude/context/core/standards/task-management.md`
**Lines affected**: 11, 39, 52-54, 86, 95, 117-118, 130, 240, 246, 266

**Required changes**:
- Line 11: Remove "priority must be explicitly tracked" from Core Principles
- Line 39: Remove `- **Priority**: Task priority (Low|Medium|High...)` from Required Fields
- Lines 52-54: Remove "Override Priority when" section
- Line 86: Change "Insert under the appropriate Priority section" to "Prepend to ## Tasks"
- Line 95: Remove `--priority` flag references
- Lines 117-118: Remove `--priority High` and `--priority Medium` from examples
- Line 130: Remove "Priority defaults to Medium"
- Line 240: Remove "Priority" from metadata checklist
- Line 246: Remove "Priority" from required fields list

#### 1.8 `.claude/commands/todo.md`
**Lines affected**: 991-993

**Required changes**:
- Lines 991-993: Remove priority breakdown from output summary:
  ```
  - High priority: {N}
  - Medium priority: {N}
  - Low priority: {N}
  ```

### Category 2: Format/Documentation Files (Secondary Changes)

#### 2.1 `.claude/context/core/formats/report-format.md`
**Lines affected**: 10, 59

**Required changes**:
- Line 10: Remove `- **Priority**: High | Medium | Low` from metadata
- Line 59: Remove `- **Priority**: High` from example skeleton

#### 2.2 `.claude/context/core/formats/plan-format.md`
**Lines affected**: 8, 18, 103

**Required changes**:
- Line 8: Remove `Priority` from required fields list
- Line 18: Remove `- **Priority**: Medium` from example
- Line 103: Remove `- **Priority**: High` from example skeleton

#### 2.3 `.claude/context/core/formats/summary-format.md`
**Lines affected**: 11

**Required changes**:
- Line 11: Remove `- **Priority**: High | Medium | Low` from metadata

#### 2.4 `.claude/agents/planner-agent.md`
**Lines affected**: 182, 260

**Required changes**:
- Line 182: Remove `- **Priority**: {priority}` from task entry format
- Line 260: Remove `- **Priority**:` from pattern recognition list

#### 2.5 `.claude/agents/meta-builder-agent.md`
**Lines affected**: 278, 294, 339, 356, 360, 559

**Required changes**:
- Line 278: Remove "Priority assignment (High, Medium, Low per task)" from questions
- Line 294: Remove `Priority` column from task table
- Line 339: Remove `- **Priority**: {priority}` from task entry format
- Lines 356, 360: Remove `**High Priority**:` and `**Medium Priority**:` section headers
- Line 559: Remove "under appropriate priority section"

#### 2.6 `.claude/agents/general-research-agent.md`
**Lines affected**: 197

**Required changes**:
- Line 197: Remove `**Priority**: {priority}` from report metadata

#### 2.7 `.claude/context/project/lean4/agents/lean-research-flow.md`
**Lines affected**: 100

**Required changes**:
- Line 100: Remove `**Priority**: {priority}` from task format

#### 2.8 `.claude/context/core/orchestration/state-management.md`
**Lines affected**: 76

**Required changes**:
- Line 76: Remove `"priority": "high"` from example

### Category 3: Review/Errors Commands (Keep Priority for Issues)

The `/review` and `/errors` commands use priority for **issue severity**, not task priority. These should be preserved as they serve a different purpose (categorizing discovered issues by importance).

**Files to leave unchanged**:
- `.claude/commands/review.md` - Uses priority for issue severity
- `.claude/commands/errors.md` - Uses priority for fix ordering
- `.claude/context/core/formats/roadmap-format.md` - Uses priority for phase importance

### Category 4: TODO.md Structure Changes

#### Current Structure
```markdown
---
next_project_number: 779
priority_distribution:
  critical: 0
  high: 3
  medium: 4
  low: 2
---

# TODO

## High Priority

## Medium Priority

### 778. Task...

## Low Priority
```

#### New Structure
```markdown
---
next_project_number: 779
---

# TODO

## Tasks

### 778. Task...
---

### 777. Task...
---
```

**Required changes**:
- Remove `priority_distribution:` block from frontmatter
- Replace `## High Priority`, `## Medium Priority`, `## Low Priority` with single `## Tasks`
- New tasks prepend (insert after `## Tasks\n\n`) rather than append to priority sections

### Category 5: state.json Schema Changes

#### Current state.json active_projects entry
```json
{
  "project_number": 334,
  "project_name": "task_slug",
  "status": "planned",
  "language": "lean",
  "priority": "high",
  "created": "..."
}
```

#### New state.json active_projects entry
```json
{
  "project_number": 334,
  "project_name": "task_slug",
  "status": "planned",
  "language": "lean",
  "created": "..."
}
```

**Note**: Existing entries with `priority` field are harmless (will be ignored). No need to migrate existing data.

## Decisions

1. **Forward-only migration**: Existing tasks retain priority field; no bulk data migration
2. **Preserve review/errors priority**: Issue severity is distinct from task priority
3. **Prepend strategy**: New tasks insert at top of `## Tasks` section
4. **Keep separator pattern**: Task entries continue to use `---` separator between them
5. **Remove frontmatter metrics**: `priority_distribution` block removed entirely

## Recommendations

1. **Phase 1**: Update core files (task.md, state-management.md)
2. **Phase 2**: Update skills (skill-lake-repair, skill-learn)
3. **Phase 3**: Update documentation/format files
4. **Phase 4**: Update TODO.md structure (manual one-time change)
5. **Phase 5**: Test task creation workflow

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Existing tasks have priority in state.json | Low | Fields are read but ignored; harmless |
| Skills fail to prepend correctly | Medium | Clear pattern: insert after `## Tasks\n\n` |
| Review command confusion | Low | Document that review priority = issue severity |
| TODO.md parsing breaks | Medium | Test skill-lake-repair and skill-learn after changes |

## Appendix

### Search Queries Used
```bash
grep -ri "priority" .claude/
grep -ri "High Priority|Medium Priority|Low Priority" .claude/
grep -ri "priority" specs/*.md
grep -ri "priority" specs/*.json
```

### Files Identified (31 total in .claude/)
1. `.claude/commands/task.md`
2. `.claude/commands/todo.md`
3. `.claude/commands/meta.md`
4. `.claude/commands/errors.md` (keep - issue severity)
5. `.claude/commands/review.md` (keep - issue severity)
6. `.claude/commands/lake.md`
7. `.claude/commands/learn.md`
8. `.claude/CLAUDE.md`
9. `.claude/README.md`
10. `.claude/rules/state-management.md`
11. `.claude/skills/skill-orchestrator/SKILL.md`
12. `.claude/skills/skill-lake-repair/SKILL.md`
13. `.claude/skills/skill-learn/SKILL.md`
14. `.claude/agents/planner-agent.md`
15. `.claude/agents/meta-builder-agent.md`
16. `.claude/agents/general-research-agent.md`
17. `.claude/context/core/templates/state-template.json`
18. `.claude/context/core/templates/delegation-context.md`
19. `.claude/context/core/formats/report-format.md`
20. `.claude/context/core/formats/plan-format.md`
21. `.claude/context/core/formats/summary-format.md`
22. `.claude/context/core/formats/roadmap-format.md` (keep - phase priority)
23. `.claude/context/core/standards/task-management.md`
24. `.claude/context/core/standards/analysis-framework.md`
25. `.claude/context/core/standards/code-patterns.md`
26. `.claude/context/core/standards/testing.md`
27. `.claude/context/core/orchestration/state-management.md`
28. `.claude/context/core/orchestration/routing.md`
29. `.claude/context/core/orchestration/orchestrator.md`
30. `.claude/context/core/workflows/command-lifecycle.md`
31. `.claude/context/project/lean4/agents/lean-research-flow.md`

### Summary of Changes by File Count
- **Must change**: 8 files
- **Should change** (documentation/formats): 10 files
- **Keep unchanged** (different purpose): 3 files
- **Contextual/minor**: 10 files
