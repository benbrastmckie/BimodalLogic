# Research Report: Enhance Revise Command with Dual-Mode Routing

## Metadata

- **Task**: 301 - Enhance Revise Command with Dual-Mode Routing
- **Started**: 2026-01-05
- **Completed**: 2026-01-05
- **Effort**: 2 hours
- **Priority**: High
- **Dependencies**: Task 299 (unknown status), Task 300 (completed)
- **Sources/Inputs**: 
  - `.opencode/command/revise.md` (current implementation)
  - `.opencode/agent/subagents/task-reviser.md` (task-only revision agent)
  - `.opencode/agent/subagents/planner.md` (plan revision agent)
  - `specs/state.json` (state structure with plan_path)
  - `.opencode/context/core/system/routing-guide.md` (routing patterns)
  - `.opencode/context/core/system/state-management.md` (status transitions)
- **Artifacts**: research-001.md
- **Standards**: status-markers.md, artifact-management.md, tasks.md, report.md

---

## Executive Summary

The current `/revise` command (`.opencode/command/revise.md`) routes exclusively to the `planner` subagent for plan revision, assuming a plan always exists. However, there are scenarios where users need to revise task metadata (description, priority, effort, dependencies) when no plan exists yet. Task 301 requires implementing dual-mode routing based on plan presence detection:

1. **No Plan Mode**: Route to `task-reviser` subagent for task metadata updates
2. **Plan Exists Mode**: Route to `planner` subagent for plan revision with research integration

**Key Findings**:
- Current `/revise` validates plan existence (line 89-91) but always routes to planner
- `task-reviser.md` subagent already exists and handles task-only revision
- `planner.md` already supports plan revision with report detection (Task 300 completed)
- Plan presence can be detected via `plan_path` field in `state.json`
- Routing decision should occur in Stage 1 (ParseAndValidate) of `/revise` command

**Recommendation**: Implement plan presence detection in Stage 1 and conditional routing in Stage 2 of `/revise` command. Minimal changes required - architecture already supports dual-mode operation.

---

## Context & Scope

### Problem Statement

Users need to revise tasks at different lifecycle stages:
- **Early Stage**: Task created but no plan yet - need to refine description, adjust priority, update effort estimates
- **Planning Stage**: Plan exists - need to create new plan versions incorporating new research findings

Current `/revise` command only handles the second scenario, forcing users to manually edit TODO.md and state.json for task-only revisions.

### Scope

**In Scope**:
- Plan presence detection logic in `/revise` command Stage 1
- Conditional routing to `task-reviser` vs `planner` in Stage 2
- Documentation updates for dual-mode usage
- Validation of routing decision correctness

**Out of Scope**:
- Modifications to `task-reviser` or `planner` subagents (already functional)
- Changes to state.json schema (plan_path field already exists)
- Status transition logic (already defined in state-management.md)

### Dependencies

- **Task 299**: Status unknown, may be related to revision workflow
- **Task 300**: COMPLETED - "Add report detection to planner" - enables planner to detect new reports since last plan version and integrate findings

---

## Key Findings

### Finding 1: Current /revise Command Architecture

**File**: `.opencode/command/revise.md`

**Current Behavior**:
- Lines 1-10: Frontmatter specifies `agent: orchestrator` with language-based routing to `lean-planner` or `planner`
- Lines 26-102: Stage 1 (ParseAndValidate) validates plan existence (lines 89-91)
- Lines 104-124: Stage 2 (Delegate) always routes to planner

**Critical Code** (lines 89-91):
```markdown
6. Validate existing plan exists
   - If plan_path is empty: Return error "No plan exists. Use /plan $task_number first."
   - Verify plan file exists at plan_path
```

**Issue**: Command aborts if no plan exists, preventing task-only revision.

**Routing Logic** (lines 97-99):
```markdown
8. Determine target agent based on language
   - lean → lean-planner
   - general → planner
```

**Issue**: Always routes to planner, no conditional routing based on plan presence.

### Finding 2: task-reviser Subagent Capabilities

**File**: `.opencode/agent/subagents/task-reviser.md`

**Purpose**: Task metadata revision when no plan exists (lines 46-52)

