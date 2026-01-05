---
name: revise
agent: orchestrator
description: "Revise task metadata (no plan) or create new plan versions (plan exists) with dual-mode routing"
timeout: 1800
routing:
  plan_based: true
  task_only: task-reviser
  language_based: true
  lean: lean-planner
  default: planner
---

**Task Input (required):** $ARGUMENTS

<context>
  <system_context>Dual-mode revision command with plan presence detection and language-based routing</system_context>
  <task_context>Parse task number, validate, detect plan presence, route to task-reviser (no plan) or planner (plan exists) for revision</task_context>
</context>

<role>Revision command agent - Parse arguments and route to appropriate agent based on plan presence and language</role>

<task>
  Parse task number from $ARGUMENTS, lookup task in state.json, detect plan presence, extract metadata, route to task-reviser for task-only revision or planner for plan revision
</task>

<workflow_execution>
  <stage id="1" name="ParseAndValidate">
    <action>Parse task number and lookup in state.json</action>
    <process>
      1. Parse task number and flags from $ARGUMENTS
         - $ARGUMENTS contains: "196" or "196 Adjust phase breakdown" or "196 --force"
         - Extract first token as task_number
         - Validate is integer
         - Check for --force flag in remaining arguments
         - If --force present: force_mode=true, log warning "Using --force flag to override validation"
         - Else: force_mode=false
      
      2. Validate state.json exists and is valid
         - Check .opencode/specs/state.json exists
         - Validate is valid JSON with jq
         - If missing/corrupt: Return error "Run /meta to regenerate state.json"
      
      3. Lookup task in state.json
         - Use jq to find task by project_number:
           task_data=$(jq -r --arg num "$task_number" \
             '.active_projects[] | select(.project_number == ($num | tonumber))' \
             .opencode/specs/state.json)
         - If task_data is empty: Return error "Task $task_number not found"
      
      4. Extract all metadata at once
         - language=$(echo "$task_data" | jq -r '.language // "general"')
         - status=$(echo "$task_data" | jq -r '.status')
         - project_name=$(echo "$task_data" | jq -r '.project_name')
         - description=$(echo "$task_data" | jq -r '.description // ""')
         - priority=$(echo "$task_data" | jq -r '.priority')
         - plan_path=$(echo "$task_data" | jq -r '.plan_path // ""')
      
      5. Validate task status allows revision (skip if --force flag present)
         - If force_mode == false:
           case "$status" in
             "completed")
               echo "Error: Task $task_number already completed"
               echo "Recommendation: Task is done, no revision needed"
               echo "To override: /revise $task_number --force"
               exit 1
               ;;
             "abandoned")
               echo "Error: Task $task_number is abandoned"
               echo "Recommendation: Un-abandon task before revising"
               echo "To override: /revise $task_number --force"
               exit 1
               ;;
             "revising")
               echo "Warning: Task $task_number plan is already being revised"
               echo "If this is a stale status (e.g., previous revision crashed):"
               echo "  1. Check for existing plan versions"
               echo "  2. Use /sync to reset status if needed"
               echo "To override: /revise $task_number --force"
               exit 1
               ;;
             *)
               # Other statuses allow revision, proceed
               ;;
           esac
         - Else (force_mode == true):
           echo "WARNING: Using --force flag to override status validation"
           echo "Current status: $status"
           echo "Proceeding with revision despite status"
      
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
      
      7. Extract custom prompt from $ARGUMENTS if present
         - If $ARGUMENTS has multiple tokens: custom_prompt = remaining tokens
         - Else: custom_prompt = ""
      
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
    </process>
    <checkpoint>Task validated, plan exists, metadata extracted, target agent determined</checkpoint>
  </stage>
  
  <stage id="2" name="Delegate">
    <action>Delegate to planner with parsed context</action>
    <process>
      1. Generate session_id for tracking
         - session_id="sess_$(date +%s)_$(head -c 6 /dev/urandom | base64 | tr -dc 'a-z0-9')"
         - Store for validation: expected_session_id="$session_id"
      
      2. Invoke target agent via task tool with appropriate context:
         
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
      
      3. Wait for planner to complete and capture return
         - Subagent returns JSON to stdout
         - Capture in variable: subagent_return
    </process>
    <checkpoint>Delegated to planner for revision, return captured</checkpoint>
  </stage>
  
  <stage id="3" name="ValidateReturn">
    <action>Validate subagent return format and artifacts</action>
    <process>
      1. Log return for debugging
         - Log first 500 chars of return
         - Log: "Validating return from ${target_agent}"
      
      2. VALIDATION STEP 1: Validate JSON Structure
         - Parse return as JSON using jq
         - If parsing fails:
           * Log error: "[FAIL] Invalid JSON return from ${target_agent}"
           * Return error to user: "Subagent return validation failed: Cannot parse return as JSON"
           * Recommendation: "Fix ${target_agent} subagent return format"
           * Exit with error
         - If parsing succeeds:
           * Log: "[PASS] Return is valid JSON"
      
      3. VALIDATION STEP 2: Validate Required Fields
         - Check required fields exist: status, summary, artifacts, metadata
         - Check metadata subfields exist: session_id, agent_type, delegation_depth, delegation_path
         - For each missing field:
           * Log error: "[FAIL] Missing required field: ${field}"
           * Return error to user: "Subagent return validation failed: Missing required field: ${field}"
           * Recommendation: "Fix ${target_agent} subagent to include all required fields"
           * Exit with error
         - If all fields present:
           * Log: "[PASS] All required fields present"
      
      4. VALIDATION STEP 3: Validate Status Field
         - Extract status from return: status=$(echo "$subagent_return" | jq -r '.status')
         - Check status is valid enum: completed, partial, failed, blocked
         - If status invalid:
           * Log error: "[FAIL] Invalid status: ${status}"
           * Log: "Valid statuses: completed, partial, failed, blocked"
           * Return error to user: "Subagent return validation failed: Invalid status: ${status}"
           * Recommendation: "Fix ${target_agent} subagent to use valid status enum"
           * Exit with error
         - If status valid:
           * Log: "[PASS] Status is valid: ${status}"
      
      5. VALIDATION STEP 4: Validate Session ID
         - Extract returned session_id: returned_session_id=$(echo "$subagent_return" | jq -r '.metadata.session_id')
         - Compare with expected session_id (from delegation context)
         - If mismatch:
           * Log error: "[FAIL] Session ID mismatch"
           * Log: "Expected: ${expected_session_id}"
           * Log: "Got: ${returned_session_id}"
           * Return error to user: "Subagent return validation failed: Session ID mismatch"
           * Recommendation: "Fix ${target_agent} subagent to return correct session_id"
           * Exit with error
         - If match:
           * Log: "[PASS] Session ID matches"
      
      6. VALIDATION STEP 5: Validate Artifacts (CRITICAL - only if status=completed)
         - If status == "completed":
           a. Check artifacts array is non-empty
              - artifact_count=$(echo "$subagent_return" | jq '.artifacts | length')
              - If artifact_count == 0:
                * Log error: "[FAIL] Agent returned 'completed' status but created no artifacts"
                * Log error: "Error: Phantom revision detected - status=completed but no artifacts"
                * Return error to user: "Subagent return validation failed: Phantom revision detected"
                * Recommendation: "Verify ${target_agent} creates artifacts before updating status"
                * Exit with error
              - Else:
                * Log: "[INFO] Artifact count: ${artifact_count}"
           
           b. Verify each artifact exists on disk
              - Extract artifact paths: artifact_paths=$(echo "$subagent_return" | jq -r '.artifacts[].path')
              - For each path in artifact_paths:
                * Check file exists: [ -f "$path" ]
                * If file does not exist:
                  - Log error: "[FAIL] Artifact does not exist: ${path}"
                  - Return error to user: "Subagent return validation failed: Artifact not found: ${path}"
                  - Recommendation: "Verify ${target_agent} writes artifacts to correct paths"
                  - Exit with error
                * If file exists:
                  - Log: "[PASS] Artifact exists: ${path}"
           
           c. Verify each artifact is non-empty
              - For each path in artifact_paths:
                * Check file is non-empty: [ -s "$path" ]
                * If file is empty:
                  - Log error: "[FAIL] Artifact is empty: ${path}"
                  - Return error to user: "Subagent return validation failed: Empty artifact: ${path}"
                  - Recommendation: "Verify ${target_agent} writes content to artifacts"
                  - Exit with error
                * If file is non-empty:
                  - file_size=$(stat -c%s "$path" 2>/dev/null || stat -f%z "$path")
                  - Log: "[PASS] Artifact is non-empty: ${path} (${file_size} bytes)"
           
           d. Log validation success
              - Log: "[PASS] ${artifact_count} artifacts validated"
         
         - Else (status != "completed"):
           * Log: "[INFO] Skipping artifact validation (status=${status})"
           * Note: Partial/failed/blocked status may have empty or incomplete artifacts
      
      7. Validation Summary
         - Log: "[PASS] Return validation succeeded"
         - Log: "Status: ${status}"
         - If status == "completed":
           * Log: "Artifacts: ${artifact_count} validated"
    </process>
    <checkpoint>Subagent return validated, all checks passed</checkpoint>
  </stage>
  
  <stage id="4" name="RelayResult">
    <action>Relay validated result to user</action>
    <process>
      1. Extract key information from validated return
         - summary=$(echo "$subagent_return" | jq -r '.summary')
         - next_steps=$(echo "$subagent_return" | jq -r '.next_steps // "None"')
      
      2. Format response for user
         - Display status and summary
         - List artifacts created
         - Show next steps
      
      3. Return to user
    </process>
    <checkpoint>Result relayed to user</checkpoint>
  </stage>
