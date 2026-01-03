# Creating Commands Guide

## Overview

This guide provides a comprehensive walkthrough for creating new commands that work seamlessly with the orchestrator in the ProofChecker .opencode system.

## Prerequisites

Before creating a new command, ensure you understand:

1. **Command Types**: Task-based vs. direct commands
2. **Argument Handling**: How `$ARGUMENTS` works
3. **Routing Patterns**: Language-based vs. direct routing
4. **Delegation Flow**: How orchestrator delegates to subagents
5. **Return Format**: Standard subagent return schema

**Required Reading**:
- `.opencode/context/core/standards/command-argument-handling.md`
- `.opencode/context/core/system/routing-logic.md`
- `.opencode/context/core/standards/delegation.md`
- `.opencode/agent/orchestrator.md`

## Step-by-Step Process

### Step 1: Determine Command Type

**Question**: Does your command operate on tasks from TODO.md?

- **YES** → Task-based command (e.g., `/research`, `/plan`, `/implement`)
- **NO** → Direct command (e.g., `/meta`, `/review`, `/errors`)

**Task-Based Commands**:
- Require a task number as first argument
- Extract language from task metadata
- May use language-based routing
- Format prompt as `"Task: {number}"` for subagent

**Direct Commands**:
- May have optional arguments or no arguments
- Don't require task validation
- Pass `$ARGUMENTS` as-is to subagent
- Use direct routing (no language extraction)

### Step 2: Choose Routing Strategy

**Question**: Does your command need different agents for different languages?

- **YES** → Language-based routing (e.g., Lean tasks → lean-research-agent)
- **NO** → Direct routing (e.g., all tasks → planner)

**Language-Based Routing**:
```yaml
routing:
  language_based: true
  lean: lean-research-agent
  default: researcher
```

**Direct Routing**:
```yaml
routing:
  language_based: false
  default: planner
```

### Step 3: Create Command File

Create `.opencode/command/{command-name}.md` with proper frontmatter.

**Template for Task-Based Command**:

```markdown
---
name: {command-name}
agent: orchestrator
description: "{Brief description of what this command does}"
context_level: 2
language: markdown
routing:
  language_based: {true|false}
  lean: {lean-agent-name}  # If language_based: true
  default: {default-agent-name}
timeout: 3600
context_loading:
  strategy: lazy
  index: ".opencode/context/index.md"
  required:
    - "core/standards/delegation.md"
    - "core/system/state-management.md"
    - "core/system/routing-guide.md"
    - "core/standards/command-argument-handling.md"
  optional:
    - "{domain-specific context files}"
  max_context_size: 50000
---

**Task Input (required):** $ARGUMENTS (task number; e.g., `/{command-name} 258`)

**Usage:** `/{command-name} TASK_NUMBER [OPTIONS]`

## Description

{Detailed description of command functionality}

## Workflow Setup

**Orchestrator handles (Stage 1-5):**
- **Stage 1 (PreflightValidation):** Read task number from $ARGUMENTS variable, validate task exists in TODO.md
- **Stage 2 (DetermineRouting):** Extract language from task entry (state.json or TODO.md), map to agent using routing table, validate routing
- **Stage 3 (RegisterAndDelegate):** Register session and invoke target agent
- **Stage 4 (ValidateReturn):** Validate return format, verify artifacts exist and are non-empty
- **Stage 5 (PostflightCleanup):** Update session registry and relay result to user

**{Agent-name} subagent handles:**
- {List of responsibilities}
- Status updates
- Git commits

## Arguments

**Required**:
- `TASK_NUMBER`: Task number from TODO.md

**Optional**:
- `{option}`: {description}

## Examples

```bash
# Basic usage
/{command-name} 258

# With options
/{command-name} 258 --{option}
```

## Error Handling

**Missing task number**:
```
Error: Task number required for /{command-name} command

Usage: /{command-name} <task_number> [options]

Example: /{command-name} 258
```

**Invalid task number**:
```
Error: Task number must be an integer. Got: {input}

Usage: /{command-name} TASK_NUMBER

Example: /{command-name} 258
```

**Task not found**:
```
Error: Task {task_number} not found in TODO.md

Please verify the task number exists in .opencode/specs/TODO.md
```

## See Also

- Command Template: `.opencode/context/core/templates/command-template.md`
- Argument Handling: `.opencode/context/core/standards/command-argument-handling.md`
- Routing Logic: `.opencode/context/core/system/routing-logic.md`
```

**Template for Direct Command**:

