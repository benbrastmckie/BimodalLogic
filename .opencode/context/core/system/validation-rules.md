# Validation Rules Standard

## Overview

This standard defines validation rules for subagent returns, including return format validation and artifact verification.

**ENFORCEMENT**: These validation rules are ENFORCED by command files (`.opencode/command/*.md`) in Stage 3 (ValidateReturn). All subagent returns are validated before relaying results to the user. Validation failures result in immediate error reporting to the user and workflow termination.

**IMPLEMENTATION**: See command files for executable validation logic:
- `.opencode/command/research.md` Stage 3 (ValidateReturn)
- `.opencode/command/plan.md` Stage 3 (ValidateReturn)
- `.opencode/command/revise.md` Stage 3 (ValidateReturn)
- `.opencode/command/implement.md` Stage 3 (ValidateReturn)

**ARCHITECTURE NOTE**: In orchestrator v7.0 (pure router architecture), validation moved from orchestrator Stage 4 to command files Stage 3. This reflects the architectural shift from centralized orchestrator to distributed command files.

## Return Format Validation

All subagents must return a standard JSON format (see `core/standards/delegation.md`).

### Required Fields

```json
{
  "status": "completed|partial|failed|blocked",
  "summary": "Brief 2-5 sentence summary (<100 tokens)",
  "artifacts": [...],
  "metadata": {
    "session_id": "...",
    "duration_seconds": 123,
    "agent_type": "...",
    "delegation_depth": 1,
    "delegation_path": [...]
  },
  "errors": [...],
  "next_steps": "..."
}
```

### Validation Steps

#### Step 1: Validate JSON Structure

```bash
# Parse return as JSON
if ! echo "$return" | jq . > /dev/null 2>&1; then
  echo "[FAIL] Invalid JSON return from ${agent}"
  exit 1
fi

echo "[PASS] Return is valid JSON"
```

#### Step 2: Validate Required Fields

```bash
# Check required fields exist
required_fields=("status" "summary" "artifacts" "metadata" "session_id")

for field in "${required_fields[@]}"; do
  if ! echo "$return" | jq -e ".${field}" > /dev/null 2>&1; then
    echo "[FAIL] Missing required field: ${field}"
    exit 1
  fi
done

echo "[PASS] All required fields present"
```

#### Step 3: Validate Status Field

```bash
# Check status is valid enum
status=$(echo "$return" | jq -r '.status')
valid_statuses=("completed" "partial" "failed" "blocked")

if [[ ! " ${valid_statuses[@]} " =~ " ${status} " ]]; then
  echo "[FAIL] Invalid status: ${status}"
  echo "Valid statuses: completed, partial, failed, blocked"
  exit 1
fi

echo "[PASS] Status is valid: ${status}"
```

#### Step 4: Validate Session ID

```bash
# Check session_id matches expected
returned_session_id=$(echo "$return" | jq -r '.session_id')

if [ "$returned_session_id" != "$expected_session_id" ]; then
  echo "[FAIL] Session ID mismatch"
  echo "Expected: ${expected_session_id}"
  echo "Got: ${returned_session_id}"
  exit 1
fi

echo "[PASS] Session ID matches"
```

#### Step 5: Validate Summary Token Limit

```bash
# Check summary is <100 tokens (~400 characters)
summary=$(echo "$return" | jq -r '.summary')
summary_length=${#summary}

if [ $summary_length -gt 400 ]; then
  echo "[WARN] Summary exceeds recommended length: ${summary_length} characters"
  # Non-critical warning, continue
fi
```

## Artifact Validation (CRITICAL)

Prevents "phantom research" - status=completed but no artifacts created.

### When to Validate

**Only validate artifacts if status == "completed"**

For partial/failed/blocked status, artifacts may be empty or incomplete.

### Validation Steps

#### Step 1: Check Artifacts Array is Non-Empty

```bash
if [ "$status" == "completed" ]; then
  artifact_count=$(echo "$return" | jq '.artifacts | length')
  
  if [ $artifact_count -eq 0 ]; then
    echo "[FAIL] Agent returned 'completed' status but created no artifacts"
    echo "Error: Phantom research detected - status=completed but no artifacts"
    exit 1
  fi
  
  echo "[INFO] Artifact count: ${artifact_count}"
fi
```

#### Step 2: Verify Each Artifact Exists

```bash
if [ "$status" == "completed" ]; then
  # Extract artifact paths
  artifact_paths=$(echo "$return" | jq -r '.artifacts[].path')
  
  for path in $artifact_paths; do
    # Check file exists
    if [ ! -f "$path" ]; then
      echo "[FAIL] Artifact does not exist: ${path}"
      exit 1
    fi
    
    echo "[PASS] Artifact exists: ${path}"
  done
fi
```

