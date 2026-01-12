---
name: skill-status-sync
description: Atomically update task status across TODO.md and state.json. Invoke when task status changes.
allowed-tools: Read, Write, Edit, Bash
# Context loaded on-demand via @-references (see Context Loading section)
---

# Status Sync Skill

Atomic status updates across TODO.md and state.json using efficient jq/grep patterns.

## API Operations

This skill exposes three primary operations for checkpoint-based execution:

| Operation | Purpose | When to Use |
|-----------|---------|-------------|
| `preflight_update` | Set in-progress status | GATE IN checkpoint |
| `postflight_update` | Set completed status + link artifacts | GATE OUT checkpoint |
| `artifact_link` | Add single artifact link (idempotent) | Post-artifact creation |

### preflight_update

**Input:**
- `task_number`: Task ID
- `target_status`: In-progress variant (researching, planning, implementing)
- `session_id`: Session identifier for traceability

**Execution:**
```bash
# Update state.json
jq --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" --arg status "$target_status" \
  '(.active_projects[] | select(.project_number == '$task_number')) |= . + {
    status: $status,
    last_updated: $ts
  }' .claude/specs/state.json > /tmp/state.json && \
  mv /tmp/state.json .claude/specs/state.json

# Update TODO.md status marker
# Use Edit tool: [OLD_STATUS] -> [NEW_STATUS]
```

**Output:**
```json
{
  "status": "completed|failed",
  "summary": "Updated task #N to [STATUS]",
  "previous_status": "not_started",
  "new_status": "researching"
}
```

### postflight_update

**Input:**
- `task_number`: Task ID
- `target_status`: Completed variant (researched, planned, completed, partial)
- `artifacts`: Array of {path, type} to link
- `session_id`: Session identifier

**Execution:**
1. Update status in state.json
2. Add artifacts to state.json artifacts array
3. Update status marker in TODO.md
4. Link each artifact in TODO.md (calls artifact_link internally)

**Output:**
```json
{
  "status": "completed|failed",
  "summary": "Updated task #N to [STATUS] with N artifacts",
  "artifacts_linked": ["path1", "path2"],
  "previous_status": "researching",
  "new_status": "researched"
}
```

### artifact_link (Idempotent)

**Input:**
- `task_number`: Task ID
- `artifact_path`: Relative path to artifact
- `artifact_type`: research | plan | summary

**Execution:**
```bash
# IDEMPOTENCY CHECK - Skip if link already exists
if grep -A 30 "^### ${task_number}\." .claude/specs/TODO.md | grep -q "$artifact_path"; then
  echo "Link already exists for $artifact_path, skipping"
  exit 0  # Success - idempotent operation
fi

# Add to state.json artifacts array
jq --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
   --arg path "$artifact_path" \
   --arg type "$artifact_type" \
  '(.active_projects[] | select(.project_number == '$task_number')) |= . + {
    last_updated: $ts,
    artifacts: ((.artifacts // []) + [{"path": $path, "type": $type}])
  }' .claude/specs/state.json > /tmp/state.json && \
  mv /tmp/state.json .claude/specs/state.json

# Add link to TODO.md using Edit tool
# Format depends on artifact_type (see Artifact Link Formats below)
```

**Output:**
```json
{
  "status": "completed|skipped",
  "summary": "Linked artifact to task #N" | "Link already exists",
  "artifact_path": "path/to/artifact.md",
  "artifact_type": "research"
}
```

---

## Context Pointers

Reference (do not load eagerly):
- Path: `.claude/context/core/validation.md`
- Purpose: Return validation at GATE OUT checkpoint
- Load at: Agent execution only

Note: This skill executes directly. It does not delegate to a subagent.

## Trigger Conditions

This skill activates when:
- Task status needs to change
- Artifacts are added to a task
- Task metadata needs updating
- New task is created
- Task is archived/abandoned

---

## Lookup Patterns (Read Operations)

### Single Task Lookup by Number

```bash
# Get full task object from state.json (~5-10ms)
task_data=$(jq -r --arg num "$task_number" \
  '.active_projects[] | select(.project_number == ($num | tonumber))' \
  .claude/specs/state.json)

# Validate task exists
if [ -z "$task_data" ]; then
  echo "Error: Task $task_number not found in state.json"
  exit 1
fi
```

### Field Extraction (from task_data)

```bash
# Extract all fields in one pass (fast, ~2-3ms each)
language=$(echo "$task_data" | jq -r '.language // "general"')
status=$(echo "$task_data" | jq -r '.status')
project_name=$(echo "$task_data" | jq -r '.project_name')
description=$(echo "$task_data" | jq -r '.description // ""')
priority=$(echo "$task_data" | jq -r '.priority')
effort=$(echo "$task_data" | jq -r '.effort // ""')
```

