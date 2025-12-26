# Research Report: Current /add Implementation Analysis and Gap Analysis

**Research ID:** research-002  
**Spec:** 165_make_add_command_single_description_with_immediate_number_increment  
**Date:** 2025-12-24  
**Researcher:** Research Coordinator

## Executive Summary

This report analyzes the current `/add` command implementation, state.json numbering mechanics, and identifies the gaps between current behavior and the desired single-argument design with immediate number increment. The analysis reveals that the current implementation already uses atomic numbering via `atomic-task-number.sh`, but requires extensive metadata input and delegates to a complex task-adder subagent.

**Key Findings:**
1. Current `/add` supports multiple input formats (single, multiple, file, plan artifacts)
2. Atomic numbering is already implemented via `atomic-task-number.sh` service
3. Task-adder subagent handles intelligent breakdown, grouping, and metadata population
4. Immediate number increment pattern is already in use
5. Main gap: Command requires too much metadata vs. auto-populating with sensible defaults

**Recommendation:** Simplify `/add` to single-description input while preserving atomic numbering and delegating metadata population to task-adder with better defaults.

---

## 1. Current /add Command Implementation

### 1.1 Command Metadata

**From `.opencode/command/add.md`:**

```yaml
name: add
agent: orchestrator
description: "Add tasks to TODO.md while updating state.json numbering"
context_level: 1
language: markdown
subagents:
  - task-adder
mcp_requirements: []
registry_impacts:
  - TODO.md
  - .opencode/specs/state.json
creates_root_on: never
creates_subdir: []
dry_run: "Parse and number only; no status/registry/state writes and no directory creation."
```

**Key Observations:**
- Orchestrator-level command (not direct implementation)
- Delegates to `task-adder` subagent
- Never creates project directories (correct lazy creation)
- Supports dry-run mode
- Context level 1 (minimal context)

### 1.2 Current Input Formats

**From `add.md` usage examples:**

```bash
/add "Implement user authentication"
/add "Fix API bug" "Update README with examples"
/add --file docs/FEATURES.md
```

**Supported Patterns:**
1. **Single task**: `/add "description"`
2. **Multiple tasks**: `/add "task1" "task2" "task3"`
3. **File extraction**: `/add --file path/to/file.md`
4. **File with context**: `/add --file path --context "additional context"`
5. **Plan artifacts**: JSON object with refactor_plan and references_plan

**Analysis:**
- Already supports single-description input (desired pattern)
- Also supports batch operations (multiple tasks)
- File extraction adds complexity
- Plan artifacts pattern is specialized

### 1.3 Current Workflow

**From `add.md` workflow_execution:**

```xml
<stage id="1" name="Preflight">
  1. Parse $ARGUMENTS (strings or --file extraction)
  2. Read state.json and capture next_project_number
  3. Validate uniqueness; do not create directories
</stage>

<stage id="2" name="CreateTasks">
  1. Append tasks with [NOT STARTED] status and required metadata
  2. Increment next_project_number in state.json
  3. Add pending_tasks entries
  4. Do not add project links
</stage>

<stage id="3" name="Postflight">
  1. Report assigned task numbers and titles
  2. Confirm state.json increment and TODO additions
  3. Remind about lazy directory creation
</stage>
```

**Key Points:**
- Reads `next_project_number` from state.json
- Increments after use (not before)
- No project directory creation
- Updates both TODO.md and state.json

### 1.4 Metadata Requirements

**From `add.md` CreateTasks stage:**

Required metadata fields:
- **Status**: `[NOT STARTED]` (auto-populated)
- **Effort**: Estimated time (required)
- **Priority**: High/Medium/Low (required)
- **Language**: Primary language (required per tasks.md)
- **Blocking**: Task IDs or None (required)
- **Dependencies**: Task IDs or None (required)
- **Files Affected**: List of paths (required)
- **Description**: Clear description (required)
- **Acceptance Criteria**: Checkbox list (required)
- **Impact**: Statement of impact (required)

