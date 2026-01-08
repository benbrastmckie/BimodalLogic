---
name: errors
agent: orchestrator
description: "Analyze errors.json, group errors, recommend fixes, track effectiveness"
context_level: 2
language: markdown
routing:
  language_based: false
  target_agent: error-diagnostics-agent
timeout: 1800
context_loading:
  strategy: lazy
  index: ".opencode/context/index.md"
  required:
    - "core/orchestration/delegation.md"
    - "core/orchestration/state-management.md"
    - "core/formats/subagent-return.md"
  max_context_size: 50000
---

**Task Input (optional):** $ARGUMENTS

<context>
  <system_context>Error analysis command with read-only diagnostics</system_context>
  <task_context>Parse flags, load errors.json, filter errors, delegate to error-diagnostics-agent</task_context>
</context>

<role>Error analysis command agent - Parse flags and delegate to error diagnostics specialist</role>

<task>
  Parse flags from $ARGUMENTS, load and filter errors.json, delegate to error-diagnostics-agent for analysis
</task>

<workflow_execution>
  <stage id="1" name="ParseAndValidate">
    <action>Parse flags, load errors.json, filter errors</action>
    <process>
      1. Parse flags from $ARGUMENTS
         - Default: No flags (analyze unaddressed errors only)
         - --all: Analyze all errors (including addressed)
         - --type TYPE: Filter to specific error type
         - Extract flags: all_flag=false, filter_type=""
         - If $ARGUMENTS contains "--all": all_flag=true
         - If $ARGUMENTS contains "--type": Extract next token as filter_type
         - Log: "Flags: all=${all_flag}, type=${filter_type}"
      
      2. Validate errors.json exists and is valid
         - Check .opencode/specs/errors.json exists
         - If missing: Return "No errors.json found. System is error-free or errors.json not initialized."
         - Validate is valid JSON with jq
         - If invalid JSON: Return error "errors.json is corrupted. Manual inspection required."
      
      3. Load errors.json content
         - Read full errors.json into memory
         - errors_data=$(cat .opencode/specs/errors.json)
         - Log: "Loaded errors.json"
      
      4. Filter errors based on flags
         - If all_flag == false:
           * Filter to errors where status != "addressed"
           * filtered_errors=$(echo "$errors_data" | jq '[.[] | select(.status != "addressed")]')
         - Else (all_flag == true):
           * Use all errors
           * filtered_errors="$errors_data"
         
         - If filter_type != "":
           * Further filter to errors where type == filter_type
           * filtered_errors=$(echo "$filtered_errors" | jq --arg type "$filter_type" '[.[] | select(.type == $type)]')
         
         - Count errors: error_count=$(echo "$filtered_errors" | jq 'length')
         - Log: "Filtered to ${error_count} error(s)"
      
      5. Check if any errors to analyze
         - If error_count == 0:
           * Log: "No errors found matching filter"
           * Return to user: "No errors found matching filter. Use --all to see all errors."
           * Exit (no delegation needed)
      
      6. Prepare errors for delegation
         - Convert filtered_errors to compact JSON
         - errors_json=$(echo "$filtered_errors" | jq -c '.')
         - Log: "Prepared ${error_count} error(s) for analysis"
    </process>
    <checkpoint>Flags parsed, errors loaded and filtered, ready for delegation</checkpoint>
  </stage>
  
  <stage id="2" name="Delegate">
    <action>Delegate to error-diagnostics-agent with filtered errors</action>
    <process>
      1. Generate session_id for tracking:
         - session_id="sess_$(date +%s)_$(head -c 6 /dev/urandom | base64 | tr -dc 'a-z0-9')"
         - Store for later use: expected_session_id="$session_id"
         - Log: "Generated session_id: ${session_id}"
      
      2. Invoke error-diagnostics-agent via task tool:
         task(
           subagent_type="error-diagnostics-agent",
           prompt="{
             \"errors_data\": ${errors_json},
             \"filter_type\": \"${filter_type}\",
             \"session_id\": \"${session_id}\",
             \"delegation_depth\": 1,
             \"delegation_path\": [\"orchestrator\", \"errors\", \"error-diagnostics-agent\"]
           }",
           description="Analyze ${error_count} error(s) from errors.json"
         )
      
      3. Wait for error-diagnostics-agent to complete and capture return
         - Subagent returns JSON to stdout
         - Capture in variable: subagent_return
         - Log: "Error-diagnostics-agent completed, validating return"
    </process>
    <checkpoint>Delegated to error-diagnostics-agent, return captured</checkpoint>
  </stage>
  
  <stage id="3" name="ValidateReturn">
    <action>Validate subagent return format and analysis</action>
    <process>
      1. Log return for debugging
         - Log first 500 chars of return
         - Log: "Validating return from error-diagnostics-agent"
      
      2. VALIDATION STEP 1: Validate JSON Structure
         - Parse return as JSON using jq
         - If parsing fails:
           * Log error: "[FAIL] Invalid JSON return from error-diagnostics-agent"
           * Return error to user: "Subagent return validation failed: Cannot parse return as JSON"
           * Recommendation: "Fix error-diagnostics-agent subagent return format"
           * Exit with error
         - If parsing succeeds:
           * Log: "[PASS] Return is valid JSON"
      
      3. VALIDATION STEP 2: Validate Required Fields
         - Check required fields exist: status, summary, metadata, analysis
         - Check metadata subfields exist: session_id, agent_type, delegation_depth, delegation_path
         - Check analysis subfields exist: error_groups, recommendations
         - For each missing field:
           * Log error: "[FAIL] Missing required field: ${field}"
           * Return error to user: "Subagent return validation failed: Missing required field: ${field}"
           * Recommendation: "Fix error-diagnostics-agent subagent to include all required fields"
           * Exit with error
         - If all fields present:
           * Log: "[PASS] All required fields present"
      
      4. VALIDATION STEP 3: Validate Status Field
         - Extract status from return: status=$(echo "$subagent_return" | jq -r '.status')
         - Check status is valid enum: completed, partial, failed
         - If status invalid:
           * Log error: "[FAIL] Invalid status: ${status}"
           * Log: "Valid statuses: completed, partial, failed"
           * Return error to user: "Subagent return validation failed: Invalid status: ${status}"
           * Recommendation: "Fix error-diagnostics-agent subagent to use valid status enum"
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
           * Recommendation: "Fix error-diagnostics-agent subagent to return correct session_id"
           * Exit with error
         - If match:
           * Log: "[PASS] Session ID matches"
      
      6. VALIDATION STEP 5: Validate Analysis Object
         - Extract analysis object: analysis=$(echo "$subagent_return" | jq -r '.analysis')
         - Check error_groups is array: error_groups=$(echo "$analysis" | jq '.error_groups')
         - Check recommendations is array: recommendations=$(echo "$analysis" | jq '.recommendations')
         - If error_groups or recommendations missing:
           * Log error: "[FAIL] Analysis object incomplete"
           * Return error to user: "Subagent return validation failed: Analysis object missing required fields"
           * Exit with error
         - If analysis complete:
           * Log: "[PASS] Analysis object validated"
      
      7. Validation Summary
         - Log: "[PASS] Return validation succeeded"
         - Log: "Status: ${status}"
         - Extract counts: 
           * group_count=$(echo "$analysis" | jq '.error_groups | length')
           * rec_count=$(echo "$analysis" | jq '.recommendations | length')
         - Log: "Error groups: ${group_count}, Recommendations: ${rec_count}"
    </process>
    <checkpoint>Subagent return validated, all checks passed</checkpoint>
  </stage>
  
  <stage id="4" name="RelayResult">
    <action>Relay validated result to user</action>
    <process>
      1. Extract key information from validated return
         - summary=$(echo "$subagent_return" | jq -r '.summary')
         - next_steps=$(echo "$subagent_return" | jq -r '.next_steps // "None"')
         - analysis=$(echo "$subagent_return" | jq -r '.analysis')
      
      2. Format error groups summary
         - Extract error groups: error_groups=$(echo "$analysis" | jq -r '.error_groups')
         - For each group:
           * type=$(echo "$group" | jq -r '.type')
           * count=$(echo "$group" | jq -r '.count')
           * severity=$(echo "$group" | jq -r '.severity')
           * root_cause=$(echo "$group" | jq -r '.root_cause')
           * Display: "- ${type} (${count} errors, ${severity}): ${root_cause}"
      
      3. Format top recommendations
         - Extract recommendations: recommendations=$(echo "$analysis" | jq -r '.recommendations')
         - Sort by priority (critical, high, medium, low)
         - Display top 5 recommendations:
           * priority=$(echo "$rec" | jq -r '.priority')
           * fix=$(echo "$rec" | jq -r '.fix')
           * effort=$(echo "$rec" | jq -r '.effort_hours')
           * Display: "- [${priority}] ${fix} (${effort}h)"
      
      4. Display fix effectiveness metrics (if available)
         - Extract fix_effectiveness: fix_eff=$(echo "$analysis" | jq -r '.fix_effectiveness')
         - If fix_eff != null:
           * success_rate=$(echo "$fix_eff" | jq -r '.success_rate')
           * failed_fixes=$(echo "$fix_eff" | jq -r '.failed_fixes')
           * Display: "Fix effectiveness: ${success_rate} success rate, ${failed_fixes} failed fixes"
      
      5. Format response for user
         - Display summary
         - Display error groups
         - Display top recommendations
         - Display fix effectiveness
         - Display next steps
      
      6. Return to user
    </process>
    <checkpoint>Result relayed to user</checkpoint>
  </stage>
