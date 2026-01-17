# Implementation Plan: Make /add Command Single-Description with Immediate Number Increment

**Project**: #165  
**Version**: 001  
**Date**: 2025-12-24  
**Complexity**: Moderate  
**Estimated Effort**: 2-3 hours  
**Language**: markdown  
**Status**: [IN PROGRESS]  
**Started**: 2025-12-24

---

## Research Inputs

This implementation plan is based on comprehensive research completed for task 165:

### Research Reports

1. **`specs/165_make_add_command_single_description_with_immediate_number_increment/reports/research-001.md`**
   - 582 lines of atomic number reservation patterns and best practices
   - CLI command design principles from clig.dev
   - State management and consistency guarantees
   - Linearizability and fetch-and-add patterns
   - Academic sources: Herlihy & Wing (1990), Martin Fowler patterns

2. **`specs/165_make_add_command_single_description_with_immediate_number_increment/reports/research-002.md`**
   - 582 lines of current /add command implementation analysis
   - State.json numbering mechanics documentation
   - Task-adder subagent capabilities analysis
   - Gap analysis: current vs. desired behavior
   - Comprehensive recommendations with implementation outline

3. **`specs/165_make_add_command_single_description_with_immediate_number_increment/summaries/research-summary.md`**
   - Executive summary of key findings
   - Metadata auto-population strategy table
   - Recommended changes by priority
   - Expected benefits quantification

### Specialist Analysis

4. **Complexity Analysis** (completed 2025-12-24)
   - Complexity Level: **MODERATE**
   - Estimated Effort: **2-3 hours**
   - Required Knowledge: CLI design, atomic operations, metadata inference, agent architecture
   - Potential Challenges: Metadata auto-population quality, orchestrator-subagent interface change
   - Risk Assessment: Low risk (atomic numbering already correct), Medium risk (auto-generation quality)

5. **Dependency Analysis** (completed 2025-12-24)
   - All required dependencies exist (atomic-task-numberer, task-adder, state management)
   - No blocking dependencies or missing prerequisites
   - 4 files require modification (add.md, task-adder.md, 2 standards docs)
   - Implementation order: Orchestrator → Subagent → Documentation → Testing

---

## Context

### System Context

Implementation planning system for simplifying the `/add` command to accept a single description argument while maintaining atomic number reservation and auto-populating all required metadata fields. The current system already implements correct atomic numbering via `atomic-task-number.sh` but requires 10+ metadata fields from users, creating friction for simple task creation.

### Domain Context

CLI command design for task management systems, requiring:
- Atomic number allocation with fetch-and-add pattern
- Lazy directory creation (never create project directories)
- State management consistency (state.json as source of truth)
- Metadata auto-population with sensible defaults
- Human-first CLI design following clig.dev principles

### Task Context

Coordinate orchestrator and task-adder modifications to:
1. Move atomic number allocation from subagent to orchestrator (immediate feedback)
2. Simplify input from 10+ fields to single description argument
3. Auto-populate all metadata with sensible defaults
4. Generate acceptance criteria and impact from description
5. Preserve atomic numbering guarantees and lazy directory creation

### Execution Context

- **Current State**: Research complete, complexity/dependency analysis complete
- **Target State**: Single-description /add command with immediate number feedback
- **Constraints**: Must preserve atomic numbering, lazy creation, state consistency
- **Success Criteria**: 90% reduction in required user input (10+ fields → 1 field)

---

## Role

Implementation Coordinator for /add command simplification, specializing in:
- CLI command design and user experience optimization
- Atomic operation preservation and state management
- Metadata auto-population and inference algorithms
- Orchestrator-subagent interface design
- Documentation and testing coordination

---

## Task

Simplify the `/add` command to accept a single description argument while:
1. Moving atomic number allocation to orchestrator for immediate user feedback
2. Auto-populating all required metadata fields with sensible defaults
3. Generating acceptance criteria and impact statements from description
4. Preserving atomic numbering guarantees via `atomic-task-number.sh`
5. Maintaining lazy directory creation (never create project directories)
6. Ensuring state.json and TODO.md consistency
7. Following CLI best practices from clig.dev guidelines

**Expected Outcome**: 90% reduction in required user input while maintaining complete metadata in TODO.md and state.json.

---

## Workflow Execution

### Phase 1: Orchestrator Number Allocation

**Objective**: Move atomic number allocation from task-adder subagent to /add orchestrator for immediate user feedback.

#### Stage 1.1: Update Preflight Stage

**File**: `.opencode/command/add.md`

**Actions**:
1. Add atomic-task-numberer subagent call in Preflight stage (before delegation)
2. Parse and validate single description argument
3. Reject empty or whitespace-only descriptions
4. Allocate task number immediately using atomic-task-numberer
5. Store allocated number for delegation to task-adder

**Implementation**:
```markdown
<stage id="1" name="Preflight">
  <action>Validate input and allocate task number</action>
  <process>
    1. Parse description argument from user input
    2. Validate description is non-empty and non-whitespace
    3. Call atomic-task-numberer to allocate task number
    4. Store allocated number for delegation
    5. Prepare task metadata structure with number
  </process>
  <validation>
    - Description must be non-empty string
    - Description must contain non-whitespace characters
    - Number allocation must succeed (atomic-task-numberer returns valid number)
  </validation>
  <routing>
    <route to="@subagents/atomic-task-numberer">
      <pass_data>
        - count: 1 (single task)
      </pass_data>
      <expected_return>
        - allocated_numbers: [NNN]
        - status: "completed"
      </expected_return>
    </route>
  </routing>
  <checkpoint>Task number allocated and validated</checkpoint>
</stage>
```

**Verification**:
- [ ] Atomic-task-numberer called before task-adder delegation
- [ ] Number allocation succeeds and returns valid number
- [ ] Empty description rejected with clear error message
- [ ] Allocated number stored for delegation

#### Stage 1.2: Update CreateTasks Stage

**File**: `.opencode/command/add.md`

**Actions**:
1. Update task-adder delegation to pass pre-allocated number
2. Remove number allocation from task-adder responsibility
3. Pass description and allocated number to task-adder
4. Request auto-population of all other metadata fields

**Implementation**:
```markdown
<stage id="2" name="CreateTasks">
  <action>Delegate to task-adder with pre-allocated number</action>
  <routing>
    <route to="@subagents/task-adder">
      <pass_data>
        - task_number: {allocated_number}
        - description: {user_description}
        - auto_populate: true
      </pass_data>
      <expected_return>
        - task_number: {allocated_number}
        - description: {user_description}
        - auto_populated_metadata: {...}
        - status: "completed"
      </expected_return>
    </route>
  </routing>
  <checkpoint>Task created with auto-populated metadata</checkpoint>
</stage>
```

