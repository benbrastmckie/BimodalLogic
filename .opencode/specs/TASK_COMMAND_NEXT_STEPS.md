# /task Command Enhancement - Next Steps

**Created**: 2026-01-07  
**Status**: Architecture Complete, Implementation Pending

---

## Current Status

### ✅ Completed Work

1. **Phase 1: Architecture** (Commit: dabfe6d)
   - task.md refactored to Phase 3 standards
   - Flag-based routing implemented
   - 8 stages with validation gates
   - Backward compatible

2. **Phase 6: Context Documentation** (Commit: c796817)
   - routing.md updated with flag patterns
   - delegation.md updated with bulk operations
   - validation.md updated with validation gates
   - task-management.md updated with usage standards

3. **Implementation Notes** (Commit: cdd6764)
   - Comprehensive guide for remaining phases
   - Code examples for all patterns
   - Testing checklists

### 🔧 Ready for Implementation

The architecture is complete and documented. The remaining work is implementing the operations in status-sync-manager.md:

- **unarchive_tasks**: Recover tasks from archive/state.json
- **sync_tasks**: Synchronize TODO.md ↔ state.json with git blame
- **Enhanced archive_tasks**: Support archive/state.json (currently uses completed_projects)
- **update_task_metadata**: Update task dependencies (may already exist)

---

## Immediate Next Steps

### Option 1: Implement Operations in status-sync-manager.md

**Effort**: 30-40 hours  
**Approach**: Add the four operations to status-sync-manager.md following the patterns in TASK_COMMAND_IMPLEMENTATION_NOTES.md

**Steps**:
1. Add unarchive_tasks_flow (8-10 hours)
2. Add sync_tasks_flow with git blame (10-12 hours)
3. Enhance archive_tasks_flow for archive/state.json (4-6 hours)
4. Verify/add update_task_metadata_flow (2-4 hours)
5. Integration testing (6-8 hours)

**Files to modify**:
- `.opencode/agent/subagents/status-sync-manager.md`

### Option 2: Incremental Implementation

**Effort**: 4-6 hours per operation  
**Approach**: Implement one operation at a time, test, commit, repeat

**Recommended Order**:
1. **update_task_metadata** (if missing) - Needed for --divide
2. **archive_tasks enhancement** - Foundation for --abandon and --recover
3. **unarchive_tasks** - Enables --recover
4. **sync_tasks** - Most complex, do last

**Benefits**:
- Incremental progress
- Each operation can be tested independently
- Easier to debug issues
- Can pause/resume between operations

### Option 3: Create Separate Subagents

**Effort**: 20-30 hours  
**Approach**: Create specialized subagents instead of adding to status-sync-manager

**New Subagents**:
- `task-recovery-manager.md` - Handles unarchive_tasks
- `task-sync-manager.md` - Handles sync_tasks with git blame
- Keep status-sync-manager for basic operations

**Benefits**:
- Separation of concerns
- Smaller, focused agents
- Easier to maintain
- Follows Phase 3 philosophy

**Drawbacks**:
- More files to manage
- Need to update routing
- More delegation overhead

---

## Recommended Approach

**Hybrid: Option 2 (Incremental) + Simplified Scope**

Instead of implementing all operations immediately, implement a minimal viable version:

### Minimal Viable Implementation (12-16 hours)

1. **Phase 5: --abandon** (4 hours)
   - Enhance archive_tasks to support archive/state.json
   - Add "reason" parameter
   - Test with single task, range, list

2. **Phase 2: --recover** (6-8 hours)
   - Add unarchive_tasks operation
   - Support single task, range, list
   - Reset status to NOT STARTED
   - Test recovery workflow

3. **Phase 3: --divide** (4-6 hours)
   - Verify update_task_metadata exists
   - Add if missing
   - Test task division with rollback

4. **Phase 4: --sync** (Defer to v2)
   - Most complex operation
   - Git blame conflict resolution is advanced feature
   - Can be added later without breaking existing functionality

5. **Phase 7: Testing** (2-4 hours)
   - Test --abandon, --recover, --divide
   - Verify backward compatibility
   - Document known limitations

### Benefits of Minimal Viable Approach

- **Delivers value quickly**: 3 of 4 flags working
- **Manageable scope**: 12-16 hours vs 36-46 hours
- **Testable increments**: Each phase can be verified
- **Defer complexity**: Git blame sync can be v2 feature
- **Maintains quality**: Full testing for implemented features

---

## Implementation Checklist

### Before Starting