</workflow_execution>

# /errors - Error Analysis Command

Analyze errors.json, group errors by type and root cause, check fix effectiveness, recommend targeted fixes.

## Usage

```bash
/errors                    # Analyze unaddressed errors
/errors --all              # Analyze all errors (including addressed)
/errors --type TYPE        # Filter to specific error type
```

**Flags:**
- `--all`: Analyze all errors (default: only unaddressed)
- `--type TYPE`: Filter to specific error type (delegation_hang, tool_failure, status_sync_failure, build_error, git_commit_failure)

## What This Does

1. Parses flags from arguments (--all, --type)
2. Loads and validates errors.json
3. Filters errors based on flags
4. Delegates to error-diagnostics-agent for analysis
5. Agent groups errors by type and root cause
6. Agent checks historical fix effectiveness
7. Agent recommends specific, actionable fixes
8. Returns analysis with error groups, recommendations, and next steps

## Error Types

- `delegation_hang` - Delegation timeouts or hangs
- `tool_failure` - Tool invocation failures
- `status_sync_failure` - Status synchronization failures
- `build_error` - Build/compilation errors
- `git_commit_failure` - Git commit failures

## Delegation

**Target Agent:** `error-diagnostics-agent` (`.opencode/agent/subagents/error-diagnostics-agent.md`)  
**Timeout:** 1800s (30 minutes)  
**Language-Based Routing:** No (always routes to error-diagnostics-agent)