**Verification**:
- [ ] Pre-allocated number passed to task-adder
- [ ] Task-adder accepts number as input parameter
- [ ] Auto-population flag set to true
- [ ] Task-adder returns complete metadata

#### Stage 1.3: Update Postflight Stage

**File**: `.opencode/command/add.md`

**Actions**:
1. Return immediate feedback with allocated task number
2. Display task number and description to user
3. Confirm metadata auto-population
4. Provide guidance on editing task if needed

**Implementation**:
```markdown
<stage id="3" name="Postflight">
  <action>Return immediate feedback to user</action>
  <return_format>
    Task #{task_number} created: {description}
    
    Auto-populated metadata:
    - Priority: {priority}
    - Language: {language}
    - Effort: {effort}
    - Status: [NOT STARTED]
    
    Edit task in TODO.md to customize metadata if needed.
  </return_format>
  <checkpoint>User receives immediate task number feedback</checkpoint>
</stage>
```

**Verification**:
- [ ] Task number displayed immediately to user
- [ ] Description confirmed in output
- [ ] Auto-populated metadata summarized
- [ ] Edit guidance provided

---

### Phase 2: Metadata Auto-Population

**Objective**: Implement comprehensive metadata auto-population in task-adder subagent with sensible defaults.

#### Stage 2.1: Update Task-Adder Interface

**File**: `.opencode/agent/subagents/task-adder.md`

**Actions**:
1. Update interface to accept pre-allocated task number
2. Add auto_populate flag to control behavior
3. Remove atomic-task-number.sh call from workflow
4. Update return format to include auto-populated metadata

**Implementation**:
```yaml
# Input Parameters
task_number: {pre_allocated_number}  # NEW: Accept pre-allocated number
description: {user_description}
auto_populate: true  # NEW: Enable auto-population mode

# Output Format
{
  "task_number": {task_number},
  "description": {description},
  "auto_populated_metadata": {
    "priority": "Medium",
    "language": "markdown",
    "effort": "2 hours",
    "files_affected": "TBD",
    "dependencies": "None",
    "blocking": "None",
    "acceptance_criteria": [...],
    "impact": "..."
  },
  "status": "completed"
}
```

**Verification**:
- [ ] Interface accepts task_number parameter
- [ ] Auto_populate flag controls behavior
- [ ] Atomic-task-number.sh call removed
- [ ] Return format includes all metadata

#### Stage 2.2: Implement Default Metadata Values

**File**: `.opencode/agent/subagents/task-adder.md`

**Actions**:
1. Define default values for all required metadata fields
2. Implement auto-population logic in AssignMetadata stage
3. Use sensible defaults based on research findings

**Default Values**:
```yaml
defaults:
  priority: "Medium"
  language: "markdown"  # Default to markdown for non-code tasks
  effort: "2 hours"  # Default effort, can be overridden by inference
  files_affected: "TBD"  # Placeholder for later specification
  dependencies: "None"  # No dependencies by default
  blocking: "None"  # Not blocking by default
  status: "[NOT STARTED]"  # Always start with NOT STARTED
```

**Implementation**:
```markdown
<stage id="2" name="AssignMetadata">
  <action>Auto-populate metadata with defaults and inference</action>
  <process>
    1. Use pre-allocated task_number from input
    2. Set status to [NOT STARTED] (always)
    3. Set priority to Medium (default)
    4. Set language to markdown (default)
    5. Infer effort from description (see Stage 2.3)
    6. Set files_affected to TBD (placeholder)
    7. Set dependencies to None (default)
    8. Set blocking to None (default)
    9. Generate acceptance_criteria (see Stage 2.4)
    10. Generate impact statement (see Stage 2.5)
  </process>
  <checkpoint>All metadata fields populated</checkpoint>
</stage>
```

**Verification**:
- [ ] All required metadata fields have values
- [ ] Defaults match research recommendations
- [ ] Status always set to [NOT STARTED]
- [ ] No missing or null fields

#### Stage 2.3: Implement Effort Inference

**File**: `.opencode/agent/subagents/task-adder.md`

**Actions**:
1. Implement simple heuristic for effort estimation
2. Base estimation on description length and complexity indicators
3. Use conservative estimates (round up)

**Inference Algorithm**:
```python
def infer_effort(description: str) -> str:
    word_count = len(description.split())
    
    # Complexity indicators
    has_multiple_steps = any(word in description.lower() for word in ['and', 'then', 'also', 'plus'])
    has_research = 'research' in description.lower()
    has_implementation = any(word in description.lower() for word in ['implement', 'create', 'build', 'develop'])
    
    # Base effort on word count
    if word_count < 5:
        base_effort = 1  # Very simple task
    elif word_count < 10:
        base_effort = 2  # Simple task
    elif word_count < 20:
        base_effort = 4  # Moderate task
    else:
        base_effort = 8  # Complex task
    
    # Adjust for complexity indicators
    if has_research:
        base_effort *= 2
    if has_implementation and has_multiple_steps:
        base_effort *= 1.5
    
    return f"{int(base_effort)} hours"
```

**Implementation**:
```markdown
<effort_inference>
  <algorithm>
    1. Count words in description
    2. Identify complexity indicators (research, implementation, multiple steps)
    3. Calculate base effort from word count
    4. Adjust for complexity indicators
    5. Round up to conservative estimate
  </algorithm>
  <examples>
    - "Fix typo" → 1 hour (simple, <5 words)
    - "Implement feature X" → 2 hours (simple, <10 words)
    - "Research and implement feature X with tests" → 8 hours (complex, research + implementation)
  </examples>
</effort_inference>
```

**Verification**:
- [ ] Effort inference produces reasonable estimates
- [ ] Conservative estimates (round up, not down)
- [ ] Complexity indicators properly detected
- [ ] Edge cases handled (empty description, very long description)

#### Stage 2.4: Implement Acceptance Criteria Generation

**File**: `.opencode/agent/subagents/task-adder.md`

**Actions**:
1. Generate acceptance criteria from description
2. Use template-based approach with description analysis
3. Create 2-3 criteria per task

**Generation Algorithm**:
```python
def generate_acceptance_criteria(description: str) -> list[str]:
    criteria = []
    
    # Extract action verb and object
    words = description.split()
    action_verb = words[0] if words else "Complete"
    
    # Template-based criteria
    criteria.append(f"{action_verb} successfully completed")
    
    # Add verification criterion
    if any(word in description.lower() for word in ['implement', 'create', 'build']):
        criteria.append("Implementation verified and tested")
    
    # Add documentation criterion if needed
    if any(word in description.lower() for word in ['feature', 'command', 'system']):
        criteria.append("Documentation updated")
    
    # Default criterion
    if len(criteria) == 1:
        criteria.append("Changes reviewed and approved")
    
    return criteria
```

