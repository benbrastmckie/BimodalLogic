# Research Report: Fix /implement and /research Routing to Use Lean-Specific Agents

**Task**: 208  
**Date**: 2025-12-28  
**Researcher**: lean-research-agent (delegated to researcher)  
**Status**: Completed

---

## Executive Summary

This research identifies a **critical gap between documented and actual behavior** in the OpenCode system's routing logic for Lean tasks. The command files (`implement.md`, `research.md`) and orchestrator (`orchestrator.md`) **document the intended routing behavior** but this documentation represents **specifications, not implementation**. OpenCode is a Claude-based AI agent system where the markdown files serve as **instructions to Claude**, not executable code. The routing failure occurs because **Claude is not consistently following the documented routing instructions** when executing commands.

**Root Cause**: The routing logic exists as documentation but is not being reliably executed by Claude during command processing. This is a **prompt engineering and execution consistency issue**, not a missing feature.

---

## Research Scope

### Objectives
1. Identify where routing decisions are made in /implement and /research commands
2. Determine why Language: lean field is not triggering Lean-specific agent routing
3. Document current vs expected routing behavior for Lean tasks
4. Verify lean-lsp-mcp configuration and accessibility
5. Identify specific locations where routing logic needs to be fixed
6. Determine if routing logic exists but is broken, or is completely missing
7. Document expected vs actual routing behavior
8. Research how OpenCode executes command workflows
9. Identify testing approach to verify routing works after fixes

### Methodology
- Examined command specification files (implement.md, research.md)
- Analyzed orchestrator specification (orchestrator.md)
- Reviewed Lean-specific agent specifications
- Verified .mcp.json configuration
- Analyzed OpenCode architecture documentation
- Examined TODO.md task format for Language field usage

---

## Key Findings

### Finding 1: OpenCode is a Claude-Based AI Agent System

**Discovery**: OpenCode is not a traditional software system with executable code. It is an **AI agent framework** where:

1. **Markdown files are instructions**: All `.md` files in `.opencode/` are **prompts/instructions for Claude**
2. **Claude executes workflows**: When a user invokes `/implement 193`, Claude:
   - Reads the `implement.md` command file
   - Interprets the workflow stages as instructions
   - Executes each stage by following the documented process
   - Uses available tools (bash, read, write, etc.) to perform actions

3. **No compiled code**: There is no Python, JavaScript, or other compiled code that "runs" the .opencode system
4. **Prompt-driven execution**: The system works through **prompt engineering** - Claude reads the specifications and attempts to follow them

**Evidence**:
- `.opencode/README.md` line 238: "All commands include explicit argument parsing specifications that tell the orchestrator exactly how to extract parameters"
- `.opencode/ARCHITECTURE.md` line 186: "The orchestrator reads this section and applies the parsing logic"
- No executable code files found in `.opencode/` (only markdown documentation)
- System relies on Claude's ability to interpret and follow markdown instructions

**Implication**: The routing "bug" is actually a **prompt execution consistency issue** - Claude is not reliably following the documented routing instructions.

---

### Finding 2: Routing Logic is Documented But Not Consistently Executed

**Current State**: The routing logic **exists as documentation** in three places:

#### Location 1: `/research` Command (research.md)

Lines 131-143:
```markdown
<stage id="2" name="CheckLanguage">
  <action>Determine routing based on task language</action>
  <process>
    1. Read Language field from TODO.md task
    2. Determine target agent:
       - Language: lean → lean-research-agent
       - Language: * → researcher (general)
    3. Prepare agent-specific context
  </process>
  <routing>
    Language: lean → lean-research-agent (LeanExplore, Loogle, LeanSearch)
    Language: * → researcher (web search, documentation)
  </routing>
</stage>
```

Lines 172-191 (InvokeResearcher stage):
```markdown
<invocation>
  task_tool(
    subagent_type="{researcher|lean-research-agent}",
    prompt="Research topic: {description}",
    session_id=delegation_context["session_id"],
    delegation_depth=1,
    delegation_path=delegation_context["delegation_path"],
    timeout=3600,
    divide=divide_flag
  )
</invocation>
```

#### Location 2: `/implement` Command (implement.md)

