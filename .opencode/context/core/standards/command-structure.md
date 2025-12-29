# Command Structure Standard

**Version**: 1.0.0  
**Created**: 2025-12-29  
**Purpose**: Define standard structure for command files in ProofChecker system

---

## Overview

Command files are the **routing layer** of the ProofChecker system. They:
- Parse user input
- Route to appropriate subagents
- Validate returns
- Relay results to user

Commands should be **lightweight** (<200 lines) and focus on routing, not execution.

---

## File Structure

### 1. Frontmatter (YAML)

**Required fields**:
```yaml
---
name: {command_name}              # Command name (matches filename)
agent: {target_agent}             # Default target agent path
description: "{brief description}" # One-sentence description
context_level: {1|2|3}            # Context allocation level
language: {varies|markdown|lean}  # Primary language or "varies"
---
```

**Optional fields**:
```yaml
routing:                          # Language-based routing
  lean: {lean_agent}
  markdown: {markdown_agent}
  default: {default_agent}
context_loading:                  # Context loading specification
  strategy: lazy                  # lazy | eager | minimal
  index: ".opencode/context/index.md"
  required:
    - "core/standards/subagent-return-format.md"
    - "{command_specific_context}"
  optional:
    - "{optional_context}"
  max_context_size: 50000         # bytes
  cache_strategy: session         # session | none | persistent
```

### 2. Task Input Declaration

Immediately after frontmatter:
```markdown
**Task Input**: $ARGUMENTS ({description of expected input})
```

Examples:
- `**Task Input**: $ARGUMENTS (task number; e.g., /plan 197)`
- `**Task Input**: $ARGUMENTS (task description; e.g., /task "Implement feature X")`
- `**Task Input (optional)**: $ARGUMENTS (optional flags; e.g., /errors --all)`

### 3. XML Structure

#### 3.1 Context Section
```xml
<context>
  <system_context>
    {What this command does in the system - 1-2 sentences}
  </system_context>
  <domain_context>
    {Domain-specific context - 1-2 sentences}
  </domain_context>
  <task_context>
    {Specific task this command handles - 1-2 sentences}
  </task_context>
  <execution_context>
    {How this command executes - 1-2 sentences}
  </execution_context>
</context>
```

**Guidelines**:
- Each sub-context: 1-2 sentences max
- Total context: 4-8 sentences
- Focus on essential information only
- Avoid duplication from frontmatter

#### 3.2 Role Section
```xml
<role>{Brief role description - 1 sentence}</role>
```

**Guidelines**:
- Single sentence or short phrase
- Clearly states command's responsibility
- Example: "Planning command - Create implementation plans with status tracking"

#### 3.3 Task Section
```xml
<task>
  {Detailed task description - 2-4 sentences}
</task>
```

**Guidelines**:
- 2-4 sentences describing what command accomplishes
- Include key responsibilities
- Mention delegation if applicable
- Example: "Parse task number, validate task exists, delegate to planner subagent, validate return, and relay result to user."

#### 3.4 Workflow Execution Section
```xml
<workflow_execution>
  <stage id="1" name="Preflight">
    <action>{What happens in preflight}</action>
    <process>
      1. {Step 1}
      2. {Step 2}
      3. {Step 3}
    </process>
    <checkpoint>{Completion criteria}</checkpoint>
  </stage>
  
  <stage id="2" name="Delegate">
    <action>{Delegation action}</action>
    <process>
      1. {Prepare delegation context}
      2. {Invoke subagent}
      3. {Wait for return}
    </process>
    <checkpoint>{Delegation complete}</checkpoint>
  </stage>
  
  <stage id="3" name="ValidateReturn">
    <action>{Validation action}</action>
    <process>
      1. {Validate return format}
      2. {Check artifacts}
      3. {Verify success criteria}
    </process>
    <checkpoint>{Return validated}</checkpoint>
  </stage>
  
  <stage id="4" name="ReturnSuccess">
    <action>Return result to user</action>
    <return_format>
      {Expected return format}
    </return_format>
    <checkpoint>Result returned</checkpoint>
  </stage>
</workflow_execution>
```