**Implementation**:
```markdown
<acceptance_criteria_generation>
  <algorithm>
    1. Extract action verb from description
    2. Generate completion criterion
    3. Add verification criterion if implementation task
    4. Add documentation criterion if feature/command/system task
    5. Add default review criterion if needed
  </algorithm>
  <examples>
    - "Fix typo in README" → ["Fix successfully completed", "Changes reviewed and approved"]
    - "Implement feature X" → ["Implement successfully completed", "Implementation verified and tested", "Documentation updated"]
  </examples>
</acceptance_criteria_generation>
```

**Verification**:
- [ ] Acceptance criteria generated for all tasks
- [ ] 2-3 criteria per task (not too many, not too few)
- [ ] Criteria relevant to task description
- [ ] Template-based approach produces consistent results

#### Stage 2.5: Implement Impact Statement Generation

**File**: `.opencode/agent/subagents/task-adder.md`

**Actions**:
1. Generate impact statement from description
2. Use template-based approach with description analysis
3. Keep impact statements concise (1-2 sentences)

**Generation Algorithm**:
```python
def generate_impact(description: str) -> str:
    # Extract key elements
    has_user_facing = any(word in description.lower() for word in ['user', 'cli', 'command', 'interface'])
    has_internal = any(word in description.lower() for word in ['refactor', 'optimize', 'improve', 'clean'])
    has_feature = any(word in description.lower() for word in ['implement', 'add', 'create', 'build'])
    
    # Template-based impact
    if has_user_facing and has_feature:
        return f"Improves user experience by enabling: {description}"
    elif has_internal:
        return f"Improves code quality and maintainability: {description}"
    elif has_feature:
        return f"Adds new capability: {description}"
    else:
        return f"Addresses: {description}"
```

**Implementation**:
```markdown
<impact_generation>
  <algorithm>
    1. Identify task category (user-facing, internal, feature, fix)
    2. Select appropriate impact template
    3. Incorporate description into impact statement
    4. Keep concise (1-2 sentences)
  </algorithm>
  <examples>
    - "Fix typo in README" → "Improves code quality and maintainability: Fix typo in README"
    - "Implement /add command simplification" → "Improves user experience by enabling: Implement /add command simplification"
  </examples>
</impact_generation>
```

**Verification**:
- [ ] Impact statement generated for all tasks
- [ ] Statements concise (1-2 sentences)
- [ ] Statements relevant to task description
- [ ] Template-based approach produces consistent results

---

### Phase 3: Simplified Input Parsing

**Objective**: Update /add command to accept single description argument and remove all other required inputs.

#### Stage 3.1: Update Input Parsing

**File**: `.opencode/command/add.md`

**Actions**:
1. Update input parsing to accept single description argument
2. Remove all other required metadata inputs
3. Support optional --file flag for Files Affected override
4. Validate description is non-empty

**Implementation**:
```markdown
<input_format>
  <required>
    description: Single string argument (task description)
  </required>
  <optional>
    --file: Override Files Affected field (default: TBD)
  </optional>
  <removed>
    - priority (auto-populated: Medium)
    - language (auto-populated: markdown)
    - effort (auto-populated: inferred)
    - dependencies (auto-populated: None)
    - blocking (auto-populated: None)
    - acceptance_criteria (auto-populated: generated)
    - impact (auto-populated: generated)
  </removed>
</input_format>
```

**Usage Examples**:
```bash
# Before (10+ fields required)
/add "Implement feature X" --priority High --language lean --effort "4 hours" --files "Logos/Core/Feature.lean" --dependencies "None" --blocking "None" --acceptance "Feature works" --impact "Adds capability"

# After (1 field required)
/add "Implement feature X"

# With optional file override
/add "Implement feature X" --file "Logos/Core/Feature.lean"
```

**Verification**:
- [ ] Single description argument accepted
- [ ] Optional --file flag supported
- [ ] All other metadata fields removed from input
- [ ] Empty description rejected with error

#### Stage 3.2: Remove Batch/File/Plan Artifact Support

**File**: `.opencode/command/add.md`

**Actions**:
1. Remove support for multiple tasks in single invocation
2. Remove support for --file input (task list from file)
3. Remove support for plan artifact input
4. Simplify to single-task-only workflow

**Rationale**: 
- Single-description pattern is for simple, quick task creation
- Batch operations can use separate command (/add-batch)
- File-based input can use separate command (/add-from-file)
- Plan artifacts already have /plan command
- Simplification reduces complexity and improves UX for common case

**Implementation**:
```markdown
<removed_features>
  <batch_tasks>
    Removed: Multiple tasks in single invocation
    Reason: Simplify to single-task workflow
    Alternative: Use /add-batch command (future enhancement)
  </batch_tasks>
  <file_input>
    Removed: --file flag for task list from file
    Reason: Simplify to single-task workflow
    Alternative: Use /add-from-file command (future enhancement)
  </file_input>
  <plan_artifacts>
    Removed: Plan artifact input
    Reason: Plan artifacts already handled by /plan command
    Alternative: Use /plan command for plan-based task creation
  </plan_artifacts>
</removed_features>
```

**Verification**:
- [ ] Batch task support removed
- [ ] File input support removed
- [ ] Plan artifact support removed
- [ ] Single-task workflow only

---

### Phase 4: Documentation and Testing

**Objective**: Update documentation to reflect new simplified workflow and test all functionality.

#### Stage 4.1: Update Command Documentation

**File**: `.opencode/command/add.md`

**Actions**:
1. Update command description with new workflow
2. Add usage examples showing single-description pattern
3. Document auto-population strategy
4. Add guidance on editing tasks after creation

**Implementation**:
```markdown
## Description

Add a single task to TODO.md with immediate task number allocation and auto-populated metadata.

**Workflow**:
1. User provides task description (single argument)
2. Orchestrator allocates task number immediately (atomic-task-numberer)
3. Orchestrator delegates to task-adder with pre-allocated number
4. Task-adder auto-populates all metadata with sensible defaults
5. Task-adder generates acceptance criteria and impact from description
6. Task added to TODO.md and state.json updated
7. User receives immediate feedback with task number

**Auto-Population Strategy**:
- Priority: Medium (default)
- Language: markdown (default)
- Effort: Inferred from description (word count + complexity indicators)
- Files Affected: TBD (placeholder)
- Dependencies: None (default)
- Blocking: None (default)
- Acceptance Criteria: Generated from description (2-3 criteria)
- Impact: Generated from description (1-2 sentences)
- Status: [NOT STARTED] (always)

**Editing Tasks**:
After creation, edit TODO.md to customize metadata if needed. All fields can be manually updated.

## Usage

```bash
# Simple task creation
/add "Fix typo in README"
# → Task #168 created: Fix typo in README