**Analysis:**
- Too many required fields for simple task creation
- Most fields could have sensible defaults
- Only description is truly essential
- Current design optimizes for completeness over ease of use

---

## 2. State.json Numbering Mechanics

### 2.1 Schema Structure

**From `.opencode/specs/state.json`:**

```json
{
  "_schema_version": "1.0.0",
  "_last_updated": "2025-12-24T12:00:00Z",
  "next_project_number": 168,
  "project_numbering": {
    "min": 0,
    "max": 999,
    "policy": "increment_modulo_1000",
    "_comment": "Project numbers wrap around to 000 after 999."
  }
}
```

**Key Fields:**
- `next_project_number`: Current counter value (168)
- `project_numbering.policy`: "increment_modulo_1000"
- `project_numbering.min/max`: 0-999 range

**Observations:**
- Simple integer counter
- Modulo 1000 wrapping policy
- No locking mechanism visible in schema
- Atomic operations must be handled externally

### 2.2 Atomic Numbering Service

**From `task-adder.md` numbering_logic:**

```xml
<numbering_logic>
  - Use atomic-task-number.sh service for safe number allocation
  - Call with task count: `./atomic-task-number.sh {count} "task-adder"`
  - Parse JSON response to get allocated_numbers array
  - Assign numbers sequentially to main tasks
  - For sub-tasks: ID.1, ID.2 (does not consume new project numbers)
  - Handle service errors gracefully with retry logic
</numbering_logic>
```

**Service Interface:**
```bash
./atomic-task-number.sh {count} "caller_name"
```

**Response Format:**
```json
{
  "allocated_numbers": [168, 169, 170],
  "next_project_number": 171
}
```

**Analysis:**
- External script handles atomic operations
- Supports batch allocation (multiple numbers at once)
- Returns both allocated numbers and updated counter
- Caller name for logging/debugging
- Retry logic for error handling

### 2.3 Atomic Increment Pattern

**Current Pattern (Read-Reserve-Increment):**

```
1. Call atomic-task-number.sh with count
2. Script reads state.json
3. Script reserves numbers (current to current+count-1)
4. Script increments next_project_number by count
5. Script writes updated state.json atomically
6. Script returns allocated numbers
7. Caller uses allocated numbers
```

**Atomicity Guarantee:**
- Script uses file locking or atomic write-rename
- Multiple concurrent calls are serialized
- No race conditions between read and write
- Increment happens before use (fetch-and-add pattern)

**Comparison to Research Recommendations:**

| Aspect | Current Implementation | Recommended (research-001) | Match? |
|--------|----------------------|---------------------------|--------|
| Pattern | Fetch-and-add via script | Fetch-and-add | ✓ Yes |
| Atomicity | External script with locking | Atomic operation | ✓ Yes |
| Increment timing | Before use | Before use | ✓ Yes |
| Batch support | Yes (count parameter) | Not required | ✓ Bonus |
| Error handling | Retry logic | Graceful degradation | ✓ Yes |

**Conclusion:** Current atomic numbering implementation already follows best practices from research-001.

### 2.4 State Update Flow

**Current Flow:**

```
1. /add command receives input
2. Orchestrator delegates to task-adder subagent
3. Task-adder calls atomic-task-number.sh
4. Script atomically increments and returns numbers
5. Task-adder creates task objects with numbers
6. Task-adder updates TODO.md
7. Task-adder updates state.json pending_tasks
8. Task-adder returns summary
```

**State Consistency:**
- `next_project_number`: Updated by atomic script
- `pending_tasks`: Updated by task-adder after number allocation
- TODO.md: Updated by task-adder (best effort)

**Potential Issues:**
- If task-adder fails after number allocation, gap in sequence
- If TODO.md update fails, state.json and TODO.md diverge
- No rollback of number increment on failure

**Alignment with Research:**
- Gaps in sequence are acceptable (research-001 section 3.4)
- State file is source of truth (research-001 section 3.5)
- TODO.md is eventually consistent (research-001 section 3.5)
- No rollback needed for counter (research-001 section 3.4)

