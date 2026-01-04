# Implementation Summary: Add YAML Header to TODO.md

**Task**: 272 - Add standardized YAML header to TODO.md with state.json metadata  
**Date**: 2026-01-04  
**Status**: Phase 1 Complete (Initial Header Implementation)

## What Was Implemented

Added a standardized YAML header to `.opencode/specs/TODO.md` that surfaces key metadata from `state.json` in a human-readable format. The header includes:

- Repository health metrics (overall score, production readiness)
- Task counts (active, completed, blocked, in-progress, not-started, total)
- Priority distribution (high, medium, low priority tasks)
- Technical debt metrics (sorry count, axiom count, build errors, status)
- Metadata timestamps (last_updated, last_assessed)
- Next project number for task creation

## Files Modified

1. **`.opencode/specs/TODO.md`**
   - Added YAML header between `---` delimiters
   - Header includes warning comment: "Auto-generated from state.json - do not edit manually"
   - Preserves all existing task entries below header
   - Backup created: `.opencode/specs/TODO.md.backup-20260104`

## YAML Header Format

```yaml
---
# Auto-generated from state.json - do not edit manually
last_updated: 2026-01-04T04:45:44Z
next_project_number: 280
repository_health:
  overall_score: 92
  production_readiness: excellent
  last_assessed: 2025-12-29T00:05:34Z
task_counts:
  active: 4
  completed: 50
  blocked: 2
  in_progress: 2
  not_started: 23
  total: 81
priority_distribution:
  high: 15
  medium: 12
  low: 11
technical_debt:
  sorry_count: 6
  axiom_count: 11
  build_errors: 11
  status: well-documented
---
```

## Key Decisions

1. **Field Selection**: Included high-value fields for users (health score, task counts, technical debt) while excluding verbose fields (active_projects, recent_activities)

2. **Warning Comment**: Added "Auto-generated from state.json - do not edit manually" to prevent manual edits that would be overwritten

3. **Compact Format**: Header fits in ~25 lines, minimal visual overhead

4. **Human-Readable**: YAML format chosen over JSON for better readability

## Remaining Work

This implementation completes **Phase 1** (Design and Validate YAML Header Schema) and **Phase 3** (Update TODO.md with Initial YAML Header) of the 6-phase implementation plan.

**Remaining phases**:
- **Phase 2**: Implement header regeneration in status-sync-manager (4 hours)
- **Phase 4**: Add manual refresh capability to /todo command (2 hours)
- **Phase 5**: Update context files with YAML header documentation (2 hours)
- **Phase 6**: Test header synchronization across workflow commands (2 hours)

**Total remaining effort**: ~10 hours

## Testing Recommendations

1. Verify YAML header displays correctly in markdown viewers (VS Code, GitHub)
2. Verify TODO.md parsing works with existing workflow commands
3. Test header regeneration when state.json is updated
4. Validate YAML syntax with PyYAML parser

## Next Steps

To complete the full implementation:

1. Update `status-sync-manager.md` to regenerate header on every state.json update
2. Add `--refresh-header` flag to `/todo` command for manual refresh
3. Document YAML header format in context files (tasks.md, state-management.md, artifact-management.md)
4. Test header synchronization across all workflow commands (/research, /plan, /implement, /review, /todo)

## Impact

Users can now view repository health, task counts, and technical debt directly in TODO.md without manually inspecting state.json. The header provides at-a-glance visibility into project status.

**Note**: Header is currently static and will not auto-update until Phase 2 (status-sync-manager integration) is completed.