Lines 165-183:
```markdown
<stage id="2" name="DetermineRouting">
  <action>Route based on language and complexity</action>
  <process>
    1. Check task Language field from TODO.md
    2. Check for plan existence
    3. Determine target agent:
       - Language: lean + has_plan → lean-implementation-agent (phased)
       - Language: lean + no_plan → lean-implementation-agent (simple)
       - Language: * + has_plan → task-executor (phased)
       - Language: * + no_plan → implementer (direct)
    4. Prepare agent-specific context
  </process>
  <routing>
    Language: lean + has_plan → lean-implementation-agent (phased mode)
    Language: lean + no_plan → lean-implementation-agent (simple mode)
    Language: * + has_plan → task-executor (multi-phase execution)
    Language: * + no_plan → implementer (direct implementation)
  </routing>
</stage>
```

Lines 212-233 (InvokeImplementer stage):
```markdown
<invocation>
  task_tool(
    subagent_type="{task-executor|implementer|lean-implementation-agent}",
    prompt="Implement task {number}: {description}",
    session_id=delegation_context["session_id"],
    delegation_depth=1,
    delegation_path=delegation_context["delegation_path"],
    timeout=7200,
    plan_path=plan_path,
    resume_from_phase=resume_from_phase
  )
</invocation>
```

#### Location 3: Orchestrator (orchestrator.md)

Lines 138-154 (Stage 3: CheckLanguage):
```markdown
<stage id="3" name="CheckLanguage">
  <action>Determine language for routing decisions</action>
  <process>
    1. If task number present: Read task from TODO.md
    2. Extract Language field from task or plan metadata
    3. If no language specified: default to "general"
  </process>
  <language_routing_map>
    - `lean` → Lean-specific agents (lean-implementation-agent, lean-research-agent)
    - `markdown` → Documentation agents
    - `python` → General agents (future: python-specific)
    - `general` → General agents (default)
  </language_routing_map>
  <output>Language identifier</output>
</stage>
```

Lines 161-180 (Stage 4: PrepareRouting):
```markdown
**For /research command**:
- If Language == "lean" → lean-research-agent
- Else → researcher (general)

**For /implement command**:
- If has plan file:
  - If Language == "lean" → lean-implementation-agent
  - Else → task-executor (multi-phase)
- Else (no plan):
  - If Language == "lean" → lean-implementation-agent (simple mode)
  - Else → implementer (direct)
```

**Problem**: This routing logic is **documented as instructions** but Claude is not consistently executing it. When processing `/implement 193` or `/research 193`, Claude should:
1. Read the task from TODO.md
2. Extract the `Language: lean` field
3. Route to `lean-implementation-agent` or `lean-research-agent`
4. But instead, it routes to general agents (`implementer`, `researcher`)

**Why This Happens**: 
- Claude may skip the CheckLanguage/DetermineRouting stages
- Claude may not properly parse the Language field from TODO.md
- The routing instructions may not be prominent enough in the prompt
- Claude may default to simpler routing paths

---

### Finding 3: Lean-Specific Agents Are Properly Specified

Both Lean-specific agents exist and are well-documented:

#### lean-implementation-agent.md

**Purpose**: Implement Lean code with lean-lsp-mcp integration

**Key Features**:
- Checks `.mcp.json` for lean-lsp-mcp availability (lines 63-66)
- Uses lean-lsp-mcp for compilation checking (lines 104-132)
- Graceful degradation if tool unavailable (lines 124-130)
- Logs tool unavailability to errors.json (line 127)
- Iterates on compilation errors (max 5 iterations, line 110)

**Integration Check** (lines 63-66):
```markdown
3. Load tactic patterns and proof strategies
4. Check .mcp.json for lean-lsp-mcp configuration
5. Determine tool availability (available/unavailable)
6. Log tool status
```

**Graceful Degradation** (lines 124-130):
```markdown
If lean-lsp-mcp unavailable:
- Continue with direct file modification
- Log error to errors.json with code TOOL_UNAVAILABLE
- Return partial status with warning
- Recommend installing lean-lsp-mcp
```

#### lean-research-agent.md

**Purpose**: Research Lean libraries using Loogle CLI (integrated in Task 197)

