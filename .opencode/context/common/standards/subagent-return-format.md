# Subagent Return Format Standard

**Version**: 1.0  
**Status**: Active  
**Created**: 2025-12-26  
**Purpose**: Define unified return format for all subagent invocations to ensure consistent parsing and error handling

---

## Overview

This standard defines the exact JSON format that all subagents must return when invoked by commands or other agents. Consistent return formatting enables:

- Reliable parsing and validation by calling commands
- Predictable error handling and debugging
- Clear artifact tracking and linking
- Uniform timeout and retry logic

---

## Schema Definition

All subagents must return a JSON object with the following structure:

```json
{
  "status": "completed|failed|partial|blocked",
  "summary": "Brief 2-5 sentence summary of what was accomplished (max 100 tokens)",
  "artifacts": [
    {
      "type": "research|plan|implementation|summary|test|documentation",
      "path": "relative/path/from/project/root",
      "summary": "Optional one-sentence description of this artifact"
    }
  ],
  "metadata": {
    "session_id": "unique_session_identifier",
    "duration_seconds": 123,
    "agent_type": "task-executor|researcher|planner|implementer|etc"
  },
  "errors": [
    {
      "type": "timeout|validation|execution|resource",
      "message": "Human-readable error description",
      "code": "ERROR_CODE",
      "recoverable": true
    }
  ],
  "next_steps": "Optional recommended next actions for the caller"
}
```

---

## Field Specifications

### status (required)

**Type**: String enum  
**Values**: `completed` | `failed` | `partial` | `blocked`  
**Description**: Overall execution status

- `completed`: Task finished successfully, all objectives met
- `failed`: Task failed, no usable results produced
- `partial`: Task partially completed, some results available
- `blocked`: Task cannot proceed, requires external input/resolution

**Validation Rules**:
- Must be exactly one of the four values (case-sensitive)
- Cannot be empty or null

### summary (required)

**Type**: String  
**Length**: 2-5 sentences, max 100 tokens  
**Description**: Brief summary of what was accomplished or attempted

**Content Guidelines**:
- Focus on outcomes, not process
- Be specific about what changed or was created
- Include key decisions or findings
- Mention any important blockers or issues
- No emojis or formatting markup

**Validation Rules**:
- Must be non-empty string
- Should be 10-500 characters
- Token count should not exceed 100 (approximate: 400 characters)

**Examples**:
- "Created implementation plan for task 191 with 3 phases covering return handling, cycle detection, and testing. Estimated 14 hours total effort. Plan references research findings and includes comprehensive error handling strategy."
- "Research completed on Lean 4 metaprogramming tactics. Found 15 relevant examples in mathlib4, documented 3 key patterns, and identified 2 potential approaches for our use case. Recommend pattern-matching approach for flexibility."

### artifacts (required)

**Type**: Array of artifact objects  
**Description**: List of files/resources created or modified during execution  
**Can be empty**: Yes (if no artifacts produced)

**Artifact Object Schema**:
```json
{
  "type": "research|plan|implementation|summary|test|documentation",
  "path": "relative/path/from/project/root",
  "summary": "Optional one-sentence description"
}
```

**Artifact Fields**:

- `type` (required): Category of artifact
  - `research`: Research reports, analysis documents
  - `plan`: Implementation plans, design documents
  - `implementation`: Source code, configuration files
  - `summary`: Executive summaries, overview documents
  - `test`: Test files, test data
  - `documentation`: User guides, API docs, READMEs

- `path` (required): Relative path from project root
  - Must use forward slashes (/)
  - Must not start with / (relative, not absolute)
  - Should be valid filesystem path
  - Examples: `.opencode/specs/191/plans/implementation-001.md`, `Logos/Core/Automation/ProofSearch.lean`

- `summary` (optional): One-sentence description
  - Max 200 characters
  - Briefly describes what this artifact contains
  - No emojis or formatting

