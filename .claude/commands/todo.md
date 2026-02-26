---
description: Archive completed and abandoned tasks
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(git:*), Bash(mv:*), Bash(mkdir:*), Bash(ls:*), Bash(find:*), Bash(jq:*), TodoWrite, AskUserQuestion
argument-hint: [--dry-run]
model: claude-opus-4-5-20251101
---

# /todo Command

Archive completed and abandoned tasks to clean up active task list.

**IMPORTANT: Exclusive Access Required**

This command modifies `specs/TODO.md`, `specs/state.json`, `specs/archive/`, and moves project directories.
Do NOT run `/todo` while other agents are operating on tasks - it requires exclusive access to `specs/`.

See `.claude/context/core/standards/git-staging-scope.md` for details on why `/todo` is a special case.

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

### 2.7. Auto-Complete Expanded Tasks

Scan for expanded tasks where all subtasks have reached terminal status (completed or abandoned). These parent tasks should transition to completed status.

**CRITICAL**: This step must execute BEFORE Step 3 (Prepare Archive List) so auto-completed tasks are included in the archivable list.

```bash
# Initialize tracking for auto-completed expanded tasks
auto_completed_expanded=()

# Get expanded tasks from state.json
expanded_tasks=$(jq -c '.active_projects[] | select(.status == "expanded")' specs/state.json)

for task_json in $expanded_tasks; do
  project_num=$(echo "$task_json" | jq -r '.project_number')
  project_name=$(echo "$task_json" | jq -r '.project_name')

  # Get subtasks array (handle missing field gracefully)
  subtasks=$(echo "$task_json" | jq -r '.subtasks[]?' 2>/dev/null)

  if [ -z "$subtasks" ]; then
    # No subtasks field or empty - skip this task
    echo "Note: Expanded task ${project_num} has no subtasks array, skipping"
    continue
  fi

  # Check all subtasks for terminal status
  all_terminal=true
  completed_count=0
  abandoned_count=0
  total_count=0

  for subtask_num in $subtasks; do
    ((total_count++))

    # Look up subtask status in state.json
    # Use "| not" pattern for Issue #1132 safety
    subtask_status=$(jq -r --arg n "$subtask_num" \
      '.active_projects[] | select(.project_number == ($n | tonumber)) | .status' \
      specs/state.json 2>/dev/null)

    # If not in active_projects, check archive (treated as completed)
    if [ -z "$subtask_status" ]; then
      subtask_in_archive=$(jq -r --arg n "$subtask_num" \
        '.completed_projects[] | select(.project_number == ($n | tonumber)) | .status' \
        specs/archive/state.json 2>/dev/null)

      if [ -n "$subtask_in_archive" ]; then
        # Subtask is archived - count as completed
        ((completed_count++))
      else
        # Subtask not found anywhere - treat as completed (may have been manually deleted)
        ((completed_count++))
        echo "Note: Subtask ${subtask_num} not found in state files, treating as completed"
      fi
      continue
    fi

    # Check if subtask status is terminal
    case "$subtask_status" in
      completed)
        ((completed_count++))
        ;;
      abandoned)
        ((abandoned_count++))
        ;;
      *)
        # Non-terminal status - parent cannot be auto-completed
        all_terminal=false
        break
        ;;
    esac
  done

  # If all subtasks are terminal, auto-complete the parent
  if [ "$all_terminal" = true ] && [ "$total_count" -gt 0 ]; then
    echo "Auto-completing expanded task ${project_num}: all ${total_count} subtasks finished (${completed_count} completed, ${abandoned_count} abandoned)"

    # Generate completion_summary
    completion_summary="Expanded task auto-completed: ${completed_count} subtasks completed"
    if [ "$abandoned_count" -gt 0 ]; then
      completion_summary+=", ${abandoned_count} subtasks abandoned"
    fi

    # Update state.json: change status to completed, add completion_summary
    jq --arg num "$project_num" \
       --arg summary "$completion_summary" \
       --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
       '(.active_projects[] | select(.project_number == ($num | tonumber))) |= (
         .status = "completed" |
         .completion_summary = $summary |
         .last_updated = $ts |
         .auto_completed = true
       )' specs/state.json > specs/state.json.tmp && mv specs/state.json.tmp specs/state.json

    # Update TODO.md: change [EXPANDED] to [COMPLETED] and add Completed date
    # Find the task entry and update its status marker
    old_status_line="- **Status**: [EXPANDED]"
    new_status_line="- **Status**: [COMPLETED]"
    completed_date=$(date +%Y-%m-%d)

    # Use Edit tool pattern: find task section and update status
    # Note: This is pseudo-code for the actual Edit operation
    # The task header pattern is: "### {N}. {title}"
    # We need to find this header and update the Status line within it

    # Track for output reporting
    auto_completed_expanded+=("${project_num}:${project_name}:${completed_count}:${abandoned_count}:${total_count}")
  fi
done

# Count for reporting
auto_completed_count=${#auto_completed_expanded[@]}
```

Track auto-completed tasks:
- `auto_completed_expanded[]` - Array of `project_num:project_name:completed:abandoned:total` tuples
- `auto_completed_count` - Count of auto-completed expanded tasks

**Note**: Auto-completed tasks will be picked up by Step 3 (Prepare Archive List) since their status is now "completed".

