# Research Report: Fix /revise Command Plan Link Replacement

## Metadata

- **Task**: 287 - Fix /revise command to replace old plan link instead of appending new link
- **Started**: 2026-01-04
- **Completed**: 2026-01-04
- **Effort**: 1 hour
- **Priority**: Medium
- **Dependencies**: None
- **Sources/Inputs**:
  - `.opencode/command/revise.md` - /revise command specification
  - `.opencode/agent/subagents/planner.md` - Planner subagent specification
  - `.opencode/agent/subagents/status-sync-manager.md` - Status synchronization logic
  - `specs/TODO.md` - Task 283 example showing appended plan links
- **Artifacts**:
  - `specs/287_fix_revise_command_plan_link_replacement/reports/research-001.md` (this report)
- **Standards**: status-markers.md, artifact-management.md, tasks.md, report.md

## Executive Summary

Research into the `/revise` command plan link behavior reveals that when a task already has a plan and `/revise` is executed, the new plan link is **appended** to the existing plan link instead of **replacing** it. This creates confusing entries like:

```markdown
- **Plan**: [Implementation Plan v1](283_.../plans/implementation-001.md) | [Implementation Plan v2](283_.../plans/implementation-002.md) (current)
```

The root cause is in the **status-sync-manager** artifact link update logic (step_3_prepare_updates), which does not distinguish between "add new artifact link" and "replace existing artifact link of same type". The fix requires adding plan link replacement logic to status-sync-manager that:

1. Detects when new artifact is a plan (type: "plan")
2. Searches for existing `- **Plan**:` line in TODO.md task entry
3. Replaces entire line with new plan link (not appends)
4. Preserves old plan file on disk for reference

**Estimated effort**: 2-3 hours (medium complexity - requires careful regex replacement in status-sync-manager).

## Context & Scope

### Problem Statement

When running `/revise` for a task that already has a plan, the command appends the new plan link to the existing plan link instead of replacing it. This violates the principle that TODO.md should show only the **current** plan, with old plans preserved in the project directory for reference.

### Current Behavior (Incorrect)

```markdown
# Before /revise:
- **Plan**: [Implementation Plan](283_fix_systematic_status_synchronization_failure/plans/implementation-001.md)

# After /revise:
- **Plan**: [Implementation Plan v1](283_fix_systematic_status_synchronization_failure/plans/implementation-001.md) | [Implementation Plan v2](283_fix_systematic_status_synchronization_failure/plans/implementation-002.md) (current)
```

### Expected Behavior (Correct)

```markdown
# Before /revise:
- **Plan**: [Implementation Plan](283_fix_systematic_status_synchronization_failure/plans/implementation-001.md)

# After /revise:
- **Plan**: [Implementation Plan](283_fix_systematic_status_synchronization_failure/plans/implementation-002.md)

# Old plan file still exists at:
# specs/283_fix_systematic_status_synchronization_failure/plans/implementation-001.md
```

### Scope

**In Scope**:
- Fix status-sync-manager to replace plan links instead of appending
- Preserve old plan files on disk (no deletion)
- Update only TODO.md plan link (state.json already tracks plan_path correctly)
- Support both initial plan creation and plan revision

**Out of Scope**:
- Changing plan file naming convention (implementation-NNN.md)
- Modifying plan version history in state.json (already correct)
- Deleting old plan files (they should be preserved)
- Changing /revise command workflow (only status-sync-manager needs changes)

## Key Findings

### Finding 1: Root Cause is in status-sync-manager

**Location**: `.opencode/agent/subagents/status-sync-manager.md`, step_3_prepare_updates

**Current Logic** (lines 165-189):
```markdown
2. Update specs/TODO.md task entry in memory:
   - Change status marker
   - Add/update timestamp fields
   - Add artifact links from validated_artifacts
   - Add blocking/abandonment reason if applicable
   - Add checkmark to title if completed
```

The logic says "Add artifact links" but does NOT specify:
- How to detect if artifact link already exists
- How to replace existing link vs. append new link
- How to handle plan links differently from research/implementation links

**Evidence**: Task 283 in TODO.md shows appended plan links (line 41 and 1358):
```markdown
- **Plan**: [Implementation Plan v1](283_.../plans/implementation-001.md) | [Implementation Plan v2](283_.../plans/implementation-002.md) (current)
```

### Finding 2: Planner Correctly Creates New Plan Files

**Location**: `.opencode/agent/subagents/planner.md`, step_5

