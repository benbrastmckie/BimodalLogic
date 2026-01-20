---
description: Archive completed and abandoned tasks
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(git:*), Bash(mv:*), Bash(mkdir:*), Bash(ls:*), Bash(find:*), Bash(jq:*), TodoWrite, AskUserQuestion
argument-hint: [--dry-run]
model: claude-opus-4-5-20251101
---

# /todo Command

Archive completed and abandoned tasks to clean up active task list.

## Arguments

- `--dry-run` - Show what would be archived without making changes

## Execution

### 1. Parse Arguments

```
dry_run = "--dry-run" in $ARGUMENTS
```

### 2. Scan for Archivable Tasks

Read specs/state.json and identify:
- Tasks with status = "completed"
- Tasks with status = "abandoned"

Read specs/TODO.md and cross-reference:
- Entries marked [COMPLETED]
- Entries marked [ABANDONED]

### 2.5. Detect Orphaned Directories

Scan for project directories not tracked in any state file.

**CRITICAL**: This step MUST be executed to identify orphaned directories.

```bash
# Get orphaned directories in specs/ (not tracked anywhere)
orphaned_in_specs=()
for dir in specs/[0-9]*_*/; do
  [ -d "$dir" ] || continue
  project_num=$(basename "$dir" | cut -d_ -f1)

  # Check if in state.json active_projects
  in_active=$(jq -r --arg n "$project_num" \
    '.active_projects[] | select(.project_number == ($n | tonumber)) | .project_number' \
    specs/state.json 2>/dev/null)

  # Check if in archive/state.json completed_projects
  in_archive=$(jq -r --arg n "$project_num" \
    '.completed_projects[] | select(.project_number == ($n | tonumber)) | .project_number' \
    specs/archive/state.json 2>/dev/null)

  # If not in either, it's an orphan
  if [ -z "$in_active" ] && [ -z "$in_archive" ]; then
    orphaned_in_specs+=("$dir")
  fi
done

# Get orphaned directories in specs/archive/ (not tracked in archive/state.json)
orphaned_in_archive=()
for dir in specs/archive/[0-9]*_*/; do
  [ -d "$dir" ] || continue
  project_num=$(basename "$dir" | cut -d_ -f1)

  # Check if in archive/state.json completed_projects
  in_archive=$(jq -r --arg n "$project_num" \
    '.completed_projects[] | select(.project_number == ($n | tonumber)) | .project_number' \
    specs/archive/state.json 2>/dev/null)

  # If not tracked, it's an orphan
  if [ -z "$in_archive" ]; then
    orphaned_in_archive+=("$dir")
  fi
done

# Combined list for archival operations
orphaned_dirs=("${orphaned_in_specs[@]}" "${orphaned_in_archive[@]}")
```

Collect orphaned directories in two categories:
- `orphaned_in_specs[]` - Directories in specs/ not tracked anywhere (will be moved to archive/)
- `orphaned_in_archive[]` - Directories in archive/ not tracked in archive/state.json (already in archive/, need state entries)

Store counts and lists for later use.

### 2.6. Detect Misplaced Directories