**Key Features**:
- Loogle CLI integration (lines 60-96)
- Persistent interactive mode with JSON output (line 68)
- Query generation for modal/temporal logic patterns (lines 139-172)
- Result categorization (definitions, theorems, tactics) (lines 227-250)
- Graceful fallback to web search if Loogle unavailable (lines 398-407)

**Loogle Status** (lines 65-79):
```markdown
LOOGLE CLI: INTEGRATED (Task 197)
- Binary path: /home/benjamin/.cache/loogle/.lake/build/bin/loogle
- Index path: ~/.cache/lean-research-agent/loogle-mathlib.index
- Mode: Persistent interactive mode with JSON output
- Startup timeout: 180s (index build on first run)
- Query timeout: 10s per query

LeanExplore: NOT YET INTEGRATED
LeanSearch: NOT YET INTEGRATED

FALLBACK: Web search for Lean 4 documentation and mathlib
```

**Both agents are production-ready** and waiting to be invoked by the routing logic.

---

### Finding 4: .mcp.json Configuration is Correct

**File**: `.mcp.json`

**lean-lsp-mcp Configuration** (lines 3-11):
```json
"lean-lsp": {
  "type": "stdio",
  "command": "uvx",
  "args": ["lean-lsp-mcp"],
  "env": {
    "LEAN_LOG_LEVEL": "WARNING",
    "LEAN_PROJECT_PATH": "/home/benjamin/Documents/Philosophy/Projects/ProofChecker"
  }
}
```

**Status**: [PASS] Properly configured
- Server name: "lean-lsp"
- Command: `uvx lean-lsp-mcp`
- Project path correctly set
- Ready for use by lean-implementation-agent

**Verification**: The lean-implementation-agent checks for this configuration in step_1 (lines 63-66) and will use it if available.

---

### Finding 5: TODO.md Tasks Include Language Field

**Example from TODO.md** (Task 193):

```markdown
### 193. Prove is_valid_swap_involution theorem in Truth.lean (currently sorry)
- **Effort**: 2 hours
- **Status**: [PARTIAL]
- **Started**: 2025-12-28
- **Priority**: High
- **Language**: lean
```

**Language Field Format**: `- **Language**: lean`

**Parsing Required**: Commands must:
1. Read task from TODO.md using task number
2. Parse the `**Language**: lean` field
3. Use this value for routing decisions

**Current Issue**: Claude is not consistently extracting this field during command execution.

---

### Finding 6: How OpenCode Executes Commands

Based on architecture analysis:

#### Execution Flow

1. **User Invokes Command**: `/implement 193`

2. **Claude Receives Prompt**: OpenCode system constructs a prompt containing:
   - The command file (`implement.md`)
   - Relevant context files
   - User arguments (`193`)

3. **Claude Interprets Workflow**: Claude reads the workflow stages in `implement.md`:
   - Stage 1: Preflight (parse arguments, load task)
   - Stage 2: DetermineRouting (check language, select agent)
   - Stage 3: PrepareDelegation (create session ID)
   - Stage 4: InvokeImplementer (call selected agent)
   - Stages 5-8: Receive results, process, update status, return

4. **Claude Executes Stages**: For each stage, Claude:
   - Reads the `<process>` instructions
   - Uses available tools (bash, read, write) to perform actions
   - Follows the documented logic

5. **Problem**: Claude may skip or incorrectly execute Stage 2 (DetermineRouting), leading to wrong agent selection

#### task_tool() Invocation

The `task_tool()` function appears in documentation but is **not a real function**. It's a **placeholder notation** indicating:
- "At this point, delegate to a subagent"
- The `subagent_type` parameter shows which agent to invoke
- Claude interprets this as "load the specified agent's markdown file and execute it"

**Evidence**: 
- No task_tool implementation found in codebase
- It's used in documentation as a conceptual notation
- Claude must interpret this as "switch to executing the specified agent's instructions"

---

### Finding 7: Root Cause Analysis

**The routing logic exists but is not being reliably executed by Claude.**

#### Why Routing Fails

1. **Workflow Stage Skipping**: Claude may skip the CheckLanguage/DetermineRouting stages, jumping directly to agent invocation with default routing

2. **Language Field Parsing Failure**: Claude may not properly extract the `Language: lean` field from TODO.md markdown

