# Implementation Plan: Systematically Fix TODO.md Path References

## Metadata

- **Task Number**: 232
- **Task Title**: Systematically fix TODO.md path references and migrate tasks from project root to .opencode/specs
- **Plan Version**: 1
- **Status**: [NOT STARTED]
- **Created**: 2025-12-29
- **Estimated Effort**: 11 hours
- **Language**: markdown
- **Priority**: High
- **Complexity**: Medium

## Research Inputs

**Research Report**: `.opencode/specs/232_systematically_fix_todomd_path_references/reports/research-001.md`

**Key Findings**:
1. All 150+ references use relative path `TODO.md` without `.opencode/specs/` prefix
2. No files use absolute root path (good), but all paths are context-dependent (bad)
3. Two TODO.md files exist: root (1101 lines) and canonical (837 lines)
4. 40 unique Logos project tasks in root TODO.md need migration
5. Critical risk: Bash commands and file I/O operations fail if working directory changes
6. Files affected: 9 command files (91 refs), 6 subagent files (33 refs), 5 context files (30 refs)

**Critical References Identified**:
- Language extraction bash commands in research.md, implement.md, command-lifecycle.md
- File I/O operations in status-sync-manager.md and atomic-task-numberer.md
- Task creation and status update workflows across all commands

## Overview

### Problem Statement

The OpenCode system has two TODO.md files in different locations, causing confusion and potential data corruption. All commands, agents, and context files use relative path `TODO.md` without the `.opencode/specs/` prefix, making them context-dependent. If working directory changes, file operations will fail or corrupt the wrong file. Additionally, 40 unique Logos project tasks exist in the root TODO.md that need migration to the canonical location.

### Scope

**In Scope**:
- Fix all relative `TODO.md` references to use `.opencode/specs/TODO.md` in 9 command files
- Fix all relative `TODO.md` references in 6 subagent files
- Fix all relative `TODO.md` references in 5 context files
- Migrate 40 unique Logos project tasks from root TODO.md to canonical TODO.md
- Validate migration integrity (no duplicates, valid cross-references)
- Remove root TODO.md after successful migration
- Test all workflow commands with corrected paths

**Out of Scope**:
- Changing TODO.md file format or structure
- Modifying task tracking workflow beyond path corrections
- Refactoring command or agent logic beyond path references

### Constraints

- Must preserve all task data during migration (no data loss)
- Must maintain task number uniqueness (no conflicts)
- Must preserve completion timestamps and artifact links
- Must update cross-references (dependencies, blocking tasks)
- Cannot break existing workflow commands during migration
- Must follow lazy directory creation (no premature directory creation)

### Definition of Done

- All 150+ relative `TODO.md` references changed to `.opencode/specs/TODO.md`
- All 40 unique Logos tasks migrated to canonical TODO.md
- No duplicate task numbers in canonical TODO.md
- All cross-references (dependencies, blocking) updated and valid
- Root TODO.md removed from project root
- All workflow commands tested and working with corrected paths
- Static analysis confirms zero relative `TODO.md` references remain
- Integration tests pass (task creation, status updates, language extraction)

## Goals and Non-Goals

### Goals

1. Eliminate context-dependent path resolution by using explicit `.opencode/specs/TODO.md` paths
2. Consolidate all task tracking in single canonical TODO.md file
3. Preserve all unique Logos project tasks through careful migration
4. Ensure atomic status updates always target correct TODO.md file
5. Fix critical language extraction bash commands to prevent routing failures
6. Validate migration integrity with comprehensive testing

### Non-Goals

1. Refactoring TODO.md file format or structure
2. Changing task tracking workflow or status markers
3. Modifying command or agent logic beyond path corrections
4. Creating new task management features
5. Optimizing TODO.md file size or organization

## Risks and Mitigations

### Risk 1: Data Loss During Migration

**Probability**: Medium  
**Impact**: Critical  
**Mitigation**:
- Create backup of root TODO.md before migration
- Use deduplication analysis to identify conflicts before migration
- Validate all 40 tasks migrated before removing root TODO.md
- Test task creation after migration to verify next_project_number correct

