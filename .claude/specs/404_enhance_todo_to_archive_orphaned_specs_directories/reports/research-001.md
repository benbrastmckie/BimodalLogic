# Research Report: Task #404

**Task**: Enhance /todo to archive orphaned specs directories
**Date**: 2026-01-12
**Focus**: Understanding current orphan detection and identifying gaps

## Summary

The current /todo command has comprehensive orphan detection logic (Step 2.5) that identifies directories not tracked in state files. However, there is a third category of "misplaced" directories that the current logic misses: directories in specs/ whose tasks are tracked in archive/state.json (meaning they should be in archive/).

## Findings

### Current Orphan Detection (Step 2.5)

The existing logic detects two categories:
1. **Orphaned in specs/** - Directories in `specs/` not tracked in any state file
2. **Orphaned in archive/** - Directories in `archive/` not tracked in archive/state.json

Both categories are correctly handled when detected.

### Missing Category: Misplaced Directories

There are **46 directories** currently in `specs/` that:
- ARE tracked in `archive/state.json` (status: completed/abandoned)
- Should physically BE in `specs/archive/` but are NOT

These directories were archived in state files but the physical directory move was never executed (or failed silently).

Examples:
- 176_enhance_proof_search_with_domain_specific_heuristics_and_caching
- 179_implement_performance_benchmarks_for_proof_search_and_derivation
- 315_research_and_resolve_axiom_prop_vs_type_blocker_for_proof_term_construction

### Root Cause

The /todo command's Step 5D (Move Project Directories to Archive) either:
1. Was not executed consistently in past runs
2. Failed silently without reporting errors
3. Was added recently and doesn't apply retroactively

### Current State Summary

| Location | Count | Tracked? | Status |
|----------|-------|----------|--------|
| specs/ (active) | 13 | state.json active | Correct |
| specs/ (misplaced) | 46 | archive/state.json | **Should be moved** |
| archive/ | 64 | archive/state.json | Correct |

## Recommendations

### 1. Add Third Category Detection

Add Step 2.6 to detect "misplaced" directories:

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

### 2. Handle Misplaced Directories

In Step 4.5, ask about misplaced directories:

```
AskUserQuestion:
  question: "Found {N} project directories in specs/ that should be in archive/. Move them?"
  header: "Misplaced"
  options:
    - label: "Move all"
      description: "Move directories to archive/ (state already correct)"
    - label: "Skip"
      description: "Leave directories in current location"
```

In Step 5, add Step 5F to move misplaced directories:

```bash
for dir in "${misplaced_in_specs[@]}"; do
  dir_name=$(basename "$dir")
  mv "$dir" ".claude/specs/archive/${dir_name}"
  echo "Moved misplaced: ${dir_name} -> archive/"
done
```

### 3. Simplify to Single "Reconciliation" Step

Consider consolidating orphan detection into a single "reconciliation" step that:
1. Compares specs/ directories against state.json active_projects
2. Compares archive/ directories against archive/state.json completed_projects
3. Reports discrepancies in all directions:
   - Missing state entries (current orphans)
   - Misplaced directories (tracked in wrong state file)
   - Duplicate entries (same task number in both state files)

## References

- `.claude/commands/todo.md` - Current /todo command implementation
- `.claude/specs/state.json` - Active projects state
- `.claude/specs/archive/state.json` - Archived projects state

## Next Steps

1. Update /todo command Step 2.5 to add misplaced directory detection
2. Update Step 4.5 to include misplaced directories in user prompt
3. Add Step 5F to move misplaced directories
4. Update dry-run output to show misplaced directories
5. Update final output to report misplaced directories moved