3. **Prompt Clarity**: The routing instructions may not be prominent enough in the command files

4. **Default Behavior**: Claude may default to simpler routing (general agents) when uncertain

5. **Lack of Validation**: No explicit validation step ensures routing was performed correctly

#### Evidence of Failure

From task description:
> "When running /implement on Lean-specific tasks (e.g., task 193 with Language: lean), the implementation is NOT being executed by the lean-implementation-agent subagent, and lean-lsp-mcp tools are NOT being used."

This indicates:
- Task 193 has `Language: lean` in TODO.md [YES]
- `/implement 193` was invoked [YES]
- Expected: lean-implementation-agent invoked [NO]
- Actual: General implementer invoked [NO]
- lean-lsp-mcp was not used [NO]

---

## Expected vs Actual Behavior

### Expected Behavior: /research 193

**Given**: Task 193 with `Language: lean` in TODO.md

**Expected Flow**:
1. User: `/research 193`
2. Orchestrator loads `research.md`
3. Stage 1 (Preflight): Parse task number 193, load task from TODO.md
4. **Stage 2 (CheckLanguage)**: Extract `Language: lean` from task
5. **Stage 2 (CheckLanguage)**: Route to `lean-research-agent`
6. Stage 3 (PrepareDelegation): Create session ID
7. Stage 4 (InvokeResearcher): Invoke `lean-research-agent` with Loogle integration
8. lean-research-agent:
   - Initializes Loogle CLI client
   - Generates Lean-specific queries
   - Searches mathlib using Loogle
   - Creates research report with Loogle findings
9. Stage 5-8: Receive results, update status, commit

**Expected Output**:
- Research report with Loogle query results
- Lean-specific theorem and tactic findings
- Loogle query log and metrics

### Actual Behavior: /research 193

**What Happens**:
1. User: `/research 193`
2. Orchestrator loads `research.md`
3. Stage 1 (Preflight): Parse task number 193, load task from TODO.md
4. **Stage 2 (CheckLanguage): SKIPPED OR FAILED**
5. **Default routing to `researcher` (general agent)**
6. Stage 4 (InvokeResearcher): Invoke `researcher` instead of `lean-research-agent`
7. researcher:
   - Uses web search only
   - No Loogle integration
   - Generic research, not Lean-specific
8. Stage 5-8: Receive results, update status, commit

**Actual Output**:
- Generic research report
- No Loogle queries
- No Lean-specific findings
- Missing mathlib theorem references

### Expected Behavior: /implement 193

**Given**: Task 193 with `Language: lean` and a plan file

**Expected Flow**:
1. User: `/implement 193`
2. Orchestrator loads `implement.md`
3. Stage 1 (Preflight): Parse task number 193, load task, check for plan
4. **Stage 2 (DetermineRouting)**: Extract `Language: lean`, detect plan exists
5. **Stage 2 (DetermineRouting)**: Route to `lean-implementation-agent` (phased mode)
6. Stage 3 (PrepareDelegation): Create session ID
7. Stage 4 (InvokeImplementer): Invoke `lean-implementation-agent`
8. lean-implementation-agent:
   - Checks .mcp.json for lean-lsp-mcp
   - Implements Lean proof code
   - Uses lean-lsp-mcp for compilation checking
   - Iterates on type errors
   - Returns compiled Lean code
9. Stage 5-8: Receive results, update status, commit

**Expected Output**:
- Lean proof implementation
- Compilation verified via lean-lsp-mcp
- Type errors resolved
- Status: completed (if compiled) or partial (if degraded)

### Actual Behavior: /implement 193

**What Happens**:
1. User: `/implement 193`
2. Orchestrator loads `implement.md`
3. Stage 1 (Preflight): Parse task number 193, load task, check for plan
4. **Stage 2 (DetermineRouting): SKIPPED OR FAILED**
5. **Default routing to `task-executor` or `implementer`**
6. Stage 4 (InvokeImplementer): Invoke general agent
7. General agent:
   - No lean-lsp-mcp integration
   - Direct file modification only
   - No compilation checking
   - May introduce type errors
8. Stage 5-8: Receive results, update status, commit