### Risk 2: Task Number Conflicts

**Probability**: Low  
**Impact**: High  
**Mitigation**:
- Inventory all task numbers in both files before migration
- Identify duplicates and resolve using most recent version
- Validate no duplicate task numbers after migration
- Test atomic-task-numberer reads correct next_project_number

### Risk 3: Breaking Workflow Commands

**Probability**: Medium  
**Impact**: High  
**Mitigation**:
- Fix critical bash commands first (language extraction)
- Fix file I/O operations second (status updates, task numbering)
- Test each workflow command after path corrections
- Rollback plan: Restore root TODO.md if commands fail

### Risk 4: Invalid Cross-References

**Probability**: Medium  
**Impact**: Medium  
**Mitigation**:
- Scan all dependency and blocking references after migration
- Update references to migrated tasks
- Validate all referenced task numbers exist
- Document any orphaned references for manual review

### Risk 5: Working Directory Assumptions

**Probability**: Low  
**Impact**: Medium  
**Mitigation**:
- Test commands from different working directories
- Verify all paths resolve to `.opencode/specs/TODO.md`
- Add validation that TODO.md exists before file operations
- Document working directory requirements if any remain

## Implementation Phases

### Phase 1: Critical Path Fixes - Bash Commands and File I/O [COMPLETED]

- **Completed**: 2025-12-29
**Effort**: 2 hours

**Objective**: Fix critical bash commands (language extraction) and file I/O operations (status updates, task numbering) to prevent immediate failures.

**Tasks**:
1. Fix bash commands in research.md line 135 (language extraction)
2. Fix bash commands in implement.md line 164 (language extraction)
3. Fix bash commands in command-lifecycle.md line 92 (language extraction)
4. Fix file I/O in status-sync-manager.md lines 81, 96, 100, 136, 197, 223 (status updates)
5. Fix file I/O in atomic-task-numberer.md lines 43, 89, 139, 169, 182 (task numbering)
6. Test language extraction: `/research 232` should route to correct agent
7. Test status updates: Create test task, verify status updated in canonical TODO.md
8. Test task numbering: Create new task, verify next_project_number correct

**Acceptance Criteria**:
- All bash commands use `.opencode/specs/TODO.md`
- All file I/O operations use `.opencode/specs/TODO.md`
- Language extraction works correctly (routes to lean-research-agent for Lean tasks)
- Status updates write to canonical TODO.md only
- Task numbering reads from canonical TODO.md only
- No errors when executing commands from project root

**Validation**:
- Grep for bash commands: `grep -r "grep.*TODO\.md" .opencode/command .opencode/context`
- Verify zero results with relative paths
- Test `/research` on Lean task, verify correct agent routing
- Test `/task` creation, verify task appears in canonical TODO.md

### Phase 2: Command File Fixes [COMPLETED]

- **Completed**: 2025-12-29
**Effort**: 3 hours

**Objective**: Fix all 91 relative `TODO.md` references in 9 command files to use `.opencode/specs/TODO.md`.

**Tasks**:
1. Fix research.md (8 references) - lines 62, 71, 100-101, 114, 121, 133-135, 202, 298
2. Fix plan.md (8 references) - all relative `TODO.md` to `.opencode/specs/TODO.md`
3. Fix implement.md (11 references) - lines 66, 84, 113-114, 131, 149, 162-164, 171, 272, 298-301, 379, 391
4. Fix revise.md (7 references) - all relative `TODO.md` to `.opencode/specs/TODO.md`
5. Fix task.md (15 references) - all relative `TODO.md` to `.opencode/specs/TODO.md`
6. Fix todo.md (27 references) - all relative `TODO.md` to `.opencode/specs/TODO.md`
7. Fix review.md (11 references) - all relative `TODO.md` to `.opencode/specs/TODO.md`
8. Fix errors.md (4 references) - all relative `TODO.md` to `.opencode/specs/TODO.md`
9. Test each command: /research, /plan, /implement, /revise, /task, /todo, /review, /errors

