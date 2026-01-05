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
  Parse task number from $ARGUMENTS, lookup task in state.json, extract metadata, route to appropriate planner based on language
</task>

<workflow_execution>
  <stage id="1" name="ParseAndValidate">
    <action>Parse task number and lookup in state.json</action>
    <process>
      1. Parse task number and flags from $ARGUMENTS
         - $ARGUMENTS contains: "196" or "196 Focus on phase breakdown" or "196 --force"
         - Extract first token as task_number
         - Validate is integer
         - Check for --force flag in remaining arguments
         - If --force present: force_mode=true, log warning "Using --force flag to override validation"
         - Else: force_mode=false
      
      2. Validate state.json exists and is valid
         - Check .opencode/specs/state.json exists
         - Validate is valid JSON with jq
         - If missing/corrupt: Return error "Run /meta to regenerate state.json"
      
      3. Lookup task in state.json
         - Use jq to find task by project_number:
           task_data=$(jq -r --arg num "$task_number" \
             '.active_projects[] | select(.project_number == ($num | tonumber))' \
             .opencode/specs/state.json)
         - If task_data is empty: Return error "Task $task_number not found"
      
      4. Extract all metadata at once
         - language=$(echo "$task_data" | jq -r '.language // "general"')
         - status=$(echo "$task_data" | jq -r '.status')
         - project_name=$(echo "$task_data" | jq -r '.project_name')
         - description=$(echo "$task_data" | jq -r '.description // ""')
         - priority=$(echo "$task_data" | jq -r '.priority')
         - plan_path=$(echo "$task_data" | jq -r '.plan_path // ""')
      
      5. Validate task status allows planning (skip if --force flag present)
         - If force_mode == false:
           case "$status" in
             "completed")
               echo "Error: Task $task_number already completed"
               echo "Recommendation: Task is done, no planning needed"
               echo "To override: /plan $task_number --force"
               exit 1
               ;;
             "abandoned")
               echo "Error: Task $task_number is abandoned"
               echo "Recommendation: Un-abandon task before planning"
               echo "To override: /plan $task_number --force"
               exit 1
               ;;
             "planning")
               echo "Warning: Task $task_number is already being planned"
               echo "If this is a stale status (e.g., previous planning crashed):"
               echo "  1. Check for existing plan artifacts"
               echo "  2. Use /sync to reset status if needed"
               echo "To override: /plan $task_number --force"
               exit 1
               ;;
             "planned")
               echo "Info: Task $task_number already has a plan"
               echo "Plan: $plan_path"
               echo "Recommendation: Use /revise $task_number to update plan"
               echo "To override: /plan $task_number --force"
               exit 0
               ;;
             "not_started"|"researched"|"blocked"|"partial")
               # Status allows planning, proceed
               ;;
             *)
               echo "Warning: Unknown status '$status' for task $task_number"
               echo "Proceeding with planning, but status may be invalid"
               ;;
           esac
         - Else (force_mode == true):
           echo "WARNING: Using --force flag to override status validation"
           echo "Current status: $status"
           echo "Proceeding with planning despite status"
      
      6. Check if plan already exists (warn if it does)
         - If plan_path is not empty: Warn "Plan exists at $plan_path. Use /revise to update."
      
      7. Extract custom prompt from $ARGUMENTS if present
         - If $ARGUMENTS has multiple tokens: custom_prompt = remaining tokens
         - Else: custom_prompt = ""
      
      8. Determine target agent based on language
         - lean → lean-planner
         - general → planner
    </process>
    <checkpoint>Task validated, metadata extracted, target agent determined</checkpoint>
  </stage>
  
  <stage id="2" name="Delegate">
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

**Plan command handles (Stage 1-2):**
- **Stage 1 (ParseAndValidate):** Parse task number, lookup in state.json (8x faster), extract all metadata, validate, determine target agent
- **Stage 2 (Delegate):** Invoke target planner and relay result to user

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
- `--force` (optional): Override status validation (advanced users only)

## Examples

```bash
/plan 196                          # Create plan for task 196
/plan 196 "Focus on phase breakdown"  # Create plan with custom focus
/plan 196 --force                  # Override status validation
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