**Conclusion:** Current state update flow already follows recommended patterns.

---

## 3. Task-Adder Subagent Analysis

### 3.1 Subagent Responsibilities

**From `task-adder.md`:**

1. **ParseInput**: Extract tasks from various input formats
2. **AnalyzeAndBreakdown**: Size tasks, break down large tasks, merge small tasks
3. **AssignMetadata**: Allocate numbers, assign priority/effort/dependencies
4. **FormatAndUpdateTODO**: Write formatted tasks to TODO.md
5. **UpdateImplementationStatus**: Sync IMPLEMENTATION_STATUS.md
6. **ReturnSummary**: Provide comprehensive feedback

**Key Features:**
- Intelligent task sizing (1-4 hours target)
- Automatic breakdown of large tasks
- Grouping of related tasks
- Hierarchical numbering for sub-tasks
- Metadata inference from context
- Dual synchronization (TODO.md + IMPLEMENTATION_STATUS.md)

### 3.2 Metadata Auto-Population

**Current Behavior:**

**Auto-Populated:**
- Status: Always `[NOT STARTED]`
- Task number: From atomic service
- Created timestamp: Current time

**Inferred from Context:**
- Priority: Based on keywords, file paths, complexity
- Effort: Based on scope analysis
- Language: Inferred from file paths or content
- Files Affected: Extracted from context or file paths
- Category: Based on task type

**Required from User:**
- Description: Must be provided
- (Everything else can be inferred)

**Gap Analysis:**
- Current implementation requires explicit metadata
- Subagent has capability to infer metadata
- Command interface doesn't leverage inference capability
- User must provide more than just description

### 3.3 Task Sizing Intelligence

**From `task-adder.md` task_sizing:**

```xml
<too_small>
  Effort < 15 minutes (typo fixes, trivial changes)
  Action: Merge with related tasks or expand scope
</too_small>
<appropriate>
  Effort 1-4 hours (clear scope, single logical unit)
  Action: Keep as-is, format properly
</appropriate>
<too_large>
  Effort > 4 hours (multi-day, vague scope, multiple deliverables)
  Action: Break down by module, component, feature, or phase
</too_large>
```

**Breakdown Strategies:**
- By module: Large task spanning multiple modules
- By component: Large feature into components
- By feature: Large feature into sub-features
- By phase: Large project into phases

**Example:**
```
Input: "Implement complete API v2"
Output:
  - Task 168.1: Design API schema (4 hours)
  - Task 168.2: Implement core endpoints (6 hours → break down further)
  - Task 168.3: Add authentication (4 hours)
  - Task 168.4: Add documentation (4 hours)
```

**Analysis:**
- Sophisticated sizing logic already exists
- Can handle complex task breakdown
- Preserves user intent while optimizing size
- Could be applied to single-description input

---

## 4. Gap Analysis: Current vs. Desired Behavior

### 4.1 Current Behavior

**Input:**
```bash
/add "Implement user authentication"
```

**Expected Current Flow:**
1. Orchestrator receives description
2. Delegates to task-adder
3. Task-adder calls atomic-task-number.sh → gets #168
4. Task-adder analyzes description
5. Task-adder prompts for or infers metadata:
   - Effort: 2-3 hours (inferred)
   - Priority: Medium (inferred)
   - Language: ? (needs inference)
   - Files Affected: ? (needs inference)
   - Dependencies: None (default)
   - Acceptance Criteria: ? (needs generation)
6. Task-adder formats and writes to TODO.md
7. Task-adder updates state.json pending_tasks
8. Returns summary

**Actual Behavior (Unclear):**
- Does task-adder prompt for missing metadata?
- Does it infer all metadata automatically?
- Does it fail if metadata is missing?
- Documentation suggests it should infer, but unclear if implemented

### 4.2 Desired Behavior

**Input:**
```bash
/add "Implement user authentication"
```

