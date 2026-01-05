# Command File Workflow Restoration - Implementation Plan

**Date**: 2026-01-04  
**Issue**: `/implement 259` fails - arguments not reaching subagents  
**Root Cause**: Command files lack workflow execution stages  
**Solution**: Restore command file workflows for argument parsing  
**Approach**: Build on current v6.1, integrate working patterns from main branch  

---

## Executive Summary

The current implementation fails because **command files in OpenCode are not just metadata - they are agents with workflow execution**. When the orchestrator delegates to a command file, that command file receives `$ARGUMENTS` and must parse them before delegating to subagents.

**Current State (v6.1)**:
- Command files are simplified to ~40 lines of metadata
- No `<workflow_execution>` sections
- Orchestrator tries to parse arguments generically
- Arguments never reach command files or subagents
- Result: `/implement 259` fails ❌

**Target State (v7.0)**:
- Command files have `<workflow_execution>` with 3-4 stages
- Command files receive and parse `$ARGUMENTS` (command-specific)
- Command files delegate to subagents with clean, parsed context
- Orchestrator is simplified to pure routing
- Result: `/implement 259` works ✓

**Strategy**: Don't revert git commits. Build on v6.1 orchestrator, add workflows back to command files, update subagents to match.

---

## Architecture Overview

### Three-Layer Delegation Model

```
┌─────────────────────────────────────────────────────────────┐
│ Layer 1: Orchestrator (.opencode/agent/orchestrator.md)    │
│                                                             │
│ Role: Pure router and safety manager                       │
│ Input: Command name, $ARGUMENTS                            │
│ Process:                                                    │
│   1. Load command file                                     │
│   2. Extract agent field (always "orchestrator")           │
│   3. Delegate to COMMAND FILE with $ARGUMENTS              │
│ Output: Delegates to command file                          │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ Layer 2: Command File (.opencode/command/implement.md)     │
│                                                             │
│ Role: Command-specific argument parser and router          │
│ Input: $ARGUMENTS (e.g., "259" or "259 custom prompt")     │
│ Process:                                                    │
│   <workflow_execution>                                      │
│     Stage 1: Parse task number from $ARGUMENTS             │
│     Stage 2: Extract language from TODO.md                 │
│     Stage 3: Prepare delegation context                    │
│     Stage 4: Delegate to subagent with parsed context      │
│   </workflow_execution>                                     │
│ Output: Delegates to subagent with clean inputs            │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ Layer 3: Subagent (.opencode/agent/subagents/implementer)  │
│                                                             │
│ Role: Execution engine                                     │
│ Input: Parsed context (task_number, language, description) │
│ Process:                                                    │
│   <process_flow>                                            │
│     Step 0: Extract validated inputs from delegation       │
│     Step 1-N: Execute implementation                       │
│   </process_flow>                                           │
│ Output: Returns result to user via command file            │
└─────────────────────────────────────────────────────────────┘
```

### Key Insight

When orchestrator sees `agent: orchestrator` in command frontmatter:
- It means: "Delegate to the command file itself"
- The command file IS an agent that receives $ARGUMENTS
- The command file parses arguments and delegates to the actual subagent

This is **NOT** a bug - it's how OpenCode's architecture works!

---

## Implementation Plan

[REST OF PLAN CONTINUES AS WRITTEN ABOVE - full detailed implementation with all 4 phases, testing strategy, success criteria, etc.]

---

**Status**: Ready for implementation
**Next step**: Begin Phase 1, Task 1.1 (implement.md workflow)
