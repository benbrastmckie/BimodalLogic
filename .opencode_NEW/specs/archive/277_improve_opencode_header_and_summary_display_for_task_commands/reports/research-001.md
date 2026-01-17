# Research Report: Improve OpenCode Header and Summary Display for Task Commands

**Task**: 277  
**Started**: 2026-01-03T20:40:00Z  
**Completed**: 2026-01-03T20:45:00Z  
**Researcher**: General Research Agent  

---

## Executive Summary

Research into OpenCode header and summary display patterns reveals that the system already has infrastructure for task number display through the orchestrator's prompt formatting ("Task: {number}"), but lacks consistent header display and summary conclusion patterns across commands and subagents. The current implementation focuses on internal routing but does not provide user-facing headers or standardized summary conclusions.

**Key Findings**:
1. Orchestrator formats prompts as "Task: {number}" for internal delegation but this is not displayed to users
2. Subagent return format standard requires <100 token summaries but does not mandate task/command reference in conclusions
3. No existing standard for command output headers or summary conclusions
4. Commands delegate to orchestrator which handles routing but does not display headers
5. Subagents return summaries to orchestrator which relays them to users without modification

**Recommendation**: Create command-output.md standard and update orchestrator Stage 5 (PostflightCleanup) to add headers and summary conclusions.

---

## Current State Analysis

### 1. Orchestrator Prompt Formatting

**Location**: `.opencode/agent/orchestrator.md` Stage 3 (RegisterAndDelegate)

**Current Behavior**:
- Task-based commands: Formats prompt as "Task: {task_number}" for delegation
- Direct commands: Passes $ARGUMENTS as-is (may be empty)
- Examples:
  - `/research 258` → prompt="Task: 258"
  - `/meta` → prompt=""
  - `/meta "build system"` → prompt="build proof system"

**Purpose**: Internal routing and context for subagents, NOT user-facing display

**Code Reference** (orchestrator.md lines 143-177):
```
FOR TASK-BASED COMMANDS (research, implement, plan):
- You MUST include the task_number from $ARGUMENTS (validated in Stage 1)
- Format the prompt EXACTLY as: "Task: {task_number}"
- Example: If $ARGUMENTS = "258", format as "Task: 258"
- DO NOT pass $ARGUMENTS directly - the subagent needs "Task: {number}" format

FOR DIRECT COMMANDS (meta, review, revise):
- Pass $ARGUMENTS as-is (may be empty string)
```

**Gap**: This formatting is for subagent consumption, not user display. Users do not see "Task: 258" header.

### 2. Subagent Return Format

**Location**: `.opencode/context/core/standards/subagent-return-format.md`

**Current Standard**:
```json
{
  "status": "completed|partial|failed|blocked",
  "summary": "Brief 2-5 sentence summary (<100 tokens)",
  "artifacts": [...],
  "metadata": {...},
  "errors": [...],
  "next_steps": "What user should do next (if applicable)"
}
```

**Summary Requirements**:
- **Constraints**: <100 tokens (~400 characters)
- **Description**: Brief 2-5 sentence summary of what was done
- **Purpose**: Protects orchestrator context window from bloat

**Gap**: No requirement for task number or command name in summary conclusion.

### 3. Orchestrator Stage 5 (PostflightCleanup)

**Location**: `.opencode/agent/orchestrator.md` Stage 5

**Current Behavior**:
```
3. Format response for user:
   - Extract summary (already <100 tokens)
   - Include artifact paths if applicable
   - Include error details if status != completed
   - Include next steps or resume instructions

4. Return to user
```

**Return Format Templates**:
```
<for_completed>
  {subagent_summary}
  
  {if artifacts:}
  Artifacts created:
  {for each artifact:}
  - {artifact.type}: {artifact.path}
</for_completed>
```

**Gap**: No header display, no summary conclusion with task/command reference.

### 4. Command Files

**Analyzed Commands**:
- `/research` - `.opencode/command/research.md`
- `/plan` - `.opencode/command/plan.md`
- `/implement` - `.opencode/command/implement.md`
- `/revise` - `.opencode/command/revise.md`
- `/task` - `.opencode/command/task.md`
- `/todo` - `.opencode/command/todo.md`
- `/errors` - `.opencode/command/errors.md`
- `/review` - `.opencode/command/review.md`
- `/meta` - `.opencode/command/meta.md`

**Current Behavior**:
- All commands route through orchestrator (agent: orchestrator in frontmatter)
- Orchestrator handles all user-facing output via Stage 5
- Commands define workflow but do not control output format

**Gap**: Commands cannot add headers or modify summaries - orchestrator controls all output.

### 5. Subagent Summary Patterns

**Analyzed Subagents**:
- `researcher.md` - Returns research summary
- `planner.md` - Returns plan summary
- `implementer.md` - Returns implementation summary

