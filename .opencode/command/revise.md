---
name: revise
agent: planner
description: "Create new plan versions with [REVISED] status"
timeout: 1800
routing:
  language_based: true
  lean: lean-planner
  default: planner
---

# /revise - Plan Revision Command

Create new plan versions for tasks with existing plans, preserving all previous versions.

## Usage

```bash
/revise TASK_NUMBER [PROMPT]
/revise 196
/revise 196 "Adjust phase breakdown"
```

## What This Does

1. Routes to appropriate planner based on task language
2. Agent creates new plan version (increments version number)
3. Preserves all previous plan versions
4. Updates task status to [REVISED]
5. Creates git commit

## Language-Based Routing

| Language | Agent | Features |
|----------|-------|----------|
| lean | lean-planner | Proof strategies, mathlib integration |
| general | planner | Standard implementation planning |

## Version Management

- Original plan files never modified
- New plan version created as separate file
- All plan versions preserved in plans/ directory
- TODO.md plan link updated to point to latest version

See `.opencode/agent/subagents/planner.md` for details.
