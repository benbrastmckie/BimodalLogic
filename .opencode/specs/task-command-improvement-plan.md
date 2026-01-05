# Task Command Improvement Plan

**Created**: 2026-01-04  
**Author**: Research Analysis  
**Status**: Draft for Review  
**Related Issue**: /task command inconsistently creates tasks vs. implementing them

---

## Executive Summary

The `/task` command currently has an inconsistent behavior where it sometimes creates task entries in TODO.md and state.json as intended, but other times skips ahead to implement the task directly. This plan analyzes the `/research` and `/implement` command patterns to identify best practices and proposes improvements to make `/task` consistently create tasks without implementing them.

### Key Findings

1. **Root Cause**: The `/task` command file (381 lines) contains extensive workflow documentation but lacks the clean separation of concerns found in `/research` (115 lines) and `/implement` (122 lines)
2. **Pattern Mismatch**: `/research` and `/implement` use a 2-stage workflow (ParseAndValidate → Delegate), while `/task` uses a 5-stage workflow that attempts to do everything inline
3. **Missing Delegation**: `/task` explicitly forbids delegation to subagents (lines 198-204), while `/research` and `/implement` delegate to specialized subagents
4. **State Management**: `/task` attempts manual state.json updates, while `/research` and `/implement` rely on status-sync-manager for atomic updates

### Recommended Solution

Refactor `/task` to follow the proven `/research` and `/implement` pattern:
- **2-stage workflow**: ParseAndValidate → Delegate
- **Delegate to subagent**: Create a new `task-creator` subagent that handles task creation
- **Use status-sync-manager**: Leverage existing atomic update infrastructure
- **Reduce command file size**: Target <150 lines (similar to `/research` and `/implement`)

---

## Current State Analysis

### /research Command Pattern (115 lines)

**Structure**:
```yaml
---
name: research
agent: orchestrator
routing:
  language_based: true
  lean: lean-research-agent
  default: researcher
---
```

**Workflow** (2 stages):
1. **ParseAndValidate**: Parse task number, lookup in state.json, extract metadata
2. **Delegate**: Invoke researcher subagent with parsed context

**Key Characteristics**:
- ✅ Clean separation: command parses, subagent executes
- ✅ State.json as source of truth (8x faster than TODO.md parsing)
- ✅ Language-based routing to specialized agents
- ✅ Minimal command file size (115 lines)
- ✅ Subagent handles status updates via status-sync-manager

### /implement Command Pattern (122 lines)

**Structure**:
```yaml
---
name: implement
agent: orchestrator
routing:
  language_based: true
  lean: lean-implementation-agent
  default: implementer
---
```

**Workflow** (2 stages):
1. **ParseAndValidate**: Parse task number, lookup in state.json, extract metadata
2. **Delegate**: Invoke implementer subagent with parsed context

**Key Characteristics**:
- ✅ Clean separation: command parses, subagent executes
- ✅ State.json as source of truth
- ✅ Language-based routing (lean vs. meta vs. general)
- ✅ Minimal command file size (122 lines)
- ✅ Subagent handles status updates via status-sync-manager
- ✅ Resume support for multi-phase implementations

### /task Command Current Pattern (381 lines)

**Structure**:
```yaml
---
name: task
agent: orchestrator
description: "Create new task in .opencode/specs/TODO.md (NO implementation)"
context_level: 1
language: markdown
---
```

**Workflow** (5 stages):
1. **ParseInput**: Parse description, extract flags, detect language
2. **ReadNextNumber**: Read next_project_number from state.json
3. **CreateTODOEntry**: Format and append to TODO.md
4. **UpdateStateJson**: Increment next_project_number, add recent_activities
5. **ReturnSuccess**: Return task number and confirmation

**Key Characteristics**:
- ❌ No delegation (explicitly forbidden, lines 198-204)
- ❌ Manual state.json updates (no atomic guarantees)
- ❌ Manual TODO.md updates (no validation)
- ❌ Large command file (381 lines, 3x larger than /research)
- ❌ Inline execution (no separation of concerns)
- ⚠️ Extensive validation (good) but in wrong place (should be in subagent)

