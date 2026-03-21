# Research Report: Task #719

**Task**: lake_task_redundancy_check
**Date**: 2026-01-28
**Focus**: Analyze state.json structure and /lake task creation workflow to understand how to check for existing tasks before creating new ones

## Summary

The /lake command's task creation (STEP 5 in lake.md, Step 13 in SKILL.md) currently creates tasks for all files with unfixable errors without checking if tasks already exist for those files. Adding a redundancy check requires querying state.json's `active_projects` array to match existing tasks by `source` field or `project_name` containing the file basename.

## Findings

### 1. Current Task Creation Workflow

The /lake command's task creation is documented in two files:
- **lake.md** (STEP 5): High-level workflow with user confirmation
- **SKILL.md** (Step 13): Detailed implementation with jq patterns

The current flow in Step 5C/13C:
```
1. Get next task number from state.json
2. Generate slug from filename
3. Create task directory
4. Write error report
5. Update state.json with new task entry
6. Update TODO.md with new task
```

**No existing task check is performed**.

### 2. state.json Task Structure

Tasks created by /lake include these fields:
```json
{
  "project_number": 716,
  "project_name": "fix_build_errors_soundnesslemmas",
  "status": "not_started",
  "language": "lean",
  "priority": "high",
  "source": "Theories/Bimodal/Boneyard/Metalogic/Soundness/SoundnessLemmas.lean",
  "created": "2026-01-28T07:17:18Z",
  "last_updated": "2026-01-28T07:17:18Z",
  "artifacts": [...]
}
```

Key fields for matching:
- **`source`**: Full file path (exact match)
- **`project_name`**: Contains file basename in slug form (e.g., `fix_build_errors_soundnesslemmas`)

### 3. Redundancy Check Pattern

The meta-builder-agent.md shows a pattern for searching existing tasks:
```bash
jq '.active_projects[] | select(.project_name | contains("{keyword}"))' specs/state.json
```

For /lake redundancy checking, we need a more specific pattern that checks:
1. **Exact source match**: `select(.source == $file_path)`
2. **Project name contains basename**: `select(.project_name | contains($basename))`

### 4. Recommended Implementation Approach

#### 4A: Add Redundancy Check Step (Before Task Creation)

Insert between Step 5A/5B (grouping/confirmation) and Step 5C (creation):

```bash
# Check for existing tasks covering this file
existing_task=$(jq -r --arg source "$file" --arg basename "$base_name" '
  .active_projects[] |
  select(
    (.source == $source) or
    (.project_name | test("fix_.*" + ($basename | ascii_downcase)))
  ) |
  .project_number' specs/state.json | head -1)

if [ -n "$existing_task" ]; then
  echo "Skipping $file - existing task #$existing_task"
  skipped_files+=("$file:$existing_task")
  continue
fi
```

#### 4B: Modified Flow

```
For each file in file_groups:
  1. [NEW] Extract basename from file path
  2. [NEW] Query state.json for existing task matching:
     - source == file_path
     - OR project_name contains basename (case-insensitive)
  3. [NEW] If match found: record skip, continue to next file
  4. If no match: proceed with existing task creation flow
```

#### 4C: Reporting Skipped Files

After all files processed, report:
```
Files Skipped (existing tasks):
- {file}: Task #{existing_task_number}

Files with new tasks:
- {file}: Task #{new_task_number}
```

### 5. Edge Cases

| Scenario | Behavior |
|----------|----------|
| Exact source match | Skip task creation |
| Project name contains basename | Skip task creation |
| Multiple tasks match | Use first match, log all matches |
| Completed task with same source | Create new task (completed tasks are in archive, not active_projects) |
| Task with similar but different source | Create new task (e.g., `Layer0/Basic.lean` vs `Layer1/Basic.lean`) |

### 6. jq Query Pattern

Recommended query (two-step to avoid escaping issues per jq-escaping-workarounds.md):

**Step 1**: Write file path and basename to temp file
```bash
base_name=$(basename "$file" .lean | tr '[:upper:]' '[:lower:]')
echo "$file" > /tmp/lake_source.txt
echo "$base_name" > /tmp/lake_basename.txt
```

**Step 2**: Use jq with file input
```bash
existing_task=$(jq -r '
  .active_projects[] |
  select(
    (.source == $ENV.source) or
    (.project_name | contains($ENV.basename))
  ) |
  .project_number' specs/state.json)
```

Or with `--arg` (simpler):
```bash
existing_task=$(jq -r --arg source "$file" --arg basename "$base_name" '
  .active_projects[] |
  select(
    (.source == $source) or
    (.project_name | contains($basename))
  ) |
  .project_number' specs/state.json | head -1)
```

## Recommendations

### Primary Implementation Points

1. **Modify lake.md STEP 5C**: Add redundancy check before task creation loop
2. **Modify SKILL.md Step 13C**: Add detailed jq pattern and skip logic
3. **Add skip tracking**: Maintain `skipped_files` array for reporting
4. **Update final report**: Include skipped files with links to existing tasks

### Implementation Effort

- **Estimated time**: 1-2 hours
- **Files to modify**:
  - `.claude/commands/lake.md` (STEP 5)
  - `.claude/skills/skill-lake-repair/SKILL.md` (Step 13)
- **Risk**: Low - additive change, doesn't modify existing task creation logic

### Testing Scenarios

1. Run /lake with errors in file that has no existing task - should create task
2. Run /lake with errors in file that has existing active task - should skip
3. Run /lake with errors in file that has completed/archived task - should create new task
4. Run /lake with multiple files, some with existing tasks - should create some, skip others

## References

- `.claude/commands/lake.md` - STEP 5 task creation workflow
- `.claude/skills/skill-lake-repair/SKILL.md` - Step 13 detailed implementation
- `.claude/agents/meta-builder-agent.md` - Pattern for searching existing tasks (lines 391-394)
- `.claude/context/core/patterns/jq-escaping-workarounds.md` - jq escaping best practices

## Next Steps

Run `/plan 719` to create implementation plan with specific edit patterns for lake.md and SKILL.md.
