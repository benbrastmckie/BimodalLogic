# Command Argument Handling with $ARGUMENTS

## Overview

OpenCode provides a built-in mechanism for passing command arguments from user invocations to command workflows using the **`$ARGUMENTS`** variable pattern.

## The $ARGUMENTS Pattern

### How It Works

When a user invokes a slash command with arguments:

```
/research 197
```

OpenCode automatically:
1. Extracts the command name (`research`)
2. Captures the arguments (`197`)
3. Loads the command file (`.opencode/command/research.md`)
4. **Substitutes `$ARGUMENTS` with the actual arguments** (`197`)
5. Executes the command workflow with arguments available

### Basic Usage

**In Command File Header** (after frontmatter):

```markdown
---
name: research
agent: orchestrator
description: "Conduct research and create reports"
---

**Task Input (required):** $ARGUMENTS (task number; e.g., `/research 197`)
```

**In Workflow Stage 1** (parse and validate):

```markdown
<workflow_execution>
  <stage id="1" name="ParseInput">
    <action>Parse and validate task number</action>
    <process>
      1. Parse task number from $ARGUMENTS
      2. Validate it's an integer
      3. If missing or invalid, return error with usage
      4. Extract optional parameters if present
    </process>
  </stage>
</workflow_execution>
```

## Standard Patterns

### Required Arguments

For commands that MUST have arguments:

```markdown
**Task Input (required):** $ARGUMENTS (description; e.g., `/command ARG`)
```

Examples:
- `/research TASK_NUMBER` → `**Task Input (required):** $ARGUMENTS (task number; e.g., `/research 197`)`
- `/plan TASK_NUMBER` → `**Task Input (required):** $ARGUMENTS (task number; e.g., `/plan 196`)`
- `/implement TASK_NUMBER` → `**Task Input (required):** $ARGUMENTS (task number or range; e.g., `/implement 197`)`
- `/task "DESCRIPTION"` → `**Task Input (required):** $ARGUMENTS (task description; e.g., `/task "Fix bug"`)`

### Optional Arguments

For commands that work with or without arguments:

```markdown
**Task Input (optional):** $ARGUMENTS (description; e.g., `/command` or `/command ARG`)
```

Examples:
- `/errors [FLAGS]` → `**Task Input (optional):** $ARGUMENTS (flags; e.g., `/errors --all`)`
- `/review [SCOPE]` → `**Task Input (optional):** $ARGUMENTS (scope; e.g., `/review Logos/Core`)`

### No Arguments

For commands that don't take arguments, omit the Task Input line:

```markdown
---
name: todo
agent: orchestrator
description: "Show .opencode/specs/TODO.md"
---

Context Loaded:
...
```

## Argument Types and Parsing

### Single Integer

```markdown
**Task Input (required):** $ARGUMENTS (task number; e.g., `/research 197`)
```

**Parsing in Stage 1**:
```markdown
1. Parse task_number from $ARGUMENTS
2. Validate it's an integer
3. If invalid, return: "Error: Task number must be an integer"
```

**User Input**: `/research 197`  
**$ARGUMENTS**: `197`  
**Parsed**: `task_number = 197`

### Integer with Optional Text

```markdown
**Task Input (required):** $ARGUMENTS (task number and optional prompt; e.g., `/research 197 "Focus on X"`)
```

**Parsing in Stage 1**:
```markdown
1. Split $ARGUMENTS on first space
2. First part = task_number (integer)
3. Remaining = optional_prompt (string)
4. Validate task_number is integer
```

**User Input**: `/research 197 "Focus on CLI integration"`  
**$ARGUMENTS**: `197 "Focus on CLI integration"`  
**Parsed**: `task_number = 197`, `prompt = "Focus on CLI integration"`

### Range

```markdown
**Task Input (required):** $ARGUMENTS (task number or range; e.g., `/implement 105-107`)
```

