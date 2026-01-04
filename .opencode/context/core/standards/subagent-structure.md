# Subagent Structure Standard

**Version**: 1.0.0  
**Created**: 2025-12-29  
**Purpose**: Define standard structure for subagent files in ProofChecker system

---

## Overview

Subagent files are the **execution layer** of the ProofChecker system. They:
- Execute complex workflows
- Implement business logic
- Create artifacts
- Update state
- Handle errors
- Return standardized results

Subagents should be **comprehensive** (200-400 lines) and own complete workflows.

---

## File Structure

### 1. Frontmatter (YAML)

**Required fields**:
```yaml
---
name: "{subagent_name}"           # Subagent name (matches filename)
version: "1.0.0"                  # Semantic version
description: "{detailed description}"  # 1-2 sentence description
mode: subagent                    # Always "subagent"
agent_type: {type}                # planning | implementation | research | review | utility
temperature: 0.2                  # LLM temperature (0.0-1.0)
max_tokens: 4000                  # Maximum tokens for response
timeout: {seconds}                # Execution timeout in seconds
---
```

**Tool permissions**:
```yaml
tools:
  read: true                      # Can read files
  write: true                     # Can write files
  edit: true                      # Can edit files (optional)
  bash: true                      # Can execute bash commands
  grep: true                      # Can use grep
  glob: true                      # Can use glob
permissions:
  allow:
    - read: ["{patterns}"]        # Allowed read patterns
    - write: ["{patterns}"]       # Allowed write patterns
    - bash: ["{commands}"]        # Allowed bash commands
  deny:
    - bash: ["{dangerous_commands}"]  # Denied bash commands
    - write: ["{protected_paths}"]    # Protected paths
```

**Context loading**:
```yaml
context_loading:
  strategy: lazy                  # lazy | eager | minimal
  index: ".opencode/context/index.md"
  required:
    - "{required_context_1}"      # Always load these
    - "{required_context_2}"
  optional:
    - "{optional_context_1}"      # Load if needed
  max_context_size: 50000         # Maximum bytes to load
```

**Delegation**:
```yaml
delegation:
  max_depth: 3                    # Maximum delegation depth
  can_delegate_to:
    - "{utility_agent_1}"         # Agents this can delegate to
    - "{utility_agent_2}"
  timeout_default: {seconds}      # Default timeout for delegations
  timeout_max: {seconds}          # Maximum timeout allowed
```

**Lifecycle**:
```yaml
lifecycle:
  stage: 4                        # Which command stage invokes this
  command: "/{command}"           # Which command uses this
  return_format: "subagent-return-format.md"  # Return format spec
```

### 2. Title and Context

```markdown
# {Subagent Name}

<context>
  <specialist_domain>{What this agent specializes in}</specialist_domain>
  <task_scope>{Scope of tasks this agent handles}</task_scope>
  <integration>{How this agent integrates with system}</integration>
  <lifecycle_integration>
    {Lifecycle stage ownership and return format}
  </lifecycle_integration>
</context>
```

**Guidelines**:
- specialist_domain: 1 sentence describing specialization
- task_scope: 1-2 sentences describing scope
- integration: 1 sentence describing system integration
- lifecycle_integration: 1-2 sentences describing lifecycle ownership

### 3. Role and Task

```xml
<role>
  {Detailed role description - 1-2 sentences}
</role>

<task>
  {Detailed task description - 3-5 sentences covering full workflow}
</task>
```

**Guidelines**:
- Role: Clear identity and responsibility
- Task: Complete workflow description
- Include key responsibilities
- Mention delegation if applicable

### 4. Inputs

```xml
<inputs_required>
  <parameter name="{param_name}" type="{type}">
    {Parameter description}
  </parameter>
  <parameter name="{param_name}" type="{type}" optional="true">
    {Optional parameter description}
  </parameter>
</inputs_required>

<inputs_forbidden>
  <forbidden>{forbidden_input_1}</forbidden>
  <forbidden>{forbidden_input_2}</forbidden>
</inputs_forbidden>
```

**Common parameters**:
- `task_number` (integer) - Task number for operations
- `session_id` (string) - Unique session identifier
- `delegation_depth` (integer) - Current delegation depth
- `delegation_path` (array) - Delegation chain
- `language` (string) - Programming language
- `timeout` (integer) - Operation timeout

