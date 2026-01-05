# OpenCode Command Invocation Diagnostic & Refactor Plan

**Project**: ProofChecker OpenCode Integration Fix  
**Created**: 2026-01-04  
**Status**: DIAGNOSTIC - Root Cause Analysis  

## Problem Statement

User typed: `/implement 259`  
Expected behavior: Implementer receives "259" or "/implement 259" and parses task number  
Actual behavior: "The task tool returned a request for a task number. Since no task number was provided..."  

This indicates the argument "259" is NOT being passed to the implementer subagent.

---

## Root Cause Analysis

### The Disconnect: OpenCode's Invocation Model vs Our Architecture

#### How We THINK It Works (Based on Our Refactor)

```
User types: /implement 259
  ↓
OpenCode invokes orchestrator with prompt="/implement 259"
  ↓
Orchestrator passes "/implement 259" to implementer
  ↓
Implementer parses 259 from "/implement 259"
```

#### How It ACTUALLY Works (OpenCode Reality)

OpenCode has TWO distinct invocation paths:

**Path 1: Direct Agent Invocation** (What we see with `/implement 259`):
```
User types: /implement 259
  ↓
OpenCode reads command file frontmatter: agent: implementer
  ↓
OpenCode DIRECTLY invokes implementer (bypasses orchestrator!)
  ↓
Implementer receives: (UNKNOWN FORMAT - likely empty or malformed)
```

**Path 2: Orchestrator-Mediated Invocation** (What happens with agent: orchestrator):
```
User types: /implement 259
  ↓
OpenCode reads command file frontmatter: agent: orchestrator
  ↓
OpenCode invokes orchestrator with some representation of "/implement 259"
  ↓
Orchestrator delegates to implementer
  ↓
Implementer receives delegated prompt
```

### Evidence

1. **Command file frontmatter**: Our refactored command files have `agent: implementer` (direct)
   - `/implement` → `agent: implementer` (DIRECT INVOCATION)
   - `/research` → `agent: researcher` (DIRECT INVOCATION)
   - `/plan` → `agent: planner` (DIRECT INVOCATION)

2. **OpenAgents pattern**: Their commands use `agent: subagents/specs/research-agent`
   - This is still a DIRECT invocation to the research-agent
   - But OpenAgents commands have **completely different semantics**
   - `/research "topic"` (natural language) vs `/research 259` (task number)

3. **Old ProofChecker pattern**: Before refactor, we had `agent: orchestrator`
   - All commands routed THROUGH orchestrator
   - Orchestrator parsed task number and formatted as "Task: 259"
   - Then delegated to subagent

### The Real Issue

**We changed command files to use `agent: {subagent}` (direct invocation) but:**
1. OpenCode doesn't know how to pass arguments to directly-invoked subagents
2. Subagents expect to receive the full prompt (e.g., "/implement 259")
3. But OpenCode might be invoking them with NO arguments or with a different format

**The old `agent: orchestrator` pattern worked because:**
1. Orchestrator was invoked as the primary agent
2. Orchestrator had access to `$ARGUMENTS` variable
3. Orchestrator could format and delegate

---

## The Fundamental Misunderstanding

### What We Modeled After (OpenAgents)

OpenAgents uses a **topic-based argument pattern**:
- `/research "{topic}"` - Research takes a natural language topic
- `/implement "{update}"` - Implement takes a progress update
- `/plan "{description}"` - Plan takes a feature description

**These are fundamentally different from task-number-based commands.**

### What ProofChecker Actually Needs

ProofChecker uses a **task-number-based pattern**:
- `/research TASK_NUMBER` - Research a specific task from TODO.md
- `/implement TASK_NUMBER` - Implement a specific task from TODO.md
- `/plan TASK_NUMBER` - Plan a specific task from TODO.md

**Task numbers must be extracted and validated against TODO.md.**

---

## Root Cause: Conflation of Two Different Patterns

### Pattern A: Topic-Based Commands (OpenAgents)
```markdown
---
agent: subagents/specs/research-agent
---

Usage: /research "{topic}"
```

**Characteristics**:
- Takes natural language input
- No validation against TODO.md needed
- Subagent creates NEW project/research
- No task number involved

### Pattern B: Task-Based Commands (ProofChecker)
```markdown
---
agent: orchestrator  # MUST route through orchestrator!
---

Usage: /research TASK_NUMBER
```

**Characteristics**:
- Takes integer task number
- MUST validate against TODO.md
- MUST extract language/metadata from task
- MUST delegate to appropriate subagent (lean vs general)
- Subagent works on EXISTING task

**These are fundamentally incompatible patterns!**

---

## Why Our Refactor Failed

We tried to adopt OpenAgents' **simplified orchestrator** but kept ProofChecker's **task-based semantics**.

### The Incompatibility