**Critical Constraints** (lines 183-215):
```xml
<critical_constraints>
  <no_implementation>
    This command ONLY creates task entries. It MUST NOT:
    - Implement the task
    - Create any spec directories
    - Create any research files
    - Create any plan files
    - Create any code files
    - Delegate to any subagents
  </no_implementation>
  
  <no_delegation>
    This command operates entirely within the orchestrator.
    It MUST NOT delegate to ANY subagents including:
    - atomic-task-numberer (not needed - we read state.json directly)
    - status-sync-manager (not needed - simple file update)
    - Any other subagents
  </no_delegation>
</critical_constraints>
```

**Problem**: These constraints prevent the command from using proven patterns that ensure consistency.

---

## Root Cause Analysis

### Why /task Sometimes Implements Tasks

1. **No Enforcement Mechanism**: The command relies on documentation (`<critical_constraints>`) rather than architectural constraints
2. **Inline Execution**: All logic in command file means Claude can "skip ahead" if it misinterprets instructions
3. **No Subagent Boundary**: Without delegation, there's no clear handoff point that enforces "create only, don't implement"
4. **Manual State Updates**: Direct file manipulation is error-prone and lacks atomic guarantees

### Why /research and /implement Are Consistent

1. **Architectural Enforcement**: Delegation to subagents creates clear boundaries
2. **Subagent Specialization**: Researcher can only research, implementer can only implement
3. **Atomic Updates**: status-sync-manager ensures TODO.md and state.json stay in sync
4. **Clear Handoff**: Command parses, subagent executes - no ambiguity

---

## Proposed Solution

### Architecture Changes

#### 1. Create task-creator Subagent

**File**: `.opencode/agent/subagents/task-creator.md`

**Purpose**: Handle all task creation logic with architectural enforcement

**Responsibilities**:
- Read next_project_number from state.json
- Validate task description and metadata
- Create TODO.md entry with proper formatting
- Invoke status-sync-manager for atomic updates
- Return task number and confirmation

**Constraints** (enforced by subagent permissions):
```yaml
permissions:
  allow:
    - read: [".opencode/specs/state.json", ".opencode/specs/TODO.md"]
    - bash: ["date"]
  deny:
    - write: ["**/*.lean", "**/*.py", "**/*.sh"]  # Cannot create implementation files
    - bash: ["lake", "python", "lean"]  # Cannot run implementation tools
```

**Process Flow** (4 steps):
1. **ValidateInput**: Validate description, priority, effort, language
2. **AllocateNumber**: Read next_project_number from state.json
3. **CreateEntry**: Format TODO.md entry following task standards
4. **SyncState**: Invoke status-sync-manager for atomic TODO.md + state.json update

#### 2. Refactor /task Command

**File**: `.opencode/command/task.md`

**Target Size**: <150 lines (similar to /research and /implement)

**New Workflow** (2 stages):
1. **ParseAndValidate**: Parse description, extract flags, validate inputs
2. **Delegate**: Invoke task-creator subagent with parsed context

**New Structure**:
```yaml
---
name: task
agent: orchestrator
description: "Create new task in .opencode/specs/TODO.md (NO implementation)"
routing:
  default: task-creator
---
```

**Workflow**:
```xml
<workflow_execution>
  <stage id="1" name="ParseAndValidate">
    <action>Parse task description and validate inputs</action>
    <process>
      1. Parse task description from $ARGUMENTS
      2. Extract optional flags (--priority, --effort, --language)
      3. Detect language from description keywords if not provided
      4. Validate description is non-empty
      5. Validate priority is Low|Medium|High
      6. Validate effort format
      7. Validate language is valid (lean|markdown|general|python|shell|json|meta)
    </process>
    <checkpoint>Task description validated, metadata extracted</checkpoint>
  </stage>
  
  <stage id="2" name="Delegate">
    <action>Delegate to task-creator subagent</action>
    <process>
      1. Invoke task-creator via task tool:
         task(
           subagent_type="task-creator",
           prompt="Create task: ${description}. Priority: ${priority}. Effort: ${effort}. Language: ${language}.",
           description="Create task entry"
         )
      2. Wait for task-creator to complete
      3. Relay result to user
    </process>
    <checkpoint>Delegated to task-creator, result relayed</checkpoint>
  </stage>
</workflow_execution>
```