**Common forbidden inputs**:
- `conversation_history` - Don't pass full conversation
- `full_system_state` - Don't pass entire state
- `unstructured_context` - Require structured inputs

### 5. Process Flow

```xml
<process_flow>
  <step_1>
    <action>{Action description}</action>
    <process>
      1. {Detailed step 1}
      2. {Detailed step 2}
      3. {Detailed step 3}
    </process>
    <implementation>
      {Code or detailed implementation notes}
    </implementation>
    <checkpoint>{Completion criteria}</checkpoint>
  </step_1>
  
  <step_2>
    <action>{Action description}</action>
    <process>
      {Detailed process steps}
    </process>
    <checkpoint>{Completion criteria}</checkpoint>
  </step_2>
  
  {... more steps ...}
</process_flow>
```

**Guidelines**:
- Use `<process_flow>` for subagents (vs `<workflow_execution>` for commands)
- Each step should have: action, process, checkpoint
- Include implementation details (this is execution layer)
- Add code examples where helpful
- Number steps sequentially

**Common steps**:
1. **Load/Read** - Load task, plan, or other inputs
2. **Analyze/Determine** - Analyze requirements, determine approach
3. **Execute** - Execute main operation
4. **Create Artifacts** - Create files, summaries, etc.
5. **Update State** - Update TODO.md, state.json, etc.
6. **Create Commit** - Create git commit
7. **Prepare Return** - Format return object
8. **Return** - Return to command

### Step Naming Standard

**CRITICAL**: All subagents MUST use the following step naming convention:

```xml
<process_flow>
  <step_0_preflight>
    <action>Preflight: Validate inputs and update status to [WORKING]</action>
    <process>
      1. Parse and validate inputs
      2. Invoke status-sync-manager to update status
      3. Verify status update succeeded
    </process>
    <output>Inputs validated, status updated</output>
  </step_0_preflight>
  
  <step_1>
    <action>First main workflow step</action>
    <process>...</process>
    <output>...</output>
  </step_1>
  
  <step_2>
    <action>Second main workflow step</action>
    <process>...</process>
    <output>...</output>
  </step_2>
  
  <!-- ... more steps ... -->
  
  <step_N_postflight>
    <action>Postflight: Update status to [DONE] and create git commit</action>
    <process>
      1. Invoke status-sync-manager to update final status
      2. Invoke git-workflow-manager to create commit
      3. Verify operations succeeded
    </process>
    <output>Status updated, git commit created</output>
  </step_N_postflight>
  
  <step_N+1_return>
    <action>Return: Format and return standardized result</action>
    <process>
      1. Format return per subagent-return-format.md
      2. Validate return format
      3. Return to caller
    </process>
    <output>Standardized return object</output>
  </step_N+1_return>
</process_flow>
```

**Rationale**: The explicit "step_0" numbering signals to Claude that preflight MUST execute BEFORE the main workflow begins. Using "stage_1" or other numbering is ambiguous and may cause Claude to skip or defer preflight execution.

**Key Requirements**:
- Use `<step_0_preflight>` for preflight (NOT `<stage_1_preflight>`)
- Use `<step_1>`, `<step_2>`, etc. for main workflow steps
- Use `<step_N_postflight>` for postflight (where N is last step number)
- Use `<step_N+1_return>` for return step
- Number steps sequentially starting from 0

**Example**: See planner.md and researcher.md for reference implementations.

**History**: This standard was established in Task 283 after discovering that inconsistent naming (stage_1_preflight vs step_0_preflight) caused Claude to skip preflight execution in some subagents.

### 6. Delegation Patterns (if applicable)

```xml
<delegation_patterns>
  <delegate_to name="{utility_agent}">
    <when>{When to delegate}</when>
    <context>{What context to pass}</context>
    <expected_return>{What to expect back}</expected_return>
    <integration>{How to integrate return}</integration>
  </delegate_to>
</delegation_patterns>
```

**Common delegations**:
- `status-sync-manager` - Atomic state updates
- `git-workflow-manager` - Git commits
- `atomic-task-numberer` - Task number generation
- Language-specific agents (lean-implementation-agent, etc.)

### 7. Artifact Creation

```xml
<artifact_creation>
  <artifact type="{type}">
    <path>{artifact_path_pattern}</path>
    <content>{What the artifact contains}</content>
    <validation>{How to validate artifact}</validation>
    <token_limit>{token_limit} (if applicable)</token_limit>
  </artifact>
</artifact_creation>
```

