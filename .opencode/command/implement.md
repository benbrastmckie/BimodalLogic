---
name: implement
agent: orchestrator
description: "Execute implementation with resume support and [COMPLETED] status"
timeout: 7200
routing:
  language_based: true
  lean: lean-implementation-agent
  meta: meta
  default: implementer
context_loading:
  strategy: lazy
  index: ".opencode/context/index.md"
  required:
    - "core/orchestration/delegation.md"
    - "core/orchestration/state-management.md"
    - "core/standards/git-safety.md"
  max_context_size: 30000
---

**Task Input (required):** $ARGUMENTS

<context>
  <system_context>Implementation command with language-based routing</system_context>
  <task_context>Parse task number, validate, extract language, delegate to implementer</task_context>
</context>

<role>Implementation command agent - Parse arguments and route to appropriate implementer</role>

<task>
  Parse task number from $ARGUMENTS, lookup task in state.json, extract metadata, route to appropriate implementer based on language
</task>

<workflow_execution>
  <stage id="1" name="ParseAndValidate">
    <action>Parse task number and lookup in state.json</action>
    <process>
      1. Parse task number and flags from $ARGUMENTS
         - $ARGUMENTS contains: "259" or "259 custom prompt" or "105-107" or "259 --force"
         - Extract first token as task_number
         - Validate is integer or range (N-M)
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
      
      5. Validate task status allows implementation (skip if --force flag present)
         - If force_mode == false:
           case "$status" in
             "completed")
               echo "Error: Task $task_number already completed"
               echo "Recommendation: Task is done, no implementation needed"
               echo "To override: /implement $task_number --force"
               exit 1
               ;;
             "abandoned")
               echo "Error: Task $task_number is abandoned"
               echo "Recommendation: Un-abandon task before implementing"
               echo "To override: /implement $task_number --force"
               exit 1
               ;;
             "implementing")
               echo "Warning: Task $task_number is already being implemented"
               echo "If this is a stale status (e.g., previous implementation crashed):"
               echo "  1. Check for existing implementation artifacts"
               echo "  2. Use /task --sync to reset status if needed"
               echo "  3. Or use /implement $task_number --resume to continue"
               echo "To override: /implement $task_number --force"
               exit 1
               ;;
             "blocked")
               blocking_reason=$(echo "$task_data" | jq -r '.blocking_reason // "unknown"')
               echo "Error: Task $task_number is blocked"
               echo "Blocking reason: $blocking_reason"
               echo "Recommendation: Resolve blocker before implementing"
               echo "To override: /implement $task_number --force"
               exit 1
               ;;
             "not_started"|"researched"|"planned"|"partial"|"revised")
               # Status allows implementation, proceed
               ;;
             *)
               echo "Warning: Unknown status '$status' for task $task_number"
               echo "Proceeding with implementation, but status may be invalid"
               ;;
           esac
         - Else (force_mode == true):
           echo "WARNING: Using --force flag to override status validation"
           echo "Current status: $status"
           echo "Proceeding with implementation despite status"
      
      6. Extract custom prompt from $ARGUMENTS if present
         - If $ARGUMENTS has multiple tokens: custom_prompt = remaining tokens
         - Else: custom_prompt = ""
      
      7. Determine target agent based on language
         - lean → lean-implementation-agent
         - meta → meta
         - general → implementer
    </process>
    <checkpoint>Task validated, metadata extracted, target agent determined</checkpoint>
  </stage>
  
  <stage id="1.5" name="Preflight">
    <action>Update status to [IMPLEMENTING] before delegating to implementer</action>
    <process>
      CRITICAL: This stage MUST complete BEFORE Stage 2 (Delegate) begins.
      This ensures status updates immediately when implementation starts.
      
      1. Generate session_id for tracking:
         - session_id="sess_$(date +%s)_$(head -c 6 /dev/urandom | base64 | tr -dc 'a-z0-9')"
         - Store for later use: expected_session_id="$session_id"
         - Log: "Generated session_id: ${session_id}"
      
      2. Delegate to status-sync-manager to update status:
         
         Log: "Preflight: Updating task ${task_number} status to IMPLEMENTING"
         
         INVOKE status-sync-manager via task tool:
         task(
           subagent_type="status-sync-manager",
           prompt="{
             \"operation\": \"update_status\",
             \"task_number\": ${task_number},
             \"new_status\": \"implementing\",
             \"timestamp\": \"$(date -I)\",
             \"session_id\": \"${session_id}\",
             \"delegation_depth\": 1,
             \"delegation_path\": [\"orchestrator\", \"implement\", \"status-sync-manager\"]
           }",
           description="Update task ${task_number} status to IMPLEMENTING"
         )
      
      3. Validate status-sync-manager return:
         a. Parse return as JSON
         b. Extract status field: sync_status=$(echo "$sync_return" | jq -r '.status')
         c. If sync_status != "completed":
            - Log error: "Preflight failed: status-sync-manager returned ${sync_status}"
            - Extract error message: error_msg=$(echo "$sync_return" | jq -r '.errors[0].message')
            - Return error to user: "Failed to update status to IMPLEMENTING: ${error_msg}"
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
         
         If actual_status != "implementing":
           - Log error: "Preflight verification failed"
           - Log: "Expected status: implementing"
           - Log: "Actual status: ${actual_status}"
           - Return error to user: "Status update verification failed. Run /task --sync to fix state."
           - ABORT - do NOT proceed to Stage 2 (Delegate)
         
         Log: "Preflight: Status verified as 'implementing'"
      
      5. Log preflight success:
         - Log: "✓ Preflight completed: Task ${task_number} status updated to IMPLEMENTING"
         - Log: "Files updated: ${files_updated}"
         - Log: "Proceeding to Stage 2 (Delegate to implementer)"
    </process>
    <validation>
      - status-sync-manager returned "completed" status
      - TODO.md and state.json were updated
      - state.json status field verified as "implementing"
      - User can now see [IMPLEMENTING] status immediately
    </validation>
    <checkpoint>Status verified as [IMPLEMENTING] before delegation to implementer</checkpoint>
  </stage>
  
  <stage id="2" name="Delegate">
    <action>Delegate to implementer with parsed context</action>
    <process>
      1. Use session_id from Stage 1.5 (already generated)
         - session_id is already set from Preflight stage
         - Log: "Delegating to ${target_agent} with session_id: ${session_id}"
      
      2. Invoke target agent via task tool:
         task(
           subagent_type="${target_agent}",
           prompt="Implement task ${task_number}: ${description}. ${custom_prompt}",
           description="Implement task ${task_number}",
           session_id="${session_id}"
         )
      
      3. Wait for implementer to complete and capture return
         - Subagent returns JSON to stdout
         - Log: "Implementer completed, validating return"
         - Capture in variable: subagent_return
    </process>
    <checkpoint>Delegated to implementer, return captured</checkpoint>
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
                * Log error: "Error: Phantom implementation detected - status=completed but no artifacts"
                * Return error to user: "Subagent return validation failed: Phantom implementation detected"
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
    <action>Update status to [COMPLETED], link artifacts, create git commit</action>
    <process>
      CRITICAL: This stage ensures artifacts are linked and status is updated.
      This prevents manual fixes like those needed for Task 326.
      
      1. Extract artifacts from subagent return:
         
         Log: "Postflight: Extracting artifacts from implementer return"
         
         Parse artifacts array from subagent return:
         artifacts_json=$(echo "$subagent_return" | jq -c '.artifacts')
         artifact_count=$(echo "$artifacts_json" | jq 'length')
         
         Log: "Subagent returned ${artifact_count} artifact(s)"
         
         If artifact_count == 0:
           - Log warning: "Implementer returned no artifacts"
           - Log: "This may indicate implementation failed or was incomplete"
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
         
         Log: "Postflight: Updating task ${task_number} status to COMPLETED and linking artifacts"
         
         INVOKE status-sync-manager via task tool:
         task(
           subagent_type="status-sync-manager",
           prompt="{
             \"operation\": \"update_status\",
             \"task_number\": ${task_number},
             \"new_status\": \"completed\",
             \"timestamp\": \"$(date -I)\",
             \"session_id\": \"${session_id}\",
             \"delegation_depth\": 1,
             \"delegation_path\": [\"orchestrator\", \"implement\", \"status-sync-manager\"],
             \"validated_artifacts\": ${artifacts_json}
           }",
           description="Update task ${task_number} status to COMPLETED and link artifacts"
         )
      
      4. Validate status-sync-manager return:
         a. Parse return as JSON
         b. Extract status field: sync_status=$(echo "$sync_return" | jq -r '.status')
         c. If sync_status != "completed":
            - Log error: "Postflight failed: status-sync-manager returned ${sync_status}"
            - Extract error message: error_msg=$(echo "$sync_return" | jq -r '.errors[0].message')
            - Log warning: "Implementation completed but status update failed: ${error_msg}"
            - Log: "Manual fix: /task --sync ${task_number}"
            - Continue (implementation work is done, just status update failed)
         d. Verify files_updated includes TODO.md and state.json
      
      5. Verify status and artifact links were actually updated (defense in depth):
         
         Log: "Postflight: Verifying status and artifact links"
         
         Read state.json to check current status:
         actual_status=$(jq -r --arg num "$task_number" \
           '.active_projects[] | select(.project_number == ($num | tonumber)) | .status' \
           .opencode/specs/state.json)
         
         If actual_status != "completed":
           - Log warning: "Postflight verification failed - status not updated"
           - Log: "Expected status: completed"
           - Log: "Actual status: ${actual_status}"
           - Log: "Manual fix: /task --sync ${task_number}"
         Else:
           - Log: "✓ Status verified as 'completed'"
         
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
             \"message_template\": \"task ${task_number}: implementation completed\",
             \"task_context\": {
               \"task_number\": ${task_number},
               \"description\": \"implementation completed\"
             },
             \"session_id\": \"${session_id}\",
             \"delegation_depth\": 1,
             \"delegation_path\": [\"orchestrator\", \"implement\", \"git-workflow-manager\"]
           }",
           description="Create git commit for task ${task_number} implementation"
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
            - Log: "Manual fix: git add . && git commit -m 'task ${task_number}: implementation completed'"
            - Continue (git failure doesn't fail the command)
      
      8. Log postflight success:
         - Log: "✓ Postflight completed: Task ${task_number} status updated to COMPLETED"
         - Log: "Artifacts linked: ${artifact_count}"
         - Log: "Git commit: ${commit_hash}"
         - Proceed to Stage 4 (RelayResult)
    </process>
    <validation>
      - All artifacts validated on disk before status update
      - status-sync-manager returned "completed" status
      - state.json status field verified as "completed"
      - Artifact links verified in TODO.md
      - Git commit created (or warning logged)
      - NO manual fixes needed
    </validation>
    <checkpoint>Status updated to [COMPLETED], artifacts linked and verified, git commit created</checkpoint>
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

## Usage

```bash
/implement TASK_NUMBER [PROMPT] [--force]
/implement 196
/implement 196 "Focus on error handling"
/implement 105-107
/implement 196 --force  # Override status validation
```

**Flags:**
- `--force`: Override status validation (advanced users only). Use to bypass already-in-progress or blocked checks.

## What This Does

1. Parses task number from arguments
2. Validates task exists in state.json (8x faster than TODO.md parsing)
3. Extracts all metadata at once (language, status, description, priority)
4. Routes to appropriate implementation agent based on task language
5. Agent executes implementation (plan-based or direct)
6. Creates implementation artifacts
7. Updates task status to [COMPLETED] via status-sync-manager
8. Creates git commit(s)

## Language-Based Routing

| Language | Agent | Tools |
|----------|-------|-------|
| lean | lean-implementation-agent | lean-lsp-mcp, lake build |
| meta | meta | File operations, delegation to meta subagents |
| general | implementer | File operations, git |

## Features

- **Resume Support**: Automatic resume from incomplete phases if plan exists
- **Batch Support**: Can implement multiple tasks sequentially (e.g., 105-107)
- **Plan-Based**: Follows implementation plan if exists, otherwise direct execution

See `.opencode/agent/subagents/implementer.md` for details.