**Guidelines**:
- Commands typically have 3-5 stages
- Common stages: Preflight, Delegate, ValidateReturn, ReturnSuccess
- Each stage must have: id, name, action, process, checkpoint
- Keep process steps concise (routing logic only)
- Detailed execution logic belongs in subagent files

**Standard Stages**:

1. **Preflight** - Parse input, validate, prepare
2. **CheckLanguage** (optional) - Extract language for routing
3. **PrepareDelegation** - Generate session ID, prepare context
4. **Delegate** - Invoke target subagent
5. **ValidateReturn** - Validate subagent return
6. **ReturnSuccess** - Format and return result to user

#### 3.5 Routing Intelligence Section
```xml
<routing_intelligence>
  <context_allocation>
    {Context loading strategy - which level and why}
  </context_allocation>
  
  <language_routing>  <!-- If applicable -->
    {Language-based routing rules}
  </language_routing>
  
  <delegation_strategy>  <!-- If applicable -->
    {When to delegate to which agents}
  </delegation_strategy>
</routing_intelligence>
```

**Guidelines**:
- Explain context allocation level choice
- Document language-based routing if applicable
- Reference detailed routing docs in context files

#### 3.6 Quality Standards Section
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

**Guidelines**:
- List key quality requirements
- Include atomic updates, validation, etc.
- Keep concise (details in context files)

#### 3.7 Usage Examples Section
```xml
<usage_examples>
  - `/{command} {example1}` - {description}
  - `/{command} {example2}` - {description}
  - `/{command} {example3}` - {description}
</usage_examples>
```

**Guidelines**:
- Provide 3-5 concrete examples
- Cover common use cases
- Include edge cases if relevant
- Show different argument patterns

#### 3.8 Validation Section
```xml
<validation>
  <pre_flight>
    - {Pre-flight check 1}
    - {Pre-flight check 2}
  </pre_flight>
  <mid_flight>
    - {Mid-flight check 1}
    - {Mid-flight check 2}
  </mid_flight>
  <post_flight>
    - {Post-flight check 1}
    - {Post-flight check 2}
  </post_flight>
</validation>
```

**Guidelines**:
- Define validation at each stage
- Pre-flight: Input validation
- Mid-flight: Delegation and return validation
- Post-flight: Final state validation

#### 3.9 Error Handling Section
```xml
<error_handling>
  <error_type_1>
    {How to handle error type 1}
    
    Error message format:
    ```
    Error: {error_message}
    
    Recommendation: {recovery_instructions}
    ```
  </error_type_1>
  
  <error_type_2>
    {How to handle error type 2}
  </error_type_2>
</error_handling>
```

**Guidelines**:
- Cover all major error types
- Include error message format
- Provide recovery instructions
- Reference error handling guide for details

---

## Size Guidelines

### Target Sizes
- **Minimum**: 100 lines (very simple commands)
- **Target**: 150-200 lines (most commands)
- **Maximum**: 250 lines (complex commands with multiple routing paths)

### Size Reduction Strategies

If command exceeds 200 lines:

1. **Move detailed workflows to subagent files**
   - Commands route, subagents execute
   - Keep only routing stages in command

2. **Move detailed documentation to context files**
   - Create process documentation in context/project/processes/
   - Reference from command file

3. **Consolidate error handling**
   - Keep error types in command
   - Move detailed error handling to context/core/standards/error-handling.md

4. **Use references instead of duplication**
   - Reference context files for details
   - Don't duplicate information

---

## Context Loading Strategy

### Level 1 (Isolated)
**Use for**: Simple commands with no state dependencies
- Load: Command frontmatter only
- Size: <5KB
- Examples: /task (simple creation)

### Level 2 (Filtered)
**Use for**: Commands that need project context
- Load: Command frontmatter + required context files
- Size: <50KB
- Examples: /plan, /implement, /research

