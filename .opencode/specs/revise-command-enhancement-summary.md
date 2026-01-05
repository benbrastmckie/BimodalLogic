# /revise Command Enhancement: Dual-Mode Revision with Report Integration

## Overview

This enhancement adds intelligent dual-mode revision capability to the `/revise` command, enabling it to handle both task-only revisions (when no plan exists) and task+plan revisions (when a plan exists, with automatic integration of new reports).

## Current State

**Before Enhancement:**
- `/revise` command only works when a plan exists
- Always delegates to planner to create new plan versions
- No mechanism to revise task descriptions/requirements without a plan
- No automatic detection or integration of new reports created after plan

## Enhanced Behavior

**After Enhancement:**

### Mode 1: Task-Only Revision (No Plan Present)
- **Trigger**: Task has no plan_path in state.json
- **Agent**: Routes to new `task-reviser` subagent
- **Actions**:
  - Prompts user for revision details (description, priority, effort)
  - Updates task metadata in TODO.md and state.json atomically
  - Creates git commit with revision details
  - Returns standardized format with updated task info

### Mode 2: Task+Plan Revision (Plan Present)
- **Trigger**: Task has plan_path in state.json
- **Agent**: Routes to enhanced `planner` subagent
- **Actions**:
  - Scans `.opencode/specs/NNN_*/reports/` for new reports
  - Compares report modification times with plan creation time
  - Identifies reports created after last plan version
  - Reads and extracts key findings from new reports
  - Creates new plan version integrating new findings
  - Updates plan metadata with `reports_integrated` field
  - Updates TODO.md and state.json atomically
  - Creates git commit with plan revision

## Implementation Tasks

### Task 299: Create Task Reviser Subagent
**Effort**: 3 hours  
**Priority**: High  
**Dependencies**: None

Creates new subagent `.opencode/agent/subagents/task-reviser.md` that:
- Extracts task metadata from state.json
- Prompts user for revision details
- Updates TODO.md and state.json atomically via status-sync-manager
- Returns standardized format per subagent-return-format.md
- Handles errors gracefully with rollback

### Task 300: Add Report Detection to Planner
**Effort**: 4 hours  
**Priority**: High  
**Dependencies**: None

Enhances planner subagent to:
- Scan `.opencode/specs/NNN_*/reports/` directory
- Compare report modification times with plan creation time
- Identify reports created after last plan version
- Read and extract key findings from new reports
- Include new findings in revised plan Overview and Phases
- Update plan metadata with `reports_integrated` field
- Log report integration in plan revision notes

### Task 301: Enhance Revise Command with Dual-Mode Routing
**Effort**: 3 hours  
**Priority**: High  
**Dependencies**: 299, 300

Updates `/revise` command to:
- Detect plan presence in Stage 1 (ParseAndValidate)
- Route to task-reviser if no plan exists
- Route to planner with report context if plan exists
- Pass report detection flag to planner
- Update command documentation with dual-mode examples
- Validate routing decision correctness

### Task 302: Test Dual-Mode Revision Workflow
**Effort**: 2 hours  
**Priority**: High  
**Dependencies**: 301

Creates comprehensive tests:
- Test case 1: Task-only revision updates description/priority/effort
- Test case 2: Plan revision creates new version without reports
- Test case 3: Plan revision integrates new reports into phases
- Validates atomic updates to TODO.md and state.json
- Verifies git commits created correctly for each mode
- Tests rollback on failures
- Documents test cases in `.opencode/TESTING.md`

## Total Effort

**12 hours** across 4 tasks

## Dependency Chain

```
299 (task-reviser) ─┐
                     ├─> 301 (dual-mode routing) ─> 302 (testing)
300 (report detect) ─┘
```

Tasks 299 and 300 can be implemented in parallel, then 301 integrates both, and 302 validates the complete workflow.

## Usage Examples

### Example 1: Revise Task Without Plan

```bash
/revise 259
```

**Behavior:**
- Detects no plan exists for task 259
- Routes to task-reviser subagent
- Prompts: "What would you like to revise? (description/priority/effort/all)"
- User selects and provides new values
- Updates TODO.md and state.json atomically
- Creates commit: "task 259: revised description and priority"