**Acceptance Criteria**:
- All 91 references in command files use `.opencode/specs/TODO.md`
- No relative `TODO.md` references remain in command files
- All workflow commands execute successfully
- Error messages reference correct TODO.md path
- Documentation strings reference correct TODO.md path

**Validation**:
- Static analysis: `grep -r "TODO\.md" .opencode/command --include="*.md" | grep -v "\.opencode/specs/TODO\.md"`
- Expected: Zero results
- Test each command with real task numbers
- Verify all commands read/write canonical TODO.md

### Phase 3: Subagent File Fixes [COMPLETED]

- **Completed**: 2025-12-29
**Effort**: 1 hour

**Objective**: Fix all 33 relative `TODO.md` references in 6 subagent files to use `.opencode/specs/TODO.md`.

**Tasks**:
1. Fix planner.md (5 references) - lines 56, 292, and others
2. Fix reviewer.md (2 references) - all relative `TODO.md` to `.opencode/specs/TODO.md`
3. Fix implementer.md (2 references) - all relative `TODO.md` to `.opencode/specs/TODO.md`
4. Fix lean-implementation-agent.md (1 reference) - relative `TODO.md` to `.opencode/specs/TODO.md`
5. Fix git-workflow-manager.md (1 reference) - relative `TODO.md` to `.opencode/specs/TODO.md`
6. Fix error-diagnostics-agent.md (1 reference) - relative `TODO.md` to `.opencode/specs/TODO.md`
7. Test subagent delegation: Verify planner reads task from canonical TODO.md

**Acceptance Criteria**:
- All 33 references in subagent files use `.opencode/specs/TODO.md`
- No relative `TODO.md` references remain in subagent files
- Subagents read task data from canonical TODO.md
- Planner creates plans with correct task references
- Reviewer creates review tasks in canonical TODO.md

**Validation**:
- Static analysis: `grep -r "TODO\.md" .opencode/agent/subagents --include="*.md" | grep -v "\.opencode/specs/TODO\.md"`
- Expected: Zero results
- Test `/plan` command, verify planner reads from canonical TODO.md
- Test `/review` command, verify reviewer creates task in canonical TODO.md

### Phase 4: Context File Fixes [COMPLETED]

- **Completed**: 2025-12-29
**Effort**: 1 hour

**Objective**: Fix all 30 relative `TODO.md` references in 5 context files to use `.opencode/specs/TODO.md`.

**Tasks**:
1. Fix command-lifecycle.md (24 references) - lines 53, 62, 66, 74, 82, 92, 205-560
2. Fix review.md workflow (2 references) - all relative `TODO.md` to `.opencode/specs/TODO.md`
3. Fix documentation.md (references) - all relative `TODO.md` to `.opencode/specs/TODO.md`
4. Fix commands.md (references) - all relative `TODO.md` to `.opencode/specs/TODO.md`
5. Fix command-argument-handling.md (references) - all relative `TODO.md` to `.opencode/specs/TODO.md`
6. Verify context files loaded correctly by commands

**Acceptance Criteria**:
- All 30 references in context files use `.opencode/specs/TODO.md`
- No relative `TODO.md` references remain in context files
- Documentation references correct TODO.md location
- Workflow descriptions reference correct TODO.md path
- Command lifecycle documentation accurate

**Validation**:
- Static analysis: `grep -r "TODO\.md" .opencode/context --include="*.md" | grep -v "\.opencode/specs/TODO\.md"`
- Expected: Zero results
- Review command-lifecycle.md for accuracy
- Verify workflow descriptions match actual behavior

### Phase 5: Task Migration from Root TODO.md [COMPLETED]

- **Completed**: 2025-12-29
**Effort**: 3 hours

**Objective**: Migrate 40 unique Logos project tasks from root TODO.md to canonical TODO.md without creating duplicates.

