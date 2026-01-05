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

**Task Input (required):** $ARGUMENTS

<context>
  <system_context>Research command with language-based routing</system_context>
  <task_context>Parse task number, validate, extract language, delegate to researcher</task_context>
</context>

<role>Research command agent - Parse arguments and route to appropriate researcher</role>

<task>
  Parse task number from $ARGUMENTS, lookup task in state.json, extract metadata, route to appropriate researcher based on language
</task>

<workflow_execution>
  <stage id="1" name="ParseAndValidate">
    <action>Parse task number and lookup in state.json</action>
    <process>
      1. Parse task number from $ARGUMENTS
         - $ARGUMENTS contains: "197" or "197 Focus on CLI integration"
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
      
      5. Validate task status allows research
         - If status is "completed": Return error "Task $task_number already completed"
      
      6. Extract research focus from $ARGUMENTS if present
         - If $ARGUMENTS has multiple tokens: research_focus = remaining tokens
         - Else: research_focus = ""
      
      7. Determine target agent based on language
         - lean → lean-research-agent
         - general → researcher
    </process>
    <checkpoint>Task validated, metadata extracted, target agent determined</checkpoint>
  </stage>
  
  <stage id="2" name="Delegate">
    <action>Delegate to researcher with parsed context</action>
    <process>
      1. Invoke target agent via task tool:
         task(
           subagent_type="${target_agent}",
           prompt="Research task ${task_number}: ${description}. Focus: ${research_focus}",
           description="Research task ${task_number}"
         )
      
      2. Wait for researcher to complete
      
      3. Relay result to user
    </process>
    <checkpoint>Delegated to researcher, result relayed</checkpoint>
  </stage>
</workflow_execution>

# /research - Research Command

Conduct research for tasks and create research reports with [RESEARCHED] status.

## Usage

```bash
/research TASK_NUMBER [PROMPT]
/research 197
/research 197 "Focus on CLI integration"
```

## What This Does

1. Validates task exists in state.json (8x faster than TODO.md parsing)
2. Extracts all metadata at once (language, status, description, priority)
3. Routes to appropriate research agent based on task language
4. Agent conducts research using specialized tools
5. Creates research report in `.opencode/specs/{task}_*/reports/`
6. Updates task status to [RESEARCHED] via status-sync-manager
7. Creates git commit

## Language-Based Routing

| Language | Agent | Tools |
|----------|-------|-------|
| lean | lean-research-agent | LeanExplore, Loogle, LeanSearch |
| general | researcher | Web search, documentation |

See `.opencode/agent/subagents/researcher.md` for details.
