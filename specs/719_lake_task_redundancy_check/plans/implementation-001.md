# Implementation Plan: Task #719

- **Task**: 719 - lake_task_redundancy_check
- **Status**: [NOT STARTED]
- **Effort**: 1.5 hours
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: specs/719_lake_task_redundancy_check/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Enhance the /lake command's task creation workflow (STEP 5 in lake.md, Step 13 in SKILL.md) to check state.json for existing tasks before creating new ones. This prevents redundant task creation when a task already exists for a file with build errors, improving workflow efficiency by avoiding duplicate tasks for the same source file.

### Research Integration

Key findings from research-001.md:
- Tasks created by /lake include a `source` field with the full file path
- Project names follow pattern `fix_build_errors_{basename}` for matching
- jq query patterns identified for checking existing tasks by source or project name
- Edge cases clarified: completed tasks in archive should not block new task creation

## Goals & Non-Goals

**Goals**:
- Prevent creation of duplicate tasks for files that already have active tasks
- Provide clear feedback when files are skipped due to existing tasks
- Maintain existing task creation behavior for files without existing tasks

**Non-Goals**:
- Modifying archived/completed task handling (those are in archive, not active_projects)
- Adding new state.json fields
- Changing the structure of created tasks

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| jq query performance on large state.json | Low | Low | Query runs per-file, short-circuit on first match |
| False positive matches on project_name | Medium | Low | Use exact source match as primary, project_name as secondary |
| Edge case: different files with same basename | Medium | Medium | Exact source path matching takes priority |

## Implementation Phases

### Phase 1: Add Redundancy Check to SKILL.md [NOT STARTED]

**Goal**: Add the jq query and skip logic to Step 13C in the detailed SKILL.md implementation.

**Tasks**:
- [ ] Insert redundancy check step before task creation in Step 13C
- [ ] Add jq query pattern checking source and project_name fields
- [ ] Add skip tracking array for files with existing tasks
- [ ] Update 13F final report to include skipped files section

**Timing**: 45 minutes

**Files to modify**:
- `.claude/skills/skill-lake-repair/SKILL.md` - Add redundancy check in Step 13

**Specific changes**:

1. Between 13B (User Confirmation) and 13C (Error Report Format), insert new section:

```markdown
#### 13B': Check for Existing Tasks

For each file in `file_groups`, check if an active task already exists:

\`\`\`bash
# Extract basename for project_name matching
base_name=$(basename "$file" .lean | tr '[:upper:]' '[:lower:]')

# Query state.json for existing task
existing_task=$(jq -r --arg source "$file" --arg basename "$base_name" '
  .active_projects[] |
  select(
    (.source == $source) or
    (.project_name | contains("fix_build_errors_" + $basename))
  ) |
  .project_number' specs/state.json | head -1)

if [ -n "$existing_task" ]; then
  echo "Skipping $file - existing task #$existing_task"
  skipped_files+=("$file:$existing_task")
  continue
fi
\`\`\`

**Skip tracking**:
- `skipped_files[]` - Array of "file:task_number" pairs for files with existing tasks
- Files in this array are excluded from task creation
```

2. Update 13F (Final Report) to include skipped files:

```markdown
#### 13F: Final Report

After all tasks processed:

\`\`\`
Tasks Created
=============

{If skipped_files not empty:}
Files skipped (existing tasks):
- {file}: Task #{task_num}

{If created_tasks not empty:}
Created {len(created_tasks)} tasks for unfixable build errors:
- Task #{task_num}: Fix build errors in {basename} ({error_count} errors)

{If no tasks created and no files skipped:}
No tasks created.

Run /implement {task_num} to work on each task.
Or fix manually and run /lake again.
\`\`\`
```

**Verification**:
- SKILL.md compiles as valid markdown
- jq query pattern is syntactically correct
- Skip logic prevents task creation for matched files

---

### Phase 2: Update lake.md High-Level Workflow [NOT STARTED]

**Goal**: Add corresponding high-level documentation to the lake.md command file.

**Tasks**:
- [ ] Add redundancy check step to STEP 5C workflow
- [ ] Update STEP 5 intro to mention duplicate prevention
- [ ] Add example output showing skipped files

**Timing**: 30 minutes

**Files to modify**:
- `.claude/commands/lake.md` - Update STEP 5 with redundancy check

**Specific changes**:

1. Update STEP 5C intro paragraph to mention redundancy check:

```markdown
#### 5C: Create Tasks and Error Reports

**EXECUTE NOW**: For each file group, check for existing tasks and create new tasks where needed.

For each `(file, errors)` in `file_groups`:

**First, check for existing task**:
\`\`\`bash
base_name=$(basename "$file" .lean | tr '[:upper:]' '[:lower:]')
existing_task=$(jq -r --arg source "$file" --arg basename "$base_name" '
  .active_projects[] |
  select((.source == $source) or (.project_name | contains("fix_build_errors_" + $basename))) |
  .project_number' specs/state.json | head -1)

if [ -n "$existing_task" ]; then
  echo "Skipping $file - existing task #$existing_task"
  skipped_files+=("$file:$existing_task")
  continue
fi
\`\`\`

**If no existing task**, proceed with task creation:
```

2. Update final report output to show skipped files:

```markdown
**After all tasks processed**:
\`\`\`
Tasks Created
=============

{If files were skipped:}
Files skipped (existing tasks):
- {file}: Task #{existing_task_number}

Created {len(created_tasks)} tasks:
{for (file, task_num) in created_tasks:}
- Task #{task_num}: Fix build errors in {basename(file)}

Run /implement {task_num} to work on each task.
\`\`\`
```

**Verification**:
- lake.md remains valid markdown
- STEP 5 flow is clear and logical
- Documentation matches SKILL.md implementation

---

### Phase 3: Verification and Testing [NOT STARTED]

**Goal**: Verify the implementation works correctly across edge cases.

**Tasks**:
- [ ] Test jq query against current state.json structure
- [ ] Verify skip message format is consistent
- [ ] Review for edge cases (same basename, different paths)

**Timing**: 15 minutes

**Verification approach**:
1. Manually verify jq query syntax with sample data
2. Confirm state.json structure matches query expectations
3. Review both files for consistency

**Test scenarios** (conceptual, for manual review):
1. File with no existing task -> should create task
2. File with exact source match in active_projects -> should skip
3. File with matching project_name pattern -> should skip
4. File with similar but different basename -> should create task (e.g., `Layer0/Basic.lean` vs `Layer1/Basic.lean`)

**Verification**:
- Both files edited correctly
- No syntax errors in markdown
- Logic is consistent between lake.md and SKILL.md

## Testing & Validation

- [ ] jq query executes without error on specs/state.json
- [ ] Skip logic correctly identifies existing tasks
- [ ] Final report format includes skipped files section
- [ ] Documentation is clear and consistent between lake.md and SKILL.md

## Artifacts & Outputs

- `.claude/commands/lake.md` - Updated with redundancy check in STEP 5
- `.claude/skills/skill-lake-repair/SKILL.md` - Updated with redundancy check in Step 13

## Rollback/Contingency

If the implementation causes issues:
1. Revert changes using git: `git checkout -- .claude/commands/lake.md .claude/skills/skill-lake-repair/SKILL.md`
2. Both files are tracked in git with clean state
3. No external dependencies modified
