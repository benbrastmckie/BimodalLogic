# Atomic State Updates Pattern

## Overview

The atomic state updates pattern ensures both `state.json` AND `TODO.md` update together or neither (rollback on failure). This prevents the task 690 failure mode where state.json was updated but TODO.md was not.

## Key Components

### 1. Atomic Postflight Scripts

Located in `.claude/scripts/`:
- **atomic-postflight-research.sh** - Research workflow
- **atomic-postflight-plan.sh** - Planning workflow
- **atomic-postflight-implement.sh** - Implementation workflow

### 2. Python TODO.md Updater

**`.claude/scripts/update-todo-artifact.py`** - Reliable TODO.md updates with precise line insertion, replacing the fragile Edit tool.

### 3. Validation Library

**`.claude/scripts/lib/validation.sh`** - Reusable validation functions for state.json and TODO.md.

---

## Pattern Architecture

```
SKILL POSTFLIGHT LAYER (3-Stage Pattern)
│
├─ Stage 7: Atomic State Update
│  ├─ Invoke atomic-postflight-{workflow}.sh
│  ├─ Script creates backups
│  ├─ Script updates both files to temp
│  ├─ Script validates temp files
│  ├─ Script atomically replaces both (or rollback)
│  └─ On failure: restore from backups
│
├─ Stage 8: Validation Checkpoint (NEW)
│  ├─ Read-back state.json: verify status + artifact
│  ├─ Read-back TODO.md: verify status marker + link
│  ├─ Count checks: exactly one status, exactly one link
│  └─ ABORT if validation fails
│
└─ Stage 9: Conditional Git Commit (CHANGED)
   └─ Only commit if validation passed
```

---

## Usage by Workflow

### Research Workflow

```bash
# Stage 7: Atomic State Update
if [ "$status" = "researched" ]; then
    if ! .claude/scripts/atomic-postflight-research.sh \
        "$task_number" \
        "$artifact_path" \
        "$artifact_summary" \
        "$project_name"; then

        echo "ERROR: Atomic postflight failed"
        rm -f specs/.postflight-pending

        # Rollback
        if [ -f /tmp/state.json.backup ]; then
            cp /tmp/state.json.backup specs/state.json
        fi
        if [ -f /tmp/TODO.md.backup ]; then
            cp /tmp/TODO.md.backup specs/TODO.md
        fi

        return "Research completed but state update failed. Run /research ${task_number} to retry."
    fi
fi

# Stage 8: Validation
source .claude/scripts/lib/validation.sh
validate_state_json specs/state.json "$task_number" "researched" "report"
validate_todo_md specs/TODO.md "$task_number" "RESEARCHED" "Research"

# Stage 9: Conditional Commit
git add specs/state.json specs/TODO.md "specs/${task_number}_${project_name}/reports/"
git commit -m "task ${task_number}: complete research..."
```

### Planning Workflow

```bash
# Stage 7: Use atomic-postflight-plan.sh
.claude/scripts/atomic-postflight-plan.sh \
    "$task_number" "$artifact_path" "$artifact_summary" "$project_name"

# Stage 8: Validate with "planned" and "PLANNED" markers
validate_state_json specs/state.json "$task_number" "planned" "plan"
validate_todo_md specs/TODO.md "$task_number" "PLANNED" "Plan"
```

### Implementation Workflow

```bash
# Stage 7: Use atomic-postflight-implement.sh with completion data
completion_data=$(jq -c '{
  claudemd_suggestions: .claudemd_suggestions,
  roadmap_items: .roadmap_items
}' "$metadata_file")

.claude/scripts/atomic-postflight-implement.sh \
    "$task_number" \
    "$artifact_path" \
    "$artifact_summary" \
    "$project_name" \
    "$completion_summary" \
    "$completion_data"

# Stage 8: Validate with "completed" and "COMPLETED" markers
validate_state_json specs/state.json "$task_number" "completed" "summary"
validate_todo_md specs/TODO.md "$task_number" "COMPLETED" "Summary"
```

