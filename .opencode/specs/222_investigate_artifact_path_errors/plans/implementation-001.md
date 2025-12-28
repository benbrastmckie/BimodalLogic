# Implementation Plan: Fix Artifact Path Creation Errors

## Metadata

- **Task**: 222
- **Status**: [NOT STARTED]
- **Estimated Effort**: 3 hours
- **Language**: markdown
- **Priority**: High
- **Created**: 2025-12-28
- **Session**: sess_1735431930_a7b2c9
- **Research Integrated**: Yes (research-001.md)

## Overview

### Problem Statement

Artifacts are being created in `/specs/` instead of `/.opencode/specs/` for Lean research tasks. Research identified the root cause as a single incorrect path pattern in lean-research-agent.md line 497 missing the `.opencode/` prefix. This affects 3 confirmed projects (tasks 213, 215, 218) that used lean-research-agent.

### Scope

This implementation will:
- Fix the incorrect path pattern in lean-research-agent.md
- Migrate 3 existing misplaced project directories to correct location
- Update artifact references in TODO.md and state.json
- Verify all other subagents use correct path patterns
- Clean up empty /specs/ directory

### Constraints

- Must maintain backward compatibility for existing artifact links
- Must update TODO.md and state.json atomically to avoid broken references
- Must verify no other path pattern issues exist in codebase
- Must not break any existing workflows or commands

### Definition of Done

- lean-research-agent.md uses correct `.opencode/specs/` path pattern
- All 3 misplaced projects migrated to `.opencode/specs/`
- TODO.md artifact links updated and verified working
- state.json artifact paths updated
- Empty /specs/ directory removed
- All subagents verified to use correct path patterns
- Test Lean research task creates artifacts in correct location

## Goals and Non-Goals

### Goals

- Fix root cause in lean-research-agent.md line 497
- Migrate existing misplaced artifacts to correct location
- Update all references to migrated artifacts
- Verify fix with test Lean research task
- Document path pattern standard

### Non-Goals

- Changing path patterns in other subagents (already correct)
- Modifying artifact-management.md standards (already correct)
- Creating automated linting for path patterns (future enhancement)
- Migrating non-artifact files from /specs/

## Risks and Mitigations

### Risk 1: Broken Artifact Links After Migration
- **Likelihood**: Medium
- **Impact**: High
- **Mitigation**: Update TODO.md and state.json in same commit as migration
- **Contingency**: Keep backup of original /specs/ until verification complete

### Risk 2: Additional Path Pattern Issues
- **Likelihood**: Low (research verified all other subagents)
- **Impact**: Medium
- **Mitigation**: Comprehensive grep for path patterns before declaring complete
- **Contingency**: Extend scope if additional issues found

### Risk 3: State File Corruption
- **Likelihood**: Low
- **Impact**: High
- **Mitigation**: Validate JSON syntax after updates
- **Contingency**: Git revert if state.json becomes invalid

## Implementation Phases

### Phase 1: Fix lean-research-agent.md Path Pattern
**Estimated Effort**: 0.5 hours
**Status**: [COMPLETED]

**Objectives**:
- Update line 497 in lean-research-agent.md with correct path
- Verify no other incorrect path patterns in file
- Commit fix with clear message

**Tasks**:
1. Read lean-research-agent.md to locate line 497
2. Replace `"path": "specs/{task_number}_{topic}/reports/research-001.md"` with `"path": ".opencode/specs/{task_number}_{topic}/reports/research-001.md"`
3. Search entire file for any other instances of `specs/` without `.opencode/` prefix
4. Verify fix matches pattern used by other subagents
5. Commit change with message: "Fix lean-research-agent path pattern to use .opencode/specs/"

**Acceptance Criteria**:
- Line 497 contains `.opencode/specs/` path pattern
- No other incorrect path patterns in lean-research-agent.md
- File syntax valid (no markdown errors)
- Commit created with clear message

**Dependencies**: None

### Phase 2: Migrate Project 213 (Test Migration)
**Estimated Effort**: 0.5 hours
**Status**: [NOT STARTED]

**Objectives**:
- Migrate first project as test case
- Verify migration process works correctly
- Update references for single project

**Tasks**:
1. Create target directory: `.opencode/specs/213_resolve_is_valid_swap_involution_blocker/`
2. Move `/specs/213_resolve_is_valid_swap_involution_blocker/` to `.opencode/specs/`
3. Update TODO.md artifact links for task 213 (lines 356-359)
4. Verify TODO.md links work correctly
5. Test that artifact files are accessible at new location

**Acceptance Criteria**:
- Project 213 directory exists at `.opencode/specs/213_resolve_is_valid_swap_involution_blocker/`
- All artifacts preserved (research-001.md, research-summary.md, implementation-001.md, implementation-002.md)
- TODO.md links for task 213 point to `.opencode/specs/` location
- Links verified working (files accessible)

**Dependencies**: Phase 1 (fix should be committed before migration)

### Phase 3: Migrate Projects 215 and 218
**Estimated Effort**: 0.5 hours
**Status**: [NOT STARTED]

**Objectives**:
- Complete migration of remaining 2 projects
- Update all TODO.md references
- Verify consistency across all migrations

**Tasks**:
1. Move `/specs/215_fix_todo_command_task_block_removal/` to `.opencode/specs/`
2. Move `/specs/218_fix_lean_lsp_mcp_integration_and_opencode_module_import_errors/` to `.opencode/specs/`
3. Update TODO.md artifact links for task 215 (line 215)
4. Update TODO.md artifact links for task 218 (lines 465, 468)
5. Verify all TODO.md links work correctly
6. Verify all artifacts preserved in migrations

