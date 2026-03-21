# Research Report: Task #717

**Task**: Enhance /lake to create tasks for unfixable errors
**Date**: 2026-01-28
**Focus**: Research patterns for creating tasks from build errors, error report artifact formats, and integration with existing /task creation workflow

## Summary

The `/lake` command can be enhanced to automatically create tasks for unfixable build errors by following existing patterns from `/task`, `/errors`, and `/meta`. The key design decisions are: group errors by file (one task per affected file), prompt user for confirmation before creating tasks, and link an error report artifact to each task. The implementation requires changes to both `lake.md` (add STEP 5) and `skill-lake-repair/SKILL.md` (add error report generation).

## Findings

### Existing Task Creation Patterns

**Pattern 1: `/task` Command (task.md:38-113)**
- Creates task by updating `state.json` via jq and `TODO.md` via Edit
- Uses `next_project_number` from state.json, increments it
- Creates task entry with: project_number, project_name (slug), status, language, priority, created, last_updated
- Does NOT create task directories - those are created lazily when artifacts are written

**Pattern 2: `/errors` Command (errors.md:121-129)**
- Creates fix tasks for error patterns
- Uses `/task` command to create entries: `"/task Fix: {error description} ({N} occurrences)"`
- Creates analysis reports at `specs/errors/analysis-{DATE}.md`

**Pattern 3: `/meta` Command (skill-meta/SKILL.md:104)**
- Creates task entries directly (TODO.md + state.json)
- Creates task directories as artifacts
- Links artifacts via the `artifacts` array in state.json

### Artifact Linking Pattern

From state.json task entries (e.g., task 715):
```json
{
  "artifacts": [
    {
      "path": "specs/715_fix_lake_command_execution/plans/implementation-001.md",
      "type": "plan",
      "summary": "Plan to add execution directives to /lake command"
    }
  ]
}
```

In TODO.md, artifacts are linked with markdown:
```markdown
- **Plan**: [implementation-001.md](specs/715_fix.../plans/implementation-001.md)
- **Research**: [research-001.md](specs/.../reports/research-001.md)
```

### Task 716 as Reference Example

Task 716 was manually created for build errors with this structure:
- **Source** field: `Theories/Bimodal/Boneyard/Metalogic/Soundness/SoundnessLemmas.lean`
- **Description** includes: file name, error count (7 errors), line numbers (263, 287, 288, etc.), error type (type mismatches)
- **Language**: lean (inherited from source file type)

This is exactly the pattern we want to automate.

### Proposed Error Report Format

New artifact type: `specs/{N}_{SLUG}/reports/error-report-{DATE}.md`

```markdown
# Build Error Report: Task #{N}

**Generated**: {ISO_DATE}
**Source file**: {file_path}
**Error count**: {N} errors

## Errors

### Error 1: Line {line}
**Type**: {error_type}
**Column**: {column}
**Message**:
```
{full error message}
```

### Error 2: Line {line}
...

## Context

Build output excerpt showing error context.

## Suggested Approach

{Brief analysis of error pattern and potential fix approach}
```

### User Confirmation Pattern

From `/meta` and `/task --review` patterns:
1. Collect information about what will be created
2. Present summary to user
3. Use AskUserQuestion to confirm before creating
4. Return without creating if user declines

### Integration Points

**STEP 4 Enhancement** (current reporting step):
- After reporting unfixable errors, check if any exist
- If none, stop (current behavior)
- If errors exist, **IMMEDIATELY CONTINUE** to STEP 5

**New STEP 5: Task Creation** (new):
1. Group unfixable errors by file
2. For each file with errors, prepare task proposal
3. Display summary of proposed tasks
4. Use AskUserQuestion to confirm
5. If confirmed, create tasks using /task pattern
6. Create error report artifacts
7. Link artifacts to tasks

## Recommendations

### 1. Add STEP 5 to lake.md

Add a new section after STEP 4 that handles task creation with user confirmation:
```markdown
### STEP 5: Create Tasks for Unfixable Errors (Optional)

**EXECUTE NOW**: If unfixable errors remain, offer to create tasks.

#### 5A: Group Errors by File
...
#### 5B: Confirm with User
...
#### 5C: Create Tasks and Reports
...
```

### 2. Define Error Report Artifact Format

Add new artifact type to `artifact-formats.md`:
- Location: `specs/{N}_{SLUG}/reports/error-report-{DATE}.md`
- Format: Error listing with line numbers, messages, and context

### 3. Update skill-lake-repair/SKILL.md

Add detailed steps for:
- Error grouping logic
- Error report generation
- Task creation via jq pattern

### 4. Add State Management

Track created tasks in the output so user knows what was created:
```
Created {N} task(s) for unfixable errors:
- Task #{X}: Fix build errors in {file1} (3 errors)
- Task #{Y}: Fix build errors in {file2} (2 errors)

Next: /research {X} to begin work on first task
```

## References

- `.claude/commands/task.md` - Task creation workflow (lines 38-113)
- `.claude/commands/errors.md` - Error analysis and task creation (lines 121-129)
- `.claude/skills/skill-meta/SKILL.md` - Artifact linking pattern
- `.claude/rules/artifact-formats.md` - Report format templates
- `.claude/rules/state-management.md` - state.json and TODO.md sync requirements

## Next Steps

1. Create implementation plan with phases:
   - Phase 1: Add STEP 5 to lake.md with confirmation flow
   - Phase 2: Add error report generation to skill-lake-repair/SKILL.md
   - Phase 3: Test with actual build errors
2. Run `/plan 717` to create detailed implementation plan