**Key Features**:
- Lines 111-115: Validates no plan exists before proceeding
- Lines 179-200: Displays current task metadata to user
- Lines 202-253: Prompts for revisions (description, priority, effort, dependencies)
- Lines 255-285: Confirms changes with user
- Lines 287-341: Delegates to status-sync-manager for atomic updates
- Lines 343-394: Creates git commit via git-workflow-manager

**Validation Logic** (lines 161-164):
```markdown
4. Validate no plan exists:
   - Check plan_path field in task metadata
   - If plan_path is non-empty: Return error "Task {task_number} has a plan. Use /revise for plan revision."
   - If plan_path is empty or missing: Proceed with task-only revision
```

**Status**: Fully implemented, ready to use.

### Finding 3: planner Subagent Plan Revision Capabilities

**File**: `.opencode/agent/subagents/planner.md`

**Purpose**: Create implementation plans with research integration (lines 48-55)

**Revision Support**:
- Lines 80-85: Accepts `revision_context` parameter from `/revise` command
- Lines 114-130: Determines revision mode based on `revision_context` presence
- Lines 146-211: Detects new reports created since last plan version (Task 300)
- Lines 213-292: Harvests research findings and generates integration summary
- Lines 374-493: Executes postflight (status update to [REVISED], git commit)

**Report Detection Logic** (lines 172-196):
```markdown
d. Scan reports directory for all research reports:
   # Determine project directory from task_number
   project_dir=$(find .opencode/specs -maxdepth 1 -type d -name "${task_number}_*" | head -1)
   reports_dir="${project_dir}/reports"
   
   # Scan for research reports if directory exists
   new_reports=()
   if [ -d "$reports_dir" ]; then
     for report in "$reports_dir"/research-*.md; do
       [ -f "$report" ] || continue
       
       # Get report mtime
       report_mtime=$(stat -c %Y "$report")
       
       # Compare timestamps: report created after plan = NEW
       if [ "$report_mtime" -gt "$plan_mtime" ]; then
         new_reports+=("$report")
       fi
     done
   fi
```

**Status**: Fully implemented with Task 300 completion.

### Finding 4: Plan Presence Detection via state.json

**File**: `specs/state.json`

**Schema**: Each active project has a `plan_path` field (lines 1-100 sample):
```json
{
  "project_number": 259,
  "project_name": "automation_tactics",
  "plan_path": "specs/259_automation_tactics/plans/implementation-001.md",
  "status": "planned"
}
```

**Detection Logic**:
```bash
# Extract plan_path from state.json
plan_path=$(jq -r --arg num "$task_number" \
  '.active_projects[] | select(.project_number == ($num | tonumber)) | .plan_path // ""' \
  specs/state.json)

# Check if plan exists
if [ -z "$plan_path" ] || [ "$plan_path" == "null" ]; then
  # No plan exists - route to task-reviser
  has_plan=false
else
  # Plan exists - route to planner
  has_plan=true
fi
```

**Validation**: Should also verify plan file exists on disk to detect inconsistent state.

### Finding 5: Routing Patterns from routing-guide.md

**File**: `.opencode/context/core/system/routing-guide.md`

**Language-Based Routing** (lines 44-72):
- Extract language from state.json or TODO.md
- Route based on language: `lean` → `lean-*-agent`, `general` → `*-agent`

**Delegation Preparation** (lines 117-167):
- Generate session_id for tracking
- Build delegation context with task metadata
- Set appropriate timeouts

**Routing Validation** (lines 74-92):
```bash
# Validate lean routing
if [ "$language" == "lean" ] && [[ ! "$agent" =~ ^lean- ]]; then
  echo "[FAIL] Routing validation failed: language=lean but agent=${agent}"
  exit 1
fi
```

**Application to /revise**: Need similar validation for plan-based routing.

### Finding 6: Status Transitions from state-management.md

**File**: `.opencode/context/core/system/state-management.md`

**Revision Status Markers** (lines 78-88):
- `[REVISING]`: Plan revision in progress (used by `/revise`)
- `[REVISED]`: Plan revision completed, new plan version created

