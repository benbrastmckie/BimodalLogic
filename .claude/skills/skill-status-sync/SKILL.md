---
name: skill-status-sync
description: Atomically update task status across TODO.md and state.json. Invoke when task status changes.
allowed-tools: Read, Write, Edit, Bash
context:
  - .claude/context/core/orchestration/state-management.md
  - .claude/context/core/orchestration/state-lookup.md
---

# Status Sync Skill

Atomic status updates across TODO.md and state.json using efficient jq/grep patterns.

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
