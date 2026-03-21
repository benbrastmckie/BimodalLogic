# Research Report: Task #308

**Task**: Final cleanup and comprehensive testing (5/5)
**Date**: 2026-01-10
**Focus**: Codebase cleanup needs and command testing

## Summary

Research identified a critical structural issue with state.json that prevents commands from functioning correctly. The state.json file is using JSON Lines (JSONL) format instead of the expected JSON structure with `active_projects` array. This causes all jq-based lookups to fail. Additionally, there is no cruft or deprecated files to clean up - the codebase is well-organized.

## Findings

### Critical: state.json Format Mismatch

**Issue**: The file `specs/state.json` uses JSON Lines format (one JSON object per line) instead of the expected structure:

**Current format (JSONL)**:
```json
{
  "project_number": 132,
  "project_name": "prove_lindenbaum_maximal_consistency_lemma_in_completeness.lean",
  "status": "not_started",
  ...
}
{
  "project_number": 133,
  ...
}
```

**Expected format (proper JSON)**:
```json
{
  "next_project_number": 352,
  "active_projects": [
    {
      "project_number": 132,
      "project_name": "...",
      "status": "not_started",
      ...
    },
    ...
  ]
}
```

**Impact**:
- All jq commands that query `.active_projects[]` return null/errors
- Task lookup by number fails
- Status updates fail
- New task creation fails
- `/task`, `/research`, `/plan`, `/implement` commands cannot function

**Evidence**:
```bash
$ jq -r '.next_project_number' specs/state.json
null (repeated for each object in file)
```

### Command Testing Results

| Command | Expected Result | Actual Result | Status |
|---------|----------------|---------------|--------|
| `/task` | Create new task using jq | Would fail - no `next_project_number` or `active_projects` | **BLOCKED** |
| `/task --sync` | Sync state.json with TODO.md | Would fail - incompatible format | **BLOCKED** |
| `/task --recover N` | Recover from archive | Would fail - jq queries fail | **BLOCKED** |
| `/task --abandon N` | Archive task | Would fail - jq queries fail | **BLOCKED** |
| `/meta` | Interactive interview | Works - doesn't read state.json | **OK** |
| `/meta --analyze` | Analyze .claude/ structure | Works - reads files directly | **OK** |
| `/todo` | Archive completed tasks | Would fail - expects `active_projects` | **BLOCKED** |
| `/review` | Create review report | Works for basic review | **OK** |
| `/review --create-tasks` | Create tasks from review | Would fail - calls /task | **BLOCKED** |
| `/research N` | Research task | Would fail - jq lookup fails | **BLOCKED** |

### Codebase Structure Assessment

**Well-organized areas**:
- `.claude/commands/` - 9 command files, properly structured
- `.claude/skills/` - 9 skill directories with SKILL.md files
- `.claude/context/` - Comprehensive documentation hierarchy
- `.claude/rules/` - 5 rule files for specialized contexts
- `specs/` - 68 task directories with artifacts

**No cleanup needed**:
- No backup files (.bak, .old, ~)
- No orphaned directories
- No deprecated agents (task-creator already removed)
- Archive directory properly structured with valid JSON

### Archive state.json Comparison

The archive file has correct structure:
```json
{
  "_schema_version": "1.0.0",
  "archived_projects": [],
  "completed_projects": [...]
}
```

This demonstrates the expected format for the main state.json.

## Recommendations

1. **HIGH PRIORITY**: Convert state.json from JSONL to proper JSON format with:
   - Top-level `next_project_number` field (value: 352 per TODO.md frontmatter)
   - `active_projects` array containing all task objects
   - This is blocking all workflow commands

2. **Consider creating a migration script** to:
   - Read all JSON objects from current JSONL format
   - Wrap in proper structure
   - Validate against TODO.md for consistency

3. **Add schema validation** to prevent format regression

4. **No file cleanup needed** - codebase is well-organized

## References

- `specs/state.json` - Current (broken) format
- `specs/archive/state.json` - Correct format example
- `.claude/skills/skill-status-sync/SKILL.md` - Expected jq patterns
- `.claude/commands/task.md` - Command expecting proper JSON structure

## Next Steps

1. Create task for state.json format migration (requires manual intervention since /task is blocked)
2. After migration, test all commands comprehensively
3. Verify task counts match between state.json and TODO.md frontmatter
4. Run /task --sync to ensure full consistency
