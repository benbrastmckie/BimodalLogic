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
  Parse task number from $ARGUMENTS, validate task and existing plan exist, extract language, route to appropriate planner for creating new plan version
</task>

<workflow_execution>
  <stage id="1" name="ParseAndValidate">
    <action>Parse task number and validate</action>
    <process>
      1. Parse task number from $ARGUMENTS
         - $ARGUMENTS contains: "196" or "196 Adjust phase breakdown"
         - Extract first token as task_number
         - Validate is integer
      2. Validate task exists in .opencode/specs/TODO.md
         - Read TODO.md and search for task entry
         - Format: "### ${task_number}."
         - If not found: Return error message
      3. Validate existing plan exists
         - Check task entry for plan link
         - If not found: Return error message suggesting /plan instead
      4. Extract task description and current status
    </process>
    <checkpoint>Task number parsed, task and plan validated</checkpoint>
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
         - revision_mode: true (signal to planner to create new version)
    </process>
    <checkpoint>Context prepared for delegation</checkpoint>
  </stage>
  
  <stage id="4" name="Delegate">
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

1. Routes to appropriate planner based on task language
2. Agent creates new plan version (increments version number)
3. Preserves all previous plan versions
4. Updates task status to [REVISED]
5. Creates git commit

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
