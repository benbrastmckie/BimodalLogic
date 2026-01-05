# Command Argument Parsing Refactor - Implementation Plan

**Project**: ProofChecker Command System Simplification
**Created**: 2026-01-04
**Status**: DRAFT - Ready for Review

## Executive Summary

The ProofChecker `.opencode/` system has accumulated significant complexity through successive refactors, particularly in how the orchestrator and subagents handle command arguments. The current implementation has multiple layers of parsing, validation, and formatting that create fragility and confusion. This plan proposes a comprehensive simplification modeled after the cleaner OpenAgents system.

## Problem Analysis

### Current Issues

#### 1. **Orchestrator Over-Engineering**
**Location**: `.opencode/agent/orchestrator.md` Stage 1 & Stage 3

**Problems**:
- **Dual parsing**: Arguments parsed in Stage 1, then re-formatted in Stage 3
- **Complex state management**: `task_number` extracted in Stage 1 must be preserved for Stage 3
- **Fragile prompt formatting**: Stage 3 reformats as "Task: {number}" instead of passing original
- **Verbose validation**: 180+ lines of argument handling logic in orchestrator
- **JSON format enforcement**: Appending JSON_FORMAT_INSTRUCTION to every delegation

**Example of Current Complexity**:
```markdown
Stage 1: Parse $ARGUMENTS → extract task_number = "271"
Stage 3: Format prompt = "Task: 271" + JSON_FORMAT_INSTRUCTION
```

**Why This Is Problematic**:
- If Stage 1 fails to extract task_number, Stage 3 fails silently
- Subagents receive "Task: 271" instead of original "271" or "/implement 271"
- Subagents must re-parse "Task: 271" to extract "271"
- Triple parsing: Orchestrator Stage 1 → Orchestrator Stage 3 → Subagent Step 0

#### 2. **Subagent Redundant Parsing**
**Location**: `researcher.md`, `implementer.md`, `planner.md` Step 0

**Problems**:
- **Re-parsing already parsed data**: Subagents parse task_number from prompt string even though orchestrator already parsed it
- **Multiple format support**: Must handle "/research 267", "267", "Task: 267", "research 267"
- **Regex complexity**: Complex parsing logic duplicated across all subagents
- **Validation duplication**: Task existence checked in orchestrator AND subagent

**Example from researcher.md Step 0**:
```markdown
1. Parse task_number from delegation context or prompt string:
   a. Check if task_number parameter provided in delegation context
   b. If not provided, parse from prompt string:
      - Extract first numeric argument from prompt (e.g., "267" from "/research 267")
      - Support formats: "/research 267", "267", "Task: 267", "research 267"
      - Use regex or string parsing to extract task number
```

**Why This Is Problematic**:
- Orchestrator already validated task_number in Stage 1
- Subagent re-validates in Step 0
- If formats diverge, parsing fails
- Maintenance burden: Update parsing logic in 4+ places

#### 3. **Command File Complexity**
**Location**: `.opencode/command/research.md`, `implement.md`, etc.

**Problems**:
- **Verbose documentation**: 160+ lines per command file
- **Routing logic in command**: Language-based routing duplicated in command and orchestrator
- **Artifact validation**: Phantom research prevention logic in command file
- **Workflow stages**: 5-stage workflow defined in command, executed by orchestrator

**Example**:
```markdown
**Orchestrator handles (Stage 1-5):**
- Stage 1 (PreflightValidation): Read task number from $ARGUMENTS variable...
- Stage 2 (DetermineRouting): Extract language from task entry...
- Stage 3 (RegisterAndDelegate): Register session and invoke target agent
- Stage 4 (ValidateReturn): Validate return format...
- Stage 5 (PostflightCleanup): Update session registry...
```

**Why This Is Problematic**:
- Command files should be simple routing metadata
- Workflow logic belongs in orchestrator or subagent
- Duplication between command file and orchestrator
- Hard to maintain consistency