### Level 3 (Full)
**Use for**: Commands that need comprehensive context
- Load: Command frontmatter + all relevant context
- Size: <100KB
- Examples: /review (codebase analysis)

### Frontmatter Specification

Always include `context_loading` in frontmatter:
```yaml
context_loading:
  strategy: lazy              # How to load context
  index: ".opencode/context/index.md"  # Context index file
  required:                   # Always load these
    - "core/standards/subagent-return-format.md"
    - "core/system/status-markers.md"
    - "{command_specific_context}"
  optional:                   # Load if needed
    - "{optional_context_1}"
  max_context_size: 50000     # Maximum bytes to load
  cache_strategy: session     # How long to cache
```

---

## Delegation Patterns

### Pattern 1: Simple Delegation
```xml
<stage id="2" name="Delegate">
  <action>Delegate to {subagent} subagent</action>
  <process>
    1. Prepare delegation context (session_id, task_number, etc.)
    2. Invoke {subagent} with task context
    3. Wait for return
  </process>
  <checkpoint>Subagent invoked</checkpoint>
</stage>
```

### Pattern 2: Language-Based Routing
```xml
<stage id="2" name="CheckLanguage">
  <action>Extract language for routing</action>
  <process>
    1. Extract language from task entry in TODO.md
    2. Determine target agent:
       - lean → lean-{operation}-agent
       - markdown → {operation}-agent
       - default → {operation}-agent
    3. If extraction fails, default to "general" with warning
  </process>
  <checkpoint>Routing target determined</checkpoint>
</stage>

<stage id="3" name="Delegate">
  <action>Delegate to language-specific agent</action>
  <process>
    1. Prepare delegation context
    2. Invoke target agent (from CheckLanguage stage)
    3. Wait for return
  </process>
  <checkpoint>Subagent invoked</checkpoint>
</stage>
```

### Pattern 3: Conditional Delegation
```xml
<stage id="2" name="DetermineMode">
  <action>Determine execution mode</action>
  <process>
    1. Check if task has existing plan
    2. If plan exists: mode = "phased", delegate to task-executor
    3. If no plan: mode = "direct", delegate to implementer
  </process>
  <checkpoint>Execution mode determined</checkpoint>
</stage>

<stage id="3" name="Delegate">
  <action>Delegate to appropriate agent</action>
  <process>
    1. Prepare delegation context with mode
    2. Invoke target agent (from DetermineMode stage)
    3. Wait for return
  </process>
  <checkpoint>Subagent invoked</checkpoint>
</stage>
```

---

## Return Format

Commands should return concise summaries to users:

### Success Return
```
{Operation} completed for task {number}.
{brief_1_sentence_overview}
{key_metric}: {value}
{artifact_type}: {artifact_path}
```

Example:
```
Plan created for task 195.
Integrated LeanSearch API research findings into 4-phase implementation.
4 phases, 6 hours estimated.
Plan: .opencode/specs/195_lean_tools/plans/implementation-001.md
```

### Partial Return
```
{Operation} partially completed for task {number}.
{brief_reason}
Resume with: /{command} {number}
```

### Error Return
```
Error: {error_message}

Recommendation: {recovery_instructions}
```

**Token Limit**: All returns must be <100 tokens (~400 characters)

---

## Validation Checklist

Use this checklist when creating or reviewing command files:

### Structure
- [ ] Frontmatter includes all required fields
- [ ] Task input declaration present
- [ ] XML structure complete (context, role, task, workflow, etc.)
- [ ] File size <200 lines (target) or <250 lines (max)

### Context
- [ ] `<context>` has 4 sub-contexts
- [ ] Each sub-context is 1-2 sentences
- [ ] No duplication from frontmatter
- [ ] Focuses on essential information

### Role & Task
- [ ] `<role>` is concise (1 sentence)
- [ ] `<task>` clearly states objective (2-4 sentences)