# With file override
/add "Implement feature X" --file "Logos/Core/Feature.lean"
# → Task #169 created: Implement feature X
```
```

**Verification**:
- [ ] Command description updated
- [ ] Usage examples added
- [ ] Auto-population strategy documented
- [ ] Edit guidance provided

#### Stage 4.2: Update Standards Documentation

**File**: `.opencode/context/core/standards/tasks.md`

**Actions**:
1. Document metadata auto-population strategy
2. Define default values for all metadata fields
3. Update examples to show auto-populated tasks
4. Add guidance on editing tasks after creation

**Implementation**:
```markdown
## Metadata Auto-Population

When using `/add` command with single description argument, all metadata fields are auto-populated with sensible defaults:

| Field | Default Value | Source |
|-------|---------------|--------|
| Number | Allocated | atomic-task-numberer (fetch-and-add) |
| Description | User input | Required argument |
| Status | [NOT STARTED] | Always |
| Priority | Medium | Default |
| Language | markdown | Default |
| Effort | Inferred | Description analysis (word count + complexity) |
| Files Affected | TBD | Placeholder |
| Dependencies | None | Default |
| Blocking | None | Default |
| Acceptance Criteria | Generated | Template-based from description |
| Impact | Generated | Template-based from description |

## Editing Tasks After Creation

All auto-populated fields can be manually edited in TODO.md:
1. Open TODO.md in editor
2. Locate task by number
3. Update metadata fields as needed
4. Save file

Auto-population provides sensible defaults for quick task creation. Manual editing allows customization for complex tasks.
```

**Verification**:
- [ ] Auto-population strategy documented
- [ ] Default values table added
- [ ] Examples updated
- [ ] Edit guidance added

**File**: `.opencode/context/core/standards/commands.md`

**Actions**:
1. Update /add command documentation with new workflow
2. Add examples of immediate number feedback
3. Document single-description pattern as primary interface

**Implementation**:
```markdown
## /add Command

**Purpose**: Add single task to TODO.md with immediate number allocation and auto-populated metadata.

**Workflow**:
1. Preflight: Validate description, allocate task number (atomic-task-numberer)
2. CreateTasks: Delegate to task-adder with pre-allocated number
3. Postflight: Return immediate feedback with task number

**Input**: Single description argument (required)

**Output**: Immediate task number feedback

**Example**:
```bash
/add "Implement feature X"
# → Task #168 created: Implement feature X
#   Auto-populated: Priority=Medium, Language=markdown, Effort=2 hours
```

**Auto-Population**: All metadata fields auto-populated with sensible defaults (see tasks.md standard).

**Editing**: Edit TODO.md to customize metadata after creation.
```

**Verification**:
- [ ] Command workflow documented
- [ ] Examples added
- [ ] Auto-population referenced
- [ ] Edit guidance provided

#### Stage 4.3: Testing

**Actions**:
1. Test single-description task creation
2. Test metadata auto-population correctness
3. Test concurrent task creation (race conditions)
4. Test error handling (empty description, allocation failure)
5. Test state.json and TODO.md sync
6. User acceptance testing

**Test Cases**:

**Test 1: Simple Task Creation**
```bash
Input: /add "Fix typo in README"
Expected Output:
  Task #168 created: Fix typo in README
  Auto-populated metadata:
  - Priority: Medium
  - Language: markdown
  - Effort: 1 hour
  - Status: [NOT STARTED]
Verification:
  - Task appears in TODO.md with number 168
  - All metadata fields populated
  - state.json incremented to 168
```

**Test 2: Complex Task Creation**
```bash
Input: /add "Research and implement feature X with comprehensive tests and documentation"
Expected Output:
  Task #169 created: Research and implement feature X with comprehensive tests and documentation
  Auto-populated metadata:
  - Priority: Medium
  - Language: markdown
  - Effort: 16 hours (research + implementation + multiple steps)
  - Status: [NOT STARTED]
Verification:
  - Effort inference detects complexity
  - Acceptance criteria includes implementation, testing, documentation
  - Impact statement mentions new capability
```

**Test 3: Empty Description Rejection**
```bash
Input: /add ""
Expected Output: Error: Description cannot be empty
Verification:
  - No task created
  - No number allocated
  - state.json unchanged
```

**Test 4: Concurrent Task Creation**
```bash
Input: /add "Task A" & /add "Task B" & /add "Task C"
Expected Output:
  Task #168 created: Task A
  Task #169 created: Task B
  Task #170 created: Task C
Verification:
  - No duplicate numbers
  - All tasks in TODO.md
  - state.json = 170
  - No race conditions
```

**Test 5: File Override**
```bash
Input: /add "Implement feature X" --file "Logos/Core/Feature.lean"
Expected Output:
  Task #168 created: Implement feature X
  Files Affected: Logos/Core/Feature.lean
Verification:
  - Files Affected field set to specified file
  - Other metadata auto-populated
```

**Test 6: State Consistency**
```bash
Input: /add "Task 1" && /add "Task 2"
Verification:
  - state.json.last_task_number = 169
  - TODO.md contains tasks 168, 169
  - No gaps in numbering
  - Timestamps correct
```

**Verification**:
- [ ] All test cases pass
- [ ] No race conditions detected
- [ ] Error handling works correctly
- [ ] State consistency maintained
- [ ] User acceptance criteria met

---

## Technology Stack

**Languages**:
- Markdown (agent system, documentation)
- Bash (atomic-task-number.sh script)
- JSON (state management)

**Frameworks**:
- Markdown-based agent system
- Atomic task numbering service

**Tools**:
- jq (JSON parsing and manipulation)
- bash (file locking, atomic operations)
- mkdir (atomic lock mechanism)

**Dependencies**:
- atomic-task-numberer subagent (atomic number allocation)
- task-adder subagent (metadata population)
- state.json (task numbering counter)
- TODO.md (task registry)

---

## Dependencies

### Required Modules/Packages

**Subagents**:
- `@subagents/atomic-task-numberer` - Atomic task number allocation with file locking
- `@subagents/task-adder` - Task metadata population and TODO.md formatting