#### 4. **Context File Overhead**
**Location**: `.opencode/context/core/standards/command-argument-handling.md`

**Problems**:
- **444 lines** of argument handling documentation
- **Over-specified**: Covers edge cases that don't exist in practice
- **Contradictory**: Says to use $ARGUMENTS but orchestrator reformats it
- **Maintenance burden**: Must update when adding new command patterns

### Root Cause Analysis

The complexity stems from **over-abstraction** and **premature optimization**:

1. **Orchestrator as Universal Router**: Trying to handle all command types with one complex workflow
2. **Defensive Programming**: Multiple validation layers "just in case"
3. **Incomplete Refactors**: Old patterns not fully removed when new ones added
4. **Documentation Drift**: Standards don't match implementation

### Comparison with OpenAgents System

The OpenAgents system demonstrates a simpler, more maintainable approach:

#### OpenAgents Command File (research.md)
```markdown
---
description: Conduct research and generate structured research reports
agent: subagents/specs/research-agent
---

# /research - Research Command

Conduct comprehensive research on a specified topic and generate a structured 
research report in `.opencode/specs/`.

## Usage

```bash
/research "{topic or question}"
```
```

**Key Differences**:
- **15 lines** vs 162 lines
- **No workflow stages** in command file
- **Simple routing**: Just specifies target agent
- **No argument parsing logic**: Subagent handles it

#### OpenAgents Orchestrator
```markdown
## Role
You are the main orchestrator for the OpenAgents project. Your primary 
responsibility is to analyze user requests and delegate them to the 
appropriate subsystem orchestrator.

## Workflow
1. **Analyze Request**: If the request contains keywords like "Lean 4"...
2. **Execute**: Call the appropriate orchestrator.
3. **Review**: Return the result to the user.
```

**Key Differences**:
- **15 lines** vs 300+ lines
- **Simple delegation**: No complex argument parsing
- **Trust subagents**: Subagents handle their own validation
- **No state management**: Stateless routing

#### OpenAgents Subagent (research-agent.md)
```markdown
<stage id="1" name="InitializeProject">
  <action>Determine project context and initialize if needed</action>
  <process>
    1. Check if .opencode/specs/ exists, create if not
    2. Load .opencode/specs/state.json (or create initial state)
    3. Determine if this is new project or existing project:
       - Parse research topic to extract project name
```

**Key Differences**:
- **Subagent owns workflow**: No orchestrator micromanagement
- **Direct argument access**: Receives user's original prompt
- **Self-contained**: All logic in one place
- **Simpler validation**: Trust orchestrator did basic routing

## Proposed Solution

### Design Principles

1. **Simplicity Over Completeness**: Handle 95% of cases simply, not 100% of cases complexly
2. **Single Responsibility**: Each component does one thing well
3. **Trust Boundaries**: Orchestrator routes, subagents execute
4. **Minimal State**: Avoid passing parsed data through multiple layers
5. **Direct Communication**: Pass user's original prompt to subagents

### Architecture Changes

#### 1. Simplified Orchestrator

**New Workflow** (3 stages instead of 5):

```markdown
<workflow_execution>
  <stage id="1" name="LoadAndValidate">
    <action>Load command file and validate basic routing</action>
    <process>
      1. Extract command name from invocation
      2. Load command file: .opencode/command/{command}.md
      3. Parse frontmatter (YAML)
      4. Extract target agent from frontmatter
      5. Validate agent file exists
      6. Generate session_id
    </process>
    <checkpoint>Command loaded, agent identified, session created</checkpoint>
  </stage>

  <stage id="2" name="Delegate">
    <action>Invoke target agent with original prompt</action>
    <process>
      1. Prepare delegation context:
         - session_id
         - delegation_depth: 1
         - delegation_path: ["orchestrator", "{agent}"]
         - timeout: {from frontmatter or default}
      
      2. Invoke agent via task tool:
         task(
           subagent_type="{agent}",
           prompt="{original_user_prompt}",  # PASS ORIGINAL PROMPT
           session_id=session_id,
           ...
         )
      
      3. Wait for agent return
    </process>
    <checkpoint>Agent invoked with original user prompt</checkpoint>
  </stage>

  <stage id="3" name="ValidateAndRelay">
    <action>Validate agent return and relay to user</action>
    <process>
      1. Validate return is valid JSON (if expected)
      2. Check status field exists
      3. Relay result to user
      4. Update session registry
    </process>
    <checkpoint>Result validated and returned to user</checkpoint>
  </stage>
</workflow_execution>
```