**Tasks**:
1. Create backup of root TODO.md: `cp TODO.md TODO.md.backup`
2. Inventory unique tasks: Extract task numbers from root TODO.md not in canonical TODO.md
3. Deduplication analysis: Identify tasks in both files, resolve using most recent version
4. Migrate Logos Core Development tasks (15 tasks): Tasks 1, 2, 8, 9, 126, 132-141
5. Migrate Logos Build Fixes tasks (7 tasks): Tasks 183-185, 209, 213, 218-219
6. Migrate Logos Documentation tasks (6 tasks): Tasks 172, 177, 186-188
7. Migrate Logos Testing tasks (1 task): Task 174
8. Migrate Logos Automation tasks (2 tasks): Tasks 3-4
9. Migrate Logos Infrastructure tasks (7 tasks): Tasks 175-180, 189
10. Migrate OpenCode System tasks (8 tasks): Tasks 148, 190, 205, 208, 210-211, 220, 222, 224
11. Update cross-references: Fix dependency and blocking references to migrated tasks
12. Validate migration: Verify all 40 tasks migrated, no duplicates, all cross-references valid

**Acceptance Criteria**:
- Backup of root TODO.md created
- All 40 unique Logos tasks migrated to canonical TODO.md
- No duplicate task numbers in canonical TODO.md
- All cross-references (dependencies, blocking) updated and valid
- All completion timestamps preserved
- All artifact links preserved and working
- Task categories maintained (High/Medium/Low priority)
- Completion history preserved

**Validation**:
- Count tasks in canonical TODO.md before and after migration
- Verify 40 tasks added
- Check for duplicate task numbers: `grep "^### [0-9]" .opencode/specs/TODO.md | sort | uniq -d`
- Expected: Zero duplicates
- Validate all artifact links: Check each link resolves to existing file
- Test task creation: Verify next_project_number correct after migration

### Phase 6: Root TODO.md Removal and Final Validation [COMPLETED]

- **Completed**: 2025-12-29
**Effort**: 1 hour

**Objective**: Remove root TODO.md after validating migration success and test all workflow commands.

**Tasks**:
1. Final validation: Verify all 40 tasks migrated, no duplicates, all cross-references valid
2. Test task creation: `/task "Test task after migration"` - verify appears in canonical TODO.md
3. Test research workflow: `/research 232` - verify reads from canonical TODO.md
4. Test plan workflow: `/plan 232` - verify reads from canonical TODO.md
5. Test implement workflow: Create test task, implement, verify status updated in canonical TODO.md
6. Test from different working directories: Execute commands from root, .opencode/, .opencode/command/
7. Remove root TODO.md: `rm /home/benjamin/Projects/ProofChecker/TODO.md`
8. Final static analysis: Verify zero relative `TODO.md` references remain
9. Integration test: Full workflow (create task → research → plan → implement)
10. Document migration in MAINTENANCE.md or similar

**Acceptance Criteria**:
- All 40 tasks verified migrated
- No duplicate task numbers
- All cross-references valid
- All workflow commands tested and working
- Commands work from different working directories
- Root TODO.md removed
- Zero relative `TODO.md` references remain in .opencode system
- Integration test passes (full workflow)
- Migration documented

**Validation**:
- Static analysis: `grep -r "TODO\.md" .opencode --include="*.md" | grep -v "\.opencode/specs/TODO\.md"`
- Expected: Zero results
- Verify root TODO.md removed: `ls -la /home/benjamin/Projects/ProofChecker/TODO.md`
- Expected: File not found
- Verify canonical TODO.md exists: `ls -la /home/benjamin/Projects/ProofChecker/.opencode/specs/TODO.md`
- Expected: File exists
- Test full workflow: Create task → research → plan → implement
- Expected: All artifacts created, all statuses updated, no errors

## Testing and Validation

### Unit Testing

**Test 1: Path Resolution**
- Execute commands from different working directories (root, .opencode/, .opencode/command/)
- Expected: All commands resolve to `.opencode/specs/TODO.md`
- Coverage: All 9 command files

**Test 2: Language Extraction**
- Create Lean task, run `/research {task_number}`
- Expected: Bash command extracts "lean" from `.opencode/specs/TODO.md`, routes to lean-research-agent
- Coverage: research.md, implement.md, command-lifecycle.md

