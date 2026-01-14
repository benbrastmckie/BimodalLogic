# Research Report: Fix Orchestrator Stage 4 Validation

## Metadata

- **Task**: 280 - Fix orchestrator Stage 4 validation to enforce subagent return format and prevent phantom research
- **Started**: 2026-01-04
- **Completed**: 2026-01-04
- **Effort**: 2 hours
- **Priority**: High
- **Dependencies**: None
- **Sources/Inputs**:
  - `.opencode/agent/orchestrator.md` (orchestrator implementation)
  - `.opencode/context/core/system/validation-rules.md` (validation documentation)
  - `.opencode/context/core/standards/subagent-return-format.md` (return format standard)
  - `.opencode/specs/TODO.md` (task 280 description)
  - Task 279 phantom research example
- **Artifacts**:
  - `.opencode/specs/280_fix_orchestrator_stage_4_validation/reports/research-001.md` (this report)
- **Standards**: status-markers.md, artifact-management.md, tasks.md, report.md

## Executive Summary

The orchestrator's Stage 4 (ValidateReturn) is documented but NOT implemented. It references `validation-rules.md` which contains comprehensive validation logic (JSON parsing, required fields, status enum, session_id, artifact existence), but the orchestrator only lists the validation steps without executing them. This allows subagents to return plain text or malformed JSON, claim "completed" status without creating artifacts, and cause "phantom research" where users think work is done but no artifacts exist.

**Root Cause**: Stage 4 is documentation-only, not executable validation logic.

**Impact**: ALL workflow commands (/research, /plan, /implement, /revise) are vulnerable to phantom operations.

**Solution**: Implement the validation logic from `validation-rules.md` in orchestrator Stage 4 as executable process steps.

## Context & Scope

### Problem Statement

When running `/research 279`, the researcher agent returned plain text instead of the required JSON format (per `subagent-return-format.md`), and the orchestrator's Stage 4 (ValidateReturn) did not catch this violation. This resulted in "phantom research" - the orchestrator claimed research was completed successfully, but:

- No artifacts were created
- No status was updated
- No directory was created
- No git commit was made

The orchestrator accepted the malformed return and reported success to the user.

### Current Behavior

**Orchestrator Stage 4 (ValidateReturn)** - Lines 200-212 of `orchestrator.md`:

```xml
<stage id="4" name="ValidateReturn">
  <action>Validate agent return format and content</action>
  <process>
    See: @.opencode/context/core/system/validation-rules.md
    
    1. Validate JSON structure
    2. Validate required fields
    3. Validate status enum
    4. Validate session_id
    5. Validate artifacts (if status=completed)
  </process>
  <checkpoint>Return validated and artifacts verified</checkpoint>
</stage>
```

**Problem**: This is DOCUMENTATION, not IMPLEMENTATION. The orchestrator lists 5 validation steps but doesn't execute them. It just says "See: validation-rules.md" and moves to Stage 5.

### Expected Behavior

Stage 4 should execute the validation logic documented in `validation-rules.md`:

1. **Parse JSON**: Verify return is valid JSON (not plain text)
2. **Check Required Fields**: Verify `status`, `summary`, `artifacts`, `metadata` fields exist
3. **Validate Status**: Verify status is one of: `completed`, `partial`, `failed`, `blocked`
4. **Validate Session ID**: Verify `metadata.session_id` matches expected session_id
5. **Validate Artifacts** (CRITICAL for preventing phantom research):
   - If status == "completed": Verify artifacts array is non-empty
   - For each artifact: Verify file exists on disk
   - For each artifact: Verify file is non-empty (size > 0 bytes)
6. **Reject Invalid Returns**: If any validation fails, return error to user with clear message

## Key Findings

### Finding 1: Validation Logic Exists But Is Not Executed

**Evidence**: `validation-rules.md` (277 lines) contains comprehensive validation logic:

- **Step 1: Validate JSON Structure** (lines 32-42):
  ```bash
  if ! echo "$return" | jq . > /dev/null 2>&1; then
    echo "[FAIL] Invalid JSON return from ${agent}"
    exit 1
  fi
  ```