**Actual Output**:
- Lean code written but not verified
- No compilation checking
- Potential type errors undetected
- lean-lsp-mcp never invoked

---

## Specific Code Locations Requiring Fixes

Since OpenCode is prompt-based, "fixes" mean **improving the prompt instructions** to ensure Claude reliably executes routing logic.

### Fix Location 1: research.md Stage 2 (CheckLanguage)

**File**: `.opencode/command/research.md`  
**Lines**: 131-144

**Current Issue**: Stage may be skipped or language extraction may fail

**Required Enhancement**:
```markdown
<stage id="2" name="CheckLanguage">
  <action>Determine routing based on task language</action>
  <process>
    1. Read Language field from TODO.md task
       CRITICAL: Extract the line matching "- **Language**: {value}"
       Parse {value} as the language identifier
    2. Determine target agent:
       - Language: lean → lean-research-agent (REQUIRED for Lean tasks)
       - Language: * → researcher (general)
    3. Prepare agent-specific context
    4. VALIDATION: Verify language was extracted successfully
       If extraction failed, default to "general" and log warning
  </process>
  <routing>
    Language: lean → lean-research-agent (LeanExplore, Loogle, LeanSearch)
    Language: * → researcher (web search, documentation)
  </routing>
  <validation>
    MUST extract Language field before proceeding to Stage 3
    MUST route to lean-research-agent if Language == "lean"
    MUST log routing decision for debugging
  </validation>
</stage>
```

**Key Additions**:
- Explicit language extraction instructions
- Validation requirement before proceeding
- Logging of routing decision
- Emphasis on CRITICAL and REQUIRED

### Fix Location 2: implement.md Stage 2 (DetermineRouting)

**File**: `.opencode/command/implement.md`  
**Lines**: 165-183

**Current Issue**: Stage may be skipped or language extraction may fail

**Required Enhancement**:
```markdown
<stage id="2" name="DetermineRouting">
  <action>Route based on language and complexity</action>
  <process>
    1. Check task Language field from TODO.md
       CRITICAL: Extract the line matching "- **Language**: {value}"
       Parse {value} as the language identifier
    2. Check for plan existence (look for **Plan**: link in TODO.md)
    3. Determine target agent using this EXACT logic:
       IF Language == "lean" AND has_plan:
         → lean-implementation-agent (phased mode)
       ELSE IF Language == "lean" AND NOT has_plan:
         → lean-implementation-agent (simple mode)
       ELSE IF Language != "lean" AND has_plan:
         → task-executor (phased)
       ELSE:
         → implementer (direct)
    4. Prepare agent-specific context
    5. VALIDATION: Verify routing decision is correct
       Log: "Routing task {number} (Language: {lang}, Plan: {has_plan}) → {agent}"
  </process>
  <routing>
    Language: lean + has_plan → lean-implementation-agent (phased mode)
    Language: lean + no_plan → lean-implementation-agent (simple mode)
    Language: * + has_plan → task-executor (multi-phase execution)
    Language: * + no_plan → implementer (direct implementation)
  </routing>
  <validation>
    MUST extract Language field before routing
    MUST route to lean-implementation-agent if Language == "lean"
    MUST log routing decision with language and plan status
    MUST NOT skip this stage
  </validation>
</stage>
```

**Key Additions**:
- Explicit IF/ELSE routing logic
- Validation requirement with logging
- Emphasis on MUST NOT skip
- Clear routing decision logging

### Fix Location 3: orchestrator.md Stage 3 (CheckLanguage)

**File**: `.opencode/agent/orchestrator.md`  
**Lines**: 138-154

**Current Issue**: Language extraction may not be performed

**Required Enhancement**:
```markdown
<stage id="3" name="CheckLanguage">
  <action>Determine language for routing decisions</action>
  <process>
    1. If task number present: Read task from TODO.md
       Use bash tool: grep -A 20 "^## Task {number}" TODO.md
    2. Extract Language field from task metadata
       Search for line: "- **Language**: {value}"
       Parse {value} as language identifier
    3. If no language specified: default to "general"
    4. VALIDATION: Verify language was extracted
       Log: "Task {number} language: {language}"
  </process>
  <language_routing_map>
    - `lean` → Lean-specific agents (lean-implementation-agent, lean-research-agent)
    - `markdown` → Documentation agents
    - `python` → General agents (future: python-specific)
    - `general` → General agents (default)
  </language_routing_map>
  <output>Language identifier</output>
  <validation>
    MUST extract language before Stage 4 (PrepareRouting)
    MUST log language extraction result
    MUST default to "general" if extraction fails
  </validation>
</stage>
```