**Current Pattern**:
```json
{
  "summary": "Created implementation plan for task 244 with 3 phases. Plan focuses on context reorganization, orchestrator streamlining, and command simplification. Estimated effort: 8 hours.",
  ...
}
```

**Gap**: Summaries describe work done but do not conclude with task number or command reference.

---

## Requirements Analysis

### User Requirements (from Task 277)

1. **Header Display**:
   - Task-based commands (`/task`, `/research`, `/plan`, `/revise`, `/implement`): Display "Task: {number}"
   - Direct commands (`/todo`, `/errors`, `/review`, `/meta`): Display "Command: /{command}"

2. **Summary Conclusions**:
   - Task-based commands: Conclude with "Task {number} - /{command}"
   - Direct commands: Conclude with "Command: /{command}"

3. **Brief Summaries**:
   - All summaries should be brief (target: <100 tokens)
   - Already enforced by subagent-return-format.md standard

### Technical Requirements

1. **Header Display Location**: Orchestrator Stage 5 (PostflightCleanup)
   - Add header before subagent summary
   - Format based on command type (task-based vs direct)

2. **Summary Conclusion Location**: Orchestrator Stage 5 (PostflightCleanup)
   - Append conclusion after subagent summary
   - Format based on command type and task number

3. **Command Type Detection**: Orchestrator Stage 1 (PreflightValidation)
   - Already determines command type (task-based vs direct)
   - Pass command type to Stage 5 for formatting

4. **Task Number Extraction**: Orchestrator Stage 1 (PreflightValidation)
   - Already extracts task number from $ARGUMENTS
   - Pass task number to Stage 5 for formatting

---

## Implementation Approach

### Option 1: Modify Orchestrator Stage 5 (RECOMMENDED)

**Advantages**:
- Single point of control for all command output
- Consistent formatting across all commands
- No changes needed to subagents or commands
- Minimal code changes

**Changes Required**:
1. Update Stage 1 to store command_type and task_number in delegation_context
2. Update Stage 5 to add header before summary
3. Update Stage 5 to append conclusion after summary
4. Create command-output.md standard documenting format

**Implementation**:

```markdown
<stage id="5" name="PostflightCleanup">
  <action>Update session registry and format user response</action>
  <process>
    1. Update registry entry (unchanged)
    
    2. Remove from active registry (unchanged)
    
    3. Format response for user:
       a. Determine header based on command type:
          - Task-based: "Task: {task_number}"
          - Direct: "Command: /{command}"
       
       b. Format output:
          {header}
          
          {subagent_summary}
          
          {if artifacts:}
          Artifacts created:
          {for each artifact:}
          - {artifact.type}: {artifact.path}
          
          {conclusion}
       
       c. Determine conclusion based on command type:
          - Task-based: "Task {task_number} - /{command}"
          - Direct: "Command: /{command}"
    
    4. Return to user
  </process>
</stage>
```

**Example Output (Task-based)**:
```
Task: 258

Research completed for Truth.lean sorries. Found 3 sorries already resolved in Task 213. All acceptance criteria met.

Artifacts created:
- report: specs/258_resolve_truth_lean_sorries/reports/research-001.md
- summary: specs/258_resolve_truth_lean_sorries/summaries/research-summary.md

Task 258 - /research
```

**Example Output (Direct)**:
```
Command: /review

Codebase review completed. Updated 4 registries. Found 6 sorries, 11 axioms, 11 build errors. Test coverage 87.5%.

Artifacts created:
- summary: specs/225_codebase_review/summaries/review-summary.md

Command: /review
```

### Option 2: Modify Subagent Return Format

**Advantages**:
- Subagents control their own output format
- More flexibility for subagent-specific formatting

**Disadvantages**:
- Requires changes to all subagents (researcher, planner, implementer, etc.)
- Inconsistent if subagents implement differently
- More code changes and maintenance burden
- Subagents don't always know command name (only task number)

**Verdict**: NOT RECOMMENDED

### Option 3: Modify Command Files

**Advantages**:
- Commands control their own output

**Disadvantages**:
- Commands route through orchestrator, cannot control output
- Would require architectural change to command execution model
- Much more complex than Option 1

**Verdict**: NOT RECOMMENDED

---

## Recommended Solution

### Summary

Modify orchestrator Stage 5 (PostflightCleanup) to add headers and summary conclusions. Create command-output.md standard to document the format.

### Files to Modify

1. **`.opencode/agent/orchestrator.md`**:
   - Stage 1: Store command_type and task_number in delegation_context
   - Stage 5: Add header and conclusion formatting logic
   - Update return_format templates with header and conclusion

2. **`.opencode/context/core/standards/command-output.md`** (NEW):
   - Document header format for task-based and direct commands
   - Document summary conclusion format
   - Provide examples for each command type
   - Reference from orchestrator.md

### Implementation Steps