**Current Logic** (lines 221-243):
```markdown
4. Generate plan filename: plans/implementation-{version:03d}.md
5. Populate plan sections:
   - Metadata (task, status, effort, language, etc.)
   - Overview (problem, scope, constraints, definition of done)
   - Goals and Non-Goals
   - Risks and Mitigations
   - Implementation Phases (each phase with [NOT STARTED] marker)
   - Testing and Validation
   - Artifacts and Outputs
   - Rollback/Contingency
   - Success Metrics
```

The planner correctly:
- Creates new plan file with incremented version number (001, 002, 003, etc.)
- Preserves old plan files (never modifies them)
- Returns new plan path in validated_artifacts

**Conclusion**: Planner is working correctly. The issue is in status-sync-manager's artifact link update logic.

### Finding 3: state.json Correctly Tracks plan_path

**Location**: `.opencode/agent/subagents/status-sync-manager.md`, plan_version_history section (lines 496-573)

**Current Logic**:
```markdown
<plan_revision>
  When plan is revised:
  1. Append new entry to plan_versions array
  2. Increment version number
  3. Include revision_reason from /revise command
  4. Update plan_path to new version
  5. Preserve all previous versions
</plan_revision>
```

**Evidence**: state.json correctly tracks plan_path and plan_versions:
```json
{
  "plan_path": "specs/283_.../plans/implementation-002.md",
  "plan_versions": [
    {
      "version": 1,
      "path": "plans/implementation-001.md",
      "created": "2026-01-04T06:00:00Z",
      "reason": "Initial implementation plan"
    },
    {
      "version": 2,
      "path": "plans/implementation-002.md",
      "created": "2026-01-04T07:00:00Z",
      "reason": "Revised to fix naming inconsistency"
    }
  ]
}
```

**Conclusion**: state.json is working correctly. Only TODO.md plan link needs fixing.

### Finding 4: Artifact Link Types

**Research Artifacts**:
- `- **Research**: [Research Report](path/to/research-001.md)` (can have multiple)

**Plan Artifacts**:
- `- **Plan**: [Implementation Plan](path/to/implementation-001.md)` (should have only ONE - current plan)

**Implementation Artifacts**:
- `- **Implementation**: [Implementation Summary](path/to/implementation-summary.md)` (can have multiple)

**Key Insight**: Plan links should be **replaced** (only current plan shown), while research and implementation links should be **appended** (all artifacts shown).

### Finding 5: No Existing Replacement Logic

**Search Results**: Searched status-sync-manager.md for "replace", "existing", "current plan" - no logic found for detecting and replacing existing artifact links.

**Current Implementation**: status-sync-manager appends all artifact links without checking for duplicates or existing links of the same type.

**Gap**: Need to add replacement logic specifically for plan artifacts.

## Detailed Analysis

### Artifact Link Update Flow

**Current Flow** (Incorrect for Plans):
1. Planner creates new plan file (implementation-002.md)
2. Planner returns validated_artifacts with new plan path
3. status-sync-manager receives validated_artifacts
4. status-sync-manager appends new plan link to TODO.md task entry
5. Result: Both old and new plan links shown (confusing)

**Desired Flow** (Correct for Plans):
1. Planner creates new plan file (implementation-002.md)
2. Planner returns validated_artifacts with new plan path
3. status-sync-manager receives validated_artifacts
4. status-sync-manager detects artifact type is "plan"
5. status-sync-manager searches for existing `- **Plan**:` line
6. status-sync-manager replaces entire line with new plan link
7. Result: Only current plan link shown (clear)

### Implementation Approach

**Option 1: Add Replacement Logic to status-sync-manager** (Recommended)

**Pros**:
- Centralized logic in one place (status-sync-manager)
- Works for all commands that update plan links (/plan, /revise)
- Consistent with status-sync-manager's role (atomic multi-file updates)

**Cons**:
- Requires careful regex replacement to avoid breaking TODO.md format
- Need to handle edge cases (no existing plan, malformed plan link, etc.)

**Option 2: Add Replacement Logic to Planner**

**Pros**:
- Planner already knows about plan versioning

**Cons**:
- Violates separation of concerns (planner should create plans, not update TODO.md)
- Duplicates logic between planner and status-sync-manager
- Breaks atomic update pattern (status-sync-manager owns TODO.md updates)

**Recommendation**: Option 1 (status-sync-manager) is architecturally correct.

### Replacement Algorithm

**Step 1: Detect Plan Artifact**
```
IF validated_artifacts contains artifact with type == "plan":
  plan_replacement_mode = true
  new_plan_path = artifact.path
```

