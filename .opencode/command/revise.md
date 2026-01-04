---
name: revise
agent: orchestrator
description: "Create new plan versions with [REVISED] status"
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
    - "core/standards/subagent-return-format.md"
    - "core/workflows/status-transitions.md"
    - "core/system/routing-guide.md"
  optional:
    - "project/lean4/processes/end-to-end-proof-workflow.md"
  max_context_size: 50000
---

**Usage:** `/revise TASK_NUMBER [PROMPT]`

## Description

Creates new plan versions for tasks with existing plans. Supports language-based routing: Lean tasks route to lean-planner (with proof strategies and mathlib integration), general tasks route to planner. Increments version number, preserves all previous versions, and updates task status to [REVISED].

## Workflow Setup

**Orchestrator handles (Stage 1-5):**
- **Stage 1 (PreflightValidation):** Parse task number from $ARGUMENTS, validate task exists and has existing plan
- **Stage 2 (DetermineRouting):** Extract language from task entry (state.json or TODO.md), map to agent (lean → lean-planner, general → planner)
- **Stage 3 (RegisterAndDelegate):** Register session and invoke target planner with revision context
- **Stage 4 (ValidateReturn):** Validate return format, verify plan artifact exists
- **Stage 5 (PostflightCleanup):** Update session registry and relay result to user

**Planner/Lean-planner subagent handles:**
- Plan revision (creates new version, preserves old)
- Version management (increments version number)
- Research integration (if new research available)
- Phase breakdown updates
- Status updates ([REVISING] → [REVISED])
- Git commits

## Arguments

- `TASK_NUMBER` (required): Task number from TODO.md
- `PROMPT` (optional): Revision reason or focus

## Examples

```bash
/revise 196                                      # Create new plan version
/revise 196 "Adjust phase breakdown"             # Revise with specific reason
```

## Delegation

**Target Agent:** `planner` (`.opencode/agent/subagents/planner.md`)  
**Timeout:** 1800s (30 minutes)  
**Language-Based Routing:** No (always routes to planner)

**Planner Responsibilities:**
- Create new plan version (implementation-00N.md)
- Preserve all previous plan versions
- Incorporate new research if available
- Update status atomically via status-sync-manager
- Create git commit via git-workflow-manager

## Quality Standards

**Plan Preservation:**
- Original plan files never modified
- New plan version created as separate file
- All plan versions preserved in plans/ directory
- TODO.md plan link updated to point to latest version

**Version Management:**
- implementation-001.md (first plan)
- implementation-002.md (first revision)
- implementation-003.md (second revision)
- etc.

**Atomic Updates:**
- TODO.md (status, timestamps, plan link to new version)
- state.json (status, timestamps, plan_path, plan_metadata)

## Error Handling

**Task Not Found:**
```
Error: Task {task_number} not found in .opencode/specs/TODO.md
Recommendation: Verify task number exists in TODO.md
```

**Invalid Task Number:**
```
Error: Task number must be an integer. Got: {input}
Usage: /revise TASK_NUMBER [PROMPT]
```

**No Existing Plan:**
```
Error: Task {task_number} has no existing plan
Recommendation: Use /plan {task_number} to create initial plan
```

**Version Already Exists:**
```
Error: Plan version {version} already exists for task {task_number}
Existing plan: {plan_path}
Recommendation: Check plan directory for existing versions
```

**Revision Timeout:**
```
Error: Plan revision timed out after 1800s
Status: Partial revision may exist
Recommendation: Resume with /revise {task_number}
```

## Notes

- **Version Management**: Plans versioned sequentially (001, 002, 003, etc.)
- **Plan Preservation**: Original plans never modified, all versions preserved
- **Research Integration**: Planner can incorporate new research if available
- **Atomic Updates**: status-sync-manager ensures consistency across files
- **Git Workflow**: Delegated to git-workflow-manager for standardized commits

For detailed workflow documentation, see:
- `.opencode/agent/subagents/planner.md`