**State Files**:
- `specs/state.json` - Task numbering counter and project tracking
- `specs/TODO.md` - Task list with metadata

**Standards**:
- `.opencode/context/core/standards/tasks.md` - Task metadata format specification
- `.opencode/context/core/standards/commands.md` - Command structure requirements

**System Documentation**:
- `.opencode/context/core/system/state-schema.md` - State file structure
- `.opencode/context/core/system/artifact-management.md` - Lazy directory creation rules

### Prerequisites

**Phase 1 Prerequisites**:
- Atomic-task-numberer subagent exists and works correctly [YES]
- State.json schema supports atomic increment [YES]
- Lazy directory creation enforced [YES]

**Phase 2 Prerequisites**:
- Task-adder subagent exists [YES]
- Task-adder can accept pre-allocated number (requires modification)
- Metadata inference algorithms implemented (requires implementation)

**Phase 3 Prerequisites**:
- Phase 1 complete (number allocation in orchestrator)
- Phase 2 complete (auto-population in task-adder)

**Phase 4 Prerequisites**:
- Phase 1, 2, 3 complete
- All functionality implemented and working

### External Libraries

**Bash Utilities**:
- `jq` - JSON parsing and manipulation (assumed available)
- `mkdir` - Atomic lock mechanism (built-in)
- `mv` - Atomic file operations (built-in)

**No external dependencies required** - all tools are standard Unix utilities.

---

## Implementation Steps

### Step 1: Update Orchestrator Preflight Stage

**Action**: Move atomic number allocation to orchestrator Preflight stage

**File**: `.opencode/command/add.md`

**Approach**:
1. Add atomic-task-numberer subagent call in Preflight stage
2. Parse and validate single description argument
3. Allocate task number immediately
4. Store allocated number for delegation

**Verification**:
- Run `/add "Test task"` and verify number allocated before delegation
- Check that empty description is rejected
- Verify atomic-task-numberer called with count=1

### Step 2: Update Orchestrator CreateTasks Stage

**Action**: Pass pre-allocated number to task-adder subagent

**File**: `.opencode/command/add.md`

**Approach**:
1. Update task-adder delegation to pass pre-allocated number
2. Set auto_populate flag to true
3. Pass description and number to task-adder

**Verification**:
- Verify task-adder receives pre-allocated number
- Verify auto_populate flag set to true
- Verify task created with correct number

### Step 3: Update Orchestrator Postflight Stage

**Action**: Return immediate feedback with task number

**File**: `.opencode/command/add.md`

**Approach**:
1. Display task number and description to user
2. Summarize auto-populated metadata
3. Provide edit guidance

**Verification**:
- Verify user sees task number immediately
- Verify auto-populated metadata displayed
- Verify edit guidance provided

### Step 4: Update Task-Adder Interface

**Action**: Accept pre-allocated task number as input parameter

**File**: `.opencode/agent/subagents/task-adder.md`

**Approach**:
1. Add task_number input parameter
2. Add auto_populate flag
3. Remove atomic-task-number.sh call
4. Update return format

**Verification**:
- Verify task-adder accepts task_number parameter
- Verify atomic-task-number.sh call removed
- Verify return format includes all metadata

### Step 5: Implement Default Metadata Values

**Action**: Define and implement default values for all metadata fields

**File**: `.opencode/agent/subagents/task-adder.md`

**Approach**:
1. Define default values (Priority=Medium, Language=markdown, etc.)
2. Implement auto-population logic in AssignMetadata stage
3. Set all fields to defaults

**Verification**:
- Verify all metadata fields have values
- Verify defaults match research recommendations
- Verify no missing or null fields

### Step 6: Implement Effort Inference

**Action**: Implement effort estimation from description

**File**: `.opencode/agent/subagents/task-adder.md`

**Approach**:
1. Count words in description
2. Identify complexity indicators (research, implementation, multiple steps)
3. Calculate base effort from word count
4. Adjust for complexity indicators
5. Round up to conservative estimate

**Verification**:
- Test with simple description: "Fix typo" → 1 hour
- Test with moderate description: "Implement feature X" → 2 hours
- Test with complex description: "Research and implement feature X with tests" → 8+ hours
- Verify conservative estimates (round up)

### Step 7: Implement Acceptance Criteria Generation

**Action**: Generate acceptance criteria from description

**File**: `.opencode/agent/subagents/task-adder.md`

**Approach**:
1. Extract action verb from description
2. Generate completion criterion
3. Add verification criterion if implementation task
4. Add documentation criterion if feature/command/system task
5. Add default review criterion if needed

**Verification**:
- Test with "Fix typo" → ["Fix successfully completed", "Changes reviewed and approved"]
- Test with "Implement feature X" → ["Implement successfully completed", "Implementation verified and tested", "Documentation updated"]
- Verify 2-3 criteria per task

### Step 8: Implement Impact Statement Generation

**Action**: Generate impact statement from description

**File**: `.opencode/agent/subagents/task-adder.md`

**Approach**:
1. Identify task category (user-facing, internal, feature, fix)
2. Select appropriate impact template
3. Incorporate description into impact statement
4. Keep concise (1-2 sentences)

**Verification**:
- Test with "Fix typo in README" → "Improves code quality and maintainability: Fix typo in README"
- Test with "Implement /add command simplification" → "Improves user experience by enabling: Implement /add command simplification"
- Verify statements concise and relevant

### Step 9: Simplify Input Parsing

**Action**: Update /add to accept single description argument

**File**: `.opencode/command/add.md`

**Approach**:
1. Update input parsing to accept single description
2. Remove all other required metadata inputs
3. Support optional --file flag
4. Validate description is non-empty

**Verification**:
- Test `/add "Test task"` → succeeds
- Test `/add ""` → fails with error
- Test `/add "Test task" --file "path/to/file"` → succeeds with file override

### Step 10: Remove Batch/File/Plan Support

**Action**: Remove support for multiple tasks, file input, plan artifacts

**File**: `.opencode/command/add.md`

**Approach**:
1. Remove batch task support
2. Remove file input support
3. Remove plan artifact support
4. Simplify to single-task workflow

**Verification**:
- Verify batch task support removed
- Verify file input support removed
- Verify plan artifact support removed
- Verify single-task workflow only

### Step 11: Update Command Documentation

**Action**: Update add.md with new workflow and usage examples

**File**: `.opencode/command/add.md`

**Approach**:
1. Update command description
2. Add usage examples
3. Document auto-population strategy
4. Add edit guidance

**Verification**:
- Verify documentation complete and accurate
- Verify examples work as documented
- Verify auto-population strategy clear