**Step 2: Search for Existing Plan Link**
```
Read TODO.md task entry
Search for line matching pattern: ^- \*\*Plan\*\*:
IF found:
  existing_plan_line = matched line
  replacement_needed = true
ELSE:
  replacement_needed = false (first plan)
```

**Step 3: Replace or Append**
```
IF replacement_needed:
  Replace existing_plan_line with:
  - **Plan**: [Implementation Plan]({new_plan_path})
ELSE:
  Append new line:
  - **Plan**: [Implementation Plan]({new_plan_path})
```

**Step 4: Validate Replacement**
```
Verify new plan link exists in TODO.md
Verify old plan link removed (if replacement occurred)
Verify old plan file still exists on disk
```

### Edge Cases

**Edge Case 1: No Existing Plan**
- **Scenario**: First plan created with /plan command
- **Handling**: Append plan link (no replacement needed)
- **Test**: Create plan for task with no existing plan

**Edge Case 2: Malformed Existing Plan Link**
- **Scenario**: Plan link manually edited and malformed
- **Handling**: Log warning, append new plan link (don't break TODO.md)
- **Test**: Manually corrupt plan link, run /revise

**Edge Case 3: Multiple Plan Links** (Current Bug)
- **Scenario**: Plan link already appended (v1 | v2 format)
- **Handling**: Replace entire line with single new plan link
- **Test**: Run /revise on task 283 (currently has appended links)

**Edge Case 4: Plan File Deleted**
- **Scenario**: Old plan file deleted from disk
- **Handling**: Still replace link (file existence checked separately)
- **Test**: Delete old plan file, run /revise

## Code Examples

### Regex Pattern for Plan Link Detection

```bash
# Pattern to match plan link line
PLAN_LINK_PATTERN="^- \*\*Plan\*\*:.*$"

# Extract existing plan link
existing_plan_line=$(echo "$task_entry" | grep -E "$PLAN_LINK_PATTERN")

# Check if plan link exists
if [ -n "$existing_plan_line" ]; then
  echo "Existing plan link found: $existing_plan_line"
  replacement_needed=true
else
  echo "No existing plan link found"
  replacement_needed=false
fi
```

### Replacement Logic

```bash
# Replace plan link in TODO.md task entry
if [ "$replacement_needed" = true ]; then
  # Replace entire line
  updated_task_entry=$(echo "$task_entry" | sed -E "s|^- \*\*Plan\*\*:.*$|- **Plan**: [Implementation Plan](${new_plan_path})|")
else
  # Append new plan link after description
  updated_task_entry="${task_entry}\n- **Plan**: [Implementation Plan](${new_plan_path})"
fi
```

### Validation

```bash
# Verify replacement succeeded
new_plan_line=$(echo "$updated_task_entry" | grep -E "$PLAN_LINK_PATTERN")
if [ -z "$new_plan_line" ]; then
  echo "ERROR: Plan link replacement failed"
  return 1
fi

# Verify old plan file still exists
if [ ! -f "$old_plan_path" ]; then
  echo "WARNING: Old plan file deleted: $old_plan_path"
fi

# Verify new plan file exists
if [ ! -f "$new_plan_path" ]; then
  echo "ERROR: New plan file not found: $new_plan_path"
  return 1
fi
```

## Decisions

### Decision 1: Replace Plan Links, Append Other Artifact Links

**Rationale**: Plan links should show only the current plan (clarity), while research and implementation links should show all artifacts (completeness).

**Implementation**: Add artifact type detection in status-sync-manager:
- If artifact type == "plan": Use replacement logic
- If artifact type != "plan": Use append logic (current behavior)

### Decision 2: Preserve Old Plan Files on Disk

**Rationale**: Old plans provide valuable historical context and should not be deleted.

**Implementation**: No deletion logic needed. status-sync-manager only updates TODO.md link, never deletes files.

### Decision 3: Update Only TODO.md, Not state.json

**Rationale**: state.json already correctly tracks plan_path and plan_versions. Only TODO.md plan link needs fixing.

**Implementation**: Modify only TODO.md update logic in status-sync-manager step_3_prepare_updates.

### Decision 4: Use Regex Replacement, Not Manual Parsing

**Rationale**: Regex is simpler and more robust for single-line replacement.

**Implementation**: Use sed or similar tool to replace plan link line in TODO.md task entry.

## Recommendations

### Recommendation 1: Implement Plan Link Replacement in status-sync-manager

**Priority**: High  
**Effort**: 2-3 hours  
**Impact**: Fixes confusing plan link display in TODO.md

**Implementation Steps**:
1. Add artifact type detection in step_3_prepare_updates
2. Add plan link search logic (regex pattern matching)
3. Add plan link replacement logic (sed or string replacement)
4. Add validation (verify replacement succeeded, old file exists)
5. Update status-sync-manager documentation
6. Test with task 283 (currently has appended links)

### Recommendation 2: Add Regression Test

**Priority**: Medium  
**Effort**: 1 hour  
**Impact**: Prevents future regressions

**Test Cases**:
1. Create initial plan with /plan (verify link appended)
2. Revise plan with /revise (verify link replaced, not appended)
3. Revise plan again (verify link replaced again)
4. Verify old plan files still exist on disk
5. Verify state.json plan_versions array correct

### Recommendation 3: Fix Task 283 Plan Links Manually (Optional)

**Priority**: Low  
**Effort**: 5 minutes  
**Impact**: Cleans up example of bug

**Steps**:
1. Edit TODO.md task 283 manually
2. Replace appended plan links with single link to implementation-002.md
3. Verify old plan file (implementation-001.md) still exists
4. Commit changes

## Risks & Mitigations

### Risk 1: Regex Replacement Breaks TODO.md Format

**Likelihood**: Medium  
**Impact**: High (corrupts TODO.md)

**Mitigation**:
- Use two-phase commit (prepare in memory, validate, then write)
- Add pre-commit validation (verify TODO.md well-formed after replacement)
- Add rollback mechanism (restore from backup if validation fails)
- Test with multiple task formats before deploying

### Risk 2: Edge Cases Not Handled

**Likelihood**: Medium  
**Impact**: Medium (some tasks have incorrect plan links)

**Mitigation**:
- Identify edge cases during research (see Edge Cases section)
- Add specific handling for each edge case
- Add validation for malformed plan links
- Log warnings for unexpected formats

### Risk 3: Breaks Existing /revise Workflow

**Likelihood**: Low  
**Impact**: High (breaks /revise command)

**Mitigation**:
- Test /revise command end-to-end after changes
- Verify both /plan and /revise work correctly
- Test with tasks that have no plan, one plan, and multiple plans
- Add rollback instructions if deployment fails

## Appendix: Sources and Citations

### Source 1: /revise Command Specification

**File**: `.opencode/command/revise.md`  
**Lines**: 1-137  
**Key Content**:
- /revise command workflow
- Delegation to planner subagent
- Version management (implementation-001.md, implementation-002.md, etc.)
- Plan preservation (original plans never modified)

### Source 2: Planner Subagent Specification

**File**: `.opencode/agent/subagents/planner.md`  
**Lines**: 1-500  
**Key Content**:
- Plan creation workflow (step_5)
- Plan filename generation (implementation-{version:03d}.md)
- Artifact validation (step_6)
- Status update delegation to status-sync-manager (step_7)

### Source 3: Status Sync Manager Specification

**File**: `.opencode/agent/subagents/status-sync-manager.md`  
**Lines**: 1-650  
**Key Content**:
- Atomic multi-file update logic (two-phase commit)
- Artifact link update logic (step_3_prepare_updates, lines 165-189)
- Plan version history tracking (lines 496-573)
- Validation and rollback mechanisms

### Source 4: Task 283 Example

**File**: `specs/TODO.md`  
**Lines**: 33-191 (task 283 description), 41 (appended plan links)  
**Key Content**:
- Example of appended plan links (the bug)
- Expected behavior vs. current behavior
- Note about manual artifact link addition

### Source 5: state.json Plan Tracking

**File**: `specs/state.json`  
**Lines**: 459-498 (task 283 entry)  
**Key Content**:
- Correct plan_path tracking (points to latest version)
- Correct plan_versions array (preserves history)
- Demonstrates state.json is working correctly

## Conclusion

The `/revise` command plan link appending behavior is caused by status-sync-manager's artifact link update logic, which does not distinguish between "replace" and "append" operations. The fix requires adding plan link replacement logic to status-sync-manager that:

1. Detects plan artifacts (type: "plan")
2. Searches for existing plan link in TODO.md
3. Replaces entire line (not appends)
4. Preserves old plan files on disk

**Estimated effort**: 2-3 hours (medium complexity)  
**Priority**: Medium (improves clarity, not critical)  
**Impact**: Fixes confusing plan link display in TODO.md

The fix is architecturally sound, low-risk (with proper validation), and aligns with the principle that TODO.md should show only the current plan while preserving historical plans in the project directory.