**Key Changes**:
- **No argument parsing**: Pass original prompt to subagent
- **No task number extraction**: Subagent handles it
- **No prompt reformatting**: Subagent receives "/research 271" not "Task: 271"
- **No JSON format enforcement**: Subagent knows its return format
- **90% reduction in complexity**: 300+ lines → 30 lines

#### 2. Simplified Command Files

**New Structure**:

```markdown
---
name: research
agent: researcher
description: "Conduct research and create reports with [RESEARCHED] status"
timeout: 3600
routing:
  language_based: true
  lean: lean-research-agent
  default: researcher
---

# /research - Research Command

Conduct research for tasks and create research reports with [RESEARCHED] status.

## Usage

```bash
/research TASK_NUMBER [PROMPT]
/research 197
/research 197 "Focus on CLI integration"
```

## What This Does

1. Routes to appropriate research agent based on task language
2. Agent conducts research using specialized tools
3. Creates research report in `.opencode/specs/{task}_*/reports/`
4. Updates task status to [RESEARCHED]
5. Creates git commit

## Language-Based Routing

| Language | Agent | Tools |
|----------|-------|-------|
| lean | lean-research-agent | LeanExplore, Loogle, LeanSearch |
| general | researcher | Web search, documentation |

See `.opencode/agent/subagents/researcher.md` for details.
```

**Key Changes**:
- **Remove workflow stages**: Orchestrator doesn't need them
- **Remove argument parsing docs**: Subagent handles it
- **Remove validation logic**: Subagent handles it
- **Keep routing metadata**: Orchestrator needs this
- **160 lines → 40 lines**

#### 3. Simplified Subagents

**New Step 0 (Preflight)**:

```markdown
<step_0_preflight>
  <action>Parse arguments and validate task</action>
  <process>
    1. Parse task number from prompt:
       - Prompt format: "/research 271" or "271" or "/research 271 extra args"
       - Extract first integer: task_number = 271
       - Extract remaining text: optional_prompt = "extra args"
    
    2. Validate task exists:
       - Read .opencode/specs/TODO.md
       - Find task entry: grep "^### ${task_number}\."
       - If not found: Return error
    
    3. Update status to [RESEARCHING]:
       - Delegate to status-sync-manager
       - Validate status update succeeded
    
    4. Proceed to research
  </process>
  <checkpoint>Task validated, status updated</checkpoint>
</step_0_preflight>
```

**Key Changes**:
- **Simple parsing**: Extract first integer from prompt
- **No format support matrix**: Just handle actual formats received
- **Direct validation**: Check task exists, update status
- **No delegation context parsing**: Orchestrator provides clean prompt
- **100 lines → 20 lines**

#### 4. Eliminate Context File

**Action**: Delete `.opencode/context/core/standards/command-argument-handling.md`

**Rationale**:
- 444 lines of documentation for simple pattern
- Over-specified edge cases
- Contradicts actual implementation
- Maintenance burden

**Replacement**: Add simple section to orchestrator.md:

```markdown
## Argument Handling

Commands receive user's original prompt unchanged.

Examples:
- User types: `/research 271`
- Subagent receives: "/research 271"

- User types: `/implement 196 "Focus on error handling"`
- Subagent receives: "/implement 196 \"Focus on error handling\""

Subagents parse arguments as needed for their specific use case.
```