#### 3. Leverage status-sync-manager

**Current Problem**: `/task` manually updates state.json (lines 144-162)

**Solution**: Use status-sync-manager for atomic updates

**Benefits**:
- ✅ Atomic updates (TODO.md + state.json updated together or not at all)
- ✅ Consistent format (same update logic as /research, /implement)
- ✅ Validation (status-sync-manager validates all updates)
- ✅ Error handling (rollback on failure)

**Implementation**:
```javascript
// In task-creator subagent, step 4
invoke status-sync-manager with:
{
  task_number: allocated_number,
  new_status: "not_started",
  timestamp: current_date,
  session_id: session_id,
  delegation_depth: 2,
  delegation_path: ["orchestrator", "task", "task-creator", "status-sync-manager"],
  artifact_links: [],  // No artifacts for new tasks
  plan_metadata: null  // No plan yet
}
```

---

## Implementation Plan

### Phase 1: Create task-creator Subagent (4-6 hours)

**Tasks**:
1. Create `.opencode/agent/subagents/task-creator.md` following subagent-structure.md
2. Implement 4-step process flow (ValidateInput → AllocateNumber → CreateEntry → SyncState)
3. Add permission constraints to prevent implementation
4. Add validation for task standards (Language field mandatory, metadata format, etc.)
5. Add error handling for missing state.json, invalid TODO.md, etc.
6. Add unit tests (if testing framework exists)

**Acceptance Criteria**:
- [ ] task-creator.md follows subagent-structure.md standard
- [ ] Permissions prevent creating implementation files
- [ ] Validation enforces task standards (Language field, metadata format)
- [ ] Error messages are clear and actionable
- [ ] Invokes status-sync-manager for atomic updates
- [ ] Returns standardized format per subagent-return-format.md

**Files Created**:
- `.opencode/agent/subagents/task-creator.md`

### Phase 2: Refactor /task Command (3-4 hours)

**Tasks**:
1. Backup current `/task` command to `.opencode/backups/task-command-v1.md`
2. Reduce command file to 2-stage workflow (ParseAndValidate → Delegate)
3. Remove inline execution logic (stages 2-5)
4. Remove `<no_delegation>` constraint
5. Add routing to task-creator subagent
6. Update documentation to reflect new architecture
7. Reduce file size to <150 lines

**Acceptance Criteria**:
- [ ] Command file <150 lines (similar to /research and /implement)
- [ ] 2-stage workflow (ParseAndValidate → Delegate)
- [ ] Delegates to task-creator subagent
- [ ] No inline execution logic
- [ ] Documentation updated
- [ ] Backup created

**Files Modified**:
- `.opencode/command/task.md`

**Files Created**:
- `.opencode/backups/task-command-v1.md`

### Phase 3: Update Documentation (2-3 hours)

**Tasks**:
1. Update `.opencode/context/core/standards/tasks.md` to reference task-creator
2. Update `.opencode/context/core/workflows/command-lifecycle.md` to include /task
3. Add task-creator to `.opencode/AGENTS.md` registry
4. Update `.opencode/context/core/system/routing-guide.md` with /task routing
5. Create migration guide for users (if needed)

**Acceptance Criteria**:
- [ ] tasks.md references task-creator subagent
- [ ] command-lifecycle.md includes /task workflow
- [ ] AGENTS.md includes task-creator entry
- [ ] routing-guide.md includes /task routing rules
- [ ] Migration guide created (if breaking changes)

**Files Modified**:
- `.opencode/context/core/standards/tasks.md`
- `.opencode/context/core/workflows/command-lifecycle.md`
- `.opencode/AGENTS.md`
- `.opencode/context/core/system/routing-guide.md`

### Phase 4: Testing and Validation (3-4 hours)

**Tasks**:
1. Test task creation with various inputs:
   - Simple description: `/task "Fix bug in Foo.lean"`
   - With flags: `/task "Add feature X" --priority High --effort "4 hours"`
   - Language detection: `/task "Implement proof for theorem Y"` (should detect lean)
   - Edge cases: empty description, invalid priority, malformed effort