**Valid Transitions** (lines 128-129):
```
| [PLANNED] | [REVISING] | `/revise` command starts |
| [REVISING] | [REVISED] | Plan revision completes successfully |
```

**Task-Only Revision**: No specific status marker defined. Task-reviser updates metadata without changing status (or keeps current status).

---

## Detailed Analysis

### Current /revise Command Flow

**Stage 1: ParseAndValidate** (lines 26-102)
1. Parse task_number and flags from $ARGUMENTS
2. Validate state.json exists and is valid
3. Lookup task in state.json
4. Extract metadata (language, status, project_name, description, priority, plan_path)
5. Validate task status allows revision (skip if --force)
6. **Validate existing plan exists** ← BLOCKING STEP
7. Extract custom prompt from $ARGUMENTS
8. Determine target agent based on language

**Stage 2: Delegate** (lines 104-124)
1. Invoke target agent (planner or lean-planner)
2. Wait for completion
3. Relay result to user

**Problem**: Step 6 aborts if no plan exists, preventing task-only revision.

### Proposed Dual-Mode Routing Logic

**Modified Stage 1: ParseAndValidate**
1. Parse task_number and flags from $ARGUMENTS
2. Validate state.json exists and is valid
3. Lookup task in state.json
4. Extract metadata (language, status, project_name, description, priority, plan_path)
5. Validate task status allows revision (skip if --force)
6. **NEW: Detect plan presence** ← ROUTING DECISION POINT
   - If plan_path is empty or missing: `routing_mode = "task-only"`
   - If plan_path exists: `routing_mode = "plan-revision"`
   - Validate plan file exists if plan_path set (detect inconsistent state)
7. Extract custom prompt from $ARGUMENTS
8. **NEW: Determine target agent based on routing_mode AND language**
   - If `routing_mode == "task-only"`: target_agent = "task-reviser"
   - If `routing_mode == "plan-revision"` AND `language == "lean"`: target_agent = "lean-planner"
   - If `routing_mode == "plan-revision"` AND `language != "lean"`: target_agent = "planner"

**Modified Stage 2: Delegate**
1. Invoke target agent (task-reviser, planner, or lean-planner)
2. Pass appropriate context:
   - For task-reviser: revision_context with custom prompt
   - For planner: revision_context with custom prompt + existing_plan_path
3. Wait for completion
4. Relay result to user

### Implementation Approach

**Phase 1: Update Stage 1 (ParseAndValidate)**

**Step 1.1: Replace plan existence validation with plan presence detection**

Current code (lines 89-91):
```markdown
6. Validate existing plan exists
   - If plan_path is empty: Return error "No plan exists. Use /plan $task_number first."
   - Verify plan file exists at plan_path
```

New code:
```markdown
6. Detect plan presence and determine routing mode
   a. Extract plan_path from state.json (already done in step 4)
   
   b. Determine routing mode:
      - If plan_path is empty or missing: routing_mode = "task-only"
      - If plan_path is non-empty: routing_mode = "plan-revision"
   
   c. Validate plan file consistency (if plan_path set):
      - If plan_path is non-empty AND file doesn't exist:
        * Log error: "Inconsistent state: plan_path in state.json points to missing file"
        * Recommendation: "Run /plan to create initial plan or /sync to fix state"
        * Exit with error
      - If plan_path is non-empty AND file exists:
        * Log: "Plan exists at ${plan_path}, routing to planner for revision"
      - If plan_path is empty:
        * Log: "No plan exists, routing to task-reviser for task-only revision"
   
   d. Set routing_mode variable for Stage 2
```

**Step 1.2: Update target agent determination**

Current code (lines 97-99):
```markdown
8. Determine target agent based on language
   - lean → lean-planner
   - general → planner
```

New code:
```markdown
8. Determine target agent based on routing_mode and language
   a. If routing_mode == "task-only":
      - target_agent = "task-reviser"
      - Log: "Routing to task-reviser for task metadata revision"
   
   b. If routing_mode == "plan-revision":
      - If language == "lean": target_agent = "lean-planner"
      - Else: target_agent = "planner"
      - Log: "Routing to ${target_agent} for plan revision"
   
   c. Validate routing decision:
      - Verify target_agent file exists in .opencode/agent/subagents/
      - If missing: Exit with error "Agent ${target_agent} not found"
```

