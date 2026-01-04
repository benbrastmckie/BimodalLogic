# Implementation Plan: Clean up context directory structure by migrating common/ to core/ and removing archive/

- **Task**: 265 - Clean up context directory structure by migrating common/ to core/ and removing archive/
- **Status**: [COMPLETED]
- **Effort**: 10 hours
- **Priority**: High
- **Dependencies**: None
- **Research Inputs**: reports/research-001.md (comprehensive file inventory, reference analysis, content conflict resolution)
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**:
  - @.opencode/context/core/standards/plan.md
  - @.opencode/context/core/system/status-markers.md
  - @.opencode/context/core/system/artifact-management.md
  - @.opencode/context/core/standards/tasks.md
- **Language**: markdown
- **Lean Intent**: false

## Overview

This plan systematically migrates all content from `.opencode/context/common/` to `.opencode/context/core/`, removes the deprecated `.opencode/context/archive/` directory, resolves content duplication, and updates 120 file references throughout the codebase. Research shows zero references in active commands/agents, making this a zero-risk migration for active workflows. The migration follows a 4-phase strategy: archive removal, content conflict resolution, common directory migration, and reference updates with validation.

## Goals & Non-Goals

**Goals:**
- Remove all files from `.opencode/context/archive/` (2 deprecated files)
- Migrate all active content from `.opencode/context/common/` to `.opencode/context/core/` (24 files)
- Resolve 3 content conflicts (subagent-return-format.md, delegation-patterns.md, command-lifecycle.md)
- Update all 120 references from `@.opencode/context/common/` to `@.opencode/context/core/`
- Remove empty `common/` and `archive/` directories
- Update context index to reflect new structure
- Maintain zero breaking changes to active workflows

**Non-Goals:**
- Modifying content of migrated files (except for merges)
- Changing directory structure beyond common/ and archive/ removal
- Creating new context files
- Updating project-specific context (project/ directory)

## Risks & Mitigations

**Risk:** Broken references after migration causing context loading failures  
**Mitigation:** Update all references before moving files; validate after each phase; use git commits for rollback points

**Risk:** Content loss during file merges  
**Mitigation:** Manual review of all merges; preserve unique content from both sources; validate merged files before deletion

**Risk:** Commands fail after migration due to missing context  
**Mitigation:** Test all workflow commands after migration; verify context loading works; check for broken references

**Risk:** Git history loss for migrated files  
**Mitigation:** Use `git mv` for file moves to preserve history; document migration in commit messages

**Risk:** Incomplete reference updates leaving orphaned links  
**Mitigation:** Use automated search/replace with validation; check for remaining common/ references after updates

## Implementation Phases

### Phase 1: Archive Directory Removal [COMPLETED]

**Goal:** Remove deprecated archive/ directory and update references

**Tasks:**
- [ ] Verify zero references to `@.opencode/context/archive/` in active files
- [ ] Search for any references to archive/ files in codebase
- [ ] Remove `archive/command-lifecycle.md` (1,138 lines, deprecated)
- [ ] Remove `archive/delegation-patterns.md` (725 lines, deprecated redirect)
- [ ] Remove `archive/` directory
- [ ] Validate directory removed successfully
- [ ] Create git commit: "task 265: remove deprecated archive/ directory"

**Timing:** 30 minutes

**Acceptance Criteria:**
- [ ] `.opencode/context/archive/` directory does not exist
- [ ] No broken references to archive/ files
- [ ] Git commit created with clear message

### Phase 2: Content Conflict Resolution [COMPLETED]

**Goal:** Resolve duplicate files between common/ and core/ before migration

**Tasks:**
- [ ] **Conflict 1: subagent-return-format.md**
  - [ ] Verify common/ version is deprecated redirect (27 lines)
  - [ ] Verify core/ version is authoritative (212 lines)
  - [ ] Delete `core/standards/subagent-return-format.md`
  - [ ] Keep `core/standards/subagent-return-format.md`
- [ ] **Conflict 2: delegation-patterns.md**
  - [ ] Read `core/workflows/delegation-patterns.md` (726 lines)
  - [ ] Read `core/standards/delegation.md` (510 lines)
  - [ ] Verify common/ is deprecated redirect
  - [ ] Delete `core/workflows/delegation-patterns.md`
  - [ ] Keep `core/standards/delegation.md`
- [ ] **Conflict 3: command-lifecycle.md**
  - [ ] Verify file already removed in Phase 1 (was in archive/)
  - [ ] No action needed
- [ ] **Merge 1: git-commits.md → git-safety.md**
  - [ ] Read `core/system/git-commits.md` (34 lines)
  - [ ] Read `core/standards/git-safety.md` (536 lines)
  - [ ] Identify unique content in git-commits.md
  - [ ] Merge unique commit patterns into git-safety.md
  - [ ] Validate merged content complete
  - [ ] Delete `core/system/git-commits.md`