**Validation Rules**:
- Array must be present (can be empty: `[]`)
- Each artifact must have valid `type` and `path`
- Paths should reference files that actually exist (best effort)
- No duplicate paths in array

### metadata (required)

**Type**: Object  
**Description**: Execution metadata for tracking and debugging

**Required Fields**:

- `session_id` (string): Unique identifier for this execution
  - Format: `{agent_type}_{task_id}_{timestamp}_{random}`
  - Examples: `task-executor_191_20251226_001`, `researcher_200_20251226T143022_abc123`
  - Should be provided by caller and echoed back
  - Used for correlation and debugging

- `duration_seconds` (number): Total execution time in seconds
  - Integer or decimal value
  - Measured from invocation to return
  - Used for timeout monitoring and performance analysis

- `agent_type` (string): Type of subagent that executed
  - Should match the agent's defined type
  - Examples: `task-executor`, `researcher`, `planner`, `implementer`, `batch-task-orchestrator`
  - Used for routing and debugging

**Optional Fields**:

- `delegation_depth` (number): Delegation depth in chain (default: 0)
- `delegation_path` (array): Delegation chain leading to this agent
- `retries` (number): Number of retry attempts made
- `warnings` (array): Non-fatal warnings encountered

**Validation Rules**:
- All three required fields must be present
- `duration_seconds` must be non-negative number
- `session_id` must be non-empty string
- `agent_type` must be non-empty string

### errors (optional)

**Type**: Array of error objects  
**Description**: Errors encountered during execution  
**Default**: Empty array `[]`

**Error Object Schema**:
```json
{
  "type": "timeout|validation|execution|resource|cycle",
  "message": "Human-readable error description",
  "code": "ERROR_CODE_UPPERCASE",
  "recoverable": true
}
```

**Error Fields**:

- `type` (required): Error category
  - `timeout`: Execution exceeded time limit
  - `validation`: Input validation failed
  - `execution`: Runtime error during execution
  - `resource`: Required resource not available
  - `cycle`: Delegation cycle detected

- `message` (required): Human-readable description
  - Should be actionable and specific
  - Include relevant context (file paths, values, etc.)
  - Suggest fixes when possible
  - Max 500 characters

- `code` (optional): Machine-readable error code
  - UPPERCASE_SNAKE_CASE format
  - Examples: `TIMEOUT_EXCEEDED`, `VALIDATION_FAILED`, `DELEGATION_CYCLE`
  - Used for programmatic error handling

- `recoverable` (optional): Whether error is recoverable
  - Boolean: true if retry might succeed
  - Default: false
  - Used to determine retry strategy

**Validation Rules**:
- Array can be empty (no errors)
- Each error must have `type` and `message`
- Error types must be valid enum values

### next_steps (optional)

**Type**: String  
**Description**: Recommended next actions for the caller  
**Default**: Empty string or null

**Content Guidelines**:
- Provide concrete actionable steps
- Prioritize steps by importance
- Reference specific files/tasks when relevant
- Keep concise (max 300 characters)

**Examples**:
- "Review implementation plan and run /implement 191 to execute Phase 1"
- "Address validation errors in Task 132 config, then retry execution"
- "Research findings suggest pattern-matching approach; update plan accordingly"

---

## Validation Rules Summary

Commands receiving subagent returns must validate:

1. **Structure**: JSON object with all required top-level fields
2. **Status**: Valid enum value (completed|failed|partial|blocked)
3. **Summary**: Non-empty string, reasonable length
4. **Artifacts**: Array (can be empty), valid structure if non-empty
5. **Metadata**: All three required fields present and valid types
6. **Errors**: Array (can be empty), valid structure if non-empty

