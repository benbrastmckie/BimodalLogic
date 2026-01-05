---
name: research
agent: orchestrator
description: "Conduct research and create reports with [RESEARCHED] status"
timeout: 3600
routing:
  language_based: true
  lean: lean-research-agent
  default: researcher
---

**Task Input (required):** $ARGUMENTS

<context>
  <system_context>Research command with language-based routing</system_context>
  <task_context>Parse task number, validate, extract language, delegate to researcher</task_context>
</context>

<role>Research command agent - Parse arguments and route to appropriate researcher</role>

<task>
  Parse task number from $ARGUMENTS, lookup task in state.json, extract metadata, route to appropriate researcher based on language
</task>

<workflow_execution>
  <stage id="1" name="ParseAndValidate">
    <action>Parse task number and lookup in state.json</action>
    <process>
      1. Parse task number and flags from $ARGUMENTS
         - $ARGUMENTS contains: "197" or "197 Focus on CLI integration" or "197 --force"
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
      
      5. Validate task status allows research (skip if --force flag present)
         - If force_mode == false:
           case "$status" in
             "completed")
               echo "Error: Task $task_number already completed"
               echo "Recommendation: Task is done, no research needed"
               echo "To override: /research $task_number --force"
               exit 1
               ;;
             "abandoned")
               echo "Error: Task $task_number is abandoned"
               echo "Recommendation: Un-abandon task before researching"
               echo "To override: /research $task_number --force"
               exit 1
               ;;
             "researching")
               echo "Warning: Task $task_number is already being researched"
               echo "If this is a stale status (e.g., previous research crashed):"
               echo "  1. Check for existing research artifacts"
               echo "  2. Use /sync to reset status if needed"
               echo "To override: /research $task_number --force"
               exit 1
               ;;
             "researched")
               research_path=$(echo "$task_data" | jq -r '.artifacts[0] // "unknown"')
               echo "Info: Task $task_number already researched"
               echo "Research report: $research_path"
               echo "Recommendation: Use /plan to continue workflow"
               echo "To override: /research $task_number --force"
               exit 0
               ;;
             "not_started"|"planned"|"implementing"|"blocked"|"partial")
               # Status allows research, proceed
               ;;
             *)
               echo "Warning: Unknown status '$status' for task $task_number"
               echo "Proceeding with research, but status may be invalid"
               ;;
           esac
         - Else (force_mode == true):
           echo "WARNING: Using --force flag to override status validation"
           echo "Current status: $status"
           echo "Proceeding with research despite status"
      
      6. Extract research focus from $ARGUMENTS if present
         - If $ARGUMENTS has multiple tokens: research_focus = remaining tokens
         - Else: research_focus = ""
      
      7. Determine target agent based on language
         - lean → lean-research-agent
         - general → researcher
    </process>
    <checkpoint>Task validated, metadata extracted, target agent determined</checkpoint>
  </stage>
  
  <stage id="2" name="Delegate">
    <action>Delegate to researcher with parsed context</action>
    <process>
      1. Generate session_id for tracking
         - session_id="sess_$(date +%s)_$(head -c 6 /dev/urandom | base64 | tr -dc 'a-z0-9')"
         - Store for validation: expected_session_id="$session_id"
      
      2. Invoke target agent via task tool:
         task(
           subagent_type="${target_agent}",
           prompt="Research task ${task_number}: ${description}. Focus: ${research_focus}",
           description="Research task ${task_number}"
         )
      
      3. Wait for researcher to complete and capture return
         - Subagent returns JSON to stdout
         - Capture in variable: subagent_return
    </process>
    <checkpoint>Delegated to researcher, return captured</checkpoint>
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
                * Log error: "Error: Phantom research detected - status=completed but no artifacts"
                * Return error to user: "Subagent return validation failed: Phantom research detected"
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

# /research - Research Command

Conduct research for tasks and create research reports with [RESEARCHED] status.

## Usage

```bash
/research TASK_NUMBER [PROMPT] [--force]
/research 197
/research 197 "Focus on CLI integration"
/research 197 --force  # Override status validation
```

**Flags:**
- `--force`: Override status validation (advanced users only). Use to bypass already-in-progress or already-completed checks.

## What This Does

1. Validates task exists in state.json (8x faster than TODO.md parsing)
2. Extracts all metadata at once (language, status, description, priority)
3. Routes to appropriate research agent based on task language
4. Agent conducts research using specialized tools
5. Creates research report in `.opencode/specs/{task}_*/reports/`
6. Updates task status to [RESEARCHED] via status-sync-manager
7. Creates git commit

## Language-Based Routing

| Language | Agent | Tools |
|----------|-------|-------|
| lean | lean-research-agent | LeanExplore, Loogle, LeanSearch |
| general | researcher | Web search, documentation |

See `.opencode/agent/subagents/researcher.md` for details.