**Parsing in Stage 1**:
```markdown
1. Check if $ARGUMENTS contains "-"
2. If yes, split on "-" to get start and end
3. Validate both are integers
4. If no, parse as single integer
```

**User Input**: `/implement 105-107`  
**$ARGUMENTS**: `105-107`  
**Parsed**: `task_range = [105, 106, 107]`

### Comma-Separated List

```markdown
**Task Input (required):** $ARGUMENTS (task numbers; e.g., `/research 132,134,136`)
```

**Parsing in Stage 1**:
```markdown
1. Split $ARGUMENTS on ","
2. Parse each part as integer
3. Deduplicate and sort
4. Validate all are integers
```

**User Input**: `/research 132,134,136`  
**$ARGUMENTS**: `132,134,136`  
**Parsed**: `task_list = [132, 134, 136]`

### String/Description

```markdown
**Task Input (required):** $ARGUMENTS (description; e.g., `/task "Implement feature X"`)
```

**Parsing in Stage 1**:
```markdown
1. Use entire $ARGUMENTS as description
2. Trim quotes if present
3. Validate not empty
```

**User Input**: `/task "Implement feature X"`  
**$ARGUMENTS**: `"Implement feature X"`  
**Parsed**: `description = "Implement feature X"`

### Flags

```markdown
**Task Input (optional):** $ARGUMENTS (flags; e.g., `/errors --all --type build_error`)
```

**Parsing in Stage 1**:
```markdown
1. Split $ARGUMENTS by spaces
2. Extract tokens starting with "--" as flags
3. Extract tokens not starting with "--" as positional args
4. Parse flag values (--key value pairs)
```

**User Input**: `/errors --all --type delegation_hang`  
**$ARGUMENTS**: `--all --type delegation_hang`  
**Parsed**: `flags = {all: true, type: "delegation_hang"}`

## Error Handling

### Missing Required Arguments

```markdown
<stage id="1" name="ParseInput">
  <process>
    1. Check if $ARGUMENTS is empty or whitespace
    2. If yes, return error:
       "Error: Task number required. Usage: /research TASK_NUMBER [PROMPT]
       
       Examples:
       - /research 197
       - /research 197 'Focus on CLI integration'"
  </process>
</stage>
```

### Invalid Format

```markdown
<stage id="1" name="ParseInput">
  <process>
    1. Parse task_number from $ARGUMENTS
    2. Validate it's an integer
    3. If not, return error:
       "Error: Task number must be an integer. Got: '{$ARGUMENTS}'
       
       Usage: /research TASK_NUMBER
       Example: /research 197"
  </process>
</stage>
```

### Task Not Found

```markdown
<stage id="1" name="ParseInput">
  <process>
    1. Parse and validate task_number
    2. Load task from .opencode/specs/TODO.md
    3. If not found, return error:
       "Error: Task {task_number} not found in .opencode/specs/TODO.md
       
       Please check the task number and try again."
  </process>
</stage>
```

## Complete Example: /research Command

**Command File Header**:

```markdown
---
name: research
agent: orchestrator
description: "Conduct research and create reports"
context_level: 2
---

**Task Input (required):** $ARGUMENTS (task number; e.g., `/research 197`)

Context Loaded:
@.opencode/specs/TODO.md
...
```

**Workflow Stage 1**:

```markdown
<workflow_execution>
  <stage id="1" name="Preflight">
    <action>Parse and validate task number</action>
    <process>
      1. Parse task_number from $ARGUMENTS (first argument)
      2. Validate task_number is an integer
      3. If missing or invalid, return:
         "Error: Task number required. Usage: /research TASK_NUMBER [PROMPT]"
      4. Extract optional prompt from $ARGUMENTS (text after task_number)
      5. Load task from .opencode/specs/TODO.md
      6. If task not found, return:
         "Error: Task {task_number} not found in .opencode/specs/TODO.md"
      7. Proceed with research workflow
    </process>
  </stage>
</workflow_execution>
```