```markdown
---
name: {command-name}
agent: orchestrator
description: "{Brief description of what this command does}"
context_level: 2
language: markdown
routing:
  language_based: false
  default: {agent-name}
timeout: 1800
context_loading:
  strategy: lazy
  index: ".opencode/context/index.md"
  required:
    - "core/standards/delegation.md"
    - "core/system/state-management.md"
    - "core/standards/command-argument-handling.md"
  max_context_size: 50000
---

**Task Input (optional):** $ARGUMENTS (user input; e.g., `/{command-name} "options"`)

**Usage:** `/{command-name} [OPTIONS]`

## Description

{Detailed description of command functionality}

## Workflow Setup

**Orchestrator handles (Stage 1-5):**
- **Stage 1 (PreflightValidation):** Read $ARGUMENTS (may be empty), no task validation required
- **Stage 2 (DetermineRouting):** Use routing.default directly (no language extraction)
- **Stage 3 (RegisterAndDelegate):** Register session and invoke target agent with $ARGUMENTS as-is
- **Stage 4 (ValidateReturn):** Validate return format
- **Stage 5 (PostflightCleanup):** Update session registry and relay result to user

**{Agent-name} subagent handles:**
- {List of responsibilities}
- Artifact creation
- Git commits (if applicable)

## Arguments

**Optional**:
- `{option}`: {description}

## Examples

```bash
# No arguments
/{command-name}

# With arguments
/{command-name} {example-args}
```

## See Also

- Command Template: `.opencode/context/core/templates/command-template.md`
- Argument Handling: `.opencode/context/core/standards/command-argument-handling.md`
```

### Step 4: Implement Argument Handling

Follow the standard defined in `.opencode/context/core/standards/command-argument-handling.md`.

**For Task-Based Commands**:

1. **Document $ARGUMENTS**:
   ```markdown
   **Task Input (required):** $ARGUMENTS (task number; e.g., `/{command} 258`)
   ```

2. **Reference Standard**:
   ```markdown
   See: `.opencode/context/core/standards/command-argument-handling.md`
   ```

3. **Orchestrator Handles Parsing**:
   - Stage 1: Extracts task_number from $ARGUMENTS
   - Stage 1: Validates task_number is positive integer
   - Stage 1: Verifies task exists in TODO.md
   - Stage 3: Formats prompt as `"Task: {task_number}"`

**For Direct Commands**:

1. **Document $ARGUMENTS**:
   ```markdown
   **Task Input (optional):** $ARGUMENTS (user input; e.g., `/{command} "options"`)
   ```

2. **Reference Standard**:
   ```markdown
   See: `.opencode/context/core/standards/command-argument-handling.md`
   ```

3. **Orchestrator Handles Parsing**:
   - Stage 1: Reads $ARGUMENTS (may be empty)
   - Stage 3: Passes $ARGUMENTS as-is to subagent

### Step 5: Configure Routing

**For Language-Based Routing**:

```yaml
routing:
  language_based: true
  lean: lean-{agent-name}
  default: {agent-name}
```

**Orchestrator will**:
- Extract language from state.json or TODO.md
- Map language to agent (lean → lean-*, default → general)
- Validate routing before delegation

**For Direct Routing**:

```yaml
routing:
  language_based: false
  default: {agent-name}
```

**Orchestrator will**:
- Use routing.default directly
- Skip language extraction
- Validate agent file exists

### Step 6: Define Context Loading

Specify which context files the subagent needs.

**Required Files** (always include):
```yaml
required:
  - "core/standards/delegation.md"
  - "core/system/state-management.md"
  - "core/standards/command-argument-handling.md"
```

**Optional Files** (domain-specific):
```yaml
optional:
  - "project/lean4/tools/leansearch-api.md"  # For Lean tasks
  - "project/logic/domain/kripke-semantics-overview.md"  # For logic tasks
```

**Budget**:
- Orchestrator: <10% context window (~10KB)
- Commands: 10-20% context window (~20-40KB)
- Agents: 60-80% context window (~120-160KB)

### Step 7: Document Workflow

Clearly document what orchestrator handles vs. what subagent handles.

**Orchestrator Responsibilities** (always the same):
- Stage 1: Parse and validate arguments
- Stage 2: Determine routing
- Stage 3: Register session and delegate
- Stage 4: Validate return
- Stage 5: Cleanup and relay result

**Subagent Responsibilities** (command-specific):
- Execute core workflow
- Create artifacts
- Update status markers
- Commit changes to git

### Step 8: Add Error Handling

Document all error cases with clear messages.

**Required Error Cases**:

