---
name: plan
agent: orchestrator
description: "Create implementation plans with [PLANNED] status"
context_level: 2
language: markdown
routing:
  language_based: true
  lean: lean-planner
  default: planner
timeout: 1800
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

**Usage:** `/plan TASK_NUMBER [PROMPT]`

## Description

Creates implementation plans with phased breakdown, effort estimates, and research integration. Supports language-based routing: Lean tasks route to lean-planner (with proof strategies and mathlib integration), general tasks route to planner.

## Workflow Setup

**Orchestrator handles (Stage 1-5):**
- **Stage 1 (PreflightValidation):** Parse task number from $ARGUMENTS, validate task exists
- **Stage 2 (DetermineRouting):** Extract language from task entry (state.json or TODO.md), map to agent (lean → lean-planner, general → planner)
- **Stage 3 (RegisterAndDelegate):** Register session and invoke target planner
- **Stage 4 (ValidateReturn):** Validate return format, verify plan artifact exists
- **Stage 5 (PostflightCleanup):** Update session registry and relay result to user

**Planner/Lean-planner subagent handles:**
- Research integration (automatic harvesting from TODO.md)
- Phase breakdown (1-2 hours per phase target)
- Effort estimation
- Plan template compliance
- Status updates ([PLANNING] → [PLANNED])
- Git commits

## Arguments

- `TASK_NUMBER` (required): Task number from TODO.md
- `PROMPT` (optional): Custom planning focus or instructions

## Examples

```bash
/plan 196                          # Create plan for task 196
/plan 196 "Focus on phase breakdown"  # Create plan with custom focus
```

## Delegation

**Target Agent:** `planner` (`.opencode/agent/subagents/planner.md`)  
**Timeout:** 1800s (30 minutes)  
**Language-Based Routing:** No (always routes to planner)

**Planner Responsibilities:**
- Harvest research artifacts from TODO.md links
- Create phased implementation plan
- Follow plan.md template standard
- Update status atomically via status-sync-manager
- Create git commit via git-workflow-manager

## Quality Standards

**Plan Template Compliance:**
- Metadata section with all required fields
- Phase breakdown with [NOT STARTED] markers
- Acceptance criteria per phase
- Effort estimates (1-2 hours per phase)
- Success metrics

**Atomic Updates:**
- TODO.md (status, timestamps, plan link)
- state.json (status, timestamps, plan_path, plan_metadata)
- Project state.json (lazy created if needed)

**Lazy Directory Creation:**
- `.opencode/specs/{number}_{slug}/` created when writing plan
- `plans/` subdirectory created when writing implementation-001.md

## Error Handling

**Task Not Found:**
```
Error: Task {task_number} not found in .opencode/specs/TODO.md
Recommendation: Verify task number exists in TODO.md
```

**Invalid Task Number:**
```
Error: Task number must be an integer. Got: {input}
Usage: /plan TASK_NUMBER [PROMPT]
```

**Task Already Completed:**
```
Error: Task {task_number} is already [COMPLETED]
Recommendation: Cannot plan completed tasks
```

**Plan Already Exists:**
```
Warning: Plan already exists for task {task_number}
Existing plan: {plan_path}
Recommendation: Use /revise {task_number} to update existing plan
```

**Planning Timeout:**
```
Error: Planning timed out after 1800s
Status: Partial plan may exist
Recommendation: Resume with /plan {task_number}
```

## Notes

- **Research Harvesting**: Planner automatically loads research artifacts from TODO.md links
- **Phase Sizing**: Phases kept small (1-2 hours each) for manageable execution
- **Template Compliance**: All plans follow plan.md standard exactly
- **Atomic Updates**: status-sync-manager ensures consistency across files
- **Git Workflow**: Delegated to git-workflow-manager for standardized commits

For detailed workflow documentation, see:
- `.opencode/context/project/lean4/processes/end-to-end-proof-workflow.md`
- `.opencode/agent/subagents/planner.md`
