# Implementation Plan: Improve /todo Command to Use Git Commits Instead of Backups and Fix Divider Stacking

- **Task**: 253 - Improve /todo command to use git commits instead of backups and fix divider stacking
- **Status**: [NOT STARTED]
- **Effort**: 5 hours
- **Priority**: High
- **Dependencies**: None
- **Research Inputs**: .opencode/specs/253_improve_todo_command/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**:
  - .opencode/context/common/standards/plan.md
  - .opencode/context/common/system/status-markers.md
  - .opencode/context/common/system/artifact-management.md
  - .opencode/context/common/standards/tasks.md
  - .opencode/specs/TODO.md (file format standard)
  - .opencode/context/common/system/git-commits.md (git safety standard)
- **Language**: python
- **Lean Intent**: false

## Overview

The /todo command currently creates backup files before cleanup operations and generates Python code from scratch each time, leading to fragile rollback mechanisms and divider stacking bugs (21+ instances found). This plan replaces the backup-based workflow with git commits (pre-cleanup snapshot + post-cleanup commit) and creates a dedicated, reusable Python script at `.opencode/scripts/todo_cleanup.py` that properly handles TODO.md parsing and divider placement per the TODO.md file standards. The implementation fixes divider stacking issues and provides a more robust, maintainable solution.

## Goals & Non-Goals

**Goals**:
- Create dedicated Python script at `.opencode/scripts/todo_cleanup.py` with proper TODO.md parsing
- Implement context-aware divider algorithm to fix stacking issues (no stacked `---` dividers)
- Replace backup file creation with git commits (pre-cleanup and post-cleanup)
- Update /todo command to invoke the new script and use git-based rollback
- Ensure script follows TODO.md file standards and is reusable
- Fix all 21+ instances of stacked dividers in current TODO.md

**Non-Goals**:
- Interactive mode for task selection (future enhancement)
- Archive search functionality (future enhancement)
- Undo command for reverting archival (future enhancement)
- Changes to TODO.md file format or standards
- Changes to state.json schema

## Risks & Mitigations

- **Risk**: Script bugs could corrupt TODO.md. **Mitigation**: Implement dry-run mode, comprehensive testing, git rollback on failure.
- **Risk**: Divider algorithm errors could create formatting issues. **Mitigation**: Extensive test suite with edge cases, validation mode.
- **Risk**: Git commit failures could block archival. **Mitigation**: Comprehensive git status checks before starting, clear error messages.
- **Risk**: Breaking existing /todo workflows. **Mitigation**: Maintain backward compatibility, test with existing TODO.md.
- **Risk**: Uncommitted changes could be lost. **Mitigation**: Check for dirty working tree before starting, abort if detected.

## Implementation Phases

### Phase 1: Create Dedicated Python Script Foundation [NOT STARTED]

- **Goal**: Create `.opencode/scripts/todo_cleanup.py` with core parsing and validation functions
- **Tasks**:
  - [ ] Create `.opencode/scripts/` directory if not exists
  - [ ] Create `todo_cleanup.py` with script header and imports
  - [ ] Implement `classify_line()` function to identify line types (section, task, divider, content, empty)
  - [ ] Implement `parse_todo_file()` function to parse TODO.md into structured representation
  - [ ] Implement `extract_task_block()` function to extract complete task blocks (heading + body)
  - [ ] Implement `validate_todo_format()` function to detect orphaned metadata and format issues
  - [ ] Add command-line argument parsing (--dry-run, --verbose, --validate-only, --fix-dividers, --help)
  - [ ] Add error handling classes (ValidationError, FileIOError)
  - [ ] Add exit code constants (0=success, 1=validation error, 2=file I/O error, 3=argument error)
- **Timing**: 1.5 hours

### Phase 2: Implement Divider Fixing Algorithm [NOT STARTED]

- **Goal**: Implement context-aware divider algorithm to fix stacking issues
- **Tasks**:
  - [ ] Implement `fix_divider_stacking()` function with context-aware algorithm
  - [ ] Rule 1: Skip stacked dividers (divider after divider)
  - [ ] Rule 2: Skip divider after section header (no divider between section and first task)
  - [ ] Rule 3: Ensure divider before section (if not first section)
  - [ ] Rule 4: Ensure divider before task (if not first task in section)
  - [ ] Rule 5: Skip divider before EOF (no trailing divider)
  - [ ] Add unit tests for divider algorithm (test stacked dividers, section headers, task boundaries, EOF)
  - [ ] Test with current TODO.md to verify 21+ stacked dividers are fixed
  - [ ] Implement --fix-dividers mode to run divider fixing only
- **Timing**: 1.5 hours

### Phase 3: Implement Task Archival Logic [NOT STARTED]

- **Goal**: Implement complete task archival workflow in Python script
- **Tasks**:
  - [ ] Implement `identify_tasks_to_archive()` function (scan for [COMPLETED] and [ABANDONED])
  - [ ] Implement `archive_tasks()` function to orchestrate archival workflow
  - [ ] Extract task blocks for archival candidates
  - [ ] Remove task blocks from TODO.md content
  - [ ] Apply divider fixing to cleaned content
  - [ ] Update state.json (remove archived tasks)
  - [ ] Update archive/state.json (add archived tasks)
  - [ ] Move project directories from `.opencode/specs/{number}_{slug}/` to `.opencode/specs/archive/{number}_{slug}/`
  - [ ] Handle edge cases (no project directory, no tasks to archive, all tasks completed)
  - [ ] Return ArchivalResult with counts, moved directories, errors