### Status Validation

```bash
# Check if status allows operation
if [ "$status" = "completed" ]; then
  echo "Error: Task $task_number is already completed"
  exit 1
fi

if [ "$status" = "abandoned" ]; then
  echo "Error: Task $task_number is abandoned. Use /task --recover first"
  exit 1
fi
```

### next_project_number Retrieval

```bash
# Get next available task number
next_num=$(jq -r '.next_project_number' .claude/specs/state.json)
```

### Fast Existence Check

```bash
# Returns project_number or empty (fastest, ~5ms)
exists=$(jq -r --arg num "$task_number" \
  '.active_projects[] | select(.project_number == ($num | tonumber)) | .project_number' \
  .claude/specs/state.json)

if [ -z "$exists" ]; then
  echo "Error: Task $task_number not found"
  exit 1
fi
```

---

## TODO.md Patterns (grep-based)

### Task Section Location

```bash
# Find line number where task entry starts
task_line=$(grep -n "^### ${task_number}\." .claude/specs/TODO.md | cut -d: -f1)

if [ -z "$task_line" ]; then
  echo "Error: Task $task_number not found in TODO.md"
  exit 1
fi
```

### Read Task Section (for editing)

```bash
# Read task entry (header + following lines until next ### or ---)
task_section=$(sed -n "${task_line},/^###\|^---/p" .claude/specs/TODO.md | head -n -1)
```

### Frontmatter Field Extraction

```bash
# Get next_project_number from TODO.md frontmatter
todo_next_num=$(grep "^next_project_number:" .claude/specs/TODO.md | awk '{print $2}')
```

### Priority Section Location

```bash
# Find priority section headers
high_line=$(grep -n "^## High Priority" .claude/specs/TODO.md | cut -d: -f1)
medium_line=$(grep -n "^## Medium Priority" .claude/specs/TODO.md | cut -d: -f1)
low_line=$(grep -n "^## Low Priority" .claude/specs/TODO.md | cut -d: -f1)
```

---

## Update Patterns (Write Operations)

### Status Update (Atomic)

```bash
# Update task status in state.json
jq --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" --arg status "$new_status" \
  '(.active_projects[] | select(.project_number == '$task_number')) |= . + {
    status: $status,
    last_updated: $ts
  }' .claude/specs/state.json > /tmp/state.json && \
  mv /tmp/state.json .claude/specs/state.json
```

### Artifact Addition

```bash
# Add artifact to task in state.json
jq --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
   --arg path "$artifact_path" \
   --arg type "$artifact_type" \
  '(.active_projects[] | select(.project_number == '$task_number')) |= . + {
    last_updated: $ts,
    artifacts: ((.artifacts // []) + [{"path": $path, "type": $type}])
  }' .claude/specs/state.json > /tmp/state.json && \
  mv /tmp/state.json .claude/specs/state.json
```

### TODO.md Artifact Linking (CRITICAL)

**After adding artifacts to state.json, MUST also add links to TODO.md.**

This is a two-step process:
1. Add artifact to state.json (above)
2. Add artifact link to TODO.md task entry (below)

#### Artifact Link Formats

| Type | Format in TODO.md |
|------|-------------------|
| research | `- **Research**: [research-{NNN}.md]({path})` |
| plan | `- **Plan**: [implementation-{NNN}.md]({path})` |
| summary | `- **Summary**: [implementation-summary-{DATE}.md]({path})` |

#### Finding Insertion Point

Artifact links go after the Language line and before the Description:

```bash
# Find task entry line
task_line=$(grep -n "^### ${task_number}\." .claude/specs/TODO.md | cut -d: -f1)

# Read the task section to find insertion point
# Links go after **Language**: and before **Description** or empty line before description
```

#### Adding Research Link

```bash
# Check if Research link already exists
if grep -A 20 "^### ${task_number}\." .claude/specs/TODO.md | grep -q "^\- \*\*Research\*\*:"; then
  # Update existing link (for multiple research reports, update to latest)
  # Use Edit tool to replace the line
  echo "Research link exists, updating to: $artifact_path"
else
  # Insert new Research link after Language line
  # Use Edit tool to add: - **Research**: [filename](path)
  echo "Adding Research link: $artifact_path"
fi
```

#### Adding Plan Link

```bash
# Check if Plan link already exists
if grep -A 20 "^### ${task_number}\." .claude/specs/TODO.md | grep -q "^\- \*\*Plan\*\*:"; then
  # Update existing link (for revised plans, update to latest version)
  echo "Plan link exists, updating to: $artifact_path"
else
  # Insert new Plan link after Research link (or after Language if no Research)
  echo "Adding Plan link: $artifact_path"
fi
```