### Workflow
- [ ] `<workflow_execution>` has clear stages
- [ ] Each stage has id, name, action, process, checkpoint
- [ ] Stages focus on routing, not execution
- [ ] Detailed execution logic is in subagent files

### Supporting Sections
- [ ] `<routing_intelligence>` explains routing logic
- [ ] `<quality_standards>` lists key requirements
- [ ] `<usage_examples>` provides 3-5 examples
- [ ] `<validation>` covers pre/mid/post flight
- [ ] `<error_handling>` covers major error types

### Context Loading
- [ ] `context_loading` frontmatter present
- [ ] Strategy is appropriate (lazy/eager/minimal)
- [ ] Required context files listed
- [ ] max_context_size is reasonable

### References
- [ ] References to detailed docs are clear
- [ ] No duplication of information from context files
- [ ] External references use correct paths

---

## Examples

### Minimal Command (Simple Routing)
See: `.opencode/command/task.md` (after Phase 3 conversion)

### Standard Command (Language Routing)
See: `.opencode/command/implement.md` (after Phase 3 conversion)

### Complex Command (Multi-Stage)
See: `.opencode/command/review.md` (existing, good example)

---

## Anti-Patterns (Avoid These)

### ❌ Detailed Execution Logic in Command
```xml
<stage id="4" name="ExecuteImplementation">
  <action>Execute implementation</action>
  <process>
    1. Read task description
    2. Determine files to modify
    3. For each file:
       a. Read current content
       b. Apply changes
       c. Write updated content
    4. Create implementation summary
    5. Update status to [COMPLETED]
    6. Create git commit
  </process>
</stage>
```
**Problem**: Execution logic belongs in subagent, not command

### ✅ Delegation to Subagent
```xml
<stage id="4" name="Delegate">
  <action>Delegate to implementer subagent</action>
  <process>
    1. Prepare delegation context
    2. Invoke implementer with task context
    3. Wait for return
  </process>
  <checkpoint>Implementer invoked</checkpoint>
</stage>
```

### ❌ Verbose Context
```xml
<context>
  <system_context>
    This command is part of the ProofChecker system which provides comprehensive
    proof checking and verification capabilities built on Lean 4 with extensive
    support for formal verification, theorem proving, and mathematical reasoning
    across multiple domains including logic, algebra, topology, and more...
  </system_context>
</context>
```
**Problem**: Too verbose, includes unnecessary details

### ✅ Concise Context
```xml
<context>
  <system_context>
    Command for creating implementation plans with phased breakdown and status tracking.
  </system_context>
</context>
```

### ❌ Duplicated Information
Command file includes full workflow documentation that's already in subagent file.

**Problem**: Duplication makes maintenance harder

### ✅ Reference to Subagent
```xml
<delegation>
  Detailed implementation workflow in `.opencode/agent/subagents/implementer.md`
  
  Implementer handles:
  - Plan-based vs direct implementation
  - Resume support
  - Artifact creation
  - Status updates
  - Git commits
</delegation>
```

---

## Migration Guide

When converting existing commands to this standard:

1. **Add frontmatter** with all required fields
2. **Add context_loading** section to frontmatter
3. **Wrap content in XML tags** (context, role, task, workflow_execution)
4. **Simplify workflow** to routing stages only
5. **Move detailed logic** to subagent files
6. **Add supporting sections** (routing, quality, validation, errors)
7. **Reduce file size** to <200 lines
8. **Test command** to ensure it still works

---

## References

- **XML Patterns**: `.opencode/context/core/standards/xml-patterns.md`
- **Subagent Structure**: `.opencode/context/core/standards/subagent-structure.md`
- **Context Index**: `.opencode/context/index.md`
- **Error Handling**: `.opencode/context/core/standards/error-handling.md`
- **Examples**: 
  - `.opencode/command/review.md` (existing, good example)
  - `.opencode/command/todo.md` (existing, good example)
  - `.opencode/command/errors.md` (existing, good example)