Scan for project directories in specs/ that ARE tracked in archive/state.json (meaning they should be in archive/ but aren't).

**CRITICAL**: This is distinct from orphans - misplaced directories have correct state entries but are in the wrong location.

```bash
# Get misplaced directories (in specs/ but tracked in archive/state.json)
misplaced_in_specs=()
for dir in specs/[0-9]*_*/; do
  [ -d "$dir" ] || continue
  project_num=$(basename "$dir" | cut -d_ -f1)

  # Skip if already identified as orphan (not tracked anywhere)
  in_active=$(jq -r --arg n "$project_num" \
    '.active_projects[] | select(.project_number == ($n | tonumber)) | .project_number' \
    specs/state.json 2>/dev/null)

  # Check if tracked in archive/state.json (should be in archive/)
  in_archive=$(jq -r --arg n "$project_num" \
    '.completed_projects[] | select(.project_number == ($n | tonumber)) | .project_number' \
    specs/archive/state.json 2>/dev/null)

  # If in archive state but not in active state, it's misplaced
  if [ -z "$in_active" ] && [ -n "$in_archive" ]; then
    misplaced_in_specs+=("$dir")
  fi
done
```

Collect misplaced directories:
- `misplaced_in_specs[]` - Directories in specs/ that are tracked in archive/state.json (need physical move only, no state update)

Store count for later reporting.

### 3. Prepare Archive List

For each archivable task, collect:
- project_number
- project_name (slug)
- status
- completion/abandonment date
- artifact paths

### 3.5. Scan Roadmap for Task References (Structured Matching)

Use structured extraction from completion_summary fields, falling back to exact `(Task {N})` matching.

**Step 3.5.1: Extract completed tasks with summaries**:
```bash
# Extract completed tasks with their completion_summary and roadmap_items
completed_with_summaries=$(jq -r '
  .active_projects[] |
  select(.status == "completed") |
  select(.completion_summary != null) |
  {
    number: .project_number,
    name: .project_name,
    summary: .completion_summary,
    roadmap_items: (.roadmap_items // [])
  }
' specs/state.json)
```

**Step 3.5.2: Match using structured data**:
```bash
# Initialize roadmap tracking
roadmap_matches=()
roadmap_completed_count=0
roadmap_abandoned_count=0

for task in "${archivable_tasks[@]}"; do
  project_num=$(echo "$task" | jq -r '.project_number')
  status=$(echo "$task" | jq -r '.status')
  completion_summary=$(echo "$task" | jq -r '.completion_summary // empty')
  explicit_items=$(echo "$task" | jq -r '.roadmap_items[]?' 2>/dev/null)

  # Priority 1: Explicit roadmap_items (highest confidence)
  if [ -n "$explicit_items" ]; then
    while IFS= read -r item_text; do
      [ -z "$item_text" ] && continue
      # Escape special regex characters for grep
      escaped_item=$(printf '%s\n' "$item_text" | sed 's/[[\.*^$()+?{|]/\\&/g')
      line_info=$(grep -n "^\s*- \[ \].*${escaped_item}" specs/ROAD_MAP.md 2>/dev/null | head -1 || true)
      if [ -n "$line_info" ]; then
        line_num=$(echo "$line_info" | cut -d: -f1)
        roadmap_matches+=("${project_num}:${status}:explicit:${line_num}:${item_text}")
        if [ "$status" = "completed" ]; then
          ((roadmap_completed_count++))
        fi
      fi
    done <<< "$explicit_items"
    continue  # Skip other matching methods if explicit items found
  fi

  # Priority 2: Exact (Task N) reference matching
  matches=$(grep -n "(Task ${project_num})" specs/ROAD_MAP.md 2>/dev/null || true)
  if [ -n "$matches" ]; then
    while IFS= read -r match_line; do
      line_num=$(echo "$match_line" | cut -d: -f1)
      item_text=$(echo "$match_line" | cut -d: -f2-)
      roadmap_matches+=("${project_num}:${status}:exact:${line_num}:${item_text}")
      if [ "$status" = "completed" ]; then
        ((roadmap_completed_count++))
      elif [ "$status" = "abandoned" ]; then
        ((roadmap_abandoned_count++))
      fi
    done <<< "$matches"
    continue
  fi

  # Priority 3: Summary-based search (for tasks with completion_summary but no explicit items)
  # Only search unchecked items for key phrases from completion_summary
  if [ -n "$completion_summary" ] && [ "$status" = "completed" ]; then
    # Extract distinctive phrases (first 3 words of summary, excluding common words)
    # This is semantic matching, not keyword heuristic - uses actual completion context
    # Implementation note: Summary-based matching is optional enhancement
    # The explicit roadmap_items field is the primary mechanism
    :
  fi
done
```

Track:
- `roadmap_matches[]` - Array of task:status:match_type:line_num:item_text tuples
- `roadmap_completed_count` - Count of completed task matches
- `roadmap_abandoned_count` - Count of abandoned task matches

**Match Types**:
- `explicit` - Matched via `roadmap_items` field (highest confidence)
- `exact` - Matched via `(Task {N})` reference in ROAD_MAP.md
- `summary` - Matched via completion_summary content search (optional, future enhancement)

### 4. Dry Run Output (if --dry-run)

```
Tasks to archive:

Completed:
- #{N1}: {title} (completed {date})
- #{N2}: {title} (completed {date})

Abandoned:
- #{N3}: {title} (abandoned {date})

Orphaned directories in specs/ (will be moved to archive/): {N}
- {N4}_{SLUG4}/
- {N5}_{SLUG5}/

Orphaned directories in archive/ (need state tracking): {N}
- {N6}_{SLUG6}/
- {N7}_{SLUG7}/

Misplaced directories in specs/ (tracked in archive/, will be moved): {N}
- {N8}_{SLUG8}/
- {N9}_{SLUG9}/

Roadmap updates (from completion summaries):

Task #{N1} ({project_name}):
  Summary: "{completion_summary}"
  Matches:
    - [ ] {item text} (line {N}) [explicit]
    - [ ] {item text 2} (line {N}) [exact]

Task #{N2} ({project_name}):
  Summary: "{completion_summary}"
  Matches:
    - [ ] {item text} (line {N}) [exact]

Task #{N3} ({project_name}) [abandoned]:
  Matches:
    - [ ] {item text} (line {N}) [exact] -> *(Task {N} abandoned)*

Total roadmap items to update: {N}
- Completed: {N}
  - Explicit matches: {N}
  - Exact matches: {N}
- Abandoned: {N}

Total tasks: {N}
Total orphans: {N} (specs: {N}, archive: {N})
Total misplaced: {N}

Run without --dry-run to archive.
```

If no roadmap matches were found (from Step 3.5), omit the "Roadmap updates" section.

Exit here if dry run.

### 4.5. Handle Orphaned Directories (if any found)

If orphaned directories were detected in Step 2.5:

**Use AskUserQuestion**:
```
AskUserQuestion:
  question: "Found {N} orphaned project directories not tracked in state files. What would you like to do?"
  header: "Orphans"
  options:
    - label: "Track all orphans"
      description: "Move specs/ orphans to archive/ and add state entries for all orphans"
    - label: "Skip orphans"
      description: "Only archive tracked completed/abandoned tasks"
    - label: "Review list first"
      description: "Show the full list of orphaned directories"
  multiSelect: false
```

**If "Review list first" selected**:
Display the full list of orphaned directories with their contents summary:
```
Orphaned directories:
- 170_maintenance_report_improvements/ (contains: reports/, plans/)
- 190_meta_system_optimization/ (contains: reports/)
...

```

Then re-ask with only two options:
```
AskUserQuestion:
  question: "Track these {N} orphaned directories in state files?"
  header: "Confirm"
  options:
    - label: "Yes, track all"
      description: "Move specs/ orphans to archive/ and add state entries for all"
    - label: "No, skip orphans"
      description: "Only archive tracked completed/abandoned tasks"
  multiSelect: false
```

**Store the user's decision** (track_orphans = true/false) for use in Step 5.

If no orphaned directories were found, skip this step and proceed.

### 4.6. Handle Misplaced Directories (if any found)

If misplaced directories were detected in Step 2.6:

**Use AskUserQuestion**:
```
AskUserQuestion:
  question: "Found {N} misplaced directories in specs/ that should be in archive/ (already tracked in archive/state.json). Move them?"
  header: "Misplaced"
  options:
    - label: "Move all"
      description: "Move directories to archive/ (state already correct, no updates needed)"
    - label: "Skip"
      description: "Leave directories in current location"
  multiSelect: false
```

**Store the user's decision** (move_misplaced = true/false) for use in Step 5F.

If no misplaced directories were found, skip this step and proceed.

### 5. Archive Tasks

**A. Update archive/state.json**

Ensure archive directory exists:
```bash
mkdir -p specs/archive/
```

Read or create specs/archive/state.json:
```json
{
  "archived_projects": [],
  "completed_projects": []
}
```

Move each task from state.json `active_projects` to archive/state.json `completed_projects` (for completed tasks) or `archived_projects` (for abandoned tasks).

**B. Update state.json**

Remove archived tasks from active_projects array.

**C. Update TODO.md**

Remove archived task entries from main sections.

**D. Move Project Directories to Archive**

**CRITICAL**: This step MUST be executed - do not skip it.

For each archived task (completed or abandoned):
```bash
# Variables from task data
project_number={N}
project_name={SLUG}

src="specs/${project_number}_${project_name}"
dst="specs/archive/${project_number}_${project_name}"

if [ -d "$src" ]; then
  mv "$src" "$dst"
  echo "Moved: ${project_number}_${project_name} -> archive/"
  # Track this move for output reporting
else
  echo "Note: No directory for task ${project_number} (skipped)"
  # Track this skip for output reporting
fi
```

Track:
- directories_moved: list of successfully moved directories
- directories_skipped: list of tasks without directories

**E. Track Orphaned Directories (if approved in Step 4.5)**

If user selected "Track all orphans" (track_orphans = true):

**Step E.1: Move orphaned directories from specs/ to archive/**
```bash
for orphan_dir in "${orphaned_in_specs[@]}"; do
  dir_name=$(basename "$orphan_dir")
  mv "$orphan_dir" "specs/archive/${dir_name}"
  echo "Moved orphan: ${dir_name} -> archive/"
done
```

**Step E.2: Add state entries for ALL orphans (both moved and existing in archive/)**
```bash
for orphan_dir in "${orphaned_dirs[@]}"; do
  dir_name=$(basename "$orphan_dir")
  project_num=$(echo "$dir_name" | cut -d_ -f1)
  project_name=$(echo "$dir_name" | cut -d_ -f2-)

  # Determine archive path (after potential move)
  archive_path="specs/archive/${dir_name}"

  # Scan for existing artifacts
  artifacts="[]"
  [ -d "$archive_path/reports" ] && artifacts=$(echo "$artifacts" | jq '. + ["reports/"]')
  [ -d "$archive_path/plans" ] && artifacts=$(echo "$artifacts" | jq '. + ["plans/"]')
  [ -d "$archive_path/summaries" ] && artifacts=$(echo "$artifacts" | jq '. + ["summaries/"]')

  # Add entry to archive/state.json
  jq --arg num "$project_num" \
     --arg name "$project_name" \
     --arg date "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
     --argjson arts "$artifacts" \
     '.completed_projects += [{
       project_number: ($num | tonumber),
       project_name: $name,
       status: "orphan_archived",
       archived: $date,
       source: "orphan_recovery",
       detected_artifacts: $arts
     }]' specs/archive/state.json > specs/archive/state.json.tmp \
  && mv specs/archive/state.json.tmp specs/archive/state.json

  echo "Added state entry for orphan: ${dir_name}"
done
```

Track orphan operations for output reporting:
- orphans_moved: count of directories moved from specs/ to archive/
- orphans_tracked: count of state entries added to archive/state.json

**F. Move Misplaced Directories (if approved in Step 4.6)**

If user selected "Move all" (move_misplaced = true):

```bash
# Move misplaced directories from specs/ to archive/
misplaced_moved=0
for dir in "${misplaced_in_specs[@]}"; do
  dir_name=$(basename "$dir")
  dst="specs/archive/${dir_name}"

  # Check if destination already exists
  if [ -d "$dst" ]; then
    echo "Warning: ${dir_name} already exists in archive/, skipping"
    continue
  fi

  mv "$dir" "$dst"
  echo "Moved misplaced: ${dir_name} -> archive/"
  ((misplaced_moved++))
done
```

**Note**: Unlike orphans, misplaced directories do NOT need state entries added - they are already correctly tracked in archive/state.json. Only the physical move is needed.

Track misplaced operations for output reporting:
- misplaced_moved: count of directories moved from specs/ to archive/

### 5.5. Update Roadmap for Archived Tasks

**Context**: Load @.claude/context/core/patterns/roadmap-update.md for matching strategy.

For each archived task with roadmap matches (from Step 3.5):

**1. Read current ROAD_MAP.md content**

**2. Parse match tuple** (from Step 3.5):
```bash
# roadmap_matches[] entries are: project_num:status:match_type:line_num:item_text
# Parse components
project_num=$(echo "$match" | cut -d: -f1)
status=$(echo "$match" | cut -d: -f2)
match_type=$(echo "$match" | cut -d: -f3)  # explicit, exact, or summary
line_num=$(echo "$match" | cut -d: -f4)
item_text=$(echo "$match" | cut -d: -f5-)
```

**3. For each match, determine if already annotated**:
```bash
# Skip if already has completion or abandonment annotation
if echo "$line_content" | grep -qE '\*(Completed:|\*(Abandoned:|\*(Task [0-9]+ abandoned:'; then
  echo "Skipped: Line $line_num already annotated"
  ((roadmap_skipped++))
  continue
fi
```

**4. Apply appropriate annotation based on match type**:

For completed tasks with **explicit** match (via roadmap_items):
```
Edit old_string: "- [ ] {item_text}"
     new_string: "- [x] {item_text} *(Completed: Task {N}, {DATE})*"
```

For completed tasks with **exact** match (via Task N reference):
```
Edit old_string: "- [ ] {item_text} (Task {N})"
     new_string: "- [x] {item_text} (Task {N}) *(Completed: Task {N}, {DATE})*"
```

For abandoned tasks (checkbox stays unchecked):
```
Edit old_string: "- [ ] {item_text} (Task {N})"
     new_string: "- [ ] {item_text} (Task {N}) *(Task {N} abandoned: {short_reason})*"
```

**5. Track changes**:
```json
{
  "roadmap_updates": {
    "completed_annotated": 2,
    "abandoned_annotated": 1,
    "skipped_already_annotated": 1,
    "by_match_type": {
      "explicit": 1,
      "exact": 1,
      "summary": 0
    }
  }
}
```

Track roadmap operations for output reporting:
- roadmap_completed_annotated: count of completed task items marked
- roadmap_abandoned_annotated: count of abandoned task items annotated
- roadmap_skipped: count of items skipped (already annotated)
- roadmap_by_match_type: breakdown by match type (explicit/exact/summary)

**Safety Rules** (from roadmap-update.md):
- Skip items already containing `*(Completed:` or `*(Task` annotations
- Preserve existing formatting and indentation
- One edit per item (no batch edits to same line)
- Never remove existing content

### 6. Git Commit

```bash
git add specs/
git commit -m "todo: archive {N} completed tasks"
```

Include roadmap, orphan, and misplaced counts in message as applicable:
```bash
# If roadmap items updated, orphans tracked, and misplaced moved:
git commit -m "todo: archive {N} tasks, update {R} roadmap items, track {M} orphans, move {P} misplaced"

# If roadmap items updated only:
git commit -m "todo: archive {N} tasks, update {R} roadmap items"

# If roadmap items updated and orphans tracked:
git commit -m "todo: archive {N} tasks, update {R} roadmap items, track {M} orphaned directories"

# If orphans tracked and misplaced moved (no roadmap):
git commit -m "todo: archive {N} tasks, track {M} orphans, move {P} misplaced directories"

# If only orphans tracked (no roadmap):
git commit -m "todo: archive {N} tasks and track {M} orphaned directories"

# If only misplaced moved (no roadmap):
git commit -m "todo: archive {N} tasks and move {P} misplaced directories"
```

Where `{R}` = roadmap_completed_annotated + roadmap_abandoned_annotated (total roadmap items updated).

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

Orphaned directories tracked: {N}
- {N4}_{SLUG4}/ (moved to archive/, state entry added)
- {N5}_{SLUG5}/ (already in archive/, state entry added)

Misplaced directories moved: {N}
- {N8}_{SLUG8}/ (already tracked in archive/state.json)
- {N9}_{SLUG9}/ (already tracked in archive/state.json)

Roadmap updated: {N} items
- Marked complete: {N}
  - {item text} (line {N})
- Marked abandoned: {N}
  - {item text} (line {N})
- Skipped (already annotated): {N}

Skipped (no directory): {N}
- Task #{N6}

Active tasks remaining: {N}
- High priority: {N}
- Medium priority: {N}
- Low priority: {N}

Archives: specs/archive/
```

If no orphans were tracked (either none found or user skipped):
- Omit the "Orphaned directories tracked" section

If no misplaced directories were moved (either none found or user skipped):
- Omit the "Misplaced directories moved" section

If no roadmap items were updated (no matches found in Step 3.5):
- Omit the "Roadmap updated" section

## Notes

### Task Archival
- Artifacts (plans, reports, summaries) are preserved in archive/{N}_{SLUG}/
- Tasks can be recovered with `/task --recover N`
- Archive is append-only (for audit trail)
- Run periodically to keep TODO.md and specs/ manageable

### Orphan Tracking

**Orphan Categories**:
1. **Orphaned in specs/** - Directories in `specs/` not tracked in any state file
   - Action: Move to archive/ AND add entry to archive/state.json
2. **Orphaned in archive/** - Directories in `specs/archive/` not tracked in archive/state.json
   - Action: Add entry to archive/state.json (no move needed)

**orphan_archived Status**:
- Orphaned directories receive status `"orphan_archived"` in archive/state.json
- The `source` field is set to `"orphan_recovery"` to distinguish from normal archival
- The `detected_artifacts` field lists any existing subdirectories (reports/, plans/, summaries/)

**Recovery**:
- Orphaned directories with state entries can be inspected in archive/
- Manual recovery is possible by moving directories and updating state files
- Use `/task --recover N` only for tracked tasks (not orphans)

### Misplaced Directories

**Definition**: Directories in `specs/` that ARE tracked in `archive/state.json`.

This indicates the directory was archived in state but never physically moved.

**Directory Categories Summary**:

| Category | Location | Tracked in state.json? | Tracked in archive/state.json? | Action |
|----------|----------|------------------------|--------------------------------|--------|
| Active | specs/ | Yes | No | Normal (no action) |
| Orphaned in specs/ | specs/ | No | No | Move + add state entry |
| Orphaned in archive/ | archive/ | No | No | Add state entry only |
| Misplaced | specs/ | No | Yes | Move only (state correct) |
| Archived | archive/ | No | Yes | Normal (no action) |

**Misplaced Directories**:
- Already have correct state entries in archive/state.json
- Only need to be physically moved to specs/archive/
- No state updates required

**Causes of Misplaced Directories**:
- Directory move failed silently during previous archival
- Manual state edits without corresponding directory moves
- System interrupted during archival process
- /todo command Step 5D not executing consistently

**Recovery**:
- Use `/task --recover N` to recover misplaced directories (they have valid state entries)
- After moving, the directory will be in the correct location matching its state

### Roadmap Updates

**Matching Strategy** (Structured Synchronization):

Roadmap matching uses structured data from completed tasks, not keyword heuristics:

1. **Explicit roadmap_items** (Priority 1, highest confidence):
   - Tasks can include a `roadmap_items` array in state.json
   - Contains exact item text to match against ROAD_MAP.md
   - Example: `"roadmap_items": ["Improve /todo command roadmap updates"]`

2. **Exact (Task N) references** (Priority 2):
   - Searches ROAD_MAP.md for `(Task {N})` patterns
   - Works with existing roadmap items that reference task numbers

3. **Summary-based search** (Future enhancement):
   - Uses `completion_summary` field to find semantically related items
   - Not currently implemented (placeholder for future)

**Producer/Consumer Workflow**:
- `/implement` is the **producer**: populates `completion_summary` and optional `roadmap_items`
- `/todo` is the **consumer**: extracts these fields via jq and matches against ROAD_MAP.md

**Annotation Formats**:

Completed tasks with explicit match:
```markdown
- [x] {item text} *(Completed: Task {N}, {DATE})*
```

Completed tasks with exact (Task N) match:
```markdown
- [x] {item text} (Task {N}) *(Completed: Task {N}, {DATE})*
```

Abandoned tasks (checkbox stays unchecked):
```markdown
- [ ] {item text} (Task {N}) *(Task {N} abandoned: {short_reason})*
```

**Safety Rules**:
- Skip items already annotated (contain `*(Completed:` or `*(Task` patterns)
- Preserve existing formatting and indentation
- One edit per item
- Never remove existing content

**Date Format**: ISO date (YYYY-MM-DD) from task completion/abandonment timestamp

**Abandoned Reason**: Truncated to first 50 characters of `abandoned_reason` field from state.json

**Well-Formed Completion Summaries**:

Good examples:
- "Implemented structured synchronization between task completion data and roadmap updates. Added completion_summary field to task schema."
- "Fixed modal logic proof for reflexive frames. Added missing transitivity lemma and updated test cases."
- "Created LaTeX documentation for Logos layer architecture with diagrams and examples."

The summary should:
- Be 1-3 sentences describing what was accomplished
- Focus on outcomes, not process
- Be specific enough to enable roadmap matching