### Example 2: Revise Plan Without New Reports

```bash
/revise 278
```

**Behavior:**
- Detects plan exists at `.opencode/specs/278_*/plans/implementation-001.md`
- Scans reports directory: `.opencode/specs/278_*/reports/`
- Finds no reports newer than plan (created 2026-01-04 18:45)
- Routes to planner for standard plan revision
- Creates new plan version: `implementation-002.md`
- Updates TODO.md plan link to version 002

### Example 3: Revise Plan With New Reports

```bash
/revise 230
```

**Behavior:**
- Detects plan exists at `.opencode/specs/230_*/plans/implementation-001.md` (created 2026-01-03 12:00)
- Scans reports directory: `.opencode/specs/230_*/reports/`
- Finds new report: `research-001.md` (created 2026-01-03 19:41)
- Reads report and extracts key findings
- Routes to planner with report context
- Creates new plan version: `implementation-002.md`
- Integrates report findings into Overview and Phases
- Updates plan metadata: `reports_integrated: ["research-001.md"]`
- Updates TODO.md plan link to version 002

## Technical Details

### Report Detection Algorithm

```bash
# Get plan creation timestamp
plan_mtime=$(stat -c "%Y" "$plan_path")

# Scan reports directory
for report in .opencode/specs/${task_number}_*/reports/*.md; do
  report_mtime=$(stat -c "%Y" "$report")
  
  # If report is newer than plan
  if [ "$report_mtime" -gt "$plan_mtime" ]; then
    new_reports+=("$report")
  fi
done

# If new reports found, read and extract findings
if [ ${#new_reports[@]} -gt 0 ]; then
  for report in "${new_reports[@]}"; do
    # Extract key findings section
    findings=$(grep -A 50 "## Key Findings" "$report")
    # Add to plan revision context
  done
fi
```

### Atomic Update Flow

Both modes use status-sync-manager for atomic updates:

```
1. Read current state (TODO.md + state.json)
2. Prepare updates (task metadata or plan link)
3. Validate updates (schema, consistency)
4. Write TODO.md (two-phase commit)
5. Write state.json (two-phase commit)
6. If either fails: rollback both
7. Create git commit
```

### Plan Metadata Enhancement

New field added to plan frontmatter:

```yaml
---
# ... existing metadata ...
reports_integrated:
  - path: ".opencode/specs/230_*/reports/research-001.md"
    created: "2026-01-03T19:41:00Z"
    findings_summary: "Research completed on review command fix..."
---
```

## Benefits

1. **Flexibility**: Support both early-stage task refinement and plan updates
2. **Intelligence**: Automatic detection and integration of new research findings
3. **Consistency**: Atomic updates ensure TODO.md and state.json stay in sync
4. **Traceability**: Plan metadata tracks which reports were integrated
5. **Efficiency**: No manual copying of research findings into plan revisions
6. **Quality**: Plans stay up-to-date with latest research and analysis

## Migration Path

No migration needed - enhancement is backward compatible:
- Existing `/revise` behavior preserved for tasks with plans
- New task-only mode adds capability without breaking existing workflows
- Report detection is automatic and optional (works with or without reports)

## Next Steps

1. Implement tasks in order: 299, 300 → 301 → 302
2. Test each mode thoroughly with real tasks
3. Update `.opencode/TESTING.md` with test cases
4. Document dual-mode behavior in `.opencode/command/revise.md`
5. Consider adding `/revise --mode=task` and `/revise --mode=plan` flags for explicit control

## Related Documentation

- `.opencode/command/revise.md` - Current /revise command specification
- `.opencode/agent/subagents/planner.md` - Planner subagent specification
- `.opencode/agent/subagents/status-sync-manager.md` - Atomic update mechanism
- `.opencode/context/core/standards/subagent-return-format.md` - Return format standard
- `.opencode/context/core/system/state-management.md` - State management patterns

---

**Created**: 2026-01-05  
**Status**: Tasks created, ready for implementation  
**Total Effort**: 12 hours  
**Priority**: High