2. Verify TODO.md and state.json stay in sync
3. Verify task numbers are sequential and unique
4. Verify Language field is always set (mandatory per tasks.md)
5. Verify metadata format uses `- **Field**:` pattern
6. Verify no implementation occurs (no directories created, no files written)
7. Test error handling:
   - Missing state.json
   - Corrupt TODO.md
   - Invalid inputs
8. Compare behavior with /research and /implement for consistency

**Acceptance Criteria**:
- [ ] All test cases pass
- [ ] TODO.md and state.json stay in sync
- [ ] Task numbers are unique and sequential
- [ ] Language field always set
- [ ] Metadata format correct
- [ ] No implementation occurs
- [ ] Error handling works correctly
- [ ] Behavior consistent with /research and /implement

**Test Cases**:
1. Basic task creation
2. Task with custom priority
3. Task with custom effort
4. Task with explicit language
5. Task with language detection
6. Task with all flags
7. Empty description (should fail)
8. Invalid priority (should fail)
9. Missing state.json (should fail with clear error)
10. Concurrent task creation (should handle gracefully)

### Phase 5: Rollout and Monitoring (1-2 hours)

**Tasks**:
1. Create git commit with all changes
2. Update CHANGELOG.md (if exists)
3. Monitor first 10 task creations for issues
4. Collect feedback from users
5. Address any issues discovered

**Acceptance Criteria**:
- [ ] Git commit created with clear message
- [ ] CHANGELOG.md updated
- [ ] First 10 task creations successful
- [ ] No regressions reported
- [ ] Issues addressed promptly

---

## Estimated Effort

| Phase | Estimated Hours | Complexity |
|-------|----------------|------------|
| Phase 1: Create task-creator Subagent | 4-6 hours | Medium |
| Phase 2: Refactor /task Command | 3-4 hours | Low-Medium |
| Phase 3: Update Documentation | 2-3 hours | Low |
| Phase 4: Testing and Validation | 3-4 hours | Medium |
| Phase 5: Rollout and Monitoring | 1-2 hours | Low |
| **Total** | **13-19 hours** | **Medium** |

**Recommended Estimate**: 16 hours (middle of range)

---

## Risk Analysis

### High Risk

**Risk**: Breaking existing workflows that depend on /task command  
**Mitigation**: 
- Create backup of current command
- Test thoroughly before rollout
- Provide migration guide if needed
- Monitor first 10 uses closely

### Medium Risk

**Risk**: status-sync-manager may not handle task creation (designed for status updates)  
**Mitigation**:
- Review status-sync-manager capabilities
- Extend if needed to support task creation
- Alternative: Create dedicated task-sync-manager if status-sync-manager is insufficient

### Low Risk

**Risk**: task-creator subagent may be too restrictive  
**Mitigation**:
- Design permissions carefully
- Allow reading all necessary files
- Test edge cases thoroughly

---

## Success Criteria

### Functional Requirements

1. ✅ `/task` creates task entries in TODO.md and state.json
2. ✅ `/task` NEVER implements tasks
3. ✅ Task numbers are unique and sequential
4. ✅ TODO.md and state.json stay in sync
5. ✅ Language field is always set (mandatory)
6. ✅ Metadata format is correct (`- **Field**:` pattern)
7. ✅ Error handling is clear and actionable

### Non-Functional Requirements

1. ✅ Command file <150 lines (consistency with /research and /implement)
2. ✅ 2-stage workflow (ParseAndValidate → Delegate)
3. ✅ Atomic updates (via status-sync-manager)
4. ✅ Clear separation of concerns (command parses, subagent executes)
5. ✅ Architectural enforcement (permissions prevent implementation)

### Quality Requirements

1. ✅ Follows subagent-structure.md standard
2. ✅ Follows task standards (tasks.md)
3. ✅ Follows delegation standards (delegation.md)
4. ✅ No emojis (per documentation.md)
5. ✅ Clear documentation
6. ✅ Comprehensive error handling

---

## Comparison: Before vs. After

### Before (Current State)

