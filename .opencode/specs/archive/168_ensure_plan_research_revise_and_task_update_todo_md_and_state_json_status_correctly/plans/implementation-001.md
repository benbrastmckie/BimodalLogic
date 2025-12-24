# Implementation Plan: Ensure /plan, /research, /revise, and /task Update TODO.md and state.json Status Correctly

**Project**: #168
**Version**: 001
**Date**: 2025-12-24
**Status**: [COMPLETED]
**Started**: 2025-12-24
**Completed**: 2025-12-24
**Complexity**: Complex
**Estimated Effort**: 12-20 hours (1.5-2.5 days)
**Actual Effort**: ~8 hours
**Lean**: false

## Task Description

Verify and fix status synchronization across /plan, /research, /revise, and /task commands to ensure TODO.md and state.json are updated correctly and atomically according to status-markers.md and state-schema.md standards. Commands must set [IN PROGRESS] with Started timestamps at preflight, update to [RESEARCHED]/[PLANNED]/[COMPLETED] with Completed timestamps at postflight, and keep TODO/state/plan status markers in lockstep throughout execution.

## Research Inputs

- **Research Report**: `.opencode/specs/168_ensure_plan_research_revise_and_task_update_todo_md_and_state_json_status_correctly/reports/research-001.md`
  - Comprehensive audit of status synchronization across all four commands
  - Identified 5 critical gaps in atomicity and consistency
  - Analyzed batch-status-manager limitations (TODO.md only)
  - Documented field naming inconsistencies in state.json
  - Verified lazy directory creation compliance (100%)

## Complexity Assessment

### Level: **COMPLEX**

### Estimated Effort: **12-20 hours** (1.5-2.5 days)

### Required Knowledge Areas

1. **File System Operations**
   - Atomic file writes
   - File locking mechanisms
   - Transaction semantics
   - Rollback strategies

2. **State Management**
   - TODO.md status marker format
   - state.json schema
   - Implementation plan status format
   - Status transition validation

3. **Command Architecture**
   - Command orchestration patterns
   - Subagent delegation
   - Specialist integration
   - Lazy directory creation

4. **Markdown & JSON Parsing**
   - TODO.md section parsing
   - JSON schema validation
   - Plan file header parsing
   - Timestamp format handling

5. **Error Handling**
   - Partial failure recovery
   - Graceful degradation
   - Retry logic with backoff
   - Validation error reporting

### Potential Challenges

#### Critical Challenges

1. **Multi-File Atomicity Without True Transactions**
   - **Issue**: No database-style ACID transactions available
   - **Risk**: Partial updates if process crashes mid-write
   - **Mitigation**: Implement two-phase commit pattern with write-ahead logging

2. **Backward Compatibility**
   - **Issue**: Existing batch-status-manager only handles TODO.md
   - **Risk**: Breaking existing batch task execution
   - **Mitigation**: Extend rather than replace; maintain API compatibility

3. **Race Condition Prevention**
   - **Issue**: Multiple commands could update files concurrently
   - **Risk**: File corruption or lost updates
   - **Mitigation**: Implement file locking or serialization queue

#### Moderate Challenges

4. **Status Transition Ambiguity in /revise**
   - **Issue**: Unclear whether revision should reset status or preserve it
   - **Risk**: Inconsistent behavior across workflows
   - **Mitigation**: Define clear semantics and document decision

5. **Field Naming Inconsistency**
   - **Issue**: `started` vs `started_at` in different specs
   - **Risk**: Implementation bugs from mismatched field names
   - **Mitigation**: Systematic search and replace with validation

6. **Preserving Lazy Creation**
   - **Issue**: Status updates must not trigger directory creation
   - **Risk**: Violating lazy creation principle
   - **Mitigation**: Careful separation of status updates from artifact writes

## Technology Stack

### Languages
- Markdown (command specifications)
- JSON (state.json schema)

### Frameworks
- OpenCode agent system
- OpenCode command system

### Tools
- Read/Write tools for file operations
- Glob tool for file discovery
- Bash tool for validation scripts

### Dependencies
- `.opencode/context/common/system/status-markers.md` (status marker definitions)
- `.opencode/context/common/system/state-schema.md` (state.json schema)
- `.opencode/context/common/standards/plan.md` (plan format standards)
- `.opencode/agent/subagents/specialists/batch-status-manager.md` (existing specialist)