- **Timing**: 1.5 hours

### Phase 4: Update /todo Command and Test Integration [NOT STARTED]

- **Goal**: Update /todo command to use git commits and new script, validate end-to-end workflow
- **Tasks**:
  - [ ] Update `.opencode/command/todo.md` to add Stage 3: GitPreCommit
  - [ ] Implement git status checks (abort if dirty, merge in progress, detached HEAD)
  - [ ] Create pre-cleanup commit with message "todo: snapshot before archiving {N} tasks (task 253)"
  - [ ] Replace Stages 3-5 with Stage 4: RunCleanupScript
  - [ ] Execute `python3 .opencode/scripts/todo_cleanup.py` and capture output
  - [ ] Implement rollback on script failure: `git reset --hard HEAD~1`
  - [ ] Update Stage 6 to Stage 5: GitPostCommit with message "todo: archive {N} completed/abandoned tasks (task 253)"
  - [ ] Remove all backup file creation logic from command specification
  - [ ] Test end-to-end workflow with test TODO.md file
  - [ ] Verify pre-commit and post-commit created correctly
  - [ ] Verify rollback works on script failure
  - [ ] Verify dividers fixed in output
  - [ ] Update command documentation with new workflow
- **Timing**: 0.5 hours

## Testing & Validation

**Unit Tests** (in Phase 2):
- [ ] Test `classify_line()` with all line types
- [ ] Test `fix_divider_stacking()` with stacked dividers
- [ ] Test `fix_divider_stacking()` with section headers
- [ ] Test `fix_divider_stacking()` with task boundaries
- [ ] Test `fix_divider_stacking()` with EOF handling

**Integration Tests** (in Phase 4):
- [ ] Test complete archival workflow with test TODO.md
- [ ] Test git pre-commit creation
- [ ] Test git post-commit creation
- [ ] Test rollback on script failure
- [ ] Test dirty working tree detection
- [ ] Test merge in progress detection
- [ ] Test no tasks to archive scenario
- [ ] Test all tasks completed scenario
- [ ] Test task with no project directory

**Validation** (in Phase 4):
- [ ] Run script with --validate-only on current TODO.md
- [ ] Run script with --fix-dividers on current TODO.md
- [ ] Verify 21+ stacked dividers are fixed
- [ ] Run script with --dry-run to preview changes
- [ ] Execute /todo command on test repository
- [ ] Verify no backup files created
- [ ] Verify git commits created with correct messages
- [ ] Verify TODO.md format preserved

## Artifacts & Outputs

**Primary Artifacts**:
- `.opencode/scripts/todo_cleanup.py` - Dedicated Python script for TODO.md cleanup
- `.opencode/command/todo.md` - Updated /todo command specification

**Modified Files**:
- `.opencode/specs/TODO.md` - Fixed divider stacking (21+ instances)
- `.opencode/specs/state.json` - Updated by script during archival
- `.opencode/specs/archive/state.json` - Updated by script during archival

**Git Commits**:
- Pre-cleanup snapshot commit: "todo: snapshot before archiving {N} tasks (task 253)"
- Post-cleanup commit: "todo: archive {N} completed/abandoned tasks (task 253)"

**Documentation**:
- Script usage documentation in command specification
- Divider placement rules documented in script comments

## Rollback/Contingency

**If script implementation fails**:
- Revert to current /todo command behavior (backup-based)
- Document issues and create follow-on task for fixes

**If git integration fails**:
- Keep script implementation but retain backup files temporarily
- Create follow-on task to fix git integration

**If divider algorithm has bugs**:
- Disable --fix-dividers mode by default
- Create follow-on task to fix algorithm
- Manual divider cleanup as interim solution

**If /todo command breaks**:
- Rollback command specification to previous version
- Use git to restore TODO.md if corrupted: `git reset --hard HEAD~1`
- Fix issues and re-test before re-deploying

## Success Metrics

**Functional Requirements**:
- [PASS] Script correctly parses TODO.md format per .opencode/specs/TODO.md standards
- [PASS] Script removes complete task blocks (heading + body + metadata)
- [PASS] Script fixes divider stacking (no stacked `---` dividers with empty lines)
- [PASS] Script updates state.json and archive/state.json correctly
- [PASS] Script moves project directories to archive
- [PASS] /todo command creates pre-cleanup git commit
- [PASS] /todo command creates post-cleanup git commit
- [PASS] /todo command rolls back on script failure
- [PASS] No backup files created (.bak files removed)

**Quality Requirements**:
- [PASS] Script has comprehensive error handling (exit codes 0, 1, 2, 3)
- [PASS] Script validates TODO.md format before changes
- [PASS] Script provides clear error messages with line numbers
- [PASS] Script is reusable (no hardcoded task lists)
- [PASS] Script has dry-run mode (--dry-run)
- [PASS] Script has validation mode (--validate-only)
- [PASS] Script has divider-only mode (--fix-dividers)

**Testing Requirements**:
- [PASS] Unit tests cover all divider algorithm edge cases
- [PASS] Integration tests cover end-to-end workflow
- [PASS] All tests pass
- [PASS] Manual testing with real TODO.md successful
- [PASS] Git integration tested (pre-commit, post-commit, rollback)