| Aspect | OpenAgents | ProofChecker (Our Refactor) | Result |
|--------|------------|------------------------------|--------|
| Command arg | Topic string | Task number | ❌ Mismatch |
| Agent field | `subagents/...` | `implementer` | ❌ Direct invocation breaks |
| Validation | None needed | TODO.md lookup | ❌ Who validates? |
| Routing | Simple | Language-based | ❌ Who routes? |
| Orchestrator role | Keyword routing | Task validation + delegation | ❌ Conflicting roles |

### What Went Wrong

1. **Step 1 (Orchestrator)**: We removed argument parsing from orchestrator
   - But orchestrator is the ONLY component that has access to `$ARGUMENTS`!
   - Subagents receive prompt from task tool, not `$ARGUMENTS`

2. **Step 2 (Command files)**: We changed `agent: orchestrator` → `agent: implementer`
   - This bypasses orchestrator entirely!
   - OpenCode directly invokes implementer
   - Implementer has no way to receive task number

3. **Step 3 (Subagents)**: We simplified Step 0 to parse from prompt
   - But prompt is empty or malformed when directly invoked!
   - Only works when delegated through orchestrator

---

## The Correct Architecture for ProofChecker

### Option 1: Keep Orchestrator-Mediated Pattern (RECOMMENDED)

**Command files MUST use `agent: orchestrator`**:

```markdown
---
name: implement
agent: orchestrator  # ← CRITICAL
description: "Execute implementation"
---
```

**Orchestrator workflow**:
1. Receive command invocation with `$ARGUMENTS = "259"`
2. Extract task number: `259`
3. Validate task exists in TODO.md
4. Extract language from task metadata
5. Determine target agent (lean-implementation-agent vs implementer)
6. Delegate to agent with formatted context

**Subagent receives**:
- Clean, validated task number
- Task metadata (language, description, etc.)
- Original prompt for reference

### Option 2: Adopt Topic-Based Pattern (NOT RECOMMENDED)

Completely redesign ProofChecker commands to be topic-based:

```bash
/research "Investigate modal logic completeness proofs"
# Creates new task in TODO.md
# No pre-existing task number needed
```

**Requires**:
- Complete redesign of workflow
- Lose integration with TODO.md task tracking
- Massive breaking change

---

## Proposed Solution: Hybrid Architecture

### Keep What Works from v6.0 Refactor