**Validation Pseudocode**:
```
function validate_return(return_value):
  if not is_object(return_value):
    error("Return value must be JSON object")
  
  if not return_value.status in [completed, failed, partial, blocked]:
    error("Invalid status value")
  
  if not is_non_empty_string(return_value.summary):
    error("Summary must be non-empty string")
  
  if not is_array(return_value.artifacts):
    error("Artifacts must be array")
  
  for artifact in return_value.artifacts:
    if not artifact.type or not artifact.path:
      error("Artifact missing required fields")
  
  metadata = return_value.metadata
  if not (metadata.session_id and metadata.duration_seconds and metadata.agent_type):
    error("Metadata missing required fields")
  
  if return_value.errors and not is_array(return_value.errors):
    error("Errors must be array if present")
  
  return true
```

---

## Examples by Agent Type

### Task Executor Success

```json
{
  "status": "completed",
  "summary": "Successfully executed task 191. Created standardized return format schema at .opencode/context/common/standards/subagent-return-format.md. All validation rules documented with examples. Task marked COMPLETED in TODO.md.",
  "artifacts": [
    {
      "type": "documentation",
      "path": ".opencode/context/common/standards/subagent-return-format.md",
      "summary": "Standardized return format schema for all subagents"
    }
  ],
  "metadata": {
    "session_id": "task-executor_191_20251226T100000_abc123",
    "duration_seconds": 45,
    "agent_type": "task-executor"
  },
  "errors": [],
  "next_steps": "Proceed to implement return handling in /implement command"
}
```

### Researcher with Partial Results

```json
{
  "status": "partial",
  "summary": "Research on Lean 4 tactics partially completed. Analyzed 10 of 15 target files in mathlib4 before timeout. Documented 3 key patterns for metaprogramming tactics. Remaining 5 files require additional investigation.",
  "artifacts": [
    {
      "type": "research",
      "path": ".opencode/specs/200/reports/research-001.md",
      "summary": "Partial research report on Lean 4 metaprogramming tactics"
    }
  ],
  "metadata": {
    "session_id": "researcher_200_20251226T110000_def456",
    "duration_seconds": 3600,
    "agent_type": "researcher"
  },
  "errors": [
    {
      "type": "timeout",
      "message": "Research exceeded 1 hour timeout after analyzing 10/15 files",
      "code": "TIMEOUT_EXCEEDED",
      "recoverable": true
    }
  ],
  "next_steps": "Continue research with remaining 5 files or proceed with current findings"
}
```

### Planner Failure

```json
{
  "status": "failed",
  "summary": "Failed to create implementation plan for task 205. Required research artifacts not found at expected path .opencode/specs/205/reports/. Cannot proceed without research inputs defining scope and requirements.",
  "artifacts": [],
  "metadata": {
    "session_id": "planner_205_20251226T120000_ghi789",
    "duration_seconds": 12,
    "agent_type": "planner"
  },
  "errors": [
    {
      "type": "resource",
      "message": "Research artifact not found: .opencode/specs/205/reports/research-001.md",
      "code": "ARTIFACT_NOT_FOUND",
      "recoverable": true
    }
  ],
  "next_steps": "Run /research 205 to generate required research artifacts, then retry planning"
}
```

### Batch Orchestrator with Multiple Artifacts

```json
{
  "status": "completed",
  "summary": "Batch execution completed for tasks 132-135. All 4 tasks executed successfully via wave-based parallel processing. Wave 1 (tasks 132, 133) completed in 120s, Wave 2 (tasks 134, 135) completed in 95s. All task statuses updated to COMPLETED.",
  "artifacts": [
    {
      "type": "implementation",
      "path": "Logos/Core/Automation/Tactics.lean",
      "summary": "Task 132: Added new proof automation tactic"
    },
    {
      "type": "test",
      "path": "LogosTest/Core/Automation/TacticsTest.lean",
      "summary": "Task 133: Test coverage for new tactic"
    },
    {
      "type": "documentation",
      "path": "Documentation/Reference/TACTIC_REGISTRY.md",
      "summary": "Task 134: Updated tactic registry"
    },
    {
      "type": "implementation",
      "path": "Logos/Core/Automation/ProofSearch.lean",
      "summary": "Task 135: Integrated tactic into proof search"
    }
  ],
  "metadata": {
    "session_id": "batch-orchestrator_132-135_20251226T130000_jkl012",
    "duration_seconds": 215,
    "agent_type": "batch-task-orchestrator"
  },
  "errors": [],
  "next_steps": "All tasks completed successfully, no further action needed"
}
```