### Implementation Phases

#### Phase 1: Simplify Orchestrator (2-3 hours)

**Tasks**:
1. Create backup: `cp orchestrator.md orchestrator.md.backup`
2. Rewrite Stage 1: Remove argument parsing, keep command loading
3. Rewrite Stage 3: Pass original prompt, remove reformatting
4. Remove Stage 2 (routing logic moves to command frontmatter)
5. Remove JSON_FORMAT_INSTRUCTION appending
6. Test with `/plan 196` (working command)
7. Verify plan command still works

**Validation**:
- [ ] `/plan 196` works
- [ ] Orchestrator passes "/plan 196" to planner-agent
- [ ] No argument parsing in orchestrator
- [ ] No prompt reformatting

**Estimated Effort**: 2 hours

#### Phase 2: Simplify Command Files (1-2 hours)

**Tasks**:
1. Simplify `/research` command:
   - Remove workflow stages
   - Remove argument parsing docs
   - Keep routing metadata
   - Test: `/research 197`

2. Simplify `/implement` command:
   - Remove workflow stages
   - Remove argument parsing docs
   - Keep routing metadata
   - Test: `/implement 196`

3. Simplify `/revise` command:
   - Remove workflow stages
   - Remove argument parsing docs
   - Keep routing metadata
   - Test: `/revise 196`

4. Keep `/plan` command as-is (already working)

**Validation**:
- [ ] All commands under 50 lines
- [ ] No workflow stages in command files
- [ ] Routing metadata preserved
- [ ] Commands still work

**Estimated Effort**: 1.5 hours

#### Phase 3: Simplify Subagents (3-4 hours)

**Tasks**:
1. Simplify `researcher.md` Step 0:
   - Remove delegation context parsing
   - Simplify prompt parsing (extract first integer)
   - Remove format support matrix
   - Test: `/research 197`

2. Simplify `implementer.md` Step 0:
   - Remove delegation context parsing
   - Simplify prompt parsing
   - Remove format support matrix
   - Test: `/implement 196`

3. Simplify `planner.md` Step 0:
   - Already simple, verify compatibility
   - Test: `/plan 196`

4. Update `lean-research-agent.md` Step 0:
   - Match researcher.md simplifications
   - Test: `/research {lean_task}`

5. Update `lean-implementation-agent.md` Step 0:
   - Match implementer.md simplifications
   - Test: `/implement {lean_task}`

**Validation**:
- [ ] All subagents parse arguments directly from prompt
- [ ] No delegation context argument parsing
- [ ] Step 0 under 30 lines per subagent
- [ ] All commands work end-to-end

**Estimated Effort**: 3 hours

#### Phase 4: Update Documentation (1 hour)

**Tasks**:
1. Delete `command-argument-handling.md`
2. Add simple argument section to orchestrator.md
3. Update routing-guide.md to reflect simplified orchestrator
4. Update delegation.md to remove argument passing complexity
5. Create migration guide for future command additions

**Validation**:
- [ ] No contradictory documentation
- [ ] Clear guidance for adding new commands
- [ ] Examples match actual implementation

**Estimated Effort**: 1 hour

#### Phase 5: Testing & Validation (2 hours)

**Test Matrix**:

| Command | Test Case | Expected Result |
|---------|-----------|-----------------|
| `/plan 196` | Simple task number | Plan created |
| `/plan 196 "custom prompt"` | With optional prompt | Plan created with prompt |
| `/research 197` | Simple task number | Research report created |
| `/research 197 "focus area"` | With focus | Research with focus |
| `/implement 196` | Simple task number | Implementation executed |
| `/implement 196 "custom"` | With custom prompt | Implementation with prompt |
| `/revise 196` | Simple task number | Revised plan created |
| `/revise 196 "reason"` | With reason | Revision with reason |