**Phase 2: Update Stage 2 (Delegate)**

**Step 2.1: Conditional delegation based on routing_mode**

Current code (lines 107-116):
```markdown
1. Invoke target agent via task tool with revision_context:
   task(
     subagent_type="${target_agent}",
     prompt="Create revised plan (new version) for task ${task_number}: ${description}. ${custom_prompt}",
     description="Revise plan for task ${task_number}",
     context={
       "revision_context": "Plan revision requested via /revise command. ${custom_prompt}",
       "existing_plan_path": "${plan_path}"
     }
   )
```

New code:
```markdown
1. Invoke target agent via task tool with appropriate context:
   
   a. If routing_mode == "task-only":
      task(
        subagent_type="task-reviser",
        prompt="Revise task metadata for task ${task_number}: ${description}. ${custom_prompt}",
        description="Revise task metadata for task ${task_number}",
        context={
          "revision_context": "Task metadata revision requested via /revise command. ${custom_prompt}",
          "task_number": ${task_number},
          "session_id": "${session_id}",
          "delegation_depth": 1,
          "delegation_path": ["orchestrator", "revise", "task-reviser"]
        }
      )
   
   b. If routing_mode == "plan-revision":
      task(
        subagent_type="${target_agent}",
        prompt="Create revised plan (new version) for task ${task_number}: ${description}. ${custom_prompt}",
        description="Revise plan for task ${task_number}",
        context={
          "revision_context": "Plan revision requested via /revise command. ${custom_prompt}",
          "existing_plan_path": "${plan_path}",
          "task_number": ${task_number},
          "session_id": "${session_id}",
          "delegation_depth": 1,
          "delegation_path": ["orchestrator", "revise", "${target_agent}"]
        }
      )
```

**Phase 3: Update Documentation**

**Step 3.1: Update command documentation (lines 126-168)**

Add dual-mode explanation:
```markdown
## What This Does

1. Validates task exists in state.json
2. Extracts all metadata at once (language, status, description, plan_path)
3. **NEW: Detects plan presence and determines routing mode**
4. Routes to appropriate agent:
   - **No Plan**: Routes to task-reviser for task metadata updates
   - **Plan Exists**: Routes to planner for plan revision with research integration
5. Agent performs revision and updates status
6. Creates git commit

## Dual-Mode Routing

### Task-Only Revision (No Plan)

When no plan exists (`plan_path` empty in state.json):
- Routes to `task-reviser` subagent
- Updates task metadata: description, priority, effort, dependencies
- Prompts user for changes interactively
- Updates TODO.md and state.json atomically via status-sync-manager
- Creates git commit
- Does NOT change task status (keeps current status)

**Example**:
```bash
/revise 301
# Prompts for new description, priority, effort, dependencies
# Updates task metadata without creating plan
```

### Plan Revision (Plan Exists)

When plan exists (`plan_path` non-empty in state.json):
- Routes to `planner` (or `lean-planner` for Lean tasks)
- Detects new research reports created since last plan version
- Integrates new findings into revised plan
- Creates new plan version (increments version number)
- Updates status to [REVISED]
- Creates git commit

**Example**:
```bash
/revise 301 "Incorporate new routing research"
# Creates implementation-002.md with new findings
# Updates status to [REVISED]
```
```

**Step 3.2: Add validation section**

```markdown
## Routing Validation

The command validates routing decisions to ensure correctness:

1. **Plan Consistency Check**: If `plan_path` is set in state.json, verifies file exists on disk
2. **Agent Existence Check**: Verifies target agent file exists before delegation
3. **Routing Mode Logging**: Logs routing decision for debugging

**Error Handling**:
- Inconsistent state (plan_path set but file missing): Abort with recovery instructions
- Agent not found: Abort with error message
- Invalid routing mode: Abort with error message
```

### Validation Strategy

**Pre-Delegation Validation**:
1. Verify state.json is valid JSON
2. Verify task exists in state.json
3. Verify plan_path consistency (if set, file must exist)
4. Verify target agent file exists
5. Log routing decision with rationale