---

## Usage Guidelines for Commands

### Receiving and Validating Returns

Commands should:

1. **Wait for return**: Use session_id to poll/wait for completion
2. **Set timeout**: Enforce maximum wait time (e.g., 3600s)
3. **Validate format**: Check against schema before processing
4. **Handle errors**: Check errors array and status field
5. **Extract artifacts**: Parse artifacts array for result files
6. **Update state**: Use summary and metadata to update command state

### Example Validation in Commands

```xml
<stage id="3.5" name="ReceiveResults">
  <action>Wait for subagent completion and validate return</action>
  <process>
    1. Poll for completion using session_id
    2. Set timeout: 3600 seconds
    3. Receive return_value from subagent
    4. Validate against subagent-return-format.md:
       - Check required fields present
       - Validate status enum
       - Validate metadata fields
       - Validate artifacts array structure
    5. If validation fails:
       - Log validation error with details
       - Retry once
       - If still fails, return error to user
    6. If validation succeeds:
       - Extract status, summary, artifacts
       - Proceed to ProcessResults stage
  </process>
</stage>
```

---

## Error Handling Patterns

### On Timeout

```json
{
  "status": "partial",
  "summary": "Execution timed out after 3600 seconds. Partial results available in artifacts. Work completed up to Phase 1 Task 3.",
  "artifacts": [...],
  "errors": [
    {
      "type": "timeout",
      "message": "Execution exceeded 1 hour timeout",
      "code": "TIMEOUT_EXCEEDED",
      "recoverable": true
    }
  ],
  "next_steps": "Review partial results and retry with remaining tasks"
}
```

### On Validation Error

```json
{
  "status": "failed",
  "summary": "Input validation failed. Task number 999 not found in TODO.md. Cannot execute non-existent task.",
  "artifacts": [],
  "errors": [
    {
      "type": "validation",
      "message": "Task 999 not found in TODO.md",
      "code": "TASK_NOT_FOUND",
      "recoverable": false
    }
  ],
  "next_steps": "Verify task number exists in TODO.md and retry"
}
```

### On Delegation Cycle

```json
{
  "status": "failed",
  "summary": "Delegation cycle detected. Cannot route to task-executor as it would create loop: orchestrator -> implement -> task-executor -> batch-orchestrator -> task-executor.",
  "artifacts": [],
  "errors": [
    {
      "type": "cycle",
      "message": "Delegation cycle: [orchestrator, implement, task-executor, batch-orchestrator, task-executor]",
      "code": "DELEGATION_CYCLE",
      "recoverable": false
    }
  ],
  "next_steps": "Refactor delegation path to eliminate cycle"
}
```

---

## Migration Guide

Existing subagents should update their return formats as follows:

1. **Add status field**: Map existing outcomes to status enum
2. **Add summary field**: Convert existing descriptions to 2-5 sentence summaries
3. **Standardize artifacts**: Convert to artifacts array with type/path/summary
4. **Add metadata**: Include session_id (from caller), duration, agent_type
5. **Convert errors**: Structure error information into errors array
6. **Remove custom fields**: Migrate any custom return fields to metadata or next_steps

---

## Acceptance Criteria

- [ ] Schema file created with complete specification
- [ ] Validation rules documented with examples
- [ ] Examples provided for each major subagent type
- [ ] Error handling patterns documented
- [ ] Migration guide provided for existing subagents
- [ ] No emojis in documentation

---

## Version History

- **1.0** (2025-12-26): Initial standard created for delegation hang fix project
