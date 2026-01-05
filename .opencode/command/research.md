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
  Parse task number from $ARGUMENTS, validate task exists in TODO.md, extract language, route to appropriate researcher based on language
</task>

<workflow_execution>
  <stage id="1" name="ParseAndValidate">
    <action>Parse task number and validate</action>
    <process>
      1. Parse task number from $ARGUMENTS
         - $ARGUMENTS contains: "197" or "197 Focus on CLI integration"
         - Extract first token as task_number
         - Validate is integer
      2. Validate task exists in .opencode/specs/TODO.md
         - Read TODO.md and search for task entry
         - Format: "### ${task_number}."
         - If not found: Return error message
      3. Extract task description and current status
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
         - lean → lean-research-agent
         - general → researcher
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
    <action>Delegate to researcher with parsed context</action>
    <process>
      1. Invoke target agent via task tool:
         task(
           subagent_type="${target_agent}",
           prompt="Research task ${task_number}: ${description}. ${custom_prompt}",
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

1. Routes to appropriate research agent based on task language
2. Agent conducts research using specialized tools
3. Creates research report in `.opencode/specs/{task}_*/reports/`
4. Updates task status to [RESEARCHED]
5. Creates git commit

## Language-Based Routing

| Language | Agent | Tools |
|----------|-------|-------|
| lean | lean-research-agent | LeanExplore, Loogle, LeanSearch |
| general | researcher | Web search, documentation |

See `.opencode/agent/subagents/researcher.md` for details.