```
/task "Implement feature X"
  ↓
orchestrator loads task.md (381 lines)
  ↓
5-stage inline workflow:
  1. ParseInput (validate description, extract flags)
  2. ReadNextNumber (read state.json)
  3. CreateTODOEntry (manual TODO.md update)
  4. UpdateStateJson (manual state.json update)
  5. ReturnSuccess (return task number)
  ↓
❌ Sometimes skips to implementation (no enforcement)
❌ Manual updates (no atomic guarantees)
❌ Large command file (hard to maintain)
```

### After (Proposed State)

```
/task "Implement feature X"
  ↓
orchestrator loads task.md (<150 lines)
  ↓
2-stage workflow:
  1. ParseAndValidate (validate inputs)
  2. Delegate to task-creator subagent
     ↓
     task-creator (4-step process):
       1. ValidateInput (enforce task standards)
       2. AllocateNumber (read state.json)
       3. CreateEntry (format TODO.md entry)
       4. SyncState (invoke status-sync-manager)
          ↓
          status-sync-manager (atomic update):
            - Update TODO.md
            - Update state.json
            - Rollback on failure
  ↓
✅ Architectural enforcement (permissions prevent implementation)
✅ Atomic updates (via status-sync-manager)
✅ Small command file (easy to maintain)
✅ Consistent with /research and /implement patterns
```

---

## Alternative Approaches Considered

### Alternative 1: Keep Inline Execution, Add Validation

**Approach**: Keep current 5-stage workflow but add stricter validation

**Pros**:
- Minimal changes to existing code
- No new subagent needed

**Cons**:
- ❌ Doesn't address root cause (no architectural enforcement)
- ❌ Still relies on documentation rather than constraints
- ❌ Doesn't leverage proven patterns from /research and /implement
- ❌ Maintains large command file (hard to maintain)

**Decision**: Rejected - doesn't solve the fundamental problem

### Alternative 2: Use atomic-task-numberer Instead of task-creator

**Approach**: Extend atomic-task-numberer to handle task creation

**Pros**:
- Reuses existing subagent
- No new subagent needed

**Cons**:
- ❌ atomic-task-numberer is designed for number allocation only (single responsibility)
- ❌ Would violate separation of concerns
- ❌ Would make atomic-task-numberer too complex

**Decision**: Rejected - violates single responsibility principle

### Alternative 3: Extend status-sync-manager to Handle Task Creation

**Approach**: Add task creation logic to status-sync-manager

**Pros**:
- Reuses existing atomic update infrastructure
- No new subagent needed

**Cons**:
- ❌ status-sync-manager is designed for status updates, not task creation
- ❌ Would violate separation of concerns
- ❌ Would make status-sync-manager too complex

**Decision**: Rejected - violates single responsibility principle

---

## Recommended Approach

**Create task-creator subagent** (Proposed Solution)

**Rationale**:
1. ✅ Follows proven patterns from /research and /implement
2. ✅ Architectural enforcement via permissions
3. ✅ Clear separation of concerns
4. ✅ Leverages existing status-sync-manager for atomic updates
5. ✅ Reduces command file size to <150 lines
6. ✅ Single responsibility (task creation only)
7. ✅ Consistent with existing architecture

---

## Next Steps

1. **Review this plan** with stakeholders
2. **Approve or request changes**
3. **Create task in TODO.md** for implementation (using current /task command)
4. **Execute Phase 1** (Create task-creator subagent)
5. **Execute Phase 2** (Refactor /task command)
6. **Execute Phase 3** (Update documentation)
7. **Execute Phase 4** (Testing and validation)
8. **Execute Phase 5** (Rollout and monitoring)

---

## Appendix A: Key Patterns from /research and /implement

### Pattern 1: 2-Stage Workflow

Both `/research` and `/implement` use a clean 2-stage workflow:

1. **ParseAndValidate**: Parse arguments, lookup task in state.json, extract metadata
2. **Delegate**: Invoke specialized subagent with parsed context

This pattern ensures:
- Clear separation of concerns (command parses, subagent executes)
- Minimal command file size (<150 lines)
- Consistent behavior (subagent enforces constraints)

### Pattern 2: State.json as Source of Truth

Both commands use state.json for metadata lookup (8x faster than TODO.md parsing):

