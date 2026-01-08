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
context_loading:
  strategy: lazy
  index: ".opencode/context/index.md"
  required:
    - "core/orchestration/delegation.md"
    - "core/orchestration/state-management.md"
  optional:
    - "core/formats/plan-format.md"
  max_context_size: 40000
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
               echo "  2. Use /task --sync to reset status if needed"
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
              * Recommendation: "Run /plan to create initial plan or /task --sync to fix state"
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
  
  <stage id="1.5" name="Preflight">
    <action>Update status to [REVISING] before delegating to reviser</action>
    <process>
      CRITICAL: This stage MUST complete BEFORE Stage 2 (Delegate) begins.
      This ensures status updates immediately when revision starts.
      
      1. Generate session_id for tracking:
         - session_id="sess_$(date +%s)_$(head -c 6 /dev/urandom | base64 | tr -dc 'a-z0-9')"
         - Store for later use: expected_session_id="$session_id"
         - Log: "Generated session_id: ${session_id}"
      
      2. Delegate to status-sync-manager to update status:
         
         Log: "Preflight: Updating task ${task_number} status to REVISING"
         
         INVOKE status-sync-manager via task tool:
         task(
           subagent_type="status-sync-manager",
           prompt="{
             \"operation\": \"update_status\",
             \"task_number\": ${task_number},
             \"new_status\": \"revising\",
             \"timestamp\": \"$(date -I)\",
             \"session_id\": \"${session_id}\",
             \"delegation_depth\": 1,
             \"delegation_path\": [\"orchestrator\", \"revise\", \"status-sync-manager\"]
           }",
           description="Update task ${task_number} status to REVISING"
         )
      
      3. Validate status-sync-manager return:
         a. Parse return as JSON
         b. Extract status field: sync_status=$(echo "$sync_return" | jq -r '.status')
         c. If sync_status != "completed":
            - Log error: "Preflight failed: status-sync-manager returned ${sync_status}"
            - Extract error message: error_msg=$(echo "$sync_return" | jq -r '.errors[0].message')
            - Return error to user: "Failed to update status to REVISING: ${error_msg}"
            - ABORT - do NOT proceed to Stage 2 (Delegate)
         d. Verify files_updated includes TODO.md and state.json:
            - files_updated=$(echo "$sync_return" | jq -r '.files_updated[]')
            - If TODO.md not in files_updated: Log warning "TODO.md not updated"
            - If state.json not in files_updated: Log warning "state.json not updated"
      
      4. Verify status was actually updated (defense in depth):
         
         Log: "Preflight: Verifying status update succeeded"
         
         Read state.json to check current status:
         actual_status=$(jq -r --arg num "$task_number" \
           '.active_projects[] | select(.project_number == ($num | tonumber)) | .status' \
           .opencode/specs/state.json)
         
         If actual_status != "revising":
           - Log error: "Preflight verification failed"
           - Log: "Expected status: revising"
           - Log: "Actual status: ${actual_status}"
           - Return error to user: "Status update verification failed. Run /task --sync to fix state."
           - ABORT - do NOT proceed to Stage 2 (Delegate)
         
         Log: "Preflight: Status verified as 'revising'"
      
      5. Log preflight success:
         - Log: "✓ Preflight completed: Task ${task_number} status updated to REVISING"
         - Log: "Files updated: ${files_updated}"
         - Log: "Proceeding to Stage 2 (Delegate to reviser)"
    </process>
    <validation>
      - status-sync-manager returned "completed" status
      - TODO.md and state.json were updated
      - state.json status field verified as "revising"
      - User can now see [REVISING] status immediately
    </validation>
    <checkpoint>Status verified as [REVISING] before delegation to reviser</checkpoint>
  </stage>
  
  <stage id="2" name="Delegate">
    <action>Delegate to planner with parsed context</action>
    <process>
      1. Use session_id from Stage 1.5 (already generated)
         - session_id is already set from Preflight stage
         - Log: "Delegating to ${target_agent} with session_id: ${session_id}"
      
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
  
  <stage id="3.5" name="Postflight">
    <action>Update status to [REVISED], link artifacts, create git commit</action>
    <process>
      CRITICAL: This stage ensures artifacts are linked and status is updated.
      This prevents manual fixes like those needed for Task 326.
      
      1. Extract artifacts from subagent return:
         
         Log: "Postflight: Extracting artifacts from reviser return"
         
         Parse artifacts array from subagent return:
         artifacts_json=$(echo "$subagent_return" | jq -c '.artifacts')
         artifact_count=$(echo "$artifacts_json" | jq 'length')
         
         Log: "Subagent returned ${artifact_count} artifact(s)"
         
         If artifact_count == 0:
           - Log warning: "Reviser returned no artifacts"
           - Log: "This may indicate revision failed or was incomplete"
           - Continue (will update status but no artifacts to link)
      
      2. Validate artifacts exist on disk (CRITICAL):
         
         Log: "Postflight: Validating artifacts exist on disk"
         
         For each artifact in artifacts array:
         for artifact_path in $(echo "$artifacts_json" | jq -r '.[].path'); do
           # Check file exists
           if [ ! -f "$artifact_path" ]; then
             echo "ERROR: Artifact not found on disk: $artifact_path"
             echo "Subagent claimed to create artifact but file does not exist"
             exit 1
           fi
           
           # Check file is non-empty
           if [ ! -s "$artifact_path" ]; then
             echo "ERROR: Artifact is empty: $artifact_path"
             echo "Subagent created file but wrote no content"
             exit 1
           fi
           
           # Get file size for logging
           file_size=$(stat -c%s "$artifact_path" 2>/dev/null || stat -f%z "$artifact_path")
           echo "✓ Validated artifact: $artifact_path (${file_size} bytes)"
         done
         
         Log: "✓ All ${artifact_count} artifact(s) validated on disk"
      
      3. Delegate to status-sync-manager to update status and link artifacts:
         
         Log: "Postflight: Updating task ${task_number} status to REVISED and linking artifacts"
         
         INVOKE status-sync-manager via task tool:
         task(
           subagent_type="status-sync-manager",
           prompt="{
             \"operation\": \"update_status\",
             \"task_number\": ${task_number},
             \"new_status\": \"revised\",
             \"timestamp\": \"$(date -I)\",
             \"session_id\": \"${session_id}\",
             \"delegation_depth\": 1,
             \"delegation_path\": [\"orchestrator\", \"revise\", \"status-sync-manager\"],
             \"validated_artifacts\": ${artifacts_json}
           }",
           description="Update task ${task_number} status to REVISED and link artifacts"
         )
      
      4. Validate status-sync-manager return:
         a. Parse return as JSON
         b. Extract status field: sync_status=$(echo "$sync_return" | jq -r '.status')
         c. If sync_status != "completed":
            - Log error: "Postflight failed: status-sync-manager returned ${sync_status}"
            - Extract error message: error_msg=$(echo "$sync_return" | jq -r '.errors[0].message')
            - Log warning: "Revision completed but status update failed: ${error_msg}"
            - Log: "Manual fix: /task --sync ${task_number}"
            - Continue (revision work is done, just status update failed)
         d. Verify files_updated includes TODO.md and state.json
      
      5. Verify status and artifact links were actually updated (defense in depth):
         
         Log: "Postflight: Verifying status and artifact links"
         
         Read state.json to check current status:
         actual_status=$(jq -r --arg num "$task_number" \
           '.active_projects[] | select(.project_number == ($num | tonumber)) | .status' \
           .opencode/specs/state.json)
         
         If actual_status != "revised":
           - Log warning: "Postflight verification failed - status not updated"
           - Log: "Expected status: revised"
           - Log: "Actual status: ${actual_status}"
           - Log: "Manual fix: /task --sync ${task_number}"
         Else:
           - Log: "✓ Status verified as 'revised'"
         
         Verify artifact links in TODO.md:
         for artifact_path in $(echo "$artifacts_json" | jq -r '.[].path'); do
           if ! grep -q "$artifact_path" .opencode/specs/TODO.md; then
             echo "WARNING: Artifact not linked in TODO.md: $artifact_path"
             echo "Manual fix: Edit TODO.md to add artifact link"
           else
             echo "✓ Verified artifact link in TODO.md: $artifact_path"
           fi
         done
      
      6. Delegate to git-workflow-manager to create commit:
         
         Log: "Postflight: Creating git commit"
         
         Extract artifact paths for git commit:
         artifact_paths=$(echo "$artifacts_json" | jq -r '.[].path' | tr '\n' ' ')
         
         INVOKE git-workflow-manager via task tool:
         task(
           subagent_type="git-workflow-manager",
           prompt="{
             \"scope_files\": [${artifact_paths}, \".opencode/specs/TODO.md\", \".opencode/specs/state.json\"],
             \"message_template\": \"task ${task_number}: plan revised\",
             \"task_context\": {
               \"task_number\": ${task_number},
               \"description\": \"plan revised\"
             },
             \"session_id\": \"${session_id}\",
             \"delegation_depth\": 1,
             \"delegation_path\": [\"orchestrator\", \"revise\", \"git-workflow-manager\"]
           }",
           description="Create git commit for task ${task_number} revision"
         )
      
      7. Validate git-workflow-manager return:
         a. Parse return as JSON
         b. Extract status field: git_status=$(echo "$git_return" | jq -r '.status')
         c. If git_status == "completed":
            - Extract commit hash: commit_hash=$(echo "$git_return" | jq -r '.commit_info.commit_hash')
            - Log: "✓ Git commit created: ${commit_hash}"
         d. If git_status == "failed":
            - Log warning: "Git commit failed (non-critical)"
            - Extract error message: error_msg=$(echo "$git_return" | jq -r '.errors[0].message')
            - Log: "Git error: ${error_msg}"
            - Log: "Manual fix: git add . && git commit -m 'task ${task_number}: plan revised'"
            - Continue (git failure doesn't fail the command)
      
      8. Log postflight success:
         - Log: "✓ Postflight completed: Task ${task_number} status updated to REVISED"
         - Log: "Artifacts linked: ${artifact_count}"
         - Log: "Git commit: ${commit_hash}"
         - Proceed to Stage 4 (RelayResult)
    </process>
    <validation>
      - All artifacts validated on disk before status update
      - status-sync-manager returned "completed" status
      - state.json status field verified as "revised"
      - Artifact links verified in TODO.md
      - Git commit created (or warning logged)
      - NO manual fixes needed
    </validation>
    <checkpoint>Status updated to [REVISED], artifacts linked and verified, git commit created</checkpoint>
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
