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
      1. Parse task number and flags from $ARGUMENTS
         - $ARGUMENTS contains: "197" or "197 Focus on CLI integration" or "197 --force"
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
      
      5. Validate task status allows research (skip if --force flag present)
         - If force_mode == false:
           case "$status" in
             "completed")
               echo "Error: Task $task_number already completed"
               echo "Recommendation: Task is done, no research needed"
               echo "To override: /research $task_number --force"
               exit 1
               ;;
             "abandoned")
               echo "Error: Task $task_number is abandoned"
               echo "Recommendation: Un-abandon task before researching"
               echo "To override: /research $task_number --force"
               exit 1
               ;;
             "researching")
               echo "Warning: Task $task_number is already being researched"
               echo "If this is a stale status (e.g., previous research crashed):"
               echo "  1. Check for existing research artifacts"
               echo "  2. Use /sync to reset status if needed"
               echo "To override: /research $task_number --force"
               exit 1
               ;;
             "researched")
               research_path=$(echo "$task_data" | jq -r '.artifacts[0] // "unknown"')
               echo "Info: Task $task_number already researched"
               echo "Research report: $research_path"
               echo "Recommendation: Use /plan to continue workflow"
               echo "To override: /research $task_number --force"
               exit 0
               ;;
             "not_started"|"planned"|"implementing"|"blocked"|"partial")
               # Status allows research, proceed
               ;;
             *)
               echo "Warning: Unknown status '$status' for task $task_number"
               echo "Proceeding with research, but status may be invalid"
               ;;
           esac
         - Else (force_mode == true):
           echo "WARNING: Using --force flag to override status validation"
           echo "Current status: $status"
           echo "Proceeding with research despite status"
      
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
/research TASK_NUMBER [PROMPT] [--force]
/research 197
/research 197 "Focus on CLI integration"
/research 197 --force  # Override status validation
```

**Flags:**
- `--force`: Override status validation (advanced users only). Use to bypass already-in-progress or already-completed checks.

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