**Edge Cases**:

| Test Case | Expected Behavior |
|-----------|-------------------|
| `/research` (no args) | Error: "Task number required" |
| `/research abc` (invalid) | Error: "Task number must be integer" |
| `/research 999999` (not found) | Error: "Task 999999 not found" |
| `/implement 105-107` (range) | Batch implementation |

**Validation**:
- [ ] All test cases pass
- [ ] Error messages clear and helpful
- [ ] No regressions in working commands
- [ ] Performance improved (fewer parsing steps)

**Estimated Effort**: 2 hours

### Migration Strategy

#### Backward Compatibility

**Not Required**: This is an internal refactor of the .opencode system. No external APIs or user-facing changes beyond improved reliability.

#### Rollback Plan

1. **Backup before starting**:
   ```bash
   cp -r .opencode .opencode.backup.$(date +%Y%m%d_%H%M%S)
   ```

2. **Git commits per phase**:
   - Phase 1: "Simplify orchestrator argument handling"
   - Phase 2: "Simplify command files"
   - Phase 3: "Simplify subagent argument parsing"
   - Phase 4: "Update documentation"
   - Phase 5: "Add comprehensive tests"

3. **Rollback procedure**:
   ```bash
   git revert HEAD~5..HEAD  # Revert all 5 phases
   # OR
   cp -r .opencode.backup.TIMESTAMP .opencode  # Restore backup
   ```

#### Testing Strategy

1. **Test after each phase**: Don't proceed to next phase until current phase validated
2. **Keep `/plan` working**: Use as regression test (it already works)
3. **Test both simple and complex cases**: Single task, task with prompt, ranges
4. **Test error cases**: Missing args, invalid args, task not found

### Success Criteria

#### Quantitative Metrics

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| Orchestrator lines | 300+ | ~50 | 83% reduction |
| Command file lines (avg) | 160 | ~40 | 75% reduction |
| Subagent Step 0 lines (avg) | 100 | ~20 | 80% reduction |
| Context file lines | 444 | 0 | 100% reduction |
| Total argument handling code | ~1500 | ~200 | 87% reduction |
| Parsing steps per command | 3 | 1 | 67% reduction |

#### Qualitative Metrics

- [ ] **Maintainability**: Adding new command takes <30 minutes
- [ ] **Clarity**: New developer understands flow in <10 minutes
- [ ] **Reliability**: No argument parsing failures in testing
- [ ] **Consistency**: All commands follow same pattern
- [ ] **Documentation**: Docs match implementation exactly

### Risk Analysis

#### High Risk: Breaking Working Commands

**Mitigation**:
- Test `/plan` after each phase (known working command)
- Comprehensive test matrix in Phase 5
- Git commits per phase for easy rollback
- Backup before starting

**Contingency**: Rollback to backup if any command breaks

#### Medium Risk: Subagent Compatibility

**Mitigation**:
- Update all subagents in same phase
- Test each subagent individually
- Verify delegation still works

**Contingency**: Revert subagent changes, keep orchestrator simple

#### Low Risk: Documentation Drift

**Mitigation**:
- Delete contradictory docs
- Keep docs minimal and accurate
- Add examples that match implementation

**Contingency**: Restore old docs if needed

### Post-Implementation

#### Monitoring

1. **Track command success rate**: Should be 100% for valid inputs
2. **Monitor error messages**: Should be clear and actionable
3. **Measure time to add new command**: Should be <30 minutes

#### Future Enhancements

1. **Command templates**: Create template for new commands
2. **Automated testing**: Add eval framework tests for commands
3. **Performance optimization**: Profile if needed (likely not necessary)

### Comparison: Before vs After

#### Before: `/research 271` Flow

