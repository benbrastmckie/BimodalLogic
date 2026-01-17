# Research Summary: /todo Command Archival Feature

**Task**: 201  
**Date**: 2025-12-27  
**Status**: Research Complete

---

## Key Findings

1. **Current /todo removes but doesn't archive**: The existing `/todo` command removes completed/abandoned tasks from TODO.md and state.json but does not preserve artifacts or update archive state.

2. **Archive infrastructure exists**: `specs/archive/state.json` already has well-defined schema and 20 archived projects. Infrastructure is mature and ready for integration.

3. **Atomicity critical**: Archival must update 4 entities atomically: TODO.md, state.json, archive/state.json, and project directories. Failure in any requires rollback of all.

4. **Task numbering preserved**: Gaps in numbering are acceptable and expected after archival. MUST NOT renumber tasks.

5. **Self-healing pattern applies**: archive/state.json should be auto-created from template if missing, following existing self-healing patterns.

---

## Recommended Approach

**Option 1: In-Place Enhancement** (6 hours effort)

Extend existing `/todo` command with 3 new/enhanced stages:

- **Stage 3 (NEW)**: PrepareArchival - Check project directories, prepare archive state entries, apply self-healing
- **Stage 5 (Enhanced)**: AtomicUpdate - Expand from 2-file to 4-file atomic commit (TODO + state + archive/state + directories)
- **Stage 6 (Enhanced)**: GitCommit - Expand scope to include archive/state.json and moved directories

**Advantages**:
- Minimal disruption (builds on existing workflow)
- Single command for cleanup and archival
- Reuses confirmation and error handling logic
- Backward compatible (archival is additive)

---

## Implementation Highlights

### Two-Phase Commit for 4 Files

**Phase 1 (Prepare)**:
- Backup TODO.md, state.json, archive/state.json
- Validate all updates in memory
- Abort if any validation fails

**Phase 2 (Commit)**:
- Write TODO.md → verify
- Write state.json → verify
- Write archive/state.json → verify
- Move project directories → verify
- On ANY failure: Rollback all operations

### Self-Healing for Archive

```python
def ensure_archive_state_exists():
    if not exists("specs/archive/state.json"):
        create_from_template()
        log_to_recent_activities("Auto-created archive/state.json")
```

### Archive Entry Construction

Extract metadata from TODO.md task:
- project_number, project_name, type, status
- created, started, completed/abandoned, archived (current date)
- summary (task title)
- artifacts.base_path (archive directory path)

### Git Scope Expansion

```bash
git add TODO.md specs/state.json
git add specs/archive/state.json
git add specs/archive/  # Moved directories
git commit -m "todo: archive {N} completed/abandoned tasks"
```

---

## Edge Cases Handled

1. **No tasks to archive**: Exit early with message
2. **Task without project directory**: Skip directory move, create archive entry
3. **Missing archive/state.json**: Self-healing creates from template
4. **User declines confirmation**: Abort gracefully
5. **Directory move fails**: Rollback all operations
6. **Git commit fails**: Complete archival, log warning (non-critical)
7. **Malformed TODO.md**: Fail early with clear error
8. **state.json out of sync**: Use TODO.md as source of truth

---

## Testing Strategy

**Unit Tests**:
- Archive entry construction
- Self-healing logic
- Rollback mechanism

**Integration Tests**:
- Full archival flow (2-3 tasks)
- Partial archival (mixed with/without project directories)
- Rollback on failure
- User confirmation (accept/decline)

**Manual Tests**:
- Real TODO.md archival (1-2 tasks)
- Edge cases validation

---

## Effort Breakdown

| Component | Hours | Complexity |
|-----------|-------|------------|
| PrepareArchival (Stage 3) | 2.0 | Medium |
| AtomicUpdate (Stage 5) | 2.5 | High |
| GitCommit (Stage 6) | 0.5 | Low |
| ReturnSuccess (Stage 7) | 0.5 | Low |
| Testing | 1.0 | Medium |
| Documentation | 0.5 | Low |
| **Total** | **6.0** | **Medium-High** |

---

## Risks and Mitigation

**Risk**: Four-file atomic commit increases failure surface
**Mitigation**: Comprehensive rollback mechanism, extensive error handling

**Risk**: Directory move operations can fail (permissions, disk space)
**Mitigation**: Clear error messages with recovery instructions

**Risk**: Git conflicts with user's working directory
**Mitigation**: Git commit is non-critical; archival completes regardless

---

## Alternatives Considered

**Option 2: Separate /archive command**: Rejected - two-step process, manual invocation, duplication
**Option 3: Background archival service**: Rejected - over-engineered, complexity not justified

---

## Success Criteria

1. `/todo` archives completed/abandoned tasks to archive/
2. Project directories moved atomically
3. archive/state.json updated with task metadata
4. TODO.md and state.json cleaned up
5. Task numbering preserved with gaps
6. Self-healing for missing archive/state.json
7. User confirmation for bulk archival (>5 tasks)
8. Git commit records all changes
9. No data loss on any failure
10. Clear error messages with recovery instructions

---

## Recommendations

1. Implement Option 1 (In-Place Enhancement) - best balance
2. Use two-phase commit for atomicity
3. Apply self-healing for archive/state.json
4. Comprehensive rollback on any failure
5. Expand git scope to include archive/
6. Enhanced user feedback with archival details

**Next Step**: Create implementation plan
**Estimated Effort**: 6 hours
