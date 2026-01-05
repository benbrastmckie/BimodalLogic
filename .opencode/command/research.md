---
name: research
agent: orchestrator
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
