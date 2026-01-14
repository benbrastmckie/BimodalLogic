# Research Report: /abandon Command Architecture

**Task**: 298 - Create /abandon command to mark tasks as [ABANDONED] with reason  
**Started**: 2026-01-05  
**Completed**: 2026-01-05  
**Effort**: 3 hours  
**Priority**: Medium  
**Dependencies**: None  
**Sources/Inputs**: 
- .opencode/command/plan.md
- .opencode/command/implement.md
- .opencode/command/research.md
- .opencode/agent/subagents/status-sync-manager.md
- .opencode/agent/subagents/planner.md
- .opencode/agent/subagents/implementer.md
- .opencode/context/core/templates/command-template.md
- .opencode/context/core/standards/delegation.md
- .opencode/context/core/standards/subagent-return-format.md
- .opencode/context/core/system/state-management.md

**Artifacts**: 
- Research Report: .opencode/specs/298_abandon_command/reports/research-001.md

**Standards**: status-markers.md, artifact-management.md, tasks.md, report.md

---

## Executive Summary

This research analyzes the architectural patterns used by /plan, /implement, and /research commands to inform the design of a new /abandon command. The analysis reveals a consistent two-stage command pattern: (1) ParseAndValidate stage that extracts task metadata from state.json, and (2) Delegate stage that routes to status-sync-manager for atomic status updates. The /abandon command should follow this exact pattern, validating task existence and status, prompting for abandonment reason if not provided, and delegating to status-sync-manager to atomically update TODO.md and state.json with [ABANDONED] status.

Key findings: Commands are thin routing layers (50-200 lines), all business logic lives in subagents, state.json is the authoritative source for metadata (8x faster than TODO.md), and status-sync-manager provides atomic two-phase commit updates across multiple files.

---

## Context & Scope

### Research Objective

Design a /abandon command that follows the same architectural patterns as /implement, /research, and /plan commands to ensure consistency, maintainability, and reliability.

### Research Questions

1. How is the /plan command structured and implemented?
2. What architectural patterns are shared across /plan, /implement, and /research?
3. How do these commands validate tasks and delegate to subagents?
4. How does status-sync-manager perform atomic updates?
5. What are the best practices for creating a new command?

### Scope

- **In Scope**: Command structure, validation patterns, delegation mechanisms, status synchronization
- **Out of Scope**: Implementation details, testing strategies, UI/UX considerations

---

## Key Findings

### Finding 1: Two-Stage Command Pattern

**Evidence**: All workflow commands (/plan, /implement, /research) follow identical two-stage pattern:

**Stage 1: ParseAndValidate**
```bash
# Parse task number from $ARGUMENTS
task_number=$(echo "$ARGUMENTS" | awk '{print $1}')

# Validate state.json exists
if [ ! -f .opencode/specs/state.json ]; then
  echo "Error: Run /meta to regenerate state.json"
  exit 1
fi

# Lookup task in state.json (8x faster than TODO.md)
task_data=$(jq -r --arg num "$task_number" \
  '.active_projects[] | select(.project_number == ($num | tonumber))' \
  .opencode/specs/state.json)

# Validate task exists
if [ -z "$task_data" ]; then
  echo "Error: Task $task_number not found"
  exit 1
fi

# Extract all metadata at once
language=$(echo "$task_data" | jq -r '.language // "general"')
status=$(echo "$task_data" | jq -r '.status')
project_name=$(echo "$task_data" | jq -r '.project_name')
description=$(echo "$task_data" | jq -r '.description // ""')
priority=$(echo "$task_data" | jq -r '.priority')
```

**Stage 2: Delegate**
```bash
# Invoke target agent via task tool
task(
  subagent_type="${target_agent}",
  prompt="...",
  description="..."
)
```

**Implications for /abandon**:
- Follow exact same two-stage pattern
- Use state.json for fast task lookup (not TODO.md)
- Extract all metadata in single jq call
- Validate task status before proceeding

**Source**: .opencode/command/plan.md (lines 39-82), implement.md (lines 26-67), research.md (lines 26-64)

---

### Finding 2: Commands Are Thin Routing Layers

**Evidence**: Command files are 50-200 lines, contain minimal logic:

| Command | Lines | Logic |
|---------|-------|-------|
| /plan | 213 | Parse args, validate, route to planner |
| /implement | 122 | Parse args, validate, route to implementer |
| /research | 115 | Parse args, validate, route to researcher |

**Key Characteristics**:
- No business logic in commands
- No status updates in commands
- No git operations in commands
- All workflow logic delegated to subagents

**Subagent Responsibilities**:
- Update status to [IN_PROGRESS] variant (preflight)
- Execute core workflow
- Create artifacts
- Update status to completion state (postflight)
- Create git commits via git-workflow-manager
- Return standardized JSON

**Implications for /abandon**:
- /abandon should be ~100-150 lines
- Delegate all status updates to status-sync-manager
- No direct file manipulation in command
- Follow delegation safety patterns