- **Step 2: Validate Required Fields** (lines 44-58):
  ```bash
  required_fields=("status" "summary" "artifacts" "metadata" "session_id")
  for field in "${required_fields[@]}"; do
    if ! echo "$return" | jq -e ".${field}" > /dev/null 2>&1; then
      echo "[FAIL] Missing required field: ${field}"
      exit 1
    fi
  done
  ```

- **Step 3: Validate Status Field** (lines 60-74):
  ```bash
  status=$(echo "$return" | jq -r '.status')
  valid_statuses=("completed" "partial" "failed" "blocked")
  if [[ ! " ${valid_statuses[@]} " =~ " ${status} " ]]; then
    echo "[FAIL] Invalid status: ${status}"
    exit 1
  fi
  ```

- **Step 4: Validate Session ID** (lines 76-90):
  ```bash
  returned_session_id=$(echo "$return" | jq -r '.session_id')
  if [ "$returned_session_id" != "$expected_session_id" ]; then
    echo "[FAIL] Session ID mismatch"
    exit 1
  fi
  ```

- **Step 5: Validate Artifacts** (lines 105-169) - CRITICAL:
  ```bash
  if [ "$status" == "completed" ]; then
    artifact_count=$(echo "$return" | jq '.artifacts | length')
    if [ $artifact_count -eq 0 ]; then
      echo "[FAIL] Agent returned 'completed' status but created no artifacts"
      echo "Error: Phantom research detected - status=completed but no artifacts"
      exit 1
    fi
    
    artifact_paths=$(echo "$return" | jq -r '.artifacts[].path')
    for path in $artifact_paths; do
      if [ ! -f "$path" ]; then
        echo "[FAIL] Artifact does not exist: ${path}"
        exit 1
      fi
      if [ ! -s "$path" ]; then
        echo "[FAIL] Artifact is empty: ${path}"
        exit 1
      fi
    done
  fi
  ```

**Analysis**: All validation logic is documented in `validation-rules.md` but NOT executed by orchestrator Stage 4. The orchestrator just references the file and lists the steps without implementing them.

### Finding 2: Phantom Research Example (Task 279)

**Evidence**:
- Task 279 exists in TODO.md with status `[NOT STARTED]`
- No directory exists: `.opencode/specs/279_*` (verified with `ls`)
- No artifacts created
- No state.json update
- Orchestrator claimed "research completed successfully"

**Analysis**: This confirms the validation failure. The researcher agent returned a malformed response (likely plain text), and the orchestrator accepted it without validation, reporting success to the user despite no artifacts being created.

### Finding 3: Vulnerability Affects ALL Workflow Commands

**Evidence**: All workflow commands delegate to subagents through the orchestrator:

- `/research` → researcher / lean-research-agent
- `/plan` → planner / lean-planner
- `/implement` → implementer / lean-implementation-agent
- `/revise` → reviser

All use the same orchestrator Stage 4 (ValidateReturn) which is not implemented.

**Impact**:
- **Phantom research**: Status updated but no research report created
- **Phantom planning**: Status updated but no plan created
- **Phantom implementation**: Status updated but no code written
- **Phantom revision**: Status updated but no plan revised

**User Confusion**: Commands claim success but produce no output, leading to:
- Wasted time investigating "missing" artifacts
- Loss of trust in the system
- Data corruption (state.json and TODO.md out of sync with reality)

### Finding 4: Return Format Standard Is Well-Defined

**Evidence**: `subagent-return-format.md` (212 lines) defines the required JSON structure:

```json
{
  "status": "completed|partial|failed|blocked",
  "summary": "Brief 2-5 sentence summary (<100 tokens)",
  "artifacts": [
    {
      "type": "plan|report|summary|implementation|documentation",
      "path": "relative/path/to/artifact.md",
      "summary": "Brief description of artifact"
    }
  ],
  "metadata": {
    "session_id": "sess_1735460684_a1b2c3",
    "duration_seconds": 123,
    "agent_type": "planner|researcher|implementer|...",
    "delegation_depth": 1,
    "delegation_path": ["orchestrator", "plan", "planner"]
  },
  "errors": [...],
  "next_steps": "What user should do next"
}
```