**User Invocation**:
```
/research 197
```

**OpenCode Processing**:
```
1. Command name: "research"
2. Arguments: "197"
3. Load: .opencode/command/research.md
4. Substitute: $ARGUMENTS ← "197"
5. Execute: workflow Stage 1
6. Parse: task_number = 197
7. Continue: research workflow
```

## Commands Using $ARGUMENTS

### Current Command Status

| Command | Arguments | Pattern |
|---------|-----------|---------|
| `/research` | Required | `$ARGUMENTS (task number)` |
| `/plan` | Required | `$ARGUMENTS (task number)` |
| `/implement` | Required | `$ARGUMENTS (task number or range)` |
| `/task` | Required | `$ARGUMENTS (description)` |
| `/revise` | Required | `$ARGUMENTS (task number and optional prompt)` |
| `/errors` | Optional | `$ARGUMENTS (flags)` |
| `/review` | Optional | Not implemented yet |
| `/todo` | None | No $ARGUMENTS |

## Best Practices

### 1. Always Include Task Input Line

For clarity, always add the Task Input line after frontmatter:

```markdown
---
name: command
---

**Task Input (required):** $ARGUMENTS (description)
```

### 2. Parse in Stage 1

Always parse and validate $ARGUMENTS in Stage 1 of workflow:

```markdown
<stage id="1" name="ParseInput">
  <action>Parse and validate arguments</action>
  <process>
    1. Parse from $ARGUMENTS
    2. Validate format and types
    3. Return clear errors if invalid
  </process>
</stage>
```

### 3. Provide Clear Error Messages

Include usage examples in error messages:

```markdown
"Error: Task number required. Usage: /research TASK_NUMBER [PROMPT]

Examples:
- /research 197
- /research 197 'Focus on CLI integration'"
```

### 4. Document Expected Format

In the Task Input line, show expected format:

```markdown
**Task Input (required):** $ARGUMENTS (task number; e.g., `/research 197`)
```

### 5. Handle Edge Cases

- Empty $ARGUMENTS
- Whitespace-only $ARGUMENTS
- Invalid types (string when integer expected)
- Out of range values
- Missing required components

## Testing

### Test Cases

For each command with arguments, test:

1. **Valid single argument**: `/research 197`
2. **Valid with optional**: `/research 197 "prompt"`
3. **Missing required**: `/research` → Should return error
4. **Invalid type**: `/research abc` → Should return error
5. **Not found**: `/research 999999` → Should return error

### Validation Checklist

- [ ] Task Input line present after frontmatter
- [ ] $ARGUMENTS documented with examples
- [ ] Stage 1 parses from $ARGUMENTS
- [ ] Stage 1 validates argument format
- [ ] Clear error messages for all failure cases
- [ ] Usage examples included in errors
- [ ] All test cases pass

## Migration from Old Patterns

If a command used verbose CRITICAL notices or Stage 0 extraction:

**Old (Verbose)**:
```markdown
**CRITICAL**: Extract from user's original message
<stage id="0" name="ExtractUserInput">
  ...20+ lines of extraction logic...
</stage>
```

**New (Clean)**:
```markdown
**Task Input (required):** $ARGUMENTS (task number; e.g., `/research 197`)

<stage id="1" name="ParseInput">
  <process>
    1. Parse task_number from $ARGUMENTS
    2. Validate and proceed
  </process>
</stage>
```

## References

- Old system examples: `.opencode.backup.20251225_173342/command/`
- Orchestrator Stage 1: `.opencode/agent/orchestrator.md`
- Task 198: Investigation and implementation details

## Summary

The `$ARGUMENTS` pattern provides a simple, clean, and proven way to pass command arguments:

- **1 line** in command header instead of 20+
- **Built-in** OpenCode feature, not a workaround
- **Proven** in previous system versions
- **Easy** to maintain and extend

Use it for all commands that take arguments!