## Dependencies

### Required Modules/Standards

```markdown
- status-markers.md (.opencode/context/common/system/)
  Usage: Status marker definitions and transition rules

- state-schema.md (.opencode/context/common/system/)
  Usage: State file structure and field naming conventions

- batch-status-manager.md (.opencode/agent/subagents/specialists/)
  Usage: Reference implementation for atomic TODO.md updates

- tasks.md (.opencode/context/common/standards/)
  Usage: Task metadata and formatting standards

- artifact-management.md (.opencode/context/common/system/)
  Usage: Lazy directory creation and artifact lifecycle rules
```

### Prerequisites

1. **batch-status-manager specialist** (exists)
   - Location: `.opencode/agent/subagents/specialists/batch-status-manager.md`
   - Status: Handles atomic TODO.md updates only
   - Needs: Extension for state.json and plan files

2. **status-markers standard** (exists)
   - Location: `.opencode/context/common/system/status-markers.md`
   - Status: Complete specification with [RESEARCHED] and [PLANNED] markers
   - Needs: Documentation of multi-file synchronization

3. **state-schema standard** (exists)
   - Location: `.opencode/context/common/system/state-schema.md`
   - Status: Defines state.json structure
   - Needs: Field naming clarification (started vs started_at)

### External Libraries

None - uses built-in file system operations and markdown/JSON parsing.

## Implementation Steps

### Phase 1: Create status-sync-manager Specialist
**Status**: [NOT STARTED]
**Estimated Effort**: 4-6 hours

#### Step 1.1: Design Specialist Interface

**Action**: Design status-sync-manager specialist based on batch-status-manager.md

**File**: `.opencode/agent/subagents/specialists/status-sync-manager.md`

**Approach**:
1. Read batch-status-manager.md to understand existing pattern
2. Design interface for multi-file atomic updates
3. Define operations:
   - `mark_in_progress` (TODO + state + plan)
   - `mark_researched` (TODO + state)
   - `mark_planned` (TODO + state + plan)
   - `mark_completed` (TODO + state + plan)
   - `mark_blocked` (TODO + state + plan)
   - `mark_abandoned` (TODO + state + plan)
4. Specify input parameters (task_number, plan_path, timestamps)
5. Specify output format (success/failure, updated files)

**Verification**: Interface design reviewed against status-markers.md and state-schema.md

#### Step 1.2: Implement Atomic Update Logic

**Action**: Implement multi-file atomic update mechanism

**File**: `.opencode/agent/subagents/specialists/status-sync-manager.md`

**Approach**:
1. Implement two-phase commit pattern:
   - Phase 1: Read all files (TODO.md, state.json, plan file if exists)
   - Phase 2: Validate status transitions
   - Phase 3: Prepare updates in memory
   - Phase 4: Write all files atomically
2. Add rollback mechanism for partial failures
3. Implement file locking strategy (advisory locks)
4. Add timestamp synchronization:
   - TODO.md: YYYY-MM-DD format
   - state.json: YYYY-MM-DD format
   - Plan files: ISO8601 format
5. Add validation checks:
   - Status transition validity
   - Required fields present
   - Timestamp format correctness

**Verification**: Specialist can update all three files atomically with rollback on failure

#### Step 1.3: Add Status Marker Validation

**Action**: Implement status transition validation per status-markers.md

**File**: `.opencode/agent/subagents/specialists/status-sync-manager.md`

**Approach**:
1. Define valid status transitions:
   - [NOT STARTED] → [IN PROGRESS]
   - [IN PROGRESS] → [RESEARCHED]
   - [IN PROGRESS] → [PLANNED]
   - [IN PROGRESS] → [COMPLETED]
   - [IN PROGRESS] → [BLOCKED]
   - [IN PROGRESS] → [ABANDONED]
   - [RESEARCHED] → [IN PROGRESS] (for /plan after /research)
   - [PLANNED] → [IN PROGRESS] (for /task or /revise)
