---
name: skill-status-sync
description: Atomically update task status across state.json, TODO.md, and plan files. For standalone use only.
allowed-tools: Bash, Edit, Read
---

# Status Sync Skill (Direct Execution)

Direct execution skill for atomic status synchronization across **three files**:
1. `specs/state.json` - Machine-readable state (source of truth)
2. `specs/TODO.md` - User-facing task list
3. `specs/{N}_{SLUG}/plans/implementation-{NNN}.md` - Plan file Status field (line 4)

This skill executes inline without spawning a subagent, avoiding memory issues.

## Context References

Reference (do not load eagerly):
- Path: `.claude/context/core/patterns/jq-escaping-workarounds.md` - jq escaping patterns (Issue #1132)
- Path: `.claude/scripts/update-plan-status.sh` - Centralized plan file status update helper

## Standalone Use Only

**IMPORTANT**: This skill is for STANDALONE USE ONLY.

Workflow skills (skill-researcher, skill-planner, skill-implementer, etc.) now handle their own preflight/postflight status updates inline. This eliminates the multi-skill halt boundary problem where Claude may pause between skill invocations.

**Use this skill for**:
- Manual task status corrections
- Standalone scripts that need to update task state
- Recovery operations when workflow skills fail
- Testing status update behavior in isolation

**Do NOT use this skill in workflow commands** (/research, /plan, /implement, /revise) - those commands now invoke a single skill that handles its own status updates.

## Trigger Conditions

This skill activates when:
- Manual status correction is needed
- Artifacts need to be linked outside normal workflow
- Status synchronization recovery is needed between the three files (state.json, TODO.md, plan file)
- Plan file status is out of sync with state.json

## Three-File Synchronization

Status updates must propagate to all three files atomically:

```
state.json (1st) -> TODO.md (2nd) -> plan file (3rd)
```

**Order matters**: state.json is the source of truth. Update it first, then sync TODO.md, then sync the plan file.

### Using the Helper Script

The centralized helper script `.claude/scripts/update-plan-status.sh` updates plan file status:

```bash
# Usage: update-plan-status.sh TASK_NUMBER PROJECT_NAME NEW_STATUS
.claude/scripts/update-plan-status.sh 927 fix_status_sync "COMPLETED"
```

**Parameters**:
- `TASK_NUMBER`: Task number (required)
- `PROJECT_NAME`: Project slug, can be empty for fallback glob search
- `NEW_STATUS`: Target status marker (IMPLEMENTING, COMPLETED, PARTIAL, etc.)

**Returns**:
- Exit 0 + file path: Success, file was updated
- Exit 0 + empty: No-op (file not found or already at target)
- Exit 1: Invalid arguments

### Status Mapping

| state.json | TODO.md | Plan File |
|------------|---------|-----------|
| not_started | [NOT STARTED] | [NOT STARTED] |
| researching | [RESEARCHING] | - |
| researched | [RESEARCHED] | - |
| planning | [PLANNING] | - |
| planned | [PLANNED] | [PLANNED] |
| implementing | [IMPLEMENTING] | [IMPLEMENTING] |
| completed | [COMPLETED] | [COMPLETED] |
| partial | [PARTIAL] | [PARTIAL] |
| blocked | [BLOCKED] | [BLOCKED] |

Note: Research phase has no plan file (created during planning).

---

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

4. **Update plan file status** (if exists):
```bash
# Extract project_name from state.json
project_name=$(jq -r --argjson num "{task_number}" \
  '.active_projects[] | select(.project_number == $num) | .project_name // ""' \
  specs/state.json)

# Map status: implementing -> IMPLEMENTING
plan_status="IMPLEMENTING"  # for preflight_update

# Call helper script
.claude/scripts/update-plan-status.sh "{task_number}" "$project_name" "$plan_status"
```

**Status Mapping**:
| state.json | TODO.md | Plan File |
|------------|---------|-----------|
| not_started | [NOT STARTED] | [NOT STARTED] |
| researching | [RESEARCHING] | - |
| planning | [PLANNING] | - |
| implementing | [IMPLEMENTING] | [IMPLEMENTING] |

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

**IMPORTANT**: Use two-step jq pattern to avoid Issue #1132 escaping bug. See `jq-escaping-workarounds.md`.

```bash
# Step 1: Update timestamp
jq --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  '(.active_projects[] | select(.project_number == {task_number})) |= . + {
    last_updated: $ts
  }' specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json

# Step 2: Add artifact (append to array)
jq --arg path "{artifact_path}" \
   --arg type "{artifact_type}" \
  '(.active_projects[] | select(.project_number == {task_number})).artifacts += [{"path": $path, "type": $type}]' \
  specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json
```

3. **Update TODO.md status marker**:
   - Use Edit to change status: `[RESEARCHING]` -> `[RESEARCHED]`

4. **Link artifacts in TODO.md**:
   - Add research/plan/summary links in appropriate location

5. **Update plan file status** (if exists):
```bash
# Extract project_name from state.json
project_name=$(jq -r --argjson num "{task_number}" \
  '.active_projects[] | select(.project_number == $num) | .project_name // ""' \
  specs/state.json)

# Map status: completed -> COMPLETED, partial -> PARTIAL, etc.
case "{target_status}" in
    "completed") plan_status="COMPLETED" ;;
    "partial") plan_status="PARTIAL" ;;
    "planned") plan_status="PLANNED" ;;
    *) plan_status="" ;;  # No plan file update for research
esac

# Call helper script (if applicable)
if [ -n "$plan_status" ]; then
    .claude/scripts/update-plan-status.sh "{task_number}" "$project_name" "$plan_status"
fi
```

**Status Mapping**:
| state.json | TODO.md | Plan File |
|------------|---------|-----------|
| researched | [RESEARCHED] | - |
| planned | [PLANNED] | [PLANNED] |
| implemented | [COMPLETED] | [COMPLETED] |
| partial | [PARTIAL] | [PARTIAL] |

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

**IMPORTANT**: Use two-step jq pattern to avoid Issue #1132 escaping bug. See `jq-escaping-workarounds.md`.

```bash
# Step 1: Update timestamp
jq --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  '(.active_projects[] | select(.project_number == {task_number})) |= . + {
    last_updated: $ts
  }' specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json

# Step 2: Add artifact (append to array)
jq --arg path "{artifact_path}" \
   --arg type "{artifact_type}" \
  '(.active_projects[] | select(.project_number == {task_number})).artifacts += [{"path": $path, "type": $type}]' \
  specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json
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

### jq Parse Failure
If jq commands fail with INVALID_CHARACTER or syntax error (Issue #1132):
1. Log to errors.json with session_id and original command
2. Retry with two-step pattern from `jq-escaping-workarounds.md`
3. If retry succeeds, log recovery action

---

## Integration Notes

**For Workflow Commands**: Do NOT use this skill directly. Workflow skills now handle their own status updates inline.

**For Manual Operations**: Use this skill for standalone status corrections:

```
### Manual Status Correction
Invoke skill-status-sync with:
- operation: preflight_update or postflight_update
- task_number: {N}
- target_status: {valid_status}
- session_id: manual_correction
- artifacts: [{path, type}, ...] (for postflight only)
```

This skill ensures:
- Atomic updates across both files
- Consistent jq/Edit patterns
- Proper error handling
- Direct execution without subagent overhead
