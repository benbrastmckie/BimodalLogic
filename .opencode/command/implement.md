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
    - "core/standards/subagent-return-format.md"
    - "core/workflows/status-transitions.md"
    - "core/system/routing-guide.md"
  optional:
    - "project/lean4/processes/end-to-end-proof-workflow.md"
  max_context_size: 50000
---

**Usage:** `/implement TASK_NUMBER [PROMPT]` or `/implement START-END [PROMPT]`

## Description

Executes task implementations with plan-based or direct execution, language-based routing to specialized agents, and automatic resume support for long-running operations.

## Workflow Setup

**Orchestrator handles:**
- Parse task number or range from arguments
- Validate tasks exist and are not [COMPLETED]
- Extract language for routing (lean → lean-implementation-agent, others → implementer)
- Delegate to appropriate implementer agent
- Validate return format
- Relay result to user

**Implementer subagent handles:**
- Plan-based vs direct implementation
- Resume support (automatic detection of incomplete phases)
- Artifact creation (implementation files + summary)
- Status updates ([IMPLEMENTING] → [COMPLETED])
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

**Target Agent:** Language-based routing  
**Timeout:** 7200s (2 hours)  
**Language-Based Routing:** Yes

**Routing Rules:**
| Language | Agent | Tools |
|----------|-------|-------|
| lean | lean-implementation-agent | lean-lsp-mcp, lake build |
| markdown | implementer | File operations, git |
| python | implementer | File operations, git, python |
| general | implementer | File operations, git |

**Implementer Responsibilities:**
- Detect plan existence and execute plan-based or direct implementation
- Resume from incomplete phases automatically
- Create implementation artifacts and summary
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

**Language Extraction Failure:**
```
Warning: Could not extract language from task entry
Defaulting to: general (implementer agent)
Recommendation: Add **Language**: {language} to task entry in TODO.md
```

## Notes

- **Resume Support**: Automatic resume from incomplete phases if plan exists
- **Language Routing**: Lean tasks route to lean-implementation-agent with specialized tools
- **Batch Support**: Can implement multiple tasks sequentially (e.g., 105-107)
- **Git Workflow**: Per-phase commits for plan-based, single commit for direct
- **Context Window Protection**: Summary artifact for multi-file outputs

For detailed workflow documentation, see:
- `.opencode/agent/subagents/implementer.md`
- `.opencode/agent/subagents/lean-implementation-agent.md`