**Post-Delegation Validation**:
1. Verify subagent returned standardized format
2. Verify status updated correctly:
   - Task-only revision: Status unchanged or updated per user request
   - Plan revision: Status updated to [REVISED]
3. Verify git commit created
4. Verify artifacts linked in TODO.md (for plan revision)

### Edge Cases

**Case 1: Plan file deleted but plan_path still set**
- Detection: plan_path non-empty but file doesn't exist
- Handling: Abort with error, recommend `/sync` to fix state or `/plan` to recreate

**Case 2: User wants to revise task metadata when plan exists**
- Current behavior: Routes to planner (wrong)
- Desired behavior: Provide flag to force task-only revision?
- Recommendation: Add `--task-only` flag to override routing decision

**Case 3: Multiple plan versions exist**
- Detection: plans/implementation-001.md, implementation-002.md, etc.
- Handling: plan_path points to latest version, planner increments version number

**Case 4: Task status is [COMPLETED]**
- Current behavior: Validation blocks revision unless --force flag used
- Desired behavior: Allow task-only revision with --force, block plan revision
- Recommendation: Keep current behavior, document in usage

---

## Code Examples

### Example 1: Plan Presence Detection

```bash
# Extract plan_path from state.json
plan_path=$(jq -r --arg num "$task_number" \
  '.active_projects[] | select(.project_number == ($num | tonumber)) | .plan_path // ""' \
  specs/state.json)

# Determine routing mode
if [ -z "$plan_path" ] || [ "$plan_path" == "null" ]; then
  routing_mode="task-only"
  echo "[INFO] No plan exists, routing to task-reviser"
else
  # Validate plan file exists
  if [ ! -f "$plan_path" ]; then
    echo "[FAIL] Inconsistent state: plan_path set but file missing"
    echo "       plan_path: $plan_path"
    echo "       Recommendation: Run /sync to fix state or /plan to recreate"
    exit 1
  fi
  
  routing_mode="plan-revision"
  echo "[INFO] Plan exists at $plan_path, routing to planner"
fi
```

### Example 2: Conditional Agent Selection

```bash
# Determine target agent based on routing_mode and language
if [ "$routing_mode" == "task-only" ]; then
  target_agent="task-reviser"
  echo "[INFO] Routing to task-reviser for task metadata revision"
elif [ "$routing_mode" == "plan-revision" ]; then
  if [ "$language" == "lean" ]; then
    target_agent="lean-planner"
  else
    target_agent="planner"
  fi
  echo "[INFO] Routing to $target_agent for plan revision"
else
  echo "[FAIL] Invalid routing_mode: $routing_mode"
  exit 1
fi

# Validate agent exists
agent_file=".opencode/agent/subagents/${target_agent}.md"
if [ ! -f "$agent_file" ]; then
  echo "[FAIL] Agent file not found: $agent_file"
  exit 1
fi

echo "[PASS] Routing validation succeeded"
```

### Example 3: Conditional Delegation Context

```bash
# Build delegation context based on routing mode
if [ "$routing_mode" == "task-only" ]; then
  # Task-only revision context
  delegation_context=$(cat <<EOF
{
  "revision_context": "Task metadata revision requested via /revise command. $custom_prompt",
  "task_number": $task_number,
  "session_id": "$session_id",
  "delegation_depth": 1,
  "delegation_path": ["orchestrator", "revise", "task-reviser"]
}
EOF
)
else
  # Plan revision context
  delegation_context=$(cat <<EOF
{
  "revision_context": "Plan revision requested via /revise command. $custom_prompt",
  "existing_plan_path": "$plan_path",
  "task_number": $task_number,
  "session_id": "$session_id",
  "delegation_depth": 1,
  "delegation_path": ["orchestrator", "revise", "$target_agent"]
}
EOF
)
fi
```

---

## Decisions

### Decision 1: Routing Decision Point

**Question**: Where should plan presence detection occur?

**Options**:
1. Stage 1 (ParseAndValidate) - during metadata extraction
2. Stage 2 (Delegate) - just before delegation
3. Orchestrator Stage 2 (DetermineRouting) - before command invocation

**Decision**: Stage 1 (ParseAndValidate) in `/revise` command