- [ ] **Merge 2: context-guide.md → context-loading-strategy.md**
  - [ ] Read `core/system/context-guide.md` (89 lines)
  - [ ] Read `core/system/context-loading-strategy.md` (102 lines)
  - [ ] Identify unique patterns in context-guide.md
  - [ ] Merge unique patterns into context-loading-strategy.md
  - [ ] Validate merged content complete
  - [ ] Delete `core/system/context-guide.md`
- [ ] **Merge 3: commands.md → command-structure.md**
  - [ ] Read `core/standards/commands.md` (70 lines)
  - [ ] Read `core/standards/command-structure.md` (612 lines)
  - [ ] Verify commands.md is redundant (covered by command-structure.md)
  - [ ] Delete `core/standards/commands.md` if redundant
- [ ] **Rename: delegation.md → delegation-context-template.md**
  - [ ] Read `core/workflows/delegation.md` (82 lines)
  - [ ] Verify different purpose than core/standards/delegation.md
  - [ ] Move to `core/templates/delegation-context-template.md`
  - [ ] Preserve as separate template
- [ ] Validate all conflicts resolved
- [ ] Create git commit: "task 265: resolve content conflicts and merge duplicates"

**Timing:** 2 hours

**Acceptance Criteria:**
- [ ] All 3 content conflicts resolved
- [ ] All 3 merges completed with unique content preserved
- [ ] Merged files validated for completeness
- [ ] Git commit created documenting resolutions

### Phase 3: Common Directory Migration [COMPLETED]

**Goal:** Migrate all active files from common/ to core/ preserving structure

**Tasks:**
- [ ] Create target directories in core/ (if not exist):
  - [ ] `core/standards/`
  - [ ] `core/system/`
  - [ ] `core/workflows/`
  - [ ] `core/templates/`
  - [ ] `core/schemas/`
- [ ] **Migrate Standards Files (9 files):**
  - [ ] Move `core/standards/analysis.md` → `core/standards/`
  - [ ] Move `core/standards/code.md` → `core/standards/`
  - [ ] Move `core/standards/command-argument-handling.md` → `core/standards/`
  - [ ] Move `core/standards/documentation.md` → `core/standards/`
  - [ ] Move `core/standards/frontmatter-standard.md` → `core/standards/`
  - [ ] Move `core/standards/patterns.md` → `core/standards/`
  - [ ] Move `core/standards/plan.md` → `core/standards/`
  - [ ] Move `core/standards/report.md` → `core/standards/`
  - [ ] Move `core/standards/summary.md` → `core/standards/`
  - [ ] Move `core/standards/tasks.md` → `core/standards/`
  - [ ] Move `core/standards/tests.md` → `core/standards/`
- [ ] **Migrate System Files (2 files):**
  - [ ] Move `core/system/artifact-management.md` → `core/system/`
  - [ ] Move `core/system/self-healing-guide.md` → `core/system/`
- [ ] **Migrate Workflow Files (3 files):**
  - [ ] Move `core/workflows/review.md` → `core/workflows/`
  - [ ] Move `core/workflows/sessions.md` → `core/workflows/`
  - [ ] Move `core/workflows/task-breakdown.md` → `core/workflows/`
- [ ] **Migrate Template Files (5 files):**
  - [ ] Move `core/templates/meta-guide.md` → `core/templates/`
  - [ ] Move `core/templates/orchestrator-template.md` → `core/templates/`
  - [ ] Move `core/templates/subagent-template.md` → `core/templates/`
  - [ ] Move `core/templates/state-template.json` → `core/templates/`
  - [ ] Move `core/templates/subagent-frontmatter-template.yaml` → `core/templates/`
  - [ ] Delete `core/templates/command-template.md` (core/ version is newer)
- [ ] **Migrate Schema Files (1 file):**
  - [ ] Move `common/schemas/frontmatter-schema.json` → `core/schemas/`
- [ ] **Remove Deprecated Redirect Files (5 files):**
  - [ ] Delete `core/standards/subagent-return-format.md` (deprecated redirect)
  - [ ] Delete `core/system/status-markers.md` (deprecated redirect)
  - [ ] Delete `core/system/state-schema.md` (deprecated redirect)
  - [ ] Delete `core/workflows/subagent-delegation-guide.md` (deprecated redirect)
  - [ ] Delete `core/workflows/delegation-patterns.md` (deprecated redirect)
- [ ] Verify all active files migrated (24 files total)
- [ ] Verify all deprecated files deleted (8 files total)
- [ ] Remove empty common/ subdirectories
- [ ] Remove empty common/ directory
- [ ] Create git commit: "task 265: migrate common/ to core/ and remove deprecated files"

