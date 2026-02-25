---
paths: .claude/**/*
---

# Workflow Rules

## Command Lifecycle

Every command follows: **Preflight** -> **Execute** -> **Postflight**

1. **Preflight**: Parse args, validate task, update status to "in progress", log session
2. **Execute**: Route by language, execute steps, track progress, handle errors
3. **Postflight**: Update status, create artifacts, git commit, return results

## Research Workflow

`/research N [focus]`
1. Validate task exists, status allows research
2. Update status `[RESEARCHING]`
3. Route by language (lean -> lean-lsp, other -> web/code)
4. Create report `research-{NNN}.md`
5. Update status `[RESEARCHED]`
6. Git commit

## Planning Workflow

`/plan N`
1. Load research and task description
2. Update status `[PLANNING]`
3. Create phases with steps
4. Write plan `implementation-{NNN}.md`
5. Update status `[PLANNED]`
6. Git commit

## Implementation Workflow

`/implement N`
1. Load plan, find resume point
2. Update status `[IMPLEMENTING]`
3. For each phase: Mark IN PROGRESS -> Execute steps -> Mark COMPLETED -> Git commit
4. Create summary
5. Update status `[COMPLETED]`
6. Final commit

## Resume Pattern

Scan phases: `[COMPLETED]` -> skip, `[PARTIAL]`/`[IN PROGRESS]` -> resume, `[NOT STARTED]` -> start

## Error Recovery

On error during phase:
1. Keep phase `[IN PROGRESS]`
2. Log to errors.json
3. Commit partial progress
4. Return partial with resume info