**Error-Diagnostics-Agent Responsibilities:**
- Group errors by type and root cause
- Analyze error patterns and frequency
- Check historical fix effectiveness
- Identify recurring errors
- Generate specific, actionable fix recommendations
- Create fix plan outline with effort estimates
- Return analysis (no artifacts created - read-only analysis)

## Quality Standards

**Error Grouping:**
- Group errors intelligently by type and root cause
- Identify patterns and recurring issues
- Track fix effectiveness by checking recurrence

**Fix Recommendations:**
- Specific and actionable (code-level details)
- Prioritized by impact and effort
- Avoid approaches that failed historically
- Include testing recommendations

**Analysis Only:**
- No artifacts created (read-only analysis)
- No status updates (errors command doesn't modify state)
- No git commits (no file changes)

## Error Handling

**No Errors Found:**
```
No errors found matching filter
Suggestion: Use --all flag to see all errors
```

**Timeout:**
```
Error: Error analysis timed out after 1800s
Status: Partial analysis may exist
Recommendation: Retry with /errors
```

**Validation Failure:**
```
Error: Return validation failed
Details: {validation_error}
Recommendation: Fix error-diagnostics-agent subagent
```

## Notes

- **Read-Only**: /errors is read-only analysis, no file modifications
- **No Preflight/Postflight**: No status updates or git commits needed
- **Recurrence Tracking**: Checks if errors recurred after fix_attempted
- **Fix Effectiveness**: Marks fixes as successful or failed based on recurrence
- **Priority Assignment**: Critical errors → Priority: Critical, High severity → Priority: High

## Related Commands

- `/plan`: Create implementation plan for recommended fixes
- `/implement`: Execute fix plan

## See Also

- **Agent**: `.opencode/agent/subagents/error-diagnostics-agent.md`
- **Return Format**: `.opencode/context/core/formats/subagent-return.md`