**Analysis**: The standard is comprehensive and includes validation rules (lines 101-119), but these rules are not enforced by the orchestrator.

### Finding 5: Orchestrator Stage 4 Is Documentation-Only

**Evidence**: Orchestrator Stage 4 (lines 200-212):

```xml
<stage id="4" name="ValidateReturn">
  <action>Validate agent return format and content</action>
  <process>
    See: @.opencode/context/core/system/validation-rules.md
    
    1. Validate JSON structure
    2. Validate required fields
    3. Validate status enum
    4. Validate session_id
    5. Validate artifacts (if status=completed)
  </process>
  <checkpoint>Return validated and artifacts verified</checkpoint>
</stage>
```

**Analysis**: 
- The `<process>` section lists steps but doesn't implement them
- It says "See: validation-rules.md" but doesn't execute the logic
- The `<checkpoint>` claims "Return validated and artifacts verified" but no validation occurs
- This is a documentation pattern, not an execution pattern

**Comparison with Other Stages**:

Stage 3 (RegisterAndDelegate) has EXECUTABLE logic (lines 126-198):
```xml
<process>
  1. Register delegation in session registry:
     {
       "session_id": "sess_...",
       "command": "{command}",
       ...
     }
  
  2. Format prompt for subagent (CRITICAL STEP):
     FOR TASK-BASED COMMANDS:
     - Format as: "Task: {task_number}"
     
  3. Invoke target agent using the task tool:
     task_tool(
       subagent_type="researcher",
       prompt="Task: 258",
       ...
     )
</process>
```

This shows executable instructions with specific function calls and data structures.

Stage 4 should follow the same pattern with executable validation logic.

## Detailed Analysis

### Root Cause

The orchestrator was designed with a documentation-first approach where stages describe WHAT should happen but not HOW to execute it. This works for stages that delegate to other tools (like Stage 3 using `task_tool()`), but fails for Stage 4 which needs to execute validation logic directly.

**Why This Happened**:
1. `validation-rules.md` was created as a reference document
2. Orchestrator Stage 4 was written to reference the document
3. No one implemented the actual validation logic in the orchestrator
4. The system appeared to work because most subagents return valid JSON
5. The bug was discovered when a subagent returned plain text (task 279)

### Impact Assessment

**Severity**: CRITICAL

**Affected Components**:
- Orchestrator Stage 4 (ValidateReturn)
- All workflow commands: /research, /plan, /implement, /revise
- All subagents: researcher, planner, implementer, reviser, lean-research-agent, lean-implementation-agent, lean-planner

**User Impact**:
- **High**: Phantom operations cause confusion and wasted time
- **Medium**: Data corruption (state.json/TODO.md out of sync)
- **Low**: Loss of trust in the system

**Data Integrity Impact**:
- state.json may show tasks as [RESEARCHED]/[PLANNED]/[COMPLETED] when no artifacts exist
- TODO.md may show tasks as complete when no work was done
- No way to detect phantom operations without manual verification

### Validation Requirements

Based on `validation-rules.md` and `subagent-return-format.md`, the orchestrator Stage 4 must implement:

#### 1. JSON Structure Validation

**Purpose**: Prevent plain text or malformed responses

**Logic**:
```bash
# Parse return as JSON
if ! echo "$return" | jq . > /dev/null 2>&1; then
  return_error "Invalid JSON return from ${agent}" "validation_failed"
fi
```

**Error Message**:
```
[FAIL] Invalid JSON return from {agent}
Error: Cannot parse return as JSON
Recommendation: Fix {agent} subagent return format
```

#### 2. Required Fields Validation

**Purpose**: Ensure all required fields are present

**Required Fields**:
- `status` (string, enum)
- `summary` (string, <100 tokens)
- `artifacts` (array, can be empty)
- `metadata` (object with required subfields)
- `metadata.session_id` (string)
- `metadata.agent_type` (string)
- `metadata.delegation_depth` (integer)
- `metadata.delegation_path` (array)