**Key Additions**:
- Specific bash command for extraction
- Validation with logging
- Clear default behavior

### Fix Location 4: orchestrator.md Stage 4 (PrepareRouting)

**File**: `.opencode/agent/orchestrator.md`  
**Lines**: 158-210

**Current Issue**: Routing logic may not use language from Stage 3

**Required Enhancement**:
```markdown
<stage id="4" name="PrepareRouting">
  <action>Determine target agent and prepare delegation context</action>
  
  <routing_logic>
    CRITICAL: Use language from Stage 3 for routing decisions
    
    **For /research command**:
    IF language == "lean":
      target_agent = "lean-research-agent"
      Log: "Routing /research to lean-research-agent (Loogle integration)"
    ELSE:
      target_agent = "researcher"
      Log: "Routing /research to researcher (general)"
    
    **For /implement command**:
    IF has_plan_file:
      IF language == "lean":
        target_agent = "lean-implementation-agent"
        mode = "phased"
        Log: "Routing /implement to lean-implementation-agent (phased, lean-lsp-mcp)"
      ELSE:
        target_agent = "task-executor"
        Log: "Routing /implement to task-executor (phased, general)"
    ELSE:
      IF language == "lean":
        target_agent = "lean-implementation-agent"
        mode = "simple"
        Log: "Routing /implement to lean-implementation-agent (simple, lean-lsp-mcp)"
      ELSE:
        target_agent = "implementer"
        Log: "Routing /implement to implementer (direct, general)"
  </routing_logic>
  
  <validation>
    MUST use language from Stage 3
    MUST log routing decision with agent name and reason
    MUST NOT default to general agents for Lean tasks
  </validation>
  
  <delegation_context_preparation>
    ... (existing content)
  </delegation_context_preparation>
</stage>
```

**Key Additions**:
- Explicit IF/ELSE logic with logging
- CRITICAL emphasis on using Stage 3 language
- Clear logging of routing decisions

---

## Implementation Strategy

### Approach: Strengthen Prompt Instructions

Since OpenCode is prompt-based, the fix involves **enhancing the markdown instructions** to ensure Claude reliably executes routing logic.

### Phase 1: Add Explicit Validation Steps

**Goal**: Ensure routing stages are not skipped

**Changes**:
1. Add `<validation>` sections to routing stages
2. Require logging of routing decisions
3. Add explicit "MUST NOT skip" warnings

**Files to Modify**:
- `.opencode/command/research.md` (Stage 2)
- `.opencode/command/implement.md` (Stage 2)
- `.opencode/agent/orchestrator.md` (Stages 3-4)

### Phase 2: Improve Language Extraction Instructions

**Goal**: Ensure Language field is reliably extracted from TODO.md

**Changes**:
1. Provide exact bash commands for extraction
2. Add regex patterns for parsing
3. Add fallback behavior if extraction fails
4. Require logging of extracted language

**Example**:
```markdown
Extract Language field:
1. Use bash: grep -A 20 "^## Task {number}" TODO.md
2. Search output for: "- **Language**: {value}"
3. Parse {value} as language identifier
4. If not found: default to "general"
5. Log: "Task {number} language: {language}"
```

### Phase 3: Add Routing Decision Logging

**Goal**: Make routing decisions visible for debugging

**Changes**:
1. Require logging before agent invocation
2. Include language, plan status, and selected agent
3. Format: "Routing task {number} (Language: {lang}, Plan: {has_plan}) → {agent}"

**Benefits**:
- Debugging: Can verify routing was performed
- Validation: Can check if correct agent was selected
- Auditing: Can track routing decisions over time

### Phase 4: Add Pre-Invocation Checks

**Goal**: Validate routing before invoking agent

**Changes**:
1. Before invoking agent, check:
   - Language was extracted
   - Routing decision was made
   - Selected agent matches language
