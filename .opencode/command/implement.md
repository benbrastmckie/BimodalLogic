---
name: implement
agent: orchestrator
description: "Execute implementation with resume support and [COMPLETED] status"
timeout: 7200
routing:
  language_based: true
  lean: lean-implementation-agent
  default: implementer
---

**Task Input (required):** $ARGUMENTS

<context>
  <system_context>Implementation command with language-based routing</system_context>
  <task_context>Parse task number, validate, extract language, delegate to implementer</task_context>
</context>

<role>Implementation command agent - Parse arguments and route to appropriate implementer</role>

<task>
  Parse task number from $ARGUMENTS, lookup task in state.json, extract metadata, route to appropriate implementer based on language
</task>

<workflow_execution>
  <stage id="1" name="ParseAndValidate">
    <action>Parse task number and lookup in state.json</action>
    <process>
      1. Parse task number from $ARGUMENTS
         - $ARGUMENTS contains: "259" or "259 custom prompt" or "105-107"
         - Extract first token as task_number
         - Validate is integer or range (N-M)
      
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
      
      5. Validate task status allows implementation
         - If status is "completed": Return error "Task $task_number already completed"
         - If status is "abandoned": Return error "Task $task_number is abandoned"
      
      6. Extract custom prompt from $ARGUMENTS if present
         - If $ARGUMENTS has multiple tokens: custom_prompt = remaining tokens
         - Else: custom_prompt = ""
      
      7. Determine target agent based on language
         - lean → lean-implementation-agent
         - meta → meta
         - general → implementer
    </process>
    <checkpoint>Task validated, metadata extracted, target agent determined</checkpoint>
  </stage>
  
  <stage id="2" name="Delegate">
    <action>Delegate to implementer with parsed context</action>
    <process>
      1. Invoke target agent via task tool:
         task(
           subagent_type="${target_agent}",
           prompt="Implement task ${task_number}: ${description}. ${custom_prompt}",
           description="Implement task ${task_number}"
         )
      
      2. Wait for implementer to complete
      
      3. Relay result to user
    </process>
    <checkpoint>Delegated to implementer, result relayed</checkpoint>
  </stage>
</workflow_execution>

## Usage

```bash
/implement TASK_NUMBER [PROMPT]
/implement 196
/implement 196 "Focus on error handling"
/implement 105-107
```

## What This Does

1. Parses task number from arguments
2. Validates task exists in state.json (8x faster than TODO.md parsing)
3. Extracts all metadata at once (language, status, description, priority)
4. Routes to appropriate implementation agent based on task language
5. Agent executes implementation (plan-based or direct)
6. Creates implementation artifacts
7. Updates task status to [COMPLETED] via status-sync-manager
8. Creates git commit(s)

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