**Logic**:
```bash
required_fields=("status" "summary" "artifacts" "metadata")
for field in "${required_fields[@]}"; do
  if ! echo "$return" | jq -e ".${field}" > /dev/null 2>&1; then
    return_error "Missing required field: ${field}" "validation_failed"
  fi
done

# Validate metadata subfields
metadata_fields=("session_id" "agent_type" "delegation_depth" "delegation_path")
for field in "${metadata_fields[@]}"; do
  if ! echo "$return" | jq -e ".metadata.${field}" > /dev/null 2>&1; then
    return_error "Missing required metadata field: ${field}" "validation_failed"
  fi
done
```

**Error Message**:
```
[FAIL] Missing required field: {field}
Error: Subagent return is incomplete
Recommendation: Fix {agent} subagent to include all required fields
```

#### 3. Status Enum Validation

**Purpose**: Ensure status is one of the valid values

**Valid Values**: `completed`, `partial`, `failed`, `blocked`

**Logic**:
```bash
status=$(echo "$return" | jq -r '.status')
valid_statuses=("completed" "partial" "failed" "blocked")

if [[ ! " ${valid_statuses[@]} " =~ " ${status} " ]]; then
  return_error "Invalid status: ${status}" "validation_failed"
fi
```

**Error Message**:
```
[FAIL] Invalid status: {status}
Valid statuses: completed, partial, failed, blocked
Recommendation: Fix {agent} subagent to use valid status enum
```

#### 4. Session ID Validation

**Purpose**: Prevent session hijacking or mismatched returns

**Logic**:
```bash
returned_session_id=$(echo "$return" | jq -r '.metadata.session_id')

if [ "$returned_session_id" != "$expected_session_id" ]; then
  return_error "Session ID mismatch" "validation_failed"
fi
```

**Error Message**:
```
[FAIL] Session ID mismatch
Expected: {expected_session_id}
Got: {returned_session_id}
Recommendation: Fix {agent} subagent to return correct session_id
```

#### 5. Artifact Validation (CRITICAL)

**Purpose**: Prevent phantom research/planning/implementation

**Validation Rules**:
- If status == "completed": artifacts array MUST be non-empty
- For each artifact: file MUST exist on disk
- For each artifact: file MUST be non-empty (size > 0 bytes)

**Logic**:
```bash
if [ "$status" == "completed" ]; then
  # Check artifacts array is non-empty
  artifact_count=$(echo "$return" | jq '.artifacts | length')
  
  if [ $artifact_count -eq 0 ]; then
    return_error "Phantom research detected" "validation_failed" \
      "Agent returned 'completed' status but created no artifacts"
  fi
  
  # Verify each artifact exists and is non-empty
  artifact_paths=$(echo "$return" | jq -r '.artifacts[].path')
  
  for path in $artifact_paths; do
    # Check file exists
    if [ ! -f "$path" ]; then
      return_error "Artifact not found: ${path}" "validation_failed" \
        "Artifact validation failed"
    fi
    
    # Check file is non-empty
    if [ ! -s "$path" ]; then
      return_error "Artifact is empty: ${path}" "validation_failed" \
        "Artifact validation failed"
    fi
  done
  
  echo "[PASS] ${artifact_count} artifacts validated"
fi
```

**Error Messages**:

Phantom research:
```
[FAIL] Agent returned 'completed' status but created no artifacts
Error: Phantom research detected - status=completed but no artifacts
Recommendation: Verify {agent} creates artifacts before updating status
```

Artifact not found:
```
[FAIL] Artifact does not exist: {path}
Error: Artifact validation failed
Recommendation: Verify {agent} writes artifacts to correct paths
```

Empty artifact:
```
[FAIL] Artifact is empty: {path}
Error: Artifact validation failed
Recommendation: Verify {agent} writes content to artifacts
```

#### 6. Summary Token Limit Validation (Optional Warning)

**Purpose**: Protect orchestrator context window

**Logic**:
```bash
summary=$(echo "$return" | jq -r '.summary')
summary_length=${#summary}

if [ $summary_length -gt 400 ]; then
  echo "[WARN] Summary exceeds recommended length: ${summary_length} characters"
  # Non-critical warning, continue
fi
```

### Implementation Approach

