# /task Command Flags Comparison

**Version**: 2.0  
**Date**: 2026-01-07

---

## Flag Comparison Table

| Flag | Syntax | Bulk Support | Conflict Resolution | Effort | Status |
|------|--------|--------------|---------------------|--------|--------|
| **--recover** | `--recover TASK_RANGES` | ✅ Yes (ranges/lists) | N/A | 8-10h | NOT STARTED |
| **--divide** | `--divide TASK_NUMBER [PROMPT]` | ❌ No (single task) | N/A | 8-10h | NOT STARTED |
| **--sync** | `--sync [TASK_RANGES]` | ✅ Yes (default: all) | ✅ Git blame | 10-12h | NOT STARTED |
| **--abandon** | `--abandon TASK_RANGES` | ✅ Yes (ranges/lists) | N/A | 4-6h | NOT STARTED |

---

## Detailed Comparison

### --recover Flag

**Purpose**: Unarchive tasks from archive/

**Syntax**:
```bash
/task --recover TASK_RANGES
```

**Examples**:
```bash
/task --recover 350              # Single task
/task --recover 343-345          # Range
/task --recover 337, 343-345     # List with range
```

**Bulk Support**: ✅ Yes
- Supports single tasks, ranges, and lists
- Atomic operation (all tasks recovered or none)
- Single git commit for all recoveries

**Key Features**:
- Resets status to [NOT STARTED]
- Moves directories from archive/ to specs/ (non-critical)
- Updates TODO.md, state.json, archive/state.json atomically
- Creates git commit with task count and ranges

**Effort**: 8-10 hours

---

### --divide Flag

**Purpose**: Divide existing task into subtasks with dependencies

**Syntax**:
```bash
/task --divide TASK_NUMBER [PROMPT]
```

**Examples**:
```bash
/task --divide 326                           # AI analyzes task description
/task --divide 326 "Focus on implementation phases"  # With guidance
```

**Bulk Support**: ❌ No
- Operates on single task only
- No need for bulk division in typical workflows

**Key Features**:
- Analyzes task description for natural divisions (1-5 subtasks)
- Creates subtasks with parent-child dependencies
- Updates parent task with subtask dependencies
- Includes rollback on partial failure
- Creates git commit

**Effort**: 8-10 hours

---

### --sync Flag

**Purpose**: Synchronize TODO.md and state.json with git blame conflict resolution

**Syntax**:
```bash
/task --sync [TASK_RANGES]
```

**Examples**:
```bash
/task --sync                     # Sync ALL tasks (default)
/task --sync 343-345             # Sync specific range
/task --sync 337, 343-345        # Sync list with range
```

**Bulk Support**: ✅ Yes
- Default behavior: Syncs ALL tasks when no ranges specified
- Supports single tasks, ranges, and lists
- Atomic operation (all tasks synced or none)

**Conflict Resolution**: ✅ Git blame
- Uses `git blame` to determine which version is newer
- Latest commit timestamp wins
- Logs all conflict resolutions
- Automatic (no user interaction)

**Key Features**:
- Compares TODO.md vs state.json for each task
- Identifies discrepancies in all fields
- Resolves conflicts using git history
- Updates both files atomically
- Creates git commit with conflict resolution summary

**Effort**: 10-12 hours

---

### --abandon Flag

**Purpose**: Abandon multiple tasks via ranges/lists

**Syntax**:
```bash
/task --abandon TASK_RANGES
```

**Examples**:
```bash
/task --abandon 343-345          # Range
/task --abandon 337, 343-345, 350  # List with ranges
```

**Bulk Support**: ✅ Yes
- Supports ranges and lists
- Atomic operation (all tasks abandoned or none)
- Single git commit for all abandonments

**Key Features**:
- Moves tasks to archive/
- Updates TODO.md, state.json, archive/state.json atomically
- Reuses existing archive_tasks operation
- Creates git commit

**Effort**: 4-6 hours

---

## Range Syntax Reference

All flags with bulk support use the same range syntax:

| Syntax | Example | Expands To | Description |
|--------|---------|------------|-------------|
| Single | `350` | `[350]` | Single task number |
| Range | `343-345` | `[343, 344, 345]` | Inclusive range |
| List | `337, 350` | `[337, 350]` | Comma-separated list |
| Mixed | `337, 343-345, 350` | `[337, 343, 344, 345, 350]` | List with ranges |

**Validation**:
- All task numbers must be positive integers
- Ranges must have start ≤ end
- Duplicates are automatically removed
- Results are sorted numerically

---

## Git Blame Conflict Resolution (--sync only)

### How It Works

1. **Identify Discrepancies**: Compare TODO.md vs state.json
2. **Get Timestamps**: Use `git blame` for each differing field
3. **Resolve Conflicts**: Choose version with latest commit
4. **Apply Changes**: Update both files with resolved values
5. **Log Results**: Record all conflict resolutions

### Example

**Setup**:
```
Task 343 in TODO.md:     status=[IN PROGRESS]  (committed 10:00:00)
Task 343 in state.json:  status=[RESEARCHED]   (committed 11:00:00)
```

**Execution**:
```bash
/task --sync 343
```

**Result**:
```
Both files now have: status=[RESEARCHED]
Log: "Task 343 field 'status': state.json (11:00:00) > TODO.md (10:00:00) → state.json wins"
```

### Edge Cases

| Case | Action |
|------|--------|
| Task only in TODO.md | Check git log for deletion, add to state.json if never existed |
| Task only in state.json | Check git log for deletion, add to TODO.md if never existed |
| Multiple fields differ | Resolve each field independently using git blame |
| Timestamps equal | Use state.json (tie-breaker) |
| Git blame fails | Fallback to state.json as source of truth |

---

## Effort Summary

| Phase | Description | Effort |
|-------|-------------|--------|
| Phase 1 | Architecture Update | 3-4h |
| Phase 2 | --recover (bulk) | 8-10h |
| Phase 3 | --divide (single) | 8-10h |
| Phase 4 | --sync (git blame) | 10-12h |
| Phase 5 | --abandon (bulk) | 4-6h |
| Phase 6 | Testing & Docs | 6-8h |
| **Total** | **All Phases** | **39-50h** |

---

## Implementation Priority

### High Priority (Core Functionality)
1. **Phase 1**: Architecture Update (foundation for all flags)
2. **Phase 4**: --sync with git blame (most complex, highest value)
3. **Phase 2**: --recover with bulk (high user demand)

### Medium Priority (Enhanced Functionality)
4. **Phase 3**: --divide (useful but less urgent)
5. **Phase 5**: --abandon (reuses existing code)

### Low Priority (Polish)
6. **Phase 6**: Testing & Documentation (essential but can be done last)

---

## Backward Compatibility

All new flags are **fully backward compatible** with existing syntax:

| Existing Syntax | Still Works? | Notes |
|----------------|--------------|-------|
| `/task "description"` | ✅ Yes | Normal task creation |
| `/task "description" --divide` | ✅ Yes | Inline division for new tasks |
| `/task "description" --priority high` | ✅ Yes | All existing flags work |

**No breaking changes** - all existing workflows continue to work.

---

## Success Criteria

### Functional
- ✅ All 4 flags implemented and tested
- ✅ Bulk operations work correctly
- ✅ Git blame conflict resolution works correctly
- ✅ Backward compatibility maintained

### Non-Functional
- ✅ Performance: <120s per operation
- ✅ Reliability: 100% atomic updates
- ✅ Usability: Clear error messages
- ✅ Maintainability: Follows Phase 3 patterns

---

**Plan Location**: `.opencode/specs/TASK_COMMAND_COMPREHENSIVE_ENHANCEMENT_PLAN.md`  
**Summary Location**: `.opencode/specs/TASK_COMMAND_ENHANCEMENT_SUMMARY.md`  
**Version**: 2.0  
**Last Updated**: 2026-01-07