```
User: /research 271
  ↓
Orchestrator Stage 1:
  - Parse $ARGUMENTS = "271"
  - Extract task_number = "271"
  - Validate is integer
  - Store task_number for Stage 3
  ↓
Orchestrator Stage 2:
  - Extract language from state.json
  - Map language to agent
  - Validate routing
  ↓
Orchestrator Stage 3:
  - Retrieve task_number from Stage 1
  - Format prompt = "Task: 271"
  - Append JSON_FORMAT_INSTRUCTION
  - Invoke researcher with "Task: 271\n\nCRITICAL RETURN FORMAT..."
  ↓
Researcher Step 0:
  - Parse "Task: 271" to extract "271"
  - Support formats: "/research 271", "271", "Task: 271"
  - Validate task_number is integer
  - Check task exists in TODO.md
  - Update status to [RESEARCHING]
  ↓
Researcher Step 1-6:
  - Execute research
  ↓
Orchestrator Stage 4:
  - Validate JSON return
  - Verify artifacts exist
  ↓
Orchestrator Stage 5:
  - Update session registry
  - Relay to user
```

**Total Steps**: 15+
**Parsing Steps**: 3 (Orchestrator Stage 1, Orchestrator Stage 3, Researcher Step 0)
**Lines of Code**: ~500

#### After: `/research 271` Flow

```
User: /research 271
  ↓
Orchestrator Stage 1:
  - Load command file
  - Extract agent = "researcher"
  - Generate session_id
  ↓
Orchestrator Stage 2:
  - Invoke researcher with "/research 271"
  ↓
Researcher Step 0:
  - Parse "/research 271" → task_number = 271
  - Check task exists
  - Update status to [RESEARCHING]
  ↓
Researcher Step 1-6:
  - Execute research
  ↓
Orchestrator Stage 3:
  - Validate return
  - Relay to user
```

**Total Steps**: 6
**Parsing Steps**: 1 (Researcher Step 0)
**Lines of Code**: ~100

**Improvement**: 60% fewer steps, 67% fewer parsing operations, 80% less code

## Conclusion

This refactor will dramatically simplify the ProofChecker command system by:

1. **Removing unnecessary complexity**: 87% reduction in argument handling code
2. **Eliminating redundant parsing**: 3 parsing steps → 1 parsing step
3. **Improving maintainability**: Clear, simple flow matching OpenAgents pattern
4. **Reducing fragility**: Fewer moving parts, fewer failure points
5. **Better documentation**: Docs match implementation exactly

The OpenAgents system demonstrates this simpler approach works well in practice. By adopting the same patterns, ProofChecker will be more maintainable, reliable, and easier to extend.

**Recommendation**: Proceed with implementation in phases, testing thoroughly after each phase.

---

## Appendix A: Code Examples

### Example 1: Simplified Orchestrator Stage 1

**Before** (60+ lines):
```markdown
<stage id="1" name="PreflightValidation">
  <process>
    Step 1: Determine command type
    - Extract command name from invocation
    - Check if command is in TASK-BASED COMMANDS list
    - Set command_type = "task-based" or "direct"
    
    Step 2: Parse and validate arguments (CRITICAL STEP - DO NOT SKIP)
    - IF command_type == "task-based":
      a. Check if $ARGUMENTS is empty
      b. Extract first token from $ARGUMENTS
      c. Validate task_number is positive integer
      d. Store task_number for Stage 3
    
    [... 50 more lines ...]
  </process>
</stage>
```

**After** (10 lines):
```markdown
<stage id="1" name="LoadAndValidate">
  <process>
    1. Extract command name from invocation
    2. Load .opencode/command/{command}.md
    3. Parse YAML frontmatter
    4. Extract agent field
    5. Validate agent file exists
    6. Generate session_id
  </process>
</stage>
```

### Example 2: Simplified Orchestrator Stage 3