**Common artifact types**:
- `implementation` - Code, docs, configs
- `plan` - Implementation plans
- `research` - Research reports
- `summary` - Summary documents
- `review` - Review reports

**Path patterns**:
- Plans: `.opencode/specs/{number}_{slug}/plans/implementation-{version:03d}.md`
- Research: `.opencode/specs/{number}_{slug}/reports/research-{version:03d}.md`
- Summaries: `.opencode/specs/{number}_{slug}/summaries/{type}-summary-{YYYYMMDD}.md`

**Token limits**:
- Summaries: <100 tokens (~400 characters)
- Protects orchestrator context window

### 8. Return Format

```xml
<return_format>
  <structure>
    {
      "status": "completed|partial|failed|blocked",
      "summary": "{brief_summary} (<100 tokens)",
      "artifacts": [
        {
          "type": "{artifact_type}",
          "path": "{artifact_path}",
          "summary": "{brief_description}"
        }
      ],
      "metadata": {
        "{key}": "{value}"
      },
      "session_id": "{session_id}",
      "errors": [...]  // if status != completed
    }
  </structure>
  <validation>
    {Return format validation rules}
  </validation>
</return_format>
```

**Required fields**:
- `status` - One of: completed, partial, failed, blocked
- `summary` - Brief summary (<100 tokens)
- `artifacts` - Array of created artifacts
- `metadata` - Operation-specific metadata
- `session_id` - Session identifier (must match input)

**Optional fields**:
- `errors` - Array of errors (if status != completed)

**Validation rules**:
- Summary must be <100 tokens
- Session ID must match input
- Artifacts must exist on disk
- Status must be valid enum

### 9. Quality Standards

```xml
<quality_standards>
  <standard_1>
    {Quality requirement 1}
  </standard_1>
  <standard_2>
    {Quality requirement 2}
  </standard_2>
</quality_standards>
```

**Common standards**:
- Atomic updates (use status-sync-manager)
- Lazy directory creation
- Git commits (use git-workflow-manager)
- Token limits (summaries <100 tokens)
- Validation gates
- Error handling

### 10. Error Handling

```xml
<error_handling>
  <error_type name="{error_type}">
    <detection>{How to detect this error}</detection>
    <handling>{How to handle this error}</handling>
    <recovery>{Recovery instructions for user}</recovery>
    <logging>{What to log to errors.json}</logging>
  </error_type>
</error_handling>
```

**Common error types**:
- `timeout` - Operation exceeded timeout
- `validation_failure` - Input or output validation failed
- `file_operation_failure` - File read/write failed
- `delegation_failure` - Subagent delegation failed
- `git_failure` - Git operation failed (usually non-critical)

---

## Size Guidelines

### Target Sizes
- **Minimum**: 150 lines (simple subagents)
- **Target**: 200-300 lines (most subagents)
- **Maximum**: 400 lines (complex subagents with multiple modes)

### Size Management

If subagent exceeds 400 lines:

1. **Extract to context files**
   - Move detailed process documentation to context/project/processes/
   - Reference from subagent file

2. **Split into multiple subagents**
   - Create specialized subagents for different modes
   - Use routing logic to select appropriate subagent

3. **Use delegation**
   - Delegate complex sub-tasks to utility agents
   - Keep subagent focused on coordination

---

## Agent Types

### Planning Agents
**Purpose**: Create implementation plans  
**Examples**: planner  
**Key responsibilities**:
- Analyze task requirements
- Break down into phases
- Estimate effort
- Create plan artifacts
- Update status to [PLANNED]

**Typical workflow**:
1. Read task from TODO.md
2. Harvest research findings (if available)
3. Create phased implementation plan
4. Update status to [PLANNED]
5. Create git commit
6. Return plan path and summary

### Implementation Agents
**Purpose**: Execute implementations  
**Examples**: implementer, lean-implementation-agent  
**Key responsibilities**:
- Execute code/doc changes
- Create implementation artifacts
- Update status to [COMPLETED]
- Create git commits

**Typical workflow**:
1. Load task and determine mode (phased vs direct)
2. Execute implementation
3. Create artifacts
4. Update status to [COMPLETED]
5. Create git commit(s)
6. Return artifacts and summary

### Research Agents
**Purpose**: Conduct research  
**Examples**: researcher, lean-research-agent  
**Key responsibilities**:
- Research topics
- Create research reports
- Update status to [RESEARCHED]

