---
name: implement
agent: orchestrator
description: "Execute implementation with resume support and [COMPLETED] status"
context_level: 2
language: varies
routing:
  language_based: true
  lean: lean-implementation-agent
  default: implementer
timeout: 7200
context_loading:
  strategy: lazy
  index: ".opencode/context/index.md"
  required:
    - "core/standards/delegation.md"
    - "core/system/state-management.md"
    - "core/system/routing-guide.md"
    - "core/standards/command-argument-handling.md"
  optional:
    - "project/lean4/processes/end-to-end-proof-workflow.md"
  max_context_size: 50000
---

**Usage:** `/implement TASK_NUMBER [PROMPT]` or `/implement START-END [PROMPT]`

## Description

Executes task implementations with plan-based or direct execution, language-based routing to specialized agents, and automatic resume support for long-running operations.

## Workflow Setup

**Orchestrator handles (Stage 1-5):**
- **Stage 1 (PreflightValidation):** Parse task number or range from $ARGUMENTS, validate tasks exist
- **Stage 2 (DetermineRouting):** Extract language from task entry (state.json or TODO.md), map to agent using routing table, validate routing
- **Stage 3 (RegisterAndDelegate):** Register session and invoke target agent
- **Stage 4 (ValidateReturn):** Validate return format, verify artifacts exist and are non-empty
- **Stage 5 (PostflightCleanup):** Update session registry and relay result to user

**Implementer subagent handles:**
- Update status to [IMPLEMENTING] at beginning (preflight)
- Plan-based vs direct implementation
- Resume support (automatic detection of incomplete phases)
- Artifact creation (implementation files + summary)
- Update status to [COMPLETED] at end (postflight)
- Git commits (per-phase or single)

## Arguments

- `TASK_NUMBER` (required): Task number from TODO.md, or range (e.g., 105-107)
- `PROMPT` (optional): Custom implementation focus or instructions

## Examples

```bash
/implement 196                          # Implement task 196
/implement 196 "Focus on error handling"  # Implement with custom focus
/implement 105-107                      # Batch implement tasks 105-107
```

## Delegation

**Target Agent:** Type-based routing  
**Timeout:** 7200s (2 hours)  
**Type-Based Routing:** Yes

**Routing Rules:**
| Type | Agent | Tools |
|----------|-------|-------|
| lean | lean-implementation-agent | lean-lsp-mcp, lake build |
| meta | meta | File operations, git, delegation to meta subagents |
| markdown | implementer | File operations, git |
| python | implementer | File operations, git, python |
| general | implementer | File operations, git |

**Type Extraction (Orchestrator Stage 2):**
1. Priority 1: Project state.json (task-specific) - `.opencode/specs/{task_number}_*/state.json`
2. Priority 2: TODO.md task entry (**Type** field) - `grep -A 20 "^### {task_number}\."`
3. Priority 3: Default "general" (fallback) - If extraction fails

**Routing Validation (Orchestrator Stage 2):**
- Verify agent file exists at `.opencode/agent/subagents/{agent}.md`
- If type="lean": Agent must start with "lean-" (e.g., lean-implementation-agent)
- If type="meta": Agent must be "meta" (delegates to meta subagents)
- If type!="lean" and type!="meta": Agent must be "implementer"
- Log routing decision: `[INFO] Routing to {agent} (type={type})`

**Artifact Validation (Orchestrator Stage 4):**
- If status="completed": Artifacts array must be non-empty
- All artifact files must exist on disk
- All artifact files must be non-empty (size > 0 bytes)

**Implementer Responsibilities:**
- Update status to [IMPLEMENTING] at beginning (preflight)
- Detect plan existence and execute plan-based or direct implementation
- Resume from incomplete phases automatically
- Create implementation artifacts and summary
- Update status to [COMPLETED] at end (postflight)
- Update status atomically via status-sync-manager
- Create git commits via git-workflow-manager

## Quality Standards

**Atomic Updates:**
- TODO.md (status, timestamps, artifact links)
- state.json (status, timestamps, artifact_paths)
- Plan file (phase status markers if plan exists)

**Lazy Directory Creation:**
- `.opencode/specs/{number}_{slug}/` created when writing first artifact
- `summaries/` subdirectory created when writing summary

**Token Limits:**
- Summary artifacts: <100 tokens (~400 characters)
- Protects orchestrator context window from bloat

## Error Handling

**Task Not Found:**
```
Error: Task {task_number} not found in .opencode/specs/TODO.md
Recommendation: Verify task number exists in TODO.md
```

**Invalid Task Number:**
```
Error: Task must be integer or range (N-M). Got: {input}
Usage: /implement TASK_NUMBER [PROMPT]
```

**Task Already Completed:**
```
Error: Task {task_number} is already [COMPLETED]
Recommendation: Cannot re-implement completed tasks
```

**Implementation Timeout:**
```
Warning: Implementation timed out after 7200s
Status: Partial implementation may exist
Resume with: /implement {task_number}
```

**Type Extraction Failure:**
```
Warning: Could not extract type from task entry
Defaulting to: general (implementer agent)
Recommendation: Add **Type**: {type} to task entry in TODO.md
```

## Notes

- **Resume Support**: Automatic resume from incomplete phases if plan exists
- **Type-Based Routing**: Lean tasks route to lean-implementation-agent, meta tasks route to meta agent, others route to implementer
- **Batch Support**: Can implement multiple tasks sequentially (e.g., 105-107)
- **Git Workflow**: Per-phase commits for plan-based, single commit for direct
- **Context Window Protection**: Summary artifact for multi-file outputs

For detailed workflow documentation, see:
- `.opencode/agent/subagents/implementer.md`
- `.opencode/agent/subagents/lean-implementation-agent.md`
