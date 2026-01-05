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

**Task Input (required):** $ARGUMENTS

<context>
  <system_context>Planning command with language-based routing</system_context>
  <task_context>Parse task number, validate, extract language, delegate to planner</task_context>
</context>

<role>Planning command agent - Parse arguments and route to appropriate planner</role>

<task>
  Parse task number from $ARGUMENTS, validate task exists in TODO.md, extract language, route to appropriate planner based on language
</task>

<workflow_execution>
  <stage id="1" name="ParseAndValidate">
    <action>Parse task number and validate</action>
    <process>
      1. Parse task number from $ARGUMENTS
         - $ARGUMENTS contains: "196" or "196 Focus on phase breakdown"
         - Extract first token as task_number
         - Validate is integer
      2. Validate task exists in .opencode/specs/TODO.md
         - Read TODO.md and search for task entry
         - Format: "### ${task_number}."
         - If not found: Return error message
      3. Extract task description and current status
      4. Check if plan already exists (warn if it does)
    </process>
    <checkpoint>Task number parsed and validated</checkpoint>
  </stage>
  
  <stage id="2" name="ExtractLanguage">
    <action>Extract language for routing</action>
    <process>
      1. Extract language from TODO.md task entry
         - Look for **Language**: field in task entry
         - Parse language value (lean, general, etc.)
         - Default to "general" if not found
      2. Determine target agent based on routing config
         - lean → lean-planner
         - general → planner
    </process>
    <checkpoint>Language extracted, target agent determined</checkpoint>
  </stage>
  
  <stage id="3" name="PrepareContext">
    <action>Prepare delegation context</action>
    <process>
      1. Extract custom prompt from $ARGUMENTS if present
         - If $ARGUMENTS contains multiple tokens, rest is custom prompt
      2. Prepare task context object:
         - task_number: parsed number
         - language: extracted language
         - description: task description from TODO.md
         - custom_prompt: optional custom prompt from user
    </process>
    <checkpoint>Context prepared for delegation</checkpoint>
  </stage>
  
  <stage id="4" name="Delegate">
    <action>Delegate to planner with parsed context</action>
    <process>
      1. Invoke target agent via task tool:
         task(
           subagent_type="${target_agent}",
           prompt="Create implementation plan for task ${task_number}: ${description}. ${custom_prompt}",
           description="Plan task ${task_number}"
         )
      2. Wait for planner to complete
      3. Relay result to user
    </process>
    <checkpoint>Delegated to planner, result relayed</checkpoint>
  </stage>
</workflow_execution>

**Usage:** `/plan TASK_NUMBER [PROMPT]`

## Description

Creates implementation plans with phased breakdown, effort estimates, and research integration. Supports language-based routing: Lean tasks route to lean-planner (with proof strategies and mathlib integration), general tasks route to planner.

## Command Workflow

**Plan command handles (Stage 1-4):**
- **Stage 1 (ParseAndValidate):** Parse task number from $ARGUMENTS, validate task exists
- **Stage 2 (ExtractLanguage):** Extract language from task entry, map to agent (lean → lean-planner, general → planner)
- **Stage 3 (PrepareContext):** Prepare delegation context with parsed data
- **Stage 4 (Delegate):** Invoke target planner and relay result to user

**Planner/Lean-planner subagent handles:**
- Update status to [PLANNING] at beginning (preflight)
- Research integration (automatic harvesting from TODO.md)
- Phase breakdown (1-2 hours per phase target)
- Effort estimation
- Plan template compliance
- Update status to [PLANNED] at end (postflight)
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
- Update status to [PLANNING] at beginning (preflight)
- Harvest research artifacts from TODO.md links
- Create phased implementation plan
- Follow plan.md template standard
- Update status to [PLANNED] at end (postflight)
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