**Rationale**:
- Metadata extraction already happens in Stage 1 (plan_path available)
- Routing decision affects validation logic (no need to validate plan exists for task-only)
- Keeps routing logic close to validation logic
- Follows existing pattern in `/research` and `/implement` commands

### Decision 2: Agent Selection Strategy

**Question**: Should we create a new "reviser" agent or reuse existing agents?

**Options**:
1. Create new "reviser" agent that handles both modes internally
2. Reuse existing task-reviser and planner agents with conditional routing
3. Create separate "task-reviser" and "plan-reviser" agents

**Decision**: Reuse existing task-reviser and planner agents (Option 2)

**Rationale**:
- task-reviser already fully implements task-only revision
- planner already fully implements plan revision with report integration
- No code duplication
- Simpler architecture
- Easier to maintain

### Decision 3: Validation Strategy

**Question**: How should we validate plan file consistency?

**Options**:
1. Trust state.json plan_path without validation
2. Validate plan file exists if plan_path set
3. Validate plan file exists AND is non-empty

**Decision**: Validate plan file exists if plan_path set (Option 2)

**Rationale**:
- Detects inconsistent state (plan_path set but file deleted)
- Prevents routing to planner when plan doesn't actually exist
- Non-empty check unnecessary (planner can handle empty files)
- Provides clear error message with recovery instructions

### Decision 4: Task-Only Revision with Existing Plan

**Question**: Should users be able to revise task metadata when plan exists?

**Options**:
1. Block task-only revision when plan exists (force plan revision)
2. Allow task-only revision with `--task-only` flag
3. Always allow task-only revision (user choice)

**Decision**: Block task-only revision when plan exists (Option 1)

**Rationale**:
- Maintains consistency between task metadata and plan
- Prevents divergence between TODO.md and plan files
- Users can revise plan to incorporate task metadata changes
- Simpler implementation (no additional flags)
- Can add `--task-only` flag in future if needed

---

## Recommendations

### Recommendation 1: Implement Dual-Mode Routing in /revise Command

**Priority**: High

**Effort**: 1.5 hours

**Steps**:
1. Update Stage 1 (ParseAndValidate) to detect plan presence and determine routing mode (30 min)
2. Update Stage 1 to select target agent based on routing_mode and language (15 min)
3. Update Stage 2 (Delegate) to pass appropriate context based on routing_mode (30 min)
4. Update command documentation with dual-mode explanation and examples (15 min)

**Expected Outcome**: `/revise` command supports both task-only and plan revision modes.

### Recommendation 2: Add Routing Validation

**Priority**: High

**Effort**: 30 minutes

**Steps**:
1. Add plan file consistency check (plan_path set → file must exist) (15 min)
2. Add agent existence check before delegation (10 min)
3. Add routing decision logging for debugging (5 min)

**Expected Outcome**: Clear error messages when routing fails, easier debugging.

### Recommendation 3: Update Documentation

**Priority**: Medium

**Effort**: 30 minutes

**Steps**:
1. Add dual-mode explanation to command documentation (15 min)
2. Add examples for both modes (10 min)
3. Add validation section explaining checks (5 min)

**Expected Outcome**: Users understand when to use `/revise` for task vs plan revision.

### Recommendation 4: Add Integration Tests

**Priority**: Medium

**Effort**: 1 hour

**Steps**:
1. Test task-only revision (no plan exists) (20 min)
2. Test plan revision (plan exists, no new reports) (20 min)
3. Test plan revision (plan exists, new reports) (20 min)

**Expected Outcome**: Confidence that dual-mode routing works correctly.

### Recommendation 5: Consider Future Enhancements

**Priority**: Low

**Effort**: TBD

**Potential Enhancements**:
1. Add `--task-only` flag to force task-only revision when plan exists
2. Add `--plan-only` flag to force plan revision (skip task metadata)
3. Add `--dry-run` flag to preview changes without applying
4. Add `--interactive` flag to prompt for confirmation before applying

**Rationale**: These enhancements provide more control but add complexity. Implement only if user feedback indicates need.

---

## Risks & Mitigations

### Risk 1: Inconsistent State Detection Failure