1. **Missing Required Arguments**:
   ```
   Error: {argument} required for /{command} command
   
   Usage: /{command} {usage-pattern}
   
   Example: /{command} {example}
   ```

2. **Invalid Argument Format**:
   ```
   Error: {argument} must be {expected-format}. Got: {actual}
   
   Usage: /{command} {usage-pattern}
   
   Example: /{command} {example}
   ```

3. **Task Not Found** (task-based only):
   ```
   Error: Task {task_number} not found in TODO.md
   
   Please verify the task number exists in .opencode/specs/TODO.md
   ```

### Step 9: Add Usage Examples

Provide clear, realistic examples.

**Minimum Examples**:
- Basic usage (required arguments only)
- Usage with optional arguments
- Common use cases

**Example**:
```bash
# Basic usage
/research 258

# With custom prompt
/research 258 "Focus on API integration"

# With flags
/research 258 --divide
```

### Step 10: Test the Command

**Test Cases**:

1. **Valid Arguments**:
   - Test with valid task number
   - Test with optional arguments
   - Verify orchestrator routes correctly
   - Verify subagent receives correct prompt

2. **Invalid Arguments**:
   - Test with missing required arguments
   - Test with invalid argument format
   - Test with non-existent task number
   - Verify error messages are clear

3. **Routing**:
   - Test language extraction (if language-based)
   - Test agent mapping
   - Verify correct agent is invoked

4. **Return Validation**:
   - Verify return format is valid
   - Verify artifacts are created
   - Verify status updates work

**Testing Checklist**:
- [ ] Command file has valid frontmatter
- [ ] $ARGUMENTS documented with examples
- [ ] Reference to command-argument-handling.md included
- [ ] Routing configuration is correct
- [ ] Context loading includes required files
- [ ] Error handling covers all cases
- [ ] Usage examples are clear
- [ ] Command works with orchestrator
- [ ] Subagent receives correct prompt
- [ ] Return validation passes

## Common Patterns

### Pattern 1: Research-Style Command

**Use Case**: Conduct research and create reports

**Characteristics**:
- Task-based (requires task number)
- Language-based routing (Lean vs. general)
- Creates research report artifact
- Updates status to [RESEARCHED]

**Example**: `/research`

### Pattern 2: Planning-Style Command

**Use Case**: Create implementation plans

**Characteristics**:
- Task-based (requires task number)
- Direct routing (planning is language-agnostic)
- Creates plan artifact
- Updates status to [PLANNED]

**Example**: `/plan`

### Pattern 3: Implementation-Style Command

**Use Case**: Execute implementations

**Characteristics**:
- Task-based (requires task number)
- Language-based routing (Lean vs. general)
- Creates code and test artifacts
- Updates status to [IMPLEMENTED]

**Example**: `/implement`

### Pattern 4: Analysis-Style Command

**Use Case**: Analyze codebase or errors

**Characteristics**:
- Direct command (no task number)
- Direct routing (analysis is language-agnostic)
- Creates analysis report
- May update registries

**Example**: `/review`, `/errors`

### Pattern 5: Interactive-Style Command

**Use Case**: Interactive workflows

**Characteristics**:
- Direct command (no task number)
- Direct routing
- May create multiple artifacts
- Stateful interaction

**Example**: `/meta`

## Troubleshooting

### Issue: Orchestrator doesn't recognize command

**Symptom**: Command not found error

**Cause**: Command file doesn't exist or has wrong name

**Solution**:
1. Verify file exists at `.opencode/command/{command-name}.md`
2. Verify filename matches command name
3. Verify frontmatter has `name:` field matching command

### Issue: Subagent doesn't receive task number

**Symptom**: Subagent receives empty prompt or raw $ARGUMENTS

**Cause**: Orchestrator not formatting prompt correctly

**Solution**:
1. Verify command is task-based (requires task number)
2. Verify orchestrator Stage 3 formats prompt as `"Task: {number}"`
3. Check orchestrator logs for prompt formatting

### Issue: Language-based routing not working

**Symptom**: Lean tasks route to general agent

**Cause**: Language extraction failing or routing misconfigured

**Solution**:
1. Verify task has **Language** field in TODO.md
2. Verify routing.language_based is true
3. Verify routing.lean and routing.default are set
4. Check orchestrator logs for language extraction

### Issue: Return validation fails

**Symptom**: "Invalid return format" error

**Cause**: Subagent return doesn't match schema

**Solution**:
1. Verify subagent returns valid JSON
2. Verify all required fields present
3. Verify status is valid enum
4. Verify artifacts exist (if status=completed)
5. Check validation-rules.md for requirements

