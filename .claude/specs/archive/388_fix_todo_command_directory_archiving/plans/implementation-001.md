# Implementation Plan: Task #388

**Task**: Fix /todo command directory archiving
**Version**: 001
**Created**: 2026-01-12
**Language**: meta

## Overview

Enhance the `/todo` command to properly move project directories to the archive when archiving completed/abandoned tasks, and add support for detecting and optionally archiving orphaned project directories (those not tracked in any state file) with user confirmation via `AskUserQuestion`.

## Phases

### Phase 1: Update Command Metadata and Add Orphan Detection Step

**Estimated effort**: 20 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Add `AskUserQuestion` to allowed-tools
2. Add `Bash(ls:*)` and `Bash(find:*)` to allowed-tools for directory listing
3. Insert new Step 2.5 for orphan detection

**Files to modify**:
- `.claude/commands/todo.md` - Update allowed-tools and add orphan detection step

**Steps**:
1. Edit the YAML frontmatter to add `AskUserQuestion` and expand Bash permissions
2. After Step 2 (Scan for Archivable Tasks), insert Step 2.5 (Detect Orphaned Directories):
   ```markdown
   ### 2.5. Detect Orphaned Directories

   Scan for project directories not tracked in any state file:

   ```bash
   # Find all directories matching {N}_{SLUG} pattern in specs/
   # For each, check if project_number exists in:
   #   - state.json active_projects
   #   - archive/state.json completed_projects
   # Directories not in either are orphans
   ```

   Collect orphaned directories:
   - directory path
   - project number (extracted from name)
   - slug (extracted from name)
   ```
3. Renumber subsequent steps (Step 3 becomes Step 3, etc. - but insert 2.5)

**Verification**:
- Command file parses correctly
- New step is clearly documented
- allowed-tools includes AskUserQuestion

---

### Phase 2: Add User Confirmation Flow for Orphans

**Estimated effort**: 25 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Insert Step 4.5 for user confirmation when orphans are found
2. Handle all three user responses (archive all, skip, review list)

**Files to modify**:
- `.claude/commands/todo.md` - Add user confirmation step

**Steps**:
1. After Step 4 (Dry Run Output), insert Step 4.5 (Orphan Confirmation):
   ```markdown
   ### 4.5. Handle Orphaned Directories (if any found)

   If orphaned directories were detected in Step 2.5:

   **Use AskUserQuestion**:
   ```
   AskUserQuestion:
     question: "Found {N} orphaned project directories not tracked in state files. What would you like to do?"
     header: "Orphans"
     options:
       - label: "Archive all orphans"
         description: "Move all {N} orphaned directories to archive/"
       - label: "Skip orphans"
         description: "Only archive tracked completed/abandoned tasks"
       - label: "Review list first"
         description: "Show the full list of orphaned directories"
     multiSelect: false
   ```

   **If "Review list first" selected**:
   Display the full list of orphaned directories, then re-ask the question with only "Archive all" and "Skip" options.

   **Store decision** for use in Step 5.
   ```

2. Update dry run output (Step 4) to also show orphan count if any found

**Verification**:
- AskUserQuestion syntax matches /meta command patterns
- All three response paths are documented
- Review list → re-ask flow is clear

---

### Phase 3: Fix Directory Move Execution

**Estimated effort**: 30 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Make Step 5D more explicit with bash commands
2. Add orphan directory moves to Step 5
3. Add error handling for move operations

**Files to modify**:
- `.claude/commands/todo.md` - Enhance Step 5D and add orphan move logic