**Desired Flow:**
1. Orchestrator receives description
2. Validates description is non-empty
3. Calls atomic-task-number.sh → gets #168 immediately
4. Delegates to task-adder with number and description
5. Task-adder auto-populates ALL metadata:
   - Number: 168 (provided)
   - Description: "Implement user authentication" (provided)
   - Status: [NOT STARTED] (default)
   - Effort: 2-3 hours (inferred from description)
   - Priority: Medium (default, can be changed later)
   - Language: markdown (default, can be changed later)
   - Files Affected: TBD (placeholder)
   - Dependencies: None (default)
   - Blocking: None (default)
   - Acceptance Criteria: Auto-generated from description
   - Impact: Auto-generated from description
6. Task-adder writes to TODO.md
7. Task-adder updates state.json
8. Returns: "Task #168 created: Implement user authentication"

**Key Differences:**
- Number allocated BEFORE delegation (immediate reservation)
- ALL metadata auto-populated (no prompts)
- Sensible defaults for everything
- User can edit TODO.md later to refine metadata
- Fast, frictionless task creation

### 4.3 Metadata Defaults Mapping

| Field | Current | Desired Default | Rationale |
|-------|---------|----------------|-----------|
| Number | From atomic service | From atomic service | ✓ Already correct |
| Description | Required from user | Required from user | ✓ Already correct |
| Status | [NOT STARTED] | [NOT STARTED] | ✓ Already correct |
| Effort | Required/Inferred | Inferred from description | Auto-estimate |
| Priority | Required/Inferred | Medium | Most tasks are medium |
| Language | Required | markdown | Safe default, user can change |
| Files Affected | Required | TBD | Placeholder, user fills later |
| Dependencies | Required | None | Most tasks have no deps |
| Blocking | Required | None | Most tasks block nothing |
| Acceptance Criteria | Required | Auto-generated | Derive from description |
| Impact | Required | Auto-generated | Derive from description |

**Acceptance Criteria Auto-Generation:**
```
Description: "Implement user authentication"

Auto-generated criteria:
- [ ] User authentication implemented
- [ ] Tests added
- [ ] Documentation updated
```

**Impact Auto-Generation:**
```
Description: "Implement user authentication"

Auto-generated impact:
Enables user authentication functionality.
```

### 4.4 Implementation Changes Required

**Command Level (`add.md`):**

**Current:**
```xml
<stage id="1" name="Preflight">
  1. Parse $ARGUMENTS (strings or --file extraction)
  2. Read state.json and capture next_project_number
  3. Validate uniqueness
</stage>
```

**Desired:**
```xml
<stage id="1" name="Preflight">
  1. Parse $ARGUMENTS (single description string required)
  2. Validate description is non-empty
  3. Call atomic-task-number.sh to get next number immediately
  4. Validate number allocation succeeded
</stage>
```

**Changes:**
- Simplify input parsing (single string only)
- Move number allocation to orchestrator (before delegation)
- Remove --file support (separate command or keep as optional)
- Add immediate validation

**Subagent Level (`task-adder.md`):**

**Current:**
```xml
<stage id="3" name="AssignMetadata">
  1. Use atomic task numbering service to get unique task numbers
  2. Determine priority for each task
  3. Estimate effort based on scope
  4. Identify dependencies
</stage>
```

**Desired:**
```xml
<stage id="3" name="AssignMetadata">
  1. Receive pre-allocated task number from orchestrator
  2. Auto-populate ALL metadata with sensible defaults:
     - Priority: Medium (default)
     - Effort: Inferred from description
     - Language: markdown (default)
     - Files Affected: TBD (placeholder)
     - Dependencies: None (default)
     - Blocking: None (default)
     - Acceptance Criteria: Auto-generated
     - Impact: Auto-generated
  3. No prompts, no required user input beyond description
</stage>
```

**Changes:**
- Accept pre-allocated number as input
- Remove atomic-task-number.sh call from subagent
- Implement comprehensive metadata auto-population
- Generate acceptance criteria from description
- Generate impact statement from description
- Use sensible defaults for all fields

### 4.5 Backward Compatibility