2. If validation fails: Log error and abort

**Example**:
```markdown
<pre_invocation_validation>
  BEFORE invoking agent, verify:
  1. Language field was extracted from TODO.md
  2. Routing decision was logged
  3. Selected agent matches language:
     - If Language == "lean": agent MUST be lean-*-agent
     - If Language != "lean": agent MUST be general agent
  4. If validation fails: ABORT and return error
</pre_invocation_validation>
```

---

## Testing Strategy

### Test 1: Verify Language Extraction

**Objective**: Ensure Language field is extracted from TODO.md

**Test Case**:
```
1. Create test task with Language: lean
2. Invoke /research {number}
3. Check logs for: "Task {number} language: lean"
4. Expected: Language extracted successfully
```

**Success Criteria**: Language field extracted and logged

### Test 2: Verify Lean Research Routing

**Objective**: Ensure Lean tasks route to lean-research-agent

**Test Case**:
```
1. Create task with Language: lean
2. Invoke /research {number}
3. Check logs for: "Routing /research to lean-research-agent"
4. Check research report for Loogle query log
5. Expected: lean-research-agent invoked, Loogle used
```

**Success Criteria**: 
- lean-research-agent invoked
- Loogle queries executed
- Research report includes Loogle findings

### Test 3: Verify Lean Implementation Routing (No Plan)

**Objective**: Ensure Lean tasks without plans route to lean-implementation-agent

**Test Case**:
```
1. Create task with Language: lean, no plan
2. Invoke /implement {number}
3. Check logs for: "Routing /implement to lean-implementation-agent (simple)"
4. Check for lean-lsp-mcp usage
5. Expected: lean-implementation-agent invoked, lean-lsp-mcp used
```

**Success Criteria**:
- lean-implementation-agent invoked
- lean-lsp-mcp compilation checking performed
- Return includes compilation_status field

### Test 4: Verify Lean Implementation Routing (With Plan)

**Objective**: Ensure Lean tasks with plans route to lean-implementation-agent

**Test Case**:
```
1. Create task with Language: lean
2. Create plan with /plan {number}
3. Invoke /implement {number}
4. Check logs for: "Routing /implement to lean-implementation-agent (phased)"
5. Check for lean-lsp-mcp usage
6. Expected: lean-implementation-agent invoked in phased mode
```

**Success Criteria**:
- lean-implementation-agent invoked
- Phased execution with plan
- lean-lsp-mcp used for each phase

### Test 5: Verify General Task Routing

**Objective**: Ensure non-Lean tasks still route to general agents

**Test Case**:
```
1. Create task with Language: markdown
2. Invoke /research {number}
3. Check logs for: "Routing /research to researcher (general)"
4. Expected: researcher invoked, not lean-research-agent
```

**Success Criteria**:
- researcher invoked (not lean-research-agent)
- Web search used (not Loogle)

### Test 6: Verify Routing Validation

**Objective**: Ensure routing validation catches errors

**Test Case**:
```
1. Create task with Language: lean
2. Manually modify command to skip CheckLanguage stage
3. Invoke command
4. Expected: Validation error, command aborts
```

**Success Criteria**:
- Validation detects missing language extraction
- Command aborts with error message
- No agent invoked

---

## Risk Assessment

### Risk 1: Prompt Changes May Not Be Sufficient

**Likelihood**: Medium  
**Impact**: High

**Description**: Even with enhanced prompts, Claude may still skip routing stages or fail to extract language field.

**Mitigation**:
- Add multiple validation checkpoints
- Require explicit logging at each stage
- Add pre-invocation validation that aborts if routing failed
- Consider adding a "routing verification" stage

### Risk 2: Backward Compatibility

**Likelihood**: Low  
**Impact**: Medium

**Description**: Enhanced routing logic may break existing workflows for non-Lean tasks.

**Mitigation**:
- Test general task routing after changes
- Ensure default behavior (Language: general) still works
- Add fallback logic if language extraction fails

### Risk 3: Performance Impact

**Likelihood**: Low  
**Impact**: Low

**Description**: Additional validation and logging may slow down command execution.

**Mitigation**:
- Logging is minimal overhead
- Validation is simple checks
- Benefits (correct routing) outweigh small performance cost