The orchestrator Stage 4 should be rewritten from documentation-only to executable validation logic. Two approaches:

#### Approach 1: Inline Validation Logic

Embed the validation logic directly in Stage 4 `<process>` section:

```xml
<stage id="4" name="ValidateReturn">
  <action>Validate agent return format and content</action>
  <process>
    CRITICAL: Execute validation logic to prevent phantom research.
    
    1. Validate JSON structure:
       - Parse return with jq
       - If parse fails: Return error "Invalid JSON return from {agent}"
    
    2. Validate required fields:
       - Check: status, summary, artifacts, metadata
       - Check metadata: session_id, agent_type, delegation_depth, delegation_path
       - If missing: Return error "Missing required field: {field}"
    
    3. Validate status enum:
       - Extract status from return
       - Verify status in [completed, partial, failed, blocked]
       - If invalid: Return error "Invalid status: {status}"
    
    4. Validate session_id:
       - Extract metadata.session_id from return
       - Compare with expected_session_id from delegation context
       - If mismatch: Return error "Session ID mismatch"
    
    5. Validate artifacts (CRITICAL - prevents phantom research):
       - If status == "completed":
         a. Check artifacts array is non-empty
            - If empty: Return error "Phantom research detected"
         b. For each artifact path:
            - Verify file exists: [ -f "$path" ]
            - If not found: Return error "Artifact not found: {path}"
         c. For each artifact path:
            - Verify file is non-empty: [ -s "$path" ]
            - If empty: Return error "Artifact is empty: {path}"
         d. Log: "[PASS] {N} artifacts validated"
    
    6. Log validation success:
       - "[PASS] Return validation succeeded"
       - "[PASS] {N} artifacts validated"
  </process>
  <validation_failure_handling>
    If any validation fails:
    1. Log error to errors.json
    2. Format error response for user:
       - Header: "Task: {task_number}" or "Command: /{command}"
       - Status: Failed
       - Error: {validation_error_message}
       - Recommendation: {fix_recommendation}
    3. Return failed status to user
    4. DO NOT proceed to Stage 5
  </validation_failure_handling>
  <checkpoint>Return validated and artifacts verified (ACTUALLY EXECUTED)</checkpoint>
</stage>
```

**Pros**:
- All logic in one place
- Easy to understand
- No external dependencies

**Cons**:
- Verbose
- Harder to maintain
- Duplicates logic from validation-rules.md

#### Approach 2: Reference Validation Script

Create a validation script and call it from Stage 4:

**Script**: `.opencode/scripts/validate-subagent-return.sh`

```bash
#!/bin/bash
# Validate subagent return format
# Usage: validate-subagent-return.sh <return_json> <expected_session_id> <agent_name>

return_json="$1"
expected_session_id="$2"
agent_name="$3"

# Step 1: Validate JSON structure
if ! echo "$return_json" | jq . > /dev/null 2>&1; then
  echo "[FAIL] Invalid JSON return from ${agent_name}"
  exit 1
fi

# Step 2: Validate required fields
required_fields=("status" "summary" "artifacts" "metadata")
for field in "${required_fields[@]}"; do
  if ! echo "$return_json" | jq -e ".${field}" > /dev/null 2>&1; then
    echo "[FAIL] Missing required field: ${field}"
    exit 1
  fi
done

# ... (rest of validation logic)

echo "[PASS] Return validation succeeded"
exit 0
```

**Orchestrator Stage 4**:

```xml
<stage id="4" name="ValidateReturn">
  <action>Validate agent return format and content</action>
  <process>
    Execute validation script to prevent phantom research.
    
    1. Call validation script:
       .opencode/scripts/validate-subagent-return.sh \
         "$subagent_return" \
         "$expected_session_id" \
         "$agent_name"
    
    2. Check exit code:
       - If exit code == 0: Validation passed, proceed to Stage 5
       - If exit code != 0: Validation failed, return error to user
    
    3. If validation failed:
       - Extract error message from script output
       - Format error response for user
       - Return failed status
       - DO NOT proceed to Stage 5
  </process>
  <checkpoint>Return validated and artifacts verified via validation script</checkpoint>
</stage>
```