**Timing:** 2 hours

**Acceptance Criteria:**
- [ ] All 24 active files migrated to core/
- [ ] All 8 deprecated/redundant files deleted
- [ ] `.opencode/context/common/` directory does not exist
- [ ] File structure preserved in core/
- [ ] Git commit created with file moves

### Phase 4: Reference Updates and Validation [COMPLETED]

**Goal:** Update all 120 references and validate migration success

**Tasks:**
- [ ] **Update Deprecated Redirect References (63 refs):**
  - [ ] Update `status-markers.md` references (19 refs) → `core/system/state-management.md`
  - [ ] Update `subagent-return-format.md` references (16 refs) → `core/standards/delegation.md`
  - [ ] Update `subagent-delegation-guide.md` references (13 refs) → `core/standards/delegation.md`
  - [ ] Remove `command-lifecycle.md` references (18 refs) - deprecated, no replacement
  - [ ] Validate deprecated references updated
- [ ] **Update Active File References (57 refs):**
  - [ ] Update `git-commits.md` refs (15) → `core/standards/git-safety.md`
  - [ ] Update `artifact-management.md` refs (3) → `core/system/artifact-management.md`
  - [ ] Update `review.md` refs (3) → `core/workflows/review.md`
  - [ ] Update `tasks.md` refs (1) → `core/standards/tasks.md`
  - [ ] Update `plan.md` refs (1) → `core/standards/plan.md`
  - [ ] Update `summary.md` refs (1) → `core/standards/summary.md`
  - [ ] Update `patterns.md` refs (1) → `core/standards/patterns.md`
  - [ ] Update `context-guide.md` refs (1) → `core/system/context-loading-strategy.md`
  - [ ] Update `command-template.md` refs (4) → `core/templates/command-template.md`
  - [ ] Update remaining active file refs (27) → corresponding core/ paths
  - [ ] Validate active references updated
- [ ] **Update Context Index:**
  - [ ] Remove all references to common/ from `.opencode/context/index.md`
  - [ ] Add new core/ file entries to index
  - [ ] Update navigation section
  - [ ] Update consolidation summary
  - [ ] Validate index structure
- [ ] **Validate References:**
  - [ ] Search for remaining `@.opencode/context/common/` references
  - [ ] Search for remaining `@.opencode/context/archive/` references
  - [ ] Verify all core/ references point to existing files
  - [ ] Run reference validation script
  - [ ] Fix any broken references found
- [ ] **Test Workflow Commands:**
  - [ ] Test /research command
  - [ ] Test /plan command
  - [ ] Test /implement command
  - [ ] Test /revise command
  - [ ] Test /review command
  - [ ] Test /task command
  - [ ] Test /todo command
  - [ ] Verify all commands execute successfully
- [ ] **Validate Context Loading:**
  - [ ] Verify orchestrator loads routing context
  - [ ] Verify agents load execution context
  - [ ] Check lazy-loading works correctly
  - [ ] Monitor context window usage
- [ ] **Final Validation:**
  - [ ] Verify directory structure correct (only core/ and project/)
  - [ ] Verify no files in common/ or archive/
  - [ ] Verify all 120 references updated
  - [ ] Verify no broken references
  - [ ] Run validation scripts
  - [ ] Check git status clean
- [ ] Create git commit: "task 265: update all references to core/ paths"

**Timing:** 4 hours

**Acceptance Criteria:**
- [ ] All 120 references updated to core/ paths
- [ ] Zero references to common/ or archive/ remain
- [ ] All core/ references point to existing files
- [ ] All workflow commands tested and working
- [ ] Context loading validated
- [ ] Git commit created

### Phase 5: Documentation and Cleanup [COMPLETED]

**Goal:** Update documentation and finalize migration

**Tasks:**
- [ ] Update `.opencode/SYSTEM_IMPROVEMENT_PLAN.md` references
- [ ] Update `.opencode/PHASE_5_SUMMARY.md` references
- [ ] Update any migration documentation
- [ ] Verify context index final state
- [ ] Run final validation checks
- [ ] Document migration in task notes
- [ ] Create final git commit: "task 265: update documentation for context migration"
- [ ] Update task status to [COMPLETED]

**Timing:** 1.5 hours

**Acceptance Criteria:**
- [ ] All documentation updated
- [ ] Context index reflects final structure
- [ ] Migration documented
- [ ] Task marked [COMPLETED]
- [ ] Final git commit created

## Testing & Validation

**Per-Phase Validation:**
- [ ] Phase 1: Verify archive/ directory removed, no broken references
- [ ] Phase 2: Verify all conflicts resolved, merged content complete
- [ ] Phase 3: Verify all files migrated, common/ directory removed
- [ ] Phase 4: Verify all references updated, all commands working
- [ ] Phase 5: Verify documentation updated, final state correct