### Issue: Context loading fails

**Symptom**: "Context file not found" error

**Cause**: Referenced context file doesn't exist

**Solution**:
1. Verify all context files in `required:` exist
2. Check paths are relative to `.opencode/context/`
3. Verify no deprecated file references
4. Check context/index.md for correct paths

## Best Practices

### 1. Follow Naming Conventions

**Commands**: Use lowercase with hyphens (e.g., `my-command`)
**Agents**: Use lowercase with hyphens (e.g., `my-agent`)
**Files**: Match command/agent name exactly

### 2. Keep Commands Focused

Each command should have a single, clear purpose. Don't create "Swiss Army knife" commands.

**Good**: `/research` (conducts research)
**Bad**: `/do-everything` (research, plan, implement, review)

### 3. Document Thoroughly

Include:
- Clear description
- Usage examples
- Error messages
- Workflow breakdown
- See Also references

### 4. Test Edge Cases

Don't just test happy path. Test:
- Missing arguments
- Invalid arguments
- Non-existent tasks
- Empty $ARGUMENTS
- Malformed input

### 5. Use Standard Patterns

Follow existing commands as templates:
- `/research` for research-style commands
- `/plan` for planning-style commands
- `/implement` for implementation-style commands
- `/review` for analysis-style commands
- `/meta` for interactive-style commands

### 6. Validate Early

Validate arguments in Stage 1 (orchestrator handles this). Don't pass invalid data to subagents.

### 7. Provide Clear Errors

Error messages should:
- Explain what went wrong
- Show correct usage
- Provide examples
- Suggest next steps

### 8. Keep Context Minimal

Only load context files actually needed. Don't load "just in case".

### 9. Version Your Changes

When modifying commands:
- Update `updated:` field in frontmatter
- Document changes in commit message
- Update related documentation

### 10. Follow Standards

Always reference and follow:
- `.opencode/context/core/standards/command-argument-handling.md`
- `.opencode/context/core/system/routing-logic.md`
- `.opencode/context/core/standards/delegation.md`

## See Also

- **Command Template**: `.opencode/context/core/templates/command-template.md`
- **Argument Handling**: `.opencode/context/core/standards/command-argument-handling.md`
- **Routing Logic**: `.opencode/context/core/system/routing-logic.md`
- **Validation Rules**: `.opencode/context/core/system/validation-rules.md`
- **Delegation Standard**: `.opencode/context/core/standards/delegation.md`
- **Orchestrator**: `.opencode/agent/orchestrator.md`
- **Standards Quick Reference**: `.opencode/docs/STANDARDS_QUICK_REF.md`

## Quick Reference

### Task-Based Command Checklist

- [ ] Frontmatter with `routing.language_based` configured
- [ ] `**Task Input (required):** $ARGUMENTS (task number; ...)`
- [ ] Reference to command-argument-handling.md
- [ ] Orchestrator handles argument parsing (documented)
- [ ] Error handling for missing/invalid task number
- [ ] Usage examples with task numbers
- [ ] Context loading includes required standards
- [ ] Tested with valid and invalid task numbers

### Direct Command Checklist

- [ ] Frontmatter with `routing.language_based: false`
- [ ] `**Task Input (optional):** $ARGUMENTS (...)`
- [ ] Reference to command-argument-handling.md
- [ ] Orchestrator passes $ARGUMENTS as-is (documented)
- [ ] Error handling for invalid arguments (if applicable)
- [ ] Usage examples with and without arguments
- [ ] Context loading includes required standards
- [ ] Tested with various argument patterns

### Routing Configuration Checklist

- [ ] `routing.language_based` set correctly
- [ ] `routing.lean` defined (if language_based: true)
- [ ] `routing.default` defined
- [ ] Agent files exist at `.opencode/agent/subagents/{agent}.md`
- [ ] Language extraction works (if language_based: true)
- [ ] Routing validation passes

### Context Loading Checklist

- [ ] `strategy: lazy` (for on-demand loading)
- [ ] `index: ".opencode/context/index.md"`
- [ ] Required standards included
- [ ] Optional domain files included (if needed)
- [ ] `max_context_size` set appropriately
- [ ] No deprecated file references
- [ ] All referenced files exist

### Documentation Checklist

- [ ] Clear description
- [ ] Usage pattern documented
- [ ] Examples provided
- [ ] Error messages documented
- [ ] Workflow breakdown included
- [ ] See Also references added
- [ ] Arguments documented
- [ ] Edge cases covered