**Test 3: Status Updates**
- Create test task, run `/research`, `/plan`, `/implement`
- Expected: Status markers updated in `.opencode/specs/TODO.md` only
- Coverage: status-sync-manager.md

**Test 4: Task Numbering**
- Create new task with `/task`
- Expected: Task number read from `.opencode/specs/TODO.md`, new task added to canonical TODO.md
- Coverage: atomic-task-numberer.md, task.md

### Integration Testing

**Test 5: Full Workflow**
- Create task → research → plan → implement
- Expected: All artifacts created, all statuses updated in canonical TODO.md, no errors
- Coverage: All workflow commands

**Test 6: Migration Integrity**
- Count tasks before and after migration
- Expected: 40 tasks added, no duplicates, all cross-references valid
- Coverage: Migration process

**Test 7: Cross-References**
- Check all dependency and blocking references
- Expected: All referenced task numbers exist in canonical TODO.md
- Coverage: Migrated tasks

### Regression Testing

**Test 8: Existing Workflows**
- Run existing tasks through research/plan/implement workflows
- Expected: No changes in behavior, all workflows work correctly
- Coverage: All workflow commands

**Test 9: Error Handling**
- Test with invalid task numbers
- Expected: Error messages reference `.opencode/specs/TODO.md`
- Coverage: All command error handling

### Static Analysis

**Test 10: Path Reference Audit**
- Command: `grep -r "TODO\.md" .opencode --include="*.md" | grep -v "\.opencode/specs/TODO\.md"`
- Expected: Zero results
- Coverage: All .opencode files

**Test 11: Duplicate Task Numbers**
- Command: `grep "^### [0-9]" .opencode/specs/TODO.md | sort | uniq -d`
- Expected: Zero duplicates
- Coverage: Canonical TODO.md

**Test 12: Artifact Links**
- Check all artifact links in migrated tasks
- Expected: All links resolve to existing files
- Coverage: Migrated tasks

## Artifacts and Outputs

### Primary Artifacts

1. **Updated Command Files** (9 files)
   - `.opencode/command/research.md`
   - `.opencode/command/plan.md`
   - `.opencode/command/implement.md`
   - `.opencode/command/revise.md`
   - `.opencode/command/task.md`
   - `.opencode/command/todo.md`
   - `.opencode/command/review.md`
   - `.opencode/command/errors.md`

2. **Updated Subagent Files** (6 files)
   - `.opencode/agent/subagents/status-sync-manager.md`
   - `.opencode/agent/subagents/atomic-task-numberer.md`
   - `.opencode/agent/subagents/planner.md`
   - `.opencode/agent/subagents/reviewer.md`
   - `.opencode/agent/subagents/implementer.md`
   - `.opencode/agent/subagents/lean-implementation-agent.md`
   - `.opencode/agent/subagents/git-workflow-manager.md`
   - `.opencode/agent/subagents/error-diagnostics-agent.md`

3. **Updated Context Files** (5 files)
   - `.opencode/context/common/workflows/command-lifecycle.md`
   - `.opencode/context/common/workflows/review.md`
   - `.opencode/context/common/standards/documentation.md`
   - `.opencode/context/common/standards/commands.md`
   - `.opencode/context/common/standards/command-argument-handling.md`

4. **Canonical TODO.md** (updated)
   - `.opencode/specs/TODO.md` (with 40 migrated tasks)

5. **Root TODO.md Backup** (created then removed)
   - `/home/benjamin/Projects/ProofChecker/TODO.md.backup` (preserved for safety)

### Supporting Artifacts

6. **Implementation Summary**
   - `.opencode/specs/232_systematically_fix_todomd_path_references/summaries/implementation-summary-{date}.md`
   - Documents all changes, migration results, validation outcomes

7. **Migration Report**
   - Included in implementation summary
   - Lists all 40 migrated tasks with before/after status
   - Documents any conflicts resolved
   - Lists all cross-reference updates

### Validation Artifacts

8. **Static Analysis Results**
   - Output of grep commands showing zero relative references
   - Duplicate task number check results
   - Artifact link validation results

