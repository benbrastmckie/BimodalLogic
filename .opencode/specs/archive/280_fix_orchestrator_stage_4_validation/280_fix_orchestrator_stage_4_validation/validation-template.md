# Subagent Return Validation Template

## Overview

This template provides a reusable validation section for command files that delegate to subagents. It implements all 5 validation steps from `validation-rules.md` to prevent phantom operations and enforce return format.

## Usage

Add this as **Stage 3: ValidateReturn** after **Stage 2: Delegate** in command files.

## Template

```markdown
<stage id="3" name="ValidateReturn">
  <action>Validate subagent return format and artifacts</action>
  <process>
    1. Capture subagent return
       - Store return in variable: subagent_return
       - Log return for debugging (first 500 chars)
    
    2. VALIDATION STEP 1: Validate JSON Structure
       - Parse return as JSON using jq
       - If parsing fails:
         * Log error: "[FAIL] Invalid JSON return from ${agent}"
         * Return error to user: "Subagent return validation failed: Cannot parse return as JSON"
         * Recommendation: "Fix ${agent} subagent return format"
         * Exit with error
       - If parsing succeeds:
         * Log: "[PASS] Return is valid JSON"
    
    3. VALIDATION STEP 2: Validate Required Fields
       - Check required fields exist: status, summary, artifacts, metadata
       - Check metadata subfields exist: session_id, agent_type, delegation_depth, delegation_path
       - For each missing field:
         * Log error: "[FAIL] Missing required field: ${field}"
         * Return error to user: "Subagent return validation failed: Missing required field: ${field}"
         * Recommendation: "Fix ${agent} subagent to include all required fields"
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
         * Recommendation: "Fix ${agent} subagent to use valid status enum"
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
         * Recommendation: "Fix ${agent} subagent to return correct session_id"
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
              * Return error to user: "Subagent return validation failed: Phantom operation detected"
              * Recommendation: "Verify ${agent} creates artifacts before updating status"
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
                - Recommendation: "Verify ${agent} writes artifacts to correct paths"
                - Exit with error
              * If file exists:
                - Log: "[PASS] Artifact exists: ${path}"
         
         c. Verify each artifact is non-empty
            - For each path in artifact_paths:
              * Check file is non-empty: [ -s "$path" ]
              * If file is empty:
                - Log error: "[FAIL] Artifact is empty: ${path}"
                - Return error to user: "Subagent return validation failed: Empty artifact: ${path}"
                - Recommendation: "Verify ${agent} writes content to artifacts"
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
       - Proceed to next stage
  </process>
  <checkpoint>Subagent return validated, all checks passed</checkpoint>
</stage>
```

## Implementation Notes

### Error Handling

All validation failures should:
1. Log error with clear message
2. Return error to user with actionable recommendation
3. Exit immediately (fail fast)
4. NOT proceed to next stage

### Validation Order

The 5 validation steps MUST be executed in order:
1. JSON structure (prerequisite for all other checks)
2. Required fields (prerequisite for field-specific checks)
3. Status enum (prerequisite for artifact validation)
4. Session ID (security check)
5. Artifacts (only if status=completed)

### Status-Dependent Validation

**CRITICAL**: Artifact validation is ONLY performed if status == "completed"

- `completed`: MUST have non-empty artifacts array, all files must exist and be non-empty
- `partial`: MAY have artifacts (not validated)
- `failed`: MAY have empty artifacts (not validated)
- `blocked`: MAY have empty artifacts (not validated)

This prevents false positives where legitimate partial/failed operations are rejected.

### Session ID Validation

Session ID validation requires the expected session_id to be available from delegation context. Command files should:
1. Generate session_id before delegation (Stage 2)
2. Pass session_id to subagent in delegation context
3. Store expected_session_id for validation (Stage 3)

### Artifact Path Validation

Artifact paths in return JSON are relative to project root. Validation should:
1. Check file exists using `[ -f "$path" ]`
2. Check file is non-empty using `[ -s "$path" ]`
3. Get file size using `stat` (cross-platform: `-c%s` for Linux, `-f%z` for macOS)

## Integration Example

Here's how to integrate this validation section into a command file:

```markdown
<workflow_execution>
  <stage id="1" name="ParseAndValidate">
    <!-- Parse arguments, validate task, extract metadata -->
  </stage>
  
  <stage id="2" name="Delegate">
    <action>Delegate to subagent with parsed context</action>
    <process>
      1. Generate session_id for tracking
         - session_id="sess_$(date +%s)_$(head -c 6 /dev/urandom | base64 | tr -dc 'a-z0-9')"
         - Store for validation: expected_session_id="$session_id"
      
      2. Invoke target agent via task tool:
         task(
           subagent_type="${target_agent}",
           prompt="...",
           description="...",
           context={
             "session_id": "${session_id}",
             ...
           }
         )
      
      3. Capture return
         - subagent_return=$(cat return.json)  # Or however return is captured
    </process>
  </stage>
  
  <stage id="3" name="ValidateReturn">
    <!-- Insert validation template here -->
  </stage>
  
  <stage id="4" name="RelayResult">
    <action>Relay validated result to user</action>
    <process>
      1. Format response for user
      2. Include summary, artifacts, next_steps
      3. Return to user
    </process>
  </stage>
</workflow_execution>
```

## Testing

To test validation, simulate malformed returns:

### Test Case 1: Plain Text Return
```bash
# Simulate plain text return
echo "Research completed successfully" > /tmp/test_return.json
# Expected: [FAIL] Invalid JSON return
```

### Test Case 2: Missing Required Field
```bash
# Simulate missing status field
echo '{"summary": "Done", "artifacts": []}' > /tmp/test_return.json
# Expected: [FAIL] Missing required field: status
```

### Test Case 3: Invalid Status
```bash
# Simulate invalid status
echo '{"status": "success", "summary": "Done", "artifacts": [], "metadata": {}}' > /tmp/test_return.json
# Expected: [FAIL] Invalid status: success
```

### Test Case 4: Phantom Research
```bash
# Simulate phantom research
echo '{"status": "completed", "summary": "Done", "artifacts": [], "metadata": {"session_id": "test"}}' > /tmp/test_return.json
# Expected: [FAIL] Phantom research detected
```

### Test Case 5: Missing Artifact File
```bash
# Simulate missing artifact
echo '{"status": "completed", "summary": "Done", "artifacts": [{"path": "/nonexistent/file.md"}], "metadata": {"session_id": "test"}}' > /tmp/test_return.json
# Expected: [FAIL] Artifact does not exist
```

### Test Case 6: Valid Return
```bash
# Create test artifact
echo "Test content" > /tmp/test_artifact.md

# Simulate valid return
echo '{"status": "completed", "summary": "Done", "artifacts": [{"path": "/tmp/test_artifact.md"}], "metadata": {"session_id": "test", "agent_type": "researcher", "delegation_depth": 1, "delegation_path": ["orchestrator", "research", "researcher"]}}' > /tmp/test_return.json
# Expected: [PASS] Return validation succeeded
```

## See Also

- **Validation Rules**: `.opencode/context/core/system/validation-rules.md`
- **Validation Strategy**: `.opencode/context/core/system/validation-strategy.md`
- **Subagent Return Format**: `.opencode/context/core/standards/subagent-return-format.md`
- **Command Files**: `.opencode/command/*.md`