#### Adding Summary Link

```bash
# Check if Summary link already exists
if grep -A 20 "^### ${task_number}\." .claude/specs/TODO.md | grep -q "^\- \*\*Summary\*\*:"; then
  # Update existing link
  echo "Summary link exists, updating to: $artifact_path"
else
  # Insert new Summary link after Plan link
  echo "Adding Summary link: $artifact_path"
fi
```

#### Link Insertion Using Edit Tool

When adding artifact links, use the Edit tool to modify TODO.md:

**For Research artifact (after Language line):**
```
old_string: "- **Language**: {lang}"
new_string: "- **Language**: {lang}\n- **Research**: [{filename}]({path})"
```

**For Plan artifact (after Research or Language):**
```
old_string: "- **Research**: [{research_file}]({research_path})"
new_string: "- **Research**: [{research_file}]({research_path})\n- **Plan**: [{filename}]({path})"
```

**For Summary artifact (after Plan):**
```
old_string: "- **Plan**: [{plan_file}]({plan_path})"
new_string: "- **Plan**: [{plan_file}]({plan_path})\n- **Summary**: [{filename}]({path})"
```

#### Multiple Artifacts Policy

When a task has multiple artifacts of the same type (e.g., research-001.md and research-002.md):
- **Show the latest artifact** in TODO.md (single link per type)
- State.json retains the full history in the artifacts array
- On new artifact creation, update the existing link rather than adding multiple

---

## Artifact Linking Verification (Defense in Depth)

After any artifact operation, verify consistency between state.json and TODO.md.

### Verify Artifact in state.json

```bash
# Check artifact exists in state.json artifacts array
artifact_exists=$(jq -r --arg path "$artifact_path" \
  '.active_projects[] | select(.project_number == '$task_number') |
   .artifacts[]? | select(.path == $path) | .path' \
  .claude/specs/state.json)

if [ -z "$artifact_exists" ]; then
  echo "WARNING: Artifact not found in state.json: $artifact_path"
fi
```

### Verify Artifact Link in TODO.md

```bash
# Check artifact link exists in TODO.md task entry
if ! grep -A 30 "^### ${task_number}\." .claude/specs/TODO.md | grep -q "$artifact_path"; then
  echo "WARNING: Artifact not linked in TODO.md: $artifact_path"
  echo "Task entry may need manual fix"
fi
```

### Full Consistency Check

```bash
# For a given task, verify all artifacts in state.json are linked in TODO.md
artifacts=$(jq -r --arg num "$task_number" \
  '.active_projects[] | select(.project_number == ($num | tonumber)) |
   .artifacts[]?.path' \
  .claude/specs/state.json)

for artifact in $artifacts; do
  if ! grep -A 30 "^### ${task_number}\." .claude/specs/TODO.md | grep -q "$artifact"; then
    echo "MISSING LINK: $artifact not linked in TODO.md for task $task_number"
  fi
done
```

### Verification Timing

Run verification:
1. **After artifact_add operation** - Immediate verification
2. **After status_update with artifact** - Verify artifact was linked
3. **On /task --sync** - Full consistency check across all tasks

### Warning vs Error Behavior

| Condition | Response |
|-----------|----------|
| Artifact missing from state.json | ERROR - data loss, halt operation |
| Artifact link missing from TODO.md | WARNING - log and continue (cosmetic) |
| Multiple verification failures | WARNING - suggest /task --sync |

Artifact link failures in TODO.md are warnings (not errors) because:
- The artifact file exists and is tracked in state.json (no data loss)
- TODO.md is user-facing view that can be manually fixed
- Blocking on cosmetic issues would frustrate users

---

### Task Creation

```bash
# Create new task in state.json (increments next_project_number)
jq --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
   --arg name "$project_name" \
   --arg desc "$description" \
   --arg lang "$language" \
   --arg prio "$priority" \
   --arg effort "$effort" \
  '.next_project_number as $num |
   .next_project_number = ($num + 1) |
   .active_projects = [{
     project_number: $num,
     project_name: $name,
     type: "feature",
     phase: "not_started",
     status: "not_started",
     priority: $prio,
     language: $lang,
     created: $ts,
     last_updated: $ts,
     effort: $effort,
     description: $desc
   }] + .active_projects' \
  .claude/specs/state.json > /tmp/state.json && \
  mv /tmp/state.json .claude/specs/state.json
```

### Task Archival

```bash
# Move task from active_projects (removes from active list)
# Note: Full archival also requires updating archive/state.json
jq '(.active_projects[] | select(.project_number == '$task_number')) |= . + {
    status: "abandoned",
    abandoned: "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"
  }' .claude/specs/state.json > /tmp/state.json && \
  mv /tmp/state.json .claude/specs/state.json
```