</workflow_execution>

# /revise - Dual-Mode Revision Command

Revise task metadata when no plan exists, or create new plan versions when plan exists. Automatically detects plan presence and routes to appropriate agent.

## Usage

```bash
/revise TASK_NUMBER [PROMPT] [--force]
/revise 196                              # Task-only revision if no plan, plan revision if plan exists
/revise 196 "Adjust phase breakdown"     # Plan revision with custom prompt
/revise 196 --force                      # Override status validation
```

**Flags:**
- `--force`: Override status validation (advanced users only). Use to bypass already-in-progress checks.

## What This Does

1. Validates task exists in state.json (8x faster than TODO.md parsing)
2. Extracts all metadata at once (language, status, description, plan_path)
3. **Detects plan presence and determines routing mode**
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
- Preserves all previous plan versions
- Updates status to [REVISED]
- Creates git commit

**Example**:
```bash
/revise 301 "Incorporate new routing research"
# Creates implementation-002.md with new findings
# Updates status to [REVISED]
```

## Language-Based Routing

| Language | Agent | Features |
|----------|-------|----------|
| lean | lean-planner | Proof strategies, mathlib integration |
| general | planner | Standard implementation planning |

## Routing Validation

The command validates routing decisions to ensure correctness:

1. **Plan Consistency Check**: If `plan_path` is set in state.json, verifies file exists on disk
2. **Agent Existence Check**: Verifies target agent file exists before delegation
3. **Routing Mode Logging**: Logs routing decision for debugging

**Error Handling**:
- Inconsistent state (plan_path set but file missing): Abort with recovery instructions
- Agent not found: Abort with error message
- Invalid routing mode: Abort with error message

## Version Management (Plan Revision Only)

- Original plan files never modified
- New plan version created as separate file
- All plan versions preserved in plans/ directory
- TODO.md plan link updated to point to latest version

See `.opencode/agent/subagents/planner.md` for plan revision details.
See `.opencode/agent/subagents/task-reviser.md` for task-only revision details.
