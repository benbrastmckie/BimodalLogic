# Implementation Plan: Task #404

**Task**: Enhance /todo to archive orphaned specs directories
**Version**: 001
**Created**: 2026-01-12
**Language**: meta

## Overview

The current /todo command detects two categories of orphaned directories (not tracked anywhere, tracked but in archive/). The research identified a third category: **misplaced directories** — directories in specs/ that are tracked in archive/state.json (meaning they should be physically located in archive/ but aren't).

This enhancement adds:
1. Detection of misplaced directories (Step 2.6)
2. User prompt for handling misplaced directories (Step 4.5 extension)
3. Physical move of misplaced directories (Step 5F)
4. Updated output reporting

## Phases

### Phase 1: Add Misplaced Directory Detection

**Status**: [COMPLETED]

**Objectives**:
1. Add Step 2.6 to detect directories in specs/ tracked in archive/state.json
2. Collect misplaced directories into a separate array

**Files to modify**:
- `.claude/commands/todo.md` - Add Step 2.6 detection logic

**Steps**:
1. After Step 2.5 (orphan detection), add Step 2.6:
   ```bash
   # Get misplaced directories (in specs/ but tracked in archive/state.json)
   misplaced_in_specs=()
   for dir in .claude/specs/[0-9]*_*/; do
     [ -d "$dir" ] || continue
     project_num=$(basename "$dir" | cut -d_ -f1)

     # Check if tracked in archive/state.json (should be in archive/)
     in_archive=$(jq -r --arg n "$project_num" \
       '.completed_projects[] | select(.project_number == ($n | tonumber)) | .project_number' \
       .claude/specs/archive/state.json 2>/dev/null)

     if [ -n "$in_archive" ]; then
       misplaced_in_specs+=("$dir")
     fi
   done
   ```
2. Store count for later reporting

**Verification**:
- The detection logic captures the 46 known misplaced directories
- Does not interfere with existing orphan detection

---

### Phase 2: Extend User Prompts

**Status**: [COMPLETED]

**Objectives**:
1. Update Step 4 dry-run output to show misplaced directories
2. Extend Step 4.5 to include misplaced directory handling

**Files to modify**:
- `.claude/commands/todo.md` - Update Step 4 and Step 4.5

**Steps**:
1. Add misplaced directory section to dry-run output (Step 4):
   ```
   Misplaced directories in specs/ (tracked in archive/, will be moved): {N}
   - {N1}_{SLUG1}/
   - {N2}_{SLUG2}/
   ```
2. Extend Step 4.5 to ask about misplaced directories if any found:
   ```
   AskUserQuestion:
     question: "Found {N} misplaced directories in specs/ that should be in archive/. Move them?"
     header: "Misplaced"
     options:
       - label: "Move all"
         description: "Move directories to archive/ (state already correct)"
       - label: "Skip"
         description: "Leave directories in current location"
   ```
3. Store user decision (move_misplaced = true/false)

**Verification**:
- Dry-run output shows misplaced count and list
- User prompt appears when misplaced directories exist
- User decision is stored for Step 5F

---

### Phase 3: Implement Move Logic

**Status**: [COMPLETED]

**Objectives**:
1. Add Step 5F to physically move misplaced directories
2. Track moved directories for output reporting

**Files to modify**:
- `.claude/commands/todo.md` - Add Step 5F

**Steps**:
1. Add Step 5F after Step 5E:
   ```bash
   # Step 5F: Move misplaced directories (if approved)
   if [ "$move_misplaced" = true ]; then
     for dir in "${misplaced_in_specs[@]}"; do
       dir_name=$(basename "$dir")
       mv "$dir" ".claude/specs/archive/${dir_name}"
       echo "Moved misplaced: ${dir_name} -> archive/"
     done
   fi
   ```
2. Track misplaced_moved count for output

**Verification**:
- Directories are physically moved to archive/
- No state.json updates needed (already tracked correctly)
- Move failures are handled gracefully

---

### Phase 4: Update Output Reporting

**Status**: [COMPLETED]

**Objectives**:
1. Update Step 7 output to report misplaced directories
2. Include counts in summary

**Files to modify**:
- `.claude/commands/todo.md` - Update Step 7 output

**Steps**:
1. Add misplaced directory section to final output:
   ```
   Misplaced directories moved: {N}
   - {N1}_{SLUG1}/ (already tracked in archive/state.json)
   - {N2}_{SLUG2}/ (already tracked in archive/state.json)
   ```
2. Update git commit message format:
   ```bash
   git commit -m "todo: archive {N} tasks, track {M} orphans, move {P} misplaced directories"
   ```

**Verification**:
- Output clearly distinguishes misplaced from orphaned
- Git commit message includes all categories

---

### Phase 5: Update Notes Section

**Status**: [COMPLETED]

**Objectives**:
1. Add documentation for misplaced directory handling
2. Clarify the three categories

**Files to modify**:
- `.claude/commands/todo.md` - Update Notes section

**Steps**:
1. Add "Misplaced Directories" subsection:
   ```markdown
   ### Misplaced Directories

   **Definition**: Directories in `specs/` that ARE tracked in `archive/state.json`.

   This indicates the directory was archived in state but never physically moved.
   These directories:
   - Already have correct state entries in archive/state.json
   - Only need to be physically moved to specs/archive/
   - No state updates required

   **Causes**:
   - Directory move failed silently during archival
   - Manual state edits without corresponding directory moves
   - System interrupted during archival process
   ```
2. Update summary table of directory categories

**Verification**:
- Notes section clearly explains all three categories
- Distinction between orphaned (no state) and misplaced (wrong location) is clear

## Dependencies

- None (self-contained enhancement to existing command)

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Large number of directories to move (46) | Low | Confirmed | Move in batch, report progress |
| Directory already exists in archive/ | Medium | Low | Check existence before mv, skip if conflict |
| Permission errors during move | Medium | Low | Report failures, continue with remaining |

## Success Criteria

- [ ] Misplaced directory detection identifies all 46 known cases
- [ ] Dry-run output shows misplaced directories separately
- [ ] User can choose to move or skip misplaced directories
- [ ] Physical directory moves succeed without state updates
- [ ] Output clearly distinguishes misplaced from orphaned
- [ ] Notes section documents the three categories

## Rollback Plan

If implementation causes issues:
1. Revert changes to `.claude/commands/todo.md` via git
2. Misplaced directories remain in specs/ (harmless, just not organized)
3. No data loss possible (directories are only moved, not deleted)