**Source**: .opencode/command/*.md, .opencode/agent/subagents/*.md

---

### Finding 3: State.json Is Authoritative Source

**Evidence**: All commands use state.json for metadata lookup, not TODO.md:

**Performance Comparison**:
- TODO.md parsing: ~100ms per lookup (grep + awk parsing)
- state.json lookup: ~4ms per lookup (single jq query)
- **Improvement**: 25x faster

**Metadata Extraction Pattern**:
```bash
# Single jq call extracts all metadata
task_data=$(jq -r --arg num "$task_number" \
  '.active_projects[] | select(.project_number == ($num | tonumber))' \
  .opencode/specs/state.json)

# Extract fields with defaults
language=$(echo "$task_data" | jq -r '.language // "general"')
status=$(echo "$task_data" | jq -r '.status')
priority=$(echo "$task_data" | jq -r '.priority')
```

**Sync Direction**: state.json → TODO.md (not bidirectional)
- state.json is source of truth
- TODO.md is user-facing view
- status-sync-manager keeps them synchronized

**Implications for /abandon**:
- Extract task metadata from state.json only
- Validate task exists in state.json
- Check current status from state.json
- Delegate to status-sync-manager for updates

**Source**: .opencode/context/core/templates/command-template.md (lines 62-77), state-management.md

---

### Finding 4: Status-Sync-Manager Provides Atomic Updates

**Evidence**: status-sync-manager implements two-phase commit protocol:

**Phase 1: Prepare**
1. Read all target files (TODO.md, state.json, plan files)
2. Create backups of original content
3. Validate status transition is valid
4. Validate artifacts exist (if linking)
5. Prepare all updates in memory

**Phase 2: Commit**
1. Write TODO.md (most critical first)
2. Verify write succeeded
3. Write state.json
4. Verify write succeeded
5. Write plan files (if applicable)
6. If any write fails: rollback all previous writes

**Rollback Mechanism**:
```
If any write fails:
1. Immediately stop further writes
2. Restore all previously written files from backups
3. Log error with details
4. Return failed status with rollback info
```

**Status Transition Validation**:
```
Valid transitions to [ABANDONED]:
- [IN PROGRESS] → [ABANDONED] (work abandoned)
- [BLOCKED] → [ABANDONED] (blocker unresolvable)
- [RESEARCHING] → [ABANDONED] (research abandoned)
- [PLANNING] → [ABANDONED] (planning abandoned)
- [IMPLEMENTING] → [ABANDONED] (implementation abandoned)

Invalid transitions:
- [COMPLETED] → [ABANDONED] (completed is terminal)
- [NOT STARTED] → [ABANDONED] (cannot abandon work never started)
```

**Required Fields for [ABANDONED]**:
- `abandonment_reason` parameter (required)
- `**Abandoned**: YYYY-MM-DD` timestamp
- `**Abandonment Reason**: {reason}` in TODO.md

**Implications for /abandon**:
- Delegate to status-sync-manager for all updates
- Pass abandonment_reason parameter
- Validate status allows abandonment
- Rely on two-phase commit for atomicity

**Source**: .opencode/agent/subagents/status-sync-manager.md (lines 344-594)

---

### Finding 5: Standardized Delegation Pattern

**Evidence**: All subagents follow standardized delegation pattern:

**Delegation Context Structure**:
```json
{
  "task_number": 298,
  "new_status": "abandoned",
  "timestamp": "2026-01-05",
  "session_id": "sess_20260105_abc123",
  "delegation_depth": 1,
  "delegation_path": ["orchestrator", "abandon", "status-sync-manager"],
  "abandonment_reason": "No longer needed due to architectural changes"
}
```

**Return Format** (subagent-return-format.md):
```json
{
  "status": "completed|failed|partial|blocked",
  "summary": "Brief 2-5 sentence summary (<100 tokens)",
  "artifacts": [
    {
      "type": "state_update",
      "path": ".opencode/specs/TODO.md",
      "summary": "Updated status marker and timestamp"
    }
  ],
  "metadata": {
    "session_id": "sess_20260105_abc123",
    "duration_seconds": 2,
    "agent_type": "status-sync-manager",
    "delegation_depth": 1,
    "delegation_path": ["orchestrator", "abandon", "status-sync-manager"]
  },
  "errors": [],
  "next_steps": "Task marked as abandoned"
}
```

**Delegation Safety**:
- Max delegation depth: 3 (prevents infinite loops)
- Timeout per delegation: 60-300s (prevents hangs)
- Session ID tracking (enables debugging)
- Validation of return format (catches errors early)

**Implications for /abandon**:
- Generate unique session_id before delegation
- Pass complete delegation context
- Validate return format matches standard
- Handle timeout and error cases

**Source**: .opencode/context/core/standards/delegation.md, subagent-return-format.md

---

### Finding 6: Argument Parsing Patterns

**Evidence**: Commands support flexible argument parsing:

**Pattern 1: Task Number Only**
```bash
/abandon 298
```

**Pattern 2: Task Number + Inline Reason**
```bash
/abandon 298 "No longer needed due to architectural changes"
```

**Parsing Logic**:
```bash
# Extract task number (first token)
task_number=$(echo "$ARGUMENTS" | awk '{print $1}')

# Extract remaining tokens as reason (if present)
reason=$(echo "$ARGUMENTS" | cut -d' ' -f2-)

# If reason empty, prompt user
if [ -z "$reason" ]; then
  echo "Abandonment reason required. Please provide reason:"
  read -r reason
fi
```

**Validation**:
- Task number must be positive integer
- Reason must be non-empty string
- Reason should be 10-500 characters

**Implications for /abandon**:
- Support both inline and prompted reason
- Validate reason is meaningful (not just ".")
- Provide clear error messages for invalid input

**Source**: .opencode/command/plan.md (lines 42-75), implement.md (lines 29-59)

---

### Finding 7: Error Handling Patterns

**Evidence**: Commands provide clear, actionable error messages:

**Task Not Found**:
```
Error: Task 298 not found in .opencode/specs/state.json
Recommendation: Verify task number exists in TODO.md
```

**Invalid Task Number**:
```
Error: Task number must be an integer. Got: abc
Usage: /abandon TASK_NUMBER [REASON]
```

**Invalid Status Transition**:
```
Error: Task 298 is already [COMPLETED]
Recommendation: Cannot abandon completed tasks
```

**Missing Required Parameter**:
```
Error: Abandonment reason required
Usage: /abandon TASK_NUMBER [REASON]
Example: /abandon 298 "No longer needed"
```

**Error Handling Strategy**:
1. Validate early (fail fast)
2. Provide clear error messages
3. Include recommendations
4. Show usage examples
5. Exit with non-zero code

**Implications for /abandon**:
- Validate task exists before proceeding
- Validate status allows abandonment
- Validate reason is provided
- Provide helpful error messages

**Source**: .opencode/command/plan.md (lines 169-200), implement.md (lines 87-122)

---

## Detailed Analysis

### /plan Command Architecture

**File**: .opencode/command/plan.md (213 lines)

**Frontmatter**:
```yaml
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
```

**Stage 1: ParseAndValidate** (lines 39-82)
1. Parse task number from $ARGUMENTS
2. Validate state.json exists and is valid JSON
3. Lookup task in state.json using jq
4. Extract all metadata at once (language, status, description, priority, plan_path)
5. Validate task status allows planning (not completed)
6. Check if plan already exists (warn if it does)
7. Extract custom prompt from $ARGUMENTS if present
8. Determine target agent based on language (lean → lean-planner, general → planner)

**Stage 2: Delegate** (lines 84-99)
1. Invoke target agent via task tool
2. Wait for planner to complete
3. Relay result to user

**Key Observations**:
- No business logic in command
- All validation uses state.json (not TODO.md)
- Language-based routing to specialized agents
- Clear separation of concerns

**Delegation to Planner**:
- Planner updates status to [PLANNING] (preflight)
- Planner creates implementation plan
- Planner updates status to [PLANNED] (postflight)
- Planner delegates to status-sync-manager for atomic updates
- Planner delegates to git-workflow-manager for commits

---

### /implement Command Architecture

**File**: .opencode/command/implement.md (122 lines)

**Frontmatter**:
```yaml
name: implement
agent: orchestrator
description: "Execute implementation with resume support and [COMPLETED] status"
timeout: 7200
routing:
  language_based: true
  lean: lean-implementation-agent
  default: implementer
```

**Stage 1: ParseAndValidate** (lines 26-67)
1. Parse task number from $ARGUMENTS (supports ranges: 105-107)
2. Validate state.json exists and is valid JSON
3. Lookup task in state.json using jq
4. Extract all metadata at once
5. Validate task status allows implementation (not completed, not abandoned)
6. Extract custom prompt from $ARGUMENTS if present
7. Determine target agent based on language

**Stage 2: Delegate** (lines 69-84)
1. Invoke target agent via task tool
2. Wait for implementer to complete
3. Relay result to user

**Key Observations**:
- Supports batch operations (ranges)
- Validates against abandoned status
- Language-based routing
- Longer timeout (7200s vs 1800s for planning)

**Delegation to Implementer**:
- Implementer updates status to [IMPLEMENTING] (preflight)
- Implementer executes implementation
- Implementer creates summary artifact
- Implementer updates status to [COMPLETED] (postflight)
- Implementer delegates to status-sync-manager
- Implementer delegates to git-workflow-manager

---

### /research Command Architecture

**File**: .opencode/command/research.md (115 lines)

**Frontmatter**:
```yaml
name: research
agent: orchestrator
description: "Conduct research and create reports with [RESEARCHED] status"
timeout: 3600
routing:
  language_based: true
  lean: lean-research-agent
  default: researcher
```

**Stage 1: ParseAndValidate** (lines 26-64)
1. Parse task number from $ARGUMENTS
2. Validate state.json exists and is valid JSON
3. Lookup task in state.json using jq
4. Extract all metadata at once
5. Validate task status allows research (not completed)
6. Extract research focus from $ARGUMENTS if present
7. Determine target agent based on language

**Stage 2: Delegate** (lines 66-82)
1. Invoke target agent via task tool
2. Wait for researcher to complete
3. Relay result to user

**Key Observations**:
- Simplest command structure
- Medium timeout (3600s)
- Language-based routing
- Research focus parameter optional

**Delegation to Researcher**:
- Researcher updates status to [RESEARCHING] (preflight)
- Researcher conducts research
- Researcher creates research report
- Researcher updates status to [RESEARCHED] (postflight)
- Researcher delegates to status-sync-manager
- Researcher delegates to git-workflow-manager

---

### Status-Sync-Manager Architecture

**File**: .opencode/agent/subagents/status-sync-manager.md (1193 lines)

**Purpose**: Atomic multi-file status synchronization using two-phase commit

**Operations Supported**:
1. `update_status`: Update task status across TODO.md and state.json
2. `create_task`: Create new task in both files
3. `archive_tasks`: Move completed tasks to archive

**Update Status Flow** (lines 344-594):

**Step 1: Prepare** (lines 345-356)
- Read TODO.md into memory
- Read state.json into memory
- Read plan file if plan_path provided
- Validate all files readable
- Create backups of original content

**Step 2: Validate** (lines 358-397)
- Pre-commit validation for all target files
- Extract current status from TODO.md
- Check transition is valid per status-markers.md
- Verify required fields present (blocking_reason, abandonment_reason)
- Validate timestamp format (YYYY-MM-DD or ISO 8601)
- Validate artifacts if validated_artifacts provided
- If invalid transition: abort before writing

**Step 3: Prepare Updates** (lines 399-549)
- Regenerate TODO.md YAML header from state.json
- Update TODO.md task entry in memory:
  * Change status marker
  * Add/update timestamp fields
  * Add artifact links from validated_artifacts
  * Add blocking/abandonment reason if applicable
  * Add checkmark to title if completed
- Update state.json in memory:
  * Change status field (lowercase, underscore)
  * Add/update timestamp fields
  * Add artifact references
  * Add plan_metadata if provided
- Validate all updates well-formed

**Step 4: Commit** (lines 551-572)
- Write TODO.md (first, most critical)
- Verify write succeeded
- Write state.json
- Verify write succeeded
- Write plan file if plan_path and phase_statuses provided
- If any write fails: rollback all previous writes

**Rollback Mechanism** (lines 562-570):
```
If any write fails:
1. Immediately stop further writes
2. Restore all previously written files from backups
3. Log error with details
4. Return failed status with rollback info
5. Include specific file that failed in error message
```

**Step 5: Return** (lines 574-594)
- Post-commit validation for all files written
- Rollback validation (if rollback occurred)
- Format return following subagent-return-format.md
- Include files updated
- Include rollback info if applicable
- Return status completed or failed

**Status Transition Validation** (lines 1136-1158):

**Valid Transitions**:
- `not_started` → `in_progress`
- `not_started` → `blocked`
- `in_progress` → `researched` (research complete)
- `in_progress` → `planned` (plan complete)
- `in_progress` → `completed`
- `in_progress` → `blocked`
- `in_progress` → `abandoned`
- `researched` → `in_progress` (start planning)
- `researched` → `planned` (plan created)
- `planned` → `in_progress` (start implementation)
- `blocked` → `in_progress` (blocker resolved)
- `blocked` → `abandoned` (blocker unresolvable)

**Invalid Transitions**:
- `completed` → any (completed is terminal)
- `not_started` → `completed` (must go through in_progress)
- `not_started` → `abandoned` (cannot abandon work never started)
- `abandoned` → `completed` (abandoned work not complete)

**Required Fields for [ABANDONED]** (lines 104-106):
```yaml
abandonment_reason: "Reason for abandoned status (required if new_status is abandoned)"
```

**Implications for /abandon**:
- Delegate to status-sync-manager with operation="update_status"
- Pass abandonment_reason parameter (required)
- status-sync-manager validates transition is valid
- status-sync-manager performs atomic update
- status-sync-manager handles rollback on failure

---

### Command Template Standard

**File**: .opencode/context/core/templates/command-template.md (278 lines)

**Frontmatter Structure** (lines 6-32):
```yaml
name: {command_name}
agent: orchestrator
description: "{Brief description}"
context_level: 2
language: {markdown|lean|python|varies}
routing:
  language_based: {true|false}
  target_agent: {agent_name}  # If language_based: false
  lean: {lean_agent_name}      # If language_based: true
  default: {default_agent_name} # If language_based: true
context_loading:
  strategy: lazy
  index: ".opencode/context/index.md"
  required:
    - "core/standards/subagent-return-format.md"
    - "core/workflows/status-transitions.md"
    - "core/system/routing-guide.md"
  optional:
    - "{domain-specific context files}"
  max_context_size: 50000
```

**Command Body Structure** (lines 34-106):
1. Task Input specification
2. Context block
3. Workflow setup:
   - Stage 1: Parse arguments
   - Stage 2: Delegate to agent
   - Stage 3: Return result
4. Notes on delegation and ownership

**Fast Task Lookup Pattern** (lines 62-77):
```bash
# Validate and lookup task (8x faster than TODO.md parsing)
task_data=$(jq -r --arg num "$task_number" \
  '.active_projects[] | select(.project_number == ($num | tonumber))' \
  .opencode/specs/state.json)

if [ -z "$task_data" ]; then
  echo "Error: Task $task_number not found"
  exit 1
fi

# Extract all metadata at once
language=$(echo "$task_data" | jq -r '.language // "general"')
status=$(echo "$task_data" | jq -r '.status')
project_name=$(echo "$task_data" | jq -r '.project_name')
```

**Guidelines** (lines 243-278):

**When to Use Direct Routing**:
- Command always uses same agent regardless of task
- Examples: /plan, /revise, /review, /todo, /task

**When to Use Language-Based Routing**:
- Command needs different agents for different languages
- Examples: /research, /implement

**Context Loading**:
- Tier 2 (Commands): 10-20% context window (~20-40KB)
- Load only what's needed for routing and validation
- Agents load domain-specific context (Tier 3)

**Workflow Ownership**:
- Commands are thin routing layers
- Agents own complete workflows
- Agents handle status updates, git commits, artifact creation

**Performance Optimization**:
- Use state.json for task lookups: 25-50x faster than TODO.md parsing
- Extract all metadata at once: Avoid multiple jq calls
- Validate state.json exists: Check file exists before reading

**Implications for /abandon**:
- Use direct routing (no language-based routing needed)
- Target agent: status-sync-manager (no intermediate agent needed)
- Follow command template structure exactly
- Use state.json for fast task lookup
- Validate task status before delegating

---

## Code Examples

### Example 1: /abandon Command Structure

```yaml
---
name: abandon
agent: orchestrator
description: "Mark tasks as [ABANDONED] with reason"
context_level: 2
language: markdown
routing:
  language_based: false
  target_agent: status-sync-manager
timeout: 300
context_loading:
  strategy: lazy
  index: ".opencode/context/index.md"
  required:
    - "core/standards/delegation.md"
    - "core/system/state-management.md"
    - "core/standards/command-argument-handling.md"
  max_context_size: 50000
---

**Task Input (required):** $ARGUMENTS

<context>
  <system_context>Abandon command with status validation</system_context>
  <task_context>Parse task number, validate, extract reason, delegate to status-sync-manager</task_context>
</context>

<role>Abandon command agent - Parse arguments and route to status-sync-manager</role>

<task>
  Parse task number and reason from $ARGUMENTS, lookup task in state.json, validate status allows abandonment, delegate to status-sync-manager
</task>

<workflow_execution>
  <stage id="1" name="ParseAndValidate">
    <action>Parse task number and reason, lookup in state.json</action>
    <process>
      1. Parse task number from $ARGUMENTS
         - $ARGUMENTS contains: "298" or "298 No longer needed"
         - Extract first token as task_number
         - Validate is integer
      
      2. Parse abandonment reason from $ARGUMENTS
         - Extract remaining tokens as reason
         - If reason empty: Prompt user for reason
         - Validate reason is non-empty (10-500 chars)
      
      3. Validate state.json exists and is valid
         - Check .opencode/specs/state.json exists
         - Validate is valid JSON with jq
         - If missing/corrupt: Return error "Run /meta to regenerate state.json"
      
      4. Lookup task in state.json
         - Use jq to find task by project_number:
           task_data=$(jq -r --arg num "$task_number" \
             '.active_projects[] | select(.project_number == ($num | tonumber))' \
             .opencode/specs/state.json)
         - If task_data is empty: Return error "Task $task_number not found"
      
      5. Extract current status
         - status=$(echo "$task_data" | jq -r '.status')
      
      6. Validate task status allows abandonment
         - If status is "completed": Return error "Cannot abandon completed task"
         - If status is "abandoned": Return error "Task already abandoned"
         - If status is "not_started": Return error "Cannot abandon task that hasn't started"
      
      7. Generate timestamp: $(date -I)
    </process>
    <checkpoint>Task validated, reason extracted, status allows abandonment</checkpoint>
  </stage>
  
  <stage id="2" name="Delegate">
    <action>Delegate to status-sync-manager with abandonment context</action>
    <process>
      1. Generate session_id: sess_$(date +%Y%m%d)_$(openssl rand -hex 3)
      
      2. Invoke status-sync-manager via task tool:
         task(
           subagent_type="status-sync-manager",
           prompt="Update task ${task_number} status to abandoned with reason: ${reason}",
           description="Abandon task ${task_number}"
         )
         
         Delegation context:
         {
           "operation": "update_status",
           "task_number": ${task_number},
           "new_status": "abandoned",
           "timestamp": "${timestamp}",
           "abandonment_reason": "${reason}",
           "session_id": "${session_id}",
           "delegation_depth": 1,
           "delegation_path": ["orchestrator", "abandon", "status-sync-manager"]
         }
      
      3. Wait for status-sync-manager to complete
      
      4. Validate return format
      
      5. Relay result to user
    </process>
    <checkpoint>Delegated to status-sync-manager, result relayed</checkpoint>
  </stage>
</workflow_execution>

## Usage

```bash
/abandon TASK_NUMBER [REASON]
/abandon 298
/abandon 298 "No longer needed due to architectural changes"
```

## What This Does

1. Parses task number and optional reason from arguments
2. Validates task exists in state.json
3. Validates task status allows abandonment (not completed, not already abandoned, not not_started)
4. Prompts for reason if not provided inline
5. Delegates to status-sync-manager to atomically update TODO.md and state.json
6. Returns success or error message

## Error Handling

**Task Not Found:**
```
Error: Task 298 not found in .opencode/specs/TODO.md
Recommendation: Verify task number exists in TODO.md
```

**Invalid Task Number:**
```
Error: Task number must be an integer. Got: abc
Usage: /abandon TASK_NUMBER [REASON]
```

**Task Already Completed:**
```
Error: Task 298 is already [COMPLETED]
Recommendation: Cannot abandon completed tasks
```

**Task Already Abandoned:**
```
Error: Task 298 is already [ABANDONED]
Recommendation: Task was abandoned on 2026-01-04
```

**Task Not Started:**
```
Error: Task 298 is [NOT STARTED]
Recommendation: Cannot abandon work that hasn't started. Use /todo to remove task instead.
```

**Missing Reason:**
```
Error: Abandonment reason required
Usage: /abandon TASK_NUMBER [REASON]
Example: /abandon 298 "No longer needed"
```

## Notes

- Command delegates all status updates to status-sync-manager
- status-sync-manager ensures atomic updates across TODO.md and state.json
- Abandonment reason is required and stored in both files
- No git commit created (status-sync-manager handles this)
```

---

### Example 2: Argument Parsing Logic

```bash
#!/bin/bash

# Parse task number (first token)
task_number=$(echo "$ARGUMENTS" | awk '{print $1}')

# Validate task number is integer
if ! [[ "$task_number" =~ ^[0-9]+$ ]]; then
  echo "Error: Task number must be an integer. Got: $task_number"
  echo "Usage: /abandon TASK_NUMBER [REASON]"
  exit 1
fi

# Parse reason (remaining tokens)
reason=$(echo "$ARGUMENTS" | cut -d' ' -f2-)

# If reason empty, prompt user
if [ -z "$reason" ] || [ "$reason" = "$task_number" ]; then
  echo "Abandonment reason required. Please provide reason:"
  read -r reason
  
  # Validate reason is non-empty
  if [ -z "$reason" ]; then
    echo "Error: Abandonment reason cannot be empty"
    echo "Usage: /abandon TASK_NUMBER [REASON]"
    exit 1
  fi
fi

# Validate reason length (10-500 chars)
reason_length=${#reason}
if [ "$reason_length" -lt 10 ]; then
  echo "Error: Abandonment reason too short (minimum 10 characters)"
  echo "Example: /abandon 298 \"No longer needed due to architectural changes\""
  exit 1
fi

if [ "$reason_length" -gt 500 ]; then
  echo "Error: Abandonment reason too long (maximum 500 characters)"
  exit 1
fi
```

---

### Example 3: Task Validation Logic

```bash
#!/bin/bash

# Validate state.json exists
if [ ! -f .opencode/specs/state.json ]; then
  echo "Error: .opencode/specs/state.json not found"
  echo "Recommendation: Run /meta to regenerate state.json"
  exit 1
fi

# Validate state.json is valid JSON
if ! jq empty .opencode/specs/state.json 2>/dev/null; then
  echo "Error: .opencode/specs/state.json is not valid JSON"
  echo "Recommendation: Run /meta to regenerate state.json"
  exit 1
fi

# Lookup task in state.json
task_data=$(jq -r --arg num "$task_number" \
  '.active_projects[] | select(.project_number == ($num | tonumber))' \
  .opencode/specs/state.json)

# Validate task exists
if [ -z "$task_data" ]; then
  echo "Error: Task $task_number not found in .opencode/specs/state.json"
  echo "Recommendation: Verify task number exists in TODO.md"
  exit 1
fi

# Extract current status
status=$(echo "$task_data" | jq -r '.status')

# Validate status allows abandonment
case "$status" in
  "completed")
    echo "Error: Task $task_number is already [COMPLETED]"
    echo "Recommendation: Cannot abandon completed tasks"
    exit 1
    ;;
  "abandoned")
    echo "Error: Task $task_number is already [ABANDONED]"
    echo "Recommendation: Task was previously abandoned"
    exit 1
    ;;
  "not_started")
    echo "Error: Task $task_number is [NOT STARTED]"
    echo "Recommendation: Cannot abandon work that hasn't started. Use /todo to remove task instead."
    exit 1
    ;;
  *)
    # Status allows abandonment (in_progress, researching, planning, implementing, blocked)
    echo "Task $task_number status: [$status] - abandonment allowed"
    ;;
esac
```

---

### Example 4: Delegation to Status-Sync-Manager

```bash
#!/bin/bash

# Generate session ID
timestamp=$(date +%Y%m%d)
random=$(openssl rand -hex 3)
session_id="sess_${timestamp}_${random}"

# Generate ISO 8601 timestamp
iso_timestamp=$(date -I)

# Prepare delegation context
delegation_context=$(cat <<EOF
{
  "operation": "update_status",
  "task_number": ${task_number},
  "new_status": "abandoned",
  "timestamp": "${iso_timestamp}",
  "abandonment_reason": "${reason}",
  "session_id": "${session_id}",
  "delegation_depth": 1,
  "delegation_path": ["orchestrator", "abandon", "status-sync-manager"]
}
EOF
)

# Invoke status-sync-manager
echo "Delegating to status-sync-manager..."
result=$(task \
  --subagent-type="status-sync-manager" \
  --prompt="Update task ${task_number} status to abandoned with reason: ${reason}" \
  --description="Abandon task ${task_number}" \
  --context="${delegation_context}" \
  --timeout=300)

# Validate return format
if ! echo "$result" | jq empty 2>/dev/null; then
  echo "Error: status-sync-manager returned invalid JSON"
  echo "Result: $result"
  exit 1
fi

# Extract status from return
return_status=$(echo "$result" | jq -r '.status')

# Check if update succeeded
if [ "$return_status" = "completed" ]; then
  echo "Task $task_number marked as [ABANDONED]"
  echo "Reason: $reason"
  echo "Files updated: TODO.md, state.json"
else
  echo "Error: Failed to abandon task $task_number"
  echo "Status: $return_status"
  echo "Details: $(echo "$result" | jq -r '.summary')"
  exit 1
fi
```

---

## Decisions

### Decision 1: Direct Routing to status-sync-manager

**Options Considered**:
1. Create intermediate "abandoner" subagent (like planner, implementer)
2. Route directly to status-sync-manager

**Decision**: Route directly to status-sync-manager

**Rationale**:
- /abandon has no business logic beyond status update
- No artifacts to create (unlike /plan, /research, /implement)
- No workflow steps beyond validation and status change
- Creating intermediate agent adds unnecessary complexity
- status-sync-manager already handles all required logic

**Trade-offs**:
- Pro: Simpler architecture, fewer files
- Pro: Faster execution (one less delegation)
- Pro: Easier to maintain
- Con: Breaks pattern of command → subagent → status-sync-manager
- Con: Less extensible if future requirements emerge

**Conclusion**: Direct routing is appropriate for simple status-only commands

---

### Decision 2: Validate Status Transition in Command

**Options Considered**:
1. Validate status transition in command (before delegation)
2. Delegate validation to status-sync-manager

**Decision**: Validate in command AND in status-sync-manager

**Rationale**:
- Early validation provides better UX (fail fast)
- Command can provide context-specific error messages
- status-sync-manager validation is safety net (defense in depth)
- Prevents unnecessary delegation for invalid transitions

**Trade-offs**:
- Pro: Better error messages
- Pro: Faster failure for invalid transitions
- Pro: Defense in depth (two validation layers)
- Con: Duplicate validation logic
- Con: Must keep both validators in sync

**Conclusion**: Duplicate validation acceptable for better UX

---

### Decision 3: Prompt for Reason if Not Provided

**Options Considered**:
1. Require reason inline (fail if not provided)
2. Prompt for reason if not provided inline

**Decision**: Prompt for reason if not provided

**Rationale**:
- Better UX (user doesn't have to retry command)
- Consistent with other interactive commands
- Ensures reason is always captured
- Allows both workflows: inline and interactive

**Trade-offs**:
- Pro: Better UX
- Pro: Flexible usage
- Con: Requires interactive prompt handling
- Con: Cannot be used in non-interactive scripts

**Conclusion**: Prompting provides better UX for most use cases

---

### Decision 4: Minimum Reason Length

**Options Considered**:
1. No minimum length (allow any non-empty string)
2. Minimum 10 characters
3. Minimum 50 characters

**Decision**: Minimum 10 characters

**Rationale**:
- Prevents meaningless reasons (e.g., ".", "x", "no")
- 10 chars allows brief but meaningful reasons
- 50 chars too restrictive for simple cases
- Balances quality and flexibility

**Trade-offs**:
- Pro: Ensures meaningful reasons
- Pro: Not too restrictive
- Con: May require users to expand brief reasons

**Conclusion**: 10 character minimum strikes good balance

---

## Recommendations

### Recommendation 1: Follow Command Template Exactly

**Priority**: High

**Rationale**: Consistency across commands improves maintainability, reduces cognitive load, and ensures architectural patterns are followed.

**Implementation**:
1. Use .opencode/context/core/templates/command-template.md as base
2. Copy frontmatter structure from /plan or /research
3. Follow two-stage pattern (ParseAndValidate, Delegate)
4. Use state.json for task lookup (not TODO.md)
5. Validate early, delegate late

**Expected Outcome**: /abandon command follows same patterns as /plan, /implement, /research

---

### Recommendation 2: Delegate Directly to status-sync-manager

**Priority**: High

**Rationale**: /abandon has no business logic beyond status update, so intermediate agent is unnecessary complexity.

**Implementation**:
1. Set routing.target_agent to "status-sync-manager"
2. Set routing.language_based to false
3. Pass operation="update_status" in delegation context
4. Include abandonment_reason parameter

**Expected Outcome**: Simpler architecture, faster execution, easier maintenance

---

### Recommendation 3: Validate Status Transition in Command

**Priority**: Medium

**Rationale**: Early validation provides better error messages and prevents unnecessary delegation.

**Implementation**:
1. Extract current status from state.json
2. Check status is not "completed", "abandoned", or "not_started"
3. Provide context-specific error messages for each invalid case
4. Rely on status-sync-manager for final validation (defense in depth)

**Expected Outcome**: Better UX, faster failure for invalid transitions

---

### Recommendation 4: Support Both Inline and Prompted Reason

**Priority**: Medium

**Rationale**: Flexible usage patterns improve UX for different workflows.

**Implementation**:
1. Parse reason from $ARGUMENTS (tokens after task number)
2. If reason empty: Prompt user with read -r
3. Validate reason is 10-500 characters
4. Provide clear error messages for invalid reasons

**Expected Outcome**: Command works well in both interactive and inline modes

---

### Recommendation 5: Create Comprehensive Error Messages

**Priority**: Medium

**Rationale**: Clear error messages reduce user frustration and support tickets.

**Implementation**:
1. Task not found: "Error: Task X not found. Verify task number exists in TODO.md"
2. Invalid status: "Error: Task X is [STATUS]. Cannot abandon [STATUS] tasks."
3. Missing reason: "Error: Abandonment reason required. Usage: /abandon X [REASON]"
4. Invalid task number: "Error: Task number must be integer. Got: X"

**Expected Outcome**: Users understand errors and know how to fix them

---

### Recommendation 6: Add Usage Examples to Command Documentation

**Priority**: Low

**Rationale**: Examples help users understand command quickly.

**Implementation**:
```bash
## Usage

/abandon TASK_NUMBER [REASON]

## Examples

# Abandon with inline reason
/abandon 298 "No longer needed due to architectural changes"

# Abandon with prompted reason
/abandon 298
> Abandonment reason required. Please provide reason:
> No longer needed

# Error: Task already completed
/abandon 250
> Error: Task 250 is already [COMPLETED]
> Recommendation: Cannot abandon completed tasks
```

**Expected Outcome**: Users can quickly learn command usage

---

## Risks & Mitigations

### Risk 1: Status Transition Validation Mismatch

**Description**: Command validation and status-sync-manager validation may diverge over time.

**Likelihood**: Medium  
**Impact**: Medium (invalid transitions may be accepted or valid ones rejected)

**Mitigation**:
1. Document valid transitions in state-management.md
2. Reference same documentation in both validators
3. Add integration tests that verify both validators agree
4. Review validators when updating status-markers.md

---

### Risk 2: Reason Prompt Hangs in Non-Interactive Mode

**Description**: If command is run in non-interactive mode (e.g., script), read -r will hang waiting for input.

**Likelihood**: Low  
**Impact**: High (command hangs indefinitely)

**Mitigation**:
1. Detect non-interactive mode: if [ ! -t 0 ]; then
2. In non-interactive mode: Require reason inline, fail if not provided
3. Document requirement in command help
4. Add timeout to read -r: read -r -t 30 reason

---

### Risk 3: Abandonment Reason Contains Special Characters

**Description**: Reason may contain quotes, newlines, or other characters that break JSON or markdown formatting.

**Likelihood**: Medium  
**Impact**: Medium (delegation fails or files corrupted)

**Mitigation**:
1. Escape reason before passing to status-sync-manager
2. Use jq --arg to safely pass reason (automatic escaping)
3. Validate reason contains only printable ASCII characters
4. Strip newlines and control characters from reason

---

### Risk 4: User Abandons Task by Mistake

**Description**: User may accidentally abandon task they intended to continue.

**Likelihood**: Medium  
**Impact**: Low (can be reversed by changing status back)

**Mitigation**:
1. Add confirmation prompt for high-priority tasks
2. Log abandonment in git commit message
3. Document how to reverse abandonment in error message
4. Consider adding /unabandoned command for reversal

---

## Appendix: Sources and Citations

### Primary Sources

1. **.opencode/command/plan.md** (213 lines)
   - Two-stage command pattern
   - State.json lookup pattern
   - Language-based routing
   - Delegation to planner

2. **.opencode/command/implement.md** (122 lines)
   - Two-stage command pattern
   - Status validation (abandoned check)
   - Delegation to implementer
   - Batch operation support

3. **.opencode/command/research.md** (115 lines)
   - Two-stage command pattern
   - Simplest command structure
   - Delegation to researcher

4. **.opencode/agent/subagents/status-sync-manager.md** (1193 lines)
   - Two-phase commit protocol
   - Status transition validation
   - Atomic multi-file updates
   - Rollback mechanism
   - Required fields for [ABANDONED]

5. **.opencode/agent/subagents/planner.md** (300+ lines)
   - Subagent workflow pattern
   - Preflight status update
   - Postflight status update
   - Delegation to status-sync-manager
   - Delegation to git-workflow-manager

6. **.opencode/agent/subagents/implementer.md** (300+ lines)
   - Subagent workflow pattern
   - Language-based routing
   - Artifact creation
   - Summary artifact requirement

### Secondary Sources

7. **.opencode/context/core/templates/command-template.md** (278 lines)
   - Command structure standard
   - Frontmatter specification
   - Fast task lookup pattern
   - Routing guidelines
   - Performance optimization

8. **.opencode/context/core/standards/delegation.md** (150+ lines)
   - Return format specification
   - Delegation patterns
   - Session ID tracking
   - Delegation safety

9. **.opencode/context/core/standards/subagent-return-format.md** (150+ lines)
   - JSON schema for returns
   - Field specifications
   - Validation rules
   - Error handling

10. **.opencode/context/core/system/state-management.md** (200+ lines)
    - Status markers
    - Status transition diagram
    - Valid transitions table
    - State schemas

### Related Documentation

11. **.opencode/specs/TODO.md**
    - Task 298 description
    - Task metadata format
    - Status markers in use

12. **.opencode/specs/state.json**
    - State schema example
    - Active projects structure
    - Metadata fields

---

## Conclusion

The /abandon command should follow the exact same architectural patterns as /plan, /implement, and /research commands:

1. **Two-stage pattern**: ParseAndValidate → Delegate
2. **State.json lookup**: Fast task metadata extraction (8x faster than TODO.md)
3. **Direct routing**: Route directly to status-sync-manager (no intermediate agent needed)
4. **Status validation**: Validate transition in command (fail fast) and status-sync-manager (defense in depth)
5. **Flexible arguments**: Support both inline reason and prompted reason
6. **Atomic updates**: Delegate to status-sync-manager for two-phase commit
7. **Clear errors**: Provide context-specific error messages for all failure cases

The command should be ~100-150 lines, contain minimal logic, and delegate all status updates to status-sync-manager. This ensures consistency with existing commands, maintainability, and reliability.

**Next Steps**: Create implementation plan for /abandon command following these architectural patterns.
