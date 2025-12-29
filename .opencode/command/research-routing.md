---
name: research
agent: orchestrator
description: "Conduct research and create reports with [RESEARCHED] status"
context_level: 2
language: markdown
execution_file: research-execution.md
---

**Task Input (required):** $ARGUMENTS (task number; e.g., `/research 197`, `/research 172`)

# Research Command - Routing Logic (Stages 1-3)

<context>
  <system_context>
    Research workflow routing with language-based agent selection.
  </system_context>
  <routing_context>
    Lean tasks route to lean-research-agent, general tasks route to researcher.
  </routing_context>
</context>

<role>Research Command Routing - Parse arguments and route to appropriate research agent</role>

<task>
  Parse task number, extract language, and route to lean-research-agent or researcher.
</task>

<argument_parsing>
  <invocation_format>
    /research TASK_NUMBER [PROMPT]
    
    Examples:
    - /research 197
    - /research 197 "Focus on CLI integration"
  </invocation_format>
  
  <parameters>
    <task_number>
      <position>1</position>
      <type>integer</type>
      <required>true</required>
      <description>The task number from .opencode/specs/TODO.md to research</description>
      <extraction>Extract first argument after command name as task number</extraction>
      <validation>Must be a valid integer that exists in .opencode/specs/TODO.md</validation>
    </task_number>
    
    <prompt>
      <position>2</position>
      <type>string</type>
      <required>false</required>
      <description>Optional additional context or focus for research</description>
      <extraction>Extract remaining arguments after task number as prompt string</extraction>
      <default>Use task description from .opencode/specs/TODO.md</default>
    </prompt>
    
    <flags>
      <divide>
        <flag>--divide</flag>
        <type>boolean</type>
        <required>false</required>
        <description>Subdivide research into multiple topics</description>
        <default>false</default>
      </divide>
    </flags>
  </parameters>
  
  <parsing_logic>
    When user invokes "/research 197 'Focus on CLI'", parse as:
    1. Command: "research"
    2. Arguments: ["197", "Focus on CLI"]
    3. Extracted:
       - task_number = 197
       - prompt = "Focus on CLI"
       - flags = {}
  </parsing_logic>
  
  <error_handling>
    If task_number missing:
      Return: "Error: Task number required. Usage: /research TASK_NUMBER [PROMPT]"
    If task_number not integer:
      Return: "Error: Task number must be an integer. Got: {input}"
    If task not found in .opencode/specs/TODO.md:
      Return: "Error: Task {task_number} not found in .opencode/specs/TODO.md"
  </error_handling>
</argument_parsing>

<routing_stages>
  <stage id="1" name="Preflight">
    <validation>
      - Task number must exist in .opencode/specs/TODO.md
      - Task must not be [COMPLETED] or [ABANDONED]
      - Language field must be present (default to "general")
      - Check for --divide flag (topic subdivision)
    </validation>
  </stage>

  <stage id="2" name="CheckLanguage">
    <critical_importance>
      CRITICAL: This stage MUST extract the Language field and determine routing.
      DO NOT skip this stage. DO NOT assume language without extraction.
      Incorrect routing bypasses Lean-specific tooling (lean-lsp-mcp, Loogle).
    </critical_importance>
    <language_extraction>
      Extract Language field from .opencode/specs/TODO.md task using explicit bash command:
      ```bash
      grep -A 20 "^### ${task_number}\." .opencode/specs/TODO.md | grep "Language" | sed 's/\*\*Language\*\*: //'
      ```
      Validate extraction succeeded (non-empty result)
      If extraction fails: default to "general" and log warning
      Log extracted language: "Task ${task_number} language: ${language}"
    </language_extraction>
    <routing>
      Language: lean → lean-research-agent (LeanExplore, Loogle, LeanSearch)
      Language: * → researcher (web search, documentation)
    </routing>
    <validation>
      MUST complete before Stage 3:
      - Language field extracted and logged
      - Routing decision made and logged
      - Target agent determined (lean-research-agent or researcher)
      - Agent matches language (lean → lean-research-agent, else → researcher)
    </validation>
    <pre_invocation_check>
      Before invoking agent in Stage 4, verify:
      - Language was extracted in Stage 2
      - Routing decision was logged in Stage 2
      - Selected agent matches language:
        * If language == "lean" AND agent != "lean-research-agent" → ABORT with error
        * If language != "lean" AND agent == "lean-research-agent" → ABORT with error
      If validation fails: Return error "Routing validation failed: language=${language}, agent=${agent}"
    </pre_invocation_check>
  </stage>

  <stage id="3" name="PrepareDelegation">
    <timeout>3600s (1 hour)</timeout>
    <delegation_context>
      {
        "session_id": "sess_{timestamp}_{random}",
        "delegation_depth": 1,
        "delegation_path": ["orchestrator", "research", "{agent}"],
        "timeout": 3600,
        "task_context": {
          "task_number": {number},
          "description": "{description}",
          "language": "{language}",
          "divide": {true|false}
        }
      }
    </delegation_context>
    <special_context>
      divide_topics: boolean (from --divide flag)
    </special_context>
    <next_stage>
      Load execution file: research-execution.md
      Proceed to Stage 4 (InvokeAgent)
    </next_stage>
  </stage>
</routing_stages>

<execution_transition>
  After Stage 3 complete:
  - Load execution file: @.opencode/command/research-execution.md
  - Execution file contains Stages 4-8
  - Execution file loads full context (status-markers, subagent-return-format, etc.)
</execution_transition>
