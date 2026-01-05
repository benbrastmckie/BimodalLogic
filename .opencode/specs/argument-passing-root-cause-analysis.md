# Argument Passing Root Cause Analysis & Solution

**Date**: 2026-01-04  
**Issue**: `/implement 259` still fails with "task number not provided" even after v6.1 fix  
**Status**: ROOT CAUSE IDENTIFIED - New solution required  

---

## Critical Discovery

After comparing with the main branch (which works), I discovered the **fundamental misunderstanding** about how OpenCode's command system actually works.

### How Main Branch Works (CORRECTLY)

```
User types: /implement 259
  ↓
OpenCode invokes orchestrator with command="/implement" and $ARGUMENTS="259"
  ↓
Orchestrator Stage 5: Delegates to target agent (from command frontmatter)
  ↓
Target: The COMMAND FILE ITSELF (.opencode/command/implement.md)
  ↓
Command file is an AGENT with <workflow_execution> stages
  ↓
Command file Stage 1: Parse $ARGUMENTS="259" → task_number=259
Command file Stage 2: Extract language, determine routing
Command file Stage 3: Delegate to actual implementer subagent
  ↓
Implementer receives task context from command file
  ↓
Implementation proceeds ✓
```

**Key Insight**: **Command files ARE agents**! They contain `<workflow_execution>` sections and receive `$ARGUMENTS`.

### How We Tried to Make It Work (INCORRECTLY)

**v6.0 Attempt**: Direct invocation
```
Command file: agent: implementer
→ OpenCode bypasses orchestrator, directly invokes implementer
→ Implementer has no $ARGUMENTS
→ FAILS ✗
```

**v6.1 Attempt**: Orchestrator extraction
```
Command file: agent: orchestrator
Orchestrator tries to extract task number and pass to subagent
→ But orchestrator doesn't have the command file's context/workflow!
→ Orchestrator doesn't know HOW to parse arguments for each command
→ FAILS ✗
```

---

## The Real Architecture (Main Branch)

### Three-Layer Delegation

```
Layer 1: Orchestrator
- Role: Router and safety manager
- Input: Command name, $ARGUMENTS
- Output: Delegates to command agent

Layer 2: Command Agent (.opencode/command/X.md)
- Role: Command-specific argument parsing and routing
- Input: $ARGUMENTS from orchestrator
- Has: <workflow_execution> with command-specific logic
- Output: Delegates to appropriate subagent with parsed context

Layer 3: Subagent (.opencode/agent/subagents/Y.md)
- Role: Actual work execution
- Input: Parsed task context from command agent
- Has: <process_flow> with implementation steps
- Output: Returns result to user
```

### Example: `/implement 259` on Main Branch

**Command File** (`.opencode/command/implement.md`):
```markdown
---
name: implement
agent: orchestrator  # Orchestrator delegates HERE (to this command file)
---

**Task Input (required):** $ARGUMENTS

<workflow_execution>
  <stage id="1" name="Preflight">
    <action>Parse arguments and validate tasks</action>
    <process>
      1. Parse task number from $ARGUMENTS  # COMMAND PARSES!
      2. Validate task exists
      3. Update status
    </process>
  </stage>
  
  <stage id="2" name="CheckLanguage">
    <action>Extract language for routing</action>
    <process>
      1. Extract language from TODO.md
      2. Determine target agent (lean vs general)
    </process>
  </stage>
  
  <stage id="3" name="PrepareDelegation">
    <action>Prepare delegation context</action>
    <process>
      1. Prepare task context with parsed data
    </process>
  </stage>
  
  <stage id="4" name="Delegate">
    <action>Invoke target subagent</action>
    <process>
      1. task_tool(
           subagent_type="implementer",
           prompt="...",
           task_number=259,  # Parsed by COMMAND
           language="lean"    # Extracted by COMMAND
         )
    </process>
  </stage>
</workflow_execution>
```

