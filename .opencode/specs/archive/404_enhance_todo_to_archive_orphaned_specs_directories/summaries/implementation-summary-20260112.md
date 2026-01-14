# Implementation Summary: Task #404

**Completed**: 2026-01-12
**Duration**: ~15 minutes

## Changes Made

Enhanced the /todo command to detect and handle a third category of directories: **misplaced directories** — directories in specs/ that are already tracked in archive/state.json but were never physically moved to archive/.

This addresses the 46 known misplaced directories identified in the research phase.

## Files Modified

- `.claude/commands/todo.md` - Added misplaced directory detection, user prompts, move logic, output reporting, and documentation

### Specific Changes

1. **Step 2.6 (New)**: Added misplaced directory detection
   - Scans specs/ for directories tracked in archive/state.json
   - Distinguishes from orphans (which have no state entries)

2. **Step 4 (Updated)**: Dry-run output now shows misplaced directories
   - Shows count and list of misplaced directories
   - Shows total misplaced count

3. **Step 4.6 (New)**: User prompt for handling misplaced directories
   - Asks user whether to move misplaced directories
   - Options: "Move all" or "Skip"

4. **Step 5F (New)**: Physical move logic for misplaced directories
   - Moves directories from specs/ to archive/
   - Checks for destination conflicts
   - No state updates needed (already correct)

5. **Step 6 (Updated)**: Git commit message format
   - Includes misplaced count when applicable
   - Three variants based on what was processed

6. **Step 7 (Updated)**: Final output reporting
   - Shows misplaced directories moved section
   - Clear distinction from orphaned directories

7. **Notes Section (Updated)**: Added comprehensive documentation
   - Directory Categories Summary table
   - Misplaced Directories subsection
   - Causes and recovery information

## Verification

- All 5 phases of the implementation plan completed
- Detection logic distinguishes between orphans (no state) and misplaced (state in archive)
- User prompts allow skipping misplaced directory moves
- Output clearly distinguishes all directory categories

## Notes

The key insight from research was that "orphaned" and "misplaced" are distinct categories:
- **Orphaned**: No state entries anywhere → need state entry + potential move
- **Misplaced**: Correct state entry in wrong file → need physical move only

This enhancement will help clean up the 46 misplaced directories on next /todo run.
