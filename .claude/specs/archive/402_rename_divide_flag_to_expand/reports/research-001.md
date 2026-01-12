# Research Report: Task #402

**Task**: Rename --divide flag to --expand
**Date**: 2026-01-12
**Focus**: Identify all files requiring --divide to --expand rename

## Summary

The `--divide` flag for `/task` command should be renamed to `--expand` for consistency with the new `[EXPANDED]` status marker (task 401). This research identifies all files containing `--divide` references in the active codebase and categorizes them for implementation.

## Findings

### Files Requiring Update (8 files, 16 occurrences)

These active documentation and command files need `--divide` renamed to `--expand`:

| File | Lines | Description |
|------|-------|-------------|
| `.claude/CLAUDE.md` | 70 | Task command quick reference |
| `.claude/commands/task.md` | 4, 32, 166 | Main command definition (3 occurrences) |
| `.claude/context/core/standards/task-management.md` | 123, 153, 157, 158 | Task management documentation (4 occurrences) |
| `.claude/context/core/standards/git-integration.md` | 14 | Git workflow documentation |
| `.claude/context/core/standards/status-markers.md` | 258 | Status transition diagram |
| `.claude/context/core/standards/documentation.md` | 122 | Changelog reference |
| `.claude/context/core/orchestration/routing.md` | 219, 233, 235 | Flag routing logic (3 occurrences) |
| `.claude/context/core/orchestration/validation.md` | 161 | Flag validation logic |

### Files to Exclude (Keep --divide unchanged)

**1. /research --divide (Different Feature)**
- `.claude/context/project/processes/research-workflow.md` lines 336, 340, 369
- `.claude/context/core/orchestration/routing.md` line 215 (research-specific routing)
- This is the `/research --divide` feature for topic subdivision, not task expansion

**2. Archive Files (Historical Records)**
- All files under `.claude/specs/archive/` (189, 211, 229, 234, 325, 326, 328, 330, 332, 338, 385, etc.)
- Historical research and plans should not be modified

**3. Task Metadata (Self-Referential)**
- `.claude/specs/state.json` - Contains task 402's own description
- `.claude/specs/TODO.md` - Contains task 402's own description
- These describe the task itself, not the flag

**4. Internal Operation Names (Not Flags)**
- `.claude/context/core/orchestration/delegation.md` - Uses `divide_task` operation name and `task-divider` agent
- These are internal operation identifiers, not user-facing flags

### Detailed Changes per File

#### 1. .claude/CLAUDE.md
```
Line 70: /task --divide 326 → /task --expand 326
```

#### 2. .claude/commands/task.md
```
Line 4:   argument-hint: --divide N → --expand N
Line 32:  - `--divide N [prompt]` → - `--expand N [prompt]`
Line 166: ## Divide Mode (--divide) → ## Expand Mode (--expand)
```

#### 3. .claude/context/core/standards/task-management.md
```
Line 123: --divide → --expand
Line 153: ### Task Division (--divide) → ### Task Expansion (--expand)
Line 157: /task --divide 326 → /task --expand 326
Line 158: /task --divide 326 "Focus..." → /task --expand 326 "Focus..."
```

#### 4. .claude/context/core/standards/git-integration.md
```
Line 14: - Task division (`/task --divide`) → - Task expansion (`/task --expand`)
```

#### 5. .claude/context/core/standards/status-markers.md
```
Line 258: (/task --divide) → (/task --expand)
```

#### 6. .claude/context/core/standards/documentation.md
```
Line 122: with --divide flag → with --expand flag
```

#### 7. .claude/context/core/orchestration/routing.md
```
Line 219: | `/task` | `--divide` | → | `/task` | `--expand` |
Line 233: elif [[ "$ARGUMENTS" =~ --divide ]]; then → elif [[ "$ARGUMENTS" =~ --expand ]]; then
Line 235: args="${ARGUMENTS#*--divide }" → args="${ARGUMENTS#*--expand }"
```
**Note**: Line 215 (`/research --divide`) should NOT be changed.

#### 8. .claude/context/core/orchestration/validation.md
```
Line 161: [[ "$ARGUMENTS" =~ --divide ]] → [[ "$ARGUMENTS" =~ --expand ]]
```

## Recommendations

1. **Rename systematically**: Update all 8 files with the changes documented above
2. **Preserve /research --divide**: The research command's subdivision feature remains unchanged
3. **Don't modify archives**: Historical records in `.claude/specs/archive/` should remain as-is
4. **Verify consistency**: After changes, grep for `--divide` to ensure only research-related references remain

## References

- Task 401: Add [EXPANDED] status for parent tasks
- `.claude/context/core/standards/status-markers.md`: Status transition definitions
- `.claude/commands/task.md`: Task command implementation

## Next Steps

1. Create implementation plan with phased updates
2. Update each file per the detailed changes above
3. Verify no unintended changes to /research --divide
4. Git commit the changes