### Risk 4: Incomplete Fix

**Likelihood**: Medium  
**Impact**: High

**Description**: Fixing command files but not orchestrator (or vice versa) may leave routing partially broken.

**Mitigation**:
- Fix all three locations (research.md, implement.md, orchestrator.md)
- Test both /research and /implement commands
- Verify routing at both command and orchestrator levels

---

## Recommendations

### Immediate Actions (High Priority)

1. **Enhance research.md Stage 2 (CheckLanguage)**
   - Add explicit language extraction instructions
   - Add validation requirements
   - Add routing decision logging

2. **Enhance implement.md Stage 2 (DetermineRouting)**
   - Add explicit IF/ELSE routing logic
   - Add validation requirements
   - Add routing decision logging

3. **Enhance orchestrator.md Stages 3-4**
   - Add language extraction validation
   - Add routing logic validation
   - Add pre-invocation checks

4. **Test Routing with Lean Tasks**
   - Test /research with Language: lean
   - Test /implement with Language: lean (no plan)
   - Test /implement with Language: lean (with plan)
   - Verify lean-lsp-mcp and Loogle are used

### Medium-Term Actions

1. **Add Routing Verification Stage**
   - New stage after PrepareRouting
   - Validates routing decision before invocation
   - Logs routing decision for audit

2. **Create Routing Test Suite**
   - Automated tests for language extraction
   - Automated tests for routing decisions
   - Regression tests for general task routing

3. **Document Routing Behavior**
   - Add routing examples to QUICK-START.md
   - Document expected vs actual behavior
   - Add troubleshooting guide for routing issues

### Long-Term Actions

1. **Consider Routing Enforcement Mechanism**
   - Explore ways to make routing more reliable
   - Consider adding routing validation to orchestrator
   - Investigate prompt engineering techniques for reliability

2. **Monitor Routing Effectiveness**
   - Track routing decisions in logs
   - Analyze routing failures
   - Identify patterns in routing errors

3. **Extend Language Support**
   - Add Python-specific agents
   - Add JavaScript-specific agents
   - Generalize routing logic for new languages

---

## Conclusion

The routing bug is a **prompt execution consistency issue** in a Claude-based AI agent system. The routing logic **exists as documentation** in command and orchestrator files, but Claude is not reliably executing it. The fix involves **strengthening the prompt instructions** with:

1. Explicit validation requirements
2. Detailed language extraction instructions
3. Routing decision logging
4. Pre-invocation validation checks

The Lean-specific agents (lean-implementation-agent, lean-research-agent) are production-ready and properly configured. The .mcp.json configuration is correct. The issue is solely in the **routing execution**, not in the agents or tools.

**Estimated Implementation Effort**: 2-3 hours
- 1 hour: Enhance command files (research.md, implement.md)
- 1 hour: Enhance orchestrator.md
- 1 hour: Testing and validation

**Success Criteria**:
- Lean tasks consistently route to Lean-specific agents
- lean-lsp-mcp is used for Lean implementation
- Loogle is used for Lean research
- General tasks still route to general agents
- Routing decisions are logged for debugging

---

## References

### Documentation Reviewed

1. `.opencode/command/implement.md` - /implement command specification
2. `.opencode/command/research.md` - /research command specification
3. `.opencode/agent/orchestrator.md` - Orchestrator specification
4. `.opencode/agent/subagents/lean-implementation-agent.md` - Lean implementation agent
5. `.opencode/agent/subagents/lean-research-agent.md` - Lean research agent
6. `.opencode/.mcp.json` - MCP server configuration
7. `.opencode/ARCHITECTURE.md` - System architecture
8. `.opencode/README.md` - System overview
9. `.opencode/QUICK-START.md` - Quick start guide
10. `specs/TODO.md` - Task list with Language fields

### Key Insights

- OpenCode is a Claude-based AI agent system using markdown as prompts
- Routing logic exists but is not consistently executed
- Lean-specific agents are ready and properly configured
- Fix requires prompt engineering, not code changes
- Testing must verify routing decisions are logged and correct

---

**Report Completed**: 2025-12-28  
**Next Steps**: Create implementation plan to fix routing logic