2. Implement validation logic
3. Add error messages for invalid transitions
4. Add graceful degradation (update what's possible, report failures)

**Verification**: Invalid status transitions are rejected with clear error messages

#### Step 1.4: Write Specialist Documentation

**Action**: Document specialist interface, operations, and usage

**File**: `.opencode/agent/subagents/specialists/status-sync-manager.md`

**Approach**:
1. Add specialist header with metadata
2. Document each operation with examples
3. Add usage guidelines for command orchestrators
4. Document error handling and rollback behavior
5. Add examples of multi-file synchronization
6. Document backward compatibility with batch-status-manager

**Verification**: Documentation is complete and follows specialist template

### Phase 2: Fix state.json Field Naming
**Status**: [NOT STARTED]
**Estimated Effort**: 1-2 hours

#### Step 2.1: Audit state.json Field Names

**Action**: Search all command specs and state files for field naming inconsistencies

**Files**: 
- `.opencode/command/plan.md`
- `.opencode/command/research.md`
- `.opencode/command/revise.md`
- `.opencode/command/task.md`
- `.opencode/specs/state.json`
- All project-specific state.json files

**Approach**:
1. Use Grep tool to find all references to `started_at`, `completed_at`, `researched_at`, `planned_at`
2. Use Grep tool to find all references to `started`, `completed`, `researched`, `planned`
3. Document all occurrences and their contexts
4. Identify which fields are status fields vs timestamp fields

**Verification**: Complete list of field naming inconsistencies

#### Step 2.2: Standardize Field Names

**Action**: Update all specs to use consistent field naming per state-schema.md

**Files**: All command specs and state-schema.md

**Approach**:
1. Standardize on:
   - Status fields: `status` (values: "not_started", "in_progress", "researched", "planned", "completed", "blocked", "abandoned")
   - Timestamp fields: `started`, `completed`, `researched`, `planned` (format: YYYY-MM-DD)
2. Update task.md line 67 from `started_at` to `started`
3. Update all command specifications for consistency
4. Update state-schema.md to clarify field naming conventions
5. Add examples showing correct field usage

**Verification**: All specs use consistent field names matching state-schema.md

#### Step 2.3: Update Existing state.json Files

**Action**: Update all existing state.json files to use standardized field names

**Files**: `.opencode/specs/state.json` and project-specific state.json files

**Approach**:
1. Read each state.json file
2. Rename fields if needed (e.g., `researched_at` → `researched`)
3. Validate JSON structure
4. Write updated files
5. Preserve all other data

**Verification**: All state.json files use standardized field names

### Phase 3: Fix /revise Command Postflight
**Status**: [NOT STARTED]
**Estimated Effort**: 2-3 hours

#### Step 3.1: Define /revise Status Transition Semantics

**Action**: Clarify whether /revise should change task status or preserve [PLANNED]

**File**: `.opencode/command/revise.md`

**Approach**:
1. Analyze use cases:
   - Scenario 1: User revises plan before starting work → Keep [PLANNED]
   - Scenario 2: User revises plan during work → Keep [IN PROGRESS]
2. **Decision**: /revise should preserve current status (don't reset to [PLANNED])
3. Rationale: Revision is a refinement, not a status change
4. Document decision in revise.md
5. Add examples showing status preservation

**Verification**: Clear semantics documented with examples

#### Step 3.2: Add Postflight Status Updates

**Action**: Add explicit status update specification to /revise postflight

**File**: `.opencode/command/revise.md`

**Approach**:
1. Update Stage 3 (Postflight) to include:
   - Update TODO.md: Preserve current status, update plan link, add **Completed** timestamp for revision
   - Update state.json: Preserve current status, update plan version, add revision timestamp
   - Update new plan file: Set header to [NOT STARTED], set all phases to [NOT STARTED]
   - Update old plan file: Add note indicating superseded by new version
2. Delegate to status-sync-manager for atomic updates
3. Specify timestamp handling (YYYY-MM-DD for TODO/state, ISO8601 for plans)
4. Add error handling for failed updates

**Verification**: Postflight stage specifies all required status updates

#### Step 3.3: Remove Conditional State Updates

**Action**: Remove "if task-bound" condition from state.json updates

**File**: `.opencode/command/revise.md`

**Approach**:
1. Update Stage 1 (Preflight) line 53
2. Change from: "state to `in_progress` if task-bound"
3. Change to: "state to current status (preserve)"
4. Rationale: Simplify logic, ensure consistency
5. Document that /revise always updates state.json

**Verification**: No conditional state updates in /revise

#### Step 3.4: Update Documentation

**Action**: Update /revise documentation with new status update behavior

**File**: `.opencode/command/revise.md`

**Approach**:
1. Add examples showing status preservation
2. Document atomic update mechanism
3. Add troubleshooting section for status update failures
4. Update command description to mention status preservation

**Verification**: Documentation is complete and accurate

### Phase 4: Standardize Plan File Status Updates
**Status**: [NOT STARTED]
**Estimated Effort**: 3-4 hours

#### Step 4.1: Update /plan Command

**Action**: Add plan file status updates to /plan postflight

**File**: `.opencode/command/plan.md`

**Approach**:
1. Update Stage 1 (Preflight) line 55:
   - Add explicit atomic update mechanism
   - Delegate to status-sync-manager
   - Specify TODO.md + state.json updates
2. Update Stage 4 (Postflight) line 79:
   - Add plan file status update: Set header to [PLANNED]
   - Add **Completed** timestamp to plan header (ISO8601)
   - Delegate to status-sync-manager for atomic TODO + state + plan updates
3. Add error handling for failed updates
4. Document atomic update mechanism

**Verification**: /plan updates plan file status atomically with TODO.md and state.json

#### Step 4.2: Update /research Command

**Action**: Add explicit atomic update mechanism to /research

**File**: `.opencode/command/research.md`

**Approach**:
1. Update Stage 1 (Preflight) line 53:
   - Add explicit atomic update mechanism
   - Delegate to status-sync-manager
   - Specify TODO.md + state.json updates
2. Update Stage 3 (Postflight) line 69:
   - Delegate to status-sync-manager for atomic TODO + state updates
   - Note: No plan file updates (research doesn't create plans)
3. Add error handling for failed updates
4. Document atomic update mechanism

**Verification**: /research updates TODO.md and state.json atomically

#### Step 4.3: Verify /task Command

**Action**: Verify /task command atomic update implementation

**Files**: 
- `.opencode/command/task.md`
- `.opencode/agent/subagents/task-executor.md`
- `.opencode/agent/subagents/batch-task-orchestrator.md`

**Approach**:
1. Audit task.md for atomic update specification (already correct)
2. Audit task-executor.md Stage 1 (MarkTaskInProgress) and Stage 9 (MarkTaskComplete)
3. Verify delegation to status-sync-manager (or batch-status-manager)
4. Update batch-task-orchestrator.md to use status-sync-manager instead of batch-status-manager
5. Add explicit atomicity mechanism documentation
6. Test multi-task batch updates

**Verification**: /task uses status-sync-manager for atomic multi-file updates

#### Step 4.4: Update batch-status-manager References

**Action**: Update all references to batch-status-manager to use status-sync-manager

**Files**: 
- `.opencode/agent/subagents/batch-task-orchestrator.md`
- `.opencode/agent/subagents/task-executor.md`
- Any other agents using batch-status-manager

**Approach**:
1. Use Grep tool to find all references to batch-status-manager
2. Evaluate each reference:
   - If only TODO.md updates needed: Keep batch-status-manager
   - If multi-file updates needed: Switch to status-sync-manager
3. Update agent specifications
4. Document migration path
5. Maintain backward compatibility

**Verification**: All multi-file status updates use status-sync-manager

### Phase 5: Testing and Validation
**Status**: [NOT STARTED]
**Estimated Effort**: 2-3 hours

#### Step 5.1: Create Integration Test Plan

**Action**: Design comprehensive test plan for status synchronization

**File**: `.opencode/specs/168_ensure_plan_research_revise_and_task_update_todo_md_and_state_json_status_correctly/test-plan.md`

**Approach**:
1. Define test scenarios:
   - Test 1: /plan command updates TODO + state + plan atomically
   - Test 2: /research command updates TODO + state atomically
   - Test 3: /revise command preserves status and updates files atomically
   - Test 4: /task command updates TODO + state + plan atomically
   - Test 5: Rollback on partial failure
   - Test 6: Concurrent update handling
   - Test 7: Invalid status transitions rejected
   - Test 8: Lazy directory creation preserved
2. Define success criteria for each test
3. Define test data and setup
4. Define validation steps

**Verification**: Comprehensive test plan covering all scenarios

#### Step 5.2: Execute Integration Tests

**Action**: Run integration tests for all four commands

**Approach**:
1. Create test TODO.md with sample tasks
2. Test /plan command:
   - Run /plan on test task
   - Verify TODO.md updated to [PLANNED]
   - Verify state.json updated to "planned"
   - Verify plan file header updated to [PLANNED]
   - Verify timestamps present and correct
3. Test /research command:
   - Run /research on test task
   - Verify TODO.md updated to [RESEARCHED]
   - Verify state.json updated to "researched"
   - Verify timestamps present and correct
4. Test /revise command:
   - Run /revise on planned task
   - Verify status preserved
   - Verify plan link updated
   - Verify new plan created with [NOT STARTED]
5. Test /task command:
   - Run /task on planned task
   - Verify TODO.md updated to [COMPLETED]
   - Verify state.json updated to "completed"
   - Verify plan file updated to [COMPLETED]
6. Document test results

**Verification**: All tests pass with atomic updates confirmed

#### Step 5.3: Test Lazy Directory Creation

**Action**: Verify lazy directory creation preserved throughout

**Approach**:
1. Test status updates without artifact creation:
   - Update task status to [IN PROGRESS]
   - Verify no directories created
2. Test status updates with artifact creation:
   - Run /plan to create plan artifact
   - Verify project root + plans/ created only when writing plan
3. Test /revise:
   - Verify no new project root created
   - Verify new plan file created in existing plans/
4. Document results

**Verification**: Lazy directory creation preserved in all scenarios

#### Step 5.4: Test Error Handling

**Action**: Test rollback and error handling

**Approach**:
1. Test partial failure scenarios:
   - Simulate TODO.md write failure
   - Verify rollback of state.json and plan file
   - Verify error message clear and actionable
2. Test invalid status transitions:
   - Attempt [NOT STARTED] → [COMPLETED]
   - Verify rejection with error message
3. Test concurrent updates:
   - Simulate two commands updating same task
   - Verify file locking prevents corruption
4. Document results

**Verification**: Error handling and rollback work correctly

### Phase 6: Documentation Updates
**Status**: [NOT STARTED]
**Estimated Effort**: 1-2 hours

#### Step 6.1: Update status-markers.md

**Action**: Document multi-file synchronization in status-markers.md

**File**: `.opencode/context/common/system/status-markers.md`

**Approach**:
1. Add section on multi-file atomic updates
2. Document status-sync-manager specialist
3. Add examples of synchronized updates across TODO/state/plan
4. Document rollback behavior
5. Add troubleshooting section

**Verification**: status-markers.md documents multi-file synchronization

#### Step 6.2: Update state-schema.md

**Action**: Clarify field naming conventions in state-schema.md

**File**: `.opencode/context/common/system/state-schema.md`

**Approach**:
1. Add explicit field naming section:
   - Status field: `status` (string, values: "not_started", "in_progress", etc.)
   - Timestamp fields: `started`, `completed`, `researched`, `planned` (string, format: YYYY-MM-DD)
2. Add examples showing correct field usage
3. Document that timestamp fields do NOT use `_at` suffix
4. Add migration guide for existing state.json files

**Verification**: state-schema.md clearly documents field naming

#### Step 6.3: Create Troubleshooting Guide

**Action**: Create troubleshooting guide for status synchronization issues

**File**: `.opencode/specs/168_ensure_plan_research_revise_and_task_update_todo_md_and_state_json_status_correctly/troubleshooting.md`

**Approach**:
1. Document common issues:
   - TODO.md and state.json out of sync
   - Plan file status doesn't match TODO.md
   - Invalid status transitions
   - Partial update failures
2. Add diagnostic steps for each issue
3. Add resolution steps
4. Add prevention strategies

**Verification**: Troubleshooting guide is comprehensive and actionable

#### Step 6.4: Update Command Documentation

**Action**: Update all command documentation with atomic update details

**Files**: plan.md, research.md, revise.md, task.md

**Approach**:
1. Add "Status Synchronization" section to each command
2. Document atomic update mechanism
3. Add examples showing status updates
4. Document error handling
5. Add links to status-sync-manager specialist

**Verification**: All command docs document status synchronization

## File Structure

```
.opencode/
├── agent/
│   └── subagents/
│       └── specialists/
│           ├── batch-status-manager.md (existing, unchanged)
│           └── status-sync-manager.md (NEW - Phase 1)
├── command/
│   ├── plan.md (MODIFIED - Phase 4)
│   ├── research.md (MODIFIED - Phase 4)
│   ├── revise.md (MODIFIED - Phase 3)
│   └── task.md (MODIFIED - Phase 4)
├── context/
│   └── common/
│       ├── standards/
│       │   └── plan.md (reference only)
│       └── system/
│           ├── status-markers.md (MODIFIED - Phase 6)
│           └── state-schema.md (MODIFIED - Phase 2, Phase 6)
└── specs/
    ├── state.json (MODIFIED - Phase 2)
    └── 168_ensure_plan_research_revise_and_task_update_todo_md_and_state_json_status_correctly/
        ├── plans/
        │   └── implementation-001.md (THIS FILE)
        ├── reports/
        │   └── research-001.md (existing)
        ├── test-plan.md (NEW - Phase 5)
        └── troubleshooting.md (NEW - Phase 6)
```

## Testing Strategy

### Unit Tests

**Scope**: status-sync-manager specialist operations

**Tests**:
1. Test `mark_in_progress` updates TODO + state + plan
2. Test `mark_researched` updates TODO + state
3. Test `mark_planned` updates TODO + state + plan
4. Test `mark_completed` updates TODO + state + plan
5. Test status transition validation
6. Test timestamp format validation
7. Test rollback on partial failure

**Coverage Goal**: 100% of status-sync-manager operations

### Integration Tests

**Scope**: End-to-end command execution

**Tests**:
1. Test /plan command full workflow
2. Test /research command full workflow
3. Test /revise command full workflow
4. Test /task command full workflow
5. Test command chaining (/research → /plan → /task)
6. Test concurrent command execution
7. Test lazy directory creation preservation

**Coverage Goal**: All four commands with all status transitions

### Regression Tests

**Scope**: Ensure backward compatibility

**Tests**:
1. Test batch-status-manager still works for TODO.md-only updates
2. Test existing batch task execution workflows
3. Test existing command invocations
4. Test existing state.json files

**Coverage Goal**: No breaking changes to existing functionality

## Verification Checkpoints

- [ ] Phase 1.1: status-sync-manager interface designed and reviewed
- [ ] Phase 1.2: Atomic update logic implemented with rollback
- [ ] Phase 1.3: Status transition validation implemented
- [ ] Phase 1.4: status-sync-manager documentation complete
- [ ] Phase 2.1: Field naming inconsistencies documented
- [ ] Phase 2.2: All specs use consistent field names
- [ ] Phase 2.3: All state.json files updated
- [ ] Phase 3.1: /revise status semantics defined
- [ ] Phase 3.2: /revise postflight status updates added
- [ ] Phase 3.3: Conditional state updates removed
- [ ] Phase 3.4: /revise documentation updated
- [ ] Phase 4.1: /plan updates plan file status
- [ ] Phase 4.2: /research uses atomic updates
- [ ] Phase 4.3: /task verified to use status-sync-manager
- [ ] Phase 4.4: batch-status-manager references updated
- [ ] Phase 5.1: Integration test plan created
- [ ] Phase 5.2: All integration tests pass
- [ ] Phase 5.3: Lazy directory creation verified
- [ ] Phase 5.4: Error handling and rollback tested
- [ ] Phase 6.1: status-markers.md updated
- [ ] Phase 6.2: state-schema.md clarified
- [ ] Phase 6.3: Troubleshooting guide created
- [ ] Phase 6.4: All command docs updated

## Documentation Requirements

### Specialist Documentation

- **status-sync-manager.md**: Complete specialist specification with interface, operations, examples, and error handling

### Standard Updates

- **status-markers.md**: Add multi-file synchronization section with examples
- **state-schema.md**: Clarify field naming conventions with migration guide

### Command Updates

- **plan.md**: Document atomic update mechanism and plan file status updates
- **research.md**: Document atomic update mechanism
- **revise.md**: Document status preservation semantics and atomic updates
- **task.md**: Verify and document status-sync-manager usage

### Project Documentation

- **test-plan.md**: Comprehensive integration test plan
- **troubleshooting.md**: Common issues and resolutions

## Success Criteria

### Functional Requirements

- [ ] All four commands (/plan, /research, /revise, /task) update TODO.md and state.json atomically
- [ ] Plan file status markers synchronized with TODO.md and state.json
- [ ] /revise command preserves task status and updates files atomically
- [ ] Invalid status transitions rejected with clear error messages
- [ ] Partial update failures trigger rollback
- [ ] Lazy directory creation preserved throughout

### Technical Requirements

- [ ] status-sync-manager specialist implements multi-file atomic updates
- [ ] Two-phase commit pattern with rollback implemented
- [ ] File locking prevents concurrent update corruption
- [ ] Timestamp formats correct per file type (YYYY-MM-DD for TODO/state, ISO8601 for plans)
- [ ] Field naming consistent across all specs (started, completed, not started_at, completed_at)

### Quality Requirements

- [ ] All integration tests pass
- [ ] No breaking changes to existing functionality
- [ ] Documentation complete and accurate
- [ ] Troubleshooting guide comprehensive
- [ ] Code review completed

### Compliance Requirements

- [ ] status-markers.md compliance: All status markers and transitions correct
- [ ] state-schema.md compliance: All field names and formats correct
- [ ] plan.md compliance: Plan format and status markers correct
- [ ] Lazy directory creation: No directories created until artifact write

## Related Research

- **Research Report**: `.opencode/specs/168_ensure_plan_research_revise_and_task_update_todo_md_and_state_json_status_correctly/reports/research-001.md`
  - Comprehensive audit identifying 5 critical gaps
  - Detailed analysis of batch-status-manager limitations
  - Field naming inconsistency documentation
  - Lazy directory creation compliance verification

## Notes

### Design Decisions

1. **status-sync-manager vs Extending batch-status-manager**
   - Decision: Create new status-sync-manager specialist
   - Rationale: Clean separation of concerns, easier to maintain, backward compatible
   - Alternative: Extend batch-status-manager (rejected due to complexity)

2. **/revise Status Preservation**
   - Decision: Preserve current status, don't reset to [PLANNED]
   - Rationale: Revision is refinement, not status change
   - Alternative: Reset to [PLANNED] (rejected as too disruptive)

3. **Field Naming: started vs started_at**
   - Decision: Use `started`, `completed` (no `_at` suffix)
   - Rationale: Matches status-markers.md specification
   - Alternative: Use `_at` suffix (rejected for consistency)

4. **Atomicity Implementation**
   - Decision: Two-phase commit with rollback
   - Rationale: Best balance of atomicity and simplicity
   - Alternative: Event-driven architecture (deferred to future)

### Implementation Priorities

1. **High Priority**: Phase 1 (status-sync-manager) - Foundational for all other phases
2. **High Priority**: Phase 3 (/revise fixes) - Critical gap identified in research
3. **Medium Priority**: Phase 2 (field naming) - Can be done in parallel with Phase 1
4. **Medium Priority**: Phase 4 (plan file updates) - Depends on Phase 1
5. **Low Priority**: Phase 5 (testing) - Validates all previous phases
6. **Low Priority**: Phase 6 (documentation) - Final polish

### Risk Mitigation

1. **Backward Compatibility Risk**
   - Mitigation: Keep batch-status-manager unchanged, add status-sync-manager as new specialist
   - Validation: Test existing batch task execution workflows

2. **Partial Update Risk**
   - Mitigation: Implement rollback mechanism in status-sync-manager
   - Validation: Test partial failure scenarios

3. **Concurrent Update Risk**
   - Mitigation: Implement file locking in status-sync-manager
   - Validation: Test concurrent command execution

4. **Field Naming Migration Risk**
   - Mitigation: Update all specs first, then update state.json files
   - Validation: Grep for all field references before and after

### Future Enhancements

1. **Event-Driven Architecture**: Commands emit status change events, central manager consumes
2. **Status Update Monitoring**: Track success rate, detect divergence, alert on failures
3. **Automated Divergence Detection**: Periodic scans to find TODO/state/plan mismatches
4. **Status Update Audit Log**: Record all status changes for debugging and compliance

### Dependencies on Other Tasks

- None - This is a foundational task that other tasks may depend on

### Estimated Timeline

- **Phase 1**: 4-6 hours (Day 1)
- **Phase 2**: 1-2 hours (Day 1)
- **Phase 3**: 2-3 hours (Day 1-2)
- **Phase 4**: 3-4 hours (Day 2)
- **Phase 5**: 2-3 hours (Day 2)
- **Phase 6**: 1-2 hours (Day 2)

**Total**: 12-20 hours (1.5-2.5 days)

### Completion Criteria

This implementation is complete when:
1. All 6 phases are marked [COMPLETED]
2. All verification checkpoints are checked
3. All success criteria are met
4. Integration tests pass
5. Documentation is complete
6. Code review is approved
7. This plan status is updated to [COMPLETED]