```bash
task_data=$(jq -r --arg num "$task_number" \
  '.active_projects[] | select(.project_number == ($num | tonumber))' \
  .opencode/specs/state.json)
```

This pattern ensures:
- Fast lookups (no TODO.md parsing)
- Consistent metadata (single source of truth)
- Atomic updates (via status-sync-manager)

### Pattern 3: Language-Based Routing

Both commands route to specialized subagents based on task language:

```yaml
routing:
  language_based: true
  lean: lean-research-agent  # or lean-implementation-agent
  default: researcher        # or implementer
```

This pattern ensures:
- Specialized handling (Lean tasks use Lean-specific tools)
- Consistent behavior (same routing logic across commands)
- Extensibility (easy to add new language-specific agents)

### Pattern 4: Subagent Handles Status Updates

Both commands delegate status updates to subagents, which invoke status-sync-manager:

```
/research 197
  ↓
researcher subagent
  ↓
status-sync-manager (atomic update):
  - Update TODO.md status to [RESEARCHING] (preflight)
  - Update state.json status to "researching"
  - Create research report
  - Update TODO.md status to [RESEARCHED] (postflight)
  - Update state.json status to "researched"
  - Add artifact links
```

This pattern ensures:
- Atomic updates (TODO.md + state.json updated together)
- Consistent format (same update logic across commands)
- Error handling (rollback on failure)

---

## Appendix B: task-creator Subagent Specification

### Frontmatter

```yaml
---
name: "task-creator"
version: "1.0.0"
description: "Create new tasks in .opencode/specs/TODO.md with atomic state updates"
mode: subagent
agent_type: utility
temperature: 0.1
max_tokens: 1000
timeout: 120
tools:
  read: true
  bash: true
permissions:
  allow:
    - read: [".opencode/specs/state.json", ".opencode/specs/TODO.md"]
    - bash: ["date"]
  deny:
    - write: ["**/*.lean", "**/*.py", "**/*.sh"]  # Cannot create implementation files
    - bash: ["lake", "python", "lean"]  # Cannot run implementation tools
context_loading:
  strategy: lazy
  index: ".opencode/context/index.md"
  required:
    - "core/standards/tasks.md"
    - "core/system/state-management.md"
  max_context_size: 20000
delegation:
  max_depth: 3
  can_delegate_to: ["status-sync-manager"]
  timeout_default: 120
  timeout_max: 120
lifecycle:
  stage: 2
  command: "/task"
  return_format: "subagent-return-format.md"
---
```

### Process Flow