**Steps**:
1. Rewrite Step 5D with explicit, imperative instructions:
   ```markdown
   **D. Move Project Directories to Archive**

   **CRITICAL**: This step MUST be executed - do not skip it.

   First, ensure archive directory exists:
   ```bash
   mkdir -p .claude/specs/archive/
   ```

   For each archived task (completed or abandoned):
   ```bash
   # Variables from task data
   project_number={N}
   project_name={SLUG}

   src=".claude/specs/${project_number}_${project_name}"
   dst=".claude/specs/archive/${project_number}_${project_name}"

   if [ -d "$src" ]; then
     mv "$src" "$dst"
     echo "Moved: ${project_number}_${project_name} -> archive/"
   else
     echo "Note: No directory for task ${project_number}"
   fi
   ```

   Track moved directories for output reporting.
   ```

2. Add Step 5E for orphan directory moves (if user approved):
   ```markdown
   **E. Move Orphaned Directories (if approved in Step 4.5)**

   If user selected "Archive all orphans":
   ```bash
   for each orphan_dir in orphaned_directories:
     mv "$orphan_dir" ".claude/specs/archive/$(basename $orphan_dir)"
     echo "Moved orphan: $(basename $orphan_dir) -> archive/"
   ```

   Note: Orphaned directories are moved but NOT added to archive/state.json since they have no task metadata.
   ```

**Verification**:
- Step 5D has explicit bash commands
- Error handling for non-existent directories
- Orphan moves are conditional on user approval
- mkdir -p runs first

---

### Phase 4: Update Output Reporting

**Estimated effort**: 15 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Update Step 7 output to include directory move results
2. Add orphan handling summary
3. Ensure output clearly shows what was moved

**Files to modify**:
- `.claude/commands/todo.md` - Enhance output section

**Steps**:
1. Update Step 7 output template:
   ```markdown
   ### 7. Output

   ```
   Archived {N} tasks:

   Completed ({N}):
   - #{N1}: {title}
   - #{N2}: {title}

   Abandoned ({N}):
   - #{N3}: {title}

   Directories moved to archive: {N}
   - {N1}_{SLUG1}/ -> archive/
   - {N2}_{SLUG2}/ -> archive/

   Orphaned directories archived: {N}
   - {N4}_{SLUG4}/ -> archive/ (orphan)
   - {N5}_{SLUG5}/ -> archive/ (orphan)

   Skipped (no directory): {N}
   - Task #{N6}

   Active tasks remaining: {N}
   - High priority: {N}
   - Medium priority: {N}
   - Low priority: {N}

   Archives: .claude/specs/archive/
   ```
   ```

2. Add note about orphan recovery limitations:
   ```markdown
   ## Notes

   - Artifacts (plans, reports, summaries) are preserved in archive/{N}_{SLUG}/
   - Tasks can be recovered with `/task --recover N`
   - **Orphaned directories** can be manually moved back but have no state.json entry
   - Archive is append-only (for audit trail)
   - Run periodically to keep TODO.md and .claude/specs/ manageable
   ```

**Verification**:
- Output includes all categories of moves
- Orphan moves clearly labeled
- Skipped tasks noted

---

## Dependencies

- None - self-contained command update

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Directory move fails mid-operation | Medium | Low | Use conditional checks, report failures |
| User confused by orphan prompt | Low | Medium | Clear option descriptions |
| Large number of orphans overwhelms UI | Low | Low | Count shown, full list on request |

## Success Criteria

- [ ] `/todo --dry-run` shows orphaned directories count
- [ ] Running `/todo` moves completed/abandoned task directories to archive
- [ ] User is prompted about orphaned directories with AskUserQuestion
- [ ] Output clearly reports which directories were moved
- [ ] Archive directory contains moved project directories after run

## Rollback Plan

If implementation fails:
1. Restore `.claude/commands/todo.md` from git
2. Directories that were moved can be manually moved back
3. No state.json changes needed (directory moves are independent of state)

## Test Plan

1. Run `/todo --dry-run` to verify detection
2. Run `/todo` with a mix of:
   - Completed tasks with directories
   - Abandoned tasks with directories
   - Tasks without directories
   - Orphaned directories
3. Verify all directories moved correctly
4. Verify orphan prompt appears and responds to all three options
5. Check output formatting
