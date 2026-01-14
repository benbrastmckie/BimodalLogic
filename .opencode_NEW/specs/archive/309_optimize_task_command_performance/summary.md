# /task Command Performance Optimization Summary

**Date**: 2026-01-05  
**Status**: Analysis Complete  
**Recommendation**: Implement Direct Delegation Pattern

---

## Problem Statement

The `/task` command without `--divide` flag is slow (~5-10 seconds) for simple task creation. User expects fast execution since the operation is straightforward: reword prompt, allocate task number, create entries in TODO.md and state.json.

---

## Root Cause

**Unnecessary delegation layer**: task-creator subagent adds minimal value

Current flow:
```
/task → task-creator → status-sync-manager
```

task-creator only:
1. Reads `next_project_number` from state.json
2. Immediately delegates to status-sync-manager
3. Returns result

This adds 2-3 seconds of overhead with no significant benefit.

---

## Recommended Solution

**Direct Delegation Pattern**

New flow:
```
/task → status-sync-manager
```

**Benefits**:
- 40-50% faster (5-10s → 3-5s)
- Eliminates unnecessary layer
- Maintains atomic updates
- Low risk, high reward

**Implementation**: 2-3 hours
1. Update /task command Stage 4 to delegate directly to status-sync-manager
2. Update documentation
3. Test thoroughly

---

## Key Findings

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| Execution time | 5-10s | 3-5s | **40-50%** |
| Delegation layers | 3 | 2 | -33% |
| Context loading | ~2150 lines | ~1697 lines | -21% |
| Subagent invocations | 2 | 1 | -50% |

---

## Implementation Plan

### Phase 1: Direct Delegation (2-3 hours)

1. **Update /task command** (1 hour)
   - Modify Stage 4: `CreateTasks`
   - Change delegation target from `task-creator` to `status-sync-manager`
   - Pass operation: `"create_task"` with task metadata

2. **Update Documentation** (0.5 hours)
   - Mark task-creator as deprecated
   - Update architecture notes

3. **Testing** (0.5-1 hour)
   - Single task creation
   - Multiple tasks with --divide
   - Error handling
   - Atomic rollback

4. **Validation** (0.5 hours)
   - Verify TODO.md/state.json consistency
   - Measure performance improvement

### Phase 2: Remove task-creator (Optional, 1 hour)
- Archive task-creator subagent
- Update references

---

## Risk Assessment

✅ **Low Risk**
- status-sync-manager already has `create_task_flow`
- No changes to status-sync-manager needed
- Atomic updates preserved
- Easy rollback

⚠️ **Medium Risk**
- Need thorough error handling testing
- Need to verify all edge cases

❌ **High Risk**
- None identified

---

## Future Enhancements

**Batch Delegation** (4-6 hours, future)
- For `--divide` flag, batch all tasks into single status-sync-manager call
- Further reduces overhead for multi-task creation
- Estimated improvement: 60-70% for 5 tasks

---

## Files to Modify

1. `.opencode/command/task.md` - Update Stage 4 delegation
2. `.opencode/agent/subagents/task-creator.md` - Mark deprecated
3. `.opencode/context/core/system/routing-guide.md` - Update routing docs

---

## Testing Checklist

- [ ] Single task creation works
- [ ] Multiple tasks with --divide works
- [ ] All flags work (--priority, --effort, --language)
- [ ] Error handling works (invalid inputs)
- [ ] Atomic rollback works (simulate failure)
- [ ] TODO.md and state.json stay consistent
- [ ] next_project_number increments correctly
- [ ] Performance improvement measured (before/after)

---

## Success Criteria

1. ✅ Execution time reduced by 40-50%
2. ✅ All tests pass
3. ✅ No regressions in functionality
4. ✅ Documentation updated
5. ✅ User-facing behavior unchanged (except speed)

---

## Conclusion

The optimization is straightforward, low-risk, and high-reward. By eliminating the unnecessary task-creator layer, we can achieve 40-50% performance improvement with minimal code changes and no loss of functionality.

**Recommendation**: Proceed with implementation.

---

**See Also**:
- `analysis.md` - Detailed technical analysis
- `.opencode/command/task.md` - Current implementation
- `.opencode/agent/subagents/task-creator.md` - Layer to be removed
- `.opencode/agent/subagents/status-sync-manager.md` - Target for direct delegation
