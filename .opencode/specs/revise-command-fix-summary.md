# /revise Command Non-Interactive Fix - Summary

## Issue
The `/revise` command was asking for user input when revising tasks without plans, requiring confirmation at multiple stages instead of executing the user's request directly.

## Solution Implemented

### 1. Added `update_task_metadata` Operation to status-sync-manager

**File**: `.opencode/agent/subagents/status-sync-manager.md`

**Changes**:
- Added `update_task_metadata` to operation enum
- Added `updated_fields` parameter for specifying which fields to update
- Created `update_task_metadata_flow` with 3 steps:
  1. Validate inputs (task exists, fields valid)
  2. Prepare and commit updates atomically
  3. Return success with updated fields
- Added example output for the new operation
- Updated operation routing to include new operation

**Atomic Update Pattern**:
- Writes to temp files first
- Atomic rename (both files or neither)
- Automatic rollback on failure
- No backup files (git-only recovery)

### 2. Refactored task-reviser to Parse Revision Requests

**File**: `.opencode/agent/subagents/task-reviser.md`

**Changes**:
- **Removed** interactive steps:
  - `step_1_display_current_metadata` (displayed current values)
  - `step_2_prompt_for_revisions` (prompted for each field)
  - `step_3_confirm_changes` (asked for confirmation)

- **Added** non-interactive steps:
  - `step_1_parse_revision_request` - Parses user's revision request
  - `step_2_validate_changes` - Validates parsed changes
  - `step_3_prepare_update` - Prepares update with only changed fields

**Parsing Logic**:
```
User input: "Update description to X and change priority to High"
Parsed: {description: "X", priority: "High"}

User input: "Change priority to High"
Parsed: {priority: "High"}

User input: "Add dependency on task 320"
Parsed: {dependencies: [320]}
```

**Validation**:
- Description: 50-500 characters
- Priority: Low|Medium|High (case-insensitive, normalized)
- Effort: Valid format (number + time unit)
- Dependencies: All task numbers must exist

## Usage

### Before (Interactive)
```bash
/revise 326
# Prompts: "Enter new description..."
# User types description
# Prompts: "Enter new priority..."
# User types priority
# Prompts: "Confirm these changes? (yes/no)"
# User types "yes"
```

### After (Non-Interactive)
```bash
/revise 326 "Update description to clarify scope and change priority to High"
# Executes immediately
# No prompts
# Returns success
```

## Examples

```bash
# Update description only
/revise 326 "Update description to add more details"

# Update priority only
/revise 326 "Change priority to High"

# Update multiple fields
/revise 326 "Update description to X, priority to High, effort to 4 hours"

# Update dependencies
/revise 326 "Add dependency on task 320"
```

## Verification

All changes verified:
- ✅ 8 references to `update_task_metadata` in status-sync-manager
- ✅ 2 references to `parse_revision_request` in task-reviser
- ✅ 0 references to `prompt_for_revisions` (removed)
- ✅ 0 references to `confirm_changes` (removed)
- ✅ Operation routing includes `update_task_metadata`
- ✅ Atomic update pattern implemented
- ✅ Example output added

## Benefits

1. **Non-Interactive**: No user prompts or confirmations
2. **Atomic Updates**: Both TODO.md and state.json updated together
3. **Flexible Parsing**: Natural language revision requests
4. **Validation**: All changes validated before applying
5. **Rollback**: Automatic rollback on failure
6. **Consistent**: Follows same pattern as other operations

## Testing

Test with:
```bash
/revise 326 "Update description to clarify the --divide flag functionality"
```

Expected behavior:
- Parses description from request
- Validates description (50-500 chars)
- Updates TODO.md and state.json atomically
- Returns success without prompts

## Files Modified

1. `.opencode/agent/subagents/status-sync-manager.md` - Added update_task_metadata operation
2. `.opencode/agent/subagents/task-reviser.md` - Refactored to non-interactive parsing

## Documentation

Created:
- `.opencode/specs/revise-command-non-interactive-fix.md` - Detailed fix documentation
- `.opencode/specs/revise-command-fix-summary.md` - This summary

## Status

✅ **COMPLETE** - Ready for testing
