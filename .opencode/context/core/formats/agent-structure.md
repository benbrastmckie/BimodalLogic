# Agent File Structure Standard

**Version**: 1.0
**Created**: 2026-01-23
**Scope**: All `.opencode/agent/*.md` files (subagents and orchestrators).

## Overview

This standard defines the required YAML frontmatter and XML-structured body layout for agent
files in the ProofChecker OpenCode system. All agent files must follow the ordering:
`<context>` → `<role>` → `<task>` → `<workflow_execution>` → `<validation>` → `<error_handling>`
→ `<outputs>` (optional) → `<notes>` (optional).

## YAML Frontmatter (Required)

```yaml
---
name: "agent-name"
version: "1.0.0"
description: "Brief description of the agent"
mode: subagent | orchestrator
agent_type: research | planning | implementation | execution | validation | orchestration
temperature: 0.1
max_tokens: 4000
timeout: 3600
tools:
  read: true
  write: true
  edit: false
  glob: true
  grep: true
  bash: false
permissions:
  allow:
    - read: ["**/*.md", ".opencode/**/*"]
    - write: ["specs/**/*"]
  deny:
    - bash: ["rm -rf", "sudo"]
context_loading:
  strategy: lazy
  index: ".opencode/context/index.md"
  required:
    - "core/formats/return-metadata-file.md"
  optional: []
  max_context_size: 50000
delegation:
  max_depth: 3
  can_delegate_to: []
  timeout_default: 1800
  timeout_max: 7200
lifecycle:
  stage: 4
  return_format: "core/formats/return-metadata-file.md"
---
```

## XML Body Structure

```xml
<context>
  <system_context>...</system_context>
  <domain_context>...</domain_context>
  <task_context>...</task_context>
  <execution_context>...</execution_context>
</context>

<role>
  ...
</role>

<task>
  ...
</task>

<workflow_execution>
  <stage id="1" name="InputValidation">...</stage>
  <stage id="2" name="ContextLoading">...</stage>
  <stage id="3" name="Execution">...</stage>
  <stage id="4" name="Postflight">...</stage>
</workflow_execution>

<validation>
  <checks>...</checks>
</validation>

<error_handling>
  <errors>...</errors>
</error_handling>

<outputs>
  <return_format>...</return_format>
</outputs>
```

## Required Sections

- `<context>` with system, domain, task, and execution sub-tags.
- `<role>` describing agent identity.
- `<task>` describing objective.
- `<workflow_execution>` with ordered stages.
- `<validation>` describing checks.
- `<error_handling>` describing recovery.

## Notes

- Use XML tags consistently with `.opencode/context/core/standards/xml-structure.md`.
- Avoid markdown headings inside the XML body; headings should be outside XML blocks.
- Use the metadata-file return protocol (`return-metadata-file.md`).