---

## Frontmatter Sync (Critical)

When creating tasks, `next_project_number` MUST be updated in BOTH files:

### state.json Update
Handled by the Task Creation jq pattern above (automatically increments).

### TODO.md Frontmatter Update

```bash
# Update next_project_number in YAML frontmatter
new_num=$((current_num + 1))
sed -i "s/^next_project_number: [0-9]*/next_project_number: $new_num/" \
  .claude/specs/TODO.md
```

### Consistency Verification

```bash
# Verify both files have matching next_project_number
state_num=$(jq -r '.next_project_number' .claude/specs/state.json)
todo_num=$(grep "^next_project_number:" .claude/specs/TODO.md | awk '{print $2}')

if [ "$state_num" != "$todo_num" ]; then
  echo "ERROR: next_project_number mismatch - state.json: $state_num, TODO.md: $todo_num"
  exit 1
fi
```

---

## Two-Phase Commit Pattern

### Phase 1: Prepare

1. **Read Current State**
   ```bash
   task_data=$(jq -r --arg num "$task_number" \
     '.active_projects[] | select(.project_number == ($num | tonumber))' \
     .claude/specs/state.json)
   task_line=$(grep -n "^### ${task_number}\." .claude/specs/TODO.md | cut -d: -f1)
   ```

2. **Validate Task Exists**
   - Check task_data is not empty (state.json)
   - Check task_line is found (TODO.md)
   - If not in both: Error

3. **Prepare Updates**
   - Calculate new status
   - Prepare jq command for state.json
   - Prepare Edit for TODO.md task entry
   - For create operations: also prepare frontmatter update

### Phase 2: Commit

1. **Write state.json First** (machine state is source of truth)
2. **Write TODO.md Second** (user-facing representation)
3. **Verify Both Updated** (re-read and confirm)

### Rollback (if needed)

If any write fails:
1. Log the failure
2. Attempt to restore original state
3. Return error with details

---

## Status Mapping

| Operation | Old Status | New Status | state.json field |
|-----------|------------|------------|------------------|
| Start research | not_started | researching | status |
| Complete research | researching | researched | status |
| Start planning | researched/not_started | planning | status |
| Complete planning | planning | planned | status, plan_version |
| Start implement | planned | implementing | status |
| Complete implement | implementing | completed | status, completed |
| Block task | any | blocked | status, blocked_reason |
| Abandon task | any | abandoned | status, abandoned |
| Expand task | any (non-terminal) | expanded | status, subtasks |

---

## Execution Flow

```
1. Receive update request:
   - task_number (required)
   - operation: status_update | artifact_add | task_create | task_archive
   - new_status (for status_update)
   - artifact_path, artifact_type (for artifact_add)
   - task metadata (for task_create)

2. Phase 1 - Prepare:
   - Use jq to read task from state.json
   - Use grep to locate task in TODO.md
   - Validate task exists (or doesn't for create)
   - Prepare update commands

3. Phase 2 - Commit:
   - Execute jq update on state.json
   - Execute Edit on TODO.md
   - For creates: also update frontmatter
   - Verify success

4. Return result
```

---

## Return Format

```json
{
  "status": "completed|failed",
  "summary": "Updated task #N to [STATUS]",
  "task_number": N,
  "old_status": "previous",
  "new_status": "current",
  "files_updated": [
    ".claude/specs/state.json",
    ".claude/specs/TODO.md"
  ]
}
```

---

## Error Handling

### File Read Error
```json
{
  "status": "failed",
  "error": "Could not read state.json",
  "recovery": "Check file exists and permissions"
}
```

### Task Not Found
```json
{
  "status": "failed",
  "error": "Task #N not found",
  "recovery": "Verify task number, check if archived"
}
```

### Write Failure
```json
{
  "status": "failed",
  "error": "Failed to write TODO.md",
  "recovery": "Check permissions, state.json may be updated"
}
```

### Inconsistency Detected
```json
{
  "status": "failed",
  "error": "TODO.md and state.json inconsistent",
  "recovery": "Run /task --sync to reconcile"
}
```

### Frontmatter Mismatch
```json
{
  "status": "failed",
  "error": "next_project_number mismatch between files",
  "recovery": "Manually sync or run /task --sync"
}
```

---

## Integration Notes

Command files should use this skill for ALL status updates:

```
# In command file documentation:
### Update Status
Invoke skill-status-sync with:
- task_number: {N}
- operation: status_update
- new_status: {target_status}
```

This ensures:
- Atomic updates across both files
- Consistent jq/grep patterns
- Proper error handling
- Frontmatter sync for creates