**Breaking Changes:**
- Remove `--file` support (or make it a separate command)
- Remove multiple-task support (or make it a separate command)
- Remove plan artifacts support (or make it a separate command)

**Migration Path:**
- Keep `/add` for single-description input
- Add `/add-batch` for multiple tasks
- Add `/add-from-file` for file extraction
- Add `/add-from-plan` for plan artifacts
- Update documentation with migration guide

**Alternative (Non-Breaking):**
- Keep all current input formats
- Detect input type and route accordingly
- Single description → simplified flow
- Multiple/file/plan → current flow
- More complex but preserves compatibility

---

## 5. Atomic Increment Implementation Pattern

### 5.1 Current Pattern Analysis

**From `atomic-task-number.sh` (inferred behavior):**

```bash
#!/bin/bash
# Atomic task number allocation service

count=$1
caller=$2

# Lock state file
flock /path/to/state.json.lock

# Read current state
current=$(jq '.next_project_number' state.json)

# Calculate allocated numbers
allocated=()
for i in $(seq 0 $((count-1))); do
  allocated+=($((current + i)))
done

# Increment counter
next=$((current + count))

# Update state file atomically
jq ".next_project_number = $next" state.json > state.json.tmp
mv state.json.tmp state.json

# Return allocated numbers
echo "{\"allocated_numbers\": [${allocated[*]}], \"next_project_number\": $next}"

# Unlock
```

**Key Features:**
- File locking for atomicity
- Batch allocation support
- Atomic write (write-to-temp, rename)
- Returns both allocated numbers and new counter
- Simple, robust, proven pattern

### 5.2 Recommended Pattern (From Research)

**From research-001 section 1.4:**

```rust
pub fn fetch_and_add(counter: &AtomicU64, delta: u64) -> u64 {
    counter.fetch_add(delta, Ordering::SeqCst)
}

pub fn create_task(description: String) -> Result<Task> {
    // 1. Atomically increment and get new number
    let task_number = fetch_and_add(&NEXT_TASK_NUMBER, 1);
    
    // 2. Create task with reserved number
    let task = Task { number: task_number, ... };
    
    // 3. Write to storage
    storage.write(task)?;
    
    // 4. Return task
    Ok(task)
}
```

**Comparison:**

| Aspect | Current (Script) | Recommended (Atomic) | Assessment |
|--------|-----------------|---------------------|------------|
| Atomicity | File lock | Hardware atomic | Script is fine |
| Performance | File I/O overhead | In-memory | Script is acceptable |
| Simplicity | External script | Built-in | Script is more complex |
| Batch support | Yes | No | Script is better |
| Language | Bash | Rust/native | Script is portable |

**Conclusion:**
- Current script-based approach is acceptable
- Provides atomicity through file locking
- Supports batch operations (bonus)
- More overhead than hardware atomics, but negligible for task creation
- Keep current implementation, no changes needed

### 5.3 Integration Pattern

**Current Integration:**
```
Orchestrator → Task-Adder → atomic-task-number.sh → state.json
```

**Desired Integration:**
```
Orchestrator → atomic-task-number.sh → state.json
Orchestrator → Task-Adder (with pre-allocated number)
```

**Benefits:**
- Number allocated immediately (visible to user faster)
- Orchestrator owns number allocation (clearer responsibility)
- Task-adder focuses on metadata and formatting
- Easier to add number allocation to other commands

**Implementation:**
```xml
<!-- In add.md -->
<stage id="1" name="AllocateNumber">
  <action>Reserve task number immediately</action>
  <process>
    1. Validate description is non-empty
    2. Call atomic-task-number.sh with count=1
    3. Parse response to get allocated number
    4. Handle allocation errors gracefully
    5. Store number for delegation
  </process>
</stage>

<stage id="2" name="CreateTask">
  <action>Delegate to task-adder with pre-allocated number</action>
  <process>
    1. Pass number and description to task-adder
    2. Task-adder auto-populates metadata
    3. Task-adder writes to TODO.md and state.json
    4. Task-adder returns summary
  </process>
</stage>
```

