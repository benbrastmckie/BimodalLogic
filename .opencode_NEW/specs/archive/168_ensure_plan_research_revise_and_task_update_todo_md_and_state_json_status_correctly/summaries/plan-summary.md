# Plan Summary: Ensure /plan, /research, /revise, and /task Update TODO.md and state.json Status Correctly

**Version**: 001
**Complexity**: Complex
**Estimated Effort**: 12-20 hours (1.5-2.5 days)

## Key Steps

1. **Create status-sync-manager specialist** (4-6 hours) - Design and implement new specialist for atomic multi-file updates across TODO.md, state.json, and plan files with two-phase commit, rollback, and file locking
2. **Fix state.json field naming** (1-2 hours) - Standardize on `started`/`completed` (no `_at` suffix) across all specs and state files per state-schema.md
3. **Fix /revise command postflight** (2-3 hours) - Add missing status updates, define status preservation semantics, remove conditional state updates, delegate to status-sync-manager
4. **Standardize plan file status updates** (3-4 hours) - Update /plan to mark plan header [PLANNED], update /research for atomic updates, verify /task uses status-sync-manager, migrate from batch-status-manager
5. **Testing and validation** (2-3 hours) - Create integration test plan, execute tests for all four commands, verify lazy directory creation, test error handling and rollback
6. **Documentation updates** (1-2 hours) - Update status-markers.md with multi-file sync, clarify state-schema.md field naming, create troubleshooting guide, update all command docs

## Dependencies

- **batch-status-manager.md** - Reference implementation for atomic TODO.md updates (extend to multi-file)
- **status-markers.md** - Status marker definitions and transition rules
- **state-schema.md** - State file structure (needs field naming clarification)
- **Research Report** - research-001.md identifies 5 critical gaps to address

## Success Criteria

- All four commands update TODO.md, state.json, and plan files atomically
- /revise command preserves task status and updates files correctly
- Invalid status transitions rejected with clear errors
- Partial update failures trigger rollback
- Lazy directory creation preserved throughout
- All integration tests pass
- No breaking changes to existing functionality

## Full Plan

See: `specs/168_ensure_plan_research_revise_and_task_update_todo_md_and_state_json_status_correctly/plans/implementation-001.md`