### 3. Prepare Archive List

For each archivable task, collect:
- project_number
- project_name (slug)
- status
- completion/abandonment date
- artifact paths

### 3.5. Scan Roadmap for Task References (Structured Matching)

Use structured extraction from completion_summary fields, falling back to exact `(Task {N})` matching.

**IMPORTANT**: Meta tasks (language: "meta") are excluded from ROAD_MAP.md matching. They use `claudemd_suggestions` instead (see Step 3.6).

**Step 3.5.1: Separate meta and non-meta tasks**:
```bash
# Separate archivable tasks by language
meta_tasks=()
non_meta_tasks=()

for task in "${archivable_tasks[@]}"; do
  language=$(echo "$task" | jq -r '.language // "general"')
  if [ "$language" = "meta" ]; then
    meta_tasks+=("$task")
  else
    non_meta_tasks+=("$task")
  fi
done
```

**Step 3.5.2: Extract non-meta completed tasks with summaries**:
```bash
# Only process non-meta tasks for ROAD_MAP.md matching
# Use file-based jq filter to avoid Issue #1132 with != operator
cat > /tmp/todo_nonmeta_$$.jq << 'EOF'
.active_projects[] |
select(.status == "completed") |
select(.language != "meta") |
select(.completion_summary != null) |
{
  number: .project_number,
  name: .project_name,
  summary: .completion_summary,
  roadmap_items: (.roadmap_items // [])
}
EOF
completed_with_summaries=$(jq -rf /tmp/todo_nonmeta_$$.jq specs/state.json)
rm -f /tmp/todo_nonmeta_$$.jq
```

**Step 3.5.3: Match non-meta tasks against ROAD_MAP.md**:
```bash
# Initialize roadmap tracking
roadmap_matches=()
roadmap_completed_count=0
roadmap_abandoned_count=0

# Only iterate non-meta tasks for roadmap matching
for task in "${non_meta_tasks[@]}"; do
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
- `meta_tasks[]` - Array of meta tasks (excluded from ROAD_MAP.md matching)
- `non_meta_tasks[]` - Array of non-meta tasks (matched against ROAD_MAP.md)
- `roadmap_matches[]` - Array of task:status:match_type:line_num:item_text tuples
- `roadmap_completed_count` - Count of completed task matches
- `roadmap_abandoned_count` - Count of abandoned task matches

**Match Types**:
- `explicit` - Matched via `roadmap_items` field (highest confidence)
- `exact` - Matched via `(Task {N})` reference in ROAD_MAP.md
- `summary` - Matched via completion_summary content search (optional, future enhancement)

### 3.6. Scan Meta Tasks for CLAUDE.md Suggestions

Meta tasks use `claudemd_suggestions` instead of ROAD_MAP.md updates. This step collects suggestions for user review.

**Step 3.6.1: Extract claudemd_suggestions from meta tasks**:
```bash
# Initialize CLAUDE.md suggestion tracking
claudemd_suggestions=()
claudemd_add_count=0
claudemd_update_count=0
claudemd_remove_count=0
claudemd_none_count=0

for task in "${meta_tasks[@]}"; do
  project_num=$(echo "$task" | jq -r '.project_number')
  project_name=$(echo "$task" | jq -r '.project_name')
  status=$(echo "$task" | jq -r '.status')

  # Extract claudemd_suggestions if present (use has() instead of != null for Issue #1132)
  has_suggestions=$(echo "$task" | jq -r 'has("claudemd_suggestions")')

  if [ "$has_suggestions" = "true" ]; then
    action=$(echo "$task" | jq -r '.claudemd_suggestions.action // "none"')
    section=$(echo "$task" | jq -r '.claudemd_suggestions.section // ""')
    rationale=$(echo "$task" | jq -r '.claudemd_suggestions.rationale // ""')
    content=$(echo "$task" | jq -r '.claudemd_suggestions.content // ""')
    removes=$(echo "$task" | jq -r '.claudemd_suggestions.removes // ""')

    # Track by action type
    case "$action" in
      add)
        ((claudemd_add_count++))
        ;;
      update)
        ((claudemd_update_count++))
        ;;
      remove)
        ((claudemd_remove_count++))
        ;;
      none)
        ((claudemd_none_count++))
        ;;
    esac

    # Store suggestion for display (JSON format for structured access)
    suggestion=$(jq -n \
      --arg num "$project_num" \
      --arg name "$project_name" \
      --arg status "$status" \
      --arg action "$action" \
      --arg section "$section" \
      --arg rationale "$rationale" \
      --arg content "$content" \
      --arg removes "$removes" \
      '{
        project_number: ($num | tonumber),
        project_name: $name,
        status: $status,
        action: $action,
        section: $section,
        rationale: $rationale,
        content: $content,
        removes: $removes
      }')
    claudemd_suggestions+=("$suggestion")
  else
    # Meta task without claudemd_suggestions - note for output
    # These are treated as implicit "none" (no CLAUDE.md changes suggested)
    ((claudemd_none_count++))
  fi
