---
name: plan
agent: orchestrator
description: "Create implementation plans with [PLANNED] status"
context_level: 2
language: markdown
routing:
  language_based: true
  lean: lean-planner
  default: planner
timeout: 1800
context_loading:
  strategy: lazy
  index: ".opencode/context/index.md"
  required:
    - "core/orchestration/delegation.md"
    - "core/orchestration/state-management.md"
    - "core/orchestration/routing.md"
  optional:
    - "project/lean4/processes/end-to-end-proof-workflow.md"
  max_context_size: 50000
---

**Task Input (required):** $ARGUMENTS

<context>
  <system_context>Planning command with language-based routing</system_context>
  <task_context>Parse task number, validate, extract language, delegate to planner</task_context>
</context>

<role>Planning command agent - Parse arguments and route to appropriate planner</role>

<task>
  Parse task number from $ARGUMENTS, lookup task in state.json, extract metadata, route to appropriate planner based on language
</task>

<workflow_execution>
  <stage id="1" name="ParseAndValidate">
    <action>Parse task number and lookup in state.json</action>
    <process>
      1. Parse task number and flags from $ARGUMENTS
         - $ARGUMENTS contains: "196" or "196 Focus on phase breakdown" or "196 --force"
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
      
      5. Validate task status allows planning (skip if --force flag present)
         - If force_mode == false:
           case "$status" in
             "completed")
               echo "Error: Task $task_number already completed"
               echo "Recommendation: Task is done, no planning needed"
               echo "To override: /plan $task_number --force"
               exit 1
               ;;
             "abandoned")
               echo "Error: Task $task_number is abandoned"
               echo "Recommendation: Un-abandon task before planning"
               echo "To override: /plan $task_number --force"
               exit 1
               ;;
             "planning")
               echo "Warning: Task $task_number is already being planned"
               echo "If this is a stale status (e.g., previous planning crashed):"
               echo "  1. Check for existing plan artifacts"
               echo "  2. Use /task --sync to reset status if needed"
               echo "To override: /plan $task_number --force"
               exit 1
               ;;
             "planned")
               echo "Info: Task $task_number already has a plan"
               echo "Plan: $plan_path"
               echo "Recommendation: Use /revise $task_number to update plan"
               echo "To override: /plan $task_number --force"
               exit 0
               ;;
             "not_started"|"researched"|"blocked"|"partial")
               # Status allows planning, proceed
               ;;
             *)
               echo "Warning: Unknown status '$status' for task $task_number"
               echo "Proceeding with planning, but status may be invalid"
               ;;
           esac
         - Else (force_mode == true):
           echo "WARNING: Using --force flag to override status validation"
           echo "Current status: $status"
           echo "Proceeding with planning despite status"
      
      6. Check if plan already exists (warn if it does)
         - If plan_path is not empty: Warn "Plan exists at $plan_path. Use /revise to update."
      
       7. Extract custom prompt from $ARGUMENTS if present
          - If $ARGUMENTS has multiple tokens: custom_prompt = remaining tokens
          - Else: custom_prompt = ""
       
       8. Determine target agent based on language (CRITICAL - language-based routing)
          - Extract language from task metadata (already extracted in step 4)
          - Apply routing rules:
            * If language == "lean": target_agent = "lean-planner"
            * Else (language == "general" or any other value): target_agent = "planner"
          - Validate routing decision:
            * Verify target_agent is set to either "lean-planner" or "planner"
            * If target_agent is not set: Return error "Routing failed: target_agent not determined"
          - Log routing decision:
            * Log: "Task ${task_number} language: ${language}"
            * Log: "Routing to: ${target_agent}"
          
          IMPORTANT: Do NOT default to lean-planner for non-lean tasks.
          Only use lean-planner when language == "lean".
          All other languages (general, markdown, python, etc.) use planner.
    </process>
    <checkpoint>Task validated, metadata extracted, target agent determined</checkpoint>
  </stage>
  
  <stage id="1.5" name="Preflight">
    <action>Update status to [PLANNING] before delegating to planner</action>
    <process>
      CRITICAL: This stage MUST complete BEFORE Stage 2 (Delegate) begins.
      This ensures status updates immediately when planning starts.
      
      1. Generate session_id for tracking:
         - session_id="sess_$(date +%s)_$(head -c 6 /dev/urandom | base64 | tr -dc 'a-z0-9')"
         - Store for later use: expected_session_id="$session_id"
         - Log: "Generated session_id: ${session_id}"
      
      2. Delegate to status-sync-manager to update status:
         
         Log: "Preflight: Updating task ${task_number} status to PLANNING"
         
         INVOKE status-sync-manager via task tool:
         task(
           subagent_type="status-sync-manager",
           prompt="{
             \"operation\": \"update_status\",
             \"task_number\": ${task_number},
             \"new_status\": \"planning\",
             \"timestamp\": \"$(date -I)\",
             \"session_id\": \"${session_id}\",
             \"delegation_depth\": 1,
             \"delegation_path\": [\"orchestrator\", \"plan\", \"status-sync-manager\"]
           }",
           description="Update task ${task_number} status to PLANNING"
         )
      
      3. Validate status-sync-manager return:
         a. Parse return as JSON
         b. Extract status field: sync_status=$(echo "$sync_return" | jq -r '.status')
         c. If sync_status != "completed":
            - Log error: "Preflight failed: status-sync-manager returned ${sync_status}"
            - Extract error message: error_msg=$(echo "$sync_return" | jq -r '.errors[0].message')
            - Return error to user: "Failed to update status to PLANNING: ${error_msg}"
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
         
         If actual_status != "planning":
           - Log error: "Preflight verification failed"
           - Log: "Expected status: planning"
           - Log: "Actual status: ${actual_status}"
           - Return error to user: "Status update verification failed. Run /task --sync to fix state."
           - ABORT - do NOT proceed to Stage 2 (Delegate)
         
         Log: "Preflight: Status verified as 'planning'"
      
      5. Log preflight success:
         - Log: "✓ Preflight completed: Task ${task_number} status updated to PLANNING"
         - Log: "Files updated: ${files_updated}"
         - Log: "Proceeding to Stage 2 (Delegate to planner)"
    </process>
    <validation>
      - status-sync-manager returned "completed" status
      - TODO.md and state.json were updated
      - state.json status field verified as "planning"
      - User can now see [PLANNING] status immediately
    </validation>
    <checkpoint>Status verified as [PLANNING] before delegation to planner</checkpoint>
  </stage>
  
  <stage id="2" name="Delegate">
    <action>Delegate to planner with parsed context</action>
    <process>
      1. Use session_id from Stage 1.5 (already generated)
         - session_id is already set from Preflight stage
         - Log: "Delegating to ${target_agent} with session_id: ${session_id}"
      
      2. Invoke target agent via task tool:
         task(
           subagent_type="${target_agent}",
           prompt="Create implementation plan for task ${task_number}: ${description}. ${custom_prompt}",
           description="Plan task ${task_number}",
           session_id="${session_id}"
         )
      
      3. Wait for planner to complete and capture return
         - Subagent returns JSON to stdout
         - Capture in variable: subagent_return
         - Log: "Planner completed, validating return"
    </process>
    <checkpoint>Delegated to planner, return captured</checkpoint>
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
                * Log error: "Error: Phantom planning detected - status=completed but no artifacts"
                * Return error to user: "Subagent return validation failed: Phantom planning detected"
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
    <action>Update status to [PLANNED], link artifacts, create git commit</action>
    <process>
      CRITICAL: This stage ensures artifacts are linked and status is updated.
      This prevents manual fixes like those needed for Task 326.
      
      1. Extract artifacts from subagent return:
         
         Log: "Postflight: Extracting artifacts from planner return"
         
         Parse artifacts array from subagent return:
         artifacts_json=$(echo "$subagent_return" | jq -c '.artifacts')
         artifact_count=$(echo "$artifacts_json" | jq 'length')
         
         Log: "Subagent returned ${artifact_count} artifact(s)"
         
         If artifact_count == 0:
           - Log warning: "Planner returned no artifacts"
           - Log: "This may indicate planning failed or was incomplete"
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
         
         Log: "Postflight: Updating task ${task_number} status to PLANNED and linking artifacts"
         
         INVOKE status-sync-manager via task tool:
         task(
           subagent_type="status-sync-manager",
           prompt="{
             \"operation\": \"update_status\",
             \"task_number\": ${task_number},
             \"new_status\": \"planned\",
             \"timestamp\": \"$(date -I)\",
             \"session_id\": \"${session_id}\",
             \"delegation_depth\": 1,
             \"delegation_path\": [\"orchestrator\", \"plan\", \"status-sync-manager\"],
             \"validated_artifacts\": ${artifacts_json}
           }",
           description="Update task ${task_number} status to PLANNED and link artifacts"
         )
      
      4. Validate status-sync-manager return:
         a. Parse return as JSON
         b. Extract status field: sync_status=$(echo "$sync_return" | jq -r '.status')
         c. If sync_status != "completed":
            - Log error: "Postflight failed: status-sync-manager returned ${sync_status}"
            - Extract error message: error_msg=$(echo "$sync_return" | jq -r '.errors[0].message')
            - Log warning: "Planning completed but status update failed: ${error_msg}"
            - Log: "Manual fix: /task --sync ${task_number}"
            - Continue (planning work is done, just status update failed)
         d. Verify files_updated includes TODO.md and state.json
      
      5. Verify status and artifact links were actually updated (defense in depth):
         
         Log: "Postflight: Verifying status and artifact links"
         
         Read state.json to check current status:
         actual_status=$(jq -r --arg num "$task_number" \
           '.active_projects[] | select(.project_number == ($num | tonumber)) | .status' \
           .opencode/specs/state.json)
         
         If actual_status != "planned":
           - Log warning: "Postflight verification failed - status not updated"
           - Log: "Expected status: planned"
           - Log: "Actual status: ${actual_status}"
           - Log: "Manual fix: /task --sync ${task_number}"
         Else:
           - Log: "✓ Status verified as 'planned'"
         
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
             \"message_template\": \"task ${task_number}: plan created\",
             \"task_context\": {
               \"task_number\": ${task_number},
               \"description\": \"plan created\"
             },
             \"session_id\": \"${session_id}\",
             \"delegation_depth\": 1,
             \"delegation_path\": [\"orchestrator\", \"plan\", \"git-workflow-manager\"]
           }",
           description="Create git commit for task ${task_number} plan"
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
            - Log: "Manual fix: git add . && git commit -m 'task ${task_number}: plan created'"
            - Continue (git failure doesn't fail the command)
      
      8. Log postflight success:
         - Log: "✓ Postflight completed: Task ${task_number} status updated to PLANNED"
         - Log: "Artifacts linked: ${artifact_count}"
         - Log: "Git commit: ${commit_hash}"
         - Proceed to Stage 4 (RelayResult)
    </process>
    <validation>
      - All artifacts validated on disk before status update
      - status-sync-manager returned "completed" status
      - state.json status field verified as "planned"
      - Artifact links verified in TODO.md
      - Git commit created (or warning logged)
      - NO manual fixes needed
    </validation>
    <checkpoint>Status updated to [PLANNED], artifacts linked and verified, git commit created</checkpoint>
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

**Usage:** `/plan TASK_NUMBER [PROMPT]`

## Description

Creates implementation plans with phased breakdown, effort estimates, and research integration. Supports language-based routing: Lean tasks route to lean-planner (with proof strategies and mathlib integration), general tasks route to planner.

## Command Workflow

**Plan command handles (Stage 1-2):**
- **Stage 1 (ParseAndValidate):** Parse task number, lookup in state.json (8x faster), extract all metadata, validate, determine target agent
- **Stage 2 (Delegate):** Invoke target planner and relay result to user

**Planner/Lean-planner subagent handles:**
- Update status to [PLANNING] at beginning (preflight)
- Research integration (automatic harvesting from TODO.md)
- Phase breakdown (1-2 hours per phase target)
- Effort estimation
- Plan template compliance
- Update status to [PLANNED] at end (postflight)
- Git commits

## Arguments

- `TASK_NUMBER` (required): Task number from TODO.md
- `PROMPT` (optional): Custom planning focus or instructions
- `--force` (optional): Override status validation (advanced users only)

## Examples

```bash
/plan 196                          # Create plan for task 196
/plan 196 "Focus on phase breakdown"  # Create plan with custom focus
/plan 196 --force                  # Override status validation
```

## Delegation

**Target Agent:** Language-based routing:
- `lean-planner` (`.opencode/agent/subagents/lean-planner.md`) for Lean tasks
- `planner` (`.opencode/agent/subagents/planner.md`) for all other tasks

**Timeout:** 1800s (30 minutes)  
**Language-Based Routing:** Yes (routes based on task language field)

**Routing Rules:**
- `language == "lean"` → `lean-planner` (proof strategies, mathlib integration)
- `language == "general"` or any other → `planner` (general implementation planning)

**Planner Responsibilities:**
- Update status to [PLANNING] at beginning (preflight)
- Harvest research artifacts from TODO.md links
- Create phased implementation plan
- Follow plan.md template standard
- Update status to [PLANNED] at end (postflight)
- Update status atomically via status-sync-manager
- Create git commit via git-workflow-manager

## Quality Standards

**Plan Template Compliance:**
- Metadata section with all required fields
- Phase breakdown with [NOT STARTED] markers
- Acceptance criteria per phase
- Effort estimates (1-2 hours per phase)
- Success metrics

**Atomic Updates:**
- TODO.md (status, timestamps, plan link)
- state.json (status, timestamps, plan_path, plan_metadata)
- Project state.json (lazy created if needed)

**Lazy Directory Creation:**
- `.opencode/specs/{number}_{slug}/` created when writing plan
- `plans/` subdirectory created when writing implementation-001.md

## Error Handling

**Task Not Found:**
```
Error: Task {task_number} not found in .opencode/specs/TODO.md
Recommendation: Verify task number exists in TODO.md
```

**Invalid Task Number:**
```
Error: Task number must be an integer. Got: {input}
Usage: /plan TASK_NUMBER [PROMPT]
```

**Task Already Completed:**
```
Error: Task {task_number} is already [COMPLETED]
Recommendation: Cannot plan completed tasks
```

**Plan Already Exists:**
```
Warning: Plan already exists for task {task_number}
Existing plan: {plan_path}
Recommendation: Use /revise {task_number} to update existing plan
```

**Planning Timeout:**
```
Error: Planning timed out after 1800s
Status: Partial plan may exist
Recommendation: Resume with /plan {task_number}
```

## Notes

- **Research Harvesting**: Planner automatically loads research artifacts from TODO.md links
- **Phase Sizing**: Phases kept small (1-2 hours each) for manageable execution
- **Template Compliance**: All plans follow plan.md standard exactly
- **Atomic Updates**: status-sync-manager ensures consistency across files
- **Git Workflow**: Delegated to git-workflow-manager for standardized commits

For detailed workflow documentation, see:
- `.opencode/context/project/lean4/processes/end-to-end-proof-workflow.md`
- `.opencode/agent/subagents/planner.md`