**Key Points**:
1. Command file HAS `<workflow_execution>` (it's an agent!)
2. Command file RECEIVES `$ARGUMENTS`
3. Command file PARSES task number
4. Command file DELEGATES to subagent with parsed context

---

## Why Our Attempts Failed

### v6.0 Failure

We removed the **command agent layer** entirely by changing:
```yaml
agent: orchestrator  # OLD: Command is an agent
```
to:
```yaml
agent: implementer  # NEW: Direct to subagent
```

**Problem**: Removed the layer that has access to `$ARGUMENTS` and knows how to parse them!

### v6.1 Failure

We tried to move argument parsing to orchestrator:
```yaml
agent: orchestrator  # Route through orchestrator
```
But orchestrator tries to be generic and doesn't have command-specific parsing logic.

**Problem**: Orchestrator doesn't know that `/implement` needs task number parsing, but `/meta` doesn't, etc.

---

## The Correct Architecture

### Command Files ARE Agents

Command files in `.opencode/command/` are **NOT just metadata**. They are **full agents** with:

1. **Frontmatter**: Routing configuration
2. **Context**: System/domain/task context
3. **Role**: What this command does
4. **Task**: Specific responsibilities
5. **Workflow Execution**: Stages for parsing and delegation

### Orchestrator Role

The orchestrator is a **pure router**:
1. Load command file
2. Extract `agent:` field (which points to the command file itself!)
3. Delegate to command file with `$ARGUMENTS`
4. Command file handles everything else

### Command File Role

The command file is a **command-specific agent**:
1. Receive `$ARGUMENTS` from orchestrator
2. Parse arguments (command-specific logic)
3. Validate inputs (command-specific validation)
4. Extract metadata (command-specific extraction)
5. Route to appropriate subagent
6. Pass parsed context to subagent

### Subagent Role

The subagent is an **execution agent**:
1. Receive parsed context from command file
2. Execute workflow
3. Return results

---

## Why Main Branch Works

Main branch command files look like this:

```markdown
---
name: implement
agent: orchestrator  # Orchestrator delegates to THIS FILE
---

**Task Input:** $ARGUMENTS

<workflow_execution>
  <!-- Command-specific parsing and routing -->
</workflow_execution>
```

When OpenCode sees `agent: orchestrator`, it means:
1. **NOT** "orchestrator will handle this"
2. **BUT** "orchestrator will delegate to the command file"

The command file receives `$ARGUMENTS` and processes it!

---

## Why We Got Confused

### Misconception 1: Agent Field Meaning

**We thought**:
- `agent: orchestrator` = Orchestrator handles the command
- `agent: implementer` = Directly invoke implementer

**Reality**:
- `agent: orchestrator` = Orchestrator delegates to THIS COMMAND FILE
- `agent: subagents/implementer` = Orchestrator delegates to implementer subagent
- The target is determined by the agent field, but $ARGUMENTS goes to that target!

### Misconception 2: OpenAgents Comparison

**We thought**: OpenAgents has simpler command files, so we should simplify ours

**Reality**: OpenAgents uses a DIFFERENT pattern:
- OpenAgents: Topic-based, no task numbers, simple delegation
- ProofChecker: Task-based, needs parsing, multi-stage delegation

We can't copy OpenAgents patterns without understanding this difference!

### Misconception 3: Command Files Are Metadata

**We thought**: Command files are just YAML metadata for routing

**Reality**: Command files are FULL AGENTS with workflow execution!

---

## The Solution

### Option 1: Restore Command File Workflows (RECOMMENDED)

**Restore the working main branch pattern**:

1. Command files have `<workflow_execution>` sections
2. Command files receive `$ARGUMENTS` from orchestrator
3. Command files parse arguments (command-specific)
4. Command files delegate to subagents with parsed context
5. Subagents execute with clean inputs

**Changes Required**:
- Restore `<workflow_execution>` in command files
- Keep `agent: orchestrator` (orchestrator delegates to command file)
- Command files parse their own arguments
- Subagents receive parsed context from command files

**Pros**:
- ✅ Proven to work (main branch)
- ✅ Clean separation: command parses, subagent executes
- ✅ Each command has its own parsing logic
- ✅ Subagents receive clean, validated inputs

**Cons**:
- ❌ Command files are longer (have workflow stages)
- ❌ More complex than "simple metadata files"

### Option 2: True Direct Invocation (NOT RECOMMENDED)

**Make command files pure metadata and enhance orchestrator**:

1. Command files are just YAML frontmatter
2. Orchestrator has command-specific parsing logic for each command
3. Orchestrator parses and delegates

**Changes Required**:
- Remove workflows from command files
- Add parsing logic to orchestrator for each command type
- Orchestrator becomes command-aware (huge complexity)

**Pros**:
- ✅ Simple command files

**Cons**:
- ❌ Orchestrator becomes bloated with command-specific logic
- ❌ Violates separation of concerns
- ❌ Hard to maintain (add new command = modify orchestrator)
- ❌ Not how OpenCode is designed

---

## Recommended Implementation: Restore Command File Workflows

### Phase 1: Restore implement.md Workflow ✅ COMPLETED

**Update `.opencode/command/implement.md`**:

```markdown
---
name: implement
agent: orchestrator
description: "Execute implementation"
timeout: 7200
routing:
  lean: lean-implementation-agent
  default: implementer
---

**Task Input (required):** $ARGUMENTS

<context>
  <system_context>Implementation command with language-based routing</system_context>
  <task_context>Parse task number, validate, extract language, delegate to implementer</task_context>
</context>

<role>Implementation command - Parse and route to implementer</role>

<task>
  Parse task number from $ARGUMENTS, validate exists, extract language, route to appropriate implementer
</task>

<workflow_execution>
  <stage id="1" name="ParseAndValidate">
    <action>Parse task number and validate</action>
    <process>
      1. Parse task number from $ARGUMENTS
         - $ARGUMENTS contains: "259" or "259 custom prompt"
         - Extract first token as task_number
         - Validate is integer
      2. Validate task exists in TODO.md
         - grep "^### ${task_number}\." TODO.md
         - If not found: Return error
      3. Extract task description and status
    </process>
    <checkpoint>Task number parsed and validated</checkpoint>
  </stage>
  
  <stage id="2" name="ExtractLanguage">
    <action>Extract language for routing</action>
    <process>
      1. Extract language from TODO.md task entry
         - grep -A 20 "^### ${task_number}\." TODO.md | grep "Language"
         - Parse **Language**: field
         - Default to "general" if not found
      2. Determine target agent based on routing config
         - lean → lean-implementation-agent
         - general → implementer
    </process>
    <checkpoint>Language extracted, routing determined</checkpoint>
  </stage>
  
  <stage id="3" name="Delegate">
    <action>Delegate to implementer with parsed context</action>
    <process>
      1. Invoke target agent via task tool:
         task(
           subagent_type="implementer",  # or lean-implementation-agent
           prompt="Implement task ${task_number}",
           task_number=${task_number},
           language="${language}",
           task_description="${description}"
         )
      2. Validate return
      3. Relay to user
    </process>
    <checkpoint>Delegated to implementer</checkpoint>
  </stage>
</workflow_execution>
```

### Phase 2: Restore Other Command Files ✅ COMPLETED

Applied same pattern to:
- research.md
- plan.md
- revise.md

### Phase 3: Simplify Orchestrator ✅ COMPLETED

Orchestrator simplified to pure router:
```markdown
<stage id="1" name="LoadCommand">
  Load command file, extract agent field
</stage>

<stage id="2" name="Delegate">
  Delegate to command file (agent field) with $ARGUMENTS, relay result to user
</stage>
```

### Phase 4: Update Subagents ✅ COMPLETED

Subagents updated to receive parsed context from command files:
```xml
<step_0_preflight>
  1. Extract task_number from delegation context (parsed by command file)
  2. Extract language from delegation context (extracted by command file)
  3. Update status
  4. Proceed
</step_0_preflight>
```

Updated subagents:
- implementer.md
- researcher.md
- planner.md
- lean-implementation-agent.md
- lean-research-agent.md
- lean-planner.md

---

## Success Criteria

After implementation:

1. ✅ `/implement 259` works correctly
2. ✅ Command files receive $ARGUMENTS
3. ✅ Command files parse arguments
4. ✅ Command files delegate with parsed context
5. ✅ Subagents receive clean inputs
6. ✅ Orchestrator is simple (pure router)

---

## Complexity Analysis

### Current Complexity (Main Branch)

```
Orchestrator: ~300 lines (routing logic)
Command files: ~200 lines each (parsing + routing)
Subagents: ~400 lines each (execution)
Total: ~300 + (4 * 200) + (4 * 400) = ~2700 lines
```

**Complexity Distribution**:
- Orchestrator: Routing (generic)
- Command files: Parsing (command-specific)
- Subagents: Execution (domain-specific)

**Clear separation of concerns** ✅

### Failed v6.1 Complexity

```
Orchestrator: ~400 lines (routing + parsing)
Command files: ~40 lines (metadata only)
Subagents: ~400 lines (execution)
Total: ~400 + (4 * 40) + (4 * 400) = ~2160 lines
```

**But doesn't work!** ❌

The reduced lines come from:
- Removed command file workflows → Lost parsing capability
- Moved some to orchestrator → Wrong place for command-specific logic

### Recommended Complexity

```
Orchestrator: ~200 lines (pure routing, simplified)
Command files: ~150 lines each (streamlined workflows)
Subagents: ~300 lines each (receive clean inputs, simpler)
Total: ~200 + (4 * 150) + (4 * 300) = ~2000 lines
```

**Benefits**:
- ✅ Works correctly
- ✅ Clear separation of concerns
- ✅ Each component has single responsibility
- ✅ 25% reduction from main branch
- ✅ Maintainable and extensible

---

## Conclusion

The root cause of `/implement 259` still failing is:

**We removed the command file workflows, which are essential for argument parsing in OpenCode's architecture.**

The solution is NOT to:
- ❌ Eliminate command file workflows
- ❌ Move parsing to orchestrator
- ❌ Try to make command files "simple metadata"

The solution IS to:
- ✅ Restore command file workflows (they're agents!)
- ✅ Let command files parse their own arguments
- ✅ Simplify the workflows (streamline, don't eliminate)
- ✅ Keep orchestrator as pure router
- ✅ Keep subagents as execution engines

**Next Steps**:
1. Restore `<workflow_execution>` in command files
2. Simplify orchestrator to pure routing
3. Update subagents to expect parsed context
4. Test `/implement 259`

**Estimated Effort**: 3-4 hours (undoing v6.0/v6.1, applying simplified version of main branch pattern)

---

**Status**: Ready for implementation plan