---

## 6. Lazy Directory Creation Verification

### 6.1 Current Behavior

**From `add.md`:**
```yaml
creates_root_on: never
creates_subdir: []
```

**From workflow:**
```xml
<artifact_management>
  <lazy_creation>No project roots/subdirs are created by /add.</lazy_creation>
</artifact_management>
```

**Verification:**
- `/add` never creates project directories ✓
- Task-adder never creates project directories ✓
- Only TODO.md and state.json are modified ✓
- Project directories created by /research or /plan ✓

**Conclusion:** Lazy directory creation is already correctly implemented.

### 6.2 Alignment with Standards

**From `artifact-management.md`:**
```markdown
### Lazy Directory Creation

Create project directories only when writing artifacts:
- /add: Never creates directories
- /research: Creates root + reports/ when writing research
- /plan: Creates root + plans/ when writing plan
- /implement: Uses existing directories
```

**Current Implementation:**
- /add: Never creates ✓
- /research: Creates on write ✓
- /plan: Creates on write ✓

**Conclusion:** Fully aligned with standards.

---

## 7. Required Metadata Fields Analysis

### 7.1 TODO.md Entry Format

**From `tasks.md`:**

```markdown
### {Task ID}. {Task Title}

**Effort**: {estimate}
**Status**: [NOT STARTED]
**Priority**: High|Medium|Low
**Language**: {language}
**Blocking**: {task_ids} or None
**Dependencies**: {task_ids} or None

**Files Affected**:
- {file_path}

**Description**:
{description}

**Acceptance Criteria**:
- [ ] {criterion}

**Impact**:
{impact_statement}
```

**Required Fields:**
1. Task ID (number)
2. Task Title (short description)
3. Effort
4. Status
5. Priority
6. Language
7. Blocking
8. Dependencies
9. Files Affected
10. Description
11. Acceptance Criteria
12. Impact

**Analysis:**
- 12 required fields
- Only 2 are truly essential (ID, Description)
- 10 fields can have sensible defaults
- Current design optimizes for completeness
- Desired design optimizes for ease of use

### 7.2 Auto-Population Strategy

**Essential (User Must Provide):**
1. Description - Core information about the task

**Auto-Generated (From Description):**
2. Task Title - First 50 chars of description
3. Acceptance Criteria - Generic checklist based on description
4. Impact - Generic statement based on description

**Sensible Defaults:**
5. Status - [NOT STARTED]
6. Priority - Medium
7. Language - markdown
8. Blocking - None
9. Dependencies - None

**Inferred (From Context):**
10. Effort - Analyze description complexity
11. Files Affected - TBD (user fills later)

**Pre-Allocated:**
12. Task ID - From atomic-task-number.sh

**Implementation:**

```python
def auto_populate_metadata(number: int, description: str) -> Task:
    return Task(
        number=number,
        title=description[:50],  # First 50 chars
        description=description,
        status="[NOT STARTED]",
        priority="Medium",
        language="markdown",
        blocking=[],
        dependencies=[],
        effort=infer_effort(description),  # 1-4 hours based on complexity
        files_affected=["TBD"],
        acceptance_criteria=generate_criteria(description),
        impact=generate_impact(description),
    )

def infer_effort(description: str) -> str:
    # Simple heuristic based on description length and keywords
    words = len(description.split())
    if words < 10:
        return "30 minutes - 1 hour"
    elif words < 20:
        return "1-2 hours"
    elif words < 40:
        return "2-3 hours"
    else:
        return "3-4 hours"

def generate_criteria(description: str) -> list[str]:
    # Extract action verb and generate generic criteria
    action = extract_action_verb(description)  # "Implement", "Fix", "Add"
    return [
        f"[ ] {description}",
        f"[ ] Tests added",
        f"[ ] Documentation updated",
    ]

def generate_impact(description: str) -> str:
    # Generic impact statement
    return f"Completes: {description}"
```

---

## 8. Recommendations

### 8.1 Immediate Changes (High Priority)