### Step 12: Update Standards Documentation

**Action**: Update tasks.md and commands.md with new patterns

**Files**: 
- `.opencode/context/core/standards/tasks.md`
- `.opencode/context/core/standards/commands.md`

**Approach**:
1. Document metadata auto-population strategy
2. Define default values table
3. Update examples
4. Add edit guidance

**Verification**:
- Verify standards documentation complete
- Verify default values table accurate
- Verify examples updated

### Step 13: Testing

**Action**: Comprehensive testing of all functionality

**Approach**:
1. Run all test cases (see Stage 4.3)
2. Verify no race conditions
3. Verify error handling
4. Verify state consistency
5. User acceptance testing

**Verification**:
- All test cases pass [YES]
- No race conditions detected [YES]
- Error handling works correctly [YES]
- State consistency maintained [YES]
- User acceptance criteria met [YES]

---

## File Structure

```
.opencode/
├── command/
│   └── add.md                          # MODIFIED: Orchestrator workflow
├── agent/
│   └── subagents/
│       ├── atomic-task-numberer.md     # NO CHANGES: Already correct
│       └── task-adder.md               # MODIFIED: Auto-population logic
├── context/
│   └── common/
│       ├── standards/
│       │   ├── tasks.md                # MODIFIED: Auto-population docs
│       │   └── commands.md             # MODIFIED: /add workflow docs
│       └── system/
│           ├── state-schema.md         # NO CHANGES: Already correct
│           └── artifact-management.md  # NO CHANGES: Already correct
└── specs/
    ├── TODO.md                         # UPDATED BY IMPLEMENTATION
    ├── state.json                      # UPDATED BY IMPLEMENTATION
    └── 165_make_add_command_single_description_with_immediate_number_increment/
        ├── reports/
        │   ├── research-001.md         # RESEARCH INPUT
        │   └── research-002.md         # RESEARCH INPUT
        ├── summaries/
        │   └── research-summary.md     # RESEARCH INPUT
        └── plans/
            └── implementation-001.md   # THIS PLAN
```

---

## Testing Strategy

### Unit Tests

**Test 1: Effort Inference**
- Input: Various descriptions with different lengths and complexity
- Expected: Reasonable effort estimates (1-16 hours)
- Verification: Conservative estimates, complexity indicators detected

**Test 2: Acceptance Criteria Generation**
- Input: Various descriptions (fix, implement, research, etc.)
- Expected: 2-3 relevant criteria per task
- Verification: Template-based approach produces consistent results

**Test 3: Impact Statement Generation**
- Input: Various descriptions (user-facing, internal, feature, fix)
- Expected: Concise impact statements (1-2 sentences)
- Verification: Statements relevant to task category

**Test 4: Default Metadata Population**
- Input: Single description
- Expected: All metadata fields populated with defaults
- Verification: No missing or null fields

### Integration Tests

**Test 5: End-to-End Task Creation**
- Input: `/add "Test task"`
- Expected: Task created with number, all metadata populated, state updated
- Verification: TODO.md, state.json, immediate feedback

**Test 6: Concurrent Task Creation**
- Input: Multiple /add commands in parallel
- Expected: No duplicate numbers, all tasks created
- Verification: Atomic numbering preserved, no race conditions

**Test 7: Error Handling**
- Input: Empty description, allocation failure
- Expected: Clear error messages, no state corruption
- Verification: State unchanged, user informed

### Regression Tests

**Test 8: Atomic Numbering Preservation**
- Input: Multiple /add commands sequentially
- Expected: Sequential numbering, no gaps (gaps acceptable but not expected)
- Verification: state.json increments correctly

**Test 9: Lazy Directory Creation**
- Input: /add command
- Expected: No project directories created
- Verification: Only TODO.md and state.json modified

**Test 10: State Consistency**
- Input: /add command
- Expected: state.json and TODO.md in sync
- Verification: Numbers match, timestamps correct

### User Acceptance Tests

**Test 11: Usability**
- Input: User creates task with single description
- Expected: Immediate number feedback, clear output
- Verification: User satisfied with experience

**Test 12: Auto-Population Quality**
- Input: Various task descriptions
- Expected: Reasonable auto-populated metadata
- Verification: User accepts defaults or edits as needed

**Test 13: Edit Workflow**
- Input: User creates task, then edits metadata in TODO.md
- Expected: Easy to find and edit task
- Verification: User can customize metadata after creation

---

## Verification Checkpoints

### Pre-Flight Checks (Before Implementation)

- [ ] Research reports reviewed and understood
- [ ] Complexity analysis reviewed (Moderate, 2-3 hours)
- [ ] Dependency analysis reviewed (all dependencies exist)
- [ ] Implementation order understood (Orchestrator → Subagent → Docs → Testing)
- [ ] File structure understood (4 files to modify)
- [ ] Constraints understood (preserve atomic numbering, lazy creation, state consistency)

### Mid-Flight Checks (During Implementation)

**After Phase 1 (Orchestrator Changes)**:
- [ ] Atomic number allocation moved to Preflight stage
- [ ] Number allocated before delegation to task-adder
- [ ] Empty description rejected with error
- [ ] Pre-allocated number passed to task-adder
- [ ] Immediate feedback returned to user

**After Phase 2 (Metadata Auto-Population)**:
- [ ] Task-adder accepts pre-allocated number
- [ ] Atomic-task-number.sh call removed from task-adder
- [ ] All metadata fields have default values
- [ ] Effort inference implemented and tested
- [ ] Acceptance criteria generation implemented and tested
- [ ] Impact statement generation implemented and tested

**After Phase 3 (Simplified Input)**:
- [ ] Single description argument accepted
- [ ] Optional --file flag supported
- [ ] All other metadata inputs removed
- [ ] Batch/file/plan support removed

**After Phase 4 (Documentation and Testing)**:
- [ ] Command documentation updated
- [ ] Standards documentation updated
- [ ] All test cases pass
- [ ] User acceptance criteria met

### Post-Flight Checks (After Implementation)

**Functionality**:
- [ ] `/add "Test task"` creates task with immediate number feedback
- [ ] All metadata fields auto-populated with sensible defaults
- [ ] Effort inference produces reasonable estimates
- [ ] Acceptance criteria generated (2-3 per task)
- [ ] Impact statement generated (1-2 sentences)
- [ ] Empty description rejected with error
- [ ] Optional --file flag works

**Correctness**:
- [ ] Atomic numbering preserved (no duplicate numbers)
- [ ] Lazy directory creation preserved (no project dirs created)
- [ ] State consistency maintained (state.json and TODO.md in sync)
- [ ] No race conditions in concurrent task creation
- [ ] Error handling works correctly