done
```

Track:
- `claudemd_suggestions[]` - Array of suggestion objects from meta tasks
- `claudemd_add_count` - Count of "add" action suggestions
- `claudemd_update_count` - Count of "update" action suggestions
- `claudemd_remove_count` - Count of "remove" action suggestions
- `claudemd_none_count` - Count of "none" action or missing suggestions

**Note**: Suggestions with action "none" are acknowledged but not displayed as actionable items in the output.

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

Auto-completed expanded tasks: {N}
- #{N10}: {title} (all {X} subtasks finished: {Y} completed, {Z} abandoned)
- #{N11}: {title} (all {X} subtasks finished: {Y} completed, {Z} abandoned)

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

CLAUDE.md suggestions (from meta tasks):

Task #{N4} ({project_name}) [meta]:
  Action: ADD
  Section: {section}
  Rationale: {rationale}
  Content:
    {content preview, first 3 lines}

Task #{N5} ({project_name}) [meta]:
  Action: UPDATE
  Section: {section}
  Rationale: {rationale}
  Removes: {removes}
  Content:
    {content preview}

Task #{N6} ({project_name}) [meta]:
  Action: NONE
  Rationale: {rationale}

Total CLAUDE.md suggestions: {N}
- Add: {N}
- Update: {N}
- Remove: {N}
- None (no changes needed): {N}

Note: Interactive selection will prompt for which suggestions to apply via Edit tool.

Changelog updates (for completed tasks):

Entries to add:
- {YYYY-MM-DD}: Task #{N1}, Task #{N2} ({N} entries, new date header)
- {YYYY-MM-DD}: Task #{N3} ({N} entry, existing date header)

Total: {N} entries across {M} dates

Total tasks: {N}
Total orphans: {N} (specs: {N}, archive: {N})
Total misplaced: {N}

Run without --dry-run to archive.
```

If no auto-completed expanded tasks were found (from Step 2.7), omit the "Auto-completed expanded tasks" section.

If no roadmap matches were found (from Step 3.5), omit the "Roadmap updates" section.

If no CLAUDE.md suggestions were found (from Step 3.6), omit the "CLAUDE.md suggestions" section.

If CLAUDE.md suggestions exist, the "Note: Interactive selection..." line is always shown in dry-run.

If CHANGE_LOG.md doesn't exist, omit the "Changelog updates" section and show:
```
Note: specs/CHANGE_LOG.md not found. Run Task 941 to create the changelog file.
```

If no completed tasks are being archived (only abandoned), omit the "Changelog updates" section.

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