**Pros**:
- Reusable script
- Easier to test
- Matches validation-rules.md structure

**Cons**:
- External dependency
- Requires script maintenance
- Slightly more complex

### Recommendation

**Use Approach 1 (Inline Validation Logic)** for the following reasons:

1. **Simplicity**: All logic in one place, easier to understand
2. **No External Dependencies**: Orchestrator is self-contained
3. **Consistency**: Matches the pattern of other stages (e.g., Stage 3 has inline logic)
4. **Maintainability**: Easier to update validation rules in one place
5. **Performance**: No script execution overhead

The orchestrator Stage 4 should be rewritten to include executable validation logic following the pattern from `validation-rules.md`.

## Code Examples

### Example 1: Valid Return (Should Pass Validation)

```json
{
  "status": "completed",
  "summary": "Research completed on orchestrator validation. Found validation logic documented but not implemented. Identified 5 validation steps needed. Estimated 6-8 hours to implement.",
  "artifacts": [
    {
      "type": "report",
      "path": ".opencode/specs/280_fix_orchestrator_stage_4_validation/reports/research-001.md",
      "summary": "Comprehensive research report on validation implementation"
    }
  ],
  "metadata": {
    "session_id": "sess_1735460684_a1b2c3",
    "duration_seconds": 1850,
    "agent_type": "researcher",
    "delegation_depth": 1,
    "delegation_path": ["orchestrator", "research", "researcher"]
  },
  "next_steps": "Create implementation plan for validation logic"
}
```

**Validation Result**: PASS
- JSON structure: Valid
- Required fields: All present
- Status: "completed" (valid enum)
- Session ID: Matches expected
- Artifacts: 1 artifact, file exists and is non-empty

### Example 2: Invalid Return - Plain Text (Should Fail Validation)

```
Research completed successfully. Found validation logic in validation-rules.md.
```

**Validation Result**: FAIL
- JSON structure: INVALID (plain text, not JSON)
- Error: "[FAIL] Invalid JSON return from researcher"
- Recommendation: "Fix researcher subagent return format"

### Example 3: Invalid Return - Phantom Research (Should Fail Validation)

```json
{
  "status": "completed",
  "summary": "Research completed successfully.",
  "artifacts": [],
  "metadata": {
    "session_id": "sess_1735460684_a1b2c3",
    "agent_type": "researcher",
    "delegation_depth": 1,
    "delegation_path": ["orchestrator", "research", "researcher"]
  }
}
```

**Validation Result**: FAIL
- JSON structure: Valid
- Required fields: All present
- Status: "completed" (valid enum)
- Session ID: Matches expected
- Artifacts: EMPTY (status=completed but no artifacts)
- Error: "[FAIL] Phantom research detected - status=completed but no artifacts"
- Recommendation: "Verify researcher creates artifacts before updating status"

### Example 4: Invalid Return - Missing Artifact File (Should Fail Validation)

```json
{
  "status": "completed",
  "summary": "Research completed.",
  "artifacts": [
    {
      "type": "report",
      "path": ".opencode/specs/280_validation/reports/research-001.md",
      "summary": "Research report"
    }
  ],
  "metadata": {
    "session_id": "sess_1735460684_a1b2c3",
    "agent_type": "researcher",
    "delegation_depth": 1,
    "delegation_path": ["orchestrator", "research", "researcher"]
  }
}
```