#### Step 3: Verify Each Artifact is Non-Empty

```bash
if [ "$status" == "completed" ]; then
  for path in $artifact_paths; do
    # Check file is non-empty (size > 0)
    if [ ! -s "$path" ]; then
      echo "[FAIL] Artifact is empty: ${path}"
      exit 1
    fi
    
    file_size=$(stat -f%z "$path" 2>/dev/null || stat -c%s "$path")
    echo "[PASS] Artifact is non-empty: ${path} (${file_size} bytes)"
  done
  
  echo "[PASS] ${artifact_count} artifacts validated"
fi
```

### Why This Matters

**Problem**: Agents may update status to "completed" without actually creating artifacts.

**Example**:
```json
{
  "status": "completed",
  "summary": "Research completed successfully",
  "artifacts": [],  // Empty! No research was actually done
  "metadata": {...}
}
```

**Impact**: User thinks research is done, but no research report exists.

**Solution**: Validate artifacts array is non-empty and all files exist.

## Error Handling

### Invalid JSON Return

**Error**:
```
[FAIL] Invalid JSON return from {agent}
Error: Cannot parse return as JSON
```

**Recommendation**: Fix {agent} subagent return format

### Missing Required Field

**Error**:
```
[FAIL] Missing required field: {field}
Error: Subagent return is incomplete
```

**Recommendation**: Fix {agent} subagent to include all required fields

### Invalid Status

**Error**:
```
[FAIL] Invalid status: {status}
Valid statuses: completed, partial, failed, blocked
```

**Recommendation**: Fix {agent} subagent to use valid status enum

### Session ID Mismatch

**Error**:
```
[FAIL] Session ID mismatch
Expected: {expected}
Got: {actual}
```

**Recommendation**: Fix {agent} subagent to return correct session_id

### Phantom Research Detected

**Error**:
```
[FAIL] Agent returned 'completed' status but created no artifacts
Error: Phantom research detected - status=completed but no artifacts
```

**Recommendation**: Verify {agent} creates artifacts before updating status

### Artifact Not Found

**Error**:
```
[FAIL] Artifact does not exist: {path}
Error: Artifact validation failed
```

**Recommendation**: Verify {agent} writes artifacts to correct paths

### Empty Artifact

**Error**:
```
[FAIL] Artifact is empty: {path}
Error: Artifact validation failed
```

**Recommendation**: Verify {agent} writes content to artifacts

## Validation Summary

After all validations pass, log summary:

```
[PASS] Return validation succeeded
[PASS] {N} artifacts validated
```

## Implementation Status

**STATUS**: ✅ ENFORCED (as of Task 280)

These validation rules are now ACTIVELY ENFORCED by command files Stage 3 (ValidateReturn). Prior to Task 280, these rules were documented but not executed, leading to "phantom research" incidents where agents claimed completion without creating artifacts.

**Key Changes**:
- Command files Stage 3 (ValidateReturn) added with executable validation logic
- All 5 validation steps now executed for every subagent return
- Validation failures result in immediate error reporting and workflow termination
- Prevents phantom research/planning/implementation across all workflow commands

**Validation Execution Flow**:
1. Command file Stage 1: Parse and validate arguments
2. Command file Stage 2: Delegate to subagent, capture return
3. Command file Stage 3: Execute validation steps 1-5 on return
4. If validation fails: Error reported to user, workflow terminated
5. If validation passes: Proceed to Stage 4 (RelayResult)

**Architecture Evolution**:
- **v5.0**: Orchestrator Stage 4 (ValidateReturn) - documentation only, not executed
- **v7.0**: Command files Stage 3 (ValidateReturn) - executable validation logic
- **Rationale**: v7.0 orchestrator is pure router, command files handle delegation and validation

**Testing**:
- Validation tested with malformed returns (plain text, missing fields, invalid status)
- Validation tested with phantom research scenarios (status=completed, no artifacts)
- Validation tested with missing/empty artifact files
- All workflow commands (/research, /plan, /implement, /revise) protected

## See Also

- **Command Files Stage 3**: `.opencode/command/*.md` Stage 3 (ValidateReturn) - Executable validation logic
- **Validation Template**: `.opencode/specs/280_fix_orchestrator_stage_4_validation/validation-template.md` - Reusable validation section
- Delegation Standard: `.opencode/context/core/standards/delegation.md`
- Subagent Return Format: `.opencode/context/core/standards/subagent-return-format.md`
- State Management: `.opencode/context/core/system/state-management.md`
- Routing Logic: `.opencode/context/core/system/routing-logic.md`
