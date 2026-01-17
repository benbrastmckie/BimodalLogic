---
name: skill-status-sync
description: Atomically update task status across TODO.md and state.json. Invoke when task status changes.
allowed-tools: Bash, Edit, Read
---

# Status Sync Skill (Direct Execution)

Direct execution skill for atomic status synchronization across TODO.md and state.json. This skill executes inline without spawning a subagent, avoiding memory issues.

## Trigger Conditions

This skill activates when:
- Task status needs to change (preflight/postflight updates)
- Artifacts are added to a task
- Status synchronization is needed between TODO.md and state.json

## API Operations

This skill exposes three primary operations:

| Operation | Purpose | When to Use |
|-----------|---------|-------------|
| `preflight_update` | Set in-progress status | GATE IN checkpoint |
| `postflight_update` | Set final status + link artifacts | GATE OUT checkpoint |
| `artifact_link` | Add single artifact link (idempotent) | Post-artifact creation |

---

## Execution

### 1. Input Validation

Validate required inputs based on operation type:

**For preflight_update**:
- `task_number` - Must be provided and exist in state.json
- `target_status` - Must be an in-progress variant (researching, planning, implementing)
- `session_id` - Must be provided for traceability

**For postflight_update**:
- `task_number` - Must be provided and exist
- `target_status` - Must be a final variant (researched, planned, implemented, partial)
- `artifacts` - Array of {path, type} to link
- `session_id` - Must be provided

**For artifact_link**:
- `task_number` - Must be provided and exist
- `artifact_path` - Relative path to artifact
- `artifact_type` - One of: research, plan, summary

### 2. Execute Operation Directly

Route to appropriate operation and execute using Bash (jq) and Edit tools.

---

## Operation: preflight_update

**Purpose**: Set in-progress status at GATE IN checkpoint

**Execution**:

1. **Validate task exists**:
```bash
task_data=$(jq -r --arg num "{task_number}" \
  '.active_projects[] | select(.project_number == ($num | tonumber))' \
  specs/state.json)

if [ -z "$task_data" ]; then
  echo "Error: Task {task_number} not found"
  exit 1
fi
```

2. **Update state.json**:
```bash
jq --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" --arg status "{target_status}" \
  '(.active_projects[] | select(.project_number == {task_number})) |= . + {
    status: $status,
    last_updated: $ts
  }' specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json
```

3. **Update TODO.md status marker**:
   - Find task entry: `grep -n "^### {task_number}\." specs/TODO.md`
   - Use Edit tool to change `[OLD_STATUS]` to `[NEW_STATUS]`

**Status Mapping**:
| state.json | TODO.md |
|------------|---------|
| not_started | [NOT STARTED] |
| researching | [RESEARCHING] |
| planning | [PLANNING] |
| implementing | [IMPLEMENTING] |

**Return**: JSON object with status "synced" and previous/new status fields.

---

## Operation: postflight_update

**Purpose**: Set final status and link artifacts at GATE OUT checkpoint

**Execution**:

1. **Update state.json status and timestamp**:
```bash
jq --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" --arg status "{target_status}" \
  '(.active_projects[] | select(.project_number == {task_number})) |= . + {
    status: $status,
    last_updated: $ts
  }' specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json
```

2. **Add artifacts to state.json** (for each artifact):
```bash
jq --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
   --arg path "{artifact_path}" \
   --arg type "{artifact_type}" \
  '(.active_projects[] | select(.project_number == {task_number})) |= . + {
    last_updated: $ts,
    artifacts: ((.artifacts // []) + [{"path": $path, "type": $type}])
  }' specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json
```

3. **Update TODO.md status marker**:
   - Use Edit to change status: `[RESEARCHING]` -> `[RESEARCHED]`

4. **Link artifacts in TODO.md**:
   - Add research/plan/summary links in appropriate location

**Status Mapping**:
| state.json | TODO.md |
|------------|---------|
| researched | [RESEARCHED] |
| planned | [PLANNED] |
| implemented | [IMPLEMENTED] |
| partial | [PARTIAL] |

**Return**: JSON object with target_status and artifacts_linked fields.

---

## Operation: artifact_link

**Purpose**: Add single artifact link (idempotent)

**Execution**:

1. **Idempotency check**:
```bash
if grep -A 30 "^### {task_number}\." specs/TODO.md | grep -q "{artifact_path}"; then
  echo "Link already exists"
  # Return "skipped" status
fi
```

2. **Add to state.json artifacts array**:
```bash
jq --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
   --arg path "{artifact_path}" \
   --arg type "{artifact_type}" \
  '(.active_projects[] | select(.project_number == {task_number})) |= . + {
    last_updated: $ts,
    artifacts: ((.artifacts // []) + [{"path": $path, "type": $type}])
  }' specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json
```

3. **Add link to TODO.md** using Edit tool:

| Type | Format in TODO.md |
|------|-------------------|
| research | `- **Research**: [research-{NNN}.md]({path})` |
| plan | `- **Plan**: [implementation-{NNN}.md]({path})` |
| summary | `- **Summary**: [implementation-summary-{DATE}.md]({path})` |

**Insertion order**:
- research: after Language line
- plan: after Research line (or Language if no Research)
- summary: after Plan line

**Return**: JSON object with status "linked" or "skipped".

---

## Return Format

### preflight_update returns:
```json
{
  "status": "synced",
  "summary": "Updated task #{N} to [{STATUS}]",
  "previous_status": "not_started",
  "new_status": "researching"
}
```

### postflight_update returns:
```json
{
  "status": "{target_status}",
  "summary": "Updated task #{N} to [{STATUS}] with {M} artifacts",
  "artifacts_linked": ["path1", "path2"],
  "previous_status": "researching",
  "new_status": "researched"
}
```

### artifact_link returns:
```json
{
  "status": "linked|skipped",
  "summary": "Linked artifact to task #{N}" | "Link already exists",
  "artifact_path": "path/to/artifact.md",
  "artifact_type": "research"
}
```

---

## Error Handling

### Task Not Found
Return failed status with recommendation to verify task number.

### Invalid Status Transition
Return failed status with current status and allowed transitions.

### File Write Failure
Return failed status with recommendation to check permissions.

---

## Integration Notes

Command files should use this skill for ALL status updates:

```
### Preflight (GATE IN)
Invoke skill-status-sync with:
- operation: preflight_update
- task_number: {N}
- target_status: researching|planning|implementing
- session_id: {session_id}

### Postflight (GATE OUT)
Invoke skill-status-sync with:
- operation: postflight_update
- task_number: {N}
- target_status: researched|planned|implemented|partial
- artifacts: [{path, type}, ...]
- session_id: {session_id}
```

This ensures:
- Atomic updates across both files
- Consistent jq/Edit patterns
- Proper error handling
- Direct execution without subagent overhead
