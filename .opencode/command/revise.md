---
name: revise
agent: orchestrator
description: "Create new plan versions with [REVISED] status"
timeout: 1800
routing:
  language_based: true
  lean: lean-planner
  default: planner
---

**Task Input (required):** $ARGUMENTS

<context>
  <system_context>Plan revision command with language-based routing</system_context>
  <task_context>Parse task number, validate, extract language, delegate to planner for revision</task_context>
</context>

<role>Revision command agent - Parse arguments and route to appropriate planner for plan revision</role>

<task>
  Parse task number from $ARGUMENTS, lookup task in state.json, validate existing plan exists, extract metadata, route to appropriate planner for creating new plan version
</task>

<workflow_execution>
  <stage id="1" name="ParseAndValidate">
    <action>Parse task number and lookup in state.json</action>
    <process>
      1. Parse task number from $ARGUMENTS
         - $ARGUMENTS contains: "196" or "196 Adjust phase breakdown"
         - Extract first token as task_number
         - Validate is integer
      
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
      
      5. Validate existing plan exists
         - If plan_path is empty: Return error "No plan exists. Use /plan $task_number first."
         - Verify plan file exists at plan_path
      
      6. Extract custom prompt from $ARGUMENTS if present
         - If $ARGUMENTS has multiple tokens: custom_prompt = remaining tokens
         - Else: custom_prompt = ""
      
      7. Determine target agent based on language
         - lean → lean-planner
         - general → planner
    </process>
    <checkpoint>Task validated, plan exists, metadata extracted, target agent determined</checkpoint>
  </stage>
  
  <stage id="2" name="Delegate">
    <action>Delegate to planner with parsed context</action>
    <process>
      1. Invoke target agent via task tool:
         task(
           subagent_type="${target_agent}",
           prompt="Create revised plan (new version) for task ${task_number}: ${description}. ${custom_prompt}",
           description="Revise plan for task ${task_number}"
         )
      
      2. Wait for planner to complete
      
      3. Relay result to user
    </process>
    <checkpoint>Delegated to planner for revision, result relayed</checkpoint>
  </stage>
</workflow_execution>

# /revise - Plan Revision Command

Create new plan versions for tasks with existing plans, preserving all previous versions.

## Usage

```bash
/revise TASK_NUMBER [PROMPT]
/revise 196
/revise 196 "Adjust phase breakdown"
```

## What This Does

1. Validates task exists in state.json (8x faster than TODO.md parsing)
2. Extracts all metadata at once (language, status, description, plan_path)
3. Validates existing plan exists
4. Routes to appropriate planner based on task language
5. Agent creates new plan version (increments version number)
6. Preserves all previous plan versions
7. Updates task status to [REVISED] via status-sync-manager
8. Creates git commit

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