**Acceptance Criteria**:
- Projects 215 and 218 exist at `.opencode/specs/` location
- All artifacts preserved for both projects
- TODO.md links updated for tasks 215 and 218
- All links verified working

**Dependencies**: Phase 2 (test migration successful)

### Phase 4: Update state.json References
**Estimated Effort**: 0.5 hours
**Status**: [NOT STARTED]

**Objectives**:
- Update artifact paths in state.json
- Validate JSON syntax
- Verify state consistency

**Tasks**:
1. Read `.opencode/specs/state.json`
2. Search for artifact paths containing `specs/213`, `specs/215`, `specs/218`
3. Update paths to use `.opencode/specs/` prefix
4. Validate JSON syntax with `jq` or Python
5. Verify state.json structure intact
6. Commit state.json update

**Acceptance Criteria**:
- All artifact paths in state.json use `.opencode/specs/` prefix
- JSON syntax valid (verified with parser)
- No broken references in state.json
- State file structure preserved

**Dependencies**: Phase 3 (all migrations complete)

### Phase 5: Cleanup and Verification
**Estimated Effort**: 0.5 hours
**Status**: [NOT STARTED]

**Objectives**:
- Remove empty /specs/ directory
- Verify no broken links remain
- Comprehensive path pattern audit

**Tasks**:
1. Verify `/specs/` directory is empty
2. Remove `/specs/` directory
3. Grep entire codebase for `specs/` patterns without `.opencode/` prefix
4. Verify all subagents use correct `.opencode/specs/` pattern
5. Check for any remaining references to old paths
6. Document any findings

**Acceptance Criteria**:
- `/specs/` directory removed
- No broken artifact links in TODO.md
- No broken paths in state.json
- All subagents verified using correct path pattern
- No unexpected path pattern issues found

**Dependencies**: Phase 4 (state.json updated)

### Phase 6: Integration Test and Documentation
**Estimated Effort**: 0.5 hours
**Status**: [NOT STARTED]

**Objectives**:
- Verify fix works with real Lean research task
- Document path pattern standard
- Create completion summary

**Tasks**:
1. Create test Lean research task (or use existing task)
2. Run `/research {test_task_number}` command
3. Verify artifact created in `.opencode/specs/` location
4. Verify return path includes `.opencode/` prefix
5. Document path pattern standard in artifact-management.md
6. Create implementation summary
7. Update TODO.md to mark task 222 as COMPLETED

**Acceptance Criteria**:
- Test research task creates artifacts in `.opencode/specs/`
- Artifact paths in return format include `.opencode/` prefix
- Path pattern standard documented
- Implementation summary created
- Task 222 marked COMPLETED in TODO.md

**Dependencies**: Phase 5 (cleanup complete)

## Testing and Validation

### Unit Tests
- Verify lean-research-agent.md line 497 has correct path pattern
- Verify all 3 project directories exist at `.opencode/specs/` location
- Verify all artifact files preserved in migrations

### Integration Tests
- Run `/research` command on Lean task
- Verify artifact created in `.opencode/specs/`
- Verify TODO.md links work correctly
- Verify state.json paths valid

### Validation Checks
- JSON syntax validation for state.json
- Markdown link validation for TODO.md
- Directory existence checks for migrated projects
- Path pattern grep across all subagents

## Artifacts and Outputs

### Modified Files
- `.opencode/agent/subagents/lean-research-agent.md` (line 497 fix)
- `.opencode/specs/TODO.md` (artifact link updates for tasks 213, 215, 218)
- `.opencode/specs/state.json` (artifact path updates)
- `Documentation/Reference/artifact-management.md` (path pattern documentation)

### Migrated Directories
- `.opencode/specs/213_resolve_is_valid_swap_involution_blocker/` (from /specs/)
- `.opencode/specs/215_fix_todo_command_task_block_removal/` (from /specs/)
- `.opencode/specs/218_fix_lean_lsp_mcp_integration_and_opencode_module_import_errors/` (from /specs/)

### Removed Directories
- `/specs/` (empty directory cleanup)

### New Artifacts
- `.opencode/specs/222_investigate_artifact_path_errors/summaries/implementation-summary-20251228.md`

## Rollback/Contingency

### Rollback Plan
If migration causes issues:
1. Git revert commits in reverse order (Phase 6 → Phase 1)
2. Restore /specs/ directory from backup
3. Restore original TODO.md and state.json
4. Investigate root cause of failure
5. Revise plan and retry

### Backup Strategy
- Keep /specs/ directory until Phase 6 verification complete
- Create git commits for each phase for granular rollback
- Backup state.json before modifications
- Document original artifact paths for reference

### Validation Gates
- Phase 2: Verify test migration successful before proceeding to Phase 3
- Phase 4: Validate state.json syntax before committing
- Phase 6: Verify test research task successful before marking complete

## Notes

### Research Findings Integration
- Research definitively identified lean-research-agent.md line 497 as sole root cause
- All other subagents (6/7) verified using correct `.opencode/specs/` pattern
- All workflow commands verified using correct path patterns
- Impact limited to 3 Lean research tasks (213, 215, 218)

### Path Pattern Standard
Correct pattern: `.opencode/specs/{task_number}_{slug}/`
Incorrect pattern: `specs/{task_number}_{slug}/`

All subagents must use `.opencode/` prefix for artifact paths.

### Future Enhancements
- Add linter rule to detect path patterns without `.opencode/` prefix
- Add pre-commit hook for path pattern validation
- Document path pattern standard in artifact-management.md
- Consider automated migration script for future path issues