**Before** (80+ lines):
```markdown
<stage id="3" name="RegisterAndDelegate">
  <process>
    PRE-STAGE VALIDATION:
    - Verify delegation_context exists
    - Verify command_type is set
    - IF command_type == "task-based":
      * Verify task_number was extracted in Stage 1
      * If missing: ABORT
    
    1. Register delegation in session registry
    
    2. Format prompt for subagent (CRITICAL STEP):
       FOR TASK-BASED COMMANDS:
       - Use task_number from Stage 1
       - Format as "Task: {task_number}"
       - DO NOT use $ARGUMENTS directly
       
       FOR DIRECT COMMANDS:
       - Pass $ARGUMENTS as-is
    
    3. Invoke target agent:
       CRITICAL JSON FORMAT ENFORCEMENT:
       Append JSON_FORMAT_INSTRUCTION to ensure compliance
       
       [... 50 more lines ...]
  </process>
</stage>
```

**After** (8 lines):
```markdown
<stage id="2" name="Delegate">
  <process>
    1. Prepare delegation context (session_id, depth, path, timeout)
    2. Invoke agent via task tool with original user prompt
    3. Wait for agent return
  </process>
</stage>
```

### Example 3: Simplified Subagent Step 0

**Before** (100+ lines):
```markdown
<step_0_preflight>
  <process>
    1. Parse task_number from delegation context or prompt string:
       a. Check if task_number parameter provided
       b. If not provided, parse from prompt string:
          - Extract first numeric argument
          - Support formats: "/research 267", "267", "Task: 267", "research 267"
          - Use regex or string parsing
       c. Validate task_number is positive integer
       d. If invalid: Return failed status
    
    2. Validate task exists in TODO.md:
       grep -A 50 "^### ${task_number}\." .opencode/specs/TODO.md
    
    3. Extract task description and current status
    
    4. Verify task not [COMPLETED] or [ABANDONED]
    
    5. Extract language from state.json (fallback to TODO.md):
       [... complex extraction logic ...]
    
    [... 70 more lines ...]
  </process>
</step_0_preflight>
```

**After** (20 lines):
```markdown
<step_0_preflight>
  <process>
    1. Parse task number from prompt:
       - Extract first integer from prompt string
       - Example: "/research 271" → task_number = 271
    
    2. Validate task exists:
       - grep "^### ${task_number}\." .opencode/specs/TODO.md
       - If not found: Return error
    
    3. Update status to [RESEARCHING]:
       - Delegate to status-sync-manager
       - Validate success
    
    4. Proceed to research
  </process>
</step_0_preflight>
```

### Example 4: Simplified Command File

**Before** (162 lines):
```markdown
---
name: research
agent: orchestrator
description: "Conduct research and create reports with [RESEARCHED] status"
[... extensive frontmatter ...]
---

**Task Input (required):** $ARGUMENTS (task number; e.g., `/research 258`)

**Usage:** `/research TASK_NUMBER [PROMPT] [--divide]`

## Workflow Setup

**Orchestrator handles (Stage 1-5):**
- **Stage 1 (PreflightValidation):** Read task number from $ARGUMENTS variable...
  [... 20 lines ...]
- **Stage 2 (DetermineRouting):** Extract language from task entry...
  [... 15 lines ...]
- **Stage 3 (RegisterAndDelegate):** Register session and invoke target agent
  [... 10 lines ...]
- **Stage 4 (ValidateReturn):** Validate return format...
  [... 15 lines ...]
- **Stage 5 (PostflightCleanup):** Update session registry...
  [... 10 lines ...]

**Researcher subagent handles:**
- Update status to [RESEARCHING] at beginning (preflight)
- Research execution (web search, documentation, or Lean-specific tools)
- Topic subdivision (if --divide flag specified)
- Research report creation
- Update status to [RESEARCHED] at end (postflight)
- Git commits

[... 100 more lines of documentation ...]
```