Remove archived tasks from active_projects array using `del()` pattern (avoids Issue #1132 with `!=` operator):
```bash
# Use del() instead of map(select(.status != "completed" and .status != "abandoned"))
# This pattern is Issue #1132-safe
jq 'del(.active_projects[] | select(.status == "completed" or .status == "abandoned"))' \
  specs/state.json > specs/state.json.tmp && mv specs/state.json.tmp specs/state.json
```

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

### 5.6. Interactive CLAUDE.md Suggestion Selection for Meta Tasks

For meta tasks with `claudemd_suggestions` (from Step 3.6), use interactive selection to apply suggestions via the Edit tool.

**Step 5.6.1: Filter actionable suggestions**:

Build list of suggestions where action is NOT "none":
```bash
actionable_suggestions=()
for suggestion in "${claudemd_suggestions[@]}"; do
  action=$(echo "$suggestion" | jq -r '.action')
  if [ "$action" != "none" ]; then
    actionable_suggestions+=("$suggestion")
  fi
done
```

If no actionable suggestions exist, skip to Step 5.6.5 (handle "none" actions only).

**Step 5.6.2: Interactive selection via AskUserQuestion**:

If `actionable_suggestions[]` has any entries:

```
AskUserQuestion:
  question: "Found {N} CLAUDE.md suggestions from meta tasks. Which should be applied?"
  header: "CLAUDE.md Updates"
  multiSelect: true
  options:
    - label: "Task #{N1}: {ACTION} to {section}"
      description: "{rationale}"
    - label: "Task #{N2}: {ACTION} to {section}"
      description: "{rationale}"
    ...
    - label: "Skip all"
      description: "Don't apply any suggestions (display only for manual review)"
```

Build options dynamically from `actionable_suggestions[]`:
```bash
options=()
for suggestion in "${actionable_suggestions[@]}"; do
  project_num=$(echo "$suggestion" | jq -r '.project_number')
  action=$(echo "$suggestion" | jq -r '.action | ascii_upcase')
  section=$(echo "$suggestion" | jq -r '.section')
  rationale=$(echo "$suggestion" | jq -r '.rationale')

  label="Task #${project_num}: ${action} to ${section}"
  options+=("{\"label\": \"$label\", \"description\": \"$rationale\"}")
done
# Always add "Skip all" as last option
options+=("{\"label\": \"Skip all\", \"description\": \"Don't apply any suggestions (display only for manual review)\"}")
```

Store user selection for Step 5.6.3.

**Step 5.6.3: Apply selected suggestions via Edit tool**:

For each selected suggestion (excluding "Skip all"):

1. Parse suggestion data:
```bash
project_num=$(echo "$suggestion" | jq -r '.project_number')
action=$(echo "$suggestion" | jq -r '.action')
section=$(echo "$suggestion" | jq -r '.section')
content=$(echo "$suggestion" | jq -r '.content // empty')
removes=$(echo "$suggestion" | jq -r '.removes // empty')
```

2. Read current `.claude/CLAUDE.md` content

3. Apply Edit based on action type:

**For ADD action**:
- Find section header (e.g., "## {section}" or "### {section}")
- Edit: Insert content after the section header line
- old_string: The section header line + following newline
- new_string: The section header line + newline + content + newline

**For UPDATE action**:
- Edit: Replace `removes` text with `content`
- old_string: `{removes}`
- new_string: `{content}`

**For REMOVE action**:
- Edit: Remove the `removes` text
- old_string: `{removes}`
- new_string: "" (empty)

4. Track result for each edit:
```bash
applied_suggestions=()
failed_suggestions=()

# After each edit attempt:
if edit_succeeded; then
  applied_suggestions+=("${project_num}:${action}:${section}")
else
  failed_suggestions+=("${project_num}:${action}:${section}:${error_reason}")
fi
```

**Step 5.6.4: Display results of applied changes**:

```
CLAUDE.md suggestions applied: {N}
- Task #{N1}: Added {section}
- Task #{N2}: Updated {section}
- Task #{N3}: Removed {section}

{If any failed:}
Failed to apply {N} suggestions:
- Task #{N4}: Section "{section}" not found
- Task #{N5}: Text to remove not found in file

{If "Skip all" was selected:}
CLAUDE.md suggestions skipped by user: {N}
The following suggestions are available for manual review:
- Task #{N1}: ADD to {section} - {rationale}
- Task #{N2}: UPDATE {section} - {rationale}
```

**Step 5.6.5: Handle tasks with "none" action**:

For meta tasks with action "none" (or missing `claudemd_suggestions`), output brief acknowledgment:

```
Meta tasks with no CLAUDE.md changes:
- Task #{N1} ({project_name}): {rationale}
- Task #{N2} ({project_name}): No claudemd_suggestions field
```

Track suggestion operations for output reporting:
- claudemd_applied: count of successfully applied suggestions
- claudemd_failed: count of failed edit attempts
- claudemd_skipped: count of suggestions skipped by user selection
- claudemd_none_acknowledged: count of "none" action tasks acknowledged

### 5.7. Sync Repository Metrics

Update repository-wide technical debt metrics in both state.json and TODO.md header.

**Step 5.7.1: Compute current metrics**:
```bash
# Count sorries (active Theories/ files, excluding Boneyard/ and Examples/)
sorry_count=$(grep -r "sorry" Theories/ --include="*.lean" | grep -v "/Boneyard/" | grep -v "/Examples/" | wc -l)

# Count axiom declarations
axiom_count=$(grep -E "^axiom " Theories/ -r --include="*.lean" | wc -l)

# Get current timestamp
ts=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# Build errors (0 if last lake build succeeded, check for .lake/build/*)
if [ -f ".lake/build/lib/Theories.olean" ]; then
  build_errors=0
else
  build_errors=1
fi
```

**Step 5.7.2: Update state.json repository_health**:
```bash
jq --arg sorry "$sorry_count" \
   --arg axiom "$axiom_count" \
   --arg ts "$ts" \
   --arg errors "$build_errors" \
   '.repository_health = {
     "last_assessed": $ts,
     "sorry_count": ($sorry | tonumber),
     "axiom_count": ($axiom | tonumber),
     "build_errors": ($errors | tonumber),
     "status": (if ($sorry | tonumber) < 100 then "good" elif ($sorry | tonumber) < 300 then "manageable" else "concerning" end)
   }' specs/state.json > specs/state.json.tmp && mv specs/state.json.tmp specs/state.json
```

**Step 5.7.3: Update TODO.md frontmatter**:

Read TODO.md and update the YAML frontmatter `technical_debt` section to match state.json:
```bash
# Using Edit tool to update TODO.md frontmatter
# old_string: current technical_debt block
# new_string: updated technical_debt block with current values
```

The technical_debt block should be updated to:
```yaml
technical_debt:
  sorry_count: {sorry_count}
  axiom_count: {axiom_count}
  build_errors: {build_errors}
  status: {status}
```

Also update `last_assessed` in repository_health:
```yaml
repository_health:
  overall_score: 90
  production_readiness: improved
  last_assessed: {ts}
```

**Step 5.7.4: Report metrics sync**:
Track for output:
- `metrics_sorry_count`: Current sorry count
- `metrics_axiom_count`: Current axiom count
- `metrics_build_errors`: Current build errors
- `metrics_synced`: true/false indicating if sync was performed

### 5.8. Update Changelog Section

**Condition**: At least one completed task is being archived AND CHANGE_LOG.md exists

**Step 5.8.1: Check prerequisites**:
```bash
# Verify CHANGE_LOG.md exists
if [ ! -f specs/CHANGE_LOG.md ]; then
  echo "Note: specs/CHANGE_LOG.md not found (requires Task 941)"
  echo "Skipping changelog updates"
  changelog_skipped=true
else
  changelog_skipped=false
fi

# Filter only completed tasks (not abandoned)
completed_for_changelog=()
for task in "${completed_tasks[@]}"; do
  status=$(echo "$task" | jq -r '.status')
  if [ "$status" = "completed" ]; then
    completed_for_changelog+=("$task")
  fi
done

# Skip if no completed tasks
if [ ${#completed_for_changelog[@]} -eq 0 ]; then
  echo "No completed tasks to add to changelog"
  changelog_skipped=true
fi
```

**Step 5.8.2: Group completed tasks by date**:
```bash
if [ "$changelog_skipped" != "true" ]; then
  # Build date -> tasks map using arrays (bash associative arrays)
  declare -A tasks_by_date

  for task in "${completed_for_changelog[@]}"; do
    # Extract date from task completion timestamp (ISO8601 -> YYYY-MM-DD)
    completed_ts=$(echo "$task" | jq -r '.last_updated // .completed // .archived')
    date=$(echo "$completed_ts" | cut -c1-10)  # YYYY-MM-DD
    project_num=$(echo "$task" | jq -r '.project_number')
    project_name=$(echo "$task" | jq -r '.project_name')
    summary=$(echo "$task" | jq -r '.completion_summary // "Completed"')

    # Check for summary artifact
    summary_path="specs/${project_num}_${project_name}/summaries/"
    if [ -d "$summary_path" ] && [ -n "$(ls -A "$summary_path" 2>/dev/null)" ]; then
      summary_file=$(ls -t "$summary_path"/*.md 2>/dev/null | head -1)
      if [ -n "$summary_file" ]; then
        entry="- **Task ${project_num}**: ${summary} [(details)](${summary_file})"
      else
        entry="- **Task ${project_num}**: ${summary}"
      fi
    else
      entry="- **Task ${project_num}**: ${summary}"
    fi

    # Append to date's entry list
    if [ -n "${tasks_by_date[$date]}" ]; then
      tasks_by_date[$date]+=$'\n'"${entry}"
    else
      tasks_by_date[$date]="${entry}"
    fi
  done
fi
```

**Step 5.8.3: Update CHANGE_LOG.md for each date**:
```bash
changelog_entries_added=0
changelog_dates_created=0

if [ "$changelog_skipped" != "true" ]; then
  # Sort dates in reverse chronological order
  sorted_dates=($(echo "${!tasks_by_date[@]}" | tr ' ' '\n' | sort -r))

  for date in "${sorted_dates[@]}"; do
    entries="${tasks_by_date[$date]}"
    entry_count=$(echo "$entries" | wc -l)

    # Check if date header exists
    date_header="### ${date}"
    if grep -q "^${date_header}$" specs/CHANGE_LOG.md; then
      # Append after existing date header
      # Use Edit tool: find the date header line and the empty line after it
      # Insert entries between the header and existing content

      # The edit pattern: "### YYYY-MM-DD\n\n" -> "### YYYY-MM-DD\n\n{entries}\n"
      old_pattern="${date_header}"$'\n\n'
      new_pattern="${date_header}"$'\n\n'"${entries}"$'\n'

      Edit old_string: "${old_pattern}"
           new_string: "${new_pattern}"

      echo "Appended ${entry_count} entries to existing date ${date}"
    else
      # Insert new date header in reverse chronological position
      # Find first date header that is older (lexically smaller) than new date
      # Insert before that, or after ## Changelog if no older dates

      # Get existing date headers
      existing_dates=$(grep -o "^### [0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}$" specs/CHANGE_LOG.md | sed 's/^### //' | sort -r)

      insert_before=""
      for existing_date in $existing_dates; do
        if [[ "$existing_date" < "$date" ]]; then
          insert_before="### ${existing_date}"
          break
        fi
      done

      if [ -n "$insert_before" ]; then
        # Insert before older date
        new_content="${date_header}"$'\n\n'"${entries}"$'\n\n'"${insert_before}"
        Edit old_string: "${insert_before}"
             new_string: "${new_content}"
      else
        # No older dates, insert right after ## Changelog header
        old_changelog="## Changelog"$'\n\n'
        new_changelog="## Changelog"$'\n\n'"${date_header}"$'\n\n'"${entries}"$'\n\n'
        Edit old_string: "${old_changelog}"
             new_string: "${new_changelog}"
      fi

      echo "Created date header ${date} with ${entry_count} entries"
      ((changelog_dates_created++))
    fi

    changelog_entries_added=$((changelog_entries_added + entry_count))
  done
fi
```

**Step 5.8.4: Track changelog changes for reporting**:
```bash
# Store for output reporting
changelog_summary="Changelog: ${changelog_entries_added} entries added"
if [ "$changelog_dates_created" -gt 0 ]; then
  changelog_summary+=" (${changelog_dates_created} new date headers)"
fi
```

### 6. Git Commit

```bash
git add specs/
git commit -m "todo: archive {N} completed tasks"
```

Include roadmap, changelog, orphan, and misplaced counts in message as applicable:
```bash
# Build commit message dynamically based on what was updated
commit_parts=("archive {N} tasks")

# Add roadmap items if updated
if [ "$roadmap_completed_annotated" -gt 0 ] || [ "$roadmap_abandoned_annotated" -gt 0 ]; then
  R=$((roadmap_completed_annotated + roadmap_abandoned_annotated))
  commit_parts+=("update {R} roadmap items")
fi

# Add changelog entries if added
if [ "$changelog_entries_added" -gt 0 ]; then
  commit_parts+=("add {C} changelog entries")
fi

# Add orphans if tracked
if [ "$orphans_tracked" -gt 0 ]; then
  commit_parts+=("track {M} orphans")
fi

# Add misplaced if moved
if [ "$misplaced_moved" -gt 0 ]; then
  commit_parts+=("move {P} misplaced")
fi

# Join parts with commas
git commit -m "todo: $(IFS=', '; echo "${commit_parts[*]}")"

# Example outputs:
# "todo: archive 3 tasks"
# "todo: archive 3 tasks, update 2 roadmap items"
# "todo: archive 3 tasks, update 2 roadmap items, add 3 changelog entries"
# "todo: archive 3 tasks, add 2 changelog entries, track 1 orphans"
```

Where:
- `{R}` = roadmap_completed_annotated + roadmap_abandoned_annotated (total roadmap items updated)
- `{C}` = changelog_entries_added (total changelog entries added)

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

Auto-completed expanded tasks: {N}
- #{N10}: {title} ({Y} completed, {Z} abandoned)
- #{N11}: {title} ({Y} completed, {Z} abandoned)

Roadmap updated: {N} items
- Marked complete: {N}
  - {item text} (line {N})
- Marked abandoned: {N}
  - {item text} (line {N})
- Skipped (already annotated): {N}

Changelog updated: {C} entries
- {YYYY-MM-DD}: {N} entries (new date header)
- {YYYY-MM-DD}: {N} entries (appended)

CLAUDE.md suggestions applied: {N}
- Task #{N1}: Added {section}
- Task #{N2}: Updated {section}

CLAUDE.md suggestions failed: {N}
- Task #{N3}: Section not found

CLAUDE.md suggestions skipped: {N}
- Task #{N4}: Skipped by user

Meta tasks with no changes: {N}

Skipped (no directory): {N}
- Task #{N6}

Active tasks remaining: {N}

Repository metrics updated:
- sorry_count: {N}
- axiom_count: {N}
- build_errors: {N}
- last_assessed: {timestamp}

Archives: specs/archive/
```

If no orphans were tracked (either none found or user skipped):
- Omit the "Orphaned directories tracked" section

If no misplaced directories were moved (either none found or user skipped):
- Omit the "Misplaced directories moved" section

If no auto-completed expanded tasks were found (from Step 2.7):
- Omit the "Auto-completed expanded tasks" section

If no roadmap items were updated (no matches found in Step 3.5):
- Omit the "Roadmap updated" section

If no changelog entries were added (changelog_skipped=true or no completed tasks):
- Omit the "Changelog updated" section

If CHANGE_LOG.md was missing:
- Show note: "Note: specs/CHANGE_LOG.md not found (requires Task 941)"

If no CLAUDE.md suggestions were collected (no meta tasks or all had "none" action):
- Omit the "CLAUDE.md suggestions applied/failed/skipped" sections

If all CLAUDE.md suggestions were successfully applied:
- Omit the "CLAUDE.md suggestions failed" section

If no suggestions were skipped (all selected or "Skip all" not chosen):
- Omit the "CLAUDE.md suggestions skipped" section

### 7.5. Generate Task Suggestions

**Condition**: Always execute at end of /todo

This step analyzes sources and proposes 3-5 next tasks, displayed as the final output section.

**Step 7.5.1: Scan active tasks**:
```bash
# Get all active tasks
active_tasks=$(jq '.active_projects[]' specs/state.json)
active_count=$(jq '.active_projects | length' specs/state.json)

# Find unblocked tasks (no blockedBy or all deps completed)
unblocked_tasks=()
for task_json in $(jq -c '.active_projects[]' specs/state.json); do
  blocked_by=$(echo "$task_json" | jq -r '.blockedBy[]?' 2>/dev/null)

  if [ -z "$blocked_by" ]; then
    # No dependencies, check if status is not_started or researched/planned
    status=$(echo "$task_json" | jq -r '.status')
    if [ "$status" = "not_started" ] || [ "$status" = "researched" ] || [ "$status" = "planned" ]; then
      project_num=$(echo "$task_json" | jq -r '.project_number')
      project_name=$(echo "$task_json" | jq -r '.project_name')
      unblocked_tasks+=("${project_num}:${project_name}:${status}")
    fi
  fi
done

# Find stale tasks (not_started for >7 days)
stale_tasks=()
current_ts=$(date +%s)
for task_json in $(jq -c '.active_projects[]' specs/state.json); do
  status=$(echo "$task_json" | jq -r '.status')
  if [ "$status" = "not_started" ]; then
    created=$(echo "$task_json" | jq -r '.created // .last_updated // empty')
    if [ -n "$created" ]; then
      created_ts=$(date -d "$created" +%s 2>/dev/null || echo 0)
      days_old=$(( (current_ts - created_ts) / 86400 ))
      if [ "$days_old" -ge 7 ]; then
        project_num=$(echo "$task_json" | jq -r '.project_number')
        project_name=$(echo "$task_json" | jq -r '.project_name')
        stale_tasks+=("${project_num}:${project_name}:${days_old}")
      fi
    fi
  fi
done
```

**Step 7.5.2: Parse ROADMAP.md sections** (if Task 833 implemented):
```bash
# Check if Ambitions section exists
if grep -q "^## Ambitions" specs/ROAD_MAP.md; then
  # Extract unchecked criteria from Ambitions
  # Pattern: "- [ ] {criterion text}"
  ambition_unchecked=$(sed -n '/^## Ambitions/,/^## /p' specs/ROAD_MAP.md | grep -c "^[[:space:]]*- \[ \]" || echo 0)

  # Extract specific unchecked items (first 3)
  ambition_items=$(sed -n '/^## Ambitions/,/^## /p' specs/ROAD_MAP.md | grep "^[[:space:]]*- \[ \]" | head -3)
else
  ambition_unchecked=0
  ambition_items=""
fi

# Check if Strategies section exists
if grep -q "^## Strategies" specs/ROAD_MAP.md; then
  # Find ACTIVE strategies with next_steps
  # Pattern: "**Status**: ACTIVE" followed by "**Next Steps**:"
  active_strategies=$(sed -n '/^## Strategies/,/^## /p' specs/ROAD_MAP.md | grep -B5 "^\*\*Status\*\*: ACTIVE" | grep "^### " | head -3)
else
  active_strategies=""
fi
```

**Step 7.5.3: Analyze recent completions**:
```bash
# Check for follow-up patterns from just-archived tasks
follow_up_suggestions=()

# Pattern 1: If many sorries remain after implementation, suggest /learn
if [ "$metrics_sorry_count" -gt 100 ]; then
  follow_up_suggestions+=("maintenance:Consider running /learn to identify cleanup opportunities (sorry_count: ${metrics_sorry_count})")
fi

# Pattern 2: If tasks were completed in a related area, suggest next phase
# (This is contextual based on completed task summaries)
for task in "${completed_for_changelog[@]}"; do
  summary=$(echo "$task" | jq -r '.completion_summary // empty')
  # Look for patterns suggesting follow-up work
  if echo "$summary" | grep -qi "phase 1\|first step\|initial"; then
    project_num=$(echo "$task" | jq -r '.project_number')
    follow_up_suggestions+=("followup:Task ${project_num} completed initial work - check for Phase 2 tasks")
  fi
done
```

**Step 7.5.4: Generate prioritized suggestions** (max 5):
```bash
suggestions=()

# Priority 1: Unblocked tasks (ready to start)
for task_info in "${unblocked_tasks[@]}"; do
  [ ${#suggestions[@]} -ge 5 ] && break
  IFS=':' read -r num name status <<< "$task_info"
  if [ "$status" = "not_started" ]; then
    suggestions+=("**Ready to start**: Task ${num} (${name}) - Run \`/research ${num}\` to begin")
  elif [ "$status" = "researched" ]; then
    suggestions+=("**Ready to plan**: Task ${num} (${name}) - Run \`/plan ${num}\` to create implementation plan")
  elif [ "$status" = "planned" ]; then
    suggestions+=("**Ready to implement**: Task ${num} (${name}) - Run \`/implement ${num}\` to execute")
  fi
done

# Priority 2: Stale tasks (need attention)
for task_info in "${stale_tasks[@]}"; do
  [ ${#suggestions[@]} -ge 5 ] && break
  IFS=':' read -r num name days <<< "$task_info"
  suggestions+=("**Stale task**: Task ${num} (${name}) has been pending ${days} days - consider prioritizing or \`/task --abandon ${num}\`")
done

# Priority 3: Ambition progress (if section exists)
if [ "$ambition_unchecked" -gt 0 ]; then
  [ ${#suggestions[@]} -ge 5 ] || suggestions+=("**Ambition progress**: ${ambition_unchecked} unchecked criteria in Ambitions section")
fi

# Priority 4: Strategy next steps (if section exists)
if [ -n "$active_strategies" ]; then
  [ ${#suggestions[@]} -ge 5 ] || suggestions+=("**Active strategies**: Check Strategies section for next steps on active items")
fi

# Priority 5: Follow-up suggestions
for followup in "${follow_up_suggestions[@]}"; do
  [ ${#suggestions[@]} -ge 5 ] && break
  IFS=':' read -r type message <<< "$followup"
  suggestions+=("**${type^}**: ${message}")
done

# If no suggestions, default message
if [ ${#suggestions[@]} -eq 0 ]; then
  suggestions=("All tasks look good! No immediate actions needed.")
fi
```

**Step 7.5.5: Display suggestions**:
```
## Task Suggestions

Based on analysis of active tasks, ROADMAP, and recent completions:

### Recommended Next Steps

1. {suggestion 1}

2. {suggestion 2}

3. {suggestion 3}

4. {suggestion 4}

5. {suggestion 5}

---

Active tasks: {N} | Completed today: {M} | Repository health: {status}
```

If no suggestions are available (extremely rare):
```
## Task Suggestions

All looks good! No immediate actions needed.

Active tasks: {N} | Repository health: {status}
```

## Notes

### Task Archival
- Artifacts (plans, reports, summaries) are preserved in archive/{N}_{SLUG}/
- Tasks can be recovered with `/task --recover N`
- Archive is append-only (for audit trail)
- Run periodically to keep TODO.md and specs/ manageable

### Auto-Completion of Expanded Tasks

**Overview**:
When tasks are expanded into subtasks via `/task --expand N`, the parent task enters `[EXPANDED]` status. Step 2.7 automatically completes these parent tasks when all their subtasks reach terminal status.

**Trigger Conditions**:
Auto-completion triggers when ALL subtasks of an expanded task are in terminal status:
- `completed` - Subtask was successfully implemented
- `abandoned` - Subtask was abandoned via `/task --abandon`

**Handling of Missing Subtasks**:
If a subtask listed in the `subtasks[]` array is not found in either state.json or archive/state.json, it is treated as completed. This handles cases where:
- Subtask was manually deleted
- Subtask was archived in a previous session
- State file was manually edited

**Auto-Generated Completion Summary**:
When auto-completing, a `completion_summary` is generated in the format:
```
"Expanded task auto-completed: {N} subtasks completed, {M} subtasks abandoned"
```

**State Updates**:
1. **state.json**: Parent task status changes from `"expanded"` to `"completed"`, adds `completion_summary` and sets `auto_completed: true`
2. **TODO.md**: Status marker changes from `[EXPANDED]` to `[COMPLETED]`, adds Completed date

**Integration with Archival**:
Auto-completed tasks become eligible for archival in Step 3 (Prepare Archive List). They appear in both dry-run and final output with subtask breakdown.

**Example**:
Task 906 was expanded into subtasks 907-911. When all five subtasks reach terminal status (e.g., 4 completed, 1 abandoned), Task 906 is auto-completed with:
```json
{
  "status": "completed",
  "completion_summary": "Expanded task auto-completed: 4 subtasks completed, 1 subtasks abandoned",
  "auto_completed": true
}
```

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

### Interactive CLAUDE.md Application

**Overview**:
Meta tasks use `claudemd_suggestions` to propose documentation changes. Unlike ROAD_MAP.md updates (which are automatic), CLAUDE.md suggestions use interactive selection.

**Workflow**:
1. Actionable suggestions (ADD/UPDATE/REMOVE) are collected from completed meta tasks
2. User is presented with AskUserQuestion multiSelect prompt
3. Selected suggestions are applied via the Edit tool
4. Results show applied, failed, and skipped counts

**Action Types**:
- **ADD**: Inserts content after a section header
- **UPDATE**: Replaces existing text with new content
- **REMOVE**: Deletes specified text

**"Skip all" Option**:
Users can choose "Skip all" to decline automatic application. Suggestions are then displayed for manual review (preserving the previous behavior).

**Edit Failure Handling**:
If an Edit operation fails (section not found, text mismatch), the failure is logged and reported. The user can manually apply the suggestion afterward.

### Changelog Updates

**Overview**:
Step 5.8 automatically updates specs/CHANGE_LOG.md when archiving completed tasks.

**Prerequisites**:
- Task 941 must be implemented first (creates the CHANGE_LOG.md file)
- Only completed tasks are added (abandoned tasks are NOT included in Changelog)

**Entry Format**:
```markdown
### YYYY-MM-DD

- **Task {N}**: {completion_summary} [(details)](path/to/summary)
```

**Behavior**:
1. Groups completed tasks by their completion date (YYYY-MM-DD)
2. If a date header exists, appends new entries after it
3. If a date header doesn't exist, creates it in reverse chronological order
4. Optionally includes a link to the implementation summary if it exists

**Graceful Degradation**:
- If specs/CHANGE_LOG.md is missing, Step 5.8 is skipped with a note
- If no completed tasks are being archived, Step 5.8 is a no-op

**Date Extraction**:
The date is extracted from the task's `last_updated`, `completed`, or `archived` timestamp in state.json.

### Task Suggestions

**Overview**:
Step 7.5 generates 3-5 actionable task suggestions displayed at the end of /todo output.

**Sources Analyzed** (in priority order):
1. **Active tasks**: Identifies unblocked tasks ready to start
2. **Stale tasks**: Finds tasks that have been `not_started` for >7 days
3. **ROADMAP Ambitions**: Extracts unchecked success criteria (requires Task 833)
4. **ROADMAP Strategies**: Finds ACTIVE strategies with next steps (requires Task 833)
5. **Recent completions**: Identifies follow-up patterns (e.g., Phase 1 complete → check for Phase 2)

**Suggestion Priority**:
1. Unblocked tasks ready to start/plan/implement
2. Stale tasks needing attention
3. Ambition progress indicators
4. Strategy next step reminders
5. Maintenance suggestions (e.g., `/learn` for cleanup)

**Output Format**:
Follows the `/learn` command pattern with numbered recommendations and a summary line.

**Graceful Degradation**:
- If Ambitions/Strategies sections don't exist, those suggestion sources are skipped
- If no suggestions are available, displays "All looks good! No immediate actions needed."

### jq Pattern Safety (Issue #1132)

**Problem**: Claude Code Issue #1132 causes jq commands with `!=` operators to fail with `INVALID_CHARACTER` or syntax errors when Claude generates them inline.

**Solution**: This command uses safe jq patterns throughout:

1. **File-based filters** for `!=` operators:
   ```bash
   # Instead of: jq 'select(.language != "meta")' file
   cat > /tmp/filter_$$.jq << 'EOF'
   select(.language != "meta")
   EOF
   jq -f /tmp/filter_$$.jq file && rm -f /tmp/filter_$$.jq
   ```

2. **`has()` for null checks**:
   ```bash
   # Instead of: jq 'select(.field != null)'
   jq 'select(has("field"))'
   ```

3. **`del()` for exclusion filters**:
   ```bash
   # Instead of: jq '.array |= map(select(.status != "completed"))'
   jq 'del(.array[] | select(.status == "completed"))'
   ```

**Reference**: See `.claude/context/core/patterns/jq-escaping-workarounds.md` for comprehensive patterns.