**Risk**: Plan file deleted but plan_path still set in state.json, routing fails

**Likelihood**: Low

**Impact**: High (command fails with unclear error)

**Mitigation**: Add plan file consistency check in Stage 1, provide clear error message with recovery instructions

### Risk 2: Routing Logic Complexity

**Risk**: Dual-mode routing adds complexity, increases maintenance burden

**Likelihood**: Medium

**Impact**: Medium (harder to debug routing issues)

**Mitigation**: Add comprehensive logging, document routing decision logic clearly, add validation checks

### Risk 3: User Confusion

**Risk**: Users don't understand when to use task-only vs plan revision

**Likelihood**: Medium

**Impact**: Low (users can recover by trying different mode)

**Mitigation**: Update documentation with clear examples, add routing decision logging visible to user

### Risk 4: Breaking Changes

**Risk**: Existing `/revise` usage breaks with new routing logic

**Likelihood**: Low

**Impact**: Medium (users need to update workflows)

**Mitigation**: Maintain backward compatibility - existing plan revision behavior unchanged, only add new task-only mode

---

## Appendix: Sources and Citations

### Source 1: /revise Command Implementation

**File**: `.opencode/command/revise.md`

**Key Sections**:
- Lines 1-10: Frontmatter with routing configuration
- Lines 26-102: Stage 1 (ParseAndValidate) with plan validation
- Lines 104-124: Stage 2 (Delegate) with planner invocation
- Lines 126-168: Documentation

**Citation**: Current implementation validates plan existence and always routes to planner.

### Source 2: task-reviser Subagent

**File**: `.opencode/agent/subagents/task-reviser.md`

**Key Sections**:
- Lines 46-52: Purpose and scope (task-only revision)
- Lines 111-115: Plan detection validation
- Lines 179-200: Display current metadata
- Lines 202-253: Prompt for revisions
- Lines 287-341: Delegate to status-sync-manager
- Lines 343-394: Create git commit

**Citation**: Fully implemented task-only revision agent with atomic updates.

### Source 3: planner Subagent

**File**: `.opencode/agent/subagents/planner.md`

**Key Sections**:
- Lines 80-85: Revision context parameter
- Lines 114-130: Revision mode detection
- Lines 146-211: New report detection (Task 300)
- Lines 213-292: Research integration
- Lines 374-493: Postflight (status update, git commit)

**Citation**: Fully implemented plan revision with report integration (Task 300 completed).

### Source 4: state.json Schema

**File**: `specs/state.json`

**Key Fields**:
- `project_number`: Task number
- `project_name`: Task slug
- `plan_path`: Path to plan file (empty if no plan)
- `status`: Current task status

**Citation**: plan_path field enables plan presence detection.

### Source 5: Routing Guide

**File**: `.opencode/context/core/system/routing-guide.md`

**Key Sections**:
- Lines 44-72: Language-based routing
- Lines 74-92: Routing validation
- Lines 117-167: Delegation preparation

**Citation**: Established patterns for routing and validation.

### Source 6: State Management Standard

**File**: `.opencode/context/core/system/state-management.md`

**Key Sections**:
- Lines 78-88: Revision status markers
- Lines 119-133: Valid status transitions

**Citation**: Status transition rules for revision workflow.

---

## Conclusion

The `/revise` command enhancement to support dual-mode routing is straightforward and well-architected. The necessary subagents (task-reviser and planner) already exist and are fully functional. The implementation requires only:

1. Replacing plan existence validation with plan presence detection in Stage 1
2. Adding conditional routing logic based on routing_mode and language
3. Updating delegation context to pass appropriate parameters
4. Updating documentation with dual-mode explanation

The architecture already supports this pattern through the plan_path field in state.json and the existing subagent capabilities. Task 300 (report detection in planner) is completed, enabling seamless plan revision with research integration.

**Estimated Total Effort**: 3 hours (matches task estimate)
- Implementation: 1.5 hours
- Validation: 0.5 hours
- Documentation: 0.5 hours
- Testing: 0.5 hours

**Risk Level**: Low - minimal changes to existing working code, clear separation of concerns.

**Recommendation**: Proceed with implementation following the phased approach outlined in this report.