1. **Create command-output.md standard** (1 hour):
   - Define header format: "Task: {number}" vs "Command: /{command}"
   - Define conclusion format: "Task {number} - /{command}" vs "Command: /{command}"
   - Provide examples for all command types
   - Document token limits and formatting rules

2. **Update orchestrator.md Stage 1** (0.5 hours):
   - Store command_type in delegation_context (already determined)
   - Store task_number in delegation_context (already extracted)
   - Store command_name in delegation_context (from command file)

3. **Update orchestrator.md Stage 5** (1.5 hours):
   - Add header formatting logic before summary
   - Add conclusion formatting logic after summary
   - Update return_format templates for all status types
   - Test with task-based and direct commands

4. **Update orchestrator.md context_loading** (0.5 hours):
   - Add command-output.md to required context files
   - Ensure orchestrator loads output formatting standard

5. **Testing and validation** (1 hour):
   - Test task-based commands: /research, /plan, /implement, /revise, /task
   - Test direct commands: /todo, /errors, /review, /meta
   - Verify headers display correctly
   - Verify conclusions display correctly
   - Verify summaries remain brief (<100 tokens)

**Total Estimated Effort**: 4.5 hours

---

## Alternative Considerations

### Brief Summary Enforcement

**Current State**: Subagent-return-format.md requires <100 token summaries

**Question**: Are summaries currently too verbose?

**Analysis**:
- Standard already enforces <100 tokens (~400 characters)
- Orchestrator Stage 4 validates summary length
- No evidence of verbose summaries in current system

**Recommendation**: No changes needed - existing standard is sufficient.

### Header Display Timing

**Question**: Should headers be displayed before or after subagent execution?

**Analysis**:
- Before: User sees "Task: 258" immediately, then waits for result
- After: User sees result with header at the same time

**Current Behavior**: Orchestrator returns all output at once (Stage 5)

**Recommendation**: Display header with result (current behavior) - simpler implementation, no streaming required.

---

## Risk Analysis

### Low Risk

1. **Orchestrator changes**: Well-defined modification to Stage 5 only
2. **Standard creation**: New file, no breaking changes
3. **Testing**: Easy to test with existing commands

### Medium Risk

1. **Context window impact**: Adding header and conclusion increases output by ~20 tokens
   - Mitigation: Still well under 100 token summary limit
   - Total output: ~120 tokens (header + summary + conclusion)

2. **Backward compatibility**: Existing tools/scripts parsing command output may break
   - Mitigation: Output format is for human consumption, not machine parsing
   - No known tools depend on current output format

### No Risk

1. **Subagent changes**: No changes required
2. **Command changes**: No changes required
3. **Breaking changes**: Purely additive, no removal of existing functionality

---

## Success Criteria

1. **Header Display**:
   - [ ] Task-based commands display "Task: {number}" at the top
   - [ ] Direct commands display "Command: /{command}" at the top

2. **Summary Conclusions**:
   - [ ] Task-based commands conclude with "Task {number} - /{command}"
   - [ ] Direct commands conclude with "Command: /{command}"

3. **Brief Summaries**:
   - [ ] All summaries remain <100 tokens (existing standard enforced)

4. **Documentation**:
   - [ ] command-output.md standard created and documented
   - [ ] orchestrator.md updated with header and conclusion logic
   - [ ] Examples provided for all command types

5. **Testing**:
   - [ ] All task-based commands tested (/research, /plan, /implement, /revise, /task)
   - [ ] All direct commands tested (/todo, /errors, /review, /meta)
   - [ ] Headers and conclusions display correctly
   - [ ] No regression in existing functionality

---

## References

1. **Orchestrator Agent**: `.opencode/agent/orchestrator.md`
   - Stage 1 (PreflightValidation): Argument parsing and command type detection
   - Stage 5 (PostflightCleanup): User output formatting

2. **Subagent Return Format**: `.opencode/context/core/standards/subagent-return-format.md`
   - Summary requirements: <100 tokens, 2-5 sentences
   - Return format schema and validation rules

3. **Command Argument Handling**: `.opencode/context/core/standards/command-argument-handling.md`
   - Task-based vs direct command classification
   - Argument parsing and validation

4. **Routing Logic**: `.opencode/context/core/system/routing-logic.md`
   - Language-based routing for task commands
   - Command type determination

---

## Conclusion

The recommended solution is to modify orchestrator Stage 5 (PostflightCleanup) to add headers and summary conclusions. This approach:

- Requires minimal code changes (single file: orchestrator.md)
- Provides consistent formatting across all commands
- Does not require changes to subagents or commands
- Is low risk and easy to test
- Estimated effort: 4.5 hours

The implementation will create a new command-output.md standard documenting the header and conclusion formats, and update orchestrator.md to implement the formatting logic.

**Next Steps**: Create implementation plan for Task 277 using `/plan 277`.
