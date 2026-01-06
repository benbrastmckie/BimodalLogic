# Fix: Make /revise Command Non-Interactive

## Problem

The `/revise` command (when used on tasks without plans) was asking for user confirmation at multiple stages:

1. Prompting for each field to change (description, priority, effort, dependencies)
2. Asking user to confirm changes before applying
3. Requiring interactive input instead of executing the user's request directly

This violated the principle that commands should execute the user's request without requiring confirmation, relying on the user to specify exactly what to do when using the command.

## Root Cause

The `task-reviser` subagent (`.opencode/agent/subagents/task-reviser.md`) was designed with an interactive workflow:

- **Step 2**: `step_2_prompt_for_revisions` - Prompted user for each field
- **Step 3**: `step_3_confirm_changes` - Asked user to confirm changes

Additionally, the `task-reviser` was trying to call a `status-sync-manager` operation (`update_task_metadata`) that didn't exist.

## Solution

### 1. Added `update_task_metadata` Operation to status-sync-manager

Added a new operation to `.opencode/agent/subagents/status-sync-manager.md`:

**Operation**: `update_task_metadata`

**Purpose**: Atomically update task metadata fields (description, priority, effort, dependencies) in both TODO.md and state.json

**Inputs**:
- `task_number`: Task to update
- `updated_fields`: Object with fields to update (only changed fields)
- `session_id`, `delegation_depth`, `delegation_path`: Standard delegation parameters

**Process**:
1. Validate inputs (task exists, fields valid)
2. Prepare updates in memory (TODO.md and state.json)
3. Commit atomically using atomic write pattern (temp files + rename)
4. Return success with updated fields

**Example Return**:
```json
{
  "status": "completed",
  "summary": "Atomically updated task 326 metadata: description, priority",
  "files_updated": [".opencode/specs/TODO.md", ".opencode/specs/state.json"],
  "metadata": {
    "updated_fields": ["description", "priority"]
  }
}
```

### 2. Refactored task-reviser to Parse Revision Request

Changed `task-reviser` workflow from interactive to non-interactive:

**Old Workflow**:
1. Display current metadata
2. Prompt for each field (interactive)
3. Confirm changes (interactive)
4. Delegate to status-sync-manager

**New Workflow**:
1. **Parse revision request** from `revision_context` parameter
   - Extract requested changes from user's prompt
   - Example: "Update description to X" → `{description: "X"}`
   - Example: "Change priority to High and effort to 4 hours" → `{priority: "High", effort: "4 hours"}`
2. **Validate changes** against task standards
   - Description: 50-500 characters
   - Priority: Low|Medium|High
   - Effort: Valid format
   - Dependencies: All tasks exist
3. **Prepare update** with only changed fields
   - Compare new values with current values
   - Build `updated_fields` object
4. **Delegate to status-sync-manager** with `operation=update_task_metadata`
5. **Return success** with updated fields

**Parsing Logic**:
- Looks for keywords: "description", "priority", "effort", "dependencies"
- Extracts values from context
- If no specific changes detected: Uses entire context as description update
- Validates all extracted values before proceeding

### 3. Updated Operation Routing

Modified `status-sync-manager` operation routing to include new operation:

```
1. If operation == "create_task": Execute create_task_flow
2. If operation == "archive_tasks": Execute archive_tasks_flow
3. If operation == "update_task_metadata": Execute update_task_metadata_flow  ← NEW
4. If operation == "update_status" or not specified: Execute update_status_flow (default)
```

## Usage

### Before (Interactive)
```bash
/revise 326
# Prompts: "Enter new description (50-500 characters), or press Enter to keep current:"
# User types: "Updated description"
# Prompts: "Enter new priority (Low/Medium/High), or press Enter to keep current:"
# User types: "High"
# Prompts: "Confirm these changes? (yes/no):"
# User types: "yes"
```

### After (Non-Interactive)
```bash
/revise 326 "Update description to clarify scope and change priority to High"
# Executes immediately without prompts
# Parses: description = "clarify scope", priority = "High"
# Updates atomically
# Returns success
```

## Benefits

1. **Non-Interactive**: No user prompts or confirmations required
2. **Atomic Updates**: Both TODO.md and state.json updated together or not at all
3. **Flexible Parsing**: Supports natural language revision requests
4. **Validation**: All changes validated before applying
5. **Rollback**: Automatic rollback on failure (via atomic write pattern)

## Testing

Test the fix with:

```bash
# Update description only
/revise 326 "Update description to add more details about the feature"

# Update priority only
/revise 326 "Change priority to High"

# Update multiple fields
/revise 326 "Update description to X, change priority to High, and set effort to 4 hours"

# Update dependencies
/revise 326 "Add dependency on task 320"
```

## Files Modified

1. `.opencode/agent/subagents/status-sync-manager.md`:
   - Added `update_task_metadata` parameter to `operation` enum
   - Added `updated_fields` parameter
   - Added `update_task_metadata_flow` section
   - Updated operation routing
   - Added example output for `update_task_metadata`

2. `.opencode/agent/subagents/task-reviser.md`:
   - Replaced `step_1_display_current_metadata` with `step_1_parse_revision_request`
   - Replaced `step_2_prompt_for_revisions` with `step_2_validate_changes`
   - Replaced `step_3_confirm_changes` with `step_3_prepare_update`
   - Updated `step_4_delegate_to_status_sync` to use `operation=update_task_metadata`

## Validation

The fix ensures:
- ✅ No user prompts or confirmations
- ✅ Atomic updates (both files or neither)
- ✅ Proper validation before updates
- ✅ Clear error messages on failure
- ✅ Automatic rollback on failure
- ✅ Standardized return format

## Next Steps

1. Test the fix with various revision requests
2. Verify atomic updates work correctly
3. Verify parsing handles edge cases (vague requests, multiple fields, etc.)
4. Update documentation if needed