**Validation Result**: FAIL (assuming file doesn't exist)
- JSON structure: Valid
- Required fields: All present
- Status: "completed" (valid enum)
- Session ID: Matches expected
- Artifacts: 1 artifact listed
- File existence: FAIL (file not found on disk)
- Error: "[FAIL] Artifact does not exist: .opencode/specs/280_validation/reports/research-001.md"
- Recommendation: "Verify researcher writes artifacts to correct paths"

### Example 5: Invalid Return - Session ID Mismatch (Should Fail Validation)

```json
{
  "status": "completed",
  "summary": "Research completed.",
  "artifacts": [
    {
      "type": "report",
      "path": ".opencode/specs/280_validation/reports/research-001.md",
      "summary": "Research report"
    }
  ],
  "metadata": {
    "session_id": "sess_WRONG_SESSION_ID",
    "agent_type": "researcher",
    "delegation_depth": 1,
    "delegation_path": ["orchestrator", "research", "researcher"]
  }
}
```

**Validation Result**: FAIL
- JSON structure: Valid
- Required fields: All present
- Status: "completed" (valid enum)
- Session ID: MISMATCH
  - Expected: "sess_1735460684_a1b2c3"
  - Got: "sess_WRONG_SESSION_ID"
- Error: "[FAIL] Session ID mismatch"
- Recommendation: "Fix researcher subagent to return correct session_id"

## Decisions

### Decision 1: Implement Validation Logic in Orchestrator Stage 4

**Rationale**: 
- Validation logic is documented but not executed
- Phantom research is a critical bug affecting all workflow commands
- Validation must be enforced at the orchestrator level to protect all commands

**Approach**: Rewrite orchestrator Stage 4 from documentation-only to executable validation logic

**Alternative Considered**: Create validation script (Approach 2)
**Rejected Because**: Inline logic is simpler, more maintainable, and consistent with other stages

### Decision 2: Use Inline Validation Logic (Approach 1)

**Rationale**:
- Simpler to understand and maintain
- No external dependencies
- Consistent with other orchestrator stages
- Better performance (no script execution overhead)

**Alternative Considered**: External validation script (Approach 2)
**Rejected Because**: Adds complexity and external dependency without significant benefit

### Decision 3: Validate Artifacts Only for status=completed

**Rationale**:
- Partial/failed/blocked status may have incomplete or no artifacts
- Validation should not fail for legitimate partial results
- Phantom research only occurs when status=completed but no artifacts exist

**Alternative Considered**: Validate artifacts for all statuses
**Rejected Because**: Would cause false positives for partial/failed/blocked returns

### Decision 4: Fail Fast on Validation Errors

**Rationale**:
- Validation errors indicate serious problems (malformed returns, phantom research)
- Continuing to Stage 5 would propagate the error
- User needs immediate feedback about validation failure

**Alternative Considered**: Log warning and continue
**Rejected Because**: Would allow phantom research to continue undetected

## Recommendations

### Immediate Actions (Critical)

1. **Implement Validation Logic in Orchestrator Stage 4**
   - Rewrite Stage 4 `<process>` section with executable validation logic
   - Follow the pattern from `validation-rules.md`
   - Include all 5 validation steps (JSON, fields, status, session_id, artifacts)
   - Add error handling for validation failures
   - Estimated effort: 3-4 hours

2. **Test Validation with Malformed Returns**
   - Create test cases for each validation failure scenario
   - Verify orchestrator rejects invalid returns
   - Verify error messages are clear and actionable
   - Estimated effort: 1-2 hours

3. **Update validation-rules.md with Implementation Details**
   - Document that validation is now enforced by orchestrator
   - Add examples of validation failures and error messages
   - Update "See Also" section to reference orchestrator Stage 4
   - Estimated effort: 0.5 hours

### Follow-Up Actions (Important)

4. **Test All Workflow Commands with Validation Enabled**
   - Test /research with valid and invalid returns
   - Test /plan with valid and invalid returns
   - Test /implement with valid and invalid returns
   - Test /revise with valid and invalid returns
   - Verify no regressions in normal operation
   - Estimated effort: 1-2 hours

5. **Add Validation Failure Logging**
   - Log validation failures to errors.json
   - Include timestamp, agent, error type, error message
   - Enable debugging and monitoring
   - Estimated effort: 0.5 hours

6. **Create Validation Failure Recovery Guide**
   - Document common validation failures
   - Provide troubleshooting steps
   - Add to user documentation
   - Estimated effort: 1 hour

### Long-Term Improvements (Optional)

7. **Add Validation Metrics**
   - Track validation success/failure rates
   - Identify problematic subagents
   - Monitor system health
   - Estimated effort: 2-3 hours

8. **Create Validation Test Suite**
   - Automated tests for all validation scenarios
   - Run as part of CI/CD pipeline
   - Prevent validation regressions
   - Estimated effort: 3-4 hours

9. **Enhance Subagent Return Format**
   - Add schema version field
   - Add validation metadata
   - Enable future schema evolution
   - Estimated effort: 4-5 hours

## Risks & Mitigations

### Risk 1: Breaking Existing Subagents

**Description**: Implementing strict validation may break subagents that currently return slightly malformed JSON

**Likelihood**: Medium

**Impact**: High (workflow commands stop working)

**Mitigation**:
1. Test all subagents with validation enabled before deployment
2. Fix any subagents that fail validation
3. Add validation to subagent development checklist
4. Create validation test suite for subagents

### Risk 2: False Positives

**Description**: Validation may reject legitimate returns (e.g., partial results with no artifacts)

**Likelihood**: Low

**Impact**: Medium (legitimate operations fail)

**Mitigation**:
1. Only validate artifacts for status=completed
2. Allow empty artifacts for partial/failed/blocked status
3. Test edge cases thoroughly
4. Add clear error messages to help users understand failures

### Risk 3: Performance Impact

**Description**: Validation adds processing time to every command

**Likelihood**: High

**Impact**: Low (validation is fast, <1 second)

**Mitigation**:
1. Use efficient jq queries
2. Avoid redundant file system checks
3. Optimize validation logic
4. Monitor performance metrics

### Risk 4: Incomplete Validation

**Description**: Validation may miss edge cases or new failure modes

**Likelihood**: Medium

**Impact**: Medium (phantom research still possible)

**Mitigation**:
1. Follow validation-rules.md comprehensively
2. Add test cases for all known failure modes
3. Monitor for new failure patterns
4. Update validation logic as needed

## Appendix: Sources and Citations

### Primary Sources

1. **Orchestrator Implementation**
   - File: `.opencode/agent/orchestrator.md`
   - Lines: 200-212 (Stage 4 ValidateReturn)
   - Evidence: Stage 4 is documentation-only, not executable

2. **Validation Rules Documentation**
   - File: `.opencode/context/core/system/validation-rules.md`
   - Lines: 1-277 (complete file)
   - Evidence: Comprehensive validation logic documented but not executed

3. **Subagent Return Format Standard**
   - File: `.opencode/context/core/standards/subagent-return-format.md`
   - Lines: 1-212 (complete file)
   - Evidence: Required JSON structure and validation rules defined

4. **Task 280 Description**
   - File: `.opencode/specs/TODO.md`
   - Lines: 30-88 (task 280 entry)
   - Evidence: Problem statement, expected behavior, acceptance criteria

### Supporting Evidence

5. **Task 279 Phantom Research Example**
   - File: `.opencode/specs/TODO.md`
   - Lines: 1483-1684 (task 279 entry)
   - Evidence: No directory created, no artifacts, status still [NOT STARTED]

6. **Researcher Subagent Implementation**
   - File: `.opencode/agent/subagents/researcher.md`
   - Lines: 1-200 (partial read)
   - Evidence: Researcher returns standardized JSON format

### Related Documentation

7. **State Management Standard**
   - File: `.opencode/context/core/system/state-management.md`
   - Referenced by: validation-rules.md (line 275)

8. **Delegation Standard**
   - File: `.opencode/context/core/standards/delegation.md`
   - Referenced by: validation-rules.md (line 273)

9. **Routing Logic**
   - File: `.opencode/context/core/system/routing-logic.md`
   - Referenced by: validation-rules.md (line 276)

### Validation Logic Examples

All validation logic examples are from:
- File: `.opencode/context/core/system/validation-rules.md`
- Step 1 (JSON): Lines 32-42
- Step 2 (Fields): Lines 44-58
- Step 3 (Status): Lines 60-74
- Step 4 (Session ID): Lines 76-90
- Step 5 (Artifacts): Lines 105-169

### Error Message Examples

All error message examples are from:
- File: `.opencode/context/core/system/validation-rules.md`
- Invalid JSON: Lines 192-199
- Missing Field: Lines 201-209
- Invalid Status: Lines 211-219
- Session ID Mismatch: Lines 221-230
- Phantom Research: Lines 232-240
- Artifact Not Found: Lines 242-250
- Empty Artifact: Lines 252-260
