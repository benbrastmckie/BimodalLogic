# Implementation Summary: Fix /revise Command Plan Link Replacement

## What Was Implemented

Added plan link replacement logic to status-sync-manager to replace old plan links instead of appending new ones when `/revise` is executed.

## Files Modified

- `.opencode/agent/subagents/status-sync-manager.md` - Added artifact link update logic with plan link replacement algorithm

## Key Changes

1. **Artifact Type Detection**: Added logic to detect artifact type (plan vs. research vs. implementation) from validated_artifacts array
2. **Plan Link Replacement Mode**: When artifact type is "plan", use replacement mode instead of append mode
3. **Regex-based Search**: Search for existing plan link using pattern `^- \*\*Plan\*\*:.*$`
4. **Atomic Replacement**: Replace entire plan link line with new plan link (removes appended links)
5. **Edge Case Handling**: Handle no existing plan, malformed links, multiple appended links, and deleted plan files

## Algorithm

1. Detect plan artifact from validated_artifacts
2. Search for existing plan link in TODO.md task entry
3. If found: Replace entire line with new plan link
4. If not found: Append new plan link (first plan creation)
5. Validate replacement succeeded

## Testing Recommendations

1. Test initial plan creation (no existing plan)
2. Test plan revision (existing plan link replaced)
3. Test multiple revisions (link replaced each time)
4. Test edge case: multiple appended links (task 283)
5. Test edge case: malformed plan link
6. Verify old plan files preserved on disk