1. ✅ **Simplified orchestrator** (3 stages, not 5)
2. ✅ **No prompt reformatting** (don't change "259" to "Task: 259")
3. ✅ **Minimal documentation** (command files are concise)
4. ✅ **Subagent ownership** (subagents own their workflows)

### Restore What's Required for Task-Based Pattern

1. ✅ **Orchestrator argument extraction** (parse task number from `$ARGUMENTS`)
2. ✅ **Orchestrator task validation** (check TODO.md)
3. ✅ **Orchestrator language routing** (lean vs general)
4. ✅ **Command files route to orchestrator** (`agent: orchestrator`)
5. ✅ **Orchestrator delegates with validated context**

### New Hybrid Workflow

```
User types: /implement 259
  ↓
OpenCode invokes orchestrator (agent: orchestrator in command file)
  ↓
Orchestrator Stage 1: Extract & Validate
  - Parse task_number from $ARGUMENTS: "259"
  - Validate task exists in TODO.md
  - Extract language from task metadata
  ↓
Orchestrator Stage 2: Route
  - Determine target agent (lean-implementation-agent or implementer)
  ↓
Orchestrator Stage 3: Delegate
  - Invoke target agent via task tool
  - Pass: task_number=259, language="lean", task_description="..."
  - Agent receives CLEAN, VALIDATED context
  ↓
Subagent executes with validated inputs
```

**Key Differences from Old v5.0**:
- ✅ No prompt reformatting ("259" not "Task: 259")
- ✅ Simpler orchestrator (3 stages, not 5)
- ✅ Pass structured context, not reformatted string
- ✅ Subagent doesn't re-parse (receives clean inputs)

**Key Differences from v6.0 Refactor**:
- ❌ Orchestrator DOES parse task number (it's the only component that can!)
- ❌ Orchestrator DOES validate task (required for task-based pattern)
- ❌ Command files route to orchestrator (not direct to subagent)
- ✅ Subagent receives validated context (not raw prompt to parse)

---

## Implementation Plan

### Phase 1: Restore Orchestrator-Mediated Routing

**Tasks**:
1. Update command files: `agent: implementer` → `agent: orchestrator`
   - implement.md
   - research.md
   - plan.md
   - revise.md

2. Update orchestrator Stage 1: Add argument extraction
   ```xml
   <stage id="1" name="ExtractAndValidate">
     1. Parse task_number from $ARGUMENTS
     2. Validate task exists in TODO.md
     3. Extract language from task metadata
     4. Generate session_id
   </stage>
   ```

3. Update orchestrator Stage 2: Add routing logic
   ```xml
   <stage id="2" name="Route">
     1. Determine target agent based on language
     2. Prepare delegation context with validated inputs
   </stage>
   ```

4. Update orchestrator Stage 3: Delegate with clean context
   ```xml
   <stage id="3" name="Delegate">
     1. Invoke target agent with:
        - task_number: 259
        - language: "lean"
        - task_description: "..."
     2. Validate return
     3. Relay to user
   </stage>
   ```

### Phase 2: Simplify Subagent Step 0

**Tasks**:
1. Update subagent Step 0 to receive delegation context
   ```xml
   <step_0_preflight>
     1. Extract task_number from delegation_context (already validated!)
     2. Extract language from delegation_context
     3. Update status to [IMPLEMENTING]
     4. Proceed to execution
   </step_0_preflight>
   ```

2. Remove redundant validation (orchestrator already validated)
3. Remove parsing (orchestrator already extracted)

### Phase 3: Update Documentation

**Tasks**:
1. Document the hybrid architecture
2. Clarify: ProofChecker ≠ OpenAgents (different argument patterns)
3. Update creating-commands.md with correct pattern

---

## Key Insights

### Why OpenAgents Pattern Doesn't Apply to ProofChecker

| Aspect | OpenAgents | ProofChecker | Conclusion |
|--------|------------|--------------|------------|
| **Workflow** | Topic → Research → Plan → Implement | Task exists first, then research → plan → implement | Different |
| **Arguments** | Natural language strings | Integer task numbers | Incompatible |
| **Validation** | None | TODO.md lookup required | Orchestrator needed |
| **Routing** | Keyword-based | Language-based (lean vs general) | Complex routing |
| **State** | Creates new projects | Works on existing tasks | Different lifecycle |

**Conclusion**: We cannot blindly copy OpenAgents patterns. ProofChecker's task-based workflow requires orchestrator-mediated routing.

### The Role of the Orchestrator

**OpenAgents Orchestrator**:
- Routes based on keywords (Lean-related → lean-orchestrator)
- Very simple, almost pass-through
- No argument parsing needed

**ProofChecker Orchestrator**:
- Extracts and validates task numbers (required!)
- Looks up tasks in TODO.md (required!)
- Extracts language metadata (required for routing!)
- Routes to language-specific agents (lean vs general)
- **Cannot be eliminated for task-based commands**

### What We Can Learn from OpenAgents

1. ✅ **Keep orchestrator simple** (3 stages, not 5)
2. ✅ **Don't reformat prompts** (no "Task: 259" nonsense)
3. ✅ **Minimal documentation** (concise command files)
4. ✅ **Clear separation** (orchestrator routes, subagents execute)
5. ❌ **But keep orchestrator for task-based pattern** (required!)

---

## Success Criteria

### After Implementation

1. ✅ User types `/implement 259`
2. ✅ Orchestrator extracts task_number=259 from $ARGUMENTS
3. ✅ Orchestrator validates task 259 exists
4. ✅ Orchestrator extracts language="lean" from task metadata
5. ✅ Orchestrator routes to lean-implementation-agent
6. ✅ Subagent receives validated context (no re-parsing!)
7. ✅ Implementation proceeds normally

### Architecture Validation

1. ✅ Command files route through orchestrator (`agent: orchestrator`)
2. ✅ Orchestrator has 3 simple stages (not 5 complex ones)
3. ✅ Orchestrator extracts, validates, routes (core responsibilities)
4. ✅ Subagents receive clean, validated inputs (no re-parsing)
5. ✅ No prompt reformatting ("259" stays as "259")
6. ✅ Documentation is accurate and concise

---

## Conclusion

The v6.0 refactor failed because we tried to eliminate the orchestrator's core responsibilities (argument extraction and validation) which are **essential for task-based commands**.

The fix is a **hybrid approach**:
- Keep the simplifications from v6.0 (3 stages, no reformatting, minimal docs)
- Restore the essential orchestrator responsibilities (extract, validate, route)
- Pass clean, validated context to subagents (not raw prompts to re-parse)

This gives us the best of both worlds:
- ✅ Simple orchestrator (like OpenAgents)
- ✅ Task-based workflow (ProofChecker's core pattern)
- ✅ No redundant parsing (orchestrator extracts once, subagent receives clean input)
- ✅ Maintainable and clear

---

**Next Steps**:
1. Review and approve this diagnostic
2. Implement Phase 1 (restore orchestrator-mediated routing)
3. Implement Phase 2 (simplify subagent Step 0 to use validated inputs)
4. Implement Phase 3 (update documentation)
5. Test with `/implement 259`

**Estimated Effort**: 2-3 hours (much less than original refactor)

**Risk**: Low (we're partially reverting to known-working patterns while keeping the good parts of v6.0)