**Typical workflow**:
1. Load task and research scope
2. Conduct research (web, docs, APIs)
3. Create research report
4. Update status to [RESEARCHED]
5. Create git commit
6. Return report path and summary

### Review Agents
**Purpose**: Review code/docs  
**Examples**: reviewer  
**Key responsibilities**:
- Analyze codebase
- Update registries
- Create review reports
- Create follow-up tasks

**Typical workflow**:
1. Scan codebase
2. Update registries (SORRY, TACTIC, FEATURE, etc.)
3. Create review report
4. Create follow-up tasks
5. Create git commit
6. Return report path and summary

### Utility Agents
**Purpose**: Provide specialized services  
**Examples**: status-sync-manager, git-workflow-manager, atomic-task-numberer  
**Key responsibilities**:
- Atomic state updates
- Git operations
- Task numbering
- Other specialized services

**Typical workflow**:
1. Receive request from parent agent
2. Execute specialized operation
3. Return result

---

## Workflow Ownership

Subagents **own complete workflows** including:

### Stage 7 (Postflight)
Subagents are responsible for:
- Updating status (via status-sync-manager)
- Creating git commits (via git-workflow-manager)
- Verifying artifacts on disk
- Handling errors

### Stage 8 (Return)
Subagents are responsible for:
- Formatting return object per subagent-return-format.md
- Validating return format
- Ensuring token limits
- Including all required fields

Commands only:
- Validate return (Stage 5)
- Relay to user (Stage 6)

---

## Context Loading Strategy

### Lazy Loading (Most Common)
```yaml
context_loading:
  strategy: lazy
  index: ".opencode/context/index.md"
  required:
    - "core/standards/subagent-return-format.md"
    - "core/system/status-markers.md"
    - "{domain_specific_context}"
  optional:
    - "{optional_context_1}"
  max_context_size: 50000
```

**When to use**: Most subagents  
**Behavior**: Load required context upfront, optional on-demand  
**Size target**: <50KB

### Eager Loading
```yaml
context_loading:
  strategy: eager
  index: ".opencode/context/index.md"
  required:
    - "core/standards/subagent-return-format.md"
    - "core/system/status-markers.md"
    - "{domain_context_1}"
    - "{domain_context_2}"
    - "{domain_context_3}"
  max_context_size: 100000
```

**When to use**: Complex operations needing lots of context  
**Behavior**: Load all required and most optional context upfront  
**Size target**: <100KB

### Minimal Loading
```yaml
context_loading:
  strategy: minimal
  index: ".opencode/context/index.md"
  required:
    - "core/standards/subagent-return-format.md"
  max_context_size: 10000
```

**When to use**: Simple utility agents  
**Behavior**: Load only essential context  
**Size target**: <10KB

---

## Delegation Best Practices

### When to Delegate

Delegate to utility agents for:
- **Atomic state updates** → status-sync-manager
- **Git operations** → git-workflow-manager
- **Task numbering** → atomic-task-numberer
- **Language-specific operations** → lean-implementation-agent, etc.

### Delegation Pattern

```xml
<step_N>
  <action>Delegate to {utility_agent}</action>
  <process>
    1. Prepare delegation context:
       - session_id: {session_id}
       - delegation_depth: {current_depth + 1}
       - delegation_path: {current_path + [this_agent, utility_agent]}
       - timeout: {timeout}
       - {operation_specific_context}
    2. Invoke {utility_agent}
    3. Wait for return
    4. Validate return against subagent-return-format.md
    5. Integrate return into workflow
  </process>
  <checkpoint>{Utility operation complete}</checkpoint>
</step_N>
```

### Delegation Safety

- **Max depth**: 3 (orchestrator → command → subagent → utility)
- **Cycle detection**: Don't delegate to self or ancestors
- **Timeout**: Always set timeout for delegations
- **Validation**: Always validate return format

---

## Validation Checklist

Use this checklist when creating or reviewing subagent files:

### Structure
- [ ] Frontmatter includes all required fields
- [ ] Tool permissions defined (allow and deny)
- [ ] Context loading specified
- [ ] Delegation configuration (if applicable)
- [ ] Lifecycle stage specified
- [ ] File size 200-400 lines

