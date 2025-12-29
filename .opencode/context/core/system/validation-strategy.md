# Validation Strategy

## Orchestrator Validation Philosophy

The orchestrator validates **structural correctness** and **safety constraints**, not business logic or domain-specific rules.

## High-Value Checks (DO Validate)

### Task Number Validation
**When**: Command requires task_number parameter
**Checks**:
- Task number is integer (regex: `^\d+$`)
- Task exists in TODO.md (grep `^### {number}\.`)
- Extract task status (for status transition validation)
- Extract task language (for routing)

**Cost**: ~50ms (file read + grep)  
**Benefit**: Prevents 80% of user errors  
**Verdict**: ✅ Worth it

### Delegation Safety Checks
**When**: Every delegation
**Checks**:
- delegation_depth ≤ 3
- No cycles in delegation_path (target not in path)
- session_id is unique (not in active registry)

**Cost**: ~5ms (in-memory checks)  
**Benefit**: Prevents infinite loops and hangs  
**Verdict**: ✅ Worth it

### Command Argument Validation
**When**: Parsing command arguments
**Checks**:
- Required arguments present
- Argument types correct (integer, string, etc.)
- Flag syntax valid

**Cost**: ~1ms (string parsing)  
**Benefit**: Clear error messages for user  
**Verdict**: ✅ Worth it

### Return Format Validation
**When**: Receiving subagent return
**Checks**:
- Return is valid JSON
- Required fields present (status, summary, artifacts, metadata, session_id)
- Status is valid enum (completed|partial|failed|blocked)
- session_id matches expected
- Summary <100 tokens

**Cost**: ~10ms (JSON parsing + validation)  
**Benefit**: Ensures consistent return handling  
**Verdict**: ✅ Worth it

## Low-Value Checks (DON'T Validate)

### Business Logic Validation
**Examples**:
- Plan file already exists (let planner check and warn)
- Task has research artifacts (let planner harvest if available)
- Specific file permissions (let agent fail with clear error)

**Rationale**: These are agent-specific concerns, not orchestrator concerns  
**Verdict**: ❌ Skip - Let agents handle

### Deep Validation
**Examples**:
- Plan file format/structure (let planner validate)
- Research report completeness (let researcher validate)
- Implementation correctness (let implementer validate)
- Lean syntax correctness (let lean-implementation-agent validate)

**Rationale**: Orchestrator shouldn't understand domain-specific formats  
**Verdict**: ❌ Skip - Let agents handle

### Artifact Existence (Partial)
**When to check**: Only if status=completed
**When to skip**: If status=partial or failed

**Rationale**: 
- Completed tasks MUST have artifacts (worth validating)
- Partial/failed tasks MAY have artifacts (not worth validating)

**Verdict**: ✅ Validate for completed, ❌ Skip for partial/failed

## Validation Stages

### Stage 2: PreflightValidation
**Validates**:
- Task number (if required)
- Task exists in TODO.md
- Delegation safety (cycles, depth)
- Session ID uniqueness

**Does NOT validate**:
- Business logic (plan exists, etc.)
- File permissions
- Domain-specific rules

### Stage 6: ValidateReturn
**Validates**:
- Return format (JSON schema)
- Required fields present
- session_id matches
- Status enum valid
- Summary token limit
- Artifacts exist (if status=completed)

**Does NOT validate**:
- Artifact content/format
- Business logic correctness
- Domain-specific rules

## Error Handling

### Validation Failures
**Orchestrator validation fails** → Return error immediately, don't delegate

**Agent validation fails** → Agent returns failed status with clear error message

### Error Messages
**Good** (orchestrator): "Task 999 not found in TODO.md"  
**Good** (agent): "Plan already exists at path/to/plan.md. Use /revise to update."

**Bad** (orchestrator): "Plan already exists" (business logic, not orchestrator concern)  
**Bad** (agent): "Invalid task number" (should be caught by orchestrator)

## Summary

| Validation Type | Orchestrator | Agent |
|----------------|--------------|-------|
| Task exists | ✅ | ❌ |
| Task number format | ✅ | ❌ |
| Delegation safety | ✅ | ❌ |
| Return format | ✅ | ❌ |
| Plan exists | ❌ | ✅ |
| Research complete | ❌ | ✅ |
| File permissions | ❌ | ✅ |
| Domain rules | ❌ | ✅ |
| Artifact format | ❌ | ✅ |
