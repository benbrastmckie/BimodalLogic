---
name: implement
agent: implementer
description: "Execute implementation with resume support and [COMPLETED] status"
timeout: 7200
routing:
  language_based: true
  lean: lean-implementation-agent
  default: implementer
---

# /implement - Implementation Command

Execute task implementations with plan-based or direct execution and automatic resume support.

## Usage

```bash
/implement TASK_NUMBER [PROMPT]
/implement 196
/implement 196 "Focus on error handling"
/implement 105-107
```

## What This Does

1. Routes to appropriate implementation agent based on task language
2. Agent executes implementation (plan-based or direct)
3. Creates implementation artifacts
4. Updates task status to [COMPLETED]
5. Creates git commit(s)

## Language-Based Routing

| Language | Agent | Tools |
|----------|-------|-------|
| lean | lean-implementation-agent | lean-lsp-mcp, lake build |
| meta | meta | File operations, delegation to meta subagents |
| general | implementer | File operations, git |

## Features

- **Resume Support**: Automatic resume from incomplete phases if plan exists
- **Batch Support**: Can implement multiple tasks sequentially (e.g., 105-107)
- **Plan-Based**: Follows implementation plan if exists, otherwise direct execution

See `.opencode/agent/subagents/implementer.md` for details.