**Reference Validation:**
- [ ] Run automated search for `@.opencode/context/common/` (expect 0 results)
- [ ] Run automated search for `@.opencode/context/archive/` (expect 0 results)
- [ ] Verify all `@.opencode/context/core/` references point to existing files
- [ ] Check for broken links in context index

**Command Testing:**
- [ ] Execute each workflow command (/research, /plan, /implement, /revise, /review, /task, /todo)
- [ ] Verify context loads correctly for each command
- [ ] Check for errors in command execution
- [ ] Validate output artifacts created correctly

**Directory Structure Validation:**
- [ ] Verify `.opencode/context/archive/` does not exist
- [ ] Verify `.opencode/context/common/` does not exist
- [ ] Verify `.opencode/context/core/` contains all migrated files
- [ ] Verify core/ subdirectories: standards/, system/, workflows/, templates/, schemas/
- [ ] Verify file counts match expected (24 migrated + existing core/ files)

**Content Validation:**
- [ ] Verify merged files contain unique content from both sources
- [ ] Verify no content loss during migration
- [ ] Verify file permissions preserved
- [ ] Verify git history preserved for moved files

## Artifacts & Outputs

**Plan Artifacts:**
- `plans/implementation-001.md` (this file)

**Migration Artifacts:**
- 24 files migrated from common/ to core/
- 2 files merged (git-commits.md, context-guide.md)
- 10 files deleted (2 archive/, 8 common/ deprecated/redundant)
- 120 references updated across 17 files
- Updated `.opencode/context/index.md`

**Git Commits:**
1. "task 265: remove deprecated archive/ directory"
2. "task 265: resolve content conflicts and merge duplicates"
3. "task 265: migrate common/ to core/ and remove deprecated files"
4. "task 265: update all references to core/ paths"
5. "task 265: update documentation for context migration"

**Validation Outputs:**
- Reference validation results (0 common/, 0 archive/ references)
- Command test results (all passing)
- Directory structure verification (correct)

## Rollback/Contingency

**Rollback Triggers:**
- Critical command failure after migration
- Context loading failure preventing workflow execution
- Data loss detected in merged files
- Broken references in active workflows causing failures

**Rollback Procedure:**

1. **Identify Failure Point:**
   - Determine which phase failed
   - Identify specific git commit before failure
   - Document failure reason and error messages

2. **Restore from Git:**
   ```bash
   # Identify last good commit
   git log --oneline
   
   # Rollback to last good commit
   git reset --hard <commit-hash>
   
   # Verify rollback successful
   git status
   ```

3. **Partial Rollback (if needed):**
   ```bash
   # Rollback specific file
   git checkout <commit-hash> -- <file-path>
   
   # Verify file restored
   git diff <file-path>
   ```

4. **Analyze and Fix:**
   - Review error logs and identify root cause
   - Determine fix for specific issue
   - Test fix in isolation
   - Re-attempt migration with fix applied

**Rollback Prevention:**
- Git commit after each phase for clear rollback points
- Validate thoroughly after each phase before proceeding
- Manual review of all file merges before deletion
- Test all commands before final cleanup
- Keep deprecated files until validation complete

**Contingency for Specific Failures:**

- **Broken References:** Restore reference updates from git, fix specific broken references, re-run validation
- **Lost Content in Merge:** Restore original files, re-merge manually with careful review, validate merged content
- **Command Failures:** Restore context files from git, identify missing context, re-migrate with corrections
- **Context Loading Failures:** Restore context index and files, verify lazy-loading configuration, re-test loading

## Success Metrics

**Completion Criteria:**
- [ ] Zero files in `.opencode/context/archive/`
- [ ] Zero files in `.opencode/context/common/`
- [ ] All 24 active files migrated to `.opencode/context/core/`
- [ ] All 120 references updated to core/ paths
- [ ] Zero broken context references
- [ ] Context index updated and accurate
- [ ] All workflow commands tested and working
- [ ] Directory structure simplified (only core/ and project/)
- [ ] Git history preserved for migrated files
- [ ] Documentation updated to reflect new structure

**Quality Metrics:**
- [ ] Zero content loss during migration
- [ ] Zero breaking changes to active workflows
- [ ] All unique content preserved in merges
- [ ] Clear git commit history documenting migration
- [ ] Validation scripts passing
- [ ] Context window usage unchanged or improved

**Time Metrics:**
- Total estimated effort: 10 hours
- Phase 1: 0.5 hours
- Phase 2: 2 hours
- Phase 3: 2 hours
- Phase 4: 4 hours
- Phase 5: 1.5 hours

**Risk Metrics:**
- Zero active workflow disruptions
- Zero data loss incidents
- Zero rollback events required
- All validation checks passing