- [ ] Review TASK_COMMAND_IMPLEMENTATION_NOTES.md
- [ ] Understand atomic two-phase commit pattern
- [ ] Understand range parsing logic
- [ ] Set up test environment with archived tasks

### During Implementation

- [ ] Follow code examples in implementation notes
- [ ] Test each operation individually
- [ ] Verify atomic updates (all or nothing)
- [ ] Check git commits are created
- [ ] Validate error handling
- [ ] Test rollback mechanisms

### After Implementation

- [ ] Run full test suite
- [ ] Verify backward compatibility
- [ ] Update documentation
- [ ] Create migration guide
- [ ] Mark phases as COMPLETED in plan

---

## Testing Strategy

### Unit Tests (Per Operation)

For each operation, test:
- Single task
- Range (e.g., 343-345)
- List (e.g., 337, 343-345, 350)
- Error cases (task not found, invalid range, etc.)
- Atomic updates (verify all files updated or none)
- Git commits created

### Integration Tests

- Test flag combinations (should error)
- Test backward compatibility (existing /task syntax)
- Test with real archived tasks
- Test rollback on failure
- Test performance (should complete within 120s)

### Manual Verification

```bash
# Test --abandon
/task --abandon 343-345
# Verify: Tasks in archive/state.json, removed from TODO.md and state.json

# Test --recover
/task --recover 343-345
# Verify: Tasks in TODO.md and state.json, removed from archive/state.json

# Test --divide
/task --divide 326
# Verify: Subtasks created, parent has dependencies

# Test backward compatibility
/task "New task description"
# Verify: Task created normally
```

---

## Risk Mitigation

### Risk: Breaking Existing Functionality

**Mitigation**:
- Test backward compatibility after each change
- Keep git commits small and focused
- Can revert individual commits if needed

### Risk: Incomplete Implementation

**Mitigation**:
- Implement incrementally (one operation at a time)
- Each operation is independently useful
- Document what's implemented vs planned

### Risk: Time Overrun

**Mitigation**:
- Use minimal viable approach (defer --sync to v2)
- Set time boxes for each operation
- Stop and document if time box exceeded

### Risk: Data Corruption

**Mitigation**:
- Use atomic two-phase commit for all operations
- Test with non-critical tasks first
- Keep git history for rollback
- Validate all updates before committing

---

## Success Criteria

### Minimal Viable Success (v1.0)

- [ ] --abandon works (single, range, list)
- [ ] --recover works (single, range, list)
- [ ] --divide works (single task)
- [ ] Backward compatibility maintained
- [ ] All operations use atomic updates
- [ ] Git commits created for all operations
- [ ] Error handling works
- [ ] Documentation updated

### Full Success (v2.0)

- [ ] All v1.0 criteria met
- [ ] --sync works with git blame conflict resolution
- [ ] Performance optimized
- [ ] Comprehensive test suite
- [ ] Migration guide created
- [ ] All phases marked COMPLETED

---

## Timeline Estimate

### Minimal Viable (v1.0)

- **Week 1**: Phase 5 (--abandon) - 4 hours
- **Week 2**: Phase 2 (--recover) - 6-8 hours
- **Week 3**: Phase 3 (--divide) - 4-6 hours
- **Week 4**: Phase 7 (Testing) - 2-4 hours
- **Total**: 16-22 hours over 4 weeks

### Full Implementation (v2.0)

- **Week 5-6**: Phase 4 (--sync) - 10-12 hours
- **Week 7**: Additional testing - 4-6 hours
- **Total**: 30-40 hours over 7 weeks

---

## Conclusion

The /task command enhancement is architecturally complete and well-documented. The remaining work is implementing the operations in status-sync-manager.md.

**Recommended path forward**:
1. Start with minimal viable implementation (v1.0)
2. Implement --abandon, --recover, --divide incrementally
3. Defer --sync to v2.0
4. Test thoroughly at each step
5. Document what's implemented vs planned

This approach delivers value quickly while maintaining quality and allowing for future enhancement.

---

**Next Action**: Choose implementation approach and begin with Phase 5 (--abandon)

**Reference Documents**:
- Implementation details: `.opencode/specs/TASK_COMMAND_IMPLEMENTATION_NOTES.md`
- Full plan: `.opencode/specs/TASK_COMMAND_COMPREHENSIVE_ENHANCEMENT_PLAN.md`
- Architecture: `.opencode/command/task.md`
- Context: `.opencode/context/core/orchestration/*.md`