### XML Structure
- [ ] `<context>` has 4 sub-contexts
- [ ] `<role>` is clear (1-2 sentences)
- [ ] `<task>` describes complete workflow (3-5 sentences)
- [ ] `<inputs_required>` lists all required parameters
- [ ] `<inputs_forbidden>` lists forbidden inputs

### Process Flow
- [ ] `<process_flow>` has clear steps
- [ ] Each step has action, process, checkpoint
- [ ] Implementation details included
- [ ] Code examples where helpful
- [ ] Steps cover complete workflow

### Supporting Sections
- [ ] `<delegation_patterns>` if agent delegates
- [ ] `<artifact_creation>` for all artifacts
- [ ] `<return_format>` matches subagent-return-format.md
- [ ] `<quality_standards>` lists key requirements
- [ ] `<error_handling>` covers major error types

### Workflow Ownership
- [ ] Owns Stage 7 (Postflight) - status updates, git commits
- [ ] Owns Stage 8 (Return) - return formatting
- [ ] Delegates to utility agents appropriately
- [ ] Handles errors comprehensively

---

## Examples

### Planning Agent
See: `.opencode/agent/subagents/planner.md`

### Implementation Agent
See: `.opencode/agent/subagents/implementer.md`

### Research Agent
See: `.opencode/agent/subagents/researcher.md` (after Phase 6)

### Utility Agent
See: `.opencode/agent/subagents/status-sync-manager.md`

---

## Anti-Patterns (Avoid These)

### ❌ Minimal Process Flow
```xml
<process_flow>
  <step_1>
    <action>Execute operation</action>
    <process>
      1. Do the thing
      2. Return result
    </process>
  </step_1>
</process_flow>
```
**Problem**: Not enough detail for execution layer

### ✅ Detailed Process Flow
```xml
<process_flow>
  <step_1>
    <action>Load task and determine mode</action>
    <process>
      1. Read task from TODO.md using grep:
         ```bash
         grep -A 50 "^### ${task_number}\." TODO.md
         ```
      2. Check for existing plan link in task entry
      3. If plan link exists:
         - Load plan file
         - Parse phase status markers
         - Determine resume point (first [NOT STARTED] or [IN PROGRESS])
         - Set mode = "phased"
      4. If no plan link:
         - Set mode = "direct"
      5. Extract language, description, acceptance criteria
    </process>
    <checkpoint>Task loaded and mode determined</checkpoint>
  </step_1>
</process_flow>
```

### ❌ Missing Return Format
Subagent doesn't specify return format

**Problem**: Unclear what to return, inconsistent returns

### ✅ Explicit Return Format
```xml
<return_format>
  <structure>
    {
      "status": "completed",
      "summary": "Plan created with 4 phases, 6 hours estimated",
      "artifacts": [
        {
          "type": "plan",
          "path": ".opencode/specs/195_lean_tools/plans/implementation-001.md",
          "summary": "4-phase implementation plan"
        }
      ],
      "metadata": {
        "task_number": 195,
        "phase_count": 4,
        "estimated_hours": 6
      },
      "session_id": "sess_20251229_abc123"
    }
  </structure>
</return_format>
```

### ❌ No Error Handling
Subagent doesn't handle errors

**Problem**: Failures are opaque, no recovery path

### ✅ Comprehensive Error Handling
```xml
<error_handling>
  <error_type name="timeout">
    <detection>Operation exceeds timeout limit</detection>
    <handling>
      1. Save current progress
      2. Update status to [IN PROGRESS]
      3. Return partial status with resume instructions
    </handling>
    <recovery>Resume with same command: /{command} {task_number}</recovery>
    <logging>Log timeout event to errors.json with session_id</logging>
  </error_type>
</error_handling>
```

---

## Migration Guide

When converting existing subagents to this standard:

1. **Review frontmatter** - Ensure all required fields present
2. **Add XML structure** - Wrap content in XML tags
3. **Expand process flow** - Add implementation details
4. **Add return format** - Specify exact return structure
5. **Add error handling** - Cover all major error types
6. **Verify workflow ownership** - Ensure owns Stages 7-8
7. **Test subagent** - Verify it still works

---

## References

- **XML Patterns**: `.opencode/context/core/standards/xml-patterns.md`
- **Command Structure**: `.opencode/context/core/standards/command-structure.md`
- **Return Format**: `.opencode/context/core/standards/subagent-return-format.md`
- **Context Index**: `.opencode/context/index.md`
- **Error Handling**: `.opencode/context/core/standards/error-handling.md`
