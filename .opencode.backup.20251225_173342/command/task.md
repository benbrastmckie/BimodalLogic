---
name: task
agent: orchestrator
description: "Add tasks to TODO.md while updating state.json numbering"
context_level: 1
language: markdown
subagents:
  - task-adder
mcp_requirements: []
registry_impacts:
  - TODO.md
  - .opencode/specs/state.json
creates_root_on: never
creates_subdir: []
---

Context Loaded:
@.opencode/specs/TODO.md
@.opencode/specs/state.json
@.opencode/context/common/system/state-schema.md
@.opencode/context/common/system/status-markers.md
@.opencode/context/common/system/artifact-management.md
@.opencode/context/common/standards/tasks.md
@.opencode/context/common/standards/commands.md
@.opencode/context/common/standards/patterns.md

<context>
  <system_context>Task creation command that must preserve numbering, status markers, and lazy directory rules.</system_context>
  <domain_context>ProofChecker .opencode task registry (TODO.md + state.json).</domain_context>
  <task_context>Assign new task IDs, append tasks to TODO.md with full metadata, and sync state.json without creating project directories.</task_context>
  <execution_context>Single-step write; only state.json and TODO.md are touched. No project roots/subdirs may be created.</execution_context>
</context>

<role>Task Adder responsible for atomic task creation and numbering integrity.</role>

<task>Create one or more tasks using the next available project number, append them to TODO.md with `[NOT STARTED]` markers, and sync state.json pending_tasks while incrementing `next_project_number`.</task>

## Quick Reference

**Most Common Usage** (90% of cases):
```bash
/task "Task description"
```

**With Priority Override**:
```bash
/task "Urgent task" --priority High
```

**Lean Task**:
```bash
/task "Prove theorem X" --language lean
```

**Batch Tasks**:
```bash
/task "Task 1" "Task 2" "Task 3"
```

**From File**:
```bash
/task --file path/to/tasks.md
```

For full documentation, see sections below.

## Description

Add tasks to TODO.md with atomic number allocation and intelligent metadata inference.

**Minimal Usage**: Provide just a description - all other metadata will be auto-populated with sensible defaults.

**Advanced Usage**: Override defaults with flags for priority, language, effort, files, etc.

**Batch Usage**: Provide multiple descriptions or use --file for bulk task creation.

## Required Input

- **Description**: Task description (required)

## Optional Input (Auto-Populated if Not Provided)

- **Priority**: Default = Medium
- **Language**: Default = markdown (inferred from description/files if possible)
- **Effort**: Default = 2 hours (inferred from description complexity)
- **Files Affected**: Default = TBD
- **Dependencies**: Default = None
- **Blocking**: Default = None
- **Acceptance Criteria**: Default = Generic checklist based on description
- **Impact**: Default = Generic statement based on description

## Input Validation

<validation>
  <pre_flight>
    1. Validate at least one description provided
    2. Validate descriptions are non-empty strings
    3. Validate --file path exists if provided
    4. Reject invalid flag combinations
  </pre_flight>
  
  <error_messages>
    - Empty description: "Error: Description cannot be empty. Usage: /task \"task description\""
    - No input: "Error: No task description provided. Usage: /task \"task description\""
    - Invalid file: "Error: File not found: {path}. Check the path and try again."
    - Invalid flags: "Error: Unknown flag: {flag}. See /task --help for valid flags."
  </error_messages>
</validation>

<workflow_execution>
  <stage id="1" name="Preflight">
    <action>Validate inputs and reserve numbers</action>
    <process>
      1. Parse `$ARGUMENTS` (strings or `--file` extraction); reject empty input.
      2. Read `.opencode/specs/state.json` and capture `next_project_number` (zero-padded).
      3. Validate uniqueness; do not create any project directories.
    </process>
  </stage>
  <stage id="2" name="CreateTasks">
    <action>Write TODO entries and update state</action>
    <process>
      1. Append tasks under the correct priority section using the template from tasks.md with **Status** `[NOT STARTED]` and required metadata (Effort, Priority, Language, Blocking, Dependencies, Files Affected, Description, Acceptance Criteria, Impact).
      2. Increment `next_project_number` in state.json and add pending_tasks entries (`status: not_started`, `created_at`: UTC date).
      3. Do not add project links; `/research` or `/plan` will create artifacts later.
    </process>
  </stage>
  <stage id="3" name="Postflight">
    <action>Summarize results</action>
    <process>
      1. Report assigned task numbers and titles.
      2. Confirm state.json increment and TODO additions.
      3. Remind that project roots/subdirs are created only when artifacts are written by /research or /plan.
    </process>
  </stage>
</workflow_execution>

<routing_intelligence>
  <context_allocation>Level 1 (single-operation write to TODO/state).</context_allocation>
  <lean_routing>Language metadata is recorded but no Lean routing occurs during creation.</lean_routing>
  <batch_handling>Support multiple tasks in one invocation; process sequentially to preserve numbering.</batch_handling>
</routing_intelligence>

<artifact_management>
  <lazy_creation>No project roots/subdirs are created by /task.</lazy_creation>
  <state_sync>Always increment `next_project_number` and add pending_tasks entries.</state_sync>
  <registry_sync>Registry files (IMPLEMENTATION_STATUS.md, SORRY_REGISTRY.md, TACTIC_REGISTRY.md) are unchanged by /task.</registry_sync>
  <git_commits>No commits are made by /task; if follow-up edits occur, use git-commits.md + git-workflow-manager to stage only relevant files and commit after artifacts exist.</git_commits>
</artifact_management>

<quality_standards>
  <status_markers>New tasks start as `[NOT STARTED]` with no timestamps.</status_markers>
  <language_routing>Capture `Language` for each task; default to user-provided or infer from input when provided.</language_routing>
  <no_emojis>Outputs and artifacts must be emoji-free.</no_emojis>
  <validation>Reject invalid/empty input; ensure JSON remains valid.</validation>
</quality_standards>

<usage_examples>
  ### Simple (Recommended for Quick Tasks)
  ```bash
  /task "Fix typo in README"
  # → Task created with all metadata auto-populated
  ```
  
  ### With Optional Overrides
  ```bash
  /task "Implement feature X" --priority High --language lean --effort "4 hours"
  # → Task created with specified metadata
  ```
  
  ### Batch Creation
  ```bash
  /task "Task 1" "Task 2" "Task 3"
  # → Multiple tasks created with sequential numbers
  ```
  
  ### File Extraction
  ```bash
  /task --file docs/FEATURES.md
  # → Extracts tasks from file and creates them
  ```
</usage_examples>

<validation>
  <pre_flight>Inputs parsed; next_project_number reserved; no directories touched.</pre_flight>
  <mid_flight>TODO and state updated atomically; numbering increments correctly.</mid_flight>
  <post_flight>Summary returned with assigned numbers; remind lazy-creation boundaries.</post_flight>
</validation>