**Documentation**:
- [ ] Command documentation complete and accurate
- [ ] Standards documentation updated
- [ ] Usage examples work as documented
- [ ] Auto-population strategy documented
- [ ] Edit guidance provided

**User Experience**:
- [ ] 90% reduction in required input (10+ fields → 1 field)
- [ ] Immediate number feedback (allocated before delegation)
- [ ] Clear, concise output
- [ ] Easy to edit tasks after creation
- [ ] Follows CLI best practices (clig.dev)

---

## Documentation Requirements

### Command Documentation

**File**: `.opencode/command/add.md`

**Required Sections**:
1. Description: New workflow with auto-population
2. Usage: Single-description pattern with examples
3. Auto-Population Strategy: Default values and inference algorithms
4. Editing Tasks: Guidance on customizing metadata after creation
5. Workflow: Preflight → CreateTasks → Postflight stages
6. Examples: Before/after comparison

### Standards Documentation

**File**: `.opencode/context/core/standards/tasks.md`

**Required Sections**:
1. Metadata Auto-Population: Strategy and default values
2. Default Values Table: All metadata fields with defaults
3. Inference Algorithms: Effort, acceptance criteria, impact
4. Editing Tasks: Guidance on manual customization
5. Examples: Auto-populated tasks

**File**: `.opencode/context/core/standards/commands.md`

**Required Sections**:
1. /add Command: New workflow and usage
2. Examples: Single-description pattern
3. Auto-Population: Reference to tasks.md standard
4. Editing: Reference to tasks.md standard

### Implementation Documentation

**File**: `specs/165_make_add_command_single_description_with_immediate_number_increment/plans/implementation-001.md`

**Required Sections** (this document):
1. Research Inputs: All research reports and analyses
2. Context: System, domain, task, execution
3. Role: Implementation coordinator
4. Task: Simplify /add command
5. Workflow Execution: Phased implementation
6. Technology Stack: Languages, frameworks, tools
7. Dependencies: Modules, prerequisites, libraries
8. Implementation Steps: Detailed step-by-step guide
9. File Structure: Files to modify
10. Testing Strategy: Unit, integration, regression, user acceptance
11. Verification Checkpoints: Pre/mid/post-flight checks
12. Documentation Requirements: Command, standards, implementation
13. Success Criteria: Expected outcomes
14. Related Research: Links to research reports
15. Notes: Additional considerations

---

## Success Criteria

### Primary Success Criteria

1. **90% Reduction in Required Input**
   - Before: 10+ metadata fields required
   - After: 1 field required (description)
   - Measurement: Count required input fields

2. **Immediate Number Feedback**
   - Before: Number allocated in subagent (delayed feedback)
   - After: Number allocated in orchestrator (immediate feedback)
   - Measurement: User sees task number before delegation completes

3. **Complete Metadata Auto-Population**
   - All required metadata fields populated with sensible defaults
   - No missing or null fields
   - Measurement: Inspect TODO.md entries

4. **Preserved Atomic Numbering**
   - No duplicate task numbers
   - No race conditions in concurrent creation
   - Measurement: Test concurrent /add commands

5. **Preserved Lazy Directory Creation**
   - No project directories created by /add command
   - Measurement: Verify no new directories in specs/

6. **State Consistency**
   - state.json and TODO.md in sync
   - Numbers match, timestamps correct
   - Measurement: Compare state.json and TODO.md

### Secondary Success Criteria

7. **Reasonable Effort Estimates**
   - Effort inference produces conservative estimates
   - Complexity indicators detected
   - Measurement: Test with various descriptions

8. **Relevant Acceptance Criteria**
   - 2-3 criteria per task
   - Template-based approach produces consistent results
   - Measurement: Inspect generated criteria

9. **Concise Impact Statements**
   - 1-2 sentences per task
   - Relevant to task category
   - Measurement: Inspect generated impact statements

10. **Clear Documentation**
    - Command documentation complete and accurate
    - Standards documentation updated
    - Usage examples work as documented
    - Measurement: Review documentation

11. **Positive User Experience**
    - Users satisfied with simplified workflow
    - Easy to create tasks quickly
    - Easy to edit tasks after creation
    - Measurement: User acceptance testing

### Acceptance Criteria

- [ ] `/add "Test task"` creates task with immediate number feedback
- [ ] All metadata fields auto-populated with sensible defaults
- [ ] Effort inference produces reasonable estimates (1-16 hours)
- [ ] Acceptance criteria generated (2-3 per task)
- [ ] Impact statement generated (1-2 sentences)
- [ ] Empty description rejected with clear error message
- [ ] Optional --file flag works correctly
- [ ] Atomic numbering preserved (no duplicate numbers)
- [ ] Lazy directory creation preserved (no project dirs)
- [ ] State consistency maintained (state.json and TODO.md in sync)
- [ ] No race conditions in concurrent task creation
- [ ] Error handling works correctly
- [ ] Documentation complete and accurate
- [ ] All test cases pass
- [ ] User acceptance criteria met

---

## Related Research

### Research Reports

1. **Atomic Number Reservation and CLI Command Design Best Practices**
   - Path: `specs/165_make_add_command_single_description_with_immediate_number_increment/reports/research-001.md`
   - Content: 582 lines of atomic numbering patterns, CLI design principles, state management
   - Key Findings: Fetch-and-add pattern optimal, single required argument, immediate state updates

2. **Current /add Implementation Analysis and Gap Analysis**
   - Path: `specs/165_make_add_command_single_description_with_immediate_number_increment/reports/research-002.md`
   - Content: 582 lines of current implementation analysis, gap analysis, recommendations
   - Key Findings: Atomic numbering already correct, requires too much metadata, number allocation in wrong place

3. **Research Summary**
   - Path: `specs/165_make_add_command_single_description_with_immediate_number_increment/summaries/research-summary.md`
   - Content: Executive summary, metadata auto-population strategy, recommendations
   - Key Findings: 90% reduction in input, immediate feedback, auto-population with defaults

### Specialist Analyses

4. **Complexity Analysis**
   - Complexity Level: Moderate
   - Estimated Effort: 2-3 hours
   - Required Knowledge: CLI design, atomic operations, metadata inference, agent architecture
   - Potential Challenges: Metadata auto-population quality, orchestrator-subagent interface change

5. **Dependency Analysis**
   - All required dependencies exist
   - No blocking dependencies
   - 4 files require modification
   - Implementation order: Orchestrator → Subagent → Documentation → Testing

### External References