---

## Benefits

1. **Atomicity**: Both files update together or neither
2. **Validation**: Read-back verification catches silent failures
3. **Rollback**: Failed operations restore previous state
4. **Error Visibility**: Users see clear failure messages
5. **Python over Edit**: Reliable TODO.md updates with error codes

---

## Validation Functions

### validate_state_json

Validates state.json contains expected task state.

**Parameters**:
1. File path
2. Task number
3. Expected status ("researched", "planned", "completed")
4. Artifact type ("report", "plan", "summary")

**Checks**:
- JSON is valid
- Task exists
- Status matches expected
- Artifact of correct type exists

### validate_todo_md

Validates TODO.md contains expected task entry.

**Parameters**:
1. File path
2. Task number
3. Expected status marker ("[RESEARCHED]", "[PLANNED]", "[COMPLETED]")
4. Link type ("Research", "Plan", "Summary")

**Checks**:
- Task exists
- Exactly one status marker (no duplicates)
- Artifact link exists

---

## Error Handling

### Atomic Script Failure

If atomic script fails:
1. Script exits with error code
2. Temp files remain for inspection
3. Backups can be manually restored
4. User sees clear error message
5. Workflow can be retried

### Validation Failure

If validation fails after atomic update:
1. State is already updated (atomic script succeeded)
2. Validation detects inconsistency (shouldn't happen)
3. Workflow aborts without git commit
4. Manual inspection required

### Git Commit Failure

Git commit failure is non-blocking:
1. State updates are preserved
2. Failure is logged
3. User can manually commit
4. Workflow reports partial success

---

## Testing

Run comprehensive test suite:

```bash
.claude/scripts/test-postflight.sh
```

Tests cover:
- Validation functions
- Duplicate detection
- Missing link detection
- Python updater
- Invalid JSON detection
- Task not found detection

---

## Migration Guide

To migrate a skill to use atomic postflight:

### Step 1: Replace Stage 7 (State Update)

**Old pattern**:
```bash
jq ... specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json
# Use Edit tool for TODO.md
```

**New pattern**:
```bash
if ! .claude/scripts/atomic-postflight-{workflow}.sh ...; then
    # Rollback
    cp /tmp/state.json.backup specs/state.json
    cp /tmp/TODO.md.backup specs/TODO.md
    return "Error message"
fi
```

### Step 2: Add Stage 8 (Validation)

```bash
source .claude/scripts/lib/validation.sh

if ! validate_state_json specs/state.json "$task_number" "$status" "$artifact_type"; then
    return "Validation failed"
fi

if ! validate_todo_md specs/TODO.md "$task_number" "$STATUS_MARKER" "$LinkType"; then
    return "Validation failed"
fi
```

### Step 3: Update Stage 9 (Conditional Commit)

Wrap git commit in validation check - only commit if previous stage succeeded.

### Step 4: Update Stage 11 (Return Message)

Include validation status in return message:
```
- Status updated to [STATUS] (validated)
- Changes committed (${commit_status})
```

---

## Skills Updated

- ✅ skill-researcher - Completed
- ✅ skill-planner - Completed
- ⏳ skill-implementer - In progress
- ⏳ skill-lean-implementation - Pending
- ⏳ skill-latex-implementation - Pending

---

## Future Enhancements

1. **Pre-commit hook** - Validate state files before every commit
2. **Automated consistency checker** - Periodic validation of all tasks
3. **Recovery tool** - Automated repair of detected inconsistencies
4. **Metrics** - Track postflight success/failure rates

---

## References

- Original failure: Task 690 (missing TODO.md link despite state.json update)
- Implementation plan: specs/postflight-improvement-plan.md
- Test suite: .claude/scripts/test-postflight.sh
- Issue #1132: Claude Code jq escaping bug (why we use two-step pattern)