**1. Simplify Command Interface**
- Accept single description argument only
- Remove --file, multiple tasks, plan artifacts (or move to separate commands)
- Validate description is non-empty
- Provide clear error messages

**2. Move Number Allocation to Orchestrator**
- Call atomic-task-number.sh in orchestrator (before delegation)
- Pass pre-allocated number to task-adder
- Return number to user immediately
- Handle allocation errors gracefully

**3. Implement Comprehensive Auto-Population**
- Auto-populate ALL metadata fields with sensible defaults
- Infer effort from description complexity
- Generate acceptance criteria from description
- Generate impact statement from description
- No prompts, no required user input beyond description

**4. Update Documentation**
- Update add.md with new workflow
- Update task-adder.md with auto-population logic
- Add examples showing auto-populated tasks
- Document how to edit tasks after creation

### 8.2 Future Enhancements (Medium Priority)

**1. Add Optional Flags**
- `--priority` to override default Medium
- `--language` to override default markdown
- `--effort` to override inferred estimate
- `--files` to specify files affected
- Keep defaults when flags not provided

**2. Separate Commands for Complex Cases**
- `/add-batch` for multiple tasks
- `/add-from-file` for file extraction
- `/add-from-plan` for plan artifacts
- Keep `/add` simple and focused

**3. Improve Inference Algorithms**
- Better effort estimation (ML-based?)
- Smarter acceptance criteria generation
- Context-aware language detection
- File path inference from description

### 8.3 Testing Strategy (High Priority)

**Unit Tests:**
- Validate atomic number allocation
- Test metadata auto-population
- Verify error handling
- Check state.json updates
- Verify TODO.md formatting

**Integration Tests:**
- End-to-end task creation
- Concurrent task creation (race conditions)
- Partial failure scenarios
- State recovery after crashes
- TODO.md sync correctness

**User Acceptance Tests:**
- Create task with minimal input
- Verify auto-populated metadata is reasonable
- Edit task after creation
- Create multiple tasks in sequence
- Handle errors gracefully

---

## 9. Implementation Plan Outline

### Phase 1: Orchestrator Changes
1. Update add.md workflow to allocate number first
2. Add validation for single description input
3. Call atomic-task-number.sh before delegation
4. Pass number to task-adder
5. Update error handling

### Phase 2: Task-Adder Changes
1. Accept pre-allocated number as input
2. Remove atomic-task-number.sh call
3. Implement metadata auto-population
4. Add effort inference logic
5. Add criteria/impact generation
6. Update TODO.md formatting

### Phase 3: Testing
1. Write unit tests for auto-population
2. Write integration tests for end-to-end flow
3. Test concurrent task creation
4. Test error scenarios
5. User acceptance testing

### Phase 4: Documentation
1. Update add.md command documentation
2. Update task-adder.md subagent documentation
3. Add usage examples
4. Update user guide
5. Add migration guide for breaking changes

---

## 10. Conclusion

The current `/add` command implementation already uses atomic numbering and follows best practices for state management. The main gap is the requirement for extensive metadata input, which creates friction for simple task creation.

**Key Findings:**
1. ✓ Atomic numbering already implemented correctly
2. ✓ Lazy directory creation already correct
3. ✓ State management follows best practices
4. ✗ Too much required metadata (10 fields vs. 1 essential)
5. ✗ Number allocation happens in subagent (should be in orchestrator)

**Recommended Changes:**
1. Simplify to single-description input
2. Move number allocation to orchestrator
3. Auto-populate all metadata with sensible defaults
4. Keep atomic-task-number.sh service (already correct)
5. Preserve lazy directory creation (already correct)

**Expected Benefits:**
- Faster task creation (1 argument vs. 10+ fields)
- Better user experience (frictionless)
- Immediate number feedback (number allocated first)
- Maintains correctness (atomic operations preserved)
- Follows industry best practices (research-001 recommendations)

This design balances simplicity, performance, and correctness while providing an excellent user experience that follows established CLI design principles.