6. **CLI Guidelines (clig.dev)**
   - Human-first design principles
   - Single required argument for primary action
   - Clear, immediate feedback
   - Sensible defaults

7. **Herlihy & Wing (1990) - Linearizability**
   - Correctness condition for concurrent objects
   - Atomic operations appear instantaneous
   - Total order consistent with real-time ordering

8. **Martin Fowler - Patterns of Distributed Systems**
   - State management patterns
   - Immediate state updates
   - No rollback for counters

---

## Notes

### Implementation Considerations

1. **Atomic Numbering Already Correct**
   - Current `atomic-task-number.sh` script implements fetch-and-add pattern correctly
   - File locking via mkdir prevents race conditions
   - No changes needed to numbering mechanism
   - Just needs to be called from orchestrator instead of subagent

2. **Lazy Directory Creation Already Enforced**
   - `/add` command has `creates_root_on: never` setting
   - No risk of breaking this guarantee
   - Implementation must preserve this setting

3. **Metadata Auto-Population Quality**
   - Initial implementation uses simple heuristics (word count, complexity indicators)
   - Can be improved iteratively with better algorithms
   - ML-based effort estimation is future enhancement
   - Template-based criteria/impact generation is good starting point

4. **Backward Compatibility**
   - Removing batch/file/plan support may break existing workflows
   - Consider creating separate commands (/add-batch, /add-from-file) for complex cases
   - Document migration path for users relying on removed features

5. **Edit Workflow**
   - Users can edit TODO.md directly to customize metadata
   - Auto-population provides sensible defaults for quick creation
   - Manual editing allows customization for complex tasks
   - Document edit workflow clearly in standards

### Future Enhancements

1. **ML-Based Effort Estimation**
   - Train model on historical task data
   - Predict effort based on description and past tasks
   - Improve accuracy over time

2. **Context-Aware Language Detection**
   - Detect language from description keywords
   - "Implement Lean theorem" → language: lean
   - "Update README" → language: markdown

3. **Smart File Path Inference**
   - Infer files affected from description
   - "Fix typo in README" → files_affected: README.md
   - "Implement feature in Logos/Core" → files_affected: Logos/Core/*.lean

4. **Batch Command Support**
   - Create separate /add-batch command for multiple tasks
   - Support file input with /add-from-file command
   - Keep /add simple for single-task workflow

5. **Interactive Mode**
   - Prompt for metadata overrides after auto-population
   - Show auto-populated values and allow editing
   - Optional flag: /add --interactive "Task description"

### Risk Mitigation

1. **Metadata Quality Risk**
   - Mitigation: Start with simple heuristics, iterate based on feedback
   - Mitigation: Document edit workflow clearly
   - Mitigation: Provide examples of good auto-populated tasks

2. **Backward Compatibility Risk**
   - Mitigation: Create separate commands for batch/file/plan workflows
   - Mitigation: Document migration path
   - Mitigation: Announce changes in release notes

3. **Race Condition Risk**
   - Mitigation: Atomic numbering already correct (file locking)
   - Mitigation: Test concurrent task creation thoroughly
   - Mitigation: Verify no duplicate numbers in testing

4. **State Consistency Risk**
   - Mitigation: State management already follows best practices
   - Mitigation: Test state.json and TODO.md sync
   - Mitigation: Verify timestamps and numbers match

### Success Metrics

1. **Input Reduction**: 90% reduction (10+ fields → 1 field)
2. **Time to Create Task**: <5 seconds (immediate number feedback)
3. **User Satisfaction**: Positive feedback on simplified workflow
4. **Metadata Quality**: 80%+ of auto-populated tasks require no editing
5. **Error Rate**: <1% of task creations fail
6. **State Consistency**: 100% of tasks in sync between state.json and TODO.md

### Next Steps After Implementation

1. **Monitor Usage**
   - Track how often users edit auto-populated metadata
   - Identify patterns in manual edits
   - Use data to improve auto-population algorithms

2. **Gather Feedback**
   - User surveys on simplified workflow
   - Identify pain points and areas for improvement
   - Prioritize enhancements based on feedback

3. **Iterate on Algorithms**
   - Improve effort inference based on usage data
   - Enhance acceptance criteria generation
   - Refine impact statement templates

4. **Document Best Practices**
   - Create guide for writing good task descriptions
   - Show examples of descriptions that auto-populate well
   - Provide tips for getting best results

5. **Consider Extensions**
   - Evaluate need for /add-batch command
   - Evaluate need for /add-from-file command
   - Evaluate need for interactive mode

---

## Appendix: Before/After Comparison

### Before: Complex Multi-Field Input

```bash
# User must provide 10+ metadata fields
/add "Implement feature X" \
  --priority High \
  --language lean \
  --effort "4 hours" \
  --files "Logos/Core/Feature.lean" \
  --dependencies "None" \
  --blocking "None" \
  --acceptance "Feature works correctly" \
  --acceptance "Tests pass" \
  --acceptance "Documentation updated" \
  --impact "Adds new capability to system"

# Output (delayed, after subagent completes)
Task #168 created: Implement feature X
```

**Problems**:
- 10+ fields required (high friction)
- Number allocated in subagent (delayed feedback)
- Complex input parsing
- Not suitable for quick task creation

### After: Simple Single-Description Input

```bash
# User provides only description
/add "Implement feature X"

# Output (immediate, before subagent delegation)
Task #168 created: Implement feature X

Auto-populated metadata:
- Priority: Medium
- Language: markdown
- Effort: 2 hours
- Status: [NOT STARTED]

Edit task in TODO.md to customize metadata if needed.
```

**Benefits**:
- 1 field required (90% reduction in input)
- Number allocated immediately (instant feedback)
- Simple input parsing
- Perfect for quick task creation
- All metadata auto-populated with sensible defaults
- Easy to edit after creation if needed

### Metadata Auto-Population Comparison

| Field | Before | After |
|-------|--------|-------|
| Number | Required (from subagent) | Auto-allocated (from orchestrator) |
| Description | Required | Required |
| Status | Required | Auto: [NOT STARTED] |
| Priority | Required | Auto: Medium |
| Language | Required | Auto: markdown |
| Effort | Required | Auto: Inferred (2 hours) |
| Files Affected | Required | Auto: TBD |
| Dependencies | Required | Auto: None |
| Blocking | Required | Auto: None |
| Acceptance Criteria | Required (multiple) | Auto: Generated (2-3) |
| Impact | Required | Auto: Generated (1-2 sentences) |

**Result**: 10 fields auto-populated, 1 field required (90% reduction)

---

**End of Implementation Plan**
