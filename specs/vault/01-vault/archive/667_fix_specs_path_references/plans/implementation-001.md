# Implementation Plan: Fix .opencode/specs Path References

- **Task**: 667 - Fix .opencode/specs path references throughout the system
- **Status**: [NOT STARTED]
- **Effort**: 4-6 hours
- **Priority**: High
- **Dependencies**: None
- **Research Inputs**: User reported task creation system is broken due to specs directory move from .opencode/specs to specs/
- **Artifacts**: 
  - plans/implementation-001.md (this file)
  - reports/research-001.md (to be created)
  - summaries/implementation-summary-20260121.md (to be created)
- **Standards**:
  - .opencode/context/core/formats/plan-format.md
  - .opencode/context/core/standards/status-markers.md
  - .opencode/context/core/standards/task-management.md
- **Type**: meta
- **Lean Intent**: false

## Overview

The task creation system is broken because the specs directory has been moved from `.opencode/specs/` to the root level `specs/`, but many parts of the system still reference the old path. This task will systematically identify and fix all references to `.opencode/specs` throughout the codebase.

## Goals & Non-Goals

**Goals**:
- Identify all files that reference `.opencode/specs` 
- Update path references to use `specs/` (root level)
- Test task creation system after fixes
- Validate that no functionality is broken

**Non-Goals**:
- Moving the specs directory back to .opencode/specs (current location is correct)
- Changing any other directory structures
- Modifying task content, only path references

## Risks & Mitigations

| Risk | Mitigation |
|------|-----------|
| Breaking existing functionality | Test each change individually |
| Missing some references | Use comprehensive grep search patterns |
| Scripts might have hardcoded paths | Test scripts after each change |
| Git history references may break | Focus on active files, not historical references |

## Implementation Phases

### Phase 1: Identify All References [NOT STARTED]
- **Goal**: Create comprehensive inventory of all .opencode/specs references
- **Tasks**:
  - [ ] Search for `.opencode/specs` patterns in all .md files
  - [ ] Search for `.opencode/specs` patterns in all .py scripts
  - [ ] Search for `.opencode/specs` patterns in shell scripts
  - [ ] Categorize references by type (scripts, agents, commands, context, docs)
  - [ ] Prioritize critical references that break functionality
- **Timing**: 1-2 hours

### Phase 2: Fix Script References [NOT STARTED]
- **Goal**: Update all Python and shell scripts to use specs/
- **Tasks**:
  - [ ] Update .opencode/scripts/validate_state_sync.py default path
  - [ ] Update .opencode/scripts/todo_cleanup.py path references  
  - [ ] Update any other script hardcoding .opencode/specs
  - [ ] Test script functionality after changes
- **Timing**: 1 hour

### Phase 3: Fix Agent and Command References [NOT STARTED]
- **Goal**: Update all agent and command files to use specs/
- **Tasks**:
  - [ ] Update .opencode/agent/subagents/planner.md path references
  - [ ] Update .opencode/agent/subagents/meta/* path references
  - [ ] Update .opencode/command/* path references
  - [ ] Test routing and task execution after changes
- **Timing**: 1-2 hours

### Phase 4: Fix Context and Documentation [NOT STARTED]
- **Goal**: Update context files and documentation
- **Tasks**:
  - [ ] Update .opencode/context/core/* path references
  - [ ] Update .opencode/docs/* path references
  - [ ] Update any README or guide references
  - [ ] Validate documentation accuracy
- **Timing**: 1 hour

### Phase 5: Validation and Testing [NOT STARTED]
- **Goal**: Verify fixes work and task creation is functional
- **Tasks**:
  - [ ] Test task creation with /meta command
  - [ ] Test task execution with /implement command
  - [ ] Verify state sync and todo updates work
  - [ ] Test archival/restore functionality
  - [ ] Run validation scripts to confirm no broken references remain
- **Timing**: 1 hour

## Testing & Validation

- [ ] All grep searches for `.opencode/specs` return only historical references
- [ ] Task creation system works end-to-end
- [ ] All scripts run without path errors
- [ ] No broken links or missing file errors
- [ ] State.json and TODO.md sync properly

## Artifacts & Outputs

- research-001.md - Comprehensive inventory of all path references
- implementation-summary-20260121.md - Summary of changes made
- Updated files with corrected path references

## Rollback/Contingency

If critical functionality breaks:
1. Use git to revert changes for specific files
2. Identify which change caused the issue
3. Test alternative approaches (e.g., symbolic links)
4. Re-apply changes more carefully
5. Update documentation to reflect any path conventions