```xml
<process_flow>
  <step_0_preflight>
    <action>Validate inputs and prepare for task creation</action>
    <process>
      1. Validate required inputs:
         - description (non-empty string)
         - priority (Low|Medium|High)
         - effort (TBD or time estimate)
         - language (lean|markdown|general|python|shell|json|meta)
      2. Validate state.json exists and is readable
      3. Validate TODO.md exists and is readable
      4. If validation fails: abort with clear error message
    </process>
    <checkpoint>Inputs validated, files accessible</checkpoint>
  </step_0_preflight>

  <step_1_allocate_number>
    <action>Read next_project_number from state.json</action>
    <process>
      1. Read .opencode/specs/state.json
      2. Extract next_project_number field
      3. Validate it's a number >= 0
      4. Store for use in task creation
    </process>
    <checkpoint>Task number allocated</checkpoint>
  </step_1_allocate_number>

  <step_2_create_entry>
    <action>Format TODO.md entry following task standards</action>
    <process>
      1. Format task entry:
         ```
         ### {number}. {description}
         - **Effort**: {effort}
         - **Status**: [NOT STARTED]
         - **Priority**: {priority}
         - **Language**: {language}
         - **Blocking**: None
         - **Dependencies**: None
         ```
      2. Validate format follows tasks.md standard:
         - Language field present (MANDATORY)
         - Metadata format uses `- **Field**:` pattern
         - All required fields present
      3. Determine correct section based on priority
      4. Prepare entry for status-sync-manager
    </process>
    <checkpoint>TODO.md entry formatted and validated</checkpoint>
  </step_2_create_entry>

  <step_3_sync_state>
    <action>Invoke status-sync-manager for atomic update</action>
    <process>
      1. Invoke status-sync-manager with:
         {
           task_number: allocated_number,
           new_status: "not_started",
           timestamp: current_date,
           session_id: session_id,
           delegation_depth: 2,
           delegation_path: ["orchestrator", "task", "task-creator", "status-sync-manager"],
           artifact_links: [],
           plan_metadata: null,
           todo_entry: formatted_entry,
           priority_section: priority
         }
      2. Wait for status-sync-manager to complete
      3. Verify atomic update succeeded
      4. If failed: return error with rollback information
    </process>
    <checkpoint>TODO.md and state.json updated atomically</checkpoint>
  </step_3_sync_state>

  <step_4_return>
    <action>Return standardized result</action>
    <process>
      1. Format return following subagent-return-format.md:
         {
           "status": "completed",
           "summary": "Task {number} created: {description}",
           "artifacts": [],
           "metadata": {
             "session_id": "{session_id}",
             "duration_seconds": {duration},
             "agent_type": "task-creator",
             "delegation_depth": 2,
             "delegation_path": ["orchestrator", "task", "task-creator"]
           },
           "errors": [],
           "next_steps": "Use /research {number} to research this task. Use /plan {number} to create implementation plan. Use /implement {number} to implement the task.",
           "task_number": {number},
           "task_details": {
             "description": "{description}",
             "priority": "{priority}",
             "effort": "{effort}",
             "language": "{language}",
             "status": "[NOT STARTED]"
           }
         }
      2. Include session_id from input
      3. Include metadata (duration, agent_type, delegation info)
      4. Return status "completed"
    </process>
    <checkpoint>Result returned to user</checkpoint>
  </step_4_return>
</process_flow>
```

### Constraints

```xml
<constraints>
  <must>Always validate Language field is set (MANDATORY per tasks.md)</must>
  <must>Always validate metadata format uses `- **Field**:` pattern</must>
  <must>Always validate all required fields present</must>
  <must>Always use status-sync-manager for atomic updates</must>
  <must>Always return standardized format per subagent-return-format.md</must>
  <must>Complete within 120 seconds</must>
  <must_not>Create any implementation files (*.lean, *.py, *.sh)</must_not>
  <must_not>Run any implementation tools (lake, python, lean)</must_not>
  <must_not>Implement the task</must_not>
  <must_not>Create any spec directories</must_not>
  <must_not>Create any research files</must_not>
  <must_not>Create any plan files</must_not>
</constraints>
```

---

## Appendix C: Migration Guide

### For Users

**No breaking changes expected**. The `/task` command will continue to work the same way:

```bash
# Before
/task "Implement feature X"

# After (same syntax)
/task "Implement feature X"
```

**New features**:
- ✅ Guaranteed consistency (task always created, never implemented)
- ✅ Atomic updates (TODO.md and state.json always in sync)
- ✅ Better error messages (clear guidance on what went wrong)

### For Developers

**Breaking changes**:
- `/task` command file reduced from 381 lines to <150 lines
- Inline execution logic removed (moved to task-creator subagent)
- Manual state.json updates replaced with status-sync-manager

**Migration steps**:
1. Review new task-creator subagent specification
2. Update any scripts that depend on /task command internals
3. Test task creation workflows thoroughly
4. Update documentation to reference task-creator

---

## Conclusion

This plan proposes refactoring the `/task` command to follow the proven patterns from `/research` and `/implement` commands. By creating a dedicated `task-creator` subagent and leveraging the existing `status-sync-manager`, we can ensure consistent behavior, atomic updates, and architectural enforcement that prevents the command from implementing tasks.

The estimated effort is 13-19 hours (recommended: 16 hours) with medium complexity. The benefits include:

1. ✅ Consistent behavior (task always created, never implemented)
2. ✅ Atomic updates (TODO.md and state.json always in sync)
3. ✅ Architectural enforcement (permissions prevent implementation)
4. ✅ Reduced command file size (<150 lines, easier to maintain)
5. ✅ Alignment with existing patterns (/research and /implement)
6. ✅ Better error handling (clear, actionable messages)

**Recommendation**: Proceed with implementation following the 5-phase plan outlined above.