9. **Test Results**
   - Path resolution test results
   - Language extraction test results
   - Status update test results
   - Task numbering test results
   - Full workflow test results
   - Migration integrity test results

## Rollback/Contingency

### Rollback Triggers

1. **Data Loss Detected**: Any unique tasks missing after migration
2. **Duplicate Task Numbers**: Task number conflicts that cannot be resolved
3. **Workflow Failures**: Any workflow command fails after path corrections
4. **Invalid Cross-References**: Orphaned dependency or blocking references
5. **Test Failures**: Any integration test fails after migration

### Rollback Procedure

**Step 1: Restore Root TODO.md**
```bash
cp /home/benjamin/Projects/ProofChecker/TODO.md.backup /home/benjamin/Projects/ProofChecker/TODO.md
```

**Step 2: Revert Path Changes**
- Use git to revert all path corrections in command, subagent, and context files
- Command: `git checkout HEAD -- .opencode/command/ .opencode/agent/subagents/ .opencode/context/`

**Step 3: Revert Canonical TODO.md**
- Use git to revert canonical TODO.md to pre-migration state
- Command: `git checkout HEAD -- .opencode/specs/TODO.md`

**Step 4: Verify Rollback**
- Test task creation: `/task "Test rollback"`
- Test workflow commands: `/research`, `/plan`, `/implement`
- Verify all commands work with original paths

**Step 5: Document Rollback Reason**
- Create rollback report documenting what failed
- Identify root cause of failure
- Plan corrective actions before retry

### Contingency Plans

**Contingency 1: Partial Migration**
- If full migration fails, migrate tasks in smaller batches
- Migrate by category (Core Development, Build Fixes, etc.)
- Validate each batch before proceeding

**Contingency 2: Manual Cross-Reference Updates**
- If automated cross-reference updates fail, update manually
- Create list of all dependency and blocking references
- Verify each reference manually

**Contingency 3: Gradual Path Corrections**
- If mass path corrections cause issues, fix files incrementally
- Fix critical files first (status-sync-manager, atomic-task-numberer)
- Test after each file corrected
- Proceed only if tests pass

**Contingency 4: Keep Root TODO.md Temporarily**
- If migration validation fails, keep root TODO.md temporarily
- Fix validation issues
- Retry migration
- Remove root TODO.md only after full validation success

### Recovery Time Objective

- **Rollback Time**: 15 minutes (restore backups, revert git changes)
- **Retry Time**: 2 hours (analyze failure, implement fixes, retry migration)
- **Maximum Downtime**: 30 minutes (time when workflow commands may be broken)

## Dependencies

### Internal Dependencies

- **Task 231**: Fix systematic command Stage 7 (Postflight) execution failures
  - Status: [RESEARCHED]
  - Impact: Ensures status-sync-manager properly invoked after path corrections
  - Blocker: No (can proceed independently)

### External Dependencies

- None

### Blocking Tasks

- None (this task can proceed immediately)

## Notes

### Implementation Strategy

This plan follows a risk-based approach, fixing critical paths first (bash commands, file I/O) before addressing less critical references (documentation, error messages). Migration is performed after all path corrections to ensure migrated tasks are immediately tracked in the correct location.

### Key Success Factors

1. **Comprehensive Testing**: Test each phase before proceeding to next
2. **Backup Strategy**: Create backups before migration, preserve for rollback
3. **Incremental Validation**: Validate after each phase, not just at end
4. **Clear Rollback Plan**: Document rollback procedure, test rollback capability

### Lessons from Research

Research identified that all references use relative paths (context-dependent) rather than explicitly wrong paths. This means the fix is straightforward (add `.opencode/specs/` prefix) but requires comprehensive coverage to prevent any references from being missed.

### Post-Implementation

After successful implementation:
1. Document canonical TODO.md location in MAINTENANCE.md
2. Add validation to commands to check TODO.md exists at canonical location
3. Consider adding pre-commit hook to prevent relative `TODO.md` references
4. Update onboarding documentation to clarify TODO.md location