**After** (40 lines):
```markdown
---
name: research
agent: researcher
description: "Conduct research and create reports with [RESEARCHED] status"
timeout: 3600
routing:
  language_based: true
  lean: lean-research-agent
  default: researcher
---

# /research - Research Command

Conduct research for tasks and create research reports.

## Usage

```bash
/research TASK_NUMBER [PROMPT]
/research 197
/research 197 "Focus on CLI integration"
```

## What This Does

1. Routes to appropriate research agent based on task language
2. Agent conducts research using specialized tools
3. Creates research report in `.opencode/specs/{task}_*/reports/`
4. Updates task status to [RESEARCHED]
5. Creates git commit

## Language-Based Routing

| Language | Agent | Tools |
|----------|-------|-------|
| lean | lean-research-agent | LeanExplore, Loogle, LeanSearch |
| general | researcher | Web search, documentation |

See `.opencode/agent/subagents/researcher.md` for workflow details.
```

## Appendix B: Testing Checklist

### Pre-Implementation Tests (Baseline)

Run these tests BEFORE starting refactor to establish baseline:

- [ ] `/plan 196` - Creates plan successfully
- [ ] `/plan 196 "custom prompt"` - Creates plan with custom prompt
- [ ] `/research 197` - Creates research report
- [ ] `/implement 196` - Executes implementation
- [ ] `/revise 196` - Creates revised plan

### Phase 1 Tests (After Orchestrator Simplification)

- [ ] `/plan 196` - Still works (regression test)
- [ ] Orchestrator passes original prompt to planner
- [ ] No argument parsing in orchestrator Stage 1
- [ ] No prompt reformatting in orchestrator Stage 3

### Phase 2 Tests (After Command File Simplification)

- [ ] `/plan 196` - Still works
- [ ] `/research 197` - Works with simplified command file
- [ ] `/implement 196` - Works with simplified command file
- [ ] `/revise 196` - Works with simplified command file

### Phase 3 Tests (After Subagent Simplification)

- [ ] `/plan 196` - Still works
- [ ] `/research 197` - Works with simplified subagent
- [ ] `/research 197 "focus"` - Works with optional prompt
- [ ] `/implement 196` - Works with simplified subagent
- [ ] `/implement 196 "custom"` - Works with optional prompt
- [ ] `/revise 196` - Works with simplified subagent
- [ ] `/revise 196 "reason"` - Works with optional reason

### Phase 4 Tests (After Documentation Update)

- [ ] All commands still work
- [ ] Documentation matches implementation
- [ ] No contradictory docs

### Phase 5 Tests (Comprehensive Validation)

#### Success Cases
- [ ] `/plan 196` - Simple task number
- [ ] `/plan 196 "prompt"` - With optional prompt
- [ ] `/research 197` - Simple task number
- [ ] `/research 197 "focus"` - With focus area
- [ ] `/implement 196` - Simple task number
- [ ] `/implement 196 "custom"` - With custom prompt
- [ ] `/revise 196` - Simple task number
- [ ] `/revise 196 "reason"` - With revision reason

#### Error Cases
- [ ] `/research` - Error: "Task number required"
- [ ] `/research abc` - Error: "Task number must be integer"
- [ ] `/research 999999` - Error: "Task not found"
- [ ] `/implement` - Error: "Task number required"
- [ ] `/implement xyz` - Error: "Task number must be integer"

#### Edge Cases
- [ ] `/implement 105-107` - Range support (if implemented)
- [ ] `/research 197 --divide` - Flag support (if implemented)
- [ ] Task with special characters in prompt
- [ ] Very long optional prompts

### Performance Tests

- [ ] Command execution time < 5 seconds (excluding actual work)
- [ ] No noticeable slowdown vs baseline
- [ ] Memory usage reasonable

### Regression Tests

- [ ] All previously working commands still work
- [ ] No new error messages for valid inputs
- [ ] Error messages still clear and helpful

---

**End of Implementation Plan**

**Next Steps**:
1. Review this plan
2. Approve or request changes
3. Create backup of .opencode/
4. Begin Phase 1 implementation
5. Test after each phase
6. Document any deviations from plan